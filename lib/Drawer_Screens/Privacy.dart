import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_car_project/screen/CarDetails.dart';

class Privacy extends StatefulWidget {
  const Privacy({super.key});

  @override
  State<Privacy> createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double fontSizeTitle = screenWidth * 0.06;
    double ButtonField = screenHeight * 0.06;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new),
          color: Colors.white,
        ),
        backgroundColor: Color.fromARGB(255, 36, 14, 144),
        title: Text(
          "Privacy Policy".tr(),
          style: GoogleFonts.outfit(
            fontSize: fontSizeTitle,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.6),
                  children: [
                    TextSpan(text: 'At '.tr()),
                    TextSpan(
                      text: 'Rent4U',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          ', we are committed to protecting your personal data. Your information is used only for the purposes of booking vehicles, user authentication, and improving user experience.\n\n'
                              .tr(),
                    ),
                    TextSpan(
                      text: 'Data Collection:\n'.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'We may collect your name, email, phone number, and uploaded documents necessary for booking a car.\n\n'
                              .tr(),
                    ),
                    TextSpan(
                      text: 'Data Usage:\n'.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'Your data is used solely for identity verification, communication, and rental operations. We do not sell or share your data with third parties.\n\n'
                              .tr(),
                    ),
                    TextSpan(
                      text: 'Security:\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'All user data is securely stored in our cloud system (Firebase) and is protected with encryption.\n\n'
                              .tr(),
                    ),
                    TextSpan(
                      text: 'Your Rights:\n'.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'You can request deletion of your data at any time by contacting our support.\n\n'
                              .tr(),
                    ),
                    TextSpan(
                      text:
                          'By using Rent4U, you agree to the terms of this privacy policy.'
                              .tr(),
                    ),
                  ],
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
