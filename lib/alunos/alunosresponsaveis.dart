import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../design.dart';
import '../layout.dart';
import '../pesquisa.dart';
import 'incluirresponsavel.dart';

class AlunosResponsaveis extends StatefulWidget {
  final DocumentSnapshot aluno;

  AlunosResponsaveis(this.aluno);

  @override
  _AlunosResponsaveisState createState() => _AlunosResponsaveisState();
}

class _AlunosResponsaveisState extends State<AlunosResponsaveis> {

  @override
  void initState() {
    super.initState();
    Pesquisa().sendAnalyticsEvent(tela: Nomes().alunosRespons);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbarcombotaosimples((context) {
        Pesquisa().irpara(IncluirResponsavel(widget.aluno), context);
      },
          widget.aluno['nome'], 'Incluir Resp', context),
      body: Row(
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: <Widget>[
                    Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection(Nomes().usersbanco)
                                .where('alunos',
                                arrayContainsAny: [widget.aluno.id])
                                .orderBy('parentesco')
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
                                        .map((doc) {
                                      return Layout().itempai(
                                          null, doc, null, null, context);
                                    }).toList(),
                                  )
                                      : Container();
                              }
                            }))
                  ],
                ),
              ),
            ),
          ),
          Layout().espacolateral(context),
        ],
      ),
    );
  }
}
