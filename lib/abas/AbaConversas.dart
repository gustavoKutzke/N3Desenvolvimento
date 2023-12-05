import 'package:flutter/material.dart';

import '../model/Conversa.dart';


class AbaConversas extends StatefulWidget {
  const AbaConversas({super.key});

  @override
  State<AbaConversas> createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {

  List<Conversa> listaConversa=[
    Conversa(
          "Ana",
        "Olá Tudo bem?",
        "https://firebasestorage.googleapis.com/v0/b/projetofluwat.appspot.com/o/perfil1.jpg?alt=media&token=c3569429-4f89-434f-b093-651ecc321833&_gl=1*1uierjv*_ga*MTI1ODIzNDYzMy4xNjg1OTEzODgz*_ga_CW55HF8NVT*MTY5ODI0MzUwNS44My4xLjE2OTgyNDUxNDMuNjAuMC4w"
        ),
    Conversa(
        "Gustavo",
        "Como está?",
        "https://firebasestorage.googleapis.com/v0/b/projetofluwat.appspot.com/o/perfil2.jpg?alt=media&token=3db1f8ec-8fcf-40b4-80ac-3c2cfc86c87e&_gl=1*1kxmoeg*_ga*MTI1ODIzNDYzMy4xNjg1OTEzODgz*_ga_CW55HF8NVT*MTY5ODI0MzUwNS44My4xLjE2OTgyNDUyMTkuNjAuMC4w"
    ),
    Conversa(
        "Joana",
        "Meu deus!!",
        "https://firebasestorage.googleapis.com/v0/b/projetofluwat.appspot.com/o/perfil3.jpg?alt=media&token=c13c74e1-667c-45df-9085-91b19b020ed5&_gl=1*1lgbdjp*_ga*MTI1ODIzNDYzMy4xNjg1OTEzODgz*_ga_CW55HF8NVT*MTY5ODI0MzUwNS44My4xLjE2OTgyNDUyMjEuNTguMC4w"
    ),
    Conversa(
        "Joao",
        "Prova Hoje",
        "https://firebasestorage.googleapis.com/v0/b/projetofluwat.appspot.com/o/perfil4.jpg?alt=media&token=7b7e67d7-acd4-4e04-a7a2-a1062a0c57e8&_gl=1*1av4hup*_ga*MTI1ODIzNDYzMy4xNjg1OTEzODgz*_ga_CW55HF8NVT*MTY5ODI0MzUwNS44My4xLjE2OTgyNDUyMjQuNTUuMC4w"
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listaConversa.length,
        itemBuilder:(context,indece){
        Conversa conversa = listaConversa[indece];
        return ListTile(
          contentPadding: EdgeInsets.fromLTRB(16, 8, 18, 8),
          leading: CircleAvatar(
            maxRadius: 30,
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(conversa.caminhoFoto),
          ),
          title: Text(
            conversa.nome,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16
            ),
          ),
          subtitle: Text(
            conversa.mensagem,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14
            ),
          ),
        );

        }
    );
  }
}
