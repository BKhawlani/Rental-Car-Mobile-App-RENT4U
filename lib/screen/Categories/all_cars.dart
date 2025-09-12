import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:rental_car_project/screen/CarDetails.dart';
import 'package:rental_car_project/utilities/car.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AllCars extends StatefulWidget {
  @override
  State<AllCars> createState() => _AllCarsState();
}

class _AllCarsState extends State<AllCars> {
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
          fetched = false;
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
        cars = carList.where((car) => car.isAvailable).toList();
        for (var car in PapularModel) {
          papularCars.addAll(
              cars.where((c) => c.model == car && c.isAvailable).toList());
        }
        isloading = false;
        fetched = true; // Set fetched to true after data is loaded
      });
    }).catchError((error) {
      print('Error fetching cars: $error');
    });
  }

  List<Car> cars = [];

  bool isloading = true;
  bool fetched = false;
  bool isSearching = false;
  List<Car> filteredCars = [];
  List<Car> papularCars = [];
  List<String> PapularModel = [
    "GLC",
    "i4",
    "Model Y",
    "110",
    "Z4",
    "E-Class",
    "Kona",
    "A6",
    "A4",
    "ES 300h",
    "Land Cruiser",
    "5 Series",
    "Camry",
  ];
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
        margin: EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Papular Cars".tr(),
              style: GoogleFonts.outfit(
                fontSize: fontSizeTitle - 2,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: verticalSpacing / 2),
            //Arabalar List View
            SizedBox(
              height: screenHeight * 0.31,
              child: fetched
                  ? cars.isNotEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              papularCars.isEmpty ? 1 : papularCars.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => Cardetails(
                                          car: papularCars,
                                          index: index,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: screenWidth * 0.6,
                                    margin: EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Color.fromARGB(
                                          255,
                                          36,
                                          14,
                                          144,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                          child: Image.network(
                                            papularCars[index].image,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: screenHeight * 0.2,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(
                                            paddingHorizontal / 2,
                                          ),
                                          child: Text(
                                            "${papularCars[index].brand} ${papularCars[index].model} ",
                                            style: GoogleFonts.outfit(
                                              fontSize: fontSizeSubtitle,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: paddingHorizontal / 2,
                                              ),
                                              child: Text(
                                                "\$${papularCars[index].price}/ ",
                                                style: GoogleFonts.outfit(
                                                  fontSize: fontSizeSubtitle,
                                                  color: Color.fromARGB(
                                                    255,
                                                    36,
                                                    14,
                                                    144,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              child: Text(
                                                "day".tr(),
                                                style: GoogleFonts.outfit(
                                                  fontSize: fontSizeSubtitle,
                                                  color: Color.fromARGB(
                                                    255,
                                                    36,
                                                    14,
                                                    144,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.3),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                  255,
                                                  36,
                                                  14,
                                                  144,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.arrow_forward,
                                                color: Colors.white,
                                                size: 25,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      : Center(
                          child: Container(
                            alignment: Alignment.topLeft,
                            width: screenWidth * 0.6,
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
                                  padding: EdgeInsets.all(
                                    paddingHorizontal / 2,
                                  ),
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
                        )
                  : isloading
                      ? Center(child: CircularProgressIndicator())
                      : null,
            ),
            SizedBox(height: verticalSpacing),

            cars.isEmpty
                ? Column(children: [Center(child: CircularProgressIndicator())])
                : Text(
                    "All Cars".tr(),
                    style: GoogleFonts.outfit(
                      fontSize: fontSizeTitle - 2,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

            SizedBox(height: verticalSpacing / 2),
            //TUM ARABALAR
            for (int i = 0; i < cars.length; i++)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Cardetails(car: cars, index: i),
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
                        cars[i].image,
                        fit: BoxFit.cover,
                        width: screenWidth * 0.2,
                        height: screenHeight * 0.1,
                      ),
                    ),
                    title: Text(
                      "${cars[i].brand} ${cars[i].model}",
                      style: GoogleFonts.outfit(
                        fontSize: fontSizeSubtitle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          "\$${cars[i].price} / ",
                          style: GoogleFonts.outfit(
                            fontSize: fontSizeSubtitle - 2,
                            color: Color.fromARGB(255, 36, 14, 144),
                          ),
                        ),
                        Text(
                          "day".tr(),
                          style: GoogleFonts.outfit(
                            fontSize: fontSizeSubtitle - 2,
                            color: Color.fromARGB(255, 36, 14, 144),
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
