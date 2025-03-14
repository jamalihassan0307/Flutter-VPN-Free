class VpnConfig {
  final String name;
  final String config;
  final String? username;
  final String? password;

  VpnConfig({
    required this.name,
    required this.config,
    this.username,
    this.password,
  });
}
