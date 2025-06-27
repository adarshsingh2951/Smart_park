class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final Map<String, bool> roles; // <-- New!

  AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.roles,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) => AppUser(
        uid: data['uid'],
        displayName: data['displayName'],
        email: data['email'],
        photoUrl: data['photoUrl'],
        roles: Map<String, bool>.from(data['roles'] ?? {}),
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'roles': roles,
      };
}
