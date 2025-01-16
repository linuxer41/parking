import 'dart:convert';

class AppConfiguration {
  final String apiBaseUrl;
  final String apiKey;

  AppConfiguration({required this.apiBaseUrl, required this.apiKey});

  factory AppConfiguration.fromJson(Map<String, dynamic> json) {
    return AppConfiguration(
      apiBaseUrl: json['apiBaseUrl'],
      apiKey: json['apiKey'],
    );
  }

  Map<String, dynamic> toJson() => {
        'apiBaseUrl': apiBaseUrl,
        'apiKey': apiKey,
      };
}
