import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'pesquisa.dart';
import 'design.dart';
import 'layout.dart';

class TurmasAdd extends StatefulWidget {
  DocumentSnapshot usuario, turmadoc;
  String unidade;
  TurmasAdd(this.usuario, this.turmadoc, this.unidade);

  @override
  _TurmasAddState createState() => _TurmasAddState();
}

class _TurmasAddState extends State<TurmasAdd> {


  TextEditingController turma = TextEditingController();
  String logo='';
  String curso='';
  List<String> cursos = ['EI', 'EF1', 'EF2','EM', 'CN'];
  List<String> turmas = [];

  @override
  void initState() {
    if (widget.turmadoc != null) {
      turma.text = widget.turmadoc['turma'];
    }
    FirebaseFirestore.instance.collection(Nomes().unidadebanco).doc(widget.unidade).get().then((value) {
      if(value.exists && value['logomenu'] != null){
        setState(() {
          logo = value['logomenu'];
        });
      }
    });

    super.initState();
  }

  buscarturmascurs(curs){
    FirebaseFirestore.instance.collection(Nomes().turmabanco)
        .where('unidade', isEqualTo: widget.unidade)
        .where('curso', isEqualTo: curs)
      .get()
        .then((value) {
       value.docs.forEach((element) {
         turmas.add(element['turma']);
       });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Layout()
          .appbarcombotaosimples(parasalvar, "Turma", "Salvar", context),
      body: Row(
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  (widget.unidade != null)
                      ? Layout().titulo(widget.unidade)
                      : Container(),
                  Layout().dropdownitem('Selecione o curso', curso, (text){
                    setState(() {
                    curso = text;
                    buscarturmascurs(curso);
                  });}, cursos),
                  Layout().caixadetexto(
                    1,
                    1,
                    TextInputType.text,
                    turma,
                    "Nome da Turma",
                    TextCapitalization.words,
                  ),
                ],
              ),
            ),
          ),
          Layout().espacolateral(context),
        ],
      ),
    );
  }

  void parasalvar(BuildContext context) {
    if (turma.text.isEmpty || curso == null) {
      Layout()
          .dialog1botao(context, "Nome da Turma e Curso", "Escreva o nome da turma e selecione o curso");
    } else if (turmas.contains(turma.text)){
      Layout()
          .dialog1botao(context, "Turma já Existe", "Esta turma já existe. Por favor, verifique.");
    }



    else if (turma.text != null && turma.text.isNotEmpty) {
      Map<String, dynamic> map = Map();
      map['turma'] = turma.text.trim();
      if(logo != null){
        map['logo'] = logo;
      }
      map['unidade'] = widget.unidade;
      map['curso'] = curso;
      map['responsavel'] = widget.usuario['nome'];
      map['data'] = Pesquisa().getDataeHora();
      Pesquisa().salvarfirebase(Nomes().turmabanco, map, null, null);
      Pesquisa().sendAnalyticsEvent(tela: Nomes().turmasAdd);
      Layout().dialog1botaofecha2(context, 'Turma Salva', 'A turma foi salva');
    }
  }
}
