import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../color.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  TextEditingController categoryName = TextEditingController();
  String uniquefilename = DateTime.now().millisecondsSinceEpoch.toString();
  String imageUrl = '';
  File? selectedImage;
  bool isLoading = false;
  String? selectedCategory;

  Future<bool> doesCategoryExist(String categoryName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("Categories")
        .where("category", isEqualTo: categoryName)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> addCategoryToFirestore() async {
    final category = categoryName.text.trim();

    if (category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a category name")),
      );
      return;
    }
    final doesExist = await doesCategoryExist(category);

    if (doesExist) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Category already exist")),
      );
    } else {
      setState(() {
        isLoading = true;
      });
      if (selectedImage != null) {
        Reference referenceRoot = FirebaseStorage.instance.ref();
        Reference referenceDirImage = referenceRoot.child('Category_images');
        Reference referenceImageToUpload =
            referenceDirImage.child(uniquefilename);
        try {
          await referenceImageToUpload.putFile(selectedImage!);
          imageUrl = await referenceImageToUpload.getDownloadURL();
          print("Image URL:$imageUrl");

          FirebaseFirestore.instance.collection("Categories").add({
            'category': categoryName.text,
            'image': imageUrl,
          }).then((value) {
            categoryName.clear();
            selectedImage = null;
            setState(() {
              isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Category Added Successfully")));
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
          'Add Category',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
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
              TextFormField(
                controller: categoryName,
                decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3)),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      borderSide: BorderSide(color: primaryColor),
                    )),
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
                    if (file == null) return;
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
                    addCategoryToFirestore();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Add Category',
                          style: TextStyle(
                            color: Colors.white,
                          ),
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
