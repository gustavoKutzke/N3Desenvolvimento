import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class Configuracoes extends StatefulWidget {
  //const Configuracoes({Key? key}) : super(key: key);

  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {

  //Controles
  TextEditingController _controllerNome = TextEditingController();

  XFile? _imagem;
  bool _subindoImagem = false;
  dynamic _idUsuarioLogado;
  dynamic _urlImagemRecuperada;


  Future<dynamic> _recuperarImagem (String origemImagem) async {

    ImagePicker Piker = ImagePicker();

    XFile? imagemSelecionada;


    switch ( origemImagem ){

      case "camera" :
        imagemSelecionada = await Piker.pickImage(source: ImageSource.camera);
        break;

      case "galeria" :
        imagemSelecionada = await Piker.pickImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      _imagem = imagemSelecionada;
      if( _imagem != null){
        _subindoImagem = true;
        _uploadImagem();
      }
    });

  }

  Future<dynamic> _uploadImagem( ) async {

    FirebaseStorage storage = await FirebaseStorage.instance;

    var file = File(_imagem!.path);

    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz
        .child('perfil')
        .child( "${_idUsuarioLogado}" + ".jpg" );

    //upload da imagem
    UploadTask task = arquivo.putFile(file);

    //controlar progresso do upload
    task.snapshotEvents.listen(( TaskSnapshot storageEvent ) {

      if ( storageEvent.state == TaskState.running){

        setState(() {
          _subindoImagem = true;
        });

      }else if( storageEvent.state == TaskState.success){

        setState(() {
          _subindoImagem = false;
        });

      }
    });

    //Recuperar url da Imagem
    Future<dynamic> _recuperarUrlImagem (TaskSnapshot snapshot) async {

      String url = await snapshot.ref.getDownloadURL();
      //print("Resultado  url  " + url);

      //recuperar imagem do banco firebaseFIRESTORE da função _atualizarUrlImagemFirestore
      _atualizarUrlImagemFirestore( url );


      setState(() {
        _urlImagemRecuperada = url;
      });
    }
    ////*
    task.then((TaskSnapshot snapshot){
      _recuperarUrlImagem( snapshot);
    });
  }

  Future<dynamic> _atualizarUrlImagemFirestore(dynamic url) async {

//------------Salvar a URL da Imagem no FirebaseFIRESTORE-----------------------
    FirebaseFirestore db = await FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      "urlImagem" : url
    };

    await db.collection("Usuarios")
        .doc(_idUsuarioLogado)
        .update( dadosAtualizar);
//------------------------------------------------------------------------------
  }

  Future<dynamic> _atualizarNomeFirestore() async {

    String nome =_controllerNome.text;
    FirebaseFirestore db = await FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      "nome" : nome
    };

    await db.collection("Usuarios")
        .doc(_idUsuarioLogado)
        .update( dadosAtualizar);
//------------------------------------------------------------------------------
  }

  Future<dynamic> _recuperarDadosUsuario ( dynamic User) async {
    FirebaseAuth auth = await FirebaseAuth.instance;
    User = await auth.currentUser?.uid;


    dynamic usuarioLogado = User;
    _idUsuarioLogado = usuarioLogado;


//-----------Recuperando dados do usuario do FIRESTORE -----------------------
    FirebaseFirestore db = await FirebaseFirestore.instance;

    DocumentSnapshot snapshot = await db.collection("Usuarios")
        .doc(_idUsuarioLogado!)
        .get();

    dynamic dados = await snapshot.data();

    _controllerNome.text = dados["nome"];

    if( dados["urlImagem"] != null ) {
      setState(() {
        _urlImagemRecuperada = dados["urlImagem"];
        _controllerNome.text = dados["nome"];
      });
    }
  }
//------------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario(User);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text("Configurações"),),

      body: Container(
        padding: EdgeInsets.all(16),

        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [

                //carregando
                _subindoImagem == true
                    ? CircularProgressIndicator()
                    : Container(),
                CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                    _urlImagemRecuperada != null
                        ? NetworkImage(_urlImagemRecuperada!)
                        :null
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    ElevatedButton(
                      onPressed: (){
                        _recuperarImagem("camera");
                      },
                      child: Text("Câmera",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff075e54),),
                    ),

                    ElevatedButton(
                      onPressed: (){
                        _recuperarImagem("galeria");
                      },
                      child: Text("Galeria",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff075e54),),
                    )
                  ],
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 8),

                  child: TextField(
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Nome",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        )),
                  ),),

                Padding(padding: EdgeInsets.only(top: 16, bottom: 10),

                  child: ElevatedButton(
                    onPressed: () {
                      _atualizarNomeFirestore();
                    },
                    child: Text(
                      "Salvar",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        shadowColor: Colors.black54,
                        elevation: 15,
                        padding: const EdgeInsets.fromLTRB(30, 16, 30, 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        )),
                  ),),
              ],

            ),
          ),
        ),

      ),
    );
  }
}
