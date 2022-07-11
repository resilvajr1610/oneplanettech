import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:package_info/package_info.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:scalifra/notificacoesportal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'calendario/calendariolista.dart';
import 'itens/itempublicacao.dart';
import 'filtro/mainfiltro.dart';
import 'mensagenspais.dart';
import 'pdfviewer.dart';
import 'recadosadd.dart';
import 'recadospara.dart';
import 'login/loginweb.dart';
import 'blocs.dart';
import 'mainescola.dart';
import 'mensagemwebpais.dart';
import 'menus.dart';
import 'design.dart';
import 'layout.dart';
import 'login/login.dart';
import 'pesquisa.dart';
import 'utils/User.dart';

// Android (key.properties, manifest nome, e package name, pubspec - versao)
// comentar Pesquisa > fb.Storage
// flutter clean
// flutter channel stable
// flutte upgrade
// flutter doctor
// flutter precache
// flutter pub get
// criar icones: flutter packages pub run flutter_launcher_icons:main
// testar
// flutter build apk --split-per-abi

// ios
// flutter clean
// flutter pub get
// cd ios > pod deintegrate
// pod install
// flutter packages pub run flutter_launcher_icons:main
// xCode Runner (bundle, version, build), Sigin (Team, Push), Info (Nome, permissões), new file swift,
// arquivo Firebase, icone 1024
// Fecha workspace Podfile : platform: iOS, 9.0 , use_frameworks!, pod 'Firebase/MLVisionTextModel'
// testar
// fechar Xcode
// flutter clean
// flutter pub get
// flutter build ios

// WEB
// verificar index.html, firebase.json,  design, imagem, favicon, icon-192, icons-512, fundo.jpg
// flutter clean
// descomentar Pesquisa > fb.Storage
// flutter clean
// flutter pub get
// flutter build web
// firebase deploy --only hosting

