import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:table_calendar/table_calendar.dart';

import 'calendariolistaadd.dart';
import '../design.dart';
import '../layout.dart';
import '../pesquisa.dart';
import 'utils.dart';

class CalendarioListaEventos extends StatefulWidget {
  final DocumentSnapshot usuario, aluno;
  final bool controle;

  CalendarioListaEventos(this.usuario, this.aluno, this.controle);

  @override
  _CalendarioListaEventosState createState() => _CalendarioListaEventosState();
}

class _CalendarioListaEventosState extends State<CalendarioListaEventos> {
  String time='', turma='', unidade='';
  late StreamSubscription<QuerySnapshot> listenquery;
  List<String> unidades = [];
  List<String> turmas = [];
  List<String> parametrosbusca = [];
  List<String> cursos = ['EI', 'EF1', 'EF2', 'EM', 'CN'];
  String curso='';

  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;

  final kEvents = LinkedHashMap<DateTime, List<Event>>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  @override
  void initState() {
    super.initState();
    time = Pesquisa().hoje();
    if (widget.controle) {
      if (widget.usuario['unidade'] == 'Todas as unidades') {
        buscarunidades();
      } else {
        unidade = widget.usuario['unidade'];
        parametrosbusca = ['Todas', unidade];
        unidades.add("Todas");
        unidades.add(widget.usuario['unidade']);

        eventoscontrole();
      }

      if (List<String>.from(widget.usuario['curso'])[0] != 'Todos') {
        cursos = List<String>.from(widget.usuario['curso']);
      }

      if (List<String>.from(widget.usuario['turma'])[0] != 'Todas') {
        turmas = List<String>.from(widget.usuario['turma']);
      }
    } else {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        if (widget.aluno != null) {
          toast(context);
        }
      });
      //   eventos();
    }
  }

  buscarunidades() {
    unidades.add('Todas');
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

  toast(context) {
    Toast.show('Perfil de ${widget.aluno['nome']}', textStyle: context,
        duration: Toast.lengthLong, gravity: Toast.center);
  }

  List _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  eventos(DateTime day) {
    listenquery = FirebaseFirestore.instance
        .collection('Calendario')
        .orderBy('datacomparar')
        .where("parametrosbusca", arrayContainsAny: [
          'Todas',
          widget.aluno['unidade'],
          widget.aluno['curso'] + ' - ' + widget.aluno['unidade'],
          widget.aluno['turma'] + ' - ' + widget.aluno['unidade'],
          widget.aluno.id
        ])
        .snapshots()
        .listen((values) {
          values.docs.forEach((doc) {
            setState(() {
              kEvents[doc['datacomparar'].toDate()] = [Event(doc['evento'])];
            });
          });
        });
  }

  eventoscontrole() {
    listenquery = FirebaseFirestore.instance
        .collection('Calendario')
        .orderBy('datacomparar')
        .where("parametrosbusca", arrayContainsAny: parametrosbusca)
        .snapshots()
        .listen((values) {
      kEvents[DateTime.now()] = [Event('Agora')];

      values.docs.forEach((doc) {
        DateTime dd = doc['datacomparar'].toDate();
        dd = new DateTime(dd.year, dd.month, dd.day, 0, 0, 0, 0, 0);
        setState(() {
          kEvents[dd] = [Event(doc['evento'])];
        });
      });
    });
  }

  @override
  void dispose() {
    if (listenquery != null) {
      listenquery.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Layout().appbar('Lista de Eventos'),
      body: Row(
        children: [
          (MediaQuery.of(context).size.width > 850)
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                )
              : Container(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (widget.controle && unidades.length > 0)
                    ? Layout().dropdownitem(
                        'Selecione a unidade', unidade, mudarUnidade, unidades)
                    : Container(),
                (widget.controle &&
                        cursos.length > 0 &&
                        unidade != null &&
                        unidade != "Todas")
                    ? Layout().dropdownitem(
                        'Selecione o curso', curso, mudarCurso, cursos)
                    : Container(),
                (widget.controle && turmas.length > 0 && curso != null)
                    ? Layout().dropdownitem(
                        'Selecione a turma', turma, mudarTurma, turmas)
                    : Container(),
                (time != Pesquisa().hoje() && !widget.controle)
                    ? Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Calendario')
                                .where('data', isEqualTo: time)
                                .where("parametrosbusca", arrayContainsAny: [
                                  'Todas',
                                  widget.aluno['unidade'],
                                  widget.aluno['turma'] +
                                      ' - ' +
                                      widget.aluno['unidade'],
                                  widget.aluno.id
                                ])
                                .orderBy('datacomparar')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                print(snapshot.error);
                                return Text(
                                    'Isto é um erro. Por gentileza, contate o suporte.');
                              }
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Container();
                                default:
                                  return (snapshot.data!.docs.length >= 1)
                                      ? ListView(
                                          children: snapshot.data!.docs
                                              .map((DocumentSnapshot document) {
                                            return Layout()
                                                .itemeventoCalendario(
                                                    controle: widget.controle,
                                                    doc: document,
                                                    usuario: widget.usuario,
                                                    aluno: widget.aluno,
                                                    context: context);
                                          }).toList(),
                                        )
                                      : Container();
                              }
                            }),
                      )
                    : Container(),
                (!widget.controle && widget.aluno != null)
                    ? Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Calendario')
                                .where('datacomparar',
                                    isGreaterThan: DateTime.now()
                                        .subtract(Duration(days: 1)))
                                .where("parametrosbusca", arrayContainsAny: [
                                  'Todas',
                                  widget.aluno['unidade'],
                                  widget.aluno['turma'] +
                                      ' - ' +
                                      widget.aluno['unidade'],
                                  widget.aluno.id
                                ])
                                .orderBy('datacomparar')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                print(snapshot.error);
                                return Text(
                                    'Isto é um erro. Por gentileza, contate o suporte.');
                              }
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Container();
                                default:
                                  return (snapshot.data!.docs.length >= 1)
                                      ? ListView(
                                          children: snapshot.data!.docs
                                              .map((DocumentSnapshot document) {
                                            return Layout()
                                                .itemeventoCalendario(
                                                controle: widget.controle,
                                                doc: document,
                                                usuario: widget.usuario,
                                                aluno: widget.aluno,
                                                context: context);
                                          }).toList(),
                                        )
                                      : Container();
                              }
                            }),
                      )
                    : Container(),
                (time != Pesquisa().hoje() &&
                        widget.controle &&
                        parametrosbusca != null &&
                        parametrosbusca.length > 0)
                    ? Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Calendario')
                                .where('data', isEqualTo: time)
                                .where("parametrosbusca",
                                    arrayContainsAny: parametrosbusca)
                                .orderBy('datacomparar')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                print(snapshot.error);
                                return Text(
                                    'Isto é um erro. Por gentileza, contate o suporte.');
                              }
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Container();
                                default:
                                  return (snapshot.data!.docs.length >= 1)
                                      ? Column(
                                          children: snapshot.data!.docs
                                              .map((DocumentSnapshot document) {
                                            return Layout()
                                                .itemeventoCalendario(
                                                controle: widget.controle,
                                                doc: document,
                                                usuario: widget.usuario,
                                                aluno: widget.aluno,
                                                context: context);
                                          }).toList(),
                                        )
                                      : Container();
                              }
                            }),
                      )
                    : Container(),
                (widget.controle &&
                        parametrosbusca != null &&
                        parametrosbusca.length > 0)
                    ? Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Calendario')
                                .where('datacomparar',
                                    isGreaterThan: DateTime.now()
                                        .subtract(Duration(days: 1)))
                                .where("parametrosbusca",
                                    arrayContainsAny: parametrosbusca)
                                .orderBy('datacomparar')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                print(snapshot.error);
                                return Text(
                                    'Isto é um erro. Por gentileza, contate o suporte.');
                              }
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Container();
                                default:
                                  return (snapshot.data!.docs.length >= 1)
                                      ? ListView(
                                          children: snapshot.data!.docs
                                              .map((DocumentSnapshot document) {
                                            return Layout()
                                                .itemeventoCalendario(
                                                controle: widget.controle,
                                                doc: document,
                                                usuario: widget.usuario,
                                                aluno: widget.aluno,
                                                context: context);
                                          }).toList(),
                                        )
                                      : Container();
                              }
                            }),
                      )
                    : Container(),
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
      floatingActionButton: Layout()
          .floatingactionbar(_floatingaction, Icons.add, 'Incluir', context),
    );
  }

  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
      parametrosbusca = [unidade];
      curso = '';
      turma = '';
    });
    eventoscontrole();
  }

  void mudarCurso(String text) {
    setState(() {
      curso = text;
      parametrosbusca = [curso + ' - ' + unidade];
      turma = '';
    });
    if (List<String>.from(widget.usuario['turma'])[0] == 'Todas') {
      buscarturmas(unidade, curso);
    }
    eventoscontrole();
  }

  void mudarTurma(String text) {
    setState(() {
      turma = text;
      parametrosbusca = [turma + ' - ' + unidade];
    });
    eventoscontrole();
  }

  Widget itemevento(doc) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 8.0),
      child: InkWell(
        onLongPress: () {
          if ((widget.controle && widget.usuario['perfil'] != 'Professor') ||
              doc['responsavel'] == (widget.usuario['nome']) ||
              doc['parametrosbusca'].contains(widget.aluno.id)) {
            Layout().deletar(doc, context);
          }
        },
        child: Row(
          children: [
            Icon(Icons.calendar_today),
            SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Layout().titulo(doc['data']),
                      (doc['hora'] != '' && doc['hora'] != '00h00')
                          ? Layout().titulo('- ' + doc['hora'].toString())
                          : Layout().titulo(' '),
                    ],
                  ),
                  Container(
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw 'Não foi possível abrir: $link';
                        }
                      },
                      text: doc['evento'],
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 17.0,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 8.0,
            ),
            Divider(
              thickness: 0.5,
            ),
          ],
        ),
      ),
    );
  }

  void _floatingaction() {
    Pesquisa().irpara(
        AgendaAdd(widget.usuario, widget.aluno, widget.controle), context);
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      locale: 'pt_BR',
      firstDay: DateTime.utc(2020, 10, 16),
      lastDay: DateTime.utc(2023, 3, 14),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      startingDayOfWeek: StartingDayOfWeek.sunday,
      eventLoader: _getEventsForDay,
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          // Call `setState()` when updating the selected day
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            time = Pesquisa().formatData(
                year: selectedDay.year,
                month: selectedDay.month,
                day: selectedDay.day);
          });
        }
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Cores().corprincipal,
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DateTime>('_selectedDay', _selectedDay));
  }
}
