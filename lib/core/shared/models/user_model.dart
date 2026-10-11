import '../../utils/enums/users_table_columns.dart';

class UserModel {
  final String? id;
  final String firstName;
  final String secondName;
  final String email;
  final String phone;
  final String? street;
  final String? building;
  final String? apartment;
  final bool hasProfileImage;
  final bool verified;
  final bool pending;

  UserModel({
    this.id,
    required this.firstName,
    required this.secondName,
    required this.email,
    required this.phone,
    this.street,
    this.building,
    this.apartment,
    this.hasProfileImage = false,
    this.verified = false,
    this.pending = false,
  });

  UserModel copyWith({
    String? id,
    String? firstName,
    String? secondName,
    String? email,
    String? phone,
    String? street,
    String? building,
    String? apartment,
    bool? hasProfileImage,
    bool? verified,
    bool? pending,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      building: building ?? this.building,
      apartment: apartment ?? this.apartment,
      hasProfileImage: hasProfileImage ?? this.hasProfileImage,
      verified: verified ?? this.verified,
      pending: pending ?? this.pending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) UsersTableColumns.id: id,
      UsersTableColumns.firstName: firstName,
      UsersTableColumns.secondName: secondName,
      UsersTableColumns.email: email,
      UsersTableColumns.phone: phone,
      if (street != null) UsersTableColumns.street: street,
      if (building != null) UsersTableColumns.building: building,
      if (apartment != null) UsersTableColumns.apartment: apartment,
      UsersTableColumns.hasProfileImage: hasProfileImage,
      UsersTableColumns.verified: verified,
      UsersTableColumns.pending: pending,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json[UsersTableColumns.id] as String?,
      firstName: json[UsersTableColumns.firstName] as String? ?? "",
      secondName: json[UsersTableColumns.secondName] as String? ?? "",
      email: json[UsersTableColumns.email] as String? ?? "",
      phone: json[UsersTableColumns.phone] as String? ?? "",
      street: json[UsersTableColumns.street] as String?,
      building: json[UsersTableColumns.building] as String?,
      apartment: json[UsersTableColumns.apartment] as String?,
      hasProfileImage: json[UsersTableColumns.hasProfileImage] as bool? ?? false,
      verified: json[UsersTableColumns.verified] as bool? ?? false,
      pending: json[UsersTableColumns.pending] as bool? ?? false,
    );
  }
}