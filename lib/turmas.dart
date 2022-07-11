import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scalifra/pesquisa.dart';

import 'turmasadd.dart';
import 'design.dart';
import 'layout.dart';

class Turmas extends StatefulWidget {
  final DocumentSnapshot usuario;
  final String unidade;

  Turmas(this.usuario, this.unidade);

  @override
  _TurmasState createState() => _TurmasState();
}

class _TurmasState extends State<Turmas> {
  List<String> unidades = [];
  String unidade='', curso='';
  List<String> cursos = ['EI', 'EF1', 'EF2', 'EM', 'CN'];

  @override
  void initState() {
    super.initState();
    if (widget.usuario['unidade'] == 'Todas as unidades') {
      buscarunidades();
    } else {
      unidade = widget.usuario['unidade'];
      unidades.add(widget.usuario['unidade']);
    }
    if (List<String>.from(widget.usuario['curso'])[0] != 'Todos') {
      cursos = List<String>.from(widget.usuario['curso']);
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().turmas);
  }

  buscarunidades() {
    FirebaseFirestore.instance
        .collection(Nomes().unidadebanco)
        .get()
        .then((unidadesDocs) {
      setState(() {
        unidades.addAll(
            unidadesDocs.docs.map((unidadeDoc) => unidadeDoc['unidade']));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbar("Turmas"),
      body: Row(
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    (unidades.length > 0)
                        ? Expanded(
                            flex: 1,
                            child: Layout().dropdownitem('Selecione a unidade',
                                unidade, mudarUnidade, unidades))
                        : Container(),
                    (unidade != null)
                        ? Expanded(
                            flex: 1,
                            child: Layout().dropdownitem(
                                'Selecione o curso', curso, mudarCurso, cursos))
                        : Container(),
                  ],
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(Nomes().turmabanco)
                        .where('unidade', isEqualTo: unidade)
                        .where('curso', isEqualTo: curso)
                        .orderBy("turma")
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
                                    return Layout().itemTurma(document,
                                        widget.usuario, null, context);
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
          (MediaQuery.of(context).size.width > 850)
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                )
              : Container(),
        ],
      ),
      floatingActionButton: floatingactionbar(Icons.add, "Incluir", context),
    );
  }

  Widget floatingactionbar(icon, tip, context) {
    return FloatingActionButton(
        backgroundColor: Cores().corprincipal,
        onPressed: () {
          floatingaction(context);
        },
        tooltip: tip,
        child: Icon(icon));
  }

  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
      curso = '';
    });
  }

  void mudarCurso(String text) {
    setState(() {
      curso = text;
    });
  }

  void floatingaction(context) {
    if (unidade == null || unidade == 'Todas as unidades') {
      Layout().dialog1botao(context, 'Unidade', 'Selecione a unidade');
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TurmasAdd(widget.usuario, '' as DocumentSnapshot, unidade)));
    }
  }
}
