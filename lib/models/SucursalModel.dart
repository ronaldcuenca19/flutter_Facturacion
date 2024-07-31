class SucursalModel {
  final String nombre;
  final String latitud;
  final String longitud;
  final String id;
  final String external_id;

  SucursalModel({
    required this.id,
    required this.nombre,
    required this.longitud,
    required this.latitud,
    required this.external_id,
  });

  factory SucursalModel.fromJson(Map<String, dynamic> json) {
    return SucursalModel(
      nombre: json['nombre'] ?? '',
      longitud: json['longitud'] ?? '',
      latitud: json['latitud'] ?? '',
      id: json['id'] ?? '',
      external_id: json['external_id'] ?? ''
    );
  }
}
