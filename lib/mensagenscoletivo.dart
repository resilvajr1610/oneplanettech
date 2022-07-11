import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:toast/toast.dart';

import 'fotoaluno.dart';
import 'itens/itemcheckboxdocs.dart';
import 'layout.dart';
import 'design.dart';
import 'pesquisa.dart';

class MensagensColetivo extends StatefulWidget {
  DocumentSnapshot usuario;

  MensagensColetivo(this.usuario);

  @override
  _MensagensColetivoState createState() => _MensagensColetivoState();
}

class _MensagensColetivoState extends State<MensagensColetivo> {
  String turma='',
      unidade='',
      curso='',
      palavrapesquisada='',
      dest = "Escolher destinatários";
  List<String> turmas = [];
  List<String> selecionardest = [
    "Escolher destinatários",
    "Todos Responsáveis",
    "Todos Alunos",
    "Todos"
  ];
  List<String> unidades = [];
  List<String> cursos = ['EI', 'EF1', 'EF2', 'EM', 'CN'];
  TextEditingController texto = TextEditingController();
  List listaCompletaDestinatarios = [];
  Map<DocumentSnapshot, DocumentSnapshot> map = Map();

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
    Pesquisa().sendAnalyticsEvent(tela: Nomes().msgColetivo);
  }

  buscarturmas(uni, curs) {
    turmas.clear();
    if (List<String>.from(widget.usuario['turma'])[0] == 'Todas') {
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
    } else {
      setState(() {
        turmas = List<String>.from(widget.usuario['turma']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbarcombotaosimples((context) {
        salvar();
      }, 'Lista de transmissão:', 'Salvar', context),
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
                    Spacer(),
                    FlatButton(
                        onPressed: () {
                          modalDestinatarios(context);
                        },
                        color: Cores().cormensagem,
                        child: Text(
                          'Ver destinatários',
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
                Layout().caixadetexto(2, 10, TextInputType.multiline, texto,
                    'Escreva aqui a mensagem', TextCapitalization.sentences),
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
                        : Container(),
                  ],
                ),
                (turma != null)
                    ? Layout().dropdownitem(
                        'Selecionar individualmente',
                        dest,
                        mudarSelecionarDest,
                        selecionardest)
                    : Container(),
                Layout().campopesquisa((text) {
                  setState(() {
                    palavrapesquisada = text;
                  });
                }),
                Expanded(
                  child: (unidade != null && turma != null)
                      ? StreamBuilder<QuerySnapshot>(
                          stream: buscarAlunos().snapshots(),
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
                                          return itemAluno(
                                              widget.usuario,
                                              document,
                                              'modal',
                                              palavrapesquisada,
                                              context);
                                        }).toList(),
                                      )
                                    : Container();
                            }
                          })
                      : Container(),
                ),
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

  Query buscarAlunos() {
    return FirebaseFirestore.instance
        .collection(Nomes().alunosbanco)
        .where('ano', arrayContainsAny: [Pesquisa().getAno()])
        .where('unidade', isEqualTo: unidade)
        .where('curso', isEqualTo: curso)
        .where("turma", isEqualTo: turma)
        .orderBy("nome");
  }

  Widget itemAluno(DocumentSnapshot usuario, DocumentSnapshot aluno, destino,
      palavrapesquisada, context) {
    return (palavrapesquisada == null ||
            aluno['nome']
                .toString()
                .toLowerCase()
                .contains(palavrapesquisada.toString().toLowerCase()))
        ? Card(
            elevation: 5.0,
            child: InkWell(
              hoverColor: Cores().corprincipal.withOpacity(0.2),
              onTap: () {
                modalResps(aluno, context);
              },
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: InkWell(
                      onTap: () {
                        Pesquisa().irpara(FotoAluno(aluno), context);
                      },
                      child: Hero(
                        tag: aluno.id,
                        child: aluno['foto'] != null
                            ? Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: (!kIsWeb)
                                          ? CachedNetworkImageProvider(
                                              aluno['foto'])
                                          : NetworkImage(aluno['foto']) as ImageProvider,
                                      fit: BoxFit.cover),
                                ))
                            : Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: AssetImage('images/picture.png'),
                                      fit: BoxFit.cover),
                                )),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: AutoSizeText(
                            aluno['nome'],
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        (aluno['turma'] != null)
                            ? Text(aluno['curso'] + " - " + aluno['turma'])
                            : Container(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        : Container();
  }

  modalResps(aluno, context) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) {
        return Scaffold(
            body: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                },
                leading: Icon(
                  Icons.close,
                  color: Colors.blue,
                ),
                title: Text(
                  'Escolha o destinatário:',
                  style: TextStyle(
                    color: Cores().corprincipal,
                    fontFamily: "Sofia",
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Divider(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(Nomes().usersbanco)
                        .where('alunos', arrayContainsAny: [aluno.documentID])
                        .orderBy('nome')
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
                                    return itemresp(document, aluno);
                                  }).toList(),
                                )
                              : Container();
                      }
                    }),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ));
      },
    );
  }

  modalDestinatarios(context) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) {
        return Scaffold(
            body: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                },
                leading: Icon(
                  Icons.close,
                  color: Colors.blue,
                ),
                title: Text(
                  'Destinatários:',
                  style: TextStyle(
                    color: Cores().corprincipal,
                    fontFamily: "Sofia",
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Divider(),
              Expanded(
                child: ListView(
                  children: List<Widget>.generate(
                    listaCompletaDestinatarios.length,
                    (int index) {
                      return itemdestinatarios(
                          listaCompletaDestinatarios[index]);
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ));
      },
    );
  }

  selecionarLista() {
    buscarAlunos().get().then((value) {
      value.docs.forEach((alunoDoc) {
        FirebaseFirestore.instance
            .collection(Nomes().usersbanco)
            .where('alunos', arrayContainsAny: [alunoDoc.id])
            .orderBy('nome')
            .get()
            .then((usersdoc) {
              usersdoc.docs.forEach((userDoc) {
                if (dest == 'Todos' ||
                    (dest == 'Todos Responsáveis' &&
                        userDoc['parentesco'] != 'Aluno') ||
                    (dest == 'Todos Alunos' &&
                        userDoc['parentesco'] == 'Aluno')) {
                  listaCompletaDestinatarios.add(
                      "${userDoc.id}-${alunoDoc.id}-${userDoc['nome']}-${userDoc['parentesco']}-${alunoDoc['nome']}");
                }
              });
            });
      });
      Toast.show(
          '$dest foram selecionados. Confira clicando em ver destinatários.', textStyle: context,
          duration: Toast.lengthLong, gravity: Toast.center);
    });
  }

  Widget itemdestinatarios(String concatenada) {
    List concatenadaSplit = concatenada.split('-');
    return Column(
      children: [
        Row(
          children: [
            Spacer(),
            TextButton(
                onPressed: () {
                  listaCompletaDestinatarios.remove(concatenada);
                  Navigator.pop(context);
                  modalDestinatarios(context);
                },
                child: Text('x')),
          ],
        ),
        Text(concatenadaSplit[2]),
        Layout().titulo(concatenadaSplit[3]),
        Text('Resp: ${concatenadaSplit[4]}'),
        Divider()
      ],
    );
  }

  Widget itemresp(DocumentSnapshot paidoc, alunodoc) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ItemCheckBoxDocs(listaCompletaDestinatarios,
              "${paidoc.id}-${alunodoc.documentID}-${paidoc['nome']}-${paidoc['parentesco']}-${alunodoc['nome']}"),
          Layout().titulo(paidoc['parentesco']),
          Text(paidoc['nome']),
          paidoc['responsavelfinanceiro']
              ? Text('Resp. Financeiro')
              : Container(),
          Divider()
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

  void mudarSelecionarDest(String text) {
    setState(() {
      dest = text;
    });
    listaCompletaDestinatarios.clear();
    if (dest == 'Escolher destinatários') {
      Toast.show(
          'Escolha os destinatários, clicando no card dos alunos', textStyle: context,
          duration: Toast.lengthLong, gravity: Toast.center);
    } else {
      selecionarLista();
    }
  }

  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
    });
    curso = '';
    turma = '';
  }

  salvar() {
    if (texto.text.isEmpty) {
      Layout().dialog1botao(context, 'Mensagem', 'Primeiro escreva a mensagem');
    } else if (listaCompletaDestinatarios.length == 0) {
      Layout().dialog1botao(context, 'Destinatários',
          'Selecione os destinatários, clicando nos alunos');
    } else {
      Pesquisa().salvarListaTransmissao(
          listaCompletaDestinatarios, widget.usuario, texto.text);
      texto.clear();
      listaCompletaDestinatarios.clear();
      Layout().dialog1botao(
          context, 'Enviada', 'A mensagem foi enviada para os destinatários');
    }
  }
}
