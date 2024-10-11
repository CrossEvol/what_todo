import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class UserProfile {
  int? id;
  final String name;
  final String email;
  final String avatarUrl;
  final DateTime updatedAt;

  UserProfile({
    this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.updatedAt,
  });

  UserProfile.create(
      {required this.name,
      required this.email,
      required this.avatarUrl,
      required this.updatedAt});

  UserProfile.update(
      {required this.id,
      required this.name,
      required this.email,
      required this.avatarUrl,
      required this.updatedAt});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'email': this.email,
      'avatarUrl': this.avatarUrl,
      'updatedAt': this.updatedAt,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      avatarUrl: map['avatarUrl'] as String,
      updatedAt: map['updatedAt'] as DateTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          avatarUrl == other.avatarUrl &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      avatarUrl.hashCode ^
      updatedAt.hashCode;
}
