import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:rental_car_project/screen/Categories/ElectricCar.dart';
import 'package:rental_car_project/screen/Categories/HatchBack.dart';
import 'package:rental_car_project/screen/Categories/Luxury.dart';
import 'package:rental_car_project/screen/Categories/PickUp.dart';
import 'package:rental_car_project/screen/Categories/SedanCar.dart';
import 'package:rental_car_project/screen/Categories/SportCar.dart';
import 'package:rental_car_project/screen/Categories/SuvCars.dart';
import 'package:rental_car_project/screen/Categories/all_cars.dart';

import 'package:rental_car_project/utilities/car.dart';

import 'package:rental_car_project/screen/CarDetails.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  Future<Map<String, dynamic>?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc.data();
      }
    }

    return null;
  }

  Future<List<Car>> fetchCars() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://680c930b2ea307e081d45573.mockapi.io/rent4u/api/cars',
        ),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((car) => Car.fromJson(car)).toList();
      } else {
        if (kDebugMode) {
          print('Server error: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Connection error: $e');
      }
      return [];
    }
  }

  void filterCars() {
    final regex = RegExp(searchvalue, caseSensitive: false);
    setState(() {
      filteredCars = cars.where((car) {
        return regex.hasMatch(car.brand) || regex.hasMatch(car.model);
      }).toList();
    });
  }

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadUserData();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    fetchCars().then((carList) {
      setState(() {
        cars = carList;
      });
    }).catchError((error) {
      print('Error fetching cars: $error');
    });
  }

  void loadUserData() async {
    userData = await getUserData();
  }

  final categories = [
    "All",
    "Sedan",
    "SUV",
    "Hatchback",
    "Pickup",
    "Luxury",
    "Electric",
    "Sports Car",
  ];
  int pageindex = 1;
  List<Car> cars = [];
  int selectedIndex = 0;
  TextEditingController searchController = TextEditingController();
  List<Car> filteredCars = [];
  String searchvalue = "";
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double paddingHorizontal = screenWidth * 0.05;
    double verticalSpacing = screenHeight * 0.025;
    double fontSizeTitle = screenWidth * 0.06;
    double fontSizeSubtitle = screenWidth * 0.04;

    return Scaffold(
      extendBodyBehindAppBar: true,
      key: scaffoldkey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              width: screenWidth,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 36, 14, 144),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        left: screenHeight * 0.01, top: screenHeight * 0.1),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text(
                                ("Hello,  ").tr(),
                                style: GoogleFonts.outfit(
                                  fontSize: fontSizeTitle,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${userData?['fullName']}",
                                style: GoogleFonts.outfit(
                                  fontSize: fontSizeTitle,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Text(
                            "Find your dream car".tr(),
                            style: GoogleFonts.outfit(
                              fontSize: fontSizeSubtitle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: verticalSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.search, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: screenHeight * 0.05,
                          child: TextField(
                            onSubmitted: (value) {
                              setState(() {
                                searchvalue = value;
                                filterCars();
                              });
                            },
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: '  Search for your dream cars...'.tr(),
                              hintStyle: GoogleFonts.outfit(
                                color: Colors.black,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(
                left: paddingHorizontal,
                top: verticalSpacing,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Katogeriler
                  if (searchvalue != "") ...[
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: verticalSpacing - 4),
                      child: Column(
                        children: [
                          if (filteredCars.length == 0) ...[
                            Text(
                              'No cars found for your search'.tr(),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ] else ...[
                            Center(
                              child: Text(
                                'Search Results for: "${searchvalue} ",\n You have ${filteredCars.length} cars in your search result',
                                style: GoogleFonts.outfit(
                                  fontSize: fontSizeSubtitle,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            for (int i = 0; i < filteredCars.length; i++)
                              MaterialButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Cardetails(
                                        car: filteredCars,
                                        index: i,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: screenWidth * 0.9,
                                  margin: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Color.fromARGB(255, 36, 14, 144),
                                      width: 2,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        filteredCars[i].image,
                                        fit: BoxFit.cover,
                                        width: screenWidth * 0.2,
                                        height: screenHeight * 0.1,
                                      ),
                                    ),
                                    title: Text(
                                      "${filteredCars[i].brand} ${filteredCars[i].model}",
                                      style: GoogleFonts.outfit(
                                        fontSize: fontSizeSubtitle,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "\$${filteredCars[i].price} / day",
                                      style: GoogleFonts.outfit(
                                        fontSize: fontSizeSubtitle - 2,
                                        color: Color.fromARGB(255, 36, 14, 144),
                                      ),
                                    ),
                                    trailing: Icon(Icons.arrow_forward_ios),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Cardetails(
                                            car: filteredCars,
                                            index: i,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ] else if (categories[selectedIndex] == 'All') ...[
                    buildCategories(context, categories, selectedIndex, (
                      int index,
                    ) {
                      setState(() {
                        selectedIndex = index;
                      });
                    }),
                    AllCars(),
                  ] else if (categories[selectedIndex] == 'Sedan') ...[
                    buildCategories(context, categories, selectedIndex, (
                      int index,
                    ) {
                      setState(() {
                        selectedIndex = index;
                      });
                    }),
                    Sedancar(),
                  ] else if (categories[selectedIndex] == 'SUV') ...[
                    buildCategories(context, categories, selectedIndex, (
                      int index,
                    ) {
                      setState(() {
                        selectedIndex = index;
                      });
                    }),
                    Suvcars(),
                  ] else if (categories[selectedIndex] == 'Hatchback') ...[
                    buildCategories(context, categories, selectedIndex, (
                      int index,
                    ) {
                      setState(() {
                        selectedIndex = index;
                      });
                    }),
                    Hatchback(),
                  ] else if (categories[selectedIndex] == 'Pickup') ...[
                    buildCategories(context, categories, selectedIndex, (
                      int index,
                    ) {
                      setState(() {
                        selectedIndex = index;
                      });
                    }),
                    Pickup(),
                  ] else if (categories[selectedIndex] == 'Luxury') ...[
                    buildCategories(context, categories, selectedIndex, (
                      int index,
                    ) {
                      setState(() {
                        selectedIndex = index;
                      });
                    }),
                    LuxuryCar(),
                  ] else if (categories[selectedIndex] == 'Electric') ...[
                    buildCategories(context, categories, selectedIndex, (
                      int index,
                    ) {
                      setState(() {
                        selectedIndex = index;
                      });
                    }),
                    Electriccar(),
                  ] else if (categories[selectedIndex] == 'Sports Car') ...[
                    buildCategories(context, categories, selectedIndex, (
                      int index,
                    ) {
                      setState(() {
                        selectedIndex = index;
                      });
                    }),
                    Sportcar(),
                  ],

                  //son
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildCategories(
  BuildContext context,
  List<String> categories,
  int selectedIndex,
  Function(int) onCategorySelected,
) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  double verticalSpacing = screenHeight * 0.025;
  double fontSizeTitle = screenWidth * 0.06;
  double fontSizeSubtitle = screenWidth * 0.04;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Categories".tr(),
        style: GoogleFonts.outfit(
          fontSize: fontSizeTitle - 2,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: verticalSpacing / 2),
      SizedBox(
        height: screenHeight * 0.06,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (BuildContext context, int index) {
            final isSelected = index == selectedIndex;
            return GestureDetector(
              onTap: () {
                onCategorySelected(index);
              },
              child: Container(
                margin: EdgeInsets.only(right: 10),
                padding: EdgeInsets.symmetric(horizontal: 17, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color.fromARGB(255, 36, 14, 144)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: Color.fromARGB(255, 36, 14, 144),
                          width: 2,
                        ),
                ),
                child: Text(
                  categories[index].tr(),
                  style: GoogleFonts.outfit(
                    fontSize: fontSizeSubtitle,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}
