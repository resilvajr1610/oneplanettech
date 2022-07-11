import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:scalifra/alunos/alunosresponsaveis.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:universal_html/html.dart' as html;
import '../blocs.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../design.dart';
import '../layout.dart';
import '../pesquisa.dart';

class Alunos extends StatefulWidget {
  final DocumentSnapshot usuario;
  final String perfil;

  Alunos(this.usuario, this.perfil);

  @override
  _AlunosState createState() => _AlunosState();
}

class _AlunosState extends State<Alunos> {
  final bloc = BlocProvider.getBloc<AlunosBloc>();

  List<String> unidades = [];
  String unidade='', palavrapesquisada='';
  List<String> cursos = ['EI', 'EF1', 'EF2', 'EM', 'CN'];
  String curso='';
  List<String> turmas = [];
  String turmastring='';

  @override
  void initState() {
    super.initState();
    //verificarPubsemCurso();
   //  Pesquisa().verificaralunos();
    // Pesquisa().adicionarfoto();
    // apagaruserseic();
    bloc.inputnumeroalunos.add(0);
    if (widget.usuario['unidade'] == 'Todas as unidades') {
      buscarunidades();
    } else {
      unidade = widget.usuario['unidade'];
      unidades.add(widget.usuario['unidade']);
    }
    if (List<String>.from(widget.usuario['curso'])[0] != 'Todos') {
      cursos = List<String>.from(widget.usuario['curso']);
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().alunosbanco);
  }

  verificarPubsemCurso() {
    FirebaseFirestore.instance
        .collection(Nomes().publicacoesbanco)
    .where('unidade', isEqualTo: 'ESFA')
        .get()
        .then((docs) {
      docs.docs.forEach((element) {
    if(element['curso'] == null){
      print(element.id);
    }
      });
    });
  }

  buscarunidades() {
    FirebaseFirestore.instance
        .collection(Nomes().unidadebanco)
        .get()
        .then((docs) {
      docs.docs.forEach((element) {
        setState(() {
          unidades.add(element['unidade']);
        });
      });
    });
  }

  Future gerarcsv() async {
    FirebaseFirestore.instance
        .collection(Nomes().alunosbanco)
        .orderBy("nome")
        .where('unidade', isEqualTo: unidade)
        .where('curso', isEqualTo: curso)
        .where('turma', isEqualTo: turmastring)
        .where("ano", arrayContainsAny: [Pesquisa().getAno()])
        .get()
        .then((docs) {
          List<List<String>> csvData = [];
          int i = 0;
          csvData.add(<String>[
            '#',
            'Codigo',
            'Nome',
            'DataNascimento',
            'Unidade',
            'Curso',
            'Turma'
          ]);
          docs.docs.forEach((doc) {
            i++;
            csvData.add(<String>[
              i.toString(),
              doc['codigo'],
              doc['nome'],
              doc['datanascimento'],
              doc['unidade'],
              doc['curso'],
              doc['turma']
            ]);
          });
          String csv =
              ListToCsvConverter().convert(csvData, fieldDelimiter: ';');

          if (kIsWeb) {
// prepare
//             final blob = html.Blob([Uint8List.fromList(csv.codeUnits)]);
//             final url = html.Url.createObjectUrlFromBlob(blob);
//             final anchor =
//                 html.document.createElement('a') as html.AnchorElement
//                   ..href = url
//                   ..style.display = 'none'
//                   ..download = '${DateTime.now().toIso8601String()}.csv';
//             html.document.body?.children.add(anchor);

// download
//             anchor.click();

// cleanup
//             html.document.body?.children.remove(anchor);
//             html.Url.revokeObjectUrl(url);
          } else {
            // Uint8List arquive = Uint8List.fromList(csv.codeUnits);
            // StorageReference storageReference = FirebaseStorage.instance
            //     .ref()
            //     .child('csv/' + DateTime.now().toIso8601String() + ".csv");
            // StorageUploadTask uploadTask = storageReference.putData(arquive);
            // uploadTask.onComplete.then((value) {
            //   value.ref.getDownloadURL().then((value) async {
            //     var url = '${value.toString()}';
            //     if (await canLaunch(url)) {
            //       await launch(url);
            //     } else {
            //       throw 'Could not launch $url';
            //     }
            //   });
            // });
          }
        });
  }

