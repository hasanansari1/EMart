import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Auth/login.dart';
import 'Brands/brands.dart';
import 'Category/category.dart';
import 'Home_Admin/orders.dart';
import 'Home_Admin/users.dart';
import 'Products/products.dart';
import 'Provider.dart';
import 'Sales/Sales.dart';
import 'color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<bool> _onWillPop() async {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      // If drawer is open, close it and prevent exiting the app
      _scaffoldKey.currentState!.openEndDrawer();
      return false;
    } else {
      // If drawer is closed, show exit confirmation dialog
      return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(
                'Exit E-Mart?',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
              ),
              content: const Text(
                'Are you sure you want to exit the app?',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          )) ??
          false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'E-Mart',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: primaryColor,
          centerTitle: true,
        ),
        drawer: SizedBox(
          width: MediaQuery.of(context).size.width * 0.55,
          child: Drawer(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  decoration: const BoxDecoration(color: primaryColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          "assets/image/emart.png",
                          height: 80,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Profile',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            fontStyle: FontStyle.italic),
                      )
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: const Text('Orders'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderListScreenSeller()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.nightlight),
                  title: const Text('Theme'),
                  onTap: () {
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleTheme();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text("Logout"),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star_rate),
                  title: const Text('Rate Us'),
                  onTap: () {},
                )
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          // physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    "assets/image/emart.png",
                    height: 100,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 20.0,
                  crossAxisSpacing: 20.0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(6, (index) {
                    List<Map<String, dynamic>> cardData = [
                      {
                        "image": "assets/images/application.png",
                        "text": "Category",
                        "onTap": _openCategoryScreen,
                      },
                      {
                        "image": "assets/images/categories.png",
                        "text": "Brands",
                        "onTap": _openSubCategoryScreen,
                      },
                      {
                        "image": "assets/images/product.png",
                        "text": "Products",
                        "onTap": _openProductsScreen,
                      },
                      {
                        "image": "assets/images/sale.png",
                        "text": "Sales",
                        "onTap": _openBannerScreen,
                      },
                      {
                        "image": "assets/images/orders.png",
                        "text": "Orders",
                        "onTap": _openOrderScreen,
                      },
                      {
                        "image": "assets/images/users.png",
                        "text": "Users",
                        "onTap": _openUsersScreen,
                      },
                    ];
                    return GestureDetector(
                      onTap: cardData[index]["onTap"],
                      child: Card(
                        color: primaryColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              cardData[index]["image"],
                              height: 48.0,
                              width: 48.0,
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              cardData[index]["text"],
                              style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openCategoryScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CategoryScreen()),
    );
  }

  void _openSubCategoryScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SubCategoryScreen()),
    );
  }

  void _openProductsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProductScreen()),
    );
  }

  void _openBannerScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SalesScreen()),
    );
  }

  void _openOrderScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => OrderListScreenSeller()),
    );
  }

  void _openUsersScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const UsersScreen()),
    );
  }
}
