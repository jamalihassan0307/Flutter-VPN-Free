// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Vpn {
  final String hostname;
  final String ip;
  final String ping;
  final String speed;
  final String countryLong;
  final String countryShort;
  final String imagePath;
  final String vpnConfigPath;
  Vpn({
    required this.hostname,
    required this.ip,
    required this.ping,
    required this.speed,
    required this.countryLong,
    required this.countryShort,
    required this.imagePath,
    required this.vpnConfigPath,
  });



  Vpn copyWith({
    String? hostname,
    String? ip,
    String? ping,
    String? speed,
    String? countryLong,
    String? countryShort,
    String? imagePath,
    String? vpnConfigPath,
  }) {
    return Vpn(
      hostname: hostname ?? this.hostname,
      ip: ip ?? this.ip,
      ping: ping ?? this.ping,
      speed: speed ?? this.speed,
      countryLong: countryLong ?? this.countryLong,
      countryShort: countryShort ?? this.countryShort,
      imagePath: imagePath ?? this.imagePath,
      vpnConfigPath: vpnConfigPath ?? this.vpnConfigPath,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'hostname': hostname,
      'ip': ip,
      'ping': ping,
      'speed': speed,
      'countryLong': countryLong,
      'countryShort': countryShort,
      'imagePath': imagePath,
      'vpnConfigPath': vpnConfigPath,
    };
  }

  factory Vpn.fromMap(Map<String, dynamic> map) {
    return Vpn(
      hostname: map['hostname'] as String,
      ip: map['ip'] as String,
      ping: map['ping'] as String,
      speed: map['speed'] as String,
      countryLong: map['countryLong'] as String,
      countryShort: map['countryShort'] as String,
      imagePath: map['imagePath'] as String,
      vpnConfigPath: map['vpnConfigPath'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Vpn.fromJson(String source) => Vpn.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Vpn(hostname: $hostname, ip: $ip, ping: $ping, speed: $speed, countryLong: $countryLong, countryShort: $countryShort, imagePath: $imagePath, vpnConfigPath: $vpnConfigPath)';
  }

  @override
  bool operator ==(covariant Vpn other) {
    if (identical(this, other)) return true;
  
    return 
      other.hostname == hostname &&
      other.ip == ip &&
      other.ping == ping &&
      other.speed == speed &&
      other.countryLong == countryLong &&
      other.countryShort == countryShort &&
      other.imagePath == imagePath &&
      other.vpnConfigPath == vpnConfigPath;
  }

  @override
  int get hashCode {
    return hostname.hashCode ^
      ip.hashCode ^
      ping.hashCode ^
      speed.hashCode ^
      countryLong.hashCode ^
      countryShort.hashCode ^
      imagePath.hashCode ^
      vpnConfigPath.hashCode;
  }
}
