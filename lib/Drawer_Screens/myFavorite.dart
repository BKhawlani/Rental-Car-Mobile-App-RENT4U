import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_car_project/screen/CarDetails.dart';
import 'package:rental_car_project/screen/home_page.dart';
import 'package:rental_car_project/utilities/car.dart';
import 'package:http/http.dart' as http;

class Myfavorite extends StatefulWidget {
  const Myfavorite({super.key});

  @override
  State<Myfavorite> createState() => _MyfavoriteState();
}

class _MyfavoriteState extends State<Myfavorite> {
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

  List<Map<String, dynamic>> userBookings = [];
  bool isLoading = true;
  Map<String, dynamic>? userData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
    fetchCars().then((carList) {
      setState(() {
        cars = carList;
      });
    }).catchError((error) {
      print('Error fetching cars: $error');
    });
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([_loadUserData(), _loadCFavorteData()]);
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data. Please try again.';
      });
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data() != null) {
      setState(() {
        userData = doc.data();
      });
    }
  }

  Future<void> _loadCFavorteData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('FavoriteCar')
        .where('userid', isEqualTo: user.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        userBookings = querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  }

  List<Car> cars = [];

  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (userBookings.isEmpty) {
      return Center(
        child: Text(
          'You did not have any Myfavorite cars yet.'.tr(),
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.12),
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            itemCount: userBookings.length,
            itemBuilder: (context, index) {
              return _buildfavoriteitem(context, userBookings[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildfavoriteitem(BuildContext context, Map<String, dynamic> car) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSizeSubtitle = screenWidth * 0.04;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 36, 14, 144),
          width: 2,
        ),
      ),
      child: MaterialButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Cardetails(
                car: cars,
                index: int.parse(car["carid"]) - 1,
              ), // verimizde sifirdan basladigi icin -1 ekliyoruz
            ),
          );
        },
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.01,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              car["image"] ?? '',
              width: screenWidth * 0.2,
              height: screenHeight * 0.1,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.car_rental, size: 40),
            ),
          ),
          title: Text(
            "${car["brand"] ?? ''} ${car["model"] ?? ''}",
            style: GoogleFonts.outfit(
              fontSize: fontSizeSubtitle,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Text(
                  "Year: ".tr(),
                  style: GoogleFonts.outfit(fontSize: fontSizeSubtitle - 2),
                ),
                Text(
                  "${car["year"] ?? ''}",
                  style: GoogleFonts.outfit(fontSize: fontSizeSubtitle - 2),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Price: ".tr(),
                  style: GoogleFonts.outfit(
                    fontSize: fontSizeSubtitle - 3,
                    color: const Color.fromARGB(255, 36, 14, 144),
                  ),
                ),
                Text(
                  "\$${car["price"] ?? '0'} / day",
                  style: GoogleFonts.outfit(
                    fontSize: fontSizeSubtitle - 3,
                    color: const Color.fromARGB(255, 36, 14, 144),
                  ),
                )
              ],
            ),
            SizedBox(
              width: 5,
            )
          ]),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Cardetails(
                        car: cars,
                        index: int.parse(car["carid"]) - 1,
                      ), // verimizde sifirdan basladigi icin -1 ekliyoruz
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
