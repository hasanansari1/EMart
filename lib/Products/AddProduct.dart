import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Brands/BrandModel.dart';
import '../Brands/addbrands.dart';
import '../color.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String? selectedSubCategory;
  String? selectedCategory;
  String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
  List<File> selectedImage = [];
  bool isLoading = false;

  TextEditingController productNameController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController productNewPriceController = TextEditingController();
  TextEditingController productColorController = TextEditingController();
  TextEditingController productTitle1Controller = TextEditingController();
  TextEditingController productDetail1Controller = TextEditingController();
  TextEditingController productTitle2Controller = TextEditingController();
  TextEditingController productDetail2Controller = TextEditingController();
  TextEditingController productTitle3Controller = TextEditingController();
  TextEditingController productDetail3Controller = TextEditingController();
  TextEditingController productTitle4Controller = TextEditingController();
  TextEditingController productDetail4Controller = TextEditingController();
  TextEditingController productAllDetailsController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();

  // Generate a unique productId
  final productId = FirebaseFirestore.instance.collection("Products").doc().id;

  Future<bool> doesProductExist(String productName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("Products")
        .where("productName", isEqualTo: productName)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> addProductsToFireStore() async {
    final category = selectedCategory;
    final subcategory = selectedSubCategory;
    final productName = productNameController.text.trim();
    final productPrice = productPriceController.text.trim();
    final productDiscount = discountController.text.trim();
    final productNewPrice = productNewPriceController.text.trim();
    final color = productColorController.text.trim();
    final productTitle1 = productTitle1Controller.text.trim();
    final productTitle2 = productTitle2Controller.text.trim();
    final productTitle3 = productTitle3Controller.text.trim();
    final productTitle4 = productTitle4Controller.text.trim();
    final productDetail1 = productDetail1Controller.text.trim();
    final productDetail2 = productDetail2Controller.text.trim();
    final productDetail3 = productDetail3Controller.text.trim();
    final productDetail4 = productDetail4Controller.text.trim();
    final allProduct = productAllDetailsController.text.trim();

    final description = productDescriptionController.text.trim();

    if (category == null || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select Category")),
      );
      return;
    }
    if (subcategory == null || subcategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select SubCategory")),
      );
      return;
    }
    if (productName.isEmpty ||
        productPrice.isEmpty ||
        productDiscount.isEmpty ||
        productNewPrice.isEmpty ||
        color.isEmpty ||
        productTitle1.isEmpty ||
        productTitle2.isEmpty ||
        productTitle3.isEmpty ||
        productTitle4.isEmpty ||
        productDetail1.isEmpty ||
        productDetail2.isEmpty ||
        productDetail3.isEmpty ||
        productDetail4.isEmpty ||
        allProduct.isEmpty ||
        description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Enter Field")),
      );
      return;
    }
    final doesExist = doesProductExist(productName);

    if (await doesExist) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Enter Product Name")),
      );
    } else {
      setState(() {
        isLoading = true;
      });
      if (selectedImage.isNotEmpty) {
        Reference referenceRoot = FirebaseStorage.instance.ref();
        Reference referenceDirImages = referenceRoot.child('Product_images');
        try {
          final List<String> imageUrls = [];
          for (var i = 0; i < selectedImage.length; i++) {
            Reference referenceImageToUpload =
                referenceDirImages.child('$uniqueFileName-$i');

            await referenceImageToUpload.putFile(selectedImage[i]);

            // Get the download URL for each image
            String imageUrl = await referenceImageToUpload.getDownloadURL();
            imageUrls.add(imageUrl);
          }
          // Print URLs to the debug console
          print('Image URLs:');
          for (var url in imageUrls) {
            print(url);
          }
          FirebaseFirestore.instance.collection("Products").add({
            'productId': productId, // Add productId to the document
            'category': category,
            'brand': subcategory,
            'productName': productName,
            'productPrice': productPrice,
            'productColor': color,
            'productDescription': description,
            'productTitle1': productTitle1,
            'productTitle2': productTitle2,
            'productTitle3': productTitle3,
            'productTitle4': productTitle4,
            'productTitleDetail1': productDetail1,
            'productTitleDetail2': productDetail2,
            'productTitleDetail3': productDetail3,
            'productTitleDetail4': productDetail4,
            'discount': productDiscount,
            'productNewPrice': productNewPrice,
            'itemdetails': allProduct,
            'images': imageUrls,
          }).then((value) {
            selectedImage.clear();
            setState(() {
              isLoading = false;
            });

            productNameController.clear();
            productPriceController.clear();
            discountController.clear();
            productNewPriceController.clear();
            productColorController.clear();
            productTitle1Controller.clear();
            productTitle2Controller.clear();
            productTitle3Controller.clear();
            productTitle4Controller.clear();
            productDetail1Controller.clear();
            productDetail2Controller.clear();
            productDetail3Controller.clear();
            productDetail4Controller.clear();
            productAllDetailsController.clear();
            productDescriptionController.clear();
            selectedCategory = null;
            selectedSubCategory = null;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Product Added Successfully")),
            );
          });
        } catch (error) {
          print("Error Uploading Image $error");
        }
        ;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please Select Images")),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        title: const Text(
          "Add Products",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              SizedBox(
                height: 180,
                width: 300,
                child: selectedImage.isNotEmpty
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImage.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(
                              selectedImage[index],
                              width: 100,
                              height: 100,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        "assets/image/image5.jpg",
                        width: 300,
                        height: 300,
                        // fit: BoxFit.cover,
                      ),
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
                      "Select Images",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
              CategoryDropdown(
                selectedCategory: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                    selectedSubCategory =
                        null; // Reset subcategory when category changes
                  });
                },
              ),
              const SizedBox(height: 20),
              BrandDropDown(
                selectedCategory: selectedCategory,
                selectedSubCategory: selectedSubCategory,
                onChanged: (value) {
                  setState(() {
                    selectedSubCategory = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                controller: productNameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: primaryColor)),
                  hintText: "Product Name",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                controller: productPriceController,
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: InputDecoration(
                  labelText: 'Product Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: primaryColor)),
                  hintText: "Product Price",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                controller: discountController,
                decoration: InputDecoration(
                  labelText: 'Discount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: primaryColor)),
                  hintText: "Discount",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                controller: productNewPriceController,
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: InputDecoration(
                  labelText: 'New Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: primaryColor)),
                  hintText: "Product New Price",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                controller: productColorController,
                decoration: InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: primaryColor)),
                  hintText: "Product Color",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                controller: productTitle1Controller,
                decoration: InputDecoration(
                  labelText: 'Product Title 1',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color:primaryColor)),
                  hintText: "Product Title 1",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: productDetail1Controller,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                decoration: InputDecoration(
                  labelText: 'Product Detail 1',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: primaryColor)),
                  hintText: "Product Detail1",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                controller: productTitle2Controller,
                decoration: InputDecoration(
                  labelText: 'Product Title 2',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: primaryColor)),
                  hintText: "Product Title 2",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                controller: productDetail2Controller,
                decoration: InputDecoration(
                  labelText: 'Product Detail 2',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: primaryColor)),
                  hintText: "Product Detail2",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                controller: productTitle3Controller,
                decoration: InputDecoration(
                  labelText: 'Product Title 3',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: primaryColor)),
                  hintText: "Product Title 3",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                controller: productDetail3Controller,
                decoration: InputDecoration(
                  labelText: 'Product Detail 3',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: primaryColor)),
                  hintText: "Product Detail3",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                controller: productTitle4Controller,
                decoration: InputDecoration(
                  labelText: 'Product Title 4',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: primaryColor)),
                  hintText: "Product Title 4",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                controller: productDetail4Controller,
                decoration: InputDecoration(
                  labelText: 'Product Detail 4',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: primaryColor)),
                  hintText: "Product Detail4",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                controller: productDescriptionController,
                // controller: productDescriptionController,
                maxLines:
                    3, // Adjust the number of lines according to your design
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  hintText: "Product Description",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                controller: productAllDetailsController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'All Details',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: primaryColor)),
                  hintText: "All Detail",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      addProductsToFireStore();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3))),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Add Product",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          )),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BrandDropDown extends StatelessWidget {
  final String? selectedSubCategory;
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;

  const BrandDropDown(
      {required this.selectedSubCategory,
      required this.onChanged,
      required this.selectedCategory,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Brands').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final brandDocs = snapshot.data!.docs;
          List<BrandModel> brands = [];

          for (var doc in brandDocs) {
            final brand = BrandModel.fromSnapshot(doc);

            if (brand.category == selectedCategory) {
              brands.add(brand);
            }
          }
          return DropdownButtonFormField<String>(
            value: selectedSubCategory,
            onChanged: onChanged,
            decoration: const InputDecoration(
              labelText: 'Select Brand',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
            items: brands.map((BrandModel brand) {
              return DropdownMenuItem<String>(
                value: brand.brand,
                child: Text(
                  brand.brand,
                  style: const TextStyle(color: primaryColor),
                ),
              );
            }).toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a Brand';
              }
              return null;
            },
          );
        });
  }
}
