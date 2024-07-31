import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

class MapaUnidadView extends StatelessWidget {
  final double latitud;
  final double longitud;
  final String nombreSucursal;
  final int caducados;

  MapaUnidadView({super.key, 
    required this.latitud,
    required this.longitud,
    required this.nombreSucursal,
    required this.caducados
  });

  final PopupController _popupController = PopupController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación de la Sucursal'),
        backgroundColor: Colors.blueGrey,
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(latitud, longitud),
          zoom: 15,
          onTap: (_, __) => _popupController.hideAllPopups(), // Hide popups when map is tapped
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
            additionalOptions: const {
              'accessToken': 'pk.eyJ1IjoibHVpczE2OSIsImEiOiJjbHMyOWl2dW0wOWcwMnFuejFxc29wMG5iIn0.cxAolwZYn7HqhWoPFZK2mw',
              'id': 'mapbox/streets-v12',
            },
          ),
          PopupMarkerLayerWidget(
            options: PopupMarkerLayerOptions(
              popupController: _popupController,
              markers: [
                Marker(
                  point: LatLng(latitud, longitud),
                  builder: (context) => const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
              popupBuilder: (context, marker) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Sucursal: $nombreSucursal\n Caducados: $caducados'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
