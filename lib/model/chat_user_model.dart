class ChatUserModel {
  late String userId;
  late String name;
  late String email;
  late String? imageUrl;
  late String? about;
  late String? status;
  late String lastActive;
  late String createdAt;
  late bool isOnline;
  late String? pushToken;

  ChatUserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.createdAt,
    this.imageUrl,
    this.about,
    required this.lastActive,
    this.isOnline = false,
    this.status = "Available",
    this.pushToken,
  });

  /// Convert model to JSON for Firebase or API
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'about': about,
      'lastActive': lastActive ,
      'createdAt': createdAt,
      'isOnline': isOnline,
      'pushToken': pushToken,
      'status' : status,
    };
  }

  // Create model from JSON
  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      imageUrl: json['imageUrl'],
      about: json['about'],
      lastActive:json['lastActive'],
      isOnline: json['isOnline'] ?? false,
      pushToken: json['pushToken'],
      createdAt: json['createdAt'],
      status: json['status'],
    );
  }
}