import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'design.dart';
import 'layout.dart';
import 'pesquisa.dart';

class ResponderEnquete extends StatelessWidget {
  late DocumentSnapshot document, usuario, aluno;
  late bool alterar;
  TextEditingController cresposta = TextEditingController();

  ResponderEnquete(DocumentSnapshot<Object?> document, usuario, DocumentSnapshot<Object?> aluno);

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collection(Nomes().respostasenquetes)
        .doc(document.id + usuario.id)
        .get()
        .then((resposta) {
      if (resposta.exists) {
        alterar = true;
        cresposta.text = resposta['resposta'];
      } else {
        alterar = false;
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Cores().corprincipal,
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              if (cresposta.text.toString().isEmpty) {
                Layout().dialog1botao(context, "Resposta",
                    "É necessário escrever a resposta primeiro.");
              } else {
                Pesquisa().salvarrespostaenquete(alterar, usuario, aluno,  document,
                    cresposta.text, context);
              }
            },
            child: Text(
              "Salvar",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
            ),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
        title: Text("Responder"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Layout().itemEnqueteresposta(document, context),
            Text(
              "Sua Resposta: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Layout().caixadetexto(3, null, TextInputType.multiline ,cresposta, "Escreva sua resposta",TextCapitalization.sentences,)
          ],
        ),
      ),
    );
  }
}


