import 'package:cloud_firestore/cloud_firestore.dart';

class BrandModel {
  final String id;
  final String image;
  final String category;
  final String brand;

  BrandModel({required this.id, required, required this.image,
  required this.category,
  required this.brand,});

  factory BrandModel.fromSnapshot(DocumentSnapshot snapshot){
    return BrandModel(
    id: snapshot.id,
    category: snapshot['category'],
    brand:snapshot['brand'],
    image: snapshot['image'],
    );
  }
}
