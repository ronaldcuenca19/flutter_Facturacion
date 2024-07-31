import 'package:flutter/material.dart';
import 'package:practica4_flutter/views/EditarDatosPersona.dart';
import 'package:practica4_flutter/views/exception/Page404View.dart';
import 'package:practica4_flutter/views/principalView.dart';
import 'package:practica4_flutter/views/sessionView.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.white).copyWith(surface: const Color.fromARGB(255, 255, 255, 255)),
      ),
      home: const SessionView(),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const SessionView(),
        '/principal': (context) => const PrincipalScreen(),
        '/editarPersona': (context) => const EditarDatosPersona(),
      },
      onGenerateRoute: (settings){
        return MaterialPageRoute(builder: (context) => const Page404View());
      },
    );
  }
}
