class Service {
  final int id;
  final String name;
  final String description;

  Service({required this.id, required this.name, required this.description});

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };
}

class ServicesResponse {
  final List<Service> services;

  ServicesResponse({required this.services});

  factory ServicesResponse.fromJson(dynamic json) {
    if (json is List) {
      return ServicesResponse(
        services: json
            .map((e) => Service.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    if (json is Map<String, dynamic>) {
      final data = json['services'];
      if (data is List) {
        return ServicesResponse(
          services: data
              .map((e) => Service.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      return ServicesResponse(services: [Service.fromJson(json)]);
    }
    throw FormatException('Unexpected JSON format for ServicesResponse');
  }
}
