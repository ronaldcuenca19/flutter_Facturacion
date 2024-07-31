import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practica4_flutter/views/principalView.dart';
import 'package:practica4_flutter/views/sessionView.dart';
import '../controls/Conexion.dart';

class EditarDatosPersona extends StatefulWidget {
  const EditarDatosPersona({super.key});

  @override
  _EditarDatosPersonaState createState() => _EditarDatosPersonaState();
}

class _EditarDatosPersonaState extends State<EditarDatosPersona> {
  Conexion c = Conexion();
  Map<String, dynamic> persona = {};
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDataProd('06da094d-9995-445b-bd62-129cf78c4e8c');
  }

  Future<void> editarUsuario() async {
    final nombres = _nombresController.text;
    final apellidos = _apellidosController.text;
    final edad = int.tryParse(_edadController.text);
    final cedula = int.tryParse(_cedulaController.text);

    if (cedula == null || cedula.toString().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cédula debe tener 10 dígitos')),
      );
      return;
    }

    if (edad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edad no válida')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${c.URL}persona/update/cliente'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombres': nombres,
          'apellidos': apellidos,
          'edad': edad.toString(),
          'cedula': cedula.toString(),
          'external_id':"06da094d-9995-445b-bd62-129cf78c4e8c"
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos actualizados correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar los datos: ${response.statusCode}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en la solicitud: $error')),
      );
    }
  }

  void _volver() {
    Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrincipalScreen()),
              );
    print('Nueva Sucursal');
  }

  void _CerrarSesion() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SessionView()),
    );
  }


  Future<void> fetchDataProd(String externalId) async {
    try {
      final response = await http.get(Uri.parse('${c.URL}persona/$externalId'));
      print('Respuesta del backend: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body)['datos'];
        setState(() {
          persona = data;
          _nombresController.text = data['nombre'];
          _apellidosController.text = data['apellido'];
          _edadController.text = data['edad'].toString();
          _cedulaController.text = data['cedula'].toString();
        });
      } else {
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (error) {
      print('Error en fetchDataProd: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Editar perfil",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 22),
        ),
        elevation: 10,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey,
        actions: [
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nombres:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                TextFormField(
                  controller: _nombresController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Escribe los nuevos nombres...',
                    hintStyle: TextStyle(color: Colors.blueGrey.withOpacity(0.5)),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Apellidos:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                TextFormField(
                  controller: _apellidosController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Escribe los nuevos apellidos...',
                    hintStyle: TextStyle(color: Colors.blueGrey.withOpacity(0.5)),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Edad:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                TextFormField(
                  controller: _edadController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Escribe la nueva edad...',
                    hintStyle: TextStyle(color: Colors.blueGrey.withOpacity(0.5)),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cédula:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                TextFormField(
                  controller: _cedulaController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Escribe la nueva cédula...',
                    hintStyle: TextStyle(color: Colors.blueGrey.withOpacity(0.5)),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: editarUsuario,
                  child: const Text('Editar Datos'),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text('Volver'),

            ),
          ),
        ],
      ),
    );
  }
}
