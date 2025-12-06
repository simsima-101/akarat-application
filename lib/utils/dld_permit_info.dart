class DldPermitInfo {
  final String? propertySize;   // e.g., "1,234.56"
  final String? plotSize;       // e.g., "5,000"
  final String? permitNumber;

  DldPermitInfo({
    this.propertySize,
    this.plotSize,
    this.permitNumber,
  });

  factory DldPermitInfo.fromJson(Map<String, dynamic> json) {
    return DldPermitInfo(
      propertySize: json['property_size']?.toString(),
      plotSize: json['plot_size']?.toString(),
      permitNumber: json['permit_number']?.toString(),
    );
  }
}