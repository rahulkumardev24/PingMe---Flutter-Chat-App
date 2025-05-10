import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ping_me/api/apis.dart';
import 'package:ping_me/model/chat_user_model.dart';
import 'package:ping_me/screen/auth/auth_service/auth_service.dart';
import 'package:ping_me/screen/auth/login_screen.dart';
import 'package:ping_me/utils/custom_text_style.dart';
import 'package:ping_me/widgets/my_navigation_button.dart';
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

  @override
  void initState() {
    super.initState();
    // Initialize status with user's current status
    _status = widget.user.status ?? "Available";
  }

  /// --- pick image form camera --- ///
  Future<void> _pickImageFromCamera() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
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

      Dialogs.myShowProgressbar(context);
      await APIs.updateUserProfilePicture(imageFile!);
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mqData = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        /// --- app bar --- ///
        appBar: AppBar(
          title: Text(
            'Profile',
            style: myTextStyle24(context, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyNavigationButton(
              btnIcon: Icons.arrow_back_ios_new_rounded,
              btnBackground: Colors.black12,
              iconSize: 21,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        /// body
        body: Form(
          key: _formKey,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  /// Profile Picture
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: mqData.width * 0.5,
                        height: mqData.width * 0.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade300,
                              Colors.orange.shade100,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
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
                                          (context, url, error) => const Icon(
                                            Icons.person,
                                            size: 60,
                                          ),
                                    ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _changePhoto(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade300,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// User Email
                  Text(
                    widget.user.email,
                    style: myTextStyle18(context, fontColor: Colors.black54),
                  ),

                  const SizedBox(height: 32),

                  /// Username Field
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 3),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        initialValue: widget.user.name,
                        onSaved: (val) => APIs.currentUser!.name = val ?? "",
                        validator:
                            (val) =>
                                val != null && val.isNotEmpty
                                    ? null
                                    : "Please fill the name",
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: InputBorder.none,
                          labelStyle: myTextStyle15(
                            context,
                            fontColor: Colors.black54,
                          ),
                          prefixIcon: Icon(Icons.person, color: Colors.orange),
                        ),
                        style: myTextStyle18(context),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // About Field
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 3),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        initialValue: widget.user.about,
                        onSaved: (val) => APIs.currentUser!.about = val ?? "",
                        validator:
                            (val) =>
                                val != null && val.isNotEmpty
                                    ? null
                                    : "Please fill the about",
                        decoration: InputDecoration(
                          labelText: 'About',
                          border: InputBorder.none,
                          labelStyle: myTextStyle15(
                            context,
                            fontColor: Colors.black54,
                          ),
                          prefixIcon: Icon(Icons.info, color: Colors.orange),
                        ),
                        style: myTextStyle18(context),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Status Selector
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 3),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonFormField<String>(
                        value: _status,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: InputBorder.none,
                          labelStyle: myTextStyle15(
                            context,
                            fontColor: Colors.black54,
                          ),
                          prefixIcon: Icon(
                            Icons.circle_notifications,
                            color: Colors.orange,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: "Available",
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Available",
                                  style: myTextStyle18(context),
                                ),
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
                                Text("Busy", style: myTextStyle18(context)),
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
                                Text("Away", style: myTextStyle18(context)),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _status = value);
                            /// Update the user model immediately when status changes
                            APIs.currentUser?.status = value;
                          }
                        },
                        dropdownColor: Theme.of(context).cardColor,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  /// --- Update button --- ///
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          /// Ensure status is saved to current user
                          APIs.currentUser?.status = _status;
                          APIs.updateCurrentUser();
                          Dialogs.myShowSnackBar(
                            context,
                            "Update Successfully",
                            Colors.greenAccent,
                            Colors.black87,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade100,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(width: 1, color: Colors.greenAccent),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text("Update", style: myTextStyle24(context)),
                    ),
                  ),

                  SizedBox(height: mqData.height * .1),

                  /// Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        authService.signOut().then((value) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withAlpha(20),
                        foregroundColor: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Logout",
                            style: myTextStyle15(
                              context,
                              fontColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _changePhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose Profile Picture",
                style: myTextStyle18(context, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera Button
                  Column(
                    children: [
                      SizedBox(
                        height: mqData.height * 0.1,
                        width: mqData.height * 0.1,
                        child: FloatingActionButton(
                          heroTag: 'camera',
                          onPressed: _pickImageFromCamera,
                          backgroundColor: Colors.orange.shade200,
                          elevation: 0,
                          child: Icon(
                            Icons.camera_alt,
                           size:mqData.height * .05,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Camera", style: myTextStyle18(context)),
                    ],
                  ),

                  /// Gallery Button
                  Column(
                    children: [
                      SizedBox(
                        height: mqData.height * 0.1,
                        width: mqData.height * 0.1,
                        child: FloatingActionButton(
                          heroTag: 'gallery',
                          onPressed: _pickImageFromGallery,
                          backgroundColor: Colors.orange.shade200,
                          elevation: 1,
                          child:  Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: mqData.height * .05,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Gallery", style: myTextStyle18(context)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
