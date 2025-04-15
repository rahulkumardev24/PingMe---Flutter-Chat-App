import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ping_me/model/chat_user_model.dart';
import 'package:ping_me/screen/auth/auth_service/auth_service.dart';
import 'package:ping_me/screen/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthService authService = AuthService();
  String _status = "Available";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// this is use for when click any when in the screen keyboard close
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editProfile(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Picture
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
                        child: CachedNetworkImage(
                          imageUrl: widget.user.imageUrl.toString(),
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const CircularProgressIndicator(),
                          errorWidget:
                              (context, url, error) => const Icon(Icons.person),
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
      
              // User Email
              Text(
                widget.user.email,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
      
              TextFormField(
                initialValue: widget.user.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
      
              const SizedBox(height: 16),
      
              // Status Selector
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
                        Icon(Icons.remove_circle, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text("Busy"),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: "Away",
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.orange, size: 16),
                        SizedBox(width: 8),
                        Text("Away"),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: "Invisible",
                    child: Row(
                      children: [
                        Icon(Icons.visibility_off, color: Colors.grey, size: 16),
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
              ElevatedButton(onPressed: (){
                authService.signOut().then((value){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginScreen() ));
                });
      
              }, child: Text("Logout"))
            ],
          ),
        ),
      ),
    );
  }

  void _editProfile() {
    // Implement edit profile functionality
  }

  void _changePhoto() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(onPressed: (){}, icon: Icon(CupertinoIcons.camera_fill , size: 60,)),
              IconButton(onPressed: (){}, icon: Icon(Icons.photo, size: 60,)),
            ]
          ),
        );
      },
    );
  }
}
