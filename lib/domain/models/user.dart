enum AuthProvider { google, microsoft, apple, dropbox, guest }

class AppUser {
  final String id;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final AuthProvider provider;
  final DateTime? lastSyncedAt;

  const AppUser({
    required this.id,
    required this.displayName,
    this.email,
    this.avatarUrl,
    this.provider = AuthProvider.guest,
    this.lastSyncedAt,
  });

  factory AppUser.guest() => const AppUser(
        id: 'guest',
        displayName: 'Guest',
        provider: AuthProvider.guest,
      );

  AppUser copyWith({
    String? id,
    String? displayName,
    String? email,
    String? avatarUrl,
    AuthProvider? provider,
    DateTime? lastSyncedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      provider: provider ?? this.provider,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'provider': provider.name,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      provider: AuthProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => AuthProvider.guest,
      ),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
    );
  }
}
