import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'design.dart';
import 'layout.dart';
import 'mensagem.dart';
import 'pesquisa.dart';

class MensagemWeb extends StatefulWidget {
  DocumentSnapshot usuario;
  bool controle;

  MensagemWeb(this.usuario, this.controle);

  @override
  _MensagemWebState createState() => _MensagemWebState();
}

class _MensagemWebState extends State<MensagemWeb> {
  String receptor='', unidade='', palavrapesquisada='';
  List receptores = [];
  List<String> unidades = [];
  String para='', alunoid='', paiuser='';
  late bool controle;
  late DocumentSnapshot professor;

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
        receptor = "Todas";
      } else {
        receptores = List<String>.from(widget.usuario['visualizarChat']);
        if (receptores.length == 1) {
          receptor = receptores[0];
        }
      }
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().mensagemWeb);
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
      backgroundColor: Cores().corfundomaisclaro,
      appBar: AppBar(
        backgroundColor: Cores().corprincipal,
        title: Text("Mensagens"),
      ),
      body: Row(
        children: [
          Flexible(flex: 2, child: InkWell(child: listamensagem())),
          Expanded(
              flex: 3,
              child: (para != null)
                  ? Mensagem(
                      para,
                      widget.usuario,
                      alunoid,
                      paiuser,
                      widget.controle,
                      professor: professor,
                    )
                  : Container()),
        ],
      ),
    );
  }

  Widget listamensagem() {
    return Column(
      children: <Widget>[
        Row(
          children: [
            (unidades.length > 0)
                ? Expanded(
                    flex: 1,
                    child: Layout().dropdownitem(
                        'Selecione a unidade', unidade, mudarUnidade, unidades),
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
        (!widget.usuario['perfil'].contains('Professor'))
            ? Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(Nomes().mensagensbanco)
                        .where('unidade', isEqualTo: unidade)
                        .where('para', isEqualTo: receptor)
                        .orderBy("datacomparar", descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                    if ((receptor == null ||
                                            receptor == "Todas") &&
                                        (widget.usuario['curso']
                                                .contains('Todos') ||
                                            widget.usuario['curso']
                                                .contains(document['curso'])) &&
                                        (widget.usuario['visualizarChat']
                                                .contains(document['tipo']) ||
                                            widget.usuario['perfil'] ==
                                                'Direção')) {
                                      return showItemMensagem(
                                          document, context);
                                    } else if (receptor != null &&
                                        receptor != "Todas" &&
                                        (widget.usuario['curso']
                                                .contains('Todos') ||
                                            widget.usuario['curso']
                                                .contains(document['curso']))) {
                                      if (document['para'] == receptor) {
                                        return showItemMensagem(
                                            document, context);
                                      }
                                      return Container();
                                    } else if (document['para'] == receptor &&
                                        (widget.usuario['curso']
                                                .contains('Todos') ||
                                            widget.usuario['curso']
                                                .contains(document['curso']))) {
                                      return showItemMensagem(
                                          document, context);
                                    } else {
                                      return Container();
                                    }
                                  }).toList(),
                                )
                              : Container();
                      }
                    }),
              )
            : Container(),
        (widget.usuario['perfil'].contains('Professor'))
            ? Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(Nomes().mensagensbanco)
                        .where('professorid',
                            isEqualTo: widget.usuario.id)
                        .orderBy("datacomparar", descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                      return showItemMensagem(
                                          document, context);
                                    } else if (receptor != null &&
                                        receptor != "Todas") {
                                      if (document['para'] == receptor) {
                                        return showItemMensagem(
                                            document, context);
                                      }
                                      return Container();
                                    } else if (document['para'] == receptor) {
                                      return showItemMensagem(
                                          document, context);
                                    } else {
                                      return Container();
                                    }
                                  }).toList(),
                                )
                              : Container();
                      }
                    }),
              )
            : Container()
      ],
    );
  }

  Widget showItemMensagem(DocumentSnapshot document, BuildContext context) {
    return itemMensagemTela(
        document, widget.usuario, true, 'escola', context, palavrapesquisada);
  }

  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
      receptor = '';
      para = '';
    });
    buscarreceptores(unidade);
  }

  mudarReceptores(String text) {
    setState(() {
      receptor = text;
      para = '';
    });
  }

  Widget itemMensagemTela(DocumentSnapshot document, user, controle, tipo,
      context, palavrapesquisada) {
    return (palavrapesquisada == null ||
            document['nome']
                .toString()
                .toLowerCase()
                .contains(palavrapesquisada.toString().toLowerCase()) ||
            document['alunonome']
                .toString()
                .toLowerCase()
                .contains(palavrapesquisada.toString().toLowerCase()))
        ? Card(
            elevation: 1.0,
            child: InkWell(
              onTap: () {
                if (document['para'] == 'Professor') {
                  FirebaseFirestore.instance
                      .collection(Nomes().usersbanco)
                      .doc(document['professorid'])
                      .get()
                      .then((value) {
                    setState(() {
                      para = document['para'];
                      alunoid = document['aluno'];
                      paiuser = document['origem'];
                      professor = value;
                    });
                  });
                } else {
                  setState(() {
                    professor = '' as DocumentSnapshot<Object?>;
                    para = document['para'];
                    alunoid = document['aluno'];
                    paiuser = document['origem'];
                  });
                }
              },
              onLongPress: () {
                return Layout().marcarcomolida(document, context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Text(
                          document['para'],
                          style: TextStyle(
                              color: Cores().corprincipal,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                              fontSize: 17.0),
                        ),
                        Spacer(),
                        Text(
                          document['data'],
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          child: Column(
                            children: <Widget>[
                              (document['parentesco'] != null)
                                  ? Text(
                                      document['parentesco'],
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  : Container(),
                              (document['logo'] != null)
                                  ? Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  document['logo']),
                                              fit: BoxFit.cover)),
                                    )
                                  : Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  "images/picture.png"),
                                              fit: BoxFit.cover)),
                                    ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 12,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  document['nome'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                (document['nome'] != document['alunonome'])
                                    ? Text(
                                        document['alunonome'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      )
                                    : Container(),
                                (document['curso'] != null &&
                                        document['turma'] != null)
                                    ? Text(
                                        document['unidade'] +
                                            ' - ' +
                                            document['curso'] +
                                            ' - ' +
                                            document['turma'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black),
                                      )
                                    : Container(),
                                Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      document['mensagem'],
                                      style: TextStyle(color: Colors.grey),
                                    )),
                                ((tipo == 'escola' &&
                                            document['nova'] == 'escola') ||
                                        (tipo == 'pais' &&
                                            document['nova'] == 'pais'))
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.add_alert,
                                            color: Colors.red,
                                            size: 25.0,
                                          ),
                                          Text(
                                            'Nova',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container();
  }
}
