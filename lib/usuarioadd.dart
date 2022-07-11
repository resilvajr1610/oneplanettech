import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scalifra/itens/itemcheckbox.dart';

import 'design.dart';
import 'layout.dart';
import 'pesquisa.dart';

class UsuarioAdd extends StatefulWidget {
  final DocumentSnapshot usuario, funcionario;

  UsuarioAdd(this.usuario, this.funcionario);

  @override
  _UsuarioAddState createState() => _UsuarioAddState();
}

class _UsuarioAddState extends State<UsuarioAdd> {
  String turma='',
      perfil='',
      horainicio='',
      horafim='',
      horainicio2='',
      horafim2='',
      horainicio3='',
      horafim3='';
  List<String> turmas = [];
  List<String> turmasselecionadas = [];
  List<String> diassemana = [];
  List<String> cursosselecionados = [];
  List<String> perfisselecionados = [];
  List<String> perfis = [];
  List<String> perfissemproprio = [];
  TextEditingController nome = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController codigofuncionario = TextEditingController();
  List<String> unidades = [];
  String unidade='';
  List<String> cursos = ['Todos', 'EI', 'EF1', 'EF2', 'EM', 'CN'];
  String curso='';

  @override
  void initState() {
    super.initState();

    if (widget.usuario['unidade'] == 'Todas as unidades') {
      buscarunidades();
    } else {
      setState(() {
        unidade = widget.usuario['unidade'];
      });
      if (widget.funcionario == null) {
        buscarperfis(unidade);
        buscarturmas(unidade);
      }
    }
    if (widget.funcionario != null) {
      unidade = widget.funcionario['unidade'];
      horainicio = widget.funcionario['horainicio'];
      horafim = widget.funcionario['horafim'];
      horainicio2 = widget.funcionario['horainicio2'];
      horafim2 = widget.funcionario['horafim2'];
      horainicio3 = widget.funcionario['horainicio3'];
      horafim3 = widget.funcionario['horafim3'];
      nome.text = widget.funcionario['nome'];
      email.text = widget.funcionario['email'];
      codigofuncionario.text = widget.funcionario['codigo'];
      buscarperfis(unidade);
      buscarturmas(unidade);
      perfil = widget.funcionario['perfil'];

      if (widget.funcionario['curso'] != null) {
        cursosselecionados = List<String>.from(widget.funcionario['curso']);
      }
      if (widget.funcionario['turma'] != null) {
        turmasselecionadas = List<String>.from(widget.funcionario['turma']);
      }
      if (widget.funcionario['visualizarChat'] != null) {
        perfisselecionados = List<String>.from(widget.funcionario['visualizarChat']);
      }
      if (widget.funcionario['diasdasemana'] != null) {
        diassemana = List<String>.from(widget.funcionario['diasdasemana']);
      }
      removerPerfilPropriodaLista();
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().usuarioAdd);
  }

  buscarunidades() {
    unidades.add('Todas as unidades');
    FirebaseFirestore.instance
        .collection(Nomes().unidadebanco)
        .get()
        .then((docs) {
      docs.docs.forEach((doc) {
        setState(() {
          unidades.add(doc['unidade']);
        });
      });
    });
  }

  buscarturmas(uni) {
    turmas.clear();
    turmas.add('Todas');
    FirebaseFirestore.instance
        .collection(Nomes().turmabanco)
        .where('unidade', isEqualTo: uni)
        .orderBy('turma')
        .get()
        .then((docs) {
      docs.docs.forEach((doc) {
        setState(() {
          turmas.add(doc['turma']);
        });
      });
    });
  }

