import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:toast/toast.dart';

import 'design.dart';
import 'layout.dart';
import 'pesquisa.dart';

class Aniversariantes extends StatefulWidget {
  DocumentSnapshot usuario, alunodoc;
  bool controle;

  Aniversariantes(this.usuario, this.alunodoc, this.controle);

  @override
  _AniversariantesState createState() => _AniversariantesState();
}

class _AniversariantesState extends State<Aniversariantes> {
  List<String> filtro = [
    "Janeiro",
    "Fevereiro",
    "Março",
    "Abril",
    "Maio",
    "Junho",
    "Julho",
    "Agosto",
    "Setembro",
    "Outubro",
    "Novembro",
    "Dezembro"
  ];
  int posicao = DateTime.now().month - 1;
  String turma='';
  List<String> turmas = [];
  String unidade='';
  List<String> unidades = [];
  List<String> cursos = ['EI', 'EF1', 'EF2', 'EM', 'CN'];
  String curso='';

  @override
  void initState() {
    super.initState();

    if (!widget.controle && widget.alunodoc != null) {
      turma = widget.alunodoc['turma'];
      unidade = widget.alunodoc['unidade'];
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
      }
      if (List<String>.from(widget.usuario['curso'])[0] != 'Todos') {
        cursos = List<String>.from(widget.usuario['curso']);
      }

      if (List<String>.from(widget.usuario['turma'])[0] != 'Todas') {
        turmas = List<String>.from(widget.usuario['turma']);
      }
    }

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.alunodoc != null) {
        toast(context);
      }
    });
    Pesquisa().sendAnalyticsEvent(tela: Nomes().aniversariantes);
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

  toast(context) {
    Toast.show('Perfil de ${widget.alunodoc['nome']}', textStyle: context,
        duration: Toast.lengthLong, gravity: Toast.center);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Cores().corfundo,
        appBar: AppBar(
          title: Text('Aniversariantes'),
          centerTitle: true,
          backgroundColor: Cores().corprincipal,
        ),
        body: Row(
          children: [
            (MediaQuery.of(context).size.width > 850)
                ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                  )
                : Container(),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    (widget.controle)
                        ? Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Layout().dropdownitem(
                                      'Selecione a unidade', unidade,
                                      (String text) {
                                    setState(() {
                                      unidade = text;
                                    });
                                    curso = '';
                                    turma = '';
                                  }, unidades)),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            if (posicao != 0) {
                              setState(() {
                                posicao--;
                              });
                            } else {
                              setState(() {
                                posicao = filtro.length - 1;
                              });
                            }
                          },
                        ),
                        Text(
                          filtro[posicao],
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              fontSize: 18.0),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            if (posicao < 11) {
                              setState(() {
                                posicao++;
                              });
                            } else {
                              setState(() {
                                posicao = 0;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    (unidade != null && turma != null)
                        ? Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection(Nomes().alunosbanco)
                                    .where('ano',
                                    arrayContainsAny: [Pesquisa().getAno()])
                                    .where('unidade', isEqualTo: unidade)
                                    .where('turma', isEqualTo: turma)
                                    .orderBy("datanascimento")
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasError){
                                    print(snapshot.error);
                                    return Text('Isto é um erro. Por gentileza, entre em contato com o suporte.');
                                  }
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return Container();
                                    default:
                                      snapshot.data!.docs.sort((a, b) {
                                        return (a['datanascimento']
                                            .toString()
                                            .compareTo(b['datanascimento']));
                                      });
                                      return (snapshot.data!.docs.length >=
                                              1)
                                          ? ListView(
                                              children: snapshot.data!.docs
                                                  .map((DocumentSnapshot
                                                      document) {
                                                String data =
                                                    document['datanascimento']
                                                        .toString();
                                                if (data != null &&
                                                    data.isNotEmpty &&
                                                    DateTime.parse(data.substring(
                                                                    data.length -
                                                                        4,
                                                                    data
                                                                        .length) +
                                                                data.substring(
                                                                    data.length -
                                                                        7,
                                                                    data.length -
                                                                        5) +
                                                                data.substring(
                                                                    data.length -
                                                                        10,
                                                                    data.length -
                                                                        8))
                                                            .month ==
                                                        posicao + 1) {
                                                  return Layout()
                                                      .itemAniversario(
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
                  ],
                ),
              ),
            ),
            (MediaQuery.of(context).size.width > 850)
                ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                  )
                : Container(),
          ],
        ));
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
