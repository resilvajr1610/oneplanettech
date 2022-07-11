import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'pesquisa.dart';
import 'usuarioadd.dart';
import 'design.dart';
import 'layout.dart';

class Usuarios extends StatefulWidget {
  DocumentSnapshot usuario;
  Usuarios(this.usuario);

  @override
  _UsuariosState createState() => _UsuariosState();
}

class _UsuariosState extends State<Usuarios> {

  String turma='', palavrapesquisada='';
  List<String> turmas = [];
  String unidade='';
  List<String> unidades = [];
  List<String> cursos = ['EI', 'EF1', 'EF2','EM', 'CN'];
  String curso='';


  @override
  void initState() {
    super.initState();

    if(widget.usuario['unidade'] == 'Todas as unidades'){
      buscarunidades();
    } else {
      setState(() {
        unidade = widget.usuario['unidade'];
      });
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().usuarios);




  }
  buscarunidades() {
    unidades.add('Todas as unidades');
    FirebaseFirestore.instance.collection(Nomes().unidadebanco).get().then((docs) {
      docs.docs.forEach((doc) {
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
      appBar: Layout().appbarcombotaosimples(parasalvar, "Usuários", "Incluir", context, userid: '', deletar: false),
      body: Row(
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Layout().dropdownitem(
                            'Selecione a unidade',
                            unidade,
                            mudarUnidade,
                            unidades)),
                    (unidade != null) ?     Expanded(
                        flex: 1,
                        child: Layout().dropdownitem(
                            'Selecione o curso',
                            curso,
                            mudarCurso,
                            cursos)):Container(),

                    (turmas.isNotEmpty) ?   Expanded(
                        flex: 1,
                        child: Layout().dropdownitem(
                            'Selecione a turma',
                            turma,
                            mudarTurma,
                            turmas)): Container(),
                  ],
                ),
                Layout().campopesquisa((text){
                  setState(() {
                    palavrapesquisada = text;
                  });
                }),
                (unidade != null && curso == null) ?  Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(Nomes().usersbanco)
                          .where("controle", isEqualTo: Nomes().controle)
                          .where('unidade', isEqualTo: unidade)
                          .orderBy("nome")
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return Text('Isto é um erro. Por gentileza, contate o suporte');
                        }

                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Container();
                          default:
                            return (snapshot.data!.docs.length >= 1)
                                ? ListView(
                              children: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                if (document['email'] != "elaine@master.com" && document['email'] != "test@gmail.com") {
                                  return Layout()
                                      .itemUsuario(document, widget.usuario, palavrapesquisada,  context);
                                } else {
                                  return Container();
                                }
                              }).toList(),
                            )
                                : Container();
                        }
                      }),
                ): Container(),
                  (curso != null && turma == null) ?  Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(Nomes().usersbanco)
                          .where("controle", isEqualTo: Nomes().controle)
                          .where('unidade', isEqualTo: unidade)
                          .where('curso', arrayContainsAny: [curso, 'Todos'])
                          .orderBy("nome")
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return Text('Isto é um erro. Por gentileza, contate o suporte');
                        }
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Container();
                          default:
                            return (snapshot.data!.docs.length >= 1)
                                ? ListView(
                              children: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                if (document['email'] != "elaine@master.com" && document['email'] != "test@gmail.com") {

                                  return Layout()
                                      .itemUsuario(document, widget.usuario, palavrapesquisada, context);
                                } else {
                                  return Container();
                                }
                              }).toList(),
                            )
                                : Container();
                        }
                      }),
                ): Container(),
                  (turma != null) ?
       Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(Nomes().usersbanco)
                          .where("controle", isEqualTo: Nomes().controle)
                          .where('unidade', isEqualTo: unidade)
                          .where('turma', arrayContainsAny: [ turma, 'Todas'])
                          .orderBy("nome")
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return Text('Isto é um erro. Por gentileza, contate o suporte');
                        }
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Container();
                          default:
                            return (snapshot.data!.docs.length >= 1)
                                ? ListView(
                              children: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                if (document['email'] != "elaine@master.com" && document['email'] != "test@gmail.com") {

                                  return

                                    (List<String>.from(document['curso']) == 'Todos' || List<String>.from(document['curso']).contains(curso) ) ?

                                    Layout()
                                      .itemUsuario(document, widget.usuario, palavrapesquisada, context) : Container();
                                } else {
                                  return Container();
                                }
                              }).toList(),
                            )
                                : Container();
                        }
                      }),
                ): Container()
              ],
            ),
          ),
          Layout().espacolateral(context),
        ],
      ),
    );
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

  void mudarCurso(String text) {
    setState(() {
      curso = text;
    });
    turma = '';
    if(List<String>.from(widget.usuario['turma'])[0] == 'Todas'){
      buscarturmas(unidade, curso);}
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

  void parasalvar(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => UsuarioAdd(widget.usuario, '' as DocumentSnapshot)));
  }
}

