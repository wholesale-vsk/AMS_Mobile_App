class JwtTokenData {
  final int exp;
  final int iat;
  final String jti;
  final String iss;
  final String aud;
  final String sub;
  final String typ;
  final String azp;
  final String sid;
  final String acr;
  final List<String> allowedOrigins;
  final List<String> realmRoles;
  final List<String> accountRoles;
  final String scope;
  final bool emailVerified;
  final String name;
  final String preferredUsername;
  final String givenName;
  final String familyName;
  final String email;

  //::::::::::::::::::>> Constructor << :::::::::::::::::://
  JwtTokenData({
    required this.exp,
    required this.iat,
    required this.jti,
    required this.iss,
    required this.aud,
    required this.sub,
    required this.typ,
    required this.azp,
    required this.sid,
    required this.acr,
    required this.allowedOrigins,
    required this.realmRoles,
    required this.accountRoles,
    required this.scope,
    required this.emailVerified,
    required this.name,
    required this.preferredUsername,
    required this.givenName,
    required this.familyName,
    required this.email,
  });

  //::::::::::::::::::>> Factory method to create an instance from a decoded JSON map << :::::::::::::::::://
  factory JwtTokenData.fromJson(Map<String, dynamic> json) {
    return JwtTokenData(
      exp: json['exp'],
      iat: json['iat'],
      jti: json['jti'],
      iss: json['iss'],
      aud: json['aud'],
      sub: json['sub'],
      typ: json['typ'],
      azp: json['azp'],
      sid: json['sid'],
      acr: json['acr'],
      allowedOrigins: List<String>.from(json['allowed-origins']),
      realmRoles: List<String>.from(json['realm_access']['roles']),
      accountRoles: List<String>.from(json['resource_access']['account']['roles']),
      scope: json['scope'],
      emailVerified: json['email_verified'],
      name: json['name'],
      preferredUsername: json['preferred_username'],
      givenName: json['given_name'],
      familyName: json['family_name'],
      email: json['email'],
    );
  }

  //::::::::::::::::::>> Method to check if the token is expired << :::::::::::::::::://
  bool isTokenExpired() {
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return exp < currentTime;
  }

  Duration timeUntilExpiration() {
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return Duration(seconds: exp - currentTime);
  }

  @override
  String toString() {
    return 'JwtTokenData{name: $name, email: $email, username: $preferredUsername, roles: $realmRoles}';
  }
}
