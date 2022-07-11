import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'design.dart';
import 'layout.dart';
import 'pesquisa.dart';

class Editar extends StatelessWidget {

  DocumentSnapshot document;
  Editar(this.document);
  TextEditingController texto = TextEditingController();

  @override
  Widget build(BuildContext context) {
    texto.text = document["mensagem"];
    return Scaffold(
      appBar: Layout().appbarcombotaosimples(parasalvar, "Editar", "Salvar", context),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Layout().caixadetexto(3, null, TextInputType.multiline, texto, null,TextCapitalization.sentences,)
          ],
        ),
      ),
    );
  }
  void parasalvar(BuildContext context) {

    if (texto.text.isEmpty) {
      Layout().dialog1botao(context, "Erro ao editar", "Impossível deixar o recado vazio.\nCaso deseje deletar, na tela inicial, clique e segure.");
    } else {
      document.reference
          .update({'mensagem': texto.text}).then((value) {
        Layout().dialog1botao(context, "Salvo", "Pronto.");
      });
      Pesquisa().sendAnalyticsEvent(tela: Nomes().recadoEdit);
    }}

}


