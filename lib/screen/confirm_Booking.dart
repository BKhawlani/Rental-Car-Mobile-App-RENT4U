import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_car_project/screen/home_page.dart';
import 'package:rental_car_project/screen/thank.dart';
import 'package:rental_car_project/utilities/car.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:http/http.dart' as http;

class ConfirmBooking extends StatefulWidget {
  final Car? selectedCar;
  final int days;
  final String pickupdate;
  final String dropoffdate;
  final String pickupcity;
  final String dropoffcity;

  const ConfirmBooking({
    Key? key,
    required this.selectedCar,
    required this.days,
    required this.pickupdate,
    required this.dropoffdate,
    required this.pickupcity,
    required this.dropoffcity,
  }) : super(key: key);

  @override
  State<ConfirmBooking> createState() => _ConfirmBookingState();
}

class _ConfirmBookingState extends State<ConfirmBooking> {
  bool isDriverNeeded = false;
  final int driverFee = 50;
  bool isLoading = false;
  Future<void> bookCar(String id) async {
    final url = Uri.parse(
        'https://680c930b2ea307e081d45573.mockapi.io/rent4u/api/cars/$id');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'available': false}),
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

  Future<void> _addCarBooking() async {
    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('user not logged in').tr()),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('CarBooking').add({
        'userid': user.uid,
        'carid': widget.selectedCar!.id,
        'brand': widget.selectedCar!.brand,
        'model': widget.selectedCar!.model,
        'year': widget.selectedCar!.year,
        'image': widget.selectedCar!.image,
        'price': widget.selectedCar!.price,
        'pickupcity': widget.pickupcity,
        'dropoffcity': widget.dropoffcity,
        'PickUpDate': widget.pickupdate,
        'DropOffDate': widget.dropoffdate,
        'driverNeeded': isDriverNeeded,
        'driverFee': isDriverNeeded ? driverFee : 0,
        'totalprice': _calculateTotalPrice(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      await bookCar(widget.selectedCar!.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking Success').tr()),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ThankYouPage()),
        (Route<dynamic> route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking Error'.tr(args: [e.toString()]))),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  int _calculateTotalPrice() {
    int basePrice = widget.days * widget.selectedCar!.price;
    return isDriverNeeded ? basePrice + driverFee : basePrice;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF240E90),
        title: Text(
          'Confirm Booking'.tr(),
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Driver Toggle Section
                _buildDriverToggleSection(size),
                SizedBox(height: size.height * 0.03),

                // Car Image and Info
                _buildCarInfoSection(size, theme),
                const Divider(thickness: 1, color: Colors.grey),
                SizedBox(height: size.height * 0.02),

                // Booking Details
                _buildBookingDetailsSection(size, theme),
                const Divider(thickness: 1, color: Colors.grey),
                SizedBox(height: size.height * 0.02),

                // Total Price
                _buildTotalPriceSection(size, theme),
                SizedBox(height: size.height * 0.05),

                // Confirm Button
                _buildConfirmButton(size),
              ],
            ),
          ),

          // Loading Indicator
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildDriverToggleSection(Size size) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(size.width * 0.04),
      child: Row(
        children: [
          Text(
            'Needs driver?'.tr(),
            style: GoogleFonts.outfit(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          AnimatedToggleSwitch<bool>.dual(
            current: isDriverNeeded,
            height: 45,
            first: false,
            second: true,
            spacing: 1,
            style: ToggleStyle(
              backgroundColor: Colors.grey.shade300,
              indicatorColor: const Color(0xFF240E90),
              borderRadius: BorderRadius.circular(20),
            ),
            onChanged: (val) => setState(() => isDriverNeeded = val),
            iconBuilder: (val) => Icon(
              val ? Icons.person : Icons.person_off,
              color: Colors.white,
              size: size.width * 0.05,
            ),
            textBuilder: (val) => Text(
              val ? 'Yes'.tr() : 'No'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: size.width * 0.035,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarInfoSection(Size size, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.selectedCar!.image,
            width: size.width * 0.4,
            height: size.height * 0.18,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.car_rental, size: 40),
            ),
          ),
        ),
        SizedBox(width: size.width * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.selectedCar!.brand} ${widget.selectedCar!.model} ${widget.selectedCar!.year}',
                style: GoogleFonts.outfit(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                '${'Price'.tr()}: ${widget.selectedCar!.price}\$',
                style: GoogleFonts.outfit(
                  fontSize: size.width * 0.04,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetailsSection(Size size, ThemeData theme) {
    return Column(
      children: [
        _buildDetailRow(
          size,
          label: 'Days'.tr(),
          value: widget.days.toString(),
        ),
        SizedBox(height: size.height * 0.02),
        _buildDetailRow(
          size,
          label: 'Price'.tr(),
          value: '${(widget.days * widget.selectedCar!.price)}\$',
        ),
        if (isDriverNeeded) ...[
          SizedBox(height: size.height * 0.02),
          _buildDetailRow(
            size,
            label: 'Driver Fee'.tr(),
            value: '${driverFee}\$',
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(Size size,
      {required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: size.width * 0.04,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: size.width * 0.04,
              color: const Color(0xFF240E90),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPriceSection(Size size, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
      child: Row(
        children: [
          Text(
            'Total'.tr(),
            style: GoogleFonts.outfit(
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${_calculateTotalPrice()}\$',
            style: GoogleFonts.outfit(
              fontSize: size.width * 0.05,
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(Size size) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF240E90),
          minimumSize: Size(double.infinity, size.height * 0.07),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          if (isLoading) {
          } else {
            _addCarBooking();
          }
        },
        child: Text(
          'Confirm'.tr(),
          style: GoogleFonts.shipporiAntique(
            fontSize: size.width * 0.045,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
