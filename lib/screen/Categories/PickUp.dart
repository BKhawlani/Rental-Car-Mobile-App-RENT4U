import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:rental_car_project/screen/CarDetails.dart';
import 'package:rental_car_project/utilities/car.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Pickup extends StatefulWidget {
  const Pickup({super.key});

  @override
  State<Pickup> createState() => _PickupState();
}

class _PickupState extends State<Pickup> {
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
        // إذا السيرفر رد بكود خطأ (مثلا 404، 500...)
        if (kDebugMode) {
          print('Server error: ${response.statusCode}');
        }
        return []; // مصفوفة فاضية
      }
    } catch (e) {
      // إذا فشل الاتصال (مثلاً مافي نت)
      if (kDebugMode) {
        print('Connection error: $e');
      }
      return []; // مصفوفة فاضية
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    fetchCars().then((carList) {
      setState(() {
        isfetched = true;
        cars = carList;
        Pickups = cars
            .where((car) => car.category == "Pickup" && car.isAvailable)
            .toList();
        isloading = false;
      });
    }).catchError((error) {
      print('Error fetching cars: $error');
    });
  }

  List<Car> cars = [];
  List<Car> Pickups = [];
  bool isloading = true;
  bool isfetched = false;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double paddingHorizontal = screenWidth * 0.05;
    double verticalSpacing = screenHeight * 0.025;
    double fontSizeTitle = screenWidth * 0.06;
    double fontSizeSubtitle = screenWidth * 0.04;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              'Pickup Cars',
              style: GoogleFonts.poppins(
                fontSize: fontSizeTitle,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            isfetched
                ? Column(
                    children: [
                      if (cars.isEmpty) ...[
                        Center(
                          child: Container(
                            alignment: Alignment.topLeft,
                            width: screenWidth * 0.5,
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  child: Image.asset(
                                    'assets/images/offlline.jpg',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: screenHeight * 0.2,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.all(paddingHorizontal / 2),
                                  child: Text(
                                    "No Cars Available".tr(),
                                    style: GoogleFonts.outfit(
                                      fontSize: fontSizeSubtitle,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: paddingHorizontal / 2,
                                  ),
                                  child: Text(
                                    "Please check your internet".tr(),
                                    style: GoogleFonts.outfit(
                                      fontSize: fontSizeSubtitle - 4,
                                      color: Color.fromARGB(255, 36, 14, 144),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else if (Pickups.isEmpty) ...[
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              border: Border.all(
                                color: Color.fromARGB(255, 36, 14, 144),
                                width: 2,
                              ),
                            ),
                            margin: EdgeInsets.only(top: 70, right: 20),
                            child: Text(
                              "There is not An Available Car in this Category, We're Sorry!!"
                                  .tr(),
                              style: GoogleFonts.outfit(
                                fontSize: screenWidth * 0.04,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        for (int i = 0; i < Pickups.length; i++)
                          MaterialButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      Cardetails(car: Pickups, index: i)));
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                right: paddingHorizontal,
                                bottom: verticalSpacing,
                              ),
                              padding: EdgeInsets.all(paddingHorizontal),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Image.network(
                                    Pickups[i].image,
                                    width: screenWidth * 0.9,
                                    height: screenHeight * 0.25,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(height: verticalSpacing),
                                  Text(
                                    Pickups[i].brand + " " + Pickups[i].model,
                                    style: GoogleFonts.poppins(
                                      fontSize: fontSizeSubtitle,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: verticalSpacing),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "\$${Pickups[i].price}/",
                                        style: GoogleFonts.outfit(
                                          fontSize: fontSizeSubtitle,
                                          color:
                                              Color.fromARGB(255, 36, 14, 144),
                                        ),
                                      ),
                                      Text(
                                        "day".tr(),
                                        style: GoogleFonts.outfit(
                                          fontSize: fontSizeSubtitle,
                                          color:
                                              Color.fromARGB(255, 36, 14, 144),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 200),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 36, 14, 144),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ],
                  )
                : isloading
                    ? Container(
                        margin: EdgeInsets.only(top: 100),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Center(child: Text("Error 404")),
          ],
        ),
      ),
    );
  }
}
