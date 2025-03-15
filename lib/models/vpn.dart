class Vpn {
  final String hostname;
  final String ip;
  final String ping;
  final String speed;
  final String countryLong;
  final String countryShort;
  final int numVpnSessions;
  final String config;

  Vpn({
    this.hostname = '',
    this.ip = '',
    this.ping = '',
    this.speed = '',
    this.countryLong = '',
    this.countryShort = '',
    this.numVpnSessions = 0,
    this.config = '',
  });

  factory Vpn.fromJson(Map<String, dynamic> json) => Vpn(
        hostname: json['HostName'] ?? '',
        ip: json['IP'] ?? '',
        ping: json['Ping']?.toString() ?? '',
        speed: json['Speed']?.toString() ?? '',
        countryLong: json['CountryLong'] ?? '',
        countryShort: json['CountryShort'] ?? '',
        numVpnSessions: json['NumVpnSessions'] ?? 0,
        config: json['Config'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'HostName': hostname,
        'IP': ip,
        'Ping': ping,
        'Speed': speed,
        'CountryLong': countryLong,
        'CountryShort': countryShort,
        'NumVpnSessions': numVpnSessions,
        'Config': config,
      };
}
