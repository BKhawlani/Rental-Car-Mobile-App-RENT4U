import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_car_project/screen/home_page.dart';
import 'package:rental_car_project/screen/navigator.dart';
import 'package:rental_car_project/screen/signin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainNavigator(),
          ),
        );
      },
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.black),
            onPressed: () {
              _showLanguageDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.white,
          child: Column(
            children: [
              Container(child: Image.asset('assets/images/welcome.png')),
              Text(
                "Welcome to \n     Rent4U Company".tr(),
                style: GoogleFonts.prostoOne(
                  fontSize: screenHeight * 0.027,
                  color: Colors.black,
                ),
              ), // Replace with your image path
              SizedBox(height: screenHeight * 0.03),
              Builder(
                builder: (context) => MaterialButton(
                  onPressed: () {
                    if (FirebaseAuth.instance.currentUser != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => MainNavigator(),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    }
                  },
                  color: const Color.fromARGB(255, 36, 14, 144),
                  minWidth: screenWidth * 0.8,
                  height: screenHeight * 0.07,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      screenHeight * 0.04,
                    ),
                  ),
                  child: Text(
                    "Get Started".tr(),
                    style: GoogleFonts.shipporiAntique(
                      fontSize: screenWidth * 0.05,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Container(
                child: Text(
                  "Devloped by: Eng: Bashar Alkhawlani".tr(),
                  style: GoogleFonts.outfit(fontSize: screenWidth * 0.045),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose Language'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("English".tr()),
                leading: CountryFlag.fromCountryCode(
                  'US',
                  width: 30,
                  height: 25,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _changeLanguage(context, "en", "US");
                },
              ),
              ListTile(
                title: Text("Turkish".tr()),
                leading: CountryFlag.fromCountryCode(
                  'TR',
                  width: 30,
                  height: 25,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _changeLanguage(context, "tr", "TR");
                },
              ),
              ListTile(
                title: Text("Arabic".tr()),
                leading: CountryFlag.fromCountryCode(
                  'YE',
                  width: 30,
                  height: 25,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _changeLanguage(context, "ar", "YE");
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _changeLanguage(
      BuildContext context, String languageCode, String countryCode) async {
    await context.setLocale(Locale(languageCode, countryCode));

    await SharedPreferences.getInstance().then((prefs) {
      prefs.setString('language', languageCode);
      prefs.setString('country', countryCode);
    });
  }
}
