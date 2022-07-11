import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scalifra/itens/itemrespostaenquete.dart';

import 'design.dart';
import 'layout.dart';
import 'pesquisa.dart';

class RespostaEnquete extends StatefulWidget {
  final DocumentSnapshot doc, usuario;

  RespostaEnquete(this.doc, this.usuario);

  @override
  _RespostaEnqueteState createState() => _RespostaEnqueteState();
}

class _RespostaEnqueteState extends State<RespostaEnquete> {
  String aluno='', turma='', unidade='', curso='';
  List<DocumentSnapshot> alunos = [];
  List<String> unidades = [];
  List<String> respostas = [];
  List<String> usuario = [];
  List<String> turmas = [];
  List<String> cursos = ['EI', 'EF1', 'EF2', 'EM', 'CN'];
  Map<String, List<String>> maprespostas = Map();

  @override
  void initState() {
    super.initState();
    if (widget.usuario['unidade'] == 'Todas as unidades' &&
        widget.doc['para'] == 'Todas') {
      buscarUnidades();
    } else {
      unidade = widget.doc['unidade'];
      unidades.add(widget.doc['unidade']);
    }
    if (List<String>.from(widget.usuario['curso'])[0] != 'Todos') {
      cursos = List<String>.from(widget.usuario['curso']);
    }
    if (List<String>.from(widget.usuario['turma'])[0] != 'Todas') {
      turmas = List<String>.from(widget.usuario['turma']);
    }

  }

  void buscarUnidades() {
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
    unidades.add(widget.usuario['unidade']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbar("Respostas Enquete"),
      body: Column(
        children: <Widget>[
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Layout().dropdownitem(
                      'Selecione a unidade', unidade, mudarUnidade, unidades)),
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
          // Rede
          (widget.doc['unidade'] == 'Todas')
              ? Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("${Nomes().alunosbanco}")
                          .where('ano',
                          arrayContainsAny: [Pesquisa().getAno()])
                          .orderBy("nome")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                              'Isto é um erro. Por gentileza, contate o suporte.');
                        }
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Container();
                            break;
                          default:
                            return Container();
                            // return ListView(
                            //   children: snapshot.data.docs.map((doc) {
                            //     if (unidade == null || unidade == 'Todas') {
                            //       return ItemRespostaEnquete(doc, widget.doc);
                            //     } else if (unidade != null &&
                            //         unidade != 'Todas' &&
                            //         doc['unidade'] == unidade &&
                            //         curso == null) {
                            //       return ItemRespostaEnquete(doc, widget.doc);
                            //     } else if (unidade != null &&
                            //         curso != null &&
                            //         doc['curso'] == curso) {
                            //       return ItemRespostaEnquete(doc, widget.doc);
                            //     }
                            //   }).toList(),
                            // );
                        }
                      }),
                )
              :
              // Turmas
              (widget.doc['para'] !=
                          List<String>.from(widget.doc['parametrosbusca'])[0] &&
                      widget.doc['para'] == widget.doc['turma'])
                  ? Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection(Nomes().alunosbanco)
                              .where('ano',
                              arrayContainsAny: [Pesquisa().getAno()])
                              .where('unidade',
                                  isEqualTo: widget.doc['unidade'])
                              .where('turma', isEqualTo: widget.doc['turma'])
                              .orderBy("nome")
                              .snapshots(),
                          builder: (context, snapshot) {
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
                                    return ItemRespostaEnquete(doc, widget.doc);
                                  }).toList(),
                                );
                            }
                          }),
                    )
                  :
                  // Alunos
                  (widget.doc['nome'] != widget.doc['para'] &&
                          widget.doc['turma'] != null)
                      ? StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection(Nomes().alunosbanco)
                              .doc(widget.doc['para'])
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text(
                                  'Isto é um erro. Por gentileza, contate o suporte.');
                            }
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Container();
                                break;
                              default:
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: ItemRespostaEnquete(
                                      snapshot.data!, widget.doc),
                                );
                            }
                          })
                      : (widget.doc['nome'] != widget.doc['para'] &&
                              turma == null)
                          ?
                          // Cursos
                          Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection("${Nomes().alunosbanco}")
                                      .where('ano',
                                      arrayContainsAny: [Pesquisa().getAno()])
                                      .where('unidade',
                                          isEqualTo: widget.doc['unidade'])
                                      .where('curso',
                                          isEqualTo: widget.doc['nome'])
                                      .orderBy("nome")
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text(
                                          'Isto é um erro. Por gentileza, contate o suporte.');
                                    }
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                        return Container();
                                        break;
                                      default:
                                        return Container();
                                        // return ListView(
                                        //   children: snapshot.data?.docs
                                        //       .map((doc) {
                                        //     if (doc.exists) {
                                        //       return ItemRespostaEnquete(
                                        //           doc, widget.doc);
                                        //     }
                                        //   }).toList(),
                                        // );
                                    }
                                  }),
                            )
                          :
// Unidades
                          Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection(Nomes().alunosbanco)
                                      .where('ano',
                                      arrayContainsAny: [Pesquisa().getAno()])
                                      .where('unidade',
                                          isEqualTo: widget.doc['unidade'])
                                      .orderBy("nome")
                                      .snapshots(),
                                  builder: (context, snapshot) {
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
                                          children: snapshot.data!.docs
                                              .map((doc) {
                                            return ItemRespostaEnquete(
                                                doc, widget.doc);
                                          }).toList(),
                                        );
                                    }
                                  }),
                            )
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
