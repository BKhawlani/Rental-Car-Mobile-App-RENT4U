import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_car_project/screen/CarDetails.dart';
import 'package:rental_car_project/utilities/car.dart';
import 'package:http/http.dart' as http;

class Mycars extends StatefulWidget {
  bool fromhome;
  Mycars({required this.fromhome});

  @override
  State<Mycars> createState() => _MycarsState();
}

class _MycarsState extends State<Mycars> {
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

  Future<void> deletebookCar(String id) async {
    final url = Uri.parse(
        'https://680c930b2ea307e081d45573.mockapi.io/rent4u/api/cars/$id');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'available': true}),
      );

      if (response.statusCode == 200) {
        print(' Update successful: ${response.body}');
      } else {
        print(' Update Failed ${response.statusCode}');
      }
    } catch (e) {
      print('  no connection : $e');
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
      await Future.wait([_loadUserData(), _loadCarsData()]);
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

  Future<void> _loadCarsData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('CarBooking')
        .where('userid', isEqualTo: user.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        userBookings = querySnapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    }
  }

  Future<void> _deleteBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('CarBooking')
          .doc(bookingId)
          .delete();

      setState(() {
        userBookings.removeWhere((booking) => booking['id'] == bookingId);
      });
      deletebookCar(bookingId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('   Error deleting booking: $e')));
    }
  }

  List<Car> cars = [];

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double fontSizeTitle = screenWidth * 0.06;
    double ButtonField = screenHeight * 0.06;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (userBookings.isEmpty) {
      return Center(
        child: Text(
          'You did not rent any cars yet!'.tr(),
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: widget.fromhome
          ? AppBar(
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
              ),
              backgroundColor: Color.fromARGB(255, 36, 14, 144),
              title: Text(
                "My Cars".tr(),
                style: GoogleFonts.outfit(
                  fontSize: fontSizeTitle,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.12),
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            itemCount: userBookings.length,
            itemBuilder: (context, index) {
              return _buildBookingItem(context, userBookings[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookingItem(BuildContext context, Map<String, dynamic> car) {
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
              builder: (context) =>
                  Cardetails(car: cars, index: int.parse(car["carid"]) - 1),
            ),
          );
        },
        child: Column(
          children: [
            ListTile(
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
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Year: ".tr(),
                        style:
                            GoogleFonts.outfit(fontSize: fontSizeSubtitle - 2),
                      ),
                      Text(
                        "${car["year"] ?? ''}",
                        style:
                            GoogleFonts.outfit(fontSize: fontSizeSubtitle - 2),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Price: ".tr(),
                        style: GoogleFonts.outfit(
                          fontSize: fontSizeSubtitle - 2,
                          color: const Color.fromARGB(255, 36, 14, 144),
                        ),
                      ),
                      Text(
                        "\$${car["price"] ?? '0'} / day",
                        style: GoogleFonts.outfit(
                          fontSize: fontSizeSubtitle - 2,
                          color: const Color.fromARGB(255, 36, 14, 144),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildCityInfo(car, fontSizeSubtitle),
                  const SizedBox(height: 4),
                  _buildDateInfo(car, fontSizeSubtitle),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "Total:".tr(),
                        style: GoogleFonts.outfit(
                          fontSize: fontSizeSubtitle - 2,
                          color: const Color.fromARGB(255, 36, 14, 144),
                        ),
                      ),
                      Text(
                        " \$${car["totalprice"]} ",
                        style: GoogleFonts.outfit(
                          fontSize: fontSizeSubtitle - 2,
                          color: const Color.fromARGB(255, 36, 14, 144),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 10.0, right: 10.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.end,
            //     children: [
            //       IconButton(
            //         icon: const Icon(Icons.delete, color: Colors.red),
            //         onPressed: () {
            //           _showDeleteDialog(car['id'], car['carid']);
            //         },
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String bookingId, String carId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Booking".tr()),
          content: Text("Are you sure you want to delete this booking?".tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel".tr(),
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBooking(bookingId);
                deletebookCar(carId);
              },
              child: Text("Delete".tr(), style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCityInfo(Map<String, dynamic> car, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Pick Up City:".tr(),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: fontSize - 3,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "Drop off City:".tr(),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: fontSize - 3,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(car['pickupcity']?.toString() ?? 'N/A'),
            const SizedBox(width: 45),
            Text(car['dropoffcity']?.toString() ?? 'N/A'),
          ],
        ),
      ],
    );
  }

  Widget _buildDateInfo(Map<String, dynamic> car, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Pick Up Date:".tr(),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: fontSize - 3,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "Drop Off Date:".tr(),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: fontSize - 3,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              car['PickUpDate']?.toString() ?? 'N/A',
              style: TextStyle(fontSize: fontSize - 3),
            ),
            const SizedBox(width: 25),
            Text(car['DropOffDate']?.toString() ?? 'N/A',
                style: TextStyle(fontSize: fontSize - 3)),
          ],
        ),
      ],
    );
  }
}
