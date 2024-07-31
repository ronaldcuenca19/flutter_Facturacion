import 'package:practica4_flutter/controls/utiles/Utiles.dart';
import 'servicio_back/RespuestaGenerica.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Conexion {
  final String URL = "http://127.0.0.1:5000/api/";
  final String URL_MEDIA = "http://127.0.0.1:5000/multimedia/";
  static bool NO_TOKEN = false;
  //news-token
  Future<RespuestaGenerica> solicitudGet(String recurso, bool token) async{
    Map<String, String> header = {'Content-Type':'application/json'};
    if(token){
      Utiles util = Utiles();
      String? tokenA = await util.getValue(token);
      header = {'Content-Type':'application/json', 'news-token': tokenA.toString()};
    }
    final String url = URL+recurso;
    final uri = Uri.parse(url);
    try{
      final response = await http.get(uri, headers: header);
      if(response.statusCode != 200){
        if(response.statusCode == 404){
          return _response(404, "Recurso no encontrado", []);
        }else{
          Map<dynamic, dynamic> mapa = jsonDecode(response.body);
          return _response(mapa['code'], mapa['msg'], mapa['datos']);
        }
        //log("Page no found");
      }else{
        Map<dynamic, dynamic> mapa = jsonDecode(response.body);
        return _response(mapa['code'], mapa['msg'], mapa['datos']);
        log(response.body);
      }
      //return RespuestaGenerica();
    }catch(e){
      return _response(500, "Error inesperado", []);
    }

  }

  Future<RespuestaGenerica> solicitudPost(String recurso, bool token, Map<dynamic, dynamic> mapa) async{
    Map<String, String> header = {'Content-Type':'application/json'};
    if(token){
      Utiles util = Utiles();
      String? tokenA = await util.getValue('token');
      header = {'Content-Type':'application/json', 'X-Access-Token': tokenA.toString()};
    }
    final String url = URL+recurso;
    final uri = Uri.parse(url);
    try{
      final response = await http.post(uri, headers: header, body: jsonEncode(mapa));
      if(response.statusCode != 200){
        if(response.statusCode == 404){
          return _response(404, "Recurso no encontrado", []);
        }else{
          Map<dynamic, dynamic> mapa = jsonDecode(response.body);
          return _response(mapa['code'], mapa['msg'], mapa['datos']);
        }
        //log("Page no found");
      }else{
        Map<dynamic, dynamic> mapa = jsonDecode(response.body);
        return _response(mapa['code'], mapa['msg'], mapa['datos']);
        log(response.body);
      }
      //return RespuestaGenerica();
    }catch(e){
      return _response(500, "Error inesperado", []);
    }

  }

  RespuestaGenerica _response(int code, String msg, dynamic data){
    var respuesta = RespuestaGenerica();
    respuesta.code = code;
    respuesta.datos = data;
    respuesta.msg = msg;
    return respuesta;
  }
}