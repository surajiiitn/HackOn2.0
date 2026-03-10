class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? avatarUrl;
  final bool isActive;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.avatarUrl,
    this.isActive = true,
  });

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? avatarUrl,
    bool? isActive,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'is_active': isActive,
    };
  }
}
