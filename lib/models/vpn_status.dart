class VpnStatus {
  final String? byteIn;
  final String? byteOut;
  final String? duration;

  VpnStatus({this.byteIn, this.byteOut, this.duration});

  factory VpnStatus.fromJson(Map<String, dynamic> json) => VpnStatus(
        duration: json['duration'],
        byteIn: json['byte_in'],
        byteOut: json['byte_out'],
      );

  Map<String, dynamic> toJson() => {
        'duration': duration,
        'byte_in': byteIn,
        'byte_out': byteOut
      };
}
