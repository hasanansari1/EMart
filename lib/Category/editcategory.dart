import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../color.dart';
import 'categoryModel.dart';

class EditCategory extends StatefulWidget {
  final CategoryModel category;
  final String image;

  const EditCategory({Key? key, required this.category, required this.image})
      : super(key: key);

  @override
  State<EditCategory> createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  File? selectedImage;
  TextEditingController categoryController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    categoryController.text = widget.category.category.trim();
  }

  Future<void> _updateCategory() async {
    if (!_validateFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    DocumentReference categoryRef = FirebaseFirestore.instance
        .collection('Categories')
        .doc(widget.category.id);

    Map<String, dynamic> updatedData = {
      'category': categoryController.text,
    };
    if (selectedImage != null) {
      String imageUrl = await uploadImageToStorage(selectedImage!);
      updatedData['image'] = imageUrl;
    }
    try {
      await categoryRef.update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Category Updated Successfully'),
        backgroundColor: primaryColor,
      ));
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to update category'),
      ));
    }
  }

  bool _validateFields() {
    return categoryController.text.isNotEmpty;
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('Categories_image/${widget.category.id}');
    await storageRef.putFile(imageFile);
    return await storageRef.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Edit Category',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: primaryColor
          // elevation: 20,
          ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                      labelText: 'Category Name',
                      // labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: primaryColor))),
                ),
              ),
              const SizedBox(
                height: 30,
              ),

              selectedImage != null
                  ? Image.file(
                      selectedImage!,
                      height: 200,
                      width: 200,
                    )
                  : Image.network(
                      widget.image,
                      width: 200,
                      height: 200,
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
                  style:
                      ElevatedButton.styleFrom(backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)
                      )
                      
                      ),
                  child: const Text(
                    'Select Image',
                    style: TextStyle(
                        color: Colors.white,
                        ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await _updateCategory();
                    setState(() {
                      isLoading = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
