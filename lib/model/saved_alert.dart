class SavedAlert {
  final int id;
  final String alertName;
  final String timePeriod;
  final String purpose;
  final String propertyType;
  final DateTime createdAt;

  SavedAlert({
    required this.id,
    required this.alertName,
    required this.timePeriod,
    required this.purpose,
    required this.propertyType,
    required this.createdAt,
  });

  factory SavedAlert.fromJson(Map<String, dynamic> j) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      final s = v.toString();
      final d = DateTime.tryParse(s);
      return d ?? DateTime.now();
    }

    int parseInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse('${v ?? ''}') ?? 0;
    }

    String canonPurpose(String p) {
      var s = p.trim().toLowerCase().replaceAll(RegExp(r'[_\s-]+'), ' ');
      if (s.contains('rent')) return 'Rent';
      if (s.contains('buy') || s.contains('sale')) return 'Buy';
      if (s.contains('new')) return 'New Projects';
      if (s.contains('commercial')) return 'Commercial';
      return p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1);
    }

    String tidyType(String t) {
      final s = t.trim().toLowerCase();
      if (s.isEmpty || s == 'any') return '';
      if (s == 'apartments' || s == 'apartment') return 'Apartment';
      if (s == 'villas' || s == 'villa') return 'Villa';
      if (s == 'studios' || s == 'studio') return 'Studio';
      if (s == 'offices' || s == 'office') return 'Office';
      if (s == 'commercials' || s == 'commercial') return 'Commercial';
      return s.replaceAll(' ', '_');
    }

    final name = (j['alert_name'] ?? j['name'] ?? '').toString();
    final period = (j['time_period'] ?? j['frequency'] ?? '').toString();

    String rawPurpose = (j['purpose'] ?? '').toString();
    String typeFromPurpose = '';
    if (rawPurpose.contains('|')) {
      final parts = rawPurpose.split('|');
      rawPurpose = parts.isNotEmpty ? parts.first : rawPurpose;
      typeFromPurpose = parts.length > 1 ? parts[1] : '';
    }

    String propType =
        (j['property_type'] ?? j['propertyType'] ?? '').toString();
    if (propType.isEmpty && typeFromPurpose.isNotEmpty) {
      propType = tidyType(typeFromPurpose);
    } else {
      propType = tidyType(propType);
    }

    return SavedAlert(
      id: parseInt(j['id']),
      alertName: name,
      timePeriod: period,
      purpose: canonPurpose(rawPurpose),
      propertyType: propType,
      createdAt: parseDate(j['created_at'] ?? j['createdAt']),
    );
  }
}
