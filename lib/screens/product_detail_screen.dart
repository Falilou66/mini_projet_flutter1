import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            floating: false,
            stretch: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                product.nom,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              background: Container(
                 decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Theme.of(context).colorScheme.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildInfoCards(context),
                  const SizedBox(height: 20),
                  _buildDescriptionCard(context),
                   const SizedBox(height: 20),
                  _buildDateCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context) {
    final stockStatusColor = product.stockDisponible <= 10 ? Colors.orange.shade800 : const Color(0xFF16A085);
    final formattedPrice = '${product.prix.toInt()} FCFA';

    return Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(Icons.sell_outlined, color: Colors.blueGrey, size: 30),
              title: const Text('Prix de vente', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
              trailing: Text(
                formattedPrice,
                style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800),
              ),
            ),
             const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Icon(Icons.inventory_2_outlined, color: stockStatusColor, size: 30),
              title: const Text('Stock Disponible', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
              trailing: Text(
                '${product.stockDisponible} Unités',
                style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: stockStatusColor),
              ),
            ),
          ],
        ));
  }

  Widget _buildDescriptionCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const Divider(height: 20, thickness: 1),
            Text(
              product.description.isNotEmpty ? product.description : "Aucune description pour ce produit.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildDateCard(BuildContext context) {
    final formattedDate = DateFormat.yMMMMd('fr_FR').add_jm().format(DateTime.parse(product.dateAjout));
    return Card(
      elevation: 2,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 24),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  'Date d\'ajout',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
