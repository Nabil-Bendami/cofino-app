import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String cafeId;
  final String fullName;
  final String? email;
  final String role;
  final bool isActive;
  final String? cafeName;
  final String? cafeCity;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.cafeId,
    required this.fullName,
    this.email,
    required this.role,
    required this.isActive,
    this.cafeName,
    this.cafeCity,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isManager => role == 'manager';
  bool get isServeur => role == 'serveur';

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      cafeId: json['cafe_id'],
      fullName: json['full_name'],
      email: json['email'],
      role: json['role'],
      isActive: json['is_active'] ?? true,
      cafeName: (json['cafes'] as Map<String, dynamic>?)?['name'],
      cafeCity: (json['cafes'] as Map<String, dynamic>?)?['city'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cafe_id': cafeId,
      'full_name': fullName,
      'email': email,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? cafeId,
    String? fullName,
    String? email,
    String? role,
    bool? isActive,
    String? cafeName,
    String? cafeCity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      cafeId: cafeId ?? this.cafeId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      cafeName: cafeName ?? this.cafeName,
      cafeCity: cafeCity ?? this.cafeCity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cafeId,
        fullName,
        email,
        role,
        isActive,
        cafeName,
        cafeCity,
        createdAt,
        updatedAt,
      ];
}
