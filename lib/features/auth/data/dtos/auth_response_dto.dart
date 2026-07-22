class AuthResponseDto {
  final String token;
  final String displayName;
  final String email;

  const AuthResponseDto({
    required this.token,
    required this.displayName,
    required this.email,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      token: json['token'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}
