import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


import '../pesquisa.dart';
import 'cuidadosimagem.dart';
import '../design.dart';
import '../layout.dart';

class Cuidados extends StatefulWidget {
  final DocumentSnapshot usuario;

  Cuidados(this.usuario);

  @override
  _CuidadosState createState() => _CuidadosState();
}

class _CuidadosState extends State<Cuidados> {

  String turma='', unidade='';
  List<String> turmas = [];
  List<String> unidades = [];

  @override
  void initState() {
    Pesquisa().sendAnalyticsEvent(tela: Nomes().cuidadosEducacaoInfantil);
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
    if (List<String>.from(widget.usuario['turma'])[0] != 'Todas') {
      turmas = List<String>.from(widget.usuario['turma']);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Layout().appbarcombotaosimples(parasalvar, 'Cuidados', 'Por Imagem', context),
      body: Row(
        children: [
          (MediaQuery.of(context).size.width > 850) ? SizedBox(width: MediaQuery.of(context).size.width*0.2,): Container(),
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
                    (turmas.isNotEmpty) ?   Expanded(
                        flex: 1,
                        child: Layout().dropdownitem(
                            'Selecione a turma',
                            turma,
                            mudarTurma,
                            turmas)): Container()
                  ],
                ),
                (unidade != null && turma != null)
                    ?   Expanded(
                  child:  StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection(Nomes().alunosbanco)
                              .where('ano',
                              arrayContainsAny: [Pesquisa().getAno()])
                              .where("unidade", isEqualTo: unidade)
                              .where("turma", isEqualTo: turma) 
                              .orderBy("nome")
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            return listamain(snapshot, context);
                          }),
                ): Container(),
              ],
            ),
          ),
          (MediaQuery.of(context).size.width > 850) ? SizedBox(width: MediaQuery.of(context).size.width*0.2,): Container(),
        ],
      ),
    );
  }
  buscarturmas(uni) {
    turmas.clear();
    FirebaseFirestore.instance
        .collection(Nomes().turmabanco)
        .where('unidade', isEqualTo: uni)
        .where('curso', isEqualTo: 'EI')
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

  void mudarTurma(String text) {
    setState(() {
      turma = text;
    });

  }
  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
    });
    if(List<String>.from(widget.usuario['turma'])[0] == 'Todas'){
      buscarturmas(unidade);}
    turma = '';
  }

  void parasalvar(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => CuidadosImagem()));
  }


  StatelessWidget listamain(
      AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
    if (snapshot.hasError) return Text('Error: ${snapshot.error}');
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return Container();
      default:
        return (snapshot.data!.docs.length >= 1)
            ? ListView(
                children:
                    snapshot.data!.docs.map((DocumentSnapshot document) {
                  return Layout().itemCuidadoIncluir(document, widget.usuario, context);
                }).toList(),
              )
            : Container();
    }
  }
}
