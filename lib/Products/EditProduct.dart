import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../color.dart';
import 'ProductModel.dart';

class EditProduct extends StatefulWidget {
  final ProductModel product;
  final String images;
  const EditProduct({
    Key? key,
    required this.product,
    required this.images,
  }) : super(key: key);

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  String? selectCategory;
  String? selectBrand;
  String? selectedCategory;
  List<File>? selectedImage;
  String? selectedBrand;
  TextEditingController categoryController = TextEditingController();
  TextEditingController subCategoryController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  // final TextEditingController deliveryController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController title1Controller = TextEditingController();
  final TextEditingController product1Controller = TextEditingController();
  final TextEditingController title2Controller = TextEditingController();
  final TextEditingController product2Controller = TextEditingController();
  final TextEditingController title3Controller = TextEditingController();
  final TextEditingController product3Controller = TextEditingController();
  final TextEditingController title4Controller = TextEditingController();
  final TextEditingController product4Controller = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController newpriceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController productAllDetailsController =
      TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectCategory = widget.product.category.toString().trim();
    selectedBrand = widget.product.brand.toString().trim();
    productNameController.text = widget.product.productName.toString().trim();
    priceController.text = widget.product.productPrice.toString().trim();
    colorController.text = widget.product.color.toString().trim();
    title1Controller.text = widget.product.title1.toString();
    product1Controller.text = widget.product.product1.toString().trim();
    title2Controller.text = widget.product.title2.toString().trim();
    product2Controller.text = widget.product.product2.toString().trim();
    title3Controller.text = widget.product.title3.toString().trim();
    product3Controller.text = widget.product.product3.toString().trim();
    title4Controller.text = widget.product.title4.toString().trim();
    product4Controller.text = widget.product.product4.toString().trim();
    descriptionController.text =
        widget.product.productDescription.toString().trim();
    newpriceController.text = widget.product.newPrice.toString().trim();
    discountController.text = widget.product.discount.toString().trim();
    productAllDetailsController.text =
        widget.product.itemdetails.toString().trim();
  }

  Future<void> _updateProduct() async {
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

    DocumentReference productRef = FirebaseFirestore.instance
        .collection('Products')
        .doc(widget.product.id);

    List<String> imageUrls = [];

    if (selectedImage != null) {
      for (File imageFile in selectedImage!) {
        String imageUrl = await uploadImageToStorage(imageFile);
        imageUrls.add(imageUrl);
      }
    }

    Map<String, dynamic> updatedData = {
      'productName': productNameController.text.trim(),
      'price': priceController.text.trim(),
      'discount': discountController.text.trim(),
      'productNewPrice': newpriceController.text.trim(),
      // 'Delivery': deliveryController.text.trim(),
      'productColor': colorController.text.trim(),
      'productTitleDetail1': product1Controller.text.trim(),
      'productTitleDetail2': product2Controller.text.trim(),
      'productTitleDetail3': product3Controller.text.trim(),
      'productTitleDetail4': product4Controller.text.trim(),
      'productTitle1': title1Controller.text.trim(),
      'productTitle2': title2Controller.text.trim(),
      'productTitle3': title3Controller.text.trim(),
      'productTitle4': title4Controller.text.trim(),
      'productDescription': descriptionController.text.trim(),
      'itemdetails': productAllDetailsController.text.trim(),
      if (imageUrls.isNotEmpty) 'images': imageUrls,
    };

    try {
      await productRef.update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product Edited Successfully'),
          backgroundColor: primaryColor,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update product'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _validateFields() {
    return productNameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        discountController.text.isNotEmpty &&
        newpriceController.text.isNotEmpty &&
        // deliveryController.text.isNotEmpty &&
        colorController.text.isNotEmpty &&
        product1Controller.text.isNotEmpty &&
        title1Controller.text.isNotEmpty &&
        product2Controller.text.isNotEmpty &&
        title2Controller.text.isNotEmpty &&
        product3Controller.text.isNotEmpty &&
        title3Controller.text.isNotEmpty &&
        product4Controller.text.isNotEmpty &&
        title4Controller.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        productAllDetailsController.text.isNotEmpty;
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef =
        FirebaseStorage.instance.ref().child('Product_images/$fileName');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await storageSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Edit Product',
          style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),

              if (selectedImage != null && selectedImage!.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedImage!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 200, // Set a fixed width for each image
                          child: Image.file(selectedImage![index],
                              height: 200, width: 200),
                        ),
                      );
                    },
                  ),
                )
              else
                Image.network(
                  widget.images,
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
                    List<XFile>? files = await imagePicker.pickMultiImage();
                    selectedImage =
                        files.map((file) => File(file.path)).toList();
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                  child: const Text(
                    'Select Images',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller: productNameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  // labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  // labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller: discountController,
                decoration: InputDecoration(
                  labelText: 'Discount',
                  // labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller: newpriceController,
                decoration: InputDecoration(
                  labelText: 'New Price',
                  // labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // TextFormField(
              //   controller: deliveryController,
              //   decoration: InputDecoration(
              //     labelText: 'Edit Delivery',
              //     // labelStyle: const TextStyle(color: Colors.black),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(3),
              //     ),
              //     focusedBorder: const OutlineInputBorder(
              //       borderRadius: BorderRadius.all(Radius.circular(10)),
              //       borderSide: BorderSide(color: primaryColor),
              //     ),
              //   ),
              // ),
              // const SizedBox(
              //   height: 20,
              // ),

              TextFormField(
                controller: colorController,
                decoration: InputDecoration(
                  labelText: 'Edit Color',
                  // labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller: title1Controller,
                decoration: InputDecoration(
                  labelText: 'Title 1',
                  // labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: product1Controller,
                decoration: InputDecoration(
                  labelText: 'Product 1',
                  // labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller: title2Controller,
                decoration: InputDecoration(
                  labelText: 'Title 2',
                  // labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller: product2Controller,
                decoration: InputDecoration(
                  labelText: 'Product 2',
                  // labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller: title3Controller,
                decoration: InputDecoration(
                  labelText: 'Title 3',
                  // labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller: product3Controller,
                decoration: InputDecoration(
                  labelText: 'Product 3',
                  // labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller: title4Controller,
                decoration: InputDecoration(
                  labelText: 'Title 4',
                  // labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller: product4Controller,
                decoration: InputDecoration(
                  labelText: 'Product 4',
                  // labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Edit Description',
                  // labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              // const SizedBox(height: 20,),
              const SizedBox(
                height: 25,
              ),

              TextFormField(
                controller: productAllDetailsController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "All Details",
                  hintText: 'About this item',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
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
                    await _updateProduct();
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
