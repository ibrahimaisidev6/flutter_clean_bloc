class UserProfile {
  final String username;
  final String email;

  UserProfile({
    required this.username, 
    required this.email,
  });

  // Factory constructor should be inside the class
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }

  // toJson method should also be inside the class
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
    };
  }

  // Optional: Add copyWith method for easier updates
  UserProfile copyWith({
    String? username,
    String? email,
  }) {
    return UserProfile(
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }

  // Optional: Add toString for debugging
  @override
  String toString() {
    return 'UserProfile(username: $username, email: $email)';
  }

  // Optional: Add equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.username == username &&
        other.email == email;
  }

  @override
  int get hashCode => username.hashCode ^ email.hashCode;
}