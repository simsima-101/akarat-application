// lib/src/features/property/data/models/toggle_model.dart

import 'property_model.dart'; // ← Import the unified Property model

class ToggleModel {
  bool? success;
  String? message;
  bool? saved;
  Property? property; // ← Now uses the unified Property from property_model.dart

  ToggleModel({this.success, this.message, this.saved, this.property});

  factory ToggleModel.fromJson(Map<String, dynamic> json) {
    return ToggleModel(
      success: json['success'],
      message: json['message'],
      saved: json['saved'],
      property: json['property'] != null
          ? Property.fromJson(json['property'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['saved'] = saved;
    if (property != null) {
      data['property'] = property!.toJson();
    }
    return data;
  }
}