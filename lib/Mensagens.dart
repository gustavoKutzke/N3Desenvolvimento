
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projetodese/model/Mensagem.dart';
import 'package:projetodese/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';


class Mensagens extends StatefulWidget {

  Usuario contato;

  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {


  File? _imagem;
  String _idUsuarioLogado="";
  String _idUsuarioDestinatario="";
  bool _subindoImagem = false;
  dynamic _urlImagemRecuperada;
  FirebaseFirestore db = FirebaseFirestore.instance;

  final _controller =StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  TextEditingController _controllerMensagem = TextEditingController();

  _enviarMensagem(){

    String textoMensagem = _controllerMensagem.text;
    if( textoMensagem.isNotEmpty ){

      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem  = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.data= Timestamp.now().toString();
      mensagem.tipo      = "texto";

      _salvarMensagem(_idUsuarioLogado!, _idUsuarioDestinatario!, mensagem);
      _salvarMensagem(_idUsuarioDestinatario!, _idUsuarioLogado!, mensagem);

    }

  }

  _salvarMensagem(String idRemetente, String idDestinatario, Mensagem msg) async {

    await db.collection("mensagens")
        .doc( idRemetente )
        .collection( idDestinatario )
        .add( msg.toMap() );

    //Limpa texto
    _controllerMensagem.clear();

  }


  _enviarFoto() async {
    ImagePicker Piker = ImagePicker();
    XFile? imagemSelecionada;

    imagemSelecionada = await Piker.pickImage(source: ImageSource.gallery);



    FirebaseStorage storage = await FirebaseStorage.instance;

    var file = File(imagemSelecionada!.path);
    _subindoImagem = true;
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz
        .child('mensagens')
        .child(_idUsuarioLogado)
        .child( nomeImagem + ".jpg" );

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

      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem  = "";
      mensagem.urlImagem = url;
      mensagem.data= Timestamp.now().toString();
      mensagem.tipo      = "imagem";

      _salvarMensagem(_idUsuarioLogado!, _idUsuarioDestinatario!, mensagem);
      _salvarMensagem(_idUsuarioDestinatario!, _idUsuarioLogado!, mensagem);

    }
    ////*
    task.then((TaskSnapshot snapshot){
      _recuperarUrlImagem( snapshot);
    });
  }


  _recuperarDadosUsuario()  {

    FirebaseAuth auth = FirebaseAuth.instance;
    var usuarioLogado = FirebaseAuth.instance.currentUser;
    _idUsuarioLogado = usuarioLogado!.uid;

    _idUsuarioDestinatario = widget.contato.idUsuario;
    _adicionarListenerMensagens();


  }

  Stream<QuerySnapshot>? _adicionarListenerMensagens(){
    final stream = db.collection("mensagens")
        .doc( _idUsuarioLogado )
        .collection( _idUsuarioDestinatario )
        .orderBy("data",descending: false)
        .snapshots();
    stream.listen((dados) {
      _controller.add(dados);
      Timer(Duration(seconds: 1),(){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }


  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {

    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite uma mensagem...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)
                    ),
                    prefixIcon: IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: _enviarFoto
                    )
                ),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Color(0xff075E54),
            child: Icon(Icons.send, color: Colors.white,),
            mini: true,
            onPressed: _enviarMensagem,
          )
        ],
      ),
    );

    var stream = StreamBuilder(
      stream:
          _controller.stream,
        builder: (context,snapshot){
        switch(snapshot.connectionState){
          case ConnectionState.none:
          case ConnectionState.waiting:
          return Center(
            child: Column(
              children: <Widget>[
                Text("Carregando  Mensagens"),
                CircularProgressIndicator()
              ],
            ),
          );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
              QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot<Object?>;
              if(snapshot.hasError){
                return Expanded(child: Text("Erro ao Carregar os dados!"),

                );
              }else{
                return Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                      itemCount: querySnapshot.docs.length,
                      itemBuilder: (context, indice){

                        List<DocumentSnapshot> mensagens = querySnapshot.docs.toList();
                        DocumentSnapshot item = mensagens[indice];

                        double larguraContainer = MediaQuery.of(context).size.width * 0.8;

                        Alignment alinhamento = Alignment.centerRight;
                        Color cor = Color(0xffd2ffa5);
                        if( _idUsuarioLogado != item["idUsuario"]){//par
                          alinhamento = Alignment.centerLeft;
                          cor = Colors.white;
                        }

                        return Align(
                          alignment: alinhamento,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Container(
                              width: larguraContainer,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: cor,
                                  borderRadius: BorderRadius.all(Radius.circular(8))
                              ),
                              child:
                              item["tipo"] == "texto"
                              ?Text(item["mensagem"], style: TextStyle(fontSize: 18),)
                                  :Image.network(item["urlImagem"]),
                            ),
                          ),
                        );

                      }
                  ),
                );
              }
            break;
          }
        },


    );


    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: widget.contato.urlImagem != null
                    ? NetworkImage(widget.contato.urlImagem)
                    : null),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(widget.contato.nome),
            )
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/bg.png"),
                fit: BoxFit.cover
            )
        ),
        child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  stream,
                  caixaMensagem,
                ],
              ),
            )
        ),
      ),
    );
  }
}


