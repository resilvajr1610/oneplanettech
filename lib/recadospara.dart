import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scalifra/recadosadd.dart';

import 'design.dart';
import 'layout.dart';

class RecadosPara extends StatefulWidget {
  DocumentSnapshot alunodoc;
  RecadosPara(this.alunodoc);
  @override
  _RecadosParaState createState() => _RecadosParaState();
}

class _RecadosParaState extends State<RecadosPara> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbar('Recado para:'),
      body: Row(
        children: [
          (MediaQuery.of(context).size.width > 850)
              ? SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
          )
              : Container(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(Nomes().usersbanco)
                      .where('unidade',
                      isEqualTo: widget.alunodoc['unidade'])
                      .where('perfil',
                      isEqualTo: 'Professor')
                      .where('turma',
                      arrayContainsAny: [widget.alunodoc['turma'] , 'Todas'])
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
                               RecadosAdd(widget.alunodoc, '' as DocumentSnapshot, document),
                                context) : Container();
                          }).toList(),
                        )
                            : Container();
                    }
                  })
            ),
          )
              ,
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
