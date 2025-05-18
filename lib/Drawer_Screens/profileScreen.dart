import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  bool fromsetting = false;
  Profile({required this.fromsetting});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;
  bool _isEditable = false;
  bool _hasChanges = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;
  late TextEditingController _genderController;
  File? _imageFile;
  GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  bool _showPasswordFields = false;
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _newEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _birthDateController = TextEditingController();
    _genderController = TextEditingController();
    _newEmailController = TextEditingController();
    loadUserData();
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

  Future<void> loadUserData() async {
    userData = await getUserData();
    if (userData != null) {
      _nameController.text = userData!['fullName'] ?? '';
      _emailController.text = userData!['email'] ?? '';
      _newEmailController.text = userData!['email'] ?? '';
      _phoneController.text = userData!['phone'] ?? '';
      _birthDateController.text = userData!['dateOfBirth'] ?? '';
      _genderController.text = userData!['gender'] ?? '';
    }
    setState(() {});
  }

  Future<void> _pickImage() async {
    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => SimpleDialog(
          title: Text('Choose the source of the image'.tr()),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: Row(children: [
                Icon(Icons.camera_alt),
                SizedBox(width: 10),
                Text('Camera'.tr())
              ]),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: Row(
                children: [
                  Icon(Icons.photo_library),
                  SizedBox(width: 10),
                  Text('Galery'.tr()),
                ],
              ),
            ),
          ],
        ),
      );

      if (source == null) return;

      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');

      // Upload the file to Firebase Storage
      await storageRef.putFile(_imageFile!);

      // Get the download URL
      final downloadURL = await storageRef.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Upload image if there's a new one
        String? photoUrl;
        if (_imageFile != null) {
          photoUrl = await _uploadImage();
        }

        final updateData = {
          'fullName': _nameController.text,
          'phone': _phoneController.text,
          'dateOfBirth': _birthDateController.text,
          'gender': _genderController.text,
          if (photoUrl != null) 'photo': photoUrl,
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(updateData);
        scaffoldkey.currentState?.openDrawer();
        scaffoldkey.currentState?.closeDrawer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully'.tr())),
        );

        setState(() {
          _isEditable = false;
          _hasChanges = false;
          userData?['fullName'] = _nameController.text;
          userData?['phone'] = _phoneController.text;
          userData?['dateOfBirth'] = _birthDateController.text;
          userData?['gender'] = _genderController.text;
          if (photoUrl != null) userData?['photo'] = photoUrl;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _updatePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Passwords do not match'.tr())));
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
        const SnackBar(content: Text('Password updated successfully')),
      );

      setState(() {
        _showPasswordFields = false;
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'wrong-password') {
        errorMessage = 'Current password is incorrect';
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double fontSizeTitle = screenWidth * 0.06;
    double ButtonField = screenHeight * 0.06;
    return Scaffold(
      appBar: widget.fromsetting
          ? AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
              ),
              backgroundColor: Color.fromARGB(255, 36, 14, 144),
              title: Text(
                "My profile".tr(),
                style: GoogleFonts.outfit(
                  fontSize: fontSizeTitle,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      extendBodyBehindAppBar: true,
      key: scaffoldkey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 36, 14, 144),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    GestureDetector(
                      onTap: _isEditable ? _pickImage : null,
                      child: Stack(
                        children: [
                          ClipOval(
                            child: _imageFile != null
                                ? Image.file(
                                    _imageFile!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    userData?['photo'] ??
                                        "https://i.pinimg.com/736x/98/1d/6b/981d6b2e0ccb5e968a0618c8d47671da.jpg",
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          if (_isEditable)
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _isEditable
                        ? Container(
                            width: screenWidth * 0.6,
                            child: TextFormField(
                              controller: _nameController,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              decoration: InputDecoration(
                                hintText: "Name".tr(),
                                hintStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                border: InputBorder.none,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _hasChanges = true;
                                });
                              },
                            ),
                          )
                        : Text(
                            userData?['fullName'] ?? 'No Name',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Email Field
              _buildEditableField(
                context: context,
                label: 'Email'.tr(),
                controller: _emailController,
                isEditable: false,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              // Phone Field
              _buildEditableField(
                context: context,
                label: 'Phone Number'.tr(),
                controller: _phoneController,
                isEditable: _isEditable,
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  setState(() {
                    _hasChanges = true;
                  });
                },
              ),

              const SizedBox(height: 10),

              _buildEditableField(
                context: context,
                label: 'Date of Birth'.tr(),
                controller: _birthDateController,
                isEditable: _isEditable,
                onTap: _isEditable
                    ? () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          _birthDateController.text =
                              "${date.year}-${date.month}-${date.day}";
                          setState(() {
                            _hasChanges = true;
                          });
                        }
                      }
                    : null,
                onChanged: (value) {
                  setState(() {
                    _hasChanges = true;
                  });
                },
              ),

              const SizedBox(height: 10),

              // Gender Field
              _buildEditableField(
                context: context,
                label: 'Gender'.tr(),
                controller: _genderController,
                isEditable: _isEditable,
                onTap: _isEditable
                    ? () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Select Gender'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text('Male'.tr()),
                                  onTap: () {
                                    _genderController.text = 'Male'.tr();
                                    setState(() {
                                      _hasChanges = true;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: Text('Female'.tr()),
                                  onTap: () {
                                    _genderController.text = 'Female'.tr();
                                    setState(() {
                                      _hasChanges = true;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    : null,
                onChanged: (value) {
                  setState(() {
                    _hasChanges = true;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Change Password Section
              if (!_showPasswordFields && !_isEditable)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showPasswordFields = true;
                    });
                  },
                  child: Text('Change Password'.tr()),
                ),

              if (_showPasswordFields)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Form(
                    key: _passwordFormKey,
                    child: Column(
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
                            if (value != userData!['password']) {
                              return 'Current password is incorrect'.tr();
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
                              return 'Password must be at least 6 characters'
                                  .tr();
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
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showPasswordFields = false;
                                  _currentPasswordController.clear();
                                  _newPasswordController.clear();
                                  _confirmPasswordController.clear();
                                });
                              },
                              child: Text('Cancel'.tr()),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _updatePassword,
                              child: Text('Update Password'.tr()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              if (!_isEditable)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditable = true;
                      _newEmailController.text = _emailController.text;
                    });
                  },
                  child: Text('Edit Profile'.tr()),
                ),

              if (_isEditable)
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            36,
                            14,
                            144,
                          ),
                        ),
                        onPressed: _saveChanges,
                        child: Text(
                          "Save Profile Changes".tr(),
                          style: GoogleFonts.shipporiAntique(
                            fontSize: screenWidth * 0.045,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditable = false;
                          _hasChanges = false;
                          loadUserData();
                          _imageFile = null;
                        });
                      },
                      child: Text('Cancel'.tr()),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required bool isEditable,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: !isEditable || onTap != null,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
          suffixIcon: isEditable ? const Icon(Icons.edit) : null,
        ),
        onTap: onTap,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
