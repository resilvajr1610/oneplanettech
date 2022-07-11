import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:multiple_select/multi_drop_down.dart';
// import 'package:multiple_select/multiple_select.dart';
import 'package:scalifra/calendario/calendariolistaaddlista.dart';

import '../design.dart';
import '../layout.dart';
import '../pesquisa.dart';

class AgendaAdd extends StatefulWidget {
  final DocumentSnapshot usuario, alunodoc;
  final bool controle;

  AgendaAdd(this.usuario, this.alunodoc, this.controle);

  @override
  _AgendaAddState createState() => _AgendaAddState();
}

class _AgendaAddState extends State<AgendaAdd> {
  TextEditingController data = TextEditingController();
  TextEditingController hora = TextEditingController();
  TextEditingController titulo = TextEditingController();
  late DateTime datacomparar;
  String unidade='';

  int opcao = 0;
  Map<int, Widget> opcoes = const <int, Widget>{
    0: Text("Unidades"),
    1: Text("Cursos"),
    2: Text("Turmas"),
  };

  List<String> turmas = [];
  List<String> unidades = [];
  Map<String, dynamic> alunosid = Map();
  List unidadesselecionadas = [];
  // List<MultipleSelectItem> unidadesmultiple=[];
  List turmasselecionadas = [];
  // List<MultipleSelectItem> turmasmultiple=[];
  String curso='';
  List<String> cursos = ['EI', 'EF1', 'EF2', 'EM', 'CN'];

