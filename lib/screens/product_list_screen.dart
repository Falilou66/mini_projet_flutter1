import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/product.dart';
import './product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _productsFuture;
  
  // Détecte automatiquement la plateforme pour choisir la bonne URL.
  final String _baseUrl = kIsWeb 
      ? 'http://localhost:8000/api/' 
      : 'http://10.0.2.2:8000/api/';

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}produits/'));
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Impossible de charger les produits (Code: ${response.statusCode})');
      }
    } catch (e) {
      _showSnackbar('Erreur de connexion: ${e.toString()}', Colors.red);
      return Future.error(e);
    }
  }

  Future<void> _addProduct(String nom, String description, double prix, int stockDisponible) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}produits/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nom': nom, 'description': description, 'prix': prix, 'stock_disponible': stockDisponible}),
    );
    if (response.statusCode == 201) {
      _refreshProducts();
      _showSnackbar('Produit ajouté avec succès !', Colors.green);
    } else {
      _showSnackbar('Erreur lors de l\'ajout du produit', Colors.red);
    }
  }

  Future<void> _updateProduct(int id, String nom, String description, double prix, int stockDisponible) async {
    final response = await http.put(
      Uri.parse('${_baseUrl}produits/$id/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nom': nom, 'description': description, 'prix': prix, 'stock_disponible': stockDisponible}),
    );
    if (response.statusCode == 200) {
      _refreshProducts();
      _showSnackbar('Produit mis à jour !', const Color(0xFF16A085));
    } else {
      _showSnackbar('Erreur lors de la mise à jour', Colors.red);
    }
  }

  Future<void> _deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('${_baseUrl}produits/$id/'));
    if (response.statusCode == 204) {
      _refreshProducts();
      _showSnackbar('Produit supprimé.', Colors.redAccent);
    } else {
      _showSnackbar('Erreur lors de la suppression', Colors.red);
    }
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = _fetchProducts();
    });
  }
  
  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showProductDialog({Product? product}) {
    final nameController = TextEditingController(text: product?.nom ?? '');
    final descriptionController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product?.prix.toString() ?? '');
    final quantityController = TextEditingController(text: product?.stockDisponible.toString() ?? '');
    final isEditing = product != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Modifier le Produit' : 'Ajouter un Produit', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: const Color(0xFF16A085))),
        content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nom du produit', border: OutlineInputBorder(), prefixIcon: Icon(Icons.label_important_outline)), autofocus: true),
                const SizedBox(height: 16),
                TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description_outlined))),
                const SizedBox(height: 16),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Prix (FCFA)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.money)), keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'Stock Disponible', border: OutlineInputBorder(), prefixIcon: Icon(Icons.inventory_2_outlined)), keyboardType: TextInputType.number),
              ],
            ),
          ),
        actions: [
          TextButton(child: const Text('Annuler'), onPressed: () => Navigator.of(context).pop()),
          ElevatedButton(
            child: Text(isEditing ? 'Mettre à jour' : 'Ajouter'),
            onPressed: () {
              final name = nameController.text;
              final description = descriptionController.text;
              final price = double.tryParse(priceController.text) ?? 0.0;
              final quantity = int.tryParse(quantityController.text) ?? 0;

              if (name.isNotEmpty) {
                if (isEditing) {
                  _updateProduct(product.id, name, description, price, quantity);
                } else {
                  _addProduct(name, description, price, quantity);
                }
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion de Stock'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshProducts, tooltip: 'Rafraîchir')]),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          } else {
            return _buildProductList(snapshot.data!);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        tooltip: 'Ajouter un produit',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('Aucun produit trouvé', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          ElevatedButton.icon(onPressed: _refreshProducts, icon: const Icon(Icons.refresh), label: const Text("Réessayer") )
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildProductCard(products[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final stockColor = product.stockDisponible <= 10 ? Colors.orange.shade800 : const Color(0xFF16A085);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
        ).then((_) => _refreshProducts()),
        child: Row(
          children: [
            Container(
              width: 90, height: 100, color: stockColor.withOpacity(0.15),
              child: Icon(Icons.laptop_chromebook_outlined, color: stockColor, size: 40),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(product.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text('${product.prix.toInt()} FCFA', style: TextStyle(fontSize: 15, color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('x${product.stockDisponible}', style: GoogleFonts.robotoMono(fontSize: 22, fontWeight: FontWeight.bold, color: stockColor)),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showProductDialog(product: product);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(product);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Modifier'))),
                const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete), title: Text('Supprimer'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Confirmation"),
        content: Text("Voulez-vous vraiment supprimer '${product.nom}' ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Non")),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              _deleteProduct(product.id);
            },
            child: const Text("Oui"),
          ),
        ],
      ),
    );
  }
}
