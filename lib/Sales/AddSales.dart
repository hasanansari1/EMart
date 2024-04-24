import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../color.dart';

class AddSales extends StatefulWidget {
  const AddSales({super.key});

  @override
  State<AddSales> createState() => _AddSalesState();
}

class _AddSalesState extends State<AddSales> {
  TextEditingController salesName = TextEditingController();
  String uniquefilename = DateTime.now().millisecondsSinceEpoch.toString();
  String imageUrl = '';
  File? selectedImage;
  bool isLoading = false;
  String? selectedSales;

  Future<bool> doesSalesExist(String salesName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Sales')
        .where("sales", isEqualTo: salesName)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> addSalesToFirestore() async {
    final sale = salesName.text.trim();

    if (sale.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter Sale'),
      ));
      return;
    }
    final doesExist = await doesSalesExist(sale);

    if (doesExist) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale Already Exist')),
      );
    } else {
      setState(() {
        isLoading = true;
      });

      if (selectedImage != null) {
        Reference referenceRoot = FirebaseStorage.instance.ref();
        Reference referenceDirImages = referenceRoot.child('Sales_images');
        Reference referenceImageToUpload =
            referenceDirImages.child(uniquefilename);

        try {
          await referenceImageToUpload.putFile(selectedImage!);
          imageUrl = await referenceImageToUpload.getDownloadURL();
          print("Image URL:$imageUrl");

          FirebaseFirestore.instance.collection('Sales').add({
            'sales': salesName.text,
            'image': imageUrl,
          }).then((value) {
            salesName.clear();
            selectedImage = null;
            setState(() {
              isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Sales Added Successfully"),
            ));
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
          'Add Sales',
          style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.white
              // color: Colors.black
              ),
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
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: salesName,
                decoration: InputDecoration(
                    labelText: 'Sale',
                    // labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                    addSalesToFirestore();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Add Sale',
                          style: TextStyle(
                            color: Colors.white,
                          ),
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
