import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_car_project/screen/home_page.dart';
import 'package:rental_car_project/screen/navigator.dart';
import 'package:rental_car_project/screen/signup_page.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCredential.user;
    if (user != null) {
      String name = user.displayName ?? 'No Name';
      String email = user.email ?? 'No Email';
      String photo = user.photoURL ?? 'No Photo';
      String phonenum = user.phoneNumber ?? 'No Phone';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = user.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': name,
        'email': email,
        'photo': photo,
      }, SetOptions(merge: true));
    }
  }

  bool rememberMe = false;
  bool passerror = false;
  bool emailerror = false;
  bool userfound = false;
  String? Loginerror;
  TextEditingController email = TextEditingController();
  TextEditingController resetemail = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> Signfrm = GlobalKey<FormState>();
  GlobalKey<FormState> resetfrm = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    loadSavedLogin();
  }

  void loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isRemembered = prefs.getBool('remember_me') ?? false;

    if (isRemembered) {
      email.text = prefs.getString('email') ?? '';
      password.text = prefs.getString('password') ?? '';
      setState(() {
        rememberMe = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double paddingHorizontal = screenWidth * 0.05;
    double verticalSpacing = screenHeight * 0.025;
    double ButtonField = screenHeight * 0.06;
    double fontSizeTitle = screenWidth * 0.08;
    double fontSizeSubtitle = screenWidth * 0.04;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.all(screenWidth * 0.015),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
          width: screenWidth,
          height: screenHeight,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.04),
              Text(
                "Sign in".tr(),
                style: GoogleFonts.outfit(fontSize: fontSizeTitle),
              ),
              SizedBox(height: verticalSpacing / 2),
              Text(
                "Please enter your login credentials below".tr(),
                style: GoogleFonts.outfit(fontSize: fontSizeSubtitle),
              ),
              SizedBox(height: verticalSpacing * 2),
              Form(
                key: Signfrm,
                child: Column(
                  children: [
                    SizedBox(
                      height: emailerror || userfound
                          ? ButtonField * 1.4
                          : ButtonField,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email'.tr();
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address'.tr();
                          }
                          return null;
                        },
                        controller: email,
                        decoration: InputDecoration(
                          labelText: "Email".tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.07,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.07,
                            ),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing / 1.5),
                    SizedBox(
                      height: emailerror || userfound || passerror
                          ? ButtonField * 1.4
                          : ButtonField,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password'.tr();
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters'
                                .tr();
                          }
                          return null;
                        },
                        controller: password,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password".tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.07,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing / 2),
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (val) {
                            setState(() {
                              rememberMe = val!;
                            });
                          },
                        ),
                        Text(
                          "Remember me".tr(),
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.040,
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.info,
                              animType: AnimType.rightSlide,
                              title: 'Password Reset'.tr(),
                              onDismissCallback: (type) {},
                              body: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Please enter your email address to receive a password reset link.'
                                        .tr(),
                                    style: GoogleFonts.outfit(
                                      fontSize: screenWidth * 0.040,
                                    ),
                                  ),
                                  SizedBox(height: verticalSpacing),
                                  Form(
                                    key: resetfrm,
                                    child: TextFormField(
                                      validator: (val) {
                                        if (val == null || val.isEmpty) {
                                          return 'Please enter your email'.tr();
                                        }
                                        if (!RegExp(
                                          r'^[^@]+@[^@]+\.[^@]+',
                                        ).hasMatch(val)) {
                                          return 'Please enter a valid email address'
                                              .tr();
                                        }
                                        return null;
                                      },
                                      controller: resetemail,
                                      decoration: InputDecoration(
                                        labelText: "Email".tr(),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            screenWidth * 0.07,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              btnOkText: "Send".tr(),
                              btnOkOnPress: () async {
                                if (resetfrm.currentState!.validate()) {
                                  try {
                                    await FirebaseAuth.instance
                                        .sendPasswordResetEmail(
                                      email: resetemail.text.trim(),
                                    );

                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.success,
                                      animType: AnimType.rightSlide,
                                      title: 'Success'.tr(),
                                      desc:
                                          'A reset link has been sent to your email.'
                                              .tr(),
                                      btnOkOnPress: () {},
                                    ).show();
                                  } on FirebaseAuthException catch (e) {
                                    String errorMessage =
                                        'The email address is invalid.'.tr();
                                    if (e.code == 'user-not-found') {
                                      errorMessage =
                                          'No user found with this email.';
                                    } else if (e.code == 'invalid-email') {
                                      errorMessage =
                                          'The email address is invalid.'.tr();
                                    }

                                    Navigator.of(context).pop();

                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.rightSlide,
                                      title: 'Error'.tr(),
                                      desc: errorMessage,
                                      btnOkOnPress: () {},
                                    ).show();
                                  }
                                }
                              },
                            ).show();
                          },
                          child: Text(
                            "Forgot Password?".tr(),
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.040,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing),
              Builder(
                builder: (context) => MaterialButton(
                  onPressed: () async {
                    setState(() {
                      emailerror = false;
                      passerror = false;
                      userfound = true;
                    });
                    if (Signfrm.currentState!.validate()) {
                      try {
                        final credential = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                          email: email.text.trim(),
                          password: password.text.trim(),
                        );

                        if (credential.user != null) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => MainNavigator(),
                            ),
                          );
                        }
                        if (rememberMe) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('remember_me', true);
                          await prefs.setString('email', email.text.trim());
                          await prefs.setString(
                            'password',
                            password.text.trim(),
                          );
                        } else {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('remember_me', false);
                          await prefs.remove('email');
                          await prefs.remove('password');
                        }
                      } on FirebaseAuthException catch (e) {
                        String errorMessage =
                            'The email or password is incorrect'.tr();

                        if (e.code == 'user-not-found') {
                          errorMessage = 'No user found with this email.'.tr();
                        } else if (e.code == 'wrong-password') {
                          errorMessage = 'Incorrect password.';
                        } else if (e.code == 'invalid-email') {
                          errorMessage = 'The email address is invalid.'.tr();
                        }

                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: 'Login Failed'.tr(),
                          desc: errorMessage,
                          btnOkOnPress: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Signup(),
                              ),
                            );
                          },
                          btnOkText: "Sign up".tr(),
                          btnCancelOnPress: () {},
                          btnCancelText: "Cancel".tr(),
                        ).show();
                      } catch (e) {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: 'Error'.tr(),
                          desc:
                              'An unexpected error occurred. Please try again.'
                                  .tr(),
                          btnOkOnPress: () {},
                        ).show();
                      }
                    }
                    ;
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: ButtonField,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 36, 14, 144),
                      borderRadius: BorderRadius.circular(
                        screenWidth * 0.05,
                      ),
                    ),
                    child: Text(
                      "Sign in".tr(),
                      style: GoogleFonts.shipporiAntique(
                        fontSize: screenWidth * 0.045,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: verticalSpacing * 2.5),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      thickness: 1,
                      endIndent: 10,
                    ),
                  ),
                  Text(
                    "Or Continue With".tr(),
                    style: GoogleFonts.outfit(fontSize: fontSizeSubtitle),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      thickness: 1,
                      indent: 10,
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalSpacing * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: screenWidth * 0.12,
                    width: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: ClipOval(
                      child: MaterialButton(
                        onPressed: () {},
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          "assets/images/apple.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.13),
                  Container(
                    height: screenWidth * 0.12,
                    width: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: ClipOval(
                      child: MaterialButton(
                        onPressed: () {},
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          "assets/images/facebook.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.13),
                  Container(
                    height: screenWidth * 0.12,
                    width: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: ClipOval(
                      child: MaterialButton(
                        onPressed: () {
                          signInWithGoogle().then((value) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => MainNavigator(),
                              ),
                            );
                          });
                        },
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          "assets/images/google.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalSpacing * 2),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => Signup()));
                  },
                  child: Text(
                    "Don't have an account? Sign up".tr(),
                    style: GoogleFonts.outfit(fontSize: screenWidth * 0.035),
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
