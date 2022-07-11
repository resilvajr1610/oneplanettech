import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'design.dart';
import 'layout.dart';
import 'pesquisa.dart';

class MensagemDetalhe extends StatefulWidget {
  DocumentSnapshot usuario;

  MensagemDetalhe(this.usuario);

  @override
  _MensagemDetalheState createState() => _MensagemDetalheState();
}

class _MensagemDetalheState extends State<MensagemDetalhe> {
  String receptor='', unidade='', palavrapesquisada='', curso='', turma='';
  List receptores = [];
  List<String> unidades = [];
  List<String> turmas = [];

  @override
  void initState() {
    super.initState();
    if (widget.usuario['unidade'] == 'Todas as unidades') {
      buscarunidades();
      receptor = "Todas";
    } else {
      unidade = widget.usuario['unidade'];
      if (widget.usuario['perfil'] == "Direção") {
        buscarreceptores(unidade);
        buscarturmas(widget.usuario['unidade'], null);
        receptor = "Todas";
      } else {
        receptores = List<String>.from(widget.usuario['visualizarChat']);
        if (receptores.length == 1) {
          receptor = receptores[0];
        }
      }
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().msgEscola);
  }

  void buscarreceptores(uni) {
    receptores.clear();
    receptores.add('Todas');
    FirebaseFirestore.instance
        .collection(Nomes().perfilbanco)
        .where('unidade', isEqualTo: uni)
        .where('chat', isEqualTo: true)
        .orderBy('perfil')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() {
          receptores.add(element['perfil']);
        });
      });
    });
  }

  void buscarunidades() {
    FirebaseFirestore.instance
        .collection(Nomes().unidadebanco)
        .orderBy("unidade")
        .get()
        .then((query) {
      query.docs.forEach((doc) {
        setState(() {
          unidades.add(doc['unidade']);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: AppBar(
        backgroundColor: Cores().corprincipal,
        title: Text("Mensagens"),
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    (unidades.isNotEmpty)
                        ? Expanded(
                            flex: 1,
                            child: Layout().dropdownitem('Selecione a unidade',
                                unidade, mudarUnidade, unidades),
                          )
                        : Container(),
                    (receptores != null && receptores.isNotEmpty)
                        ? Expanded(
                            flex: 1,
                            child: Layout().dropdownitem(
                                "Todas", receptor, mudarReceptores, receptores),
                          )
                        : Container(),
                  ],
                ),
                Layout().campopesquisa((text) {
                  setState(() {
                    palavrapesquisada = text;
                  });
                }),
                Expanded(child: carregarmensagens()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget carregarmensagens() {
    if (!widget.usuario['perfil'].contains('Professor')) {
     return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(Nomes().mensagensbanco)
              .where('unidade', isEqualTo: unidade)
              .where('para', isEqualTo: receptor)
              .orderBy("datacomparar", descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Text(
                  'Isto é um erro. Por gentileza, contate o suporte.');
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Container();
              default:
                return (snapshot.data!.docs.length >= 1)
                    ? ListView(
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          if ((receptor == null || receptor == "Todas") &&
                              (widget.usuario['curso'].contains('Todos') ||
                                  widget.usuario['curso']
                                      .contains(document['curso'])) &&
                              (widget.usuario['visualizarChat']
                                      .contains(document['tipo']) ||
                                  widget.usuario['perfil'] == 'Direção')) {
                            return showItemMensagem(document, context);
                          } else if (receptor != null &&
                              receptor != "Todas" &&
                              (widget.usuario['curso'].contains('Todos') ||
                                  widget.usuario['curso']
                                      .contains(document['curso']))) {
                            if (document['para'] == receptor) {
                              return showItemMensagem(document, context);
                            }
                            return Container();
                          } else if (document['para'] == receptor &&
                              (widget.usuario['curso'].contains('Todos') ||
                                  widget.usuario['curso']
                                      .contains(document['curso']))) {
                            return showItemMensagem(document, context);
                          } else {
                            return Container();
                          }
                        }).toList(),
                      )
                    : Container();
            }
          });
    } else if (widget.usuario['perfil'].contains('Professor')) {
      return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(Nomes().mensagensbanco)
              .where('professorid', isEqualTo: widget.usuario.id)
              .orderBy("datacomparar", descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Text(
                  'Isto é um erro. Por gentileza, contate o suporte.');
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Container();
              default:
                return (snapshot.data!.docs.length >= 1)
                    ? ListView(
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          if (receptor == "Todas") {
                            return showItemMensagem(document, context);
                          } else if (receptor != null &&
                              receptor != "Todas") {
                            if (document['para'] == receptor) {
                              return showItemMensagem(document, context);
                            }
                            return Container();
                          } else if (document['para'] == receptor) {
                            return showItemMensagem(document, context);
                          } else {
                            return Container();
                          }
                        }).toList(),
                      )
                    : Container();
            }
          });
    } else {
      return Container();
    }
  }

  Widget showItemMensagem(DocumentSnapshot document, BuildContext context) {
    return Layout().itemMensagemTela(
        document, widget.usuario, true, 'escola', context, null);
  }

  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
      receptor = '';
    });
    buscarreceptores(unidade);
  }

  mudarReceptores(String text) {
    setState(() {
      receptor = text;
    });
    if (List<String>.from(widget.usuario['turma'])[0] == 'Todas') {
      buscarturmas(unidade, curso);
    }
  }

  void mudarTurma(String text) {
    setState(() {
      turma = text;
    });
  }

  buscarturmas(uni, curs) {
    turmas.clear();
    FirebaseFirestore.instance
        .collection(Nomes().turmabanco)
        .where('unidade', isEqualTo: uni)
        .where('curso', isEqualTo: curs)
        .orderBy('turma')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() {
          turmas.add(element['turma']);
        });
      });
    });
  }
}
