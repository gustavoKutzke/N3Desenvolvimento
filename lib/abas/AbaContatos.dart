import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Mensagens.dart';
import '../model/Usuario.dart';

class AbaContatos extends StatefulWidget {
  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {
  String? _idUsuarioLogado;
  String? _emailUsuarioLogado;

  Future<List<Usuario>> _recuperarContatos() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection("Usuarios").get();
    List<Usuario> listaUsuarios = [];
    for (DocumentSnapshot item in querySnapshot.docs) {
      var dados = item.data() as Map<String, dynamic>;
      if (dados["email"] == _emailUsuarioLogado) continue;

      Usuario usuario = Usuario();
      usuario.idUsuario = item.id;
      usuario.email = dados["email"] ?? "";
      usuario.nome = dados["nome"] ?? "";
      usuario.urlImagem = dados["urlImagem"] ?? "";
      listaUsuarios.add(usuario);
    }
    return listaUsuarios;
  }

  _recuperarDadosUsuario() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    var usuarioLogado = await FirebaseAuth.instance.currentUser;
    _idUsuarioLogado = usuarioLogado?.uid;
    _emailUsuarioLogado = usuarioLogado?.email;
  }

  @override
  void initState() {
    _recuperarDadosUsuario();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
        future: _recuperarContatos(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: <Widget>[
                    Text("Carregando contatos"),
                    CircularProgressIndicator()
                  ],
                ),
              );

            case ConnectionState.active:
            case ConnectionState.done:
              return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, indice) {
                    List<Usuario>? listaItens = snapshot.data;
                    Usuario usuario = listaItens![indice];
                    return ListTile(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Mensagens(usuario),
                            ));
                      },
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      leading: CircleAvatar(
                          maxRadius: 30,
                          backgroundColor: Colors.grey,
                          backgroundImage: usuario.urlImagem != null
                              ? NetworkImage(usuario.urlImagem)
                              : null),
                      title: Text(
                        usuario.nome,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    );
                  });
          }
        });
  }
}
