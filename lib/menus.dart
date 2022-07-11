import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:scalifra/horario.dart';
import 'package:scalifra/notificacoesportal.dart';

import 'avaliacoes.dart';
import 'perfil.dart';
import 'calendario/calendariolista.dart';
import 'downloads/downloads.dart';
import 'cardapios/cardapio.dart';
import 'design.dart';
import 'layout.dart';
import 'mainescola.dart';
import 'pesquisa.dart';
import 'temasdomes.dart';

class Menu extends StatefulWidget {
  final DocumentSnapshot usuario, alunodoc;
  final String unidade, logo;

  Menu(this.usuario, this.alunodoc, this.unidade, this.logo);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  String version='', buildNumber='';
  bool aniversariantes = false,
      aniversariantesapenasescola = true,
      mostrarTurma = false,
      cardapios = false,
      avaliacoes = false,
      horarios = false,
      encerrarmenu = false,
      portaldoaluno = false,
      portaldoresponsavel = false;

  @override
  void initState() {
    super.initState();
    buscafuncionalidades();
    if (!kIsWeb) {
      pegarversao();
    }
  }

  @override
  Widget build(BuildContext context) {
    return drawermain();
  }

  Widget drawermain() {
    return Container(
      color: Colors.white,
      child: ListView(
        children: <Widget>[
          Layout().menuheader(widget.usuario, widget.logo, context),
          Divider(color: Cores().corprincipal, thickness: 0.5),
          (widget.usuario != null &&
                  widget.usuario['controle'] == Nomes().controle)
              ? Layout().itemmenu("Trocar para Funcionário",
                  Icons.remove_red_eye, MainEscola(widget.usuario), context)
              : Container(),
          Layout().itemmenu("Notificações", Icons.add_alert,
              NotificacoesPortal(widget.usuario), context),
          (avaliacoes)
              ? Layout().itemmenu(
              "Avaliações",
              Icons.school_outlined,
              Avaliacoes(widget.usuario, false, false, widget.alunodoc),
              context)
              : Container(),
          Layout().itemmenu("Calendário", Icons.calendar_today,
              CalendarioLista(widget.usuario, widget.alunodoc, false), context),
          (cardapios)
              ? Layout().itemmenu(
                  "Cardápios",
                  Icons.restaurant_menu,
                  Cardapio(widget.usuario, false, false, widget.alunodoc),
                  context)
              : Container(),
          Layout().itemmenu(
              "Downloads",
              Icons.folder_special,
              Downloads(false, false, widget.usuario, widget.alunodoc),
              context),
          (horarios)
              ? Layout().itemmenu(
                  "Horários",
                  Icons.access_time,
                  Horario(widget.usuario, false, false, widget.alunodoc),
                  context)
              : Container(),
          Layout().itemmenu("Perfil do Aluno", Icons.info_outline,
              Perfil(widget.alunodoc, false, mostrarTurma), context),
          (portaldoaluno && widget.alunodoc['curso'] != 'EI')
              ? Layout().itemmenuportal("Portal do Aluno", Icons.table_chart,
                  () {
                  Pesquisa().abrirportalweb('Aluno', widget.alunodoc,
                      widget.usuario, widget.unidade, context);
                  Pesquisa().sendAnalyticsEvent(tela: Nomes().portaldoaluno);
                }, context)
              : Container(),
          (kIsWeb) ? Container() :  Layout().itemmenu("Temas do Mês", Icons.picture_in_picture_outlined,
              TemasdoMes(), context),
          (encerrarmenu != null && encerrarmenu)
              ? Layout().sair(context)
              : Container(),
          Divider(color: Cores().corprincipal, thickness: 0.5),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Pesquisa().launchURL('https://www.scalifra.org.br/', context);},
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
          Layout().footerdesenvolvidopor(),
          (!kIsWeb) ? Layout().footerversao(version, buildNumber) : Container(),
        ],
      ),
    );
  }

  void buscafuncionalidades() {
    FirebaseFirestore.instance
        .collection('Funcionalidades')
        .doc(widget.unidade)
        .get()
        .then((doc) {
      if (this.mounted && doc != null) {
        setState(() {
          aniversariantes = doc['aniversariantes'];
          mostrarTurma = doc['mostrarTurma'];
          encerrarmenu = doc['encerrarmenu'];
          aniversariantesapenasescola = doc['aniversariantesapenasescola'];
          if (List<String>.from(doc['cardapios'])
              .contains(widget.alunodoc['curso'])) {
            cardapios = true;
          }
          if (List<String>.from(doc['avaliacoes'])
              .contains(widget.alunodoc['curso'])) {
            avaliacoes = true;
          }
          if (List<String>.from(doc['horarios'])
              .contains(widget.alunodoc['curso'])) {
            horarios = true;
          }
        });
      }
    });

    FirebaseFirestore.instance
        .collection('Unidades')
        .doc(widget.unidade)
        .get()
        .then((doc) {
      if (this.mounted) {
        setState(() {
          if (doc['linkportalaluno'] != null &&
              doc['linkportalaluno'].isNotEmpty) {
            portaldoaluno = true;
          }
          if (doc['linkportalfinanceiro'] != null &&
              doc['linkportalfinanceiro'].isNotEmpty) {
            portaldoresponsavel = true;
          }
        });
      }
    });
  }

  Future<void> pegarversao() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }
}
