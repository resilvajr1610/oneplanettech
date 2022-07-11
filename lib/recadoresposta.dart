import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'design.dart';
import 'layout.dart';
import 'pesquisa.dart';


class RecadoResposta extends StatelessWidget {
  final DocumentSnapshot document, usuario;
  bool moderacao;
  TextEditingController cresposta = TextEditingController();
  RecadoResposta(this.document, this.usuario, this.moderacao);
  @override
  Widget build(BuildContext context) {
    cresposta.text = document['resposta'];
    return Scaffold(
        appBar: Layout().appbarcombotaosimples(
            parasalvar, "Responder Recado", "Salvar", context),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Layout().itemRecadoEscola(document, null, moderacao, usuario, context),
              Layout().caixadetexto(3, null, TextInputType.multiline, cresposta, "Escreva a resposta",TextCapitalization.sentences,)
            ],
          ),
        ));
  }

  void parasalvar(BuildContext context) {
    if (cresposta.text != null && cresposta.text.isNotEmpty) {
      Pesquisa().responderrecado(
          document, cresposta.text, moderacao, usuario, context);
      Pesquisa().sendAnalyticsEvent(tela: Nomes().respostaRecado);
    } else {
      Layout().dialog1botao(context, "Ups", "Escreva a resposta");
    }
  }
}
