import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String image;
  final String category;

  CategoryModel({
    required this.id,
    required this.image,
    required this.category
  });
   factory  CategoryModel.fromSnapshot(DocumentSnapshot snapshot){
     return CategoryModel(
         id: snapshot.id,
         category: snapshot['category'],
         image: snapshot['image']);
   }
  }


