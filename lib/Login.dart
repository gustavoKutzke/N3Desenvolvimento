import 'package:flutter/material.dart';
import 'package:projetodese/Cadastro.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Home.dart';
import 'model/Usuario.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro = "";
  _validarCampos(){
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if(email.isNotEmpty && email.contains("@")){
      if(senha.isNotEmpty){

        setState(() {
          _mensagemErro = "";
        });
        Usuario usuario = Usuario();
        usuario.senha = senha;
        usuario.email = email;

        _logarUsuario(usuario);


      }else{
        setState(() {
          _mensagemErro = "Preencha a Senha!";
        });
      }
    }else{
      setState(() {
        _mensagemErro = "Preencha o Email Válido";
      });
    }
  }
  _logarUsuario(Usuario usuario){
    FirebaseAuth auth = FirebaseAuth.instance;

    auth.signInWithEmailAndPassword(email: usuario.email,
        password: usuario.senha). then((firebaseUser){

      Navigator.pushReplacementNamed(context,"/home");


    }).catchError((error){
      setState(() {
        _mensagemErro = "Erro ao autenticar usuário,Verifique e-mail e senha !";
      });
    });

  }

  Future _verificarUsuarioLogado()async{
    FirebaseAuth auth =FirebaseAuth.instance;

    //auth.signOut();
    User? usuarioLogado = await auth.currentUser;
    if(usuarioLogado !=null){
      Navigator.pushReplacementNamed(context,"/home");

    }
  }

  @override
  void initState() {
  _verificarUsuarioLogado();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(0xff075E54)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:<Widget>[
                Padding(padding: EdgeInsets.only(bottom: 32),
                ),
                Padding(padding: EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _controllerEmail,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding:EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "E-mail",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32)
                    )
                  ),
                ),
                ),
                TextField(
                  controller: _controllerSenha,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding:EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)
                      )
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 16,bottom: 10),
                child: ElevatedButton(
                  child: Text(
                    "Entrar",
                  style: TextStyle(color:Colors.white,fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16)
                  ),
                  onPressed:(){
                    _validarCampos();

                  },
                ),
                ),
                Center(
                  child: GestureDetector(
                    child: Text(
                      "Não tem Conta? cadastre-se!",
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder:(context)=>Cadastro()
                      )
                      );
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.only(top:16),
                  child: Center(
                    child:  Text(_mensagemErro,
                      style: TextStyle(color: Colors.red,
                          fontSize: 20
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
