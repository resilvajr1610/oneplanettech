import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pesquisa.dart';
import 'downloadadd.dart';
import '../design.dart';
import '../layout.dart';
import '../pdfviewer.dart';

class Downloads extends StatefulWidget {
  bool controle, horariotrabalho;
  DocumentSnapshot usuario, alunodoc;

  Downloads(this.controle, this.horariotrabalho, this.usuario, this.alunodoc);

  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  String nomeImagem='';
  late File image;
  List<String> parametrosbusca=[];
  List<String> unidades = [];
  String unidade='';
  List<String> turmas = [];
  String turma='';
  String curso='';
  List<String> cursos = ['EI', 'EF1', 'EF2','EM', 'CN'];

  @override
  void initState() {
    super.initState();
    if(widget.controle == false) {
      setState(() {
        parametrosbusca = [
          'Todas',
          widget.alunodoc['unidade'],
          widget.alunodoc['curso'] + ' - ' + widget.alunodoc['unidade'],
          widget.alunodoc['turma'] + ' - ' + widget.alunodoc['unidade'],
          widget.alunodoc.id
        ];
      });
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        if (widget.alunodoc != null) {
          toast(context);
        }
      });
    }
    else{
      //funcionário
      if(widget.usuario['unidade'] == 'Todas as unidades') {
        buscarunidades();
      } else {
        unidade = widget.usuario['unidade'];
        parametrosbusca = ['Todas', unidade];
        unidades.add("Todas");
        unidades.add(widget.usuario['unidade']);
      }
      if(List<String>.from(widget.usuario['curso'])[0] != 'Todos') {
        cursos = List<String>.from(widget.usuario['curso']);
      }
      if(List<String>.from(widget.usuario['turma'])[0] != 'Todas') {
        turmas = List<String>.from(widget.usuario['turma']);
      }
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().downloadsbanco);
  }

  void buscarturmas(curs, uni) {
    turmas.clear();
    FirebaseFirestore.instance
        .collection(Nomes().turmabanco)
        .where('curso', isEqualTo: curs)
        .where('unidade', isEqualTo: uni)
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

  buscarunidades(){
    unidades.add("Todas");
    FirebaseFirestore.instance.collection(Nomes().unidadebanco).get().then((docs) {
      docs.docs.forEach((element) {
        setState(() {
          unidades.add(element['unidade']);
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
        backgroundColor: Cores().corprincipal,
        title: Text("Downloads"),
        actions: <Widget>[
          (widget.controle && widget.horariotrabalho)
              ? FlatButton(
                  textColor: Colors.white,
                  onPressed: () {
                    editarcalendario();
                  },
                  child: Text(
                    "Incluir",
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
          Layout().espacolateral(context),
          Expanded(
            child: Column(
              children: <Widget>[
                (widget.controle) ? Row(
                  children: [
                    (unidades.isNotEmpty)
                        ?  Expanded(
                      flex: 1,
                      child: Layout().dropdownitem(
                          'Selecione a unidade', unidade, mudarUnidade, unidades),
                    ) : Container(),
                    (widget.controle && unidade != null && unidade != 'Todas')
                        ?  Expanded(
                      flex: 1,
                      child: Layout().dropdownitem(
                          'Selecione o curso', curso, mudarCurso, cursos),
                    ) : Container(),
                    (turmas != null && turmas.isNotEmpty)
                        ? Expanded(
                      flex: 1,
                      child:  Layout()
                          .dropdownitem("Selecione a turma", turma, mudarTurma, turmas),
                    )
                        : Container(),
                  ],
                ): Container(),
                (parametrosbusca!= null) ? Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection(Nomes().downloadsbanco)
                        .where('parametrosbusca', arrayContainsAny: parametrosbusca)
                        .orderBy('nome')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Isto é um erro. Por gentileza, contate o suporte.');
                      }
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Container();
                          break;
                        default:
                          return ListView(
                            children: snapshot.data!.docs.map((doc) {
                              return itemdownload(doc);
                            }).toList(),
                          );
                      }
                    },
                  ),
                ) : Container(),
              ],
            ),
          ),
          Layout().espacolateral(context),
        ],
      ),
    );
  }

  editarcalendario() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DownloadAdd(widget.usuario)));
  }

  Widget itemdownload(doc) {
    return  GestureDetector(
            onLongPress: () {
              if (widget.controle != null && widget.controle) {
                Layout().deletar(doc, context);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8.0, top: 4.0),
              child: Card(
                elevation: 1.0,
                child: InkWell(
                    onTap: () {
                      if(doc['tipo'] == 'pdf') {
                        _abrirdoc(doc);
                      }
                      if(doc['tipo'] == 'link') {
                        abrirsite(doc['link']);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: ListTile(
                        leading: Icon((doc['tipo'] == 'link') ? Icons.wifi_tethering : Icons.picture_as_pdf),
                        title: Text(
                          doc['nome'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    )),
              ),
            ),
          )
        ;
  }


  abrirsite(String link) async {
    if(!link.startsWith('http://') || !link.startsWith('https://') ){
      link = 'http://'+link;
    }
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      Toast.show('Não foi possível abrir o link', textStyle: context);
      throw 'Não foi possível abrir $link';
    }
  }
  

  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
      curso = '';
      turma = '';
      parametrosbusca = [unidade];
    });

  }
  void mudarCurso(String text) {
    setState(() {
      turma = '';
      curso = text;
    });
    parametrosbusca = [curso + ' - ' + unidade];
    if(List<String>.from(widget.usuario['turma'])[0] == 'Todas'){
    buscarturmas(curso ,unidade);
    }
  }

  void mudarTurma(String text) {
    setState(() {
      turma = text;
    });
    parametrosbusca = [ turma + ' - ' + unidade];
  }

  _abrirdoc(doc) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DocumentoDetalhes('doc', doc, widget.usuario, widget.controle)));
  }
}
