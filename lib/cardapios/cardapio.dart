import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import '../design.dart';
import '../pesquisa.dart';
import 'cardapioAdd.dart';
import '../layout.dart';

class Cardapio extends StatefulWidget {
  final DocumentSnapshot usuario, alunodoc;
  final bool controle, horariotrabalho;

  Cardapio(this.usuario, this.controle, this.horariotrabalho, this.alunodoc);

  @override
  _CardapioState createState() => _CardapioState();
}

class _CardapioState extends State<Cardapio> {
  String cardapio='';
  List cardapios = [];
  String turma='';
  List<String> turmas = [];
  String unidade='';
  List<String> unidades = [];
  List<String> cursos = [];
  String curso='';
  List<String> parametrosbusca = [];

  @override
  void initState() {
    buscartipocardapio();
    if (widget.controle == false) {
      setState(() {
        parametrosbusca = [
          'Todas',
          widget.alunodoc['unidade'],
          widget.alunodoc['curso'] + ' - ' + widget.alunodoc['unidade'],
          widget.alunodoc['turma'] + ' - ' + widget.alunodoc['unidade'],
        ];
      });
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        if (widget.alunodoc != null) {
          toast(context);
        }
      });
    }

    if (widget.controle) {
      if (widget.usuario['unidade'] == 'Todas as unidades') {
        FirebaseFirestore.instance
            .collection(Nomes().unidadebanco)
          .get()
            .then((value) {
          value.docs.forEach((element) {
            setState(() {
              unidades.add(element['unidade']);
            });
          });
        });
      } else {
        unidades.add(widget.usuario['unidade']);
        unidade = widget.usuario['unidade'];
        parametrosbusca = [unidade];
        if(List<String>.from(widget.usuario['curso'])[0] != 'Todos') {
          cursos = List<String>.from(widget.usuario['curso']);
        } else{
          buscarcursos();
        }
      }
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().cardapiobanco);
    super.initState();
  }

  void buscarcursos() {
    FirebaseFirestore.instance
        .collection('Funcionalidades')
        .doc(unidade)
        .get()
        .then((value) {
      setState(() {
        cursos = List<String>.from(value['cardapios']);
      });
    });
  }

  toast(context) {
    Toast.show('Perfil de ${widget.alunodoc['nome']}', textStyle: context,
        duration: Toast.lengthLong, gravity: Toast.center);
  }

  void buscartipocardapio() {
    cardapios.add("Todos");
    FirebaseFirestore.instance
        .collection(Nomes().tipocardapio)
        .orderBy("tipo")
      .get()
        .then((documents) {
      documents.docs.forEach((doc) {
        setState(() {
          cardapios.add(doc['tipo']);
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
        title: Text("Cardápios"),
        actions: <Widget>[
          (widget.controle &&
                  widget.horariotrabalho &&
                  widget.usuario['perfil'] != 'Professor')
              ? FlatButton(
                  textColor: Colors.white,
                  onPressed: () {
                    parasalvar(context);
                  },
                  child: Text(
                    "Editar",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0,
                        letterSpacing: 1.5),
                  ),
                  shape:
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                )
              : Container(),
        ],
      ),
      body: Row(
        children: [
          (MediaQuery.of(context).size.width > 850)
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                )
              : Container(),
          Expanded(
            child: Column(
              children: <Widget>[
                (widget.controle)
                    ? Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Layout().dropdownitem(
                                  'Selecione a unidade',
                                  unidade,
                                  mudarUnidade,
                                  unidades)),
                          (unidade != null)
                              ? Expanded(
                                  flex: 1,
                                  child: Layout().dropdownitem(
                                      'Selecione o curso',
                                      curso,
                                      mudarCurso,
                                      cursos))
                              : Container(),
                          (turmas.isNotEmpty)
                              ? Expanded(
                                  flex: 1,
                                  child: Layout().dropdownitem(
                                      'Selecione a turma',
                                      turma,
                                      mudarTurma,
                                      turmas))
                              : Container()
                        ],
                      )
                    : Container(),
                (cardapios != null && cardapios.length > 1)
                    ? Layout().dropdownitem(
                        "Todos", cardapio, mudarCardapio, cardapios)
                    : Container(),
                (cardapio != null &&
                        cardapio == "Todos" &&
                        parametrosbusca.isNotEmpty)
                    ? Expanded(
                        child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection(Nomes().cardapiobanco)
                            .where('parametrosbusca',
                                arrayContainsAny: parametrosbusca)
                            .orderBy("createdAt", descending: true)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                                'Isto é um erro. Por gentileza, contate o suporte.');
                          }
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Container();
                              break;
                            default:
                              return ListView(
                                children: snapshot.data!.docs.map((doc) {
                                  return Layout().itemCardapio(
                                      doc,
                                      widget.controle,
                                      widget.usuario,
                                      0.6,
                                      'menupdf',
                                      context);
                                }).toList(),
                              );
                          }
                        },
                      ))
                    : Container(),
                (parametrosbusca.isNotEmpty)
                    ? Expanded(
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("${Nomes().cardapiobanco}")
                              .where('parametrosbusca',
                                  arrayContainsAny: parametrosbusca)
                              .where("tipo", isEqualTo: cardapio)
                              .orderBy("createdAt", descending: true)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text(
                                  'Isto é um erro. Por gentileza, contate o suporte.');
                            }
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Container();
                                break;
                              default:
                                return ListView(
                                  children: snapshot.data!.docs.map((doc) {
                                    return Layout().itemCardapio(
                                        doc,
                                        widget.controle,
                                        widget.usuario,
                                        0.6,
                                        'menupdf',
                                        context);
                                  }).toList(),
                                );
                            }
                          },
                        ),
                    )
                    : Container(),
              ],
            ),
          ),
          (MediaQuery.of(context).size.width > 850)
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                )
              : Container(),
        ],
      ),
    );
  }

  void parasalvar(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => CardapioAdd(widget.usuario)));
  }

  void mudarCurso(String text) {
    setState(() {
      curso = text;
      parametrosbusca = [curso + ' - ' + unidade];
    });
    turma = '';
    if (List<String>.from(widget.usuario['turma'])[0] == 'Todas') {
      buscarturmas(unidade, curso);
    }
  }

  void mudarTurma(String text) {
    setState(() {
      turma = text;
      parametrosbusca = [turma + ' - ' + unidade];
    });
  }

  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
      parametrosbusca = [unidade];
    });

      buscarcursos();

    curso = '';
    turma = '';
  }

  mudarCardapio(String text) {
    setState(() {
      cardapio = text;
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