  @override
  void initState() {
    super.initState();

    if (widget.controle) {
      if (widget.usuario['unidade'] == 'Todas as unidades') {
        buscarunidades();
      } else {
        unidade = widget.usuario['unidade'];
      }
      if (List<String>.from(widget.usuario['curso'])[0] != 'Todos') {
        cursos = List<String>.from(widget.usuario['curso']);
      }
      if (List<String>.from(widget.usuario['turma'])[0] != 'Todas') {
        turmas = List<String>.from(widget.usuario['turma']);
        setState(() {
          // turmasmultiple = List.generate(
          //   turmas.length,
          //   (index) => MultipleSelectItem.build(
          //     value: index,
          //     display: '${turmas[index]}',
          //     content: '${turmas[index]}',
          //   ),
          // );
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    data.dispose();
    hora.dispose();
    titulo.dispose();
  }

  void buscarturmas(uni, curs) {
    turmas.clear();
    FirebaseFirestore.instance
        .collection(Nomes().turmabanco)
        .where('unidade', isEqualTo: uni)
        .where('curso', isEqualTo: curs)
        .orderBy("turma")
      .get()
        .then((documents) {
      documents.docs.forEach((doc) {
        setState(() {
          turmas.add(doc['turma']);
        });
        setState(() {
          // turmasmultiple = List.generate(
          //   turmas.length,
          //   (index) => MultipleSelectItem.build(
          //     value: index,
          //     display: '${turmas[index]}',
          //     content: '${turmas[index]}',
          //   ),
          // );
        });
      });
    });
  }

  void buscarunidades() {
    unidades.add("Todas");
    FirebaseFirestore.instance
        .collection(Nomes().unidadebanco)
        .orderBy("unidade")
      .get()
        .then((documents) {
      documents.docs.forEach((doc) {
        setState(() {
          unidades.add(doc['unidade']);
        });
        setState(() {
          // unidadesmultiple = List.generate(
          //   unidades.length,
          //   (index) => MultipleSelectItem.build(
          //     value: index,
          //     display: '${unidades[index]}',
          //     content: '${unidades[index]}',
          //   ),
          // );
        });
      });
    });
  }

  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Layout().appbarcombotaosimples((context){
        Navigator.pop(context);
        Pesquisa().irpara(CalendarioListaAddLista(widget.usuario), context);
      }, 'Adicionar Evento', widget.controle ? 'Lista' : '', context),
      body: Row(
        children: [
          (MediaQuery.of(context).size.width > 850)
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                )
              : Container(),
          Expanded(
            child: Column(
              children: [
                (widget.controle)
                    ? Layout()
                        .segmented(opcoes, opcao, mudardosegmento, context)
                    : Container(),
                // ( opcao == 0 && widget.controle &&
                    // //     unidadesmultiple != null &&
                    // //     widget.usuario['unidade'] == "Todas as unidades")
                    // // ? MultipleDropDown(
                    // //     placeholder: 'Selecione a(s) unidades(s)',
                    // //     disabled: false,
                    // //     values: unidadesselecionadas,
                    // //     elements: unidadesmultiple,
                    // //   )
                    // : Container(),
                (opcao == 0 && widget.controle &&
                        widget.usuario['unidade'] != "Todas as unidades" &&
                    List<String>.from(widget.usuario['curso'])[0] == 'Todos')
                    ? Layout().titulo(widget.usuario['unidade'])
                    : Container(),
                (opcao == 1 && widget.usuario['perfil'] != 'Professor')
                    ? Row(
                        children: [
                          (widget.usuario['unidade'] == "Todas as unidades")
                              ? Flexible(
                                  flex: 1,
                                  child: Layout().dropdownitem(
                                      "Selecione a unidade",
                                      unidade,
                                      mudarUnidade,
                                      unidades),
                                )
                              : Container(),
                          (unidade != null && unidade != 'Todas')
                              ? Flexible(
                                  flex: 1,
                                  child: Layout().dropdownitem(
                                      "Selecione o curso",
                                      curso,
                                      mudarCurso,
                                      cursos),
                                )
                              : Container()
                        ],
                      )
                    : Container(),
                (opcao == 2)
                    ? Row(
                        children: [
                          (widget.usuario['unidade'] == "Todas as unidades")
                              ? Flexible(
                                  flex: 1,
                                  child: Layout().dropdownitem(
                                      "Selecione a unidade",
                                      unidade,
                                      mudarUnidade,
                                      unidades),
                                )
                              : Container(),
                          (unidade != null && unidade != 'Todas')
                              ? Flexible(
                                  flex: 1,
                                  child: Layout().dropdownitem(
                                      "Selecione o curso",
                                      curso,
                                      mudarCurso,
                                      cursos),
                                )
                              : Container(),
                          // (turmasmultiple != null)
                          //     ? Flexible(
                          //         flex: 1,
                          //         child: MultipleDropDown(
                          //           placeholder: 'Selecione a(s) turma(s)',
                          //           disabled: false,
                          //           values: turmasselecionadas,
                          //           elements: turmasmultiple,
                          //         ),
                          //       )
                          //     : Container(),
                        ],
                      )
                    : Container(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text("Data: "),
                          GestureDetector(
                              onTap: () {
                                escolherprazo(context);
                              },
                              child: Layout().titulo(data.text)),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text("Hora: "),
                          GestureDetector(
                              onTap: () {
                                selecionarhorario(context);
                              },
                              child: Layout().titulo(hora.text)),
                        ],
                      ),
                    ],
                  ),
                ),
                Layout().caixadetexto(1, 3, TextInputType.text, titulo,
                    'Evento', TextCapitalization.sentences),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                (opcao == 0 && widget.controle && widget.usuario['perfil'] != 'Professor' && List<String>.from(widget.usuario['curso'])[0] == 'Todos') ?
                    botaosalvar(context) : Container(),
                (opcao == 1 && widget.usuario['perfil'] != 'Professor') ?
                botaosalvar(context) : Container(),
                (opcao == 2) ? botaosalvar(context): Container(),
                  (!widget.controle) ? botaosalvar(context): Container()
              ],
            ),
          ),
          (MediaQuery.of(context).size.width > 850)
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                )
              : Container(),
        ],
      ),
    );
  }
  Widget botaosalvar(context){
   return FlatButton(
      color: Cores().corprincipal,
      onPressed: () {
        salvar(context);
      },
      child: Text(
        'Salvar',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void mudarCurso(String text) {
    setState(() {
      curso = text;
    });
    if (opcao == 2 &&
        List<String>.from(widget.usuario['turma'])[0] == 'Todas') {
      buscarturmas(unidade, curso);
    }
  }

  void mudardosegmento(val) {
    setState(() {
      opcao = val;
      curso ='';
    });
  }

  void salvar(BuildContext context) {
    if (datacomparar == null) {
      Layout().dialog1botao(context, 'Data', 'Selecione a data');
    } else if (titulo.text.isEmpty) {
      Layout().dialog1botao(context, 'Evento', 'Escreva o evento');
    } else if (widget.controle) {
      if (opcao == 0 &&
          List<String>.from(widget.usuario['curso'])[0] == 'Todos' &&
          widget.usuario['perfil'] != 'Professor') {
        if (unidadesselecionadas.length == 0 &&
            widget.usuario['unidade'] == "Todas as unidades") {
          Layout().dialog1botao(context, "Unidade", "Selecione a unidade");
        } else if (widget.usuario['unidade'] != "Todas as unidades") {
          Layout()
              .dialog1botaofecha2(context, 'Salvo', 'O evento foi registrado');
          Map<String, dynamic> map = Map();
          map['data'] = data.text;
          map['datacomparar'] = datacomparar;
          map['hora'] = hora.text;
          map['responsavel'] = widget.usuario['nome'];
          map['parametrosbusca'] = [widget.usuario['unidade']];
          map['evento'] = titulo.text;
          Pesquisa().enviarnotificacao(Pesquisa().replaceforpush(widget.usuario['unidade']), 'Novo envento adicionado - ${data.text}');
          Pesquisa().salvarfirebase('Calendario', map, null, null);

        } else if (unidadesselecionadas.contains(0)) {
          Layout()
              .dialog1botaofecha2(context, 'Salvo', 'O evento foi registrado');
          Map<String, dynamic> map = Map();
          map['data'] = data.text;
          map['datacomparar'] = datacomparar;
          map['hora'] = hora.text;
          map['responsavel'] = widget.usuario['nome'];
          map['parametrosbusca'] = ['Todas'];
          map['evento'] = titulo.text;
          Pesquisa().enviarnotificacao(Pesquisa().replaceforpush(Nomes().push), 'Novo envento adicionado - ${data.text}');
          Pesquisa().salvarfirebase('Calendario', map, null, null);

        } else {
          Layout()
              .dialog1botaofecha2(context, 'Salvo', 'O evento foi registrado');
          Map<String, dynamic> map = Map();
          map['data'] = data.text;
          map['datacomparar'] = datacomparar;
          map['hora'] = hora.text;
          map['responsavel'] = widget.usuario['nome'];
          map['evento'] = titulo.text;
          Pesquisa().salvarcalendariounidades(map,
              unidadesSelecionadas: unidades,
              indexturmas: unidadesselecionadas);

        }
      }

      if (opcao == 1) {
        if (curso == null) {
          Layout().dialog1botao(context, "Curso", "Selecione o curso");
        } else {
          Layout()
              .dialog1botaofecha2(context, 'Salvo', 'O evento foi registrado');
          Map<String, dynamic> map = Map();
          map['data'] = data.text;
          map['datacomparar'] = datacomparar;
          map['hora'] = hora.text;
          map['responsavel'] = widget.usuario['nome'];
          map['parametrosbusca'] = [curso + ' - ' + unidade];
          map['evento'] = titulo.text;
          Pesquisa().enviarnotificacao(Pesquisa().replaceforpush(curso + unidade), 'Novo envento adicionado - ${data.text}');
          Pesquisa().salvarfirebase('Calendario', map, null, null);

        }
      }

      if (opcao == 2) {
        if (turmasselecionadas.length == 0) {
          Layout().dialog1botao(context, "Turma", "Selecione a turma");
        } else {
          Layout()
            .dialog1botaofecha2(context, 'Salvo', 'O evento foi registrado');
          Map<String, dynamic> map = Map();
          map['data'] = data.text;
          map['datacomparar'] = datacomparar;
          map['hora'] = hora.text;
          map['responsavel'] = widget.usuario['nome'];
          map['evento'] = titulo.text;
          Pesquisa().salvarcalendarioturmas(map, unidade,
              turmasSelecionadas: turmas, indexturmas: turmasselecionadas);

        }
      }
    } else {
      Layout()
          .dialog1botaofecha2(context, 'Salvo', 'O evento foi registrado');
      Map<String, dynamic> map = Map();
      map['data'] = data.text;
      map['datacomparar'] = datacomparar;
      map['hora'] = hora.text;
      map['parametrosbusca'] = [widget.alunodoc.id];
      map['evento'] = titulo.text;
      Pesquisa().salvarfirebase('Calendario', map, null, null);

    }

  }

  void selecionarhorario(BuildContext context) {
    Future<TimeOfDay?> selectedDate = showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    selectedDate.then((time) {
      if (time != null) {
        setState(() {
          hora.text =
              Pesquisa().formatHora(hour: time.hour, minute: time.minute);
              datacomparar = datacomparar.add(Duration(hours: time.hour,minutes: time.minute));
        });
      }
    });
  }

  escolherprazo(BuildContext context) async {
    var pickDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2040));
    if (pickDate != null) {
      setState(() {
        datacomparar = pickDate;
        data.text = Pesquisa().formatData(
            year: pickDate.year, month: pickDate.month, day: pickDate.day);
      });
    }
  }
}
