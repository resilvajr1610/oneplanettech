import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scalifra/chat/menumensagem.dart';

import 'layout.dart';
import 'design.dart';
import 'pesquisa.dart';

class MensagemIntra extends StatefulWidget {
  final DocumentSnapshot usuario;

  MensagemIntra(this.usuario);

  @override
  _MensagemIntraState createState() => _MensagemIntraState();
}

class _MensagemIntraState extends State<MensagemIntra> {
  String palavrapesquisada='', unidade='';
  List<String> unidades = [];


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
    Pesquisa().sendAnalyticsEvent(tela: Nomes().mensagensinternasbanco);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbar("Para quem?"),
      body: Row(
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Layout().dropdownitem(
                            'Selecione a unidade',
                            unidade,
                            mudarUnidade,
                            unidades)),

                  ],
                ),
                Layout().campopesquisa((text){setState(() {
                  palavrapesquisada = text;
                });}),
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection(Nomes().usersbanco)
                    .where('unidade', isEqualTo: unidade)
                        .where('controle', isEqualTo: Nomes().controle)
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
                              if (doc['email'] != 'elaine@master.com') {
                                  return Layout().msgIntra(widget.usuario, doc, palavrapesquisada, context);
                              }
                              return Container();
                            }).toList(),
                          );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Layout().espacolateral(context),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Cores().corprincipal,
        onPressed: () {
          Navigator.pop(context);
          Pesquisa().irpara(MenuMensagem(widget.usuario), context);
        },
        child: new Icon(
          Icons.chat,
          color: Colors.white,
        ),
      ),
    );
  }

  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
    });
  }
}
