import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Category/categorymodel.dart';
import '../color.dart';

class AddBrands extends StatefulWidget {
  const AddBrands({super.key});

  @override
  State<AddBrands> createState() => _AddBrandsState();
}

class _AddBrandsState extends State<AddBrands> {
  TextEditingController brandName = TextEditingController();
  String uniquefilename = DateTime.now().millisecondsSinceEpoch.toString();
  String imageUrl = '';
  File? selectedImage;
  bool isLoading = false;
  String? selectedCategory;

  Future<bool> doesSubCategoryExist(String subcategoryName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("Brands")
        .where("brand", isEqualTo: subcategoryName)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> addSubCategoryToFirestore() async {
    final subcategory = brandName.text.trim();
    final category = selectedCategory;

    if (subcategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a brand name")),
      );
      return;
    }
    final doesExist = await doesSubCategoryExist(subcategory);

    if (doesExist) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Brand already exists")),
      );
    } else {
      setState(() {
        isLoading = true;
      });

      if (selectedImage != null) {
        Reference referenceRoot = FirebaseStorage.instance.ref();
        Reference referenceDirImage = referenceRoot.child('Brand_images');
        Reference referenceImageToUpload =
            referenceDirImage.child(uniquefilename);
        try {
          await referenceImageToUpload.putFile(selectedImage!);
          imageUrl = await referenceImageToUpload.getDownloadURL();
          print("Image URL:$imageUrl");

          FirebaseFirestore.instance.collection("Brands").add({
            'brand': brandName.text,
            'image': imageUrl,
            'category': category,
          }).then((value) {
            brandName.clear();
            selectedImage = null;
            selectedCategory = null;
            setState(() {
              isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Brand Added Successfully")));
          });
        } catch (error) {
          print("Error uploading image: $error");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select an image")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Add Brand',
          style: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              CategoryDropdown(
                selectedCategory: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller: brandName,
                decoration: InputDecoration(
                  labelText: 'Brand Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              selectedImage != null
                  ? Image.file(
                      selectedImage!,
                      height: 200,
                      width: 200,
                    )
                  : Image.asset(
                      "assets/image/image5.jpg",
                      height: 200,
                      width: 200,
                    ),

              const SizedBox(height: 20),
              // Button for selecting an image
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    ImagePicker imagePicker = ImagePicker();
                    XFile? file = await imagePicker.pickImage(
                        source: ImageSource.gallery);
                    if (file == null) {
                      return;
                    }
                    selectedImage = File(file.path);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                  child: const Text(
                    'Select Image',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    addSubCategoryToFirestore();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Add Brand',
                          style: TextStyle(color: Colors.white,),
                        ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryDropdown extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;

  const CategoryDropdown(
      {required this.selectedCategory, required this.onChanged, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Categories').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final categoryDocs = snapshot.data!.docs;
          List<CategoryModel> categories = [];

          for (var doc in categoryDocs) {
            final category = CategoryModel.fromSnapshot(doc);
            categories.add(category);
          }

          return DropdownButtonFormField<String>(
            value: selectedCategory,
            onChanged: onChanged,
            decoration: const InputDecoration(
                labelText: 'Select Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor))),
            items: categories.map((CategoryModel category) {
              return DropdownMenuItem<String>(
                value: category.category,
                child: Text(
                  category.category,
                  style: const TextStyle(color: primaryColor),
                ),
              );
            }).toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a Category';
              }
              return null;
            },
          );
        });
  }
}
