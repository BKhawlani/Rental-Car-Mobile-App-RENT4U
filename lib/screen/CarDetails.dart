import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_car_project/Drawer_Screens/mycars.dart';
import 'package:rental_car_project/screen/booking.dart';
import 'package:rental_car_project/utilities/car.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cardetails extends StatefulWidget {
  final List<Car> car;
  final int index;
  Cardetails({required this.car, required this.index});

  @override
  State<Cardetails> createState() => _CardetailsState();
}

Car? favoriteCar;

class _CardetailsState extends State<Cardetails> {
  bool isfavorite = false;
  String? favoriteDocId;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.car == null) return;

    try {
      final query = await FirebaseFirestore.instance
          .collection('FavoriteCar')
          .where('userid', isEqualTo: user.uid)
          .where('carid', isEqualTo: widget.car[widget.index].id)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          isfavorite = true;
          favoriteDocId = query.docs.first.id;
        });
      }
    } catch (e) {
      debugPrint('Error checking favorite: $e');
    }
  }

  Future<void> addcarToFavorite() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "you are not logged in";
      if (widget.car == null) throw "car is not available";

      if (isfavorite) return;

      final docRef =
          await FirebaseFirestore.instance.collection('FavoriteCar').add({
        'userid': user.uid,
        'carid': widget.car[widget.index].id,
        'brand': widget.car[widget.index].brand,
        'model': widget.car[widget.index].model,
        'year': widget.car[widget.index].year,
        'image': widget.car[widget.index].image,
        'price': widget.car[widget.index].price,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        isfavorite = true;
        favoriteDocId = docRef.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Succsesfully added to favorite!'.tr()),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding favorite: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
      debugPrint('Error adding favorite: $e');
    }
  }

  Future<void> removeCarFromFavorite() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "you are not logged in";
      if (widget.car == null) throw "car is not available";
      if (favoriteDocId == null) throw "Can't found the car in favorite";

      await FirebaseFirestore.instance
          .collection('FavoriteCar')
          .doc(favoriteDocId)
          .delete();

      setState(() {
        isfavorite = false;
        favoriteDocId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Succesfully removed from favorite!'.tr()),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removing error ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
      debugPrint('Error removing favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double fontSizeTitle = screenWidth * 0.06;
    double fontSizeSubtitle = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new),
          color: Colors.white,
        ),
        title: Text(
          "Car Details".tr(),
          style: GoogleFonts.outfit(
            fontSize: fontSizeTitle,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 36, 14, 144),
        actions: [
          IconButton(
            icon: isfavorite
                ? Icon(Icons.favorite, color: Colors.white, size: 30)
                : Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 30,
                  ),
            onPressed: () async {
              if (isfavorite) {
                await removeCarFromFavorite();
              } else {
                await addcarToFavorite();
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            ClipRRect(
              child: Image.network(
                widget.car[widget.index].image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
            SizedBox(height: 15),
            Container(
              margin: EdgeInsets.only(left: 10, right: 15, bottom: 15),
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Color.fromARGB(255, 36, 14, 144)),
              ),
              padding: EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.car[widget.index].brand +
                            "\n" +
                            widget.car[widget.index].model +
                            " " +
                            widget.car[widget.index].year,
                        style: GoogleFonts.outfit(
                          fontSize: fontSizeTitle - 4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      SizedBox(width: 40),
                      Text(
                        "      \$${widget.car[widget.index].price} /day",
                        style: GoogleFonts.outfit(
                          fontSize: fontSizeSubtitle,
                          color: Color.fromARGB(255, 36, 14, 144),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(
                            color: Color.fromARGB(255, 36, 14, 144),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.speed,
                              color: Color.fromARGB(255, 36, 14, 144),
                              size: 20,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "${widget.car[widget.index].topSpeed} km/h",
                              style: GoogleFonts.outfit(
                                fontSize: fontSizeSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 7),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(
                            color: Color.fromARGB(255, 36, 14, 144),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.earbuds,
                              color: Color.fromARGB(255, 36, 14, 144),
                              size: 20,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "${widget.car[widget.index].gearSystem}",
                              style: GoogleFonts.outfit(
                                fontSize: fontSizeSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 7),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(
                            color: Color.fromARGB(255, 36, 14, 144),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_gas_station,
                              color: Color.fromARGB(255, 36, 14, 144),
                              size: 20,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "${widget.car[widget.index].fuel}",
                              style: GoogleFonts.outfit(
                                fontSize: fontSizeSubtitle - 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(left: 15),
              child: Text(
                "Specifications".tr(),
                style: GoogleFonts.outfit(
                  fontSize: fontSizeTitle - 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(
                        color: Color.fromARGB(255, 36, 14, 144),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bolt,
                          color: Color.fromARGB(255, 36, 14, 144),
                          size: 20,
                        ),
                        SizedBox(height: 7),
                        Text(
                          "${widget.car[widget.index].power} ",
                          style: GoogleFonts.outfit(
                            fontSize: fontSizeSubtitle + 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Power ".tr(),
                          style: GoogleFonts.outfit(fontSize: fontSizeSubtitle),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 7),
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(
                        color: Color.fromARGB(255, 36, 14, 144),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.timer,
                          color: Color.fromARGB(255, 36, 14, 144),
                          size: 20,
                        ),
                        SizedBox(height: 7),
                        Text(
                          "${widget.car[widget.index].accelaritionBySec} ",
                          style: GoogleFonts.outfit(
                            fontSize: fontSizeSubtitle + 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "0-100km/h ",
                          style: GoogleFonts.outfit(
                            fontSize: fontSizeSubtitle - 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 7),
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(
                        color: Color.fromARGB(255, 36, 14, 144),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.speed,
                          color: Color.fromARGB(255, 36, 14, 144),
                          size: 20,
                        ),
                        SizedBox(height: 7),
                        Text(
                          "${widget.car[widget.index].topSpeed}km/h ",
                          style: GoogleFonts.outfit(
                            fontSize: fontSizeSubtitle + 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Top speed ".tr(),
                          style: GoogleFonts.outfit(fontSize: fontSizeSubtitle),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              margin: EdgeInsets.only(left: 15),
              child: Text(
                "Features".tr(),
                style: GoogleFonts.outfit(
                  fontSize: fontSizeTitle - 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(3, (colIndex) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(3, (rowIndex) {
                    int featureIndex = colIndex * 3 + rowIndex;
                    if (featureIndex >=
                        widget.car[widget.index].features.length) {
                      return SizedBox();
                    }
                    return buildfeature(
                      widget.index,
                      widget.car,
                      featureIndex,
                      context,
                    );
                  }),
                );
              }),
            ),
            Container(
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Color.fromARGB(255, 36, 14, 144)),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description".tr(),
                    style: GoogleFonts.outfit(
                      fontSize: fontSizeTitle - 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    "  ${widget.car[widget.index].description}",
                    style: GoogleFonts.outfit(fontSize: fontSizeSubtitle - 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            topLeft: Radius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "   \$${widget.car[widget.index].price}/day",
              style: GoogleFonts.outfit(
                fontSize: fontSizeSubtitle + 3,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 36, 14, 144),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Booking(
                      car: widget.car,
                      fromhome: false,
                      index: widget.index,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 36, 14, 144),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Book Now".tr(),
                style: GoogleFonts.outfit(
                  fontSize: fontSizeSubtitle,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildfeature(int index, List<Car> car, int carindex, context) {
  final screenWidth = MediaQuery.of(context).size.width;

  double fontSizeSubtitle = screenWidth * 0.04;
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      border: Border.all(color: Color.fromARGB(255, 36, 14, 144)),
      borderRadius: BorderRadius.circular(20),
    ),
    margin: EdgeInsets.only(left: 20, bottom: 15),
    child: Text(
      "${car[index].features[carindex]}",
      style: GoogleFonts.outfit(fontSize: fontSizeSubtitle - 1),
    ),
  );
}