  @override
  void dispose() {
    bloc.inputturma.add('Todas');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: AppBar(
        backgroundColor: Cores().corprincipal,
        title: StreamBuilder<int>(
            stream: bloc.outputnumeroalunos,
            builder: (context, numeroalunos) {
              return Text(
                numeroalunos.data != null
                    ? "Alunos (${numeroalunos.data})"
                    : 'Alunos',
                style: Layout().sanslight(),
              );
            }),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              await gerarcsv();
            },
            child: Text(
              'CSV',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: StreamBuilder<String>(
                stream: bloc.outputturma,
                builder: (context, turma) {
                  return Column(
                    children: <Widget>[
                      Row(
                        children: [
                          (unidades.length > 0)
                              ? Expanded(
                                  flex: 1,
                                  child: Layout().dropdownitem(
                                      'Selecione a unidade',
                                      unidade,
                                      mudarUnidade,
                                      unidades),
                                )
                              : Container(),
                          (cursos != null && unidade != null)
                              ? Expanded(
                                  flex: 1,
                                  child: Layout().dropdownitem(
                                      "Selecione o curso",
                                      curso,
                                      mudarCurso,
                                      cursos),
                                )
                              : Container(),
                          (turmas != null && turmas.length > 0)
                              ? Expanded(
                                  flex: 1,
                                  child: Layout().dropdownitem(
                                      "Selecione a turma",
                                      turmastring,
                                      mudarTurma,
                                      turmas),
                                )
                              : Container(),
                        ],
                      ),
                      Layout().campopesquisa((text) {
                        setState(() {
                          palavrapesquisada = text;
                        });
                      }),
                      Expanded(
                          child: (unidade != null)
                              ? StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection(Nomes().alunosbanco)
                                      .where('unidade', isEqualTo: unidade)
                                      .where('ano', arrayContainsAny: [
                                        Pesquisa().getAno()
                                      ])
                                      .where('curso', isEqualTo: curso)
                                      .where('turma', isEqualTo: turmastring)
                                      .orderBy("nome")
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
                                        bloc.inputnumeroalunos.add(
                                            snapshot.data!.docs.length);
                                        return (snapshot
                                                    .data!.docs.length >=
                                                1)
                                            ? ListView(
                                                children: snapshot
                                                    .data!.docs
                                                    .map((DocumentSnapshot
                                                        document) {
                                                  return Layout().itemAluno(
                                                      widget.usuario,
                                                      document,
                                                      AlunosResponsaveis(
                                                          document),
                                                      palavrapesquisada,
                                                      context);
                                                }).toList(),
                                              )
                                            : Container();
                                    }
                                  })
                              : Container())
                    ],
                  );
                }),
          ),
          Layout().espacolateral(context),
        ],
      ),
    );
  }

  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
      curso = '';
      turmastring = '';
    });
  }

  void mudarCurso(String text) {
    setState(() {
      curso = text;
      turmastring = '';
    });
    if (List<String>.from(widget.usuario['turma'])[0] == 'Todas') {
      buscarturmas(unidade, curso);
    }
  }

  void mudarTurma(String text) {
    setState(() {
      turmastring = text;
    });
  }

  void buscarturmas(uni, curs) {
    turmas.clear();

    FirebaseFirestore.instance
        .collection(Nomes().turmabanco)
        .where('unidade', isEqualTo: uni)
        .where('curso', isEqualTo: curs)
        .orderBy("turma")
        .get()
        .then((documents) {
      documents.docs.forEach((doc) {
        setState(() {
          turmas.add(doc['turma']);
        });
      });
    });
  }
}
