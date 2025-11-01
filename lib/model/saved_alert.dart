// class SavedAlert {
//   final int id;
//   final String alertName;   // backend: alert_name
//   final String timePeriod;  // backend: time_period
//   final String purpose;
//   final String propertyType;
//   final DateTime createdAt;
//
//   SavedAlert({
//     required this.id,
//     required this.alertName,
//     required this.timePeriod,
//     required this.purpose,
//     required this.propertyType,
//     required this.createdAt,
//   });
//
//   factory SavedAlert.fromJson(Map<String, dynamic> j) {
//     int toInt(v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;
//     DateTime toDate(v) => DateTime.tryParse('${v ?? ''}') ?? DateTime.now();
//
//     return SavedAlert(
//       id: toInt(j['id']),
//       alertName: (j['alert_name'] ?? j['name'] ?? '').toString(),
//       timePeriod: (j['time_period'] ?? j['frequency'] ?? '').toString(),
//       purpose: (j['purpose'] ?? '').toString(),
//       propertyType: (j['property_type'] ?? j['propertyType'] ?? '').toString(),
//       createdAt: toDate(j['created_at'] ?? j['createdAt']),
//     );
//   }
// }
