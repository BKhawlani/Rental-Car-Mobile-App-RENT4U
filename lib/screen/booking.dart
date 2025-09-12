import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rental_car_project/screen/confirm_Booking.dart';
import 'package:rental_car_project/utilities/car.dart';
import 'dart:convert';

import 'package:vibration/vibration.dart';

class Booking extends StatefulWidget {
  final List<Car> car;
  bool fromhome = false;
  int index;

  Booking({required this.car, required this.fromhome, required this.index});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  final _formKey = GlobalKey<FormState>();
  List<Car> bookingCar = [];
  Car? selectedCar;
  Future<void> _selectDate(BuildContext context, int sec) async {
    final DateTime now = DateTime.now();
    final DateTime oneMonthLater = DateTime(now.year, now.month + 1, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: oneMonthLater,
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      if (sec == 1) PickUpDate.text = formattedDate;
      if (sec == 2) DropOffDate.text = formattedDate;
    }
  }

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

  List<String> cities = [
    "Select",
    "Istanbul",
    "Ankara",
    "Izmir",
    "Adana",
    "Samsun",
    "Konya",
    "Adıyaman",
    "Kayseri",
    "Kırklareli",
    "Antalya",
    "Bilecik",
    "Bursa",
    "Burdur",
    "Çanakkale",
    "Çorum",
    "Denizli",
    "Diyarbakır",
    "Eskişehir",
    "Gaziantep",
    "Giresun",
    "Gümüşhane",
    "İzmir",
    "Kahramanmaraş",
    "Kastamonu",
    "Kilis",
    "Kırıkkale",
    "Kırşehir",
    "Kocaeli",
  ];

  Future<void> addcar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || selectedCar == null) {
      print("null");
      return;
    }
    ;

    try {
      await FirebaseFirestore.instance.collection('CarBooking').add({
        'userid': user.uid,
        'carid': selectedCar!.id,
        'brand': selectedCar!.brand,
        'model': selectedCar!.model,
        'year': selectedCar!.year,
        'image': selectedCar!.image,
        'price': selectedCar!.price,
        'pickupcity': PickupCity,
        'dropoffcity': DropOffCity,
        'PickUpDate': PickUpDate.text,
        'DropOffDate': DropOffDate.text,
        'totalprice': calculateDays() * selectedCar!.price,
        'timestamp': FieldValue.serverTimestamp(), // مفيد لترتيب الحجوزات
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Successfully booked!').tr()));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error : $e')));
    }
  }

  Map<String, dynamic>? userData;

  String PickupCity = "Izmir";
  String DropOffCity = "Ankara";

  @override
  void initState() {
    super.initState();
    loadUserData();
    if (widget.fromhome) {
      // If from home, start with no selection
      selectedCar = null;
    } else {
      // If not from home, use the provided car
      if (widget.index >= 0 && widget.index < widget.car.length) {
        bookingCar = [widget.car[widget.index]];
        selectedCar = widget.car[widget.index];
      } else {
        bookingCar = [];
        selectedCar = null;
      }
    }
  }

  void loadUserData() async {
    userData = await getUserData();
  }

  TextEditingController PickUpDate = TextEditingController();
  TextEditingController DropOffDate = TextEditingController();
  int calculateDays() {
    try {
      String englishPickUpDate = convertArabicNumbers(PickUpDate.text);
      DateTime pickUpDate = DateTime.parse(englishPickUpDate);

      String englishDropOffDate = convertArabicNumbers(DropOffDate.text);
      DateTime dropOffDate = DateTime.parse(englishDropOffDate);

      if (dropOffDate.isBefore(pickUpDate)) {
        return 0;
      }

      Duration difference = dropOffDate.difference(pickUpDate);
      int totalDays = difference.inDays;
      if (totalDays == 0) totalDays = 1;
      return totalDays;
    } catch (e) {
      return 0;
    }
  }

  String convertArabicNumbers(String input) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String output = input;
    for (int i = 0; i < arabicDigits.length; i++) {
      output = output.replaceAll(arabicDigits[i], englishDigits[i]);
    }
    return output;
  }

  Widget build(BuildContext context) {
    bool hata = false;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double paddingHorizontal = screenWidth * 0.05;
    double verticalSpacing = screenHeight * 0.025;
    double fontSizeTitle = screenWidth * 0.06;
    double ButtonField = screenHeight * 0.06;

    double fontSizeSubtitle = screenWidth * 0.04;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.fromhome
          ? null
          : AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
              ),
              backgroundColor: Color.fromARGB(255, 36, 14, 144),
              title: Text(
                "Car Booking".tr(),
                style: GoogleFonts.outfit(
                  fontSize: fontSizeTitle,
                  color: Colors.white,
                ),
              ),
            ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.05,
              ),
              if (widget.fromhome) ...[
                SizedBox(height: verticalSpacing * 4.5),
              ] else ...[
                SizedBox(height: verticalSpacing * 1.5),
              ],
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      "Select the car you want to book".tr(),
                      style: GoogleFonts.outfit(
                        fontSize: fontSizeTitle - 5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    SizedBox(
                      height: screenHeight * 0.087, // ارتفاع ثابت يكفي للخطأ

                      child: DropdownButtonFormField<Car>(
                        value: selectedCar,
                        validator: (value) {
                          if (selectedCar == null) {
                            setState(() => hata = true);
                            return "You must to select a car to booking";
                          }
                        },
                        hint: Text(
                          "Choose a car".tr(),
                          style: TextStyle(fontSize: fontSizeSubtitle - 1.5),
                        ),
                        isExpanded: true,
                        alignment: Alignment.bottomCenter,
                        dropdownColor: Colors.white,
                        onChanged: (Car? newCar) {
                          setState(() {
                            selectedCar = newCar;
                          });
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyle(height: 0, fontSize: 0),
                          hintText: "Select a car".tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 36, 14, 144),
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(Icons.car_rental),
                        ),
                        items: widget.fromhome
                            ? widget.car
                                .where((car) => car.isAvailable == true)
                                .map<DropdownMenuItem<Car>>((Car car) {
                                return DropdownMenuItem<Car>(
                                  value: car,
                                  child: Text(
                                    "${car.brand} ${car.model} ${car.year}",
                                    style: GoogleFonts.outfit(
                                      fontSize: fontSizeSubtitle,
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }).toList()
                            : bookingCar.map<DropdownMenuItem<Car>>((Car car) {
                                return DropdownMenuItem<Car>(
                                  value: selectedCar,
                                  child: Text(
                                    "${car.brand} ${car.model} ${car.year}",
                                    style: GoogleFonts.outfit(
                                      fontSize: fontSizeSubtitle,
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    Text(
                      "Choose the Location and date".tr(),
                      style: GoogleFonts.outfit(
                        fontSize: fontSizeTitle - 5,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: verticalSpacing / 2),
                    Text(
                      "Pick up Location".tr(),
                      style: GoogleFonts.outfit(
                        fontSize: fontSizeTitle - 6,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: verticalSpacing / 2),
                    SizedBox(
                      height: screenHeight * 0.07,
                      child: DropdownButtonFormField<String>(
                        menuMaxHeight: 200,
                        value: PickupCity,
                        hint: Text("Select City...").tr(),
                        isExpanded: true,
                        alignment: Alignment.bottomCenter,
                        dropdownColor: Colors.white,
                        onChanged: (String? val) {
                          setState(() {
                            PickupCity = val!;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Select City...".tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 36, 14, 144),
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(Icons.location_city),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        items:
                            cities.map<DropdownMenuItem<String>>((String city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(
                              city,
                              style: GoogleFonts.outfit(
                                fontSize: fontSizeSubtitle,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    Text(
                      "Drop off location".tr(),
                      style: GoogleFonts.outfit(
                        fontSize: fontSizeTitle - 6,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: verticalSpacing / 2),
                    SizedBox(
                      height: screenHeight * 0.07,
                      child: DropdownButtonFormField<String>(
                        menuMaxHeight: 200,
                        value: DropOffCity,
                        hint: Text("Select City...").tr(),
                        isExpanded: true,
                        alignment: Alignment.bottomCenter,
                        dropdownColor: Colors.white,
                        onChanged: (String? val) {
                          setState(() {
                            DropOffCity = val!;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Select City...".tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 36, 14, 144),
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(Icons.location_city),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        items:
                            cities.map<DropdownMenuItem<String>>((String city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(
                              city,
                              style: GoogleFonts.outfit(
                                fontSize: fontSizeSubtitle,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 0.7),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pick up date".tr(),
                                style: GoogleFonts.outfit(
                                  fontSize: fontSizeTitle - 6,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: verticalSpacing / 2),
                              Container(
                                width: screenWidth * 0.5,
                                height: screenHeight * 0.08,
                                child: TextFormField(
                                  controller: PickUpDate,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: "YYYY-MM-DD",
                                    hintStyle: GoogleFonts.outfit(
                                      fontSize: fontSizeSubtitle - 3,
                                      color: Colors.black,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.calendar_today),
                                      onPressed: () => _selectDate(context, 1),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        screenWidth * 0.07,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback(
                                        (_) {},
                                      );
                                      return 'Please enter your Pick up Date'
                                          .tr();
                                    }
                                    return null;
                                  },
                                  onTap: () => _selectDate(context, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: verticalSpacing * 0.7),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Drop Off Date".tr(),
                                style: GoogleFonts.outfit(
                                  fontSize: fontSizeTitle - 6,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: verticalSpacing / 2),
                              Container(
                                width: screenWidth * 0.5,
                                height: screenHeight * 0.08,
                                child: TextFormField(
                                  controller: DropOffDate,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: "YYYY-MM-DD",
                                    hintStyle: GoogleFonts.outfit(
                                      fontSize: fontSizeSubtitle - 3,
                                      color: Colors.black,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.calendar_today),
                                      onPressed: () => _selectDate(context, 2),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        screenWidth * 0.07,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback(
                                        (_) {},
                                      );
                                      return 'Please enter your Drop Off Date'
                                          .tr();
                                    }
                                    return null;
                                  },
                                  onTap: () => _selectDate(context, 2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing * 1.5),
              Center(
                child: MaterialButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (calculateDays() > 0) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ConfirmBooking(
                              selectedCar: selectedCar,
                              days: calculateDays(),
                              pickupcity: PickupCity,
                              dropoffcity: DropOffCity,
                              pickupdate: PickUpDate.text,
                              dropoffdate: DropOffDate.text,
                            ),
                          ),
                        );
                      } else {
                        if (await Vibration.hasVibrator() ?? false) {
                          Vibration.vibrate(duration: 200);
                        }
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(
                            content:
                                Text('The Dates you insert are wrong').tr()));
                      }
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: ButtonField,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 36, 14, 144),
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    ),
                    child: Text(
                      "Continue".tr(),
                      style: GoogleFonts.shipporiAntique(
                        fontSize: screenWidth * 0.045,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
