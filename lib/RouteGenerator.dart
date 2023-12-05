import 'package:flutter/material.dart';
import 'package:projetodese/Configuracoes.dart';
import 'package:projetodese/Login.dart';
import 'package:projetodese/Mensagens.dart';
import 'Cadastro.dart';
import 'Home.dart';

class RouteGenerator{
  static var args;
  static Route<dynamic>? generateRoute(RouteSettings settings){

    args = settings.arguments;

    switch(settings.name){
      case "/":
        return MaterialPageRoute(builder: (_)=>Login());
      case"/login":
        return MaterialPageRoute(builder: (_)=>Login() );
      case"/cadastro":
        return MaterialPageRoute(builder: (_)=>Cadastro() );
      case"/home":
        return MaterialPageRoute(builder: (_)=>Home() );
      case"/configuracoes":
        return MaterialPageRoute(builder: (_)=>Configuracoes());
      case"/mensagens":
        return MaterialPageRoute(builder: (_)=>Mensagens(args));
      default:
        _errorRota();
    }
    return generateRoute(settings);

  }
  static Route<dynamic> _errorRota(){
    return MaterialPageRoute(
        builder:(_){
          return Scaffold(
            appBar: AppBar(title: Text("Tela não Encontrada"),),
            body: Center(
              child: Text("Tela não Encontrada"),
            ),
          );
        }
    );
  }

}