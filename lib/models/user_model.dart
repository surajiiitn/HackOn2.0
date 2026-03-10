class UserModel {
  final String? id;
  final String phoneNumber;
  final String? name;
  final bool isVerified;
  final bool locationPermission;
  final bool microphonePermission;
  final bool smsPermission;

  const UserModel({
    this.id,
    required this.phoneNumber,
    this.name,
    this.isVerified = false,
    this.locationPermission = false,
    this.microphonePermission = false,
    this.smsPermission = false,
  });

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    bool? isVerified,
    bool? locationPermission,
    bool? microphonePermission,
    bool? smsPermission,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      isVerified: isVerified ?? this.isVerified,
      locationPermission: locationPermission ?? this.locationPermission,
      microphonePermission: microphonePermission ?? this.microphonePermission,
      smsPermission: smsPermission ?? this.smsPermission,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      phoneNumber: json['phone_number'] as String,
      name: json['name'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      locationPermission: json['location_permission'] as bool? ?? false,
      microphonePermission: json['microphone_permission'] as bool? ?? false,
      smsPermission: json['sms_permission'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'name': name,
      'is_verified': isVerified,
      'location_permission': locationPermission,
      'microphone_permission': microphonePermission,
      'sms_permission': smsPermission,
    };
  }
}
