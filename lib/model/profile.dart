class Profile {
  final String id;
  final String name;
  final String platform; // 'android' or 'ios'
  final DateTime createdAt;
  final bool isDefault;
  final String? remotePayloadUrl;

  Profile({
    required this.id,
    required this.name,
    required this.platform,
    required this.createdAt,
    this.isDefault = false,
    this.remotePayloadUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'platform': platform,
        'createdAt': createdAt.toIso8601String(),
        'isDefault': isDefault,
        if (remotePayloadUrl != null) 'remotePayloadUrl': remotePayloadUrl,
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'],
        name: json['name'],
        platform: json['platform'],
        createdAt: DateTime.parse(json['createdAt']),
        isDefault: json['isDefault'] ?? false,
        remotePayloadUrl: json['remotePayloadUrl'],
      );

  /// Default WebEngage profiles
  static Profile defaultAndroid() => Profile(
        id: 'webengage_android',
        name: 'WebEngage',
        platform: 'android',
        createdAt: DateTime(2024, 1, 1),
        isDefault: true,
        remotePayloadUrl:
            'https://raw.githubusercontent.com/MilindWebEngage/sampleimages/refs/heads/pushpayload/android.json',
      );

  static Profile defaultIos() => Profile(
        id: 'webengage_ios',
        name: 'WebEngage',
        platform: 'ios',
        createdAt: DateTime(2024, 1, 1),
        isDefault: true,
        remotePayloadUrl:
            'https://raw.githubusercontent.com/MilindWebEngage/sampleimages/refs/heads/pushpayload/ios.json',
      );
}
