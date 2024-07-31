import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:practica4_flutter/views/principalView.dart';
import '../controls/Conexion.dart';

class RegisterSucursalView extends StatefulWidget {
  const RegisterSucursalView({super.key});

  @override
  _RegisterSucursalViewState createState() => _RegisterSucursalViewState();
}

class _RegisterSucursalViewState extends State<RegisterSucursalView> {
  Conexion c = Conexion();
  final TextEditingController _nombreController = TextEditingController();
  LocationData? _currentLocation;
  LatLng _markerPosition = LatLng(0, 0);
  bool _locationFetched = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _volver() {
    Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrincipalScreen()),
              );
    print('Nueva Sucursal');
  }

  Future<void> _initializeLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData locationData = await location.getLocation();
    setState(() {
      _currentLocation = locationData;
      _markerPosition = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
      _locationFetched = true;
    });
  }

  Future<void> saveSucursal() async {
    final nombre = _nombreController.text;

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${c.URL}sucursal/save'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'latitud': _markerPosition.latitude.toString(),
          'longitud': _markerPosition.longitude.toString(),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sucursal guardada correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la sucursal: ${response.statusCode}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en la solicitud: $error')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Registrar Sucursal",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 22),
        ),
        elevation: 10,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nombre:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            TextFormField(
              controller: _nombreController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Escribe el nombre de la sucursal...',
                hintStyle: TextStyle(color: Colors.blueGrey.withOpacity(0.5)),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeLocation,
              child: const Text('Ubicación'),
            ),
            const SizedBox(height: 16),
            if (_locationFetched) 
              Column(
                children: [
                  SizedBox(
                    height: 400,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: _markerPosition,
                        zoom: 15,
                        onPositionChanged: (position, hasGesture) {
                          if (hasGesture) {
                            setState(() {
                              _markerPosition = position.center!;
                            });
                          }
                        },
                      ),
                      nonRotatedChildren: [
                        TileLayer(
                          urlTemplate:
                              'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                          additionalOptions: const {
                            'accessToken': 'pk.eyJ1IjoibHVpczE2OSIsImEiOiJjbHMyOWl2dW0wOWcwMnFuejFxc29wMG5iIn0.cxAolwZYn7HqhWoPFZK2mw',
                            'id': 'mapbox/streets-v12',
                          },
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _markerPosition,
                              builder: (context) => const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Latitud: ${_markerPosition.latitude}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        'Longitud: ${_markerPosition.longitude}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    ElevatedButton(
      onPressed: saveSucursal,
      child: const Text('Guardar Sucursal'),
    ),
    ElevatedButton.icon(
      onPressed: _volver,
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      label: const Text('Volver'),
    ),
  ],
),
          ],
        ),
      ),
    );
  }
}
