import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'design.dart';
import 'layout.dart';
import 'mensagem.dart';
import 'pesquisa.dart';

class Publicar extends StatefulWidget {
  DocumentSnapshot usuario, alunodoc;

  Publicar(this.usuario, this.alunodoc);

  @override
  _PublicarState createState() => _PublicarState();
}

class _PublicarState extends State<Publicar> with TickerProviderStateMixin {
  int opcao = 0;
  List<Tab> tabs=[];

  late TabController tabController;

  inittab() {
    tabController = TabController(
      vsync: this,
      length: tabs.length,
      initialIndex: opcao,
    );
    tabController.addListener(() {
      setState(() {
        opcao = tabController.index;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection(Nomes().perfilbanco)
        .where('unidade', isEqualTo: widget.alunodoc['unidade'])
        .where('perfil', isEqualTo: 'Professor')
        .where('chat', isEqualTo: true)
      .get()
        .then((value) {
      if (value.docs.length > 0) {
        setState(() {
          tabs = [
            Tab(text: 'Administração'),
            Tab(text: 'Professores'),
          ];
        });

        inittab();
      } else {
        setState(() {
          tabs = [Tab(text: 'Administração')];
        });
        inittab();
      }
    });
    Pesquisa().sendAnalyticsEvent(tela: Nomes().publicar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: (tabs != null)
          ? AppBar(
              backgroundColor: Cores().corprincipal,
              title: Text("Escrever para:"),
              bottom: TabBar(
                controller: tabController,
                tabs: tabs,
              ))
          : AppBar(
              backgroundColor: Cores().corprincipal,
              title: Text("Escrever para:"),
            ),
      body: Row(
        children: [
          (MediaQuery.of(context).size.width > 850)
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                )
              : Container(),
          (opcao == 0)
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder<QuerySnapshot>(
                        stream:FirebaseFirestore.instance
                            .collection(Nomes().perfilbanco)
                            .where('unidade',
                                isEqualTo: widget.alunodoc['unidade'])
                            .where('chat', isEqualTo: true)
                        .where('cursos', arrayContainsAny: [widget.alunodoc['curso']])
                            .orderBy("perfil")
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return Text(
                                'Isto é um erro. Por gentileza, contate o suporte');
                          }

                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Container();
                            default:
                              return (snapshot.data!.docs.length >= 1)
                                  ? ListView(
                                      children: snapshot.data!.docs
                                          .map((DocumentSnapshot document) {
                                        return

                                          (document['perfil'] != 'Professor') ?
                                          Layout().itemdrawer(
                                            document['perfil'],
                                            Icons.edit,
                                            Mensagem(
                                              document['perfil'],
                                              widget.usuario,
                                              widget.alunodoc.id,
                                              widget.usuario.id,
                                              false,
                                              professor: '' as DocumentSnapshot,
                                            ),
                                            context) : Container();
                                      }).toList(),
                                    )
                                  : Container();
                          }
                        }),
                  ),
                )
              : Container(),
          (opcao == 1)
              ? Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<QuerySnapshot>(
                  stream:FirebaseFirestore.instance
                      .collection(Nomes().usersbanco)
                      .where('unidade',
                      isEqualTo: widget.alunodoc['unidade'])
                      .where('perfil',
                      isEqualTo: 'Professor')
                      .where('turma',
                      arrayContainsAny: [widget.alunodoc['turma']])
                      .orderBy("nome")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return Text(
                          'Isto é um erro. Por gentileza, contate o suporte');
                    }
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Container();
                      default:
                        return (snapshot.data!.docs.length >= 1)
                            ? ListView(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            return (List<String>.from(document['curso'])[0] == 'Todos' || List<String>.from(document['curso']).contains(widget.alunodoc['curso'])) ?
                              Layout().itemdrawer(
                                document['nome'],
                                Icons.edit,
                                Mensagem(
                                    document['perfil'],
                                    widget.usuario,
                                    widget.alunodoc.id,
                                    widget.usuario.id,
                                    false, professor: document,),
                                context) : Container();
                          }).toList(),
                        )
                            : Container();
                    }
                  }),
            ),
          )
              : Container(),
          (MediaQuery.of(context).size.width > 850)
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                )
              : Container(),
        ],
      ),
    );
  }
}



//region Description

botao1(){





}

//endregion




