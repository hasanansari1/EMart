import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../color.dart';
import 'BrandModel.dart';

class EditBrand extends StatefulWidget {
  final BrandModel brand;
  final String image;

  const EditBrand({Key? key, required this.brand, required this.image})
      : super(key: key);

  @override
  State<EditBrand> createState() => _EditBrandState();
}

class _EditBrandState extends State<EditBrand> {
  File? selectedImage;
  TextEditingController brandController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    brandController.text = widget.brand.brand.trim();
  }

  Future<void> _updateBrand() async {
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

    DocumentReference brandref =
        FirebaseFirestore.instance.collection('Brands').doc(widget.brand.id);
    Map<String, dynamic> updatedData = {'brand': brandController.text};
    if (selectedImage != null) {
      String imageUrl = await uploadImageToUpload(selectedImage!);
      updatedData['image'] = imageUrl;
    }
    try {
      await brandref.update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Brand added successfully'),
        backgroundColor: Colors.green,
      ));
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to update brands'),
      ));
    }
  }

  bool _validateFields() {
    return brandController.text.isNotEmpty;
  }

  Future<String> uploadImageToUpload(File imageFile) async {
    Reference storageref =
        FirebaseStorage.instance.ref().child('Brand_images/${widget.brand.id}');
    await storageref.putFile(imageFile);
    return await storageref.getDownloadURL();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Edit Brand',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: brandController,
                decoration: InputDecoration(
                    labelText: 'Brand Name',
                    // labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: primaryColor))),
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
                  : Image.network(
                      widget.image,
                      width: 200,
                      height: 200,
                    ),
              const SizedBox(
                height: 20,
              ),
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
                    )),
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
                      await _updateBrand();
                      setState(() {
                        isLoading = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3))),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Update',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
