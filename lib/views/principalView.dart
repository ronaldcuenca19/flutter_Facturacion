import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practica4_flutter/models/SucursalModel.dart';
import 'package:practica4_flutter/views/EditarDatosPersona.dart';
import 'package:practica4_flutter/views/mapaSucursalView.dart';
import 'package:practica4_flutter/views/registerSucursalView.dart';
import 'package:practica4_flutter/views/mapaUnidadView.dart'; // Asegúrate de importar el nuevo archivo
import 'package:practica4_flutter/views/sessionView.dart';
import '../controls/Conexion.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  _PrincipalScreenState createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  Conexion c = Conexion();
  List<SucursalModel> sucursal = [];
  List<Map<String, dynamic>> productos = [];
  List<Map<String, dynamic>> loteProductos = [];
  int? selectedCardIndex;
  bool showProductosTable = false;
  bool showLoteTable = false;
  int contCaduc = 0; // Contador de "Caducado"

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('${c.URL}sucursal'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['datos'];
        setState(() {
          sucursal = data.map((item) => SucursalModel.fromJson(item)).toList();
        });
      } else {
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (error) {
      print('Error en fetchData: $error');
    }
  }

  Future<void> fetchDataLoteProd() async {
    try {
      final response =
          await http.get(Uri.parse('${c.URL}lote_producto/escogido'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['datos'];
        setState(() {
          loteProductos = data
              .map((item) => {
                    'producto': item['producto'],
                    'cantidad': item['cantidad'],
                    'external_id': item['external_id'],
                  })
              .toList();
        });
      } else {
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (error) {
      print('Error en fetchDataLoteProd: $error');
    }
  }

  Future<void> fetchDataProd(String externalId) async {
  try {
    final response =
        await http.get(Uri.parse('${c.URL}sucursal/$externalId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['datos'];
      int caducadoCount = 0;

      // Contar productos con estado "Caducado"
      for (var item in data) {
        if (item['estado'] == 'Caducado') {
          caducadoCount++;
        }
      }

      // Actualizar el estado del widget
      setState(() {
        productos = data
            .map((item) => {
                  'nombre': item['nombre'],
                  'estado': item['estado'],
                  'precio': item['precio']
                })
            .toList();
        contCaduc = caducadoCount; // Actualizar el contador de "Caducado"
      });
    } else {
      print('Error en la solicitud: ${response.statusCode}');
    }
  } catch (error) {
    print('Error en fetchDataProd: $error');
  }
}


  Future<void> saveData(String idLoteProducto, String idSucursal) async {
    try {
      final response = await http.post(
        Uri.parse('${c.URL}lote_sucursal/save'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
            {'id_lote_producto': idLoteProducto, 'id_sucursal': idSucursal}),
      );
      if (response.statusCode == 200) {
        print('Datos guardados correctamente');
      } else {
        print('Error al guardar los datos: ${response.statusCode}');
      }
    } catch (error) {
      print('Error en saveData: $error');
    }
  }

  void _editUser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditarDatosPersona()),
    );
  }

  void _CerrarSesion() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SessionView()),
    );
  }

  void _newSucursal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterSucursalView()),
    );
  }

  void _ubicaciones() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapaSucursalView()),
    );
  }

  void _viewLocation(String latitud, String longitud, String suc, int contCaduc) {
    double lat = double.tryParse(latitud) ?? 0.0;
    double lon = double.tryParse(longitud) ?? 0.0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapaUnidadView(
          latitud: lat,
          longitud: lon,
          nombreSucursal: suc,
          caducados: contCaduc, // Pasar el contador de "Caducado"
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              "SUCURSALES:",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: _ubicaciones,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Ubicaciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        elevation: 10,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey,
        actions: [
          Tooltip(
            message: 'Editar Perfil',
            child: IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.white,
              onPressed: _editUser,
            ),
          ),
          TextButton(
            onPressed: _CerrarSesion,
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: sucursal.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: sucursal.length,
              itemBuilder: (BuildContext context, int index) {
                final sucursals = sucursal[index];
                return Column(
                  children: [
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(sucursals.nombre),
                            trailing: IconButton(
                              icon: const Icon(Icons.location_on),
                              onPressed: () {
                                _viewLocation(
                                    sucursals.latitud, sucursals.longitud, sucursals.nombre, contCaduc);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (selectedCardIndex == index &&
                                          showLoteTable) {
                                        selectedCardIndex = null;
                                        loteProductos.clear();
                                        showLoteTable = false;
                                      } else {
                                        selectedCardIndex = index;
                                        showProductosTable = false;
                                        showLoteTable = true;
                                        fetchDataLoteProd();
                                      }
                                    });
                                  },
                                  child: const Text('Mostrar Lote de Productos'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (selectedCardIndex == index &&
                                          showProductosTable) {
                                        selectedCardIndex = null;
                                        productos.clear();
                                        showProductosTable = false;
                                      } else {
                                        selectedCardIndex = index;
                                        showLoteTable = false;
                                        showProductosTable = true;
                                        fetchDataProd(sucursals.external_id);
                                      }
                                    });
                                  },
                                  child: const Text('Mostrar Productos'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _viewLocation(
                                        sucursals.latitud, sucursals.longitud, sucursals.nombre, contCaduc);
                                  },
                                  child: const Text('Ver Ubicación'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selectedCardIndex == index && showLoteTable)
  Column(
    children: [
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Lote de Productos',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      DataTable(
        columns: const [
          DataColumn(label: Text('Producto')),
          DataColumn(label: Text('Cantidad')),
          DataColumn(label: Text('Acción')), // Nueva columna para el botón
        ],
        rows: loteProductos
            .map(
              (item) => DataRow(
                cells: [
                  DataCell(Text(item['producto'])),
                  DataCell(Text(item['cantidad'].toString())),
                  DataCell(
                    ElevatedButton(
                      onPressed: () {
                        saveData(item['external_id'], sucursals.external_id);
                      },
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    ],
  ),

                    if (selectedCardIndex == index && showProductosTable)
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Productos',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataTable(
                            columns: const [
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Estado')),
                              DataColumn(label: Text('Precio')),
                            ],
                            rows: productos
                                .map(
                                  (item) => DataRow(
                                    cells: [
                                      DataCell(Text(item['nombre'])),
                                      DataCell(Text(item['estado'])),
                                      DataCell(Text(item['precio'].toString())),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
        onPressed: _newSucursal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