// firebase deploy --only functions:atualizarPublicacoesCurso
// indexes - firestore.indexes.json - firebase deploy --only firestore:indexes
// Fotos adicionadas para controle da coordenação e administração da escola.
// io.flutter.embedded_views_preview and the value YES
// imagem circular: http://crop-circle.imageonline.co/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      blocs: [
        Bloc((i) => MainBloc()),
        Bloc((i) => MainFiltroBloc()),
        Bloc((i) => MainEscolaBloc()),
        Bloc((i) => AlunosBloc()),
        Bloc((i) => ConsultaImagemBloc()),
      ],
      dependencies: [],
      child: MaterialApp(
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [const Locale('pt', 'BR')],
        debugShowCheckedModeBanner: false,
        title: 'Agenda Franciscana',
        navigatorObservers: <NavigatorObserver>[observer],
        theme: ThemeData(
          primaryColor: Colors.blueGrey,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();
  late String title='';
  late FirebaseAnalyticsObserver observer;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  FirebaseMessaging _fcm = FirebaseMessaging.instance;

  late DocumentSnapshot usuario, alunodocument, ultimodoc;
  int count = 20, hora=0;
  String horastring='',
      fotoaluno='',
      version='',
      buildNumber='',
      unidade='',
      logo='',
      logomenu='',
      filtro='',
      versaoLoja='';

  List<String> parametrosbusca = [];
  List<DocumentSnapshot> mensagensnovas = [];
  List<DocumentSnapshot> documentsList = [];
  List<DocumentSnapshot> alunos = [];
  late bool mensagem = false,
      notificacaoportal = false,
      horacerta,
      cuidados = false,
      horariopublicacao = true,
      recados = false,
      moderacao = true,
      mensagens = false;

  var userObject;

  late StreamSubscription<QuerySnapshot> listenmsg, listennotificacaoportal;

  String capa='';
  late ScrollController listScrollController;

  final bloc = BlocProvider.getBloc<MainBloc>();

  getCurrentUser() async {
    final user = await FirebaseAuth.instance.currentUser!.uid;
    return user;
  }

  limparfiltro() {
    _key.currentState?.openDrawer();
  }

  _savedevicetoken() async {
    String? fcmtoken = await _fcm.getToken();
    if (fcmtoken != null && usuario != null && usuario.id != null) {
      var tokenref = FirebaseFirestore.instance
          .collection(Nomes().usersbanco)
          .doc(usuario.id);
      await tokenref.update(
          {"token": fcmtoken, "platform": Platform.operatingSystem});
      alunodocument.reference.update({
        "tokens": FieldValue.arrayUnion([fcmtoken])
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    getCurrentUser().then((user) async {
      if (user == null && MediaQuery.of(context).size.width < 950) {
        Pesquisa().pushReplacement(context, Login());
        return;
      } else if (user == null) {
        Pesquisa().pushReplacement(context, LoginWeb());
        return;
      }

      if (!kIsWeb) {
        pegarversao();
        buscarVersaoLoja();
      }

      FirebaseFirestore.instance
          .collection(Nomes().usersbanco)
          .doc(user.uid)
          .get()
          .then((usuariob) {
        if (usuariob.exists && usuariob != null) {
          usuariob.reference.update({
            'ultimoacesso': Pesquisa().getDataeHora(),
            'versao': "Versão: $version - $buildNumber"
          });
          if (usuariob['controle'] != null &&
              usuariob['controle'] == Nomes().controle &&
              usuariob['alunos'] == null) {
            userObject.controle = usuariob['controle'];
            userObject.plataforma = usuariob['platform'];
            userObject.cursos = usuariob['curso'];
            userObject.turmas = usuariob['turma'];
            userObject.perfil = usuariob['perfil'];
            userObject.unidade = usuariob['unidade'];

            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => MainEscola(usuariob)));
            return;
          }
          verificarvisualizacaocapames(usuariob);
          if (usuariob['alunos'] != null) {
            if (this.mounted) {
              setState(() {
                usuario = usuariob;
              });
              if (List<String>.from(usuariob['alunos']).length > 1) {
                buscaralunos();
              }
            }

            buscarnovasmensagens();
            buscarnovanotificacaoportal();
            buscarparametrosbusca(usuariob['alunos'][0]);

            listScrollController = ScrollController();
            listScrollController.addListener(() {
              if (listScrollController.offset >=
                      listScrollController.position.maxScrollExtent &&
                  !listScrollController.position.outOfRange) {
                bloc.inputrodinha.add(true);
                _getMorePublicacoes();
              }
            });
          }
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Login()));
          return;
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

  buscarfuncionalidades() {
    recados = false;
    FirebaseFirestore.instance
        .collection(Nomes().perfilbanco)
        .where('unidade', isEqualTo: alunodocument['unidade'])
        .where('chat', isEqualTo: true)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          mensagens = true;
        });
      }
    });

    FirebaseFirestore.instance
        .collection('Funcionalidades')
        .doc(alunodocument['unidade'])
        .get()
        .then((doc) {
      if (this.mounted) {
        setState(() {
          cuidados = doc['cuidados'];
          horariopublicacao = doc['horariopublicacao'];
          moderacao = doc['moderacao'];
          if (List<String>.from(doc['recados'])
              .contains(alunodocument['curso'])) {
            recados = true;
          }
        });
      }
    });
    verificarhorario();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        verificarhorario();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    if (listScrollController != null) {
      listScrollController.dispose();
    }
    if (listenmsg != null) {
      listenmsg.cancel();
    }
    if (listennotificacaoportal != null) {
      listennotificacaoportal.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundomaisclaro,
      key: _key,
      appBar: AppBar(
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
        leading: (capa == null && (MediaQuery.of(context).size.width < 950))
            ? new IconButton(
                icon: new Icon(Icons.menu, size: 35.0),
                onPressed: limparfiltro,
              )
            : Container(),
        actions: <Widget>[
          (capa == null)
              ? IconButton(
                  icon: Icon(Icons.filter_list, size: 35.0),
                  onPressed: () {
                    modalfiltro(context);
                  })
              : Container(),
          (capa == null)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      if (List<String>.from(usuario['alunos']).length > 1) {
                        modalaluno(context);
                      }
                    },
                    child: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: (!kIsWeb && fotoaluno != null)
                                  ? CachedNetworkImageProvider(fotoaluno)
                                  : (fotoaluno != null)
                                      ? NetworkImage(fotoaluno)
                                      : AssetImage('images/picture.png')as ImageProvider,
                              fit: BoxFit.cover),
                        )),
                  ),
                )
              : Container(),
        ],
      ),
      drawer: Drawer(
        child: (capa == null)
            ? Menu(usuario, alunodocument, unidade, logomenu)
            : Container(),
      ),
      body: Stack(
        children: <Widget>[
          Row(
            children: [
              (MediaQuery.of(context).size.width > 950 &&
                      unidade != null &&
                      alunodocument != null)
                  ? Card(
                      child: Container(
                          width: 300.0,
                          child:
                              Menu(usuario, alunodocument, unidade, logomenu)),
                    )
                  : Container(),
              (MediaQuery.of(context).size.width > 950)
                  ? Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: VerticalDivider(
                        thickness: 1.0,
                      ),
                    )
                  : Container(),

              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    (version != null && versaoLoja != null)
                        ? Layout().bannerNovaVersao(version, versaoLoja)
                        : Container(),
                    Expanded(
                      child: StreamBuilder<List<DocumentSnapshot>>(
                          stream: bloc.outputList,
                          builder: (context, publicacoesxxx) {
                            return (publicacoesxxx.data != null)
                                ? ListView.builder(
                                    itemCount: publicacoesxxx.data!.length,
                                    shrinkWrap: true,
                                    controller: listScrollController,
                                    itemBuilder: (context, index) {
                                      var item = publicacoesxxx.data![index];
                                      bool aprovado = (!moderacao ||
                                          (item['enviar'] != null &&
                                              item['enviar']));
                                      return (aprovado)
                                          ? ItemPublicacao(usuario, item, false,
                                              moderacao, alunodocument)
                                          : Container();
                                    })
                                : Center(
                                    child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Cores().corprincipal),
                                  ));
                          }),
                    ),
                  ],
                ),
              ),
              (MediaQuery.of(context).size.width > 950)
                  ? Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: VerticalDivider(
                        thickness: 1.0,
                      ),
                    )
                  : Container(),

              (MediaQuery.of(context).size.width > 950)
                  ? Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 15.0, right: 15.0),
                        child: Column(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: Column(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                Pesquisa().irpara(
                                                    CalendarioLista(usuario,
                                                        alunodocument, false),
                                                    context);
                                              },
                                              child: Card(
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 12.0,
                                                                  right: 12.0,
                                                                  top: 5.0),
                                                          child: Layout().titulo(
                                                              'Calendário')),
                                                      Text(
                                                          'Próximos Compromissos'),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8.0,
                                                                right: 8.0),
                                                        child: Divider(
                                                          color: Colors.white,
                                                          thickness: 1.0,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            height:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    width: 2.0,
                                                                    color: Cores()
                                                                        .corprincipal)),
                                                            child: alunodocument !=
                                                                    null
                                                                ? FutureBuilder<
                                                                        QuerySnapshot>(
                                                                    future: FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'Calendario')
                                                                        .where(
                                                                            "parametrosbusca",
                                                                            arrayContainsAny:
                                                                                parametrosbusca)
                                                                        .orderBy(
                                                                            'datacomparar',
                                                                            descending:
                                                                                false)
                                                                        .get(),
                                                                    builder: (BuildContext
                                                                            context,
                                                                        AsyncSnapshot<QuerySnapshot>
                                                                            snapshot) {
                                                                      if (snapshot
                                                                          .hasError) {
                                                                        print(snapshot
                                                                            .error);
                                                                        return Text(
                                                                            'Isto é um erro. Por gentileza, contate o suporte.');
                                                                      }
                                                                      switch (snapshot
                                                                          .connectionState) {
                                                                        case ConnectionState
                                                                            .waiting:
                                                                          return Container();
                                                                        default:
                                                                          return (snapshot.data!.docs.length >= 1)
                                                                              ? ListView(
                                                                                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                                                                                    return (document['datacomparar'].toDate().month == DateTime.now().month && DateTime.now().compareTo(document['datacomparar'].toDate()) == -1) ? itemevento(document) : Container();
                                                                                  }).toList(),
                                                                                )
                                                                              : Text('Sem Novos Compromissos');
                                                                      }
                                                                    })
                                                                : Container(),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )),
                                      cardMensagens(),
                                    ],
                                  ),
                                )),
                            Card()
                          ],
                        ),
                      ),
                    )
                  : Container()
              //    ( MediaQuery.of(context).size.width > 800)   ?  Flexible(flex: 1, child: Container()) : Container(),
            ],
          ),
          StreamBuilder<bool>(
            stream: bloc.outputrodinha,
            initialData: false,
            builder: (context, rodinha) {
              return (rodinha.data!)
                  ? Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Cores().corprincipal)),
                      ),
                    )
                  : Container();
            },
          ),
          bodymensagens(),
          bodynotificacaoportal(),
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
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              : Container()
        ],
      ),
      floatingActionButton: (capa == null)
          ? floatingactionbar(Icons.edit, "Incluir", context)
          : Container(),
    );
  }

  Widget cardMensagens() {
    return Expanded(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Pesquisa().irpara(
                  MensagemWebPais(usuario, alunodocument, false), context);
            },
            child: Card(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 12.0, top: 15.0),
                        child: Layout().titulo('Novas Mensagens')),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Divider(
                        color: Colors.white,
                        thickness: 1.0,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  width: 2.0, color: Cores().corprincipal)),
                          child: (mensagensnovas.isNotEmpty)
                              ? ListView.builder(
                                  itemCount: mensagensnovas.length,
                                  itemBuilder:
                                      (BuildContext context, int index) =>
                                          Layout().itemMensagemTela(
                                              mensagensnovas[index],
                                              usuario,
                                              false,
                                              'pais',
                                              context,
                                              null))
                              : Align(
                                  alignment: Alignment.center,
                                  child:
                                      Text('Sem Mensagens Novas No Momento.'),
                                ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  itemfiltro(texto, filtro) {
    return InkWell(
        onTap: () {
          Navigator.pop(context);
          Pesquisa().irpara(
              MainFiltro(filtro, texto, usuario, parametrosbusca, alunodocument,
                  moderacao, unidade: '',),
              context);
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

  itemaluno(alunodoc) {
    return InkWell(
        onTap: () {
          ultimodoc = '' as DocumentSnapshot;
          documentsList.clear();
          buscarparametrosbusca(alunodoc.documentID);
          buscarfuncionalidades();
          Navigator.pop(context);
          Pesquisa().sendAnalyticsEvent(tela: Nomes().trocarFilhos);
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 35.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                alunodoc['nome'],
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ));
  }

  modalaluno(context) {
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
                  'Visualizar Agenda de:',
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
              (alunos.length > 1)
                  ? Column(
                      children: alunos.map((DocumentSnapshot document) {
                        return Container(
                            width: MediaQuery.of(context).size.width,
                            child: itemaluno(document));
                      }).toList(),
                    )
                  : Container(),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ));
      },
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
              (alunodocument['curso'] == 'EI' && cuidados)
                  ? itemfiltro('Cuidados', 'cuidado')
                  : Container(),
              itemfiltro('Documentos', 'documento'),
              itemfiltro('Enquetes', 'enquete'),
              itemfiltro('Fotos e Atividades', 'diario'),
              itemfiltro('Informativos', 'bilhete'),
              itemfiltro('Lembretes', 'lembrete'),
              (recados)
                  ? itemfiltro('Recados para Professor', 'recado')
                  : Container(),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ));
      },
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
                    leading: new Icon(Icons.description),
                    title: new Text('Lembrete na minha agenda'),
                    onTap: () {
                      Navigator.pop(context);
                      floatingaction(context);
                    }),
                (mensagens)
                    ? ListTile(
                        hoverColor: Cores().corprincipal.withOpacity(0.2),
                        leading: new Icon(Icons.send),
                        title: new Text('Mensagem Direta'),
                        onTap: () {
                          Navigator.pop(context);
                          if (kIsWeb) {
                            Pesquisa().irpara(
                                MensagemWebPais(usuario, alunodocument, false),
                                context);
                          } else {
                            Pesquisa().irpara(
                                MensagensPais(usuario, alunodocument), context);
                          }
                        })
                    : Container(),
                (recados)
                    ? ListTile(
                        hoverColor: Cores().corprincipal.withOpacity(0.2),
                        leading: new Icon(Icons.mode_edit),
                        title: new Text('Recado para Professor'),
                        onTap: () {
                          Navigator.pop(context);
                          Pesquisa()
                              .irpara(RecadosPara(alunodocument), context);
                        },
                      )
                    : Container(),
              ],
            ),
          );
        });
  }

  Widget floatingactionbar(icon, tip, context) {
    return FloatingActionButton(
        backgroundColor: Cores().corprincipal,
        onPressed: () {
          if (capa != null) {
            setState(() {
              capa = '';
            });
          } else {
            modalbottom(context);
          }
        },
        tooltip: tip,
        child: Icon(icon));
  }

  void floatingaction(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RecadosAdd(alunodocument, usuario, '' as DocumentSnapshot)));
  }

  Widget bodymensagens() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: (mensagem)
          ? Layout().itemnovamensagem(
              context,
              "Você tem nova mensagem",
              (kIsWeb)
                  ? MensagemWebPais(usuario, alunodocument, false)
                  : MensagensPais(usuario, alunodocument))
          : Container(),
    );
  }

  Widget bodynotificacaoportal() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: (notificacaoportal != null && notificacaoportal)
          ? Layout().itemnovamensagem(
              context, "Você tem nova notificação", NotificacoesPortal(usuario))
          : Container(),
    );
  }

  Widget itemevento(DocumentSnapshot doc) {
    return GestureDetector(
      onTap: () {
        Pesquisa()
            .irpara(CalendarioLista(usuario, alunodocument, false), context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(left: 20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today),
                Layout().titulo(
                    Pesquisa().getData1(doc['datacomparar'].toDate()) +
                        '-' +
                        doc['hora'],
                    smallSize: true),
                SizedBox(
                  width: 8.0,
                ),
                Expanded(
                  child: Container(
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
                  ),
                )
              ],
            ),
            Divider(
              thickness: 0.5,
            )
          ],
        ),
      ),
    );
  }

  verificarhorario() {
    horastring = Pesquisa().getHora();
    horastring = horastring.replaceAll(RegExp(':'), '');
    hora = int.parse(horastring);
    if (horariopublicacao) {
      if (hora > 1745) {
        horacerta = true;
      } else {
        horacerta = false;
      }
    } else {
      horacerta = true;
    }
  }

  buscaralunos() {
    List<String>.from(usuario['alunos']).forEach((element) {
      FirebaseFirestore.instance
          .collection(Nomes().alunosbanco)
          .doc(element)
          .snapshots()
          .listen((value) {
        if (!alunos.contains(value)) {
          setState(() {
            alunos.add(value);
          });
        }
      });
    });
  }

  buscarparametrosbusca(aluno) async {
    parametrosbusca.clear();
    FirebaseFirestore.instance
        .collection(Nomes().alunosbanco)
        .doc(aluno)
        .snapshots()
        .listen((alunodoc) async {
      setState(() {
        alunodocument = alunodoc;
        unidade = alunodoc['unidade'];
        buscarlogounidade(unidade);
        fotoaluno = alunodoc['foto'];
        parametrosbusca.add('Todas');
        parametrosbusca.add(alunodoc['unidade']);
        if (alunodoc['ano'].contains(Pesquisa().getAno())) {
          parametrosbusca.add(alunodoc['curso'] + ' - ' + alunodoc['unidade']);
          parametrosbusca.add(alunodoc['turma'] + ' - ' + alunodoc['unidade']);
        }
        parametrosbusca.add(alunodoc.id);

        userObject.plataforma = usuario['platform'];
        userObject.curso = alunodoc['curso'];
        userObject.turma = alunodoc['turma'];
        userObject.unidade = alunodoc['unidade'];

        userObject.parentesco = usuario['parentesco'];
        userObject.responsavelfinanceiro = usuario['responsavelfinanceiro'];
      });
      buscarfuncionalidades();
      if (!kIsWeb) {
        await notificacoes(unidade, alunodoc['curso'], alunodoc['turma']);
      }

      _getPublicacoes();
    });
  }

  notificacoes(unid, cur, tur) async {
    if (kIsWeb) {
      return;
    } else {
      _savedevicetoken();
    }
    _fcm.subscribeToTopic(Nomes().push + "2022");
    usuario.reference.update({
      "notificacoes": FieldValue.arrayUnion([Nomes().push + "2022"])
    });
    _fcm.subscribeToTopic(Pesquisa().replaceforpush(unid) + "2022");
    usuario.reference.update({
      "notificacoes":
          FieldValue.arrayUnion([Pesquisa().replaceforpush(unid) + "2022"])
    });
    _fcm.subscribeToTopic(cur + Pesquisa().replaceforpush(unid) + "2022");
    usuario.reference.update({
      "notificacoes": FieldValue.arrayUnion(
          [cur + Pesquisa().replaceforpush(unid) + "2022"])
    });
    _fcm.subscribeToTopic(Pesquisa().replaceforpush(tur) +
        Pesquisa().replaceforpush(unid) +
        "2022");
    usuario.reference.update({
      "notificacoes": FieldValue.arrayUnion([
        Pesquisa().replaceforpush(tur) +
            Pesquisa().replaceforpush(unid) +
            "2022"
      ])
    });
    if (usuario['removernotificacoes'] != null &&
        List<String>.from(usuario['removernotificacoes']).isNotEmpty) {
      List<String>.from(usuario['removernotificacoes']).forEach((element) {
        _fcm.unsubscribeFromTopic(element);
        usuario.reference.update({
          "notificacoes": FieldValue.arrayRemove([element])
        });
      });
    }
  }

  _getPublicacoes() async {
    FirebaseFirestore.instance
        .collection(Nomes().publicacoesbanco)
        .where('enviar', isEqualTo: true)
        .where("parametrosbusca", arrayContainsAny: parametrosbusca)
        .orderBy("datacomparar", descending: true)
        .limit(count)
        .snapshots()
        .listen((query) {
      if (query.docs.length > 0) {
        ultimodoc = query.docs.last;
      }
      setState(() {
        documentsList = query.docs;
      });
      bloc.inputList.add(documentsList);
      bloc.inputrodinha.add(false);
      if (documentsList.isNotEmpty) {
        bloc.inputList.add(documentsList);
      }
    });
  }

  _getMorePublicacoes() async {
    // if (!_morePublicacoesAvailable || _gettingMorePublicacoes) return;
    // _gettingMorePublicacoes = true;

    Query q = FirebaseFirestore.instance
        .collection(Nomes().publicacoesbanco)
        .where('enviar', isEqualTo: true)
        .where("parametrosbusca", arrayContainsAny: parametrosbusca)
        .orderBy("datacomparar", descending: true)
        .startAfterDocument(ultimodoc)
        .limit(count);
    QuerySnapshot querySnapshot = await q.get();

    if (querySnapshot.docs.length > 0) {
      ultimodoc = querySnapshot.docs.last;
    }
    // _morePublicacoesAvailable = querySnapshot.documents.length > 0;
    documentsList.addAll(querySnapshot.docs);
    //   _gettingMorePublicacoes = false;

    bloc.inputList.add(documentsList);
    bloc.inputrodinha.add(false);
    if (documentsList.isNotEmpty) {
      bloc.inputList.add(documentsList);
    }
    setState(() {});
  }

  buscarnovasmensagens() {
    listenmsg = FirebaseFirestore.instance
        .collection(Nomes().mensagensbanco)
        .where('origem', isEqualTo: usuario.id)
        .where('nova', isEqualTo: 'pais')
        .snapshots()
        .listen((docs) {
      if (docs.docs.length > 0) {
        setState(() {
          mensagem = true;
          mensagensnovas.addAll(docs.docs);
        });
      } else {
        setState(() {
          mensagem = false;
        });
      }
    });
  }

  buscarnovanotificacaoportal() {
    listennotificacaoportal = FirebaseFirestore.instance
        .collection(Nomes().publicacoesportal)
        .where('email', isEqualTo: usuario['email'])
        .where('lida', isEqualTo: false)
        .snapshots()
        .listen((docs) {
      if (docs.docs.length > 0) {
        setState(() {
          notificacaoportal = true;
        });
      } else {
        setState(() {
          notificacaoportal = false;
        });
      }
    });
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
        if (!mounted) {
          return;
        }
        ;
        setState(() {
          versaoLoja = value['android'];
        });
      }
    });
  }
}
