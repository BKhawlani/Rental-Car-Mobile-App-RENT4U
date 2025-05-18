import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_car_project/Drawer_Screens/Privacy.dart';
import 'package:rental_car_project/Drawer_Screens/aboutUs.dart';
import 'package:rental_car_project/Drawer_Screens/profileScreen.dart';
import 'package:country_flags/country_flags.dart';
import 'package:rental_car_project/screen/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  Map<String, dynamic>? userData;
  final _passwordFormKey = GlobalKey<FormState>();
  bool _showPasswordFields = false;
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<bool> deleteAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      await deleteUserBookings(user.uid);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // احذف الحساب من Firebase Auth
      await user.delete();

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: $e')),
      );
      return false;
    }
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: Text("Delete Account".tr()),
          content: Text("Are you sure you want to delete your account?".tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(alertContext).pop(),
              child: Text("Cancel".tr(), style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(alertContext).pop();

                final success = await deleteAccount(context);

                if (success) {
                  Future.microtask(() {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const Welcome()),
                      (route) => false,
                    );
                  });
                }
              },
              child: Text("Delete".tr(), style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteUserBookings(String userId) async {
    final bookings = await FirebaseFirestore.instance
        .collection('CarBooking')
        .where('userid', isEqualTo: userId)
        .get();

    for (var doc in bookings.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _updatePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Passwords do not match').tr()));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Reauthenticate user
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(_newPasswordController.text);

      // Clear fields
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password updated successfully').tr()),
      );

      setState(() {
        _showPasswordFields = false;
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred'.tr();
      if (e.code == 'wrong-password') {
        errorMessage = 'Current password is incorrect'.tr();
      } else {
        errorMessage = e.message ?? errorMessage;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Password').tr(),
          content: SingleChildScrollView(
            child: Form(
              key: _passwordFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Current Password'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'New Password'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password'.tr();
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match'.tr();
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _currentPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();
              },
              child: Text('Cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_passwordFormKey.currentState!.validate()) {
                  await _updatePassword();
                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: Text('Update'.tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double verticalSpacing = screenHeight * 0.025;
    double ButtonField = screenHeight * 0.06;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          _buildHeader('Account Settings'.tr()),
          _buildListTile('Profile'.tr(), Icons.person, () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Profile(fromsetting: true),
              ),
            );
          }),
          _buildListTile(
            'Change Password'.tr(),
            Icons.lock,
            _showChangePasswordDialog,
          ),
          _buildListTile('Privacy'.tr(), Icons.security, () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => Privacy()));
          }),
          _buildHeader('App Settings'.tr()),
          _buildListTile('Language'.tr(), Icons.language, () {
            _showLanguageDialog(context);
            // Navigate to language settings
          }),
          _buildHeader('Support'.tr()),
          _buildListTile('About'.tr(), Icons.info, () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Aboutus(
                  fromsetting: true,
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: ButtonField,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 36, 14, 144),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  ),
                ),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const Welcome(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text(
                  "Sign Out".tr(),
                  style: GoogleFonts.shipporiAntique(
                    fontSize: screenWidth * 0.045,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: verticalSpacing),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: ButtonField,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  ),
                ),
                onPressed: () {
                  showDeleteDialog(context);
                },
                child: Text(
                  "Delete My Accout".tr(),
                  style: GoogleFonts.shipporiAntique(
                    fontSize: screenWidth * 0.045,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTile(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: const TextStyle(color: Colors.black)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
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
