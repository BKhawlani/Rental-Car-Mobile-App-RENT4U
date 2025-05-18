import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_car_project/Drawer_Screens/Setting.dart';
import 'package:rental_car_project/Drawer_Screens/aboutUs.dart';
import 'package:rental_car_project/Drawer_Screens/myFavorite.dart';
import 'package:rental_car_project/Drawer_Screens/mycars.dart';
import 'package:rental_car_project/screen/CarDetails.dart';
import 'package:rental_car_project/screen/booking.dart';
import 'package:rental_car_project/screen/home_page.dart';
import 'package:rental_car_project/Drawer_Screens/profileScreen.dart';
import 'package:rental_car_project/screen/welcome_page.dart';
import 'package:rental_car_project/utilities/car.dart';
import 'package:http/http.dart' as http;

class MainNavigator extends StatefulWidget {
  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
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

  Map<String, dynamic>? userData;
  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    userData = await getUserData();
    fetchCars().then((carList) {
      setState(() {
        cars = carList;
      });
    }).catchError((error) {
      print('Error fetching cars: $error');
    });
  }

  List<Car> cars = [];

  int _currentIndex = 1;

  List<Widget> get _pages => [
        Booking(car: cars, fromhome: true, index: 0),
        HomePage(),
        Profile(fromsetting: false),
        Mycars(
          fromhome: false,
        ),
        Myfavorite(),
        Setting(),
        Aboutus(
          fromsetting: false,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double fontSizeTitle = screenWidth * 0.06;
    double ButtonField = screenHeight * 0.06;
    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 0
            ? Text(
                "Car Booking".tr(),
                style: GoogleFonts.outfit(
                  fontSize: fontSizeTitle,
                  color: Colors.white,
                ),
              )
            : _currentIndex == 2
                ? Text(
                    "My profile".tr(),
                    style: GoogleFonts.outfit(
                      fontSize: fontSizeTitle,
                      color: Colors.white,
                    ),
                  )
                : _currentIndex == 3
                    ? Text(
                        "My Cars".tr(),
                        style: GoogleFonts.outfit(
                          fontSize: fontSizeTitle,
                          color: Colors.white,
                        ),
                      )
                    : _currentIndex == 4
                        ? Text(
                            "My Favorites".tr(),
                            style: GoogleFonts.outfit(
                              fontSize: fontSizeTitle,
                              color: Colors.white,
                            ),
                          )
                        : _currentIndex == 5
                            ? Text(
                                "Settings".tr(),
                                style: GoogleFonts.outfit(
                                  fontSize: fontSizeTitle,
                                  color: Colors.white,
                                ),
                              )
                            : _currentIndex == 6
                                ? Text(
                                    "About Us".tr(),
                                    style: GoogleFonts.outfit(
                                      fontSize: fontSizeTitle,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 36, 14, 144),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white, size: 30),
          onPressed: () async {
            scaffoldkey.currentState?.openDrawer();
            try {
              getUserData().then((data) {
                if (mounted) {
                  setState(() {
                    userData = data;
                  });
                }
              });
            } catch (e) {
              debugPrint('Error loading user data: $e');
            }
          },
        ),
        actions: [
          if (_currentIndex != 3) ...[
            IconButton(
              icon:
                  Icon(Icons.car_rental_rounded, color: Colors.white, size: 30),
              onPressed: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Mycars(
                      fromhome: true,
                    ),
                  ),
                );
              },
            ),
          ]
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 36, 14, 144),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.only(left: 0),
                    child: Text(
                      'Rent4U',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          userData?['photo'] ??
                              "https://i.pinimg.com/736x/98/1d/6b/981d6b2e0ccb5e968a0618c8d47671da.jpg",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 20),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text(
                          "${userData?['fullName']}", //kullanic isimi buraya gelecek
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'.tr(), style: GoogleFonts.outfit(fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 1;
                });
              },
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              leading: Icon(Icons.car_rental),
              title: Text(
                'My Cars'.tr(),
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 3;
                });
              },
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text(
                'Favorites'.tr(),
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 4;
                });
              },
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text(
                'Profile'.tr(),
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 2;
                });
              },
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Settings'.tr(),
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 5;
                });
              },
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              leading: Icon(Icons.people_alt_sharp),
              title: Text(
                'About Us'.tr(),
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 6;
                });
              },
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            SizedBox(height: 170),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 160,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  border: Border.all(
                    color: Color.fromARGB(255, 36, 14, 144),
                    width: 2,
                  ),
                ),
                child: MaterialButton(
                  minWidth: 0,
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Welcome()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Log Out'.tr(),
                    style: TextStyle(
                      color: Color.fromARGB(255, 36, 14, 144),
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      key: scaffoldkey,
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Color.fromARGB(255, 36, 14, 144),
        items: const [
          Icon(Icons.calendar_month, size: 30, color: Colors.white),
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        index: _currentIndex <= 2 ? _currentIndex : 1,
        onTap: (index) {
          setState(() {
            if (index <= 2) {
              _currentIndex = index;
            }
            // تحديث الصفحة الحالية
          });
        },
        height: 60, // ارتفاع شريط التنقل
        animationDuration: Duration(milliseconds: 300), // مدة الحركة
      ),
    );
  }
}
