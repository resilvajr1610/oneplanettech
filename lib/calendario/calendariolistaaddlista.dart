import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:multiple_select/multi_drop_down.dart';
// import 'package:multiple_select/multiple_select.dart';
import 'package:scalifra/pesquisa.dart';

import '../design.dart';
import '../layout.dart';

class CalendarioListaAddLista extends StatefulWidget {
  final DocumentSnapshot usuario;

  const CalendarioListaAddLista(this.usuario);

  @override
  _CalendarioListaAddListaState createState() => _CalendarioListaAddListaState();
}

class _CalendarioListaAddListaState extends State<CalendarioListaAddLista> {
  TextEditingController lista = TextEditingController();

  late DateTime datacomparar;
  String unidade='', data='', hora='', titulo='', horastring='', minutos='';

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

  @override
  void dispose() {
    super.dispose();
    lista.dispose();
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
      appBar: Layout().appbar('Lista de Eventos'),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (MediaQuery.of(context).size.width > 850)
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                )
              : Container(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Layout().segmented(opcoes, opcao, mudardosegmento, context),
                  // (opcao == 0 &&
                  //         unidadesmultiple != null &&
                  //         widget.usuario['unidade'] == "Todas as unidades")
                  //     ? MultipleDropDown(
                  //         placeholder: 'Selecione a(s) unidades(s)',
                  //         disabled: false,
                  //         values: unidadesselecionadas,
                  //         elements: unidadesmultiple,
                  //       )
                  //     : Container(),
                  (opcao == 0 &&
                          widget.usuario['unidade'] != "Todas as unidades" &&
                          List<String>.from(widget.usuario['curso'])[0] ==
                              'Todos')
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
                    child: Layout().texto(
                      'Escreva a lista separada por "-" e finalize cada linha com ";"\nSiga os exemplos abaixos:\n20/02/2021 - 16h00 - Reunião de Pais;\n20/02/2021 - 00h00 - Reunião de Pais;',
                      16,
                      FontWeight.normal,
                      Cores().corprincipal,
                      maxLines: 1,
                      textDecoration: TextDecoration.none,
                      overflow: TextOverflow.ellipsis,
                      height: 5,
                      align: TextAlign.center
                    ),
                  ),
                  Layout().caixadetexto(5, null, TextInputType.multiline, lista,
                      'Lista de Eventos', TextCapitalization.sentences),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  (opcao == 0 &&
                          widget.usuario['perfil'] != 'Professor' &&
                          List<String>.from(widget.usuario['curso'])[0] ==
                              'Todos')
                      ? botaosalvar(context)
                      : Container(),
                  (opcao == 1 && widget.usuario['perfil'] != 'Professor')
                      ? botaosalvar(context)
                      : Container(),
                  (opcao == 2) ? botaosalvar(context) : Container(),
                ],
              ),
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

  Widget botaosalvar(context) {
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
      curso = '';
    });
  }

  void salvar(BuildContext context) {
    if (lista.text.isEmpty) {
      Layout().dialog1botao(context, 'Eventos', 'Escreva a lista de eventos');
    } else if (!lista.text.contains(';')) {
      Layout().dialog1botao(context, 'Ponto e virgula',
          'Cada linha de evento deve finalizar com ;');
    } else if (opcao == 0 &&
        unidadesselecionadas.length == 0 &&
        widget.usuario['unidade'] == "Todas as unidades") {
      Layout().dialog1botao(context, "Unidade", "Selecione a unidade");
    } else if (opcao == 1 && curso == null) {
      Layout().dialog1botao(context, "Curso", "Selecione o curso");
    } else if (opcao == 2 && turmasselecionadas.length == 0) {
      Layout().dialog1botao(context, "Turma", "Selecione a turma");
    } else {
      separarEventos();
    }
  }

  void salvarEventoIndividual(BuildContext context) {
    if (opcao == 0) {
      if (widget.usuario['unidade'] != "Todas as unidades") {
        Map<String, dynamic> map = Map();
        map['data'] = data;
        map['hora'] = hora;
        map['evento'] = titulo;
        map['datacomparar'] = datacomparar;
        map['responsavel'] = widget.usuario['nome'];
        map['parametrosbusca'] = [widget.usuario['unidade']];

        Pesquisa().enviarnotificacao(
            Pesquisa().replaceforpush(widget.usuario['unidade']),
            'Novo envento adicionado - ${data}');
        Pesquisa().salvarfirebase('Calendario', map, null, null);
      } else if (unidadesselecionadas.contains(0)) {
        Map<String, dynamic> map = Map();
        map['data'] = data;
        map['hora'] = hora;
        map['evento'] = titulo;
        map['datacomparar'] = datacomparar;
        map['responsavel'] = widget.usuario['nome'];
        map['parametrosbusca'] = ['Todas'];

        Pesquisa().enviarnotificacao(Pesquisa().replaceforpush(Nomes().push),
            'Novo envento adicionado - ${data}');
        Pesquisa().salvarfirebase('Calendario', map, null, null);
      } else {
        Map<String, dynamic> map = Map();
        map['data'] = data;
        map['hora'] = hora;
        map['evento'] = titulo;
        map['datacomparar'] = datacomparar;
        map['parametrosbusca'] = [unidade];
        map['responsavel'] = widget.usuario['nome'];

        Pesquisa().salvarcalendariounidades(map,
            unidadesSelecionadas: unidades, indexturmas: unidadesselecionadas);
      }
    }

    if (opcao == 1) {
      Map<String, dynamic> map = Map();
      map['data'] = data;
      map['hora'] = hora;
      map['evento'] = titulo;
      map['datacomparar'] = datacomparar;
      map['responsavel'] = widget.usuario['nome'];
      map['parametrosbusca'] = [curso + ' - ' + unidade];

      Pesquisa().enviarnotificacao(Pesquisa().replaceforpush(curso + unidade),
          'Novo envento adicionado - ${data}');
      Pesquisa().salvarfirebase('Calendario', map, null, null);
    }

    if (opcao == 2) {
      Map<String, dynamic> map = Map();
      map['data'] = data;
      map['hora'] = hora;
      map['evento'] = titulo;
      map['datacomparar'] = datacomparar;
      map['responsavel'] = widget.usuario['nome'];

      Pesquisa().salvarcalendarioturmas(map, unidade,
          turmasSelecionadas: turmas, indexturmas: turmasselecionadas);
    }
  }

  void separarEventos() {
    String listastring = lista.text.trim();
    List linhaseventos = listastring.split(';');
    linhaseventos.remove('');
    linhaseventos.forEach((evento) {
      String ev = evento;
      List elementosEventos = ev.split('-');
      if (elementosEventos.length != 3) {
        Layout().dialog1botao(context, 'Confira o formato da linha do evento',
            'Siga o modelo:\ndata - hora - evento;\n\nCaso não tenha hora, substitua com X.\nSiga os exemplos abaixos:\n20/02/2021 - 16h00 - Reunião de Pais;\n20/02/2021 - xxhxx - Reunião de Pais;');
        return;
      } else {
        data = elementosEventos[0].toString().trim();

        List elementosdia = data.split('/');

        if (elementosdia.length != 3) {
          Layout().dialog1botao(context, 'Confira a data',
              "A data deve seguir o seguinte formato:\nDD/MM/AAA");
          return;
        }
        String ano = elementosdia[2].toString().trim();
        String mes = elementosdia[1].toString().trim();
        String dia = elementosdia[0].toString().trim();

        hora = elementosEventos[1].toString().trim().toLowerCase();
        titulo = elementosEventos[2].toString().trim();

        if (hora.toLowerCase().contains('x')) {
          hora = '';
        } else {
          List elementoshora = hora.split('h');
          horastring = elementoshora[0].toString().trim();
          minutos = elementoshora[1].toString().trim();
        }
        datacomparar = DateTime(int.parse(ano), int.parse(mes), int.parse(dia),
            int.parse(horastring), int.parse(minutos));

        salvarEventoIndividual(context);
        if (evento == linhaseventos.last) {
          Layout().dialog1botaofecha2(
              context, 'Salvo', 'Os eventos foram registrados');
        }
      }
    });
  }
}
