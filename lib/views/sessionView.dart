import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:practica4_flutter/controls/servicio_back/FacadeService.dart';
import 'package:practica4_flutter/controls/utiles/Utiles.dart';
import 'package:practica4_flutter/views/principalView.dart';
import 'package:validators/validators.dart';

class SessionView extends StatefulWidget {
  const SessionView({super.key});

  @override
  _SessionViewState createState() => _SessionViewState();
}

class _SessionViewState extends State<SessionView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController correoControl = TextEditingController();
  final TextEditingController claveControl = TextEditingController();

  void _iniciar() {
  if (_formKey.currentState!.validate()) {
    FacadeService servicio = FacadeService();
    Map<String, String> mapa = {
      "correo": correoControl.text,
      "clave": claveControl.text
    };

    servicio.inicioSesion(mapa).then((value) async {
      try {
        if (value.code == 200) {
          Utiles util = Utiles();
          util.saveValue('token', value.datos['token']);
          util.saveValue('user', value.datos['user']);
          util.saveValue('external', value.datos['external']);
          final SnackBar msg = SnackBar(content: Text('BIENVENIDO'));
          ScaffoldMessenger.of(context).showSnackBar(msg);
          Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrincipalScreen()),
              );
        } else {
          final SnackBar msg = SnackBar(content: Text('Error: ${value.tag}'));
          ScaffoldMessenger.of(context).showSnackBar(msg);
        }
      } catch (e, stackTrace) {
        log("Excepción: $e");
        log("Stack Trace: $stackTrace");
        final SnackBar msg = SnackBar(content: Text('Error inesperado: $e'));
        ScaffoldMessenger.of(context).showSnackBar(msg);
      }
    }).catchError((error) {
      log("Error de red: $error");
      final SnackBar msg = SnackBar(content: Text('Error de red: $error'));
      ScaffoldMessenger.of(context).showSnackBar(msg);
    });
  } else {
    log("Errores en la validación del formulario");
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco para la pantalla
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: const Text(
                "Tienda KILA",
                style: TextStyle(
                  color: Colors.blueGrey, // Texto en negro
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text(
                "App de Productos",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black, // Texto en negro
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text(
                "Inicio de sesión",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black, // Texto en negro
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Correo:',
                  suffixIcon: const Icon(Icons.alternate_email, color: Colors.black),
                  labelStyle: const TextStyle(color: Colors.black),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200], // Fondo gris claro para el campo
                ),
                controller: correoControl,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Debe ingresar un correo";
                  }
                  if (!isEmail(value!)) {
                    return "Correo inválido";
                  }
                  return null;
                },
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Clave:',
                  suffixIcon: const Icon(Icons.key, color: Colors.black),
                  labelStyle: const TextStyle(color: Colors.black),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200], // Fondo gris claro para el campo
                ),
                controller: claveControl,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Debe ingresar una clave";
                  }
                  return null;
                },
                obscureText: true,
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.teal), // Fondo negro para el botón
                  foregroundColor: WidgetStateProperty.all(Colors.white), // Texto blanco para el botón
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                ),
                onPressed: _iniciar,
                child: const Text("Iniciar sesión"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
