class ChatUserModel {
  final String userId;
  final String name;
  final String email;
  final String? imageUrl;
  final String? about;
  final DateTime lastActive;
  final bool isOnline;
  final String? pushToken;

  ChatUserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.imageUrl,
    this.about,
    required this.lastActive,
    this.isOnline = false,
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
      'lastActive': lastActive.toIso8601String(),
      'isOnline': isOnline,
      'pushToken': pushToken,
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
      lastActive: DateTime.parse(json['lastActive']),
      isOnline: json['isOnline'] ?? false,
      pushToken: json['pushToken'],
    );
  }
}
