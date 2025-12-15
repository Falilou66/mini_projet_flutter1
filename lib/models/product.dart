import 'dart:convert';

class Product {
  int id;
  String nom;
  String description;
  double prix;
  int stockDisponible;
  String dateAjout;

  Product({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    required this.stockDisponible,
    required this.dateAjout,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nom: json['nom'],
      description: json['description'] ?? '',
      prix: double.parse(json['prix'].toString()),
      stockDisponible: json['stock_disponible'],
      dateAjout: json['date_ajout'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'description': description,
        'prix': prix,
        'stock_disponible': stockDisponible,
      };
}