  buscarperfis(uni) {
    FirebaseFirestore.instance
        .collection(Nomes().perfilbanco)
        .where('unidade', isEqualTo: uni)
        .orderBy('perfil')
        .get()
        .then((docs) {
      docs.docs.forEach((doc) {
        setState(() {
          perfis.add(doc['perfil']);
        });
        if (perfis.length > 3) {
          removerPerfilPropriodaLista();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: (widget.funcionario != null)
          ? Layout().appbarcombotaosimples(parasalvar, " ", "Salvar", context,
              deletar: true, userid: widget.funcionario.id)
          : Layout().appbarcombotaosimples(parasalvar, " ", "Salvar", context,deletar: false,userid: ''),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    (widget.usuario['unidade'] == 'Todas as unidades' &&
                            unidades.isNotEmpty &&
                            (unidade == null || unidades.contains(unidade)))
                        ? Layout().dropdownitem('Selecione a unidade', unidade,
                            mudarUnidade, unidades)
                        : Container(),
                    (widget.usuario['unidade'] != 'Todas as unidades' ||
                            unidade != null)
                        ? Column(
                            children: [
                              Layout().secao("Perfil", Colors.lightBlue),
                              (perfis.isNotEmpty &&
                                      (perfil == null ||
                                          perfis.contains(perfil)))
                                  ? Layout().dropdownitem("Selecione o Perfil",
                                      perfil, mudarPerfil, perfis)
                                  : Container(),
                              Layout().titulo("Nome:"),
                              Layout().caixadetexto(
                                1,
                                1,
                                TextInputType.text,
                                nome,
                                "Escreva o nome",
                                TextCapitalization.words,
                              ),
                              Layout().caixadetexto(
                                1,
                                1,
                                TextInputType.text,
                                codigofuncionario,
                                "Escreva o código do funcionário",
                                TextCapitalization.none,
                              ),
                              (widget.funcionario == null)
                                  ? Layout().caixadetexto(
                                      1,
                                      1,
                                      TextInputType.emailAddress,
                                      email,
                                      "Escreva o email",
                                      TextCapitalization.none,
                                    )
                                  : Text(email.text),
                              (perfil != "Direção")
                                  ? Column(
                                      children: <Widget>[
                                        Layout().secao(
                                            "Expediente", Colors.lightBlue),
                                        linhasemana(),
                                        linhahorario('Período 1'),
                                        linhahorario('Período 2 (se houver)'),
                                        linhahorario('Período 3 (se houver)')
                                      ],
                                    )
                                  : Container(),
                              (perfil != "Direção")
                                  ? Column(
                                      children: [
                                        Layout().secao("Cursos de Atendimento",
                                            Colors.lightBlue),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 30.0),
                                          child: Column(
                                            children:
                                                cursos.map((String document) {
                                              return ItemCheckBox(
                                                  document, cursosselecionados);
                                            }).toList(),
                                          ),
                                        ),
                                        Layout().secao("Turmas de Atendimento",
                                            Colors.lightBlue),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 30.0),
                                          child: Column(
                                            children:
                                                turmas.map((String document) {
                                              return ItemCheckBox(
                                                  document, turmasselecionadas);
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              Divider(
                                thickness: 2.0,
                              ),
                              (perfil != null && perfil != "Direção" &&
                                      !perfil.contains('Professor'))
                                  ? Column(
                                      children: [
                                        Layout().secao("Visualizar chat:",
                                            Colors.lightBlue),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 30.0),
                                          child: Column(
                                            children: perfissemproprio
                                                .map((String document) {
                                              return ItemCheckBox(
                                                  document, perfisselecionados);
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                            ],
                          )
                        : Container(),
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

  Widget linhasemana() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Wrap(
                  children: [
                    ItemCheckBox('SEG', diassemana),
                    ItemCheckBox('TER', diassemana),
                    ItemCheckBox('QUA', diassemana),
                    ItemCheckBox('QUI', diassemana),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Wrap(
                  children: [
                    ItemCheckBox('SEX', diassemana),
                    ItemCheckBox('SAB', diassemana),
                    ItemCheckBox('DOM', diassemana),
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  Widget linhahorario(titulo) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(color: Cores().corprincipal)),
        child: Column(
          children: [
            SizedBox(
              height: 10.0,
            ),
            Layout().titulo(titulo),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Column(
                    children: [
                      Card(
                        elevation: 2.0,
                        child: InkWell(
                          onTap: () {
                            Future<TimeOfDay?> selectedDate = showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light(),
                                  child: child!,
                                );
                              },
                            );
                            selectedDate.then((time) {
                              if (time != null) {
                                setState(() {
                                  if (titulo == 'Período 1') {
                                    horainicio = Pesquisa().formatHora(
                                        hour: time.hour, minute: time.minute);
                                  }
                                  if (titulo == 'Período 2 (se houver)') {
                                    horainicio2 = Pesquisa().formatHora(
                                        hour: time.hour, minute: time.minute);
                                  }
                                  if (titulo == 'Período 3 (se houver)') {
                                    horainicio3 = Pesquisa().formatHora(
                                        hour: time.hour, minute: time.minute);
                                  }
                                });
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "Editar Horário Início",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      (horainicio != null && titulo == 'Período 1')
                          ? Layout().titulo(horainicio)
                          : Container(),
                      (horainicio2 != null && titulo == 'Período 2 (se houver)')
                          ? Layout().titulo(horainicio2)
                          : Container(),
                      (horainicio3 != null && titulo == 'Período 3 (se houver)')
                          ? Layout().titulo(horainicio3)
                          : Container(),
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    children: [
                      Card(
                        elevation: 2.0,
                        child: InkWell(
                          onTap: () {
                            Future<TimeOfDay?> selectedDate = showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light(),
                                  child: child!,
                                );
                              },
                            );
                            selectedDate.then((time) {
                              if (time != null) {
                                setState(() {
                                  if (titulo == 'Período 1') {
                                    horafim = Pesquisa().formatHora(
                                        hour: time.hour, minute: time.minute);
                                  }
                                  if (titulo == 'Período 2 (se houver)') {
                                    horafim2 = Pesquisa().formatHora(
                                        hour: time.hour, minute: time.minute);
                                  }
                                  if (titulo == 'Período 3 (se houver)') {
                                    horafim3 = Pesquisa().formatHora(
                                        hour: time.hour, minute: time.minute);
                                  }
                                });
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "Editar Horário Final",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      (horafim != null && titulo == 'Período 1')
                          ? Layout().titulo(horafim)
                          : Container(),
                      (horafim2 != null && titulo == 'Período 2 (se houver)')
                          ? Layout().titulo(horafim2)
                          : Container(),
                      (horafim3 != null && titulo == 'Período 3 (se houver)')
                          ? Layout().titulo(horafim3)
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              thickness: 1.0,
            )
          ],
        ),
      ),
    );
  }

  void parasalvar(BuildContext context) {
    if (perfil == null || perfil.isEmpty) {
      Layout().dialog1botao(context, "Selecione o perfil", "Selecione");
    } else if (email.text == null || email.text.isEmpty) {
      Layout().dialog1botao(context, "E-mail", "Escreva o e-mail");
    } else if (codigofuncionario.text == null ||
        codigofuncionario.text.isEmpty) {
      Layout().dialog1botao(
          context, "Código do funcionário", "Escreva o código do funcionário");
    } else if (perfil != "Funcionário" &&
        perfil != "Direção" &&
        perfil != "Funcionário" &&
        perfil != "Professor Extracurricular" &&
        cursosselecionados.length == 0) {
      Layout().dialog1botao(context, "Selecione o curso", "Selecione");
    } else if (perfil != "Funcionário" &&
        perfil != "Direção" &&
        perfil != "Professor Extracurricular" &&
        turmasselecionadas.length == 0) {
      Layout().dialog1botao(context, "Selecione a turma", "Selecione");
    } else if (perfil != "Direção" && (horainicio == null || horafim == null)) {
      Layout().dialog1botao(
          context,
          "Para este perfil, é necessário definir o horário de expediente",
          "Falta o expediente");
    } else if (widget.funcionario == null) {
      salvarnovofuncionario(context);
    } else if (widget.funcionario != null) {
      editarfuncionario(context);
    }
  }

  void salvarnovofuncionario(BuildContext context) {
    if (perfil == "Direção") {
      Map<String, dynamic> map = Map();
      map['controle'] = Nomes().controle;
      map['email'] = email.text;
      map['codigo'] = codigofuncionario.text;
      map['nome'] = nome.text;
      map['perfil'] = perfil;
      map['turma'] = ['Todas'];
      map['curso'] = ['Todos'];
      map['visualizarChat'] = ['Todos'];
      map['unidade'] = unidade;
      map['diasdasemana'] = diassemana;
      map['users'] = Nomes().usersbanco;
      map['responsavel'] = widget.usuario['nome'];
      map['data'] = Pesquisa().hoje();
      Pesquisa().adicionarusuario(map);
      Layout().dialog1botaofecha2(context, "Adicionando usuário",
          "Estamos adicionando o usuário. Poderá levar até 3 minutos.");
    } else {
      if (cursosselecionados.contains('EI') &&
          cursosselecionados.contains('EF1') &&
          cursosselecionados.contains('EF2') &&
          cursosselecionados.contains('EM')) {
        cursosselecionados = ['Todos'];
      }
      if(!perfisselecionados.contains(perfil)){
        perfisselecionados.add(perfil);
      }
      Map<String, dynamic> map = Map();
      map['controle'] = Nomes().controle;
      map['email'] = email.text;
      map['codigo'] = codigofuncionario.text;
      map['nome'] = nome.text;
      map['perfil'] = perfil;
      map['horainicio'] = horainicio;
      map['horafim'] = horafim;
      map['horainicio2'] = horainicio2;
      map['horafim2'] = horafim2;
      map['horainicio3'] = horainicio3;
      map['horafim3'] = horafim3;
      map['responsavel'] = widget.usuario['nome'];
      map['data'] = Pesquisa().hoje();
      map['turma'] = turmasselecionadas;
      map['visualizarChat'] = perfisselecionados;
      map['curso'] = cursosselecionados;
      map['diasdasemana'] = diassemana;
      map['unidade'] = unidade;
      map['users'] = Nomes().usersbanco;

      Pesquisa().adicionarusuario(map);
      Layout().dialog1botao(context, "Adicionando usuário",
          "Estamos adicionando o usuário. Poderá levar até 3 minutos.");
    }
  }

  void editarfuncionario(BuildContext context) {
    if (perfil == "Direção") {
      Map<String, dynamic> map = Map();
      map['controle'] = Nomes().controle;
      map['codigo'] = codigofuncionario.text;
      map['nome'] = nome.text;
      map['perfil'] = perfil;
      map['turma'] = ['Todas'];
      map['visualizarChat'] = ['Todos'];
      map['diasdasemana'] = diassemana;
      map['curso'] = ['Todos'];
      map['unidade'] = unidade;
      map['responsavel'] = widget.usuario['nome'];
      map['data'] = Pesquisa().hoje();
      widget.funcionario.reference.update(map);
      Layout().dialog1botaofecha2(
          context, "Usuário Editado", "As informações foram salvas.");
    } else {
      if (cursosselecionados.contains('EI') &&
          cursosselecionados.contains('EF1') &&
          cursosselecionados.contains('EF2') &&
          cursosselecionados.contains('EM')) {
        cursosselecionados = ['Todos'];
      }
      if(!perfisselecionados.contains(perfil)){
        perfisselecionados.add(perfil);
      }
      Map<String, dynamic> map = Map();
      map['controle'] = Nomes().controle;
      map['codigo'] = codigofuncionario.text;
      map['nome'] = nome.text;
      map['perfil'] = perfil;
      map['horainicio'] = horainicio;
      map['horafim'] = horafim;
      map['horainicio2'] = horainicio2;
      map['horafim2'] = horafim2;
      map['horainicio3'] = horainicio3;
      map['horafim3'] = horafim3;
      map['diasdasemana'] = diassemana;
      map['responsavel'] = widget.usuario['nome'];
      map['data'] = Pesquisa().hoje();
      map['turma'] = turmasselecionadas;
      map['curso'] = cursosselecionados;
      map['visualizarChat'] = perfisselecionados;
      map['unidade'] = unidade;
      map['users'] = Nomes().usersbanco;

      widget.funcionario.reference.update(map);
      Layout().dialog1botaofecha2(
          context, "Usuário Editado", "As informações foram salvas.");
    }
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
    buscarperfis(unidade);
    buscarturmas(unidade);
  }

  void mudarPerfil(String text) {
    setState(() {
      perfil = text;
    });
    removerPerfilPropriodaLista();
  }

  removerPerfilPropriodaLista() {
    perfissemproprio.clear();
    perfis.forEach((perfill) {
      if (perfill != perfil) {
        setState(() {
          perfissemproprio.add(perfill);
        });
      }
    });
  }
}
