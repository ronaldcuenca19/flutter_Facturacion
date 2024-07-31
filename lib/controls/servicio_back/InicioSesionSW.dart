import 'package:practica4_flutter/controls/servicio_back/RespuestaGenerica.dart';

class InicioSesionSW extends RespuestaGenerica{
  String tag = '';
  InicioSesionSW({msg='', code=0, datos, this.tag= ''});
}