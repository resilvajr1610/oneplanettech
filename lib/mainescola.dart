import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:scalifra/chat/menumensagem.dart';
import 'package:scalifra/mensagemintra.dart';

import 'package:url_launcher/url_launcher.dart';

import 'pdfviewer.dart';
import 'alunos/alunos.dart';
import 'avaliacoes.dart';
import 'itens/itempublicacao.dart';
import 'login/login.dart';
import 'mensagemweb.dart';
import 'notificacoesportal.dart';
import 'perfil.dart';
import 'calendario/calendariolista.dart';
import 'cuidados/cuidados.dart';
import 'downloads/downloads.dart';
import 'mensagensreferentea.dart';
import 'aniversariantes.dart';
import 'cardapios/cardapio.dart';
import 'configuracoes.dart';
import 'design.dart';
import 'horario.dart';
import 'layout.dart';
import 'main.dart';
import 'mensagensescola.dart';
import 'pesquisa.dart';
import 'publicacaoadd.dart';

import 'temasdomes.dart';
import 'unidades.dart';
import 'turmas.dart';

class MainEscola extends StatefulWidget {
  final DocumentSnapshot usuario;

  MainEscola(this.usuario);

  @override
  _MainEscolaState createState() => _MainEscolaState();
}

class _MainEscolaState extends State<MainEscola> with WidgetsBindingObserver {
  ScrollController _controller = ScrollController();
  late StreamSubscription _intentDataStreamSubscription;
  late StreamSubscription iossubscription;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  late DocumentSnapshot _lastPublicacao;

  Map<String, List<String>> alunosid = Map();
  Map<String, List<String>> mapalunos = Map();
  List<DocumentSnapshot> _publicacoes = [];
  List<String> turmas = [];
  List<String> alunos = [];

  String logo='', logomenu='', tipo='', capa='', versaoLoja='';
  late StreamSubscription<QuerySnapshot> listenerquery, listenmsg;

  String nomeusuario='',
      turma='',
      alunoitem='',
      alunoid='',
      horastring='',
      version='',
      buildNumber='';
  int hora=0,
      horainicio=0,
      horafim=0,
      horainicio2=0,
      horafim2=0,
      horainicio3=0,
      horafim3=0,
      opcao = 0,
      _perpage = 50;
  late bool _gettingMorePublicacoes = false,
      _morePublicacoesAvailable = true,
      enviar,
      mensagem,
      temmensagem = true,
      horariotrabalho = false,
      moderacao = false,
      cuidados = false,
      carregando = true,
      mensagens = false,
      chatinterno = false,
      encerrarmenu = false,
      aniversariantes = false,
      horarios = false,
      avaliacoes = false,
      cardapios = false,
      portalprofessor = false;
  String unidade='';
  List<String> unidades = [];
  List<String> cursos = ['EI', 'EF1', 'EF2', 'EM', 'CN'];
  String curso='';

  Map<int, Widget> opcoes = const <int, Widget>{
    0: Text("Mensagens"),
    1: Text("Publicações"),
  };
  late DocumentSnapshot usuario;
  List<String> parametrosbusca = [];

  _savedevicetoken() async {
    String? fcmtoken = await _fcm.getToken();
    if (fcmtoken != null) {
      await widget.usuario.reference.update(
          {"token": fcmtoken, "platform": Platform.operatingSystem});
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    Pesquisa().sendAnalyticsEvent(tela: Nomes().mainescola);
    _controller.addListener(() {
      double maxScroll = _controller.position.maxScrollExtent;
      double currentScroll = _controller.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.125;
      if (maxScroll - currentScroll <= delta) {
        setState(() {
          _getMorePublicacoes();
          _gettingMorePublicacoes = true;
        });
      }
    });
    FirebaseFirestore.instance
        .collection(Nomes().usersbanco)
        .doc(widget.usuario.id)
        .get()
        .then((user) {
      if (user['perfil'] != null) {
        setState(() {
          usuario = user;
        });
        verificarvisualizacaocapames(user);
        //arrumarcacaprofessor();
       // verificarPublicacaosemTurma('STS');
        expediente();
        buscarfuncionalidades();
        buscarnovasmensagensinterna();
        if (widget.usuario['unidade'] == 'Todas as unidades') {
          unidades.clear();
          unidades.add('Todas');
          FirebaseFirestore.instance
              .collection(Nomes().unidadebanco)
              .get()
              .then((value) {
            value.docs.forEach((element) {
              if (!unidades.contains(element['unidade'])) {
                setState(() {
                  unidades.add(element['unidade']);
                  parametrosbusca = ['Todas', usuario.id];
                });
              }
              _getPublicacoes();
            });
          });
        } else {
          if (!unidades.contains(widget.usuario['unidade'])) {
            unidades.add(widget.usuario['unidade']);
          }

          buscarlogounidade(usuario['unidade']);

          unidade = widget.usuario['unidade'];
          setState(() {
            parametrosbusca.add('Todas');
            parametrosbusca.add(usuario['unidade']);
            parametrosbusca.add(usuario.id);
          });
          _getPublicacoes();
        }
        if (List<String>.from(widget.usuario['curso'])[0] != 'Todos') {
          cursos = List<String>.from(widget.usuario['curso']);
        }
        if (List<String>.from(widget.usuario['turma'])[0] != 'Todas') {
          turmas = List<String>.from(widget.usuario['turma']);
        }
        // turmaealunos();

        if (!kIsWeb) {
          notificacao();
        }
        pegarversao();
        buscarVersaoLoja();
      } else {
        FirebaseAuth.instance.signOut().then((user) {
          Navigator.pop(context);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Login()));
        });
      }
    });
    super.initState();
  }

  verificarPublicacaosemTurma(unidadee) {
    FirebaseFirestore.instance
        .collection(Nomes().publicacoesbanco)
        .where('unidade', isEqualTo: unidadee)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element['turma'] != null && element['curso'] == null) {
          print(element.id);
          FirebaseFirestore.instance
              .collection(Nomes().turmas)
              .where('turma')
              .where('unidade', isEqualTo: unidadee)
              .get()
              .then((turmasDocs) {
            element.reference
                .update({'curso': turmasDocs.docs.first['curso']});
          });
        }
      });
    });
  }

  void verificarvisualizacaocapames(DocumentSnapshot usuariob) {
    if (usuariob['visualizacao'] == null) {
      Reference reference =
          FirebaseStorage.instance.ref().child('TelaInicio/' + 'capa.png');
      reference.getDownloadURL().then((value) async {
        setState(() {
          capa = value.toString();
        });
      });
    } else if (!usuariob['visualizacao']
        .contains(Pesquisa().getMesTelaInicial())) {
      Reference reference = FirebaseStorage.instance.ref().child(
          Nomes().telaInicioMes + Pesquisa().getMesTelaInicial() + '.png');
      reference.getDownloadURL().then((value) async {
        setState(() {
          capa = value.toString();
        });
        usuariob.reference.update({
          'visualizacao':
              FieldValue.arrayUnion([Pesquisa().getMesTelaInicial()])
        });
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.paused) {
      FirebaseFirestore.instance
          .collection(Nomes().usersbanco)
          .doc(widget.usuario.id)
          .snapshots()
          .listen((doc) {
        if (doc.exists && doc['perfil'] != null) {
          setState(() {
            usuario = doc;
          });
          expediente();
          //  turmaealunos();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    if (!kIsWeb && Platform.isIOS) {
      iossubscription.cancel();
    }
    if (listenerquery != null) {
      listenerquery.cancel();
    }
    if (listenmsg != null) {
      listenmsg.cancel();
    }
    if (_intentDataStreamSubscription != null) {
      _intentDataStreamSubscription.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundomaisclaro,
      appBar: appbar(),
      drawer: (capa == null) ? Drawer(child: opcoesdrawer()) : null,
      body: (horariotrabalho != null && horariotrabalho)
          ? Stack(
              children: [
                Row(
                  children: [
                    (MediaQuery.of(context).size.width > 950)
                        ? telaweb()
                        : telaapp(),
                  ],
                ),
                bodymensagens(),
                (capa != null)
                    ? Stack(
                        children: [
                          Container(
                              color: Colors.white,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Image.network(
                                capa,
                                fit: BoxFit.cover,
                              )),
                          Positioned(
                            bottom: 10.0,
                            right: 10.0,
                            child: FlatButton(
                              color: Cores().corprincipal,
                              onPressed: () async {
                                if (usuario['visualizacao'] != null) {
                                  if (capa != null) {
                                    setState(() {
                                      capa = '';
                                    });
                                  }
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => DocumentoDetalhes(
                                              '', '' as DocumentSnapshot, usuario, false)));
                                }
                              },
                              child: Text(
                                'Continuar',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container()
              ],
            )
          : Container(),
      floatingActionButton: (capa != null)
          ? Container()
          : (usuario != null && usuario['perfil'] == "Direção" ||
                  (horariotrabalho != null && horariotrabalho == true))
              ? new FloatingActionButton(
                  backgroundColor: Cores().corprincipal,
                  onPressed: () {
                    modalbottom(context);
                  },
                  child: new Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                )
              : Container(),
    );
  }

  buscarnovasmensagensinterna() {
    listenmsg = FirebaseFirestore.instance
        .collection(Nomes().mensagensinternasbanco)
        .where("buscaparametros", arrayContainsAny: [widget.usuario.id])
        .where('novamsg', isEqualTo: usuario.id)
        .snapshots()
        .listen((docs) {
          if (docs.docs.length > 0) {
            setState(() {
              mensagem = true;
            });
          } else {
            setState(() {
              mensagem = false;
            });
          }
        });
  }

  telaweb() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Row(
        children: [
          Card(
            child: Container(width: 300.0, child: opcoesdrawer()),
          ),
          VerticalDivider(
            thickness: 1.0,
          ),
          Flexible(
            flex: 1,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Layout().dropdownitem('Selecione a unidade',
                            unidade, mudarUnidade, unidades)),
                    (unidade != null && unidade != 'Todas')
                        ? Expanded(
                            flex: 1,
                            child: Layout().dropdownitem(
                                'Selecione o curso', curso, mudarCurso, cursos))
                        : Container(),
                    (turmas.isNotEmpty)
                        ? Expanded(
                            flex: 1,
                            child: Layout().dropdownitem(
                                'Selecione a turma', turma, mudarTurma, turmas))
                        : Container(),
                    (alunos.isNotEmpty)
                        ? Expanded(
                            flex: 1,
                            child: Layout().dropdownitem('Selecione o aluno',
                                alunoitem, mudarAluno, alunos))
                        : Container()
                  ],
                ),
                Expanded(child: listamain())
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Column(
              children: [
                (mensagens)
                    ? Flexible(
                        flex: 1,
                        child: Card(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 12.0, top: 15.0),
                                    child: Layout().titulo('Novas Mensagens')),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 2.0,
                                                color: Cores().corprincipal)),
                                        child: carregarmensagens()),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ))
                    : Container(),
              ],
            ),
          )
        ],
      ),
    );
  }

  telaapp() {
    return Expanded(
      child: Container(
        child: Column(
          children: <Widget>[
            (version != null && versaoLoja != null)
                ? Layout().bannerNovaVersao(version, versaoLoja)
                : Container(),
            (mensagens)
                ? Layout().segmented(opcoes, opcao, mudardosegmento, context)
                : Container(),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: (unidades.isNotEmpty)
                        ? Layout().dropdownitem('Selecione a unidade', unidade,
                            mudarUnidade, unidades)
                        : Container()),
                (unidade != null && unidade != 'Todas')
                    ? Expanded(
                        flex: 1,
                        child: Layout().dropdownitem(
                            'Selecione o curso', curso, mudarCurso, cursos))
                    : Container(),
                (turmas.isNotEmpty)
                    ? Expanded(
                        flex: 1,
                        child: Layout().dropdownitem(
                            'Selecione a turma', turma, mudarTurma, turmas))
                    : Container(),
                (opcao == 1 && alunos.isNotEmpty)
                    ? Expanded(
                        flex: 1,
                        child: Layout().dropdownitem(
                            'Selecione o aluno', alunoitem, mudarAluno, alunos))
                    : Container()
              ],
            ),
            (opcao == 0 && mensagens)
                ? Expanded(
                    child: carregarmensagens(),
                  )
                : Container(),
            (opcao == 0 && !mensagens)
                ? Expanded(child: listamain())
                : Container(),
            (opcao == 1) ? Expanded(child: listamain()) : Container(),
          ],
        ),
      ),
    );
  }

  void modalbottom(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    hoverColor: Cores().corprincipal.withOpacity(0.2),
                    leading: new Icon(Icons.photo_filter),
                    title: new Text('Nova Publicação'),
                    onTap: () {
                      Navigator.pop(context);
                      Pesquisa().irpara(
                          PublicacaoAdd(widget.usuario, '', moderacao),
                          context);
                    }),
                (cuidados &&
                        (List<String>.from(usuario['curso'])
                                .contains('Todos') ||
                            List<String>.from(usuario['curso']).contains('EI')))
                    ? ListTile(
                        hoverColor: Cores().corprincipal.withOpacity(0.2),
                        leading: new Icon(Icons.child_care),
                        title: new Text('Cuidados Educação Infantil'),
                        onTap: () {
                          Navigator.pop(context);
                          Pesquisa().irpara(Cuidados(widget.usuario), context);
                        })
                    : Container(),
                (mensagens)
                    ? ListTile(
                        hoverColor: Cores().corprincipal.withOpacity(0.2),
                        leading: new Icon(Icons.send),
                        title: new Text('Mensagens individuais para pais'),
                        onTap: () {
                          Navigator.pop(context);
                          Pesquisa().irpara(Mensagens(widget.usuario), context);
                        },
                      )
                    : Container(),
                (chatinterno)
                    ? ListTile(
                        hoverColor: Cores().corprincipal.withOpacity(0.2),
                        leading: new Icon(Icons.send),
                        title: new Text('Chat Interno'),
                        onTap: () {
                          Navigator.pop(context);
                          Pesquisa()
                              .irpara(MensagemIntra(widget.usuario), context);
                        },
                      )
                    : Container(),
              ],
            ),
          );
        });
  }

  Widget bodymensagens() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: (mensagem != null && mensagem)
          ? Layout().itemnovamensagem(
              context, "Você tem nova mensagem", MenuMensagem(usuario))
          : Container(),
    );
  }

  void buscarfuncionalidades() {
    if (usuario['unidade'] != 'Todas as unidades') {
      FirebaseFirestore.instance
          .collection('Funcionalidades')
          .doc(usuario['unidade'])
          .get()
          .then((doc) {
        if (this.mounted) {
          setState(() {
            moderacao = doc['moderacao'];
            cuidados = doc['cuidados'];
            chatinterno = doc['chatinterno'];
            aniversariantes = doc['aniversariantes'];
            encerrarmenu = doc['encerrarmenu'];
            List<String>.from(usuario['curso']).forEach((element) {
              if (usuario['curso'].contains('Todos')) {
                if (List<String>.from(doc['cardapios']).isNotEmpty) {
                  setState(() {
                    cardapios = true;
                  });
                }
                if (List<String>.from(doc['horarios']).isNotEmpty) {
                  setState(() {
                    horarios = true;
                  });
                }
                if (List<String>.from(doc['avaliacoes']).isNotEmpty) {
                  setState(() {
                    avaliacoes = true;
                  });
                }
              }

              if (List<String>.from(doc['avaliacoes']).isNotEmpty &&
                  (List<String>.from(doc['avaliacoes']).contains(element))) {
                setState(() {
                  avaliacoes = true;
                });
              }

              if (List<String>.from(doc['cardapios']).isNotEmpty &&
                  List<String>.from(doc['cardapios']).contains(element)) {
                setState(() {
                  cardapios = true;
                });
              }

              if (List<String>.from(doc['horarios']).isNotEmpty &&
                  (List<String>.from(doc['horarios']).contains(element))) {
                setState(() {
                  horarios = true;
                });
              }
            });
          });
        }
      });
      if (usuario['perfil'] == 'Direção') {
        FirebaseFirestore.instance
            .collection(Nomes().perfilbanco)
            .where('unidade', isEqualTo: usuario['unidade'])
            .where('chat', isEqualTo: true)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            setState(() {
              mensagens = true;
            });
          }
        });
      } else {
        FirebaseFirestore.instance
            .collection(Nomes().perfilbanco)
            .where('unidade', isEqualTo: usuario['unidade'])
            .where('perfil', isEqualTo: usuario['perfil'])
            .where('chat', isEqualTo: true)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            setState(() {
              mensagens = true;
            });
          }
        });
      }
      FirebaseFirestore.instance
          .collection('Unidades')
          .doc(usuario['unidade'])
          .get()
          .then((doc) {
        if (this.mounted) {
          if (doc['linkportalprofessor'] != null &&
              doc['linkportalprofessor'].isNotEmpty) {
            setState(() {
              portalprofessor = true;
            });
          }
        }
      });
    } else {
      setState(() {
        aniversariantes = true;
        cardapios = true;
        horarios = true;
        avaliacoes = true;
        mensagens = true;
        chatinterno = true;
        moderacao = true;
        cuidados = true;
        portalprofessor = true;
      });
    }
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

  void mudarCurso(String text) {
    setState(() {
      curso = text;
      turma = '';
      alunoitem = '';
      alunoid = '';
      parametrosbusca = [curso + ' - ' + unidade];
    });
    _getPublicacoes();

    if (List<String>.from(widget.usuario['turma'])[0] == 'Todas') {
      buscarturmas(unidade, curso);
    }
  }

  void mudarTurma(String text) {
    setState(() {
      turma = text;
      alunoid = '';
      alunoitem = '';
      parametrosbusca = [turma + ' - ' + unidade];
    });
    if (opcao == 1 || MediaQuery.of(context).size.width > 950) {
      buscarAlunos(turma);
    }
    _getPublicacoes();
  }

  void mudarUnidade(String text) {
    setState(() {
      if (text == 'Todas') {
        unidade = '';
      } else {
        unidade = text;
      }
      parametrosbusca = [text];
    });
    alunoitem = '';
    curso = '';
    turma = '';
    _getPublicacoes();
  }

  buscarlogounidade(uni) {
    FirebaseFirestore.instance
        .collection(Nomes().unidadebanco)
        .doc(uni)
        .get()
        .then((value) {
      setState(() {
        logo = value['logobarra'];
        logomenu = value['logomenu'];
      });
    });
  }

  Widget opcoesdrawer() {
    return Container(
      color: Colors.white,
      child: ListView(
        children: <Widget>[
          Layout().menuheader(widget.usuario, logomenu, context),
          Divider(
            thickness: 0.5,
            color: Cores().corprincipal,
          ),
          // IconButton(icon: Icon(Icons.delete), onPressed: () {
          //   Pesquisa().excluiralunos();
          //   },),

          (widget.usuario != null && widget.usuario['alunos'] != null)
              ? Layout().itemmenu("Trocar para Responsável",
                  Icons.remove_red_eye, MyHomePage(), context)
              : Container(),
          Layout().itemmenu("Notificações", Icons.add_alert,
              NotificacoesPortal(widget.usuario), context),
          (usuario != null &&
                  (usuario['perfil'] == "Direção" ||
                      usuario['perfil'] == "Suporte - TI" ||
                      usuario['perfil'] == "Suporte TI" ||
                      usuario['perfil'] == "Suporte TI - Aux" ||
                      usuario['perfil'] == "TI") &&
                  horariotrabalho)
              ? Layout().itemmenu("Configurações", Icons.settings,
                  Configuracoes(widget.usuario), context)
              : Container(),
          (usuario != null &&
                  usuario['perfil'] != 'Professor' &&
                  usuario['perfil'] != 'Funcionário' &&
                  horariotrabalho)
              ? Layout().itemmenu("Alunos", Icons.account_circle,
                  Alunos(usuario, usuario['perfil']), context)
              : Container(),
          (aniversariantes &&
                  usuario['perfil'] != 'Funcionário' &&
                  horariotrabalho)
              ? Layout().itemmenu("Aniversariantes", Icons.cake,
                  Aniversariantes(widget.usuario, '' as DocumentSnapshot, true), context)
              : Container(),
          (horariotrabalho && avaliacoes)
              ? Layout().itemmenu("Avaliações", Icons.school_outlined,
                  Avaliacoes(usuario, true, horariotrabalho, '' as DocumentSnapshot), context)
              : Container(),
          Layout().itemmenu("Calendário", Icons.calendar_today,
              CalendarioLista(widget.usuario, '' as DocumentSnapshot, true), context),
          (horariotrabalho && cardapios)
              ? Layout().itemmenu("Cardápios", Icons.restaurant_menu,
                  Cardapio(usuario, true, horariotrabalho, '' as DocumentSnapshot), context)
              : Container(),
          (horariotrabalho && chatinterno)
              ? Layout().itemmenu(
                  "Chat Interno", Icons.send, MenuMensagem(usuario), context)
              : Container(),
          Layout().itemmenu("Downloads", Icons.folder_special,
              Downloads(true, horariotrabalho, widget.usuario, '' as DocumentSnapshot), context),
          (horariotrabalho && horarios)
              ? Layout().itemmenu("Horários", Icons.access_time,
                  Horario(usuario, true, horariotrabalho, '' as DocumentSnapshot), context)
              : Container(),
          (horariotrabalho &&
                  mensagens &&
                  MediaQuery.of(context).size.width > 950)
              ? Layout().itemmenu(
                  "Mensagens", Icons.send, MensagemWeb(usuario, true), context)
              : Container(),
          (horariotrabalho &&
                  mensagens &&
                  MediaQuery.of(context).size.width < 950)
              ? Layout().itemmenu(
                  "Mensagens", Icons.send, MensagemDetalhe(usuario), context)
              : Container(),

          Layout().itemmenu("Perfil do Funcionário", Icons.info_outline,
              Perfil(usuario, true, true), context),
          (kIsWeb)
              ? Container()
              : Layout().itemmenu("Temas do Mês",
                  Icons.picture_in_picture_outlined, TemasdoMes(), context),
          (usuario != null &&
                  usuario['perfil'] != 'Funcionário' &&
                  usuario['perfil'] != "Professora" &&
                  usuario['perfil'] != "Professor" &&
                  horariotrabalho)
              ? Layout().itemmenu(
                  "Turmas", Icons.group, Turmas(usuario, ''), context)
              : Container(),
          (usuario != null &&
                  usuario['perfil'] != "Professor" &&
                  horariotrabalho &&
                  widget.usuario['unidade'] == 'Todas as unidades')
              ? Layout()
                  .itemmenu("Unidades", Icons.home, Unidades(usuario), context)
              : Container(),
          (encerrarmenu != null && encerrarmenu)
              ? Layout().sair(context)
              : Container(),
          Divider(
            thickness: 0.5,
            color: Cores().corprincipal,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () =>
                  Pesquisa().launchURL('https://www.scalifra.org.br/', context),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 40.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("images/logohorizontal.png"),
                        fit: BoxFit.contain)),
              ),
            ),
          ),
          Divider(color: Cores().corprincipal, thickness: 0.5),
          Divider(
            thickness: 0.5,
            color: Cores().corprincipal,
          ),
          Layout().footerdesenvolvidopor(),
          (!kIsWeb) ? Layout().footerversao(version, buildNumber) : Container(),
        ],
      ),
    );
  }

  expediente() {
    if (usuario['perfil'] == "Direção") {
      setState(() {
        horariotrabalho = true;
      });
    } else {
      if (usuario['diasdasemana'] != null &&
          !usuario['diasdasemana'].contains(
              Pesquisa().diadasemana().toUpperCase().replaceAll('Á', 'A'))) {
        Layout().dialog1botao(context, "Parece que não há expediente neste dia",
            "Se isto parece um erro, fale com a administração");
        return;
      } else if (usuario['diasdasemana'] == null &&
          Pesquisa().saboudom() == true) {
        Layout().dialog1botao(context, "Aparentemente é final de semana",
            "Se isto parece um erro, fale com a administração");
        return;
      } else if (widget.usuario['horainicio'] == null ||
          widget.usuario['horafim'] == null) {
        Layout().dialog1botao(context, "Fora do Horário de Trabalho",
            "Se isto parece um erro, fale com a administração");
        return;
      } else {
        hora = int.parse(Pesquisa().getHora().replaceAll(RegExp(':'), ''));
        horainicio =
            int.parse(widget.usuario['horainicio'].replaceAll(RegExp(':'), ''));
        horafim =
            int.parse(widget.usuario['horafim'].replaceAll(RegExp(':'), ''));
        if (widget.usuario['horainicio2'] != null) {
          horainicio2 = int.parse(
              widget.usuario['horainicio2'].replaceAll(RegExp(':'), ''));
          horafim2 =
              int.parse(widget.usuario['horafim2'].replaceAll(RegExp(':'), ''));
        }
        if (widget.usuario['horainicio3'] != null) {
          horainicio3 = int.parse(
              widget.usuario['horainicio3'].replaceAll(RegExp(':'), ''));
          horafim3 =
              int.parse(widget.usuario['horafim3'].replaceAll(RegExp(':'), ''));
        }
        if (hora >= horainicio && horafim > hora) {
          setState(() {
            horariotrabalho = true;
          });
        } else if (horainicio2 != null &&
            hora >= horainicio2 &&
            horafim2 > hora) {
          setState(() {
            horariotrabalho = true;
          });
        } else if (horainicio3 != null &&
            hora >= horainicio3 &&
            horafim3 > hora) {
          setState(() {
            horariotrabalho = true;
          });
        } else {
          setState(() {
            horariotrabalho = false;
          });
          Layout().dialog1botao(
              context,
              "Fora do Horário de Trabalho",
              "Seu expediente: \n${usuario['horainicio']} às ${usuario['horafim']}"
                  "\n${usuario['horainicio2']} às ${usuario['horafim2']}"
                  "\n${usuario['horainicio3']} às ${usuario['horafim3']}."
                  "\nSe isto parece um erro, fale com a administração");
          return;
        }
      }
    }
  }

  Widget itematividadeOnePlanet() {
    return Card(
      elevation: 2.0,
      child: InkWell(
        onTap: () {
          atividadesOnePlanet();
        },
        child: ListTile(
          title:
              Text('Atividades', style: TextStyle(color: Cores().corprincipal)),
          leading: Icon(
            Icons.format_list_bulleted,
            color: Cores().corprincipal,
          ),
        ),
      ),
    );
  }

  atividadesOnePlanet() async {
    const url =
        'https://docs.google.com/spreadsheets/d/1YDs8K1IosvcrDYyYO6mPupqWL2wBu-022v8ycUl742k/edit#gid=1327092853';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> pegarversao() async {
    if (kIsWeb) {
      return;
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  notificacao() {
    if (kIsWeb) {
      return;
    } else if (Platform.isIOS) {
      // iossubscription = _fcm.getNotificationSettings.listen((data) {
      //
      // });
      _fcm.requestPermission();
      _savedevicetoken();
    } else {
      _savedevicetoken();
    }
    _fcm.subscribeToTopic(Nomes().push);
    usuario.reference.update({
      "notificacoes":
          FieldValue.arrayUnion([Pesquisa().replaceforpush(Nomes().push)])
    });
    _fcm.subscribeToTopic(Pesquisa().replaceforpush(usuario['unidade']));
    usuario.reference.update({
      "notificacoes":
          FieldValue.arrayUnion([Pesquisa().replaceforpush(usuario['unidade'])])
    });
    _fcm.subscribeToTopic(Nomes().controle +
        Pesquisa().replaceforpush(usuario['perfil'] + usuario['unidade']));
    usuario.reference.update({
      "notificacoes": FieldValue.arrayUnion([
        Nomes().controle +
            Pesquisa().replaceforpush(usuario['perfil'] + usuario['unidade'])
      ])
    });
  }

  // arrumarcacaprofessor() {
  //
  //   // var apagar = [
  //   //   "ProfessorB6bROEnNLkdLuPrX7am2mJC6NMZ2", "ProfessorekP6tAEbgXYXSDX8YNKtro2WVj93", "ProfessorJQhA14RrYcMzLA5lRhPaHDgsZ582", "ProfessorK8unA0e7y5QpiVe7J0FyrLlhVTQ2", "ProfessorkAieKx0HU5SNjDu5jeB8Mc1C9u62", "ProfessorLbdUvnsdDwaghZVR6Q7lc3n2BO82", "Professorli1UK01rOqQS3V7gVjZUDBLNBul2", "ProfessorM6xsTGdYaAQhAshRksypUlkussi1", "ProfessorMaG7xtttzNelaKqJSBYxloD7BRM2", "ProfessormCjnMuUMAgWxPpu04rDIweDDGVt2", "ProfessorMr9ZsXEXb9dkDYGxJgeENfT3cnf2", "ProfessorMRnJMDSy27bDAQoz4WBCipSr1u23", "Professorn7W498vUb1gO3dP2e2HaR02xoQc2", "ProfessorNmt4Y3C2CYV1XLwHh4kUFOdzlGs2", "ProfessorNnrSpCmkVKP6sg4WAh8N1BIwkeV2", "ProfessoroveNAj5iXKTjvWd6997IXGSurd83", "ProfessorPH7CRXWUTScv6gIU56UMRa3xAU13", "ProfessorPtVOIJBfkrTEf1A9kz393gVtKDx1", "ProfessorpWhbh7bHJ0QlQggL1juICsCnQyi2", "ProfessorPWVYk9Do97VeII8hH7GILKbYcnv1", "ProfessorqTF7YDzoxRP6oz9Fn20gTJQSaCy1", "ProfessorQWAyoViJRhd3ECKgbiE0uzbzpST2", "ProfessorrqhUIi07tdV1xdrKvmAuMw3uyQH3", "Professorsk5F9YtNc2bc0YwCWhh07tNkOQV2", "ProfessorSwHe1YeQKEbJDvn3SHrg89kcgd33", "ProfessortSd2z7Ct5fXfC7f5ooFZMVyIwfo2", "ProfessorUb1nO4eg3WgGZJiiWwL6rNNH7A82", "ProfessorUydwEuTNz4Q4knYzMiwvjSubY8I3", "Professorv4jejxVfdSTAj4kFOuUzWMJ8VZh2", "ProfessorvfjPE0hTT4Y5t41S2r3NCwaLPvo2", "ProfessorVPSPov9LnhhkHjnKTRkln0O5GKb2", "ProfessorxvlH1HnOijXPZC5ZquLAGkoLRd62", "Professory48fSVprPZXqbjgqdA7gC72Ru8m1", "ProfessoryeSSOjdSmqbJBrRMqonGEz9BQJo2", "ProfessorZ3kPfmhs9gMPj7nRm41gboYLvDv2", "ProfessorzkIpNxGUFmdx227CCsojmqIvcsK2"
  //   // ];
  //   //
  //   // apagar.forEach((element) {
  //   //   Firestore.instance.collection(Nomes().mensagensbanco).document(element).get().then((value) {
  //   //     if(value.exists){
  //   //       value.reference.delete();
  //   //     }
  //   //   });
  //   // });
  //
  //   Firestore.instance
  //       .collection(Nomes().mensagensbanco+ 'Testes')
  //       .getDocuments()
  //       .then((value) {
  //     value.documents.forEach((element) {
  //       String docId = element.documentID;
  //       String deveriaSerdocId = 'Professor' + element['professorid'] + element['origem'];
  //
  //
  //         Firestore.instance.collection(Nomes().mensagensbanco).document(deveriaSerdocId).setData(element.data).then((value) {
  //           element.reference.delete();
  //         });
  //
  //
  //         print(element['professorid'] + ' - ' + element['origem'] + ' - ' + element['aluno'] + ' - ' + element.documentID);
  //
  //     });
  //   });
  // }

  void buscarAlunos(turm) {
    alunos.clear();
    alunosid.clear();
    FirebaseFirestore.instance
        .collection(Nomes().alunosbanco)
        .where('ano', arrayContainsAny: [Pesquisa().getAno()])
        .where("unidade", isEqualTo: unidade)
        .where("turma", isEqualTo: turm)
        .orderBy('nome')
        .get()
        .then((documents) {
          documents.docs.forEach((doc) {
            setState(() {
              if (doc != null) {
                alunos.add(doc['nome']);
                alunosid[doc.id] = [doc['nome']];
              }
            });
          });
        });
  }

  void temmensagemp() {
    if (mensagens) {
      if (widget.usuario['perfil'] == 'Direção') {
        FirebaseFirestore.instance
            .collection(Nomes().mensagensbanco)
            .orderBy("datacomparar", descending: true)
            .where("unidade", isEqualTo: unidade)
            .where("curso", isEqualTo: curso)
            .where("turma", isEqualTo: turma)
            .where("nova", isEqualTo: "escola")
            .get()
            .then((value) {
          if (value.docs.isEmpty) {
            setState(() {
              temmensagem = false;
              opcao = 0;
            });
          }
        });
      } else if (widget.usuario['perfil'] != 'Professor') {
        FirebaseFirestore.instance
            .collection(Nomes().mensagensbanco)
            .where("unidade", isEqualTo: unidade)
            .where("para", isEqualTo: usuario['perfil'])
            .where("curso", isEqualTo: curso)
            .where("turma", isEqualTo: turma)
            .orderBy("datacomparar", descending: true)
            .where("nova", isEqualTo: "escola")
            .get()
            .then((value) {
          if (value.docs.isEmpty) {
            setState(() {
              temmensagem = false;
              opcao = 0;
            });
          }
        });
      } else {
        FirebaseFirestore.instance
            .collection(Nomes().mensagensbanco)
            .where("professorid", isEqualTo: usuario.id)
            .orderBy("datacomparar", descending: true)
            .where("nova", isEqualTo: "escola")
            .get()
            .then((value) {
          if (value.docs.isEmpty) {
            setState(() {
              temmensagem = false;
              opcao = 1;
            });
          }
        });
      }
    } else {
      setState(() {
        temmensagem = false;
        opcao = 0;
      });
    }
  }

  void mudardosegmento(val) {
    setState(() {
      opcao = val;
    });
  }

  void mudarAluno(String text) {
    setState(() {
      alunoitem = text;
    });
    alunosid.forEach((String key, List<String> list) {
      if (list[0] == alunoitem) {
        setState(() {
          alunoid = key;
          parametrosbusca = [alunoid];
        });
        _getPublicacoes();
      }
    });
  }

  Future goToPublicacoes() {
    const tempo = const Duration(seconds: 1);
    return Future.delayed(tempo, () {
      setState(() {
        opcao = 1;
      });
    });
  }

//Dar pub get, pois o pacote de áudio buga na minha maquina
  Widget carregarmensagens() {
    if (widget.usuario['perfil'].contains('Professor')) {
      return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(Nomes().mensagensbanco)
              .where("professorid", isEqualTo: usuario.id)
              .orderBy("datacomparar", descending: true)
              .where("nova", isEqualTo: "escola")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return new Text(
                  'Isto é um erro. Por gentileza, contate o suporte.');
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Container();
              default:
                return (snapshot.data!.docs.isNotEmpty)
                    ? ListView(
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          if (usuario['perfil'] == "Direção") {
                            return Layout().itemMensagemTela(document,
                                widget.usuario, true, 'escola', context, null);
                          } else if (document['para'] == usuario['perfil']) {
                            return Layout().itemMensagemTela(document,
                                widget.usuario, true, 'escola', context, null);
                          } else {
                            return Align(
                                alignment: Alignment.center,
                                child: Text('Sem mensagens novas no momento.'));
                          }
                        }).toList(),
                      )
                    : (!kIsWeb)
                        ? FutureBuilder(
                            initialData: Align(
                              alignment: Alignment.center,
                              child: Text('Sem mensagens novas no momento.'),
                            ),
                            future: goToPublicacoes(),
                            builder: (BuildContext context,
                                AsyncSnapshot<dynamic> future) {
                              return Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    'Sem mensagens novas no momento.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container();
            }
          });
    } else if (usuario['perfil'] == "Direção") {
      return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(Nomes().mensagensbanco)
              .where("unidade", isEqualTo: unidade)
              .where("curso", isEqualTo: curso)
              .where("turma", isEqualTo: turma)
              .orderBy("datacomparar", descending: true)
              .where("nova", isEqualTo: "escola")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return new Text(
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
                          if (usuario['perfil'] == "Direção" ||
                              (usuario['visualizarChat']
                                      .contains(document['tipo']) &&
                                  (usuario['curso'].contains('Todos') ||
                                      usuario['curso']
                                          .contains(document['curso'])))) {
                            return Layout().itemMensagemTela(document,
                                widget.usuario, true, 'escola', context, null);
                          } else {
                            return Container();
                          }
                        }).toList(),
                      )
                    : FutureBuilder(
                        initialData: Align(
                          alignment: Alignment.center,
                          child: Text('Sem mensagens novas no momento.'),
                        ),
                        future: goToPublicacoes(),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> future) {
                          return Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                'Sem mensagens novas no momento.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      );
                ;
            }
          });
    } else {
      return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(Nomes().mensagensbanco)
              .where("unidade", isEqualTo: unidade)
              .where("curso", isEqualTo: curso)
              .where("turma", isEqualTo: turma)
              .orderBy("datacomparar", descending: true)
              .where("paraArray", arrayContainsAny: usuario['visualizarChat'])
              .where("nova", isEqualTo: "escola")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return new Text(
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
                          if ((usuario['curso'].contains('Todos') ||
                              usuario['curso'].contains(document['curso']))) {
                            return Layout().itemMensagemTela(document,
                                widget.usuario, true, 'escola', context, null);
                          } else {
                            return Container();
                          }
                        }).toList(),
                      )
                    : FutureBuilder(
                        initialData: Align(
                          alignment: Alignment.center,
                          child: Text('Sem mensagens novas no momento.'),
                        ),
                        future: goToPublicacoes(),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> future) {
                          return Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                'Sem mensagens novas no momento.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      );
                ;
            }
          });
    }
  }

  _getPublicacoes() async {
    if (listenerquery != null) {
      listenerquery.cancel();
    }
    _lastPublicacao = '' as DocumentSnapshot<Object?>;

    if (tipo == 'aguardandoaprovacaoresposta') {
      listenerquery = FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .where("curso", isEqualTo: curso)
          .where("unidade", isEqualTo: unidade)
          .where("turma", isEqualTo: turma)
          .where("tipo", isEqualTo: 'recado')
          .where('enviarresposta', isEqualTo: false)
          .orderBy("datacomparar", descending: true)
          .limit(_perpage)
          .snapshots()
          .listen((query) {
        if (query.docs.length > 0) {
          _lastPublicacao = query.docs.last;
        }
        setState(() {
          _publicacoes = query.docs;
        });
      });
    } else if (tipo == 'aguardandoaprovacao') {
      listenerquery = FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .where("curso", isEqualTo: curso)
          .where("unidade", isEqualTo: unidade)
          .where("turma", isEqualTo: turma)
          .where('enviar', isEqualTo: false)
          .orderBy("datacomparar", descending: true)
          .limit(_perpage)
          .snapshots()
          .listen((query) {
        if (query.docs.length > 0) {
          _lastPublicacao = query.docs.last;
        }
        setState(() {
          _publicacoes = query.docs;
        });
      });
    } else if (tipo == 'minhaspublicacoes') {
      listenerquery = FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .where("parametrosbusca",
              arrayContainsAny: [widget.usuario.id])
          .orderBy("datacomparar", descending: true)
          .limit(_perpage)
          .snapshots()
          .listen((query) {
            if (query.docs.length > 0) {
              _lastPublicacao = query.docs.last;
            }
            setState(() {
              _publicacoes = query.docs;
            });
          });
    } else if (usuario['perfil'] != 'Professor' &&
        usuario['perfil'] != 'Funcionário' &&
        curso != null &&
        turma == null) {
      listenerquery = FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .where("curso", isEqualTo: curso)
          .where("unidade", isEqualTo: unidade)
          .where("tipo", isEqualTo: tipo)
          .orderBy("datacomparar", descending: true)
          .limit(_perpage)
          .snapshots()
          .listen((query) {
        if (query.docs.length > 0) {
          _lastPublicacao = query.docs.last;
        }
        setState(() {
          _publicacoes = query.docs;
        });
      });
    } else if (usuario['perfil'] != 'Funcionário' &&
        curso != null &&
        turma != null &&
        alunoitem == null) {
      listenerquery = FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .where("unidade", isEqualTo: unidade)
          .where("curso", isEqualTo: curso)
          .where("turma", isEqualTo: turma)
          .where("tipo", isEqualTo: tipo)
          .orderBy("datacomparar", descending: true)
          .limit(_perpage)
          .snapshots()
          .listen((query) {
        if (query.docs.length > 0) {
          _lastPublicacao = query.docs.last;
        }
        setState(() {
          _publicacoes = query.docs;
        });
      });
    } else {
      listenerquery = FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .where("parametrosbusca", arrayContainsAny: parametrosbusca)
          .where("tipo", isEqualTo: tipo)
          .orderBy("datacomparar", descending: true)
          .limit(_perpage)
          .snapshots()
          .listen((query) {
        if (query.docs.length > 0) {
          _lastPublicacao = query.docs.last;
        }
        setState(() {
          _publicacoes = query.docs;
        });
      });
    }
  }

  _getMorePublicacoes() async {
    if (!_morePublicacoesAvailable || _gettingMorePublicacoes) return;
    _gettingMorePublicacoes = true;

    if (tipo == 'aguardandoaprovacaoresposta') {
      listenerquery = FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .where("curso", isEqualTo: curso)
          .where("unidade", isEqualTo: unidade)
          .where("turma", isEqualTo: turma)
          .where("tipo", isEqualTo: 'recado')
          .where('enviarresposta', isEqualTo: false)
          .orderBy("datacomparar", descending: true)
          .startAfterDocument(_lastPublicacao)
          .limit(_perpage)
          .snapshots()
          .listen((query) {
        if (query.docs.length > 0) {
          _lastPublicacao = query.docs.last;
        }
        setState(() {
          _publicacoes.addAll(query.docs);
        });
      });
    } else if (tipo == 'aguardandoaprovacao') {
      listenerquery = FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .where("curso", isEqualTo: curso)
          .where("unidade", isEqualTo: unidade)
          .where("turma", isEqualTo: turma)
          .where('enviar', isEqualTo: false)
          .orderBy("datacomparar", descending: true)
          .startAfterDocument(_lastPublicacao)
          .limit(_perpage)
          .snapshots()
          .listen((query) {
        if (query.docs.length > 0) {
          _lastPublicacao = query.docs.last;
        }
        setState(() {
          _publicacoes.addAll(query.docs);
        });
      });
    } else if (tipo == 'minhaspublicacoes') {
      listenerquery = FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .where("parametrosbusca",
              arrayContainsAny: [widget.usuario.id])
          .startAfterDocument(_lastPublicacao)
          .orderBy("datacomparar", descending: true)
          .limit(_perpage)
          .snapshots()
          .listen((query) {
            if (query.docs.length > 0) {
              _lastPublicacao = query.docs.last;
            }
            setState(() {
              _publicacoes.addAll(query.docs);
            });
          });
    } else if (usuario['perfil'] != 'Professor' &&
        usuario['perfil'] != 'Funcionário' &&
        curso != null &&
        turma == null) {
      listenerquery = FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .where("curso", isEqualTo: curso)
          .where("unidade", isEqualTo: unidade)
          .where("tipo", isEqualTo: tipo)
          .startAfterDocument(_lastPublicacao)
          .orderBy("datacomparar", descending: true)
          .limit(_perpage)
          .snapshots()
          .listen((query) {
        if (query.docs.length > 0) {
          _lastPublicacao = query.docs.last;
        }
        setState(() {
          _publicacoes.addAll(query.docs);
        });
      });
    } else if (usuario['perfil'] != 'Funcionário' &&
        curso != null &&
        turma != null) {
      listenerquery = FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .where("unidade", isEqualTo: unidade)
          .where("curso", isEqualTo: curso)
          .where("turma", isEqualTo: turma)
          .where("tipo", isEqualTo: tipo)
          .orderBy("datacomparar", descending: true)
          .startAfterDocument(_lastPublicacao)
          .limit(_perpage)
          .snapshots()
          .listen((query) {
        if (query.docs.length > 0) {
          _lastPublicacao = query.docs.last;
        }
        setState(() {
          _publicacoes.addAll(query.docs);
        });
      });
    } else {
      listenerquery = FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .where("parametrosbusca", arrayContainsAny: parametrosbusca)
          .where("tipo", isEqualTo: tipo)
          .orderBy("datacomparar", descending: true)
          .startAfterDocument(_lastPublicacao)
          .limit(_perpage)
          .snapshots()
          .listen((query) {
        if (query.docs.length > 0) {
          _lastPublicacao = query.docs.last;
        }
        setState(() {
          _publicacoes.addAll(query.docs);
        });
      });
    }
  }

  Widget listamain() {
    return ListView.builder(
      controller: _controller,
      shrinkWrap: true,
      itemCount: _publicacoes.length,
      itemBuilder: (BuildContext ctx, int index) {
        if (_publicacoes[index]['agendado'] == null) {
          return ItemPublicacao(
              widget.usuario, _publicacoes[index], true, moderacao, '' as DocumentSnapshot);
        } else if (_publicacoes[index]['agendado'] == true &&
            _publicacoes[index]['enviar'] == true) {
          return ItemPublicacao(
              widget.usuario, _publicacoes[index], true, moderacao, '' as DocumentSnapshot);
        } else if (_publicacoes[index]['agendado'] == true &&
            _publicacoes[index]['enviar'] == false &&
            _publicacoes[index]['responsavel'] == widget.usuario['nome']) {
          return ItemPublicacao(
              widget.usuario, _publicacoes[index], true, moderacao, '' as DocumentSnapshot);
        } else {
          return Container();
        }
      },
    );
  }

  appbar() {
    return AppBar(
      elevation: 0.0,
      backgroundColor: Cores().corprincipal,
      centerTitle: true,
      title: (logo != null)
          ? Container(
              width: 100.0,
              height: 45.0,
              child: Image.network(
                logo,
                fit: BoxFit.contain,
              ))
          : Container(),
      // leading: (MediaQuery.of(context).size.width < 950)
      //     ? new IconButton(
      //   icon: new Icon(Icons.menu, size: 35.0),
      //   onPressed: limparfiltro,
      // ) : Container(),
      actions: <Widget>[
        (capa == null)
            ? IconButton(
                icon: Icon(Icons.filter_list, size: 35.0),
                onPressed: () {
                  modalfiltro(context);
                })
            : Container(),
      ],
    );
  }

  modalfiltro(context) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) {
        return Scaffold(
            body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                },
                leading: Icon(
                  Icons.close,
                  color: Colors.blue,
                ),
                title: Text(
                  'Filtrar por Tópico',
                  style: TextStyle(
                    color: Cores().corprincipal,
                    fontFamily: "Sofia",
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Divider(),
              itemfiltro('Todas as publicações', 'todasaspublicacoes'),
              Divider(),
              (moderacao &&
                      (usuario['perfil'] == 'Direção' ||
                          usuario['perfil'] == 'Coordenação'))
                  ? itemfiltro('Aguardando Aprovação', 'aguardandoaprovacao')
                  : Container(),
              (moderacao &&
                      (usuario['perfil'] == 'Direção' ||
                          usuario['perfil'] == 'Coordenação'))
                  ? Divider()
                  : Container(),
              (moderacao &&
                      (usuario['perfil'] == 'Direção' ||
                          usuario['perfil'] == 'Coordenação'))
                  ? itemfiltro('Aguardando Aprovação Resposta',
                      'aguardandoaprovacaoresposta')
                  : Container(),
              (moderacao &&
                      (usuario['perfil'] == 'Direção' ||
                          usuario['perfil'] == 'Coordenação'))
                  ? Divider()
                  : Container(),
              itemfiltro('Minhas Publicações', 'minhaspublicacoes'),
              Divider(),
              (cuidados) ? itemfiltro('Cuidados', 'cuidado') : Container(),
              itemfiltro('Documentos', 'documento'),
              itemfiltro('Enquetes', 'enquete'),
              itemfiltro('Fotos e Atividades', 'diario'),
              itemfiltro('Informativos', 'bilhete'),
              itemfiltro('Recados para Professor', 'recado'),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ));
      },
    );
  }

  itemfiltro(texto, filtro) {
    return InkWell(
        hoverColor: Cores().corprincipal.withOpacity(0.2),
        onTap: () {
          Navigator.pop(context);
          if (filtro == 'aguardandoaprovacao') {
            setState(() {
              tipo = 'aguardandoaprovacao';
              enviar = false;
            });
          } else if (filtro == 'aguardandoaprovacaoresposta') {
            setState(() {
              tipo = 'aguardandoaprovacaoresposta';
              enviar = false;
            });
          } else if (filtro == 'todasaspublicacoes') {
            setState(() {
              tipo = '';
              enviar = false;
            });
          } else {
            setState(() {
              tipo = filtro;
              enviar = false;
            });
          }
          _getPublicacoes();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 35.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                texto,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ));
  }

  buscarVersaoLoja() {
    FirebaseFirestore.instance
        .collection('VersoesApp')
        .doc('app')
        .get()
        .then((value) {
      if (Platform.isIOS) {
        setState(() {
          versaoLoja = value['ios'];
        });
      }
      if (Platform.isAndroid) {
        setState(() {
          versaoLoja = value['android'];
        });
      }
    });
  }
}
