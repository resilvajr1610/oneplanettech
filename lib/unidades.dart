import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scalifra/turmas.dart';

import 'pesquisa.dart';
import 'unidadesadd.dart';
import 'design.dart';
import 'layout.dart';

class Unidades extends StatefulWidget {
  final DocumentSnapshot usuario;
  Unidades(this.usuario);

  @override
  State<Unidades> createState() => _UnidadesState();
}

class _UnidadesState extends State<Unidades> {
  @override
  void initState() {
    super.initState();
    Pesquisa().sendAnalyticsEvent(tela: Nomes().unidadebanco);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbar("Unidades"),
      body: Row(
        children: [
          (MediaQuery.of(context).size.width > 850) ? SizedBox(width: MediaQuery.of(context).size.width*0.2,): Container(),
          Expanded(
            child: Column(
              children: <Widget>[
                (widget.usuario['unidade'] != null && widget.usuario['unidade'] != 'Todas as unidades') ?
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(Nomes().unidadebanco)
                        .where('unidade', isEqualTo: widget.usuario['unidade'])
                        .orderBy("unidade")
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Container();
                        default:
                          return (snapshot.data!.docs.length >= 1)
                              ? ListView(
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              return Layout().itemUnidade(document, widget.usuario, context);
                            }).toList(),
                          )
                              : Container();
                      }
                    },
                  ),
                )
                 :
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(Nomes().unidadebanco)
                        .orderBy("unidade")
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Container();
                        default:
                          return (snapshot.data!.docs.length >= 1)
                              ? ListView(
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              return Layout().itemUnidade(document, widget.usuario,  context);
                            }).toList(),
                          )
                              : Container();
                      }
                    },
                  ),
                )
              ],
            ),
          ),
          (MediaQuery.of(context).size.width > 850) ? SizedBox(width: MediaQuery.of(context).size.width*0.2,): Container(),
        ],
      ),
      floatingActionButton:
     floatingactionbar( Icons.add, "Incluir", context),
    );
  }

  Widget floatingactionbar( icon, tip, context) {
    return FloatingActionButton(
        backgroundColor: Cores().corprincipal,
        onPressed: (){
          floatingaction(context);
        } ,
        tooltip: tip,
        child: Icon(icon));
  }

  void floatingaction(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => UnidadesAdd(widget.usuario, '' as DocumentSnapshot)));
  }
}

