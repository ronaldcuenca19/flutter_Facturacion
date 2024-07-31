import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:practica4_flutter/controls/Conexion.dart';

class MapaSucursalView extends StatefulWidget {
  const MapaSucursalView({super.key});

  @override
  _MapaSucursalViewState createState() => _MapaSucursalViewState();
}

class _MapaSucursalViewState extends State<MapaSucursalView> {
  Conexion c = Conexion();
  List<dynamic> sucursales = [];
  List<Marker> markers = [];
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();

  @override
  void initState() {
    super.initState();
    fetchSucursales();
  }

  Future<void> fetchSucursales() async {
    try {
      final response = await http.get(Uri.parse('${c.URL}/sucursal'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['datos'];
        List<Marker> validMarkers = [];

        for (var sucursal in data) {
          try {
            double lat = double.parse(sucursal['latitud']);
            double lon = double.parse(sucursal['longitud']);

            if (_isValidCoordinate(lat, lon)) {
              validMarkers.add(Marker(
                point: LatLng(lat, lon),
                width: 40,
                height: 40,
                builder: (ctx) => const Icon(Icons.location_on, color: Colors.red, size: 40),
              ));
            } else {
              print('Coordenadas inválidas para sucursal: ${sucursal['nombre']}');
            }
          } catch (e) {
            print('Error al parsear coordenadas para sucursal ${sucursal['nombre']}: $e');
          }
        }

        if (validMarkers.isNotEmpty) {
          setState(() {
            sucursales = data;
            markers = validMarkers;

            // Ajusta el mapa para mostrar todos los marcadores
            final bounds = validMarkers.map((marker) => marker.point).toList();
            final boundsLatLngBounds = LatLngBounds.fromPoints(bounds);
            _mapController.fitBounds(
              boundsLatLngBounds,
              options: const FitBoundsOptions(padding: EdgeInsets.all(20)),
            );
          });
        }
      } else {
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (error) {
      print('Error en fetchSucursales: $error');
    }
  }

  bool _isValidCoordinate(double latitude, double longitude) {
    // Verifica que las coordenadas están dentro de rangos válidos
    return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Sucursales'),
        backgroundColor: Colors.blueGrey,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(0, 0), // Coordenadas neutrales
          zoom: 1, // Zoom inicial para mostrar todo el mapa
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
            additionalOptions: const {
              'accessToken': 'pk.eyJ1IjoibHVpczE2OSIsImEiOiJjbHMyOWl2dW0wOWcwMnFuejFxc29wMG5iIn0.cxAolwZYn7HqhWoPFZK2mw',
              'id': 'mapbox/streets-v12',
            },
          ),
          PopupMarkerLayerWidget(
            options: PopupMarkerLayerOptions(
              popupController: _popupController,
              markers: markers,
              popupBuilder: (context, marker) {
                final sucursal = sucursales.firstWhere(
                  (s) {
                    final lat = double.tryParse(s['latitud']);
                    final lon = double.tryParse(s['longitud']);
                    return lat != null && lon != null && LatLng(lat, lon) == marker.point;
                  },
                  orElse: () => null,
                );
                final nombreSucursal = sucursal?['nombre'] ?? 'Nombre no disponible';
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(nombreSucursal),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
