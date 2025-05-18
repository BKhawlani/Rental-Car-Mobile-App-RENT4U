import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_car_project/screen/signin_page.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:intl/intl.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  // Once signed in, return the UserCredential
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      dateOfbirth.text = formattedDate;
    }
  }

  void initState() {
    super.initState();
  }

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController rePassword = TextEditingController();
  TextEditingController phoneNum = TextEditingController();
  TextEditingController dateOfbirth = TextEditingController();
  String? genderValue;
  List<String> genderList = ['Male', 'Female'];

  GlobalKey<FormState> frmkey = GlobalKey<FormState>();
  PhoneNumber initialNumber = PhoneNumber(
    isoCode: 'TR',
  ); // يتم تعيينه مرة واحدة عند التهيئة
  PhoneNumber phoneNumber = PhoneNumber(isoCode: 'TR');
  bool inputerror = false;
  Future<void> addUser() {
    // Call the user's CollectionReference to add a new user
    return users
        .add({
          'full_name': name.text,
          'email': email.text,
          'password': password.text,
          'phoneNum': phoneNum.text,
          'dateOfbirth': dateOfbirth.text,
          'gender': genderValue,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double horizontalPadding = screenWidth * 0.05;
    double verticalSpacing = screenHeight * 0.02;
    double textFieldHeight = screenHeight * 0.05;
    double buttonHeight = screenHeight * 0.05;
    double fontSizeTitle = screenWidth * 0.08;
    double fontSizeSubtitle = screenWidth * 0.04;
    double fontSizeButton = screenWidth * 0.045;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sign up".tr(),
                style: GoogleFonts.outfit(fontSize: fontSizeTitle),
              ),
              SizedBox(height: verticalSpacing / 2),
              Text(
                "Please enter your information below".tr(),
                style: GoogleFonts.outfit(fontSize: fontSizeSubtitle),
              ),
              SizedBox(height: verticalSpacing),
              Form(
                key: frmkey,
                child: Column(
                  children: [
                    Container(
                      height:
                          inputerror ? textFieldHeight * 1.4 : textFieldHeight,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            setState(() {
                              setState(() {
                                inputerror = true;
                              });
                            });

                            return 'Please enter your name'.tr();
                          }

                          return null;
                        },
                        controller: name,
                        decoration: InputDecoration(
                          labelText: "Name".tr(),
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
                    SizedBox(height: 17),
                    SizedBox(
                      height: inputerror == true
                          ? textFieldHeight * 1.4
                          : textFieldHeight,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            setState(() {
                              setState(() {
                                inputerror = true;
                              });
                            });
                            return 'Please enter your email'.tr();
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            setState(() {
                              inputerror = true;
                            });
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
                    SizedBox(height: 17),
                    Container(
                      height:
                          inputerror ? textFieldHeight * 1.4 : textFieldHeight,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            setState(() {
                              inputerror = true;
                            });
                            return 'Please enter your password'.tr();
                          }
                          if (value.length < 6) {
                            setState(() {
                              inputerror = true;
                            });
                            return 'Password must be at least 6 characters'
                                .tr();
                          }
                          if (!RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,}$',
                          ).hasMatch(value)) {
                            setState(() {
                              inputerror = true;
                            });
                            return 'Password must contain at least one uppercase letter, one lowercase letter,and one number'
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
                    SizedBox(height: 17),
                    Container(
                      height:
                          inputerror ? textFieldHeight * 1.4 : textFieldHeight,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please repeat the password'.tr();
                          }

                          if (value != password.text) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              //auto validate icin gecikme yapimi
                              setState(() => inputerror = true);
                            });
                            return "Passwords aren't matches".tr();
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: rePassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Repeat Password".tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.07,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 17),
                    Container(
                      width: screenWidth,
                      height: inputerror
                          ? textFieldHeight * 1.4
                          : textFieldHeight * 1.2,
                      child: InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          setState(() {
                            phoneNumber = number;
                          });
                        },
                        selectorConfig: SelectorConfig(
                          selectorType: PhoneInputSelectorType.DROPDOWN,
                          showFlags: true,
                          useEmoji: true,
                        ),
                        ignoreBlank: true,
                        selectorTextStyle: TextStyle(color: Colors.black),
                        initialValue: phoneNumber,
                        textFieldController: phoneNum,
                        formatInput: true,
                        keyboardType: TextInputType.phone,
                        inputDecoration: InputDecoration(
                          labelText: "Phone Number".tr(),
                          hintText: "Enter your phone number".tr(),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() => inputerror = true);
                            });
                            return 'Please enter your phone number'.tr();
                          }
                          return null;
                        },
                        onSaved: (PhoneNumber number) {
                          print('Phone number saved: ${number.phoneNumber}');
                        },
                      ),
                    ),
                    SizedBox(height: 17),
                    Container(
                      height: textFieldHeight + 10,
                      child: DropdownButtonFormField<String>(
                        menuMaxHeight: 150,
                        value: genderValue,
                        hint: Text(
                          "Gender".tr(),
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        isExpanded: true,
                        alignment: Alignment.bottomCenter,
                        dropdownColor: Colors.white,
                        onChanged: (String? val) {
                          setState(() {
                            genderValue = val!;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.07,
                            ),
                          ),
                        ),
                        items: genderList.map<DropdownMenuItem<String>>((
                          String gender,
                        ) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender.tr()),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 17),
                    Container(
                      height:
                          inputerror ? textFieldHeight * 1.4 : textFieldHeight,
                      child: TextFormField(
                        controller: dateOfbirth,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Date of Birth".tr(),
                          hintText: "YYYY-MM-DD",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() => inputerror = true);
                            });
                            return 'Please enter your Date of Birth'.tr();
                          }
                          return null;
                        },
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    Builder(
                      builder: (context) => MaterialButton(
                        height: buttonHeight,
                        minWidth: double.infinity,
                        onPressed: () async {
                          try {
                            if (frmkey.currentState!.validate()) {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.noHeader,
                                animType: AnimType.bottomSlide,
                                body: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 20),
                                      Text(
                                        'Creating your account...'.tr(),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ).show();
                              final credential = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: email.text.trim(),
                                password: password.text.trim(),
                              );
                              final uid = credential.user!.uid;
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .set({
                                'fullName': name.text.trim(),
                                'phone': phoneNum.text.trim(),
                                'dateOfBirth': dateOfbirth.text.trim(),
                                'createdAt': FieldValue.serverTimestamp(),
                                'role': 'user',
                                'email': email.text,
                                'password': password.text,
                                'gender': genderValue,
                              });
                              // await addUser();

                              Navigator.pop(context);
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.success,
                                animType: AnimType.rightSlide,
                                title: "Registration Successful".tr(),
                                desc:
                                    'your account has been created successfully \n you can now log in'
                                        .tr(),
                                btnOkText: "Login".tr(),
                                btnOkOnPress: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(),
                                    ),
                                  );
                                },
                                btnOkColor: const Color.fromARGB(
                                  255,
                                  35,
                                  199,
                                  40,
                                ),
                                btnCancelText: "Email\n Verification".tr(),
                                btnCancelColor: const Color.fromARGB(
                                  255,
                                  35,
                                  199,
                                  40,
                                ),
                                btnCancelOnPress: () {
                                  FirebaseAuth.instance.currentUser!
                                      .sendEmailVerification();
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.info,
                                    animType: AnimType.bottomSlide,
                                    body: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Text(
                                            'A verification link has been sent to your email.\nPlease check your email and click the link to verify your account.'
                                                .tr(),
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    btnOkOnPress: () async {
                                      await FirebaseAuth.instance.signOut();
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => LoginPage(),
                                        ),
                                      );
                                    },
                                  ).show();
                                },
                              ).show();
                            }
                          } on FirebaseAuthException catch (e) {
                            String errorMessage =
                                " Error Occured while signing up".tr();
                            if (e.code == 'weak-password') {
                              errorMessage =
                                  'the password provided is too weak';
                            } else if (e.code == 'email-already-in-use') {
                              errorMessage =
                                  'The email address is already in use by another account'
                                      .tr();
                            } else if (e.code == 'invalid-email') {
                              errorMessage =
                                  'The email address is not valid'.tr();
                            }
                            if (Navigator.canPop(context))
                              Navigator.pop(context);
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error'.tr(),
                              desc: errorMessage,
                              btnOkOnPress: () {},
                            ).show();
                          } catch (e) {
                            if (Navigator.canPop(context))
                              Navigator.pop(context);
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Uknown Error'.tr(),
                              desc: 'Uknown Error'
                                  '${e.toString()}',
                              btnOkOnPress: () {},
                            ).show();
                          }
                        },
                        color: Color.fromARGB(255, 36, 14, 144),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          "Sign Up".tr(),
                          style: GoogleFonts.shipporiAntique(
                            fontSize: fontSizeButton,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing * 2),
              // Row(
              //   children: [
              //     Expanded(
              //       child: Divider(
              //         color: Colors.grey,
              //         thickness: 1,
              //         endIndent: 10,
              //       ),
              //     ),
              //     Text(
              //       "Or Continue With",
              //       style: GoogleFonts.outfit(fontSize: fontSizeSubtitle),
              //     ),
              //     Expanded(
              //       child: Divider(
              //         color: Colors.grey,
              //         thickness: 1,
              //         indent: 10,
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: verticalSpacing),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Container(
              //       height: screenWidth * 0.12,
              //       width: screenWidth * 0.12,
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: Colors.white,
              //         border: Border.all(color: Colors.grey, width: 1),
              //       ),
              //       child: ClipOval(
              //         child: MaterialButton(
              //           onPressed: () {},
              //           padding: const EdgeInsets.all(8),
              //           child: Image.asset(
              //             "assets/images/apple.png",
              //             fit: BoxFit.contain,
              //           ),
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: screenWidth * 0.13),
              //     Container(
              //       height: screenWidth * 0.12,
              //       width: screenWidth * 0.12,
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: Colors.white,
              //         border: Border.all(color: Colors.grey, width: 1),
              //       ),
              //       child: ClipOval(
              //         child: MaterialButton(
              //           onPressed: () {},
              //           padding: const EdgeInsets.all(8),
              //           child: Image.asset(
              //             "assets/images/facebook.png",
              //             fit: BoxFit.contain,
              //           ),
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: screenWidth * 0.13),
              //     Container(
              //       height: screenWidth * 0.12,
              //       width: screenWidth * 0.12,
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: Colors.white,
              //         border: Border.all(color: Colors.grey, width: 1),
              //       ),
              //       child: ClipOval(
              //         child: MaterialButton(
              //           onPressed: () {
              //             signInWithGoogle().then((value) {
              //               Navigator.of(context).pushReplacement(
              //                 MaterialPageRoute(
              //                   builder: (context) => LoginPage(),
              //                 ),
              //               );
              //             });
              //           },
              //           padding: const EdgeInsets.all(8),
              //           child: Image.asset(
              //             "assets/images/google.png",
              //             fit: BoxFit.contain,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: verticalSpacing),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildSocialButton(
  //   String assetPath,
  //   double screenWidth,
  //   void Function() onPressed,
  // ) {
  //   return Container(
  //     height: screenWidth * 0.12,
  //     width: screenWidth * 0.12,
  //     decoration: BoxDecoration(
  //       shape: BoxShape.circle,
  //       color: Colors.white,
  //       border: Border.all(color: Colors.grey, width: 1),
  //     ),
  //     child: ClipOval(
  //       child: MaterialButton(
  //         onPressed: () {
  //           Function() onPressed;
  //         },
  //         padding: const EdgeInsets.all(8),
  //         child: Image.asset(assetPath, fit: BoxFit.contain),
  //       ),
  //     ),
  //   );
  // }
}
