import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scalifra/mensagenscoletivo.dart';

import 'layout.dart';
import 'mensagempara.dart';
import 'design.dart';
import 'pesquisa.dart';

class Mensagens extends StatefulWidget {
  DocumentSnapshot usuario;

  Mensagens(this.usuario);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  String turma='', unidade='', curso='', palavrapesquisada='';
  List<String> turmas = [];
  List<String> unidades = [];
  List<String> cursos = ['EI', 'EF1', 'EF2', 'EM', 'CN'];

  @override
  void initState() {
    super.initState();

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
    }
    if (List<String>.from(widget.usuario['curso'])[0] != 'Todos') {
      cursos = List<String>.from(widget.usuario['curso']);
    }

    if (List<String>.from(widget.usuario['turma'])[0] != 'Todas') {
      turmas = List<String>.from(widget.usuario['turma']);
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().mensagensPais);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbarcombotaosimples((context) {
        Pesquisa().irpara(MensagensColetivo(widget.usuario), context);
      }, 'Referente a:', 'Lista de Transmissão', context),
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
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Layout().dropdownitem('Selecione a unidade',
                            unidade, mudarUnidade, unidades)),
                    (unidade != null)
                        ? Expanded(
                            flex: 1,
                            child: Layout().dropdownitem(
                                'Selecione o curso', curso, mudarCurso, cursos))
                        : Container(),
                    (turmas.isNotEmpty)
                        ? Expanded(
                            flex: 1,
                            child: Layout().dropdownitem(
                                'Selecione a turma', turma, mudarTurma, turmas))
                        : Container()
                  ],
                ),
                Layout().campopesquisa((text) {
                  setState(() {
                    palavrapesquisada = text;
                  });
                }),
                (unidade != null && (List<String>.from(widget.usuario['curso']).contains('Todos')))  ?  Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection(Nomes().alunosbanco)
                              .where('ano',
                              arrayContainsAny: [Pesquisa().getAno()])
                              .where('unidade', isEqualTo: unidade)
                              .where('curso', isEqualTo: curso)
                              .where("turma", isEqualTo: turma)
                              .orderBy("nome")
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError)
                              return Text('Error: ${snapshot.error}');
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Container();
                              default:
                                return (snapshot.data!.docs.length >= 1)
                                    ? ListView(
                                        children: snapshot.data!.docs
                                            .map((DocumentSnapshot document) {
                                          return Layout().itemAluno(
                                              widget.usuario,
                                              document,
                                              MensagemPara(
                                                  widget.usuario,
                                                  document,
                                                  widget.usuario['perfil']),
                                              palavrapesquisada,
                                              context);
                                        }).toList(),
                                      )
                                    : Container();
                            }
                          })
                ): Container(),
                (curso != null && !(List<String>.from(widget.usuario['curso']).contains('Todos'))  && (List<String>.from(widget.usuario['turma']).contains('Todas')))  ?  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(Nomes().alunosbanco)
                            .where('ano',
                            arrayContainsAny: [Pesquisa().getAno()])
                            .where('unidade', isEqualTo: unidade)
                            .where('curso', isEqualTo: curso)
                            .where("turma", isEqualTo: turma)
                            .orderBy("nome")
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError)
                            return Text('Error: ${snapshot.error}');
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Container();
                            default:
                              return (snapshot.data!.docs.length >= 1)
                                  ? ListView(
                                children: snapshot.data!.docs
                                    .map((DocumentSnapshot document) {
                                  return Layout().itemAluno(
                                      widget.usuario,
                                      document,
                                      MensagemPara(
                                          widget.usuario,
                                          document,
                                          widget.usuario['perfil']),
                                      palavrapesquisada,
                                      context);
                                }).toList(),
                              )
                                  : Container();
                          }
                        })
                ): Container(),
                (curso != null && turma != null && !(List<String>.from(widget.usuario['curso']).contains('Todos'))  && !(List<String>.from(widget.usuario['turma']).contains('Todas')))  ?  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(Nomes().alunosbanco)
                            .where('ano',
                            arrayContainsAny: [Pesquisa().getAno()])
                            .where('unidade', isEqualTo: unidade)
                            .where('curso', isEqualTo: curso)
                            .where("turma", isEqualTo: turma)
                            .orderBy("nome")
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError)
                            return Text('Error: ${snapshot.error}');
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Container();
                            default:
                              return (snapshot.data!.docs.length >= 1)
                                  ? ListView(
                                children: snapshot.data!.docs
                                    .map((DocumentSnapshot document) {
                                  return Layout().itemAluno(
                                      widget.usuario,
                                      document,
                                      MensagemPara(
                                          widget.usuario,
                                          document,
                                          widget.usuario['perfil']),
                                      palavrapesquisada,
                                      context);
                                }).toList(),
                              )
                                  : Container();
                          }
                        })
                ): Container(),
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

  void mudarCurso(String text) {
    setState(() {
      curso = text;
    });
    turma = '';
    if (List<String>.from(widget.usuario['turma'])[0] == 'Todas') {
      buscarturmas(unidade, curso);
    }
  }

  void mudarTurma(String text) {
    setState(() {
      turma = text;
    });
  }

  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
    });
    curso = '';
    turma = '';
  }
}
