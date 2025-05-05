import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ping_me/api/apis.dart';
import 'package:ping_me/model/chat_user_model.dart';
import 'package:ping_me/screen/auth/auth_service/auth_service.dart';
import 'package:ping_me/screen/auth/login_screen.dart';
import 'package:ping_me/utils/colors.dart';
import 'package:ping_me/utils/custom_text_style.dart';

import '../helper/dialogs.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Size mqData = MediaQuery.of(context).size;
  AuthService authService = AuthService();
  String _status = "Available";
  final _formKey = GlobalKey<FormState>();
  File? imageFile;

  /// --- pick image form camera --- ///
  Future<void> _pickImageFromCamera() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
      /// here we call profile image change function
      APIs.updateUserProfilePicture(imageFile!);
      Navigator.pop(context);
    }
  }
/// --- pick image from gallery --- ///
  Future<void> _pickImageFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });

      /// Show loading dialog
      Dialogs.myShowProgressbar(context);

      /// Await profile update
      await APIs.updateUserProfilePicture(imageFile!);

      /// Close progress dialog AFTER upload completes
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// this is use for when click any when in the screen keyboard close
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        /// --- appbar --- ///
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editProfile(),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// Profile Picture
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child:
                                imageFile != null
                                    ? Image.file(imageFile!, fit: BoxFit.cover)
                                    : CachedNetworkImage(
                                      imageUrl: widget.user.imageUrl.toString(),
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) =>
                                              const CircularProgressIndicator(),
                                      errorWidget:
                                          (context, url, error) =>
                                              const Icon(Icons.person),
                                    ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 18),
                              color: Colors.white,
                              onPressed: () => _changePhoto(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// User Email
                  Text(
                    widget.user.email,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),

                  /// --- username --- ///
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.currentUser!.name = val ?? "",
                    validator:
                        (val) =>
                            val != null && val.isNotEmpty
                                ? null
                                : "plz fill the name",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  /// --- about --- ///
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.currentUser!.about = val ?? "",
                    validator:
                        (val) =>
                            val != null && val.isNotEmpty
                                ? null
                                : "plz fill the about",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Status Selector
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Available",
                        child: Row(
                          children: [
                            Icon(Icons.circle, color: Colors.green, size: 16),
                            SizedBox(width: 8),
                            Text("Available"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Busy",
                        child: Row(
                          children: [
                            Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text("Busy"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Away",
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.orange,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text("Away"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Invisible",
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility_off,
                              color: Colors.grey,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text("Invisible"),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  /// --- update button --- ///
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateCurrentUser();
                        Dialogs.myShowSnackBar(
                          context,
                          "Update Successfully",
                          Colors.greenAccent,
                          Colors.black87,
                        );
                      }
                    },
                    child: Text("Update"),
                  ),

                  /// - logout button --- ///
                  ElevatedButton(
                    onPressed: () {
                      authService.signOut().then((value) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      });
                    },
                    child: Text("Logout"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editProfile() {}

  void _changePhoto() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Container(
            height: mqData.height * 0.25,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Pick profile picture", style: myTextStyle18(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// --- cameras button --- ///
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: ElevatedButton(
                        onPressed: _pickImageFromCamera,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.blue.withAlpha(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.camera_fill,
                          size: 60,
                          color: Colors.blue.shade300,
                        ),
                      ),
                    ),

                    /// --- gallery button --- ///
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: ElevatedButton(
                        onPressed: _pickImageFromGallery,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.blue.withAlpha(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.photo,
                          size: 60,
                          color: Colors.blue.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
