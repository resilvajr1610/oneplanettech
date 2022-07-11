import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'design.dart';
import 'horarioadd.dart';
import 'layout.dart';
import 'pesquisa.dart';

class Horario extends StatefulWidget {
  DocumentSnapshot usuario, alunodoc;
  bool controle, horariotrabalho;

  Horario(this.usuario, this.controle, this.horariotrabalho, this.alunodoc);

  @override
  _HorarioState createState() => _HorarioState();
}

class _HorarioState extends State<Horario> {
  String turma='';
  List<String> turmas = [];
  String unidade='';
  List<String> unidades = [];
  List<String> cursos  = ['EI', 'EF1', 'EF2','EM', 'CN'];
  String curso='';
  List<String> parametrosbusca = [];

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
        unidades.add(widget.usuario['unidade']);
      }
      if(List<String>.from(widget.usuario['curso'])[0] != 'Todos') {
        cursos = List<String>.from(widget.usuario['curso']);
      }
      if(List<String>.from(widget.usuario['turma'])[0] != 'Todas') {
        turmas = List<String>.from(widget.usuario['turma']);
      }
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().horariosescola);
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

  void buscarcursos() {
    FirebaseFirestore.instance
        .collection('Funcionalidades')
        .doc(unidade)
        .get()
        .then((value) {
      setState(() {
        cursos = List<String>.from(value['horarios']);
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
        title: Text("Horários"),
        actions: <Widget>[
          (widget.controle && widget.horariotrabalho && widget.usuario['perfil']!= 'Professor')
              ? FlatButton(
            textColor: Colors.white,
            onPressed: () {
              parasalvar(context);
            },
            child: Text(
              "Editar",
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
          (MediaQuery.of(context).size.width > 850)
              ? SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
          )
              : Container(),
          Expanded(
            child: Column(
              children: <Widget>[
                (widget.controle)
                    ? Row(
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
                )
                    : Container(),

                (parametrosbusca.isNotEmpty) ? Expanded(
                  child:  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection(Nomes().horariosescola)
                        .where('parametrosbusca', arrayContainsAny: parametrosbusca)
                        .orderBy("createdAt", descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text(
                            'Isto é um erro. Por gentileza, contate o suporte.');
                      }
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Container();
                          break;
                        default:
                          return ListView(
                            children: snapshot.data!.docs.map((doc) {
                              return Layout().itemCardapio(
                                  doc, widget.controle,  widget.usuario, 0.4, 'horarios', context);
                            }).toList(),
                          );
                      }
                    },
                  )
                ) : Container(),
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

  void parasalvar(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HorarioAdd(widget.usuario)));
  }

  void mudarCurso(String text) {
    setState(() {
      curso = text;
      parametrosbusca = [curso + ' - ' + unidade];
    });
    turma = '';
    if (List<String>.from(widget.usuario['turma'])[0] == 'Todas') {
      buscarturmas(unidade, curso);
    }
  }

  void mudarTurma(String text) {
    setState(() {
      turma = text;
      parametrosbusca = [ turma + ' - ' + unidade];
    });
  }

  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
      parametrosbusca = [unidade];
    });
    curso = '';
    turma = '';
    buscarcursos();

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
}
