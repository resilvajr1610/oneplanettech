import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../blocs.dart';
import '../design.dart';
import '../itens/itempublicacao.dart';
import '../layout.dart';
import '../pesquisa.dart';

class MainFiltro extends StatefulWidget {
  String filtro, texto, unidade='';
  DocumentSnapshot usuario, aluno;
  bool moderacao;
  List<String> parametrosbusca;

  MainFiltro(this.filtro, this.texto, this.usuario, this.parametrosbusca,
      this.aluno, this.moderacao,
      {required this.unidade});

  @override
  _MainFiltroState createState() => _MainFiltroState();
}

class _MainFiltroState extends State<MainFiltro> {
  late ScrollController listScrollController;
  final bloc = BlocProvider.getBloc<MainFiltroBloc>();
  late DocumentSnapshot ultimodoc;
  int count = 20;
  List<DocumentSnapshot> documentsList = [];

  @override
  void initState() {
    super.initState();
    print(widget.parametrosbusca);

 if (widget.filtro == 'todasaspublicacoes') {
      buscartodaspublicacoes();
      listScrollController = ScrollController();
      listScrollController.addListener(() {
        if (listScrollController.offset >=
                listScrollController.position.maxScrollExtent &&
            !listScrollController.position.outOfRange) {
          bloc.inputrodinha.add(true);
          buscartodaspublicacoes();
        }
      });
    } else if (widget.filtro == 'cuidado') {
      buscarcuidados();
      listScrollController = ScrollController();
      listScrollController.addListener(() {
        if (listScrollController.offset >=
                listScrollController.position.maxScrollExtent &&
            !listScrollController.position.outOfRange) {
          bloc.inputrodinha.add(true);
          buscarcuidados();
        }
      });
    }   else {

   buscarpublicacoes();
   listScrollController = ScrollController();
   listScrollController.addListener(() {
     if (listScrollController.offset >=
         listScrollController.position.maxScrollExtent &&
         !listScrollController.position.outOfRange) {
       bloc.inputrodinha.add(true);
       buscarpublicacoes();
     }
   });


 }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().filtroTopico);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundomaisclaro,
      appBar: Layout().appbar(widget.texto),
      body: Stack(
        children: <Widget>[
          Row(
            children: [
              Layout().espacolateral(context),
              Expanded(
                child: Column(
                  children: [

               Expanded(
                            child: StreamBuilder<List<DocumentSnapshot>>(
                                stream: bloc.outputList,
                                builder: (context, publicacoesxxx) {
                                  return (publicacoesxxx.data != null)
                                      ? StreamBuilder<String>(
                                          stream: bloc.outputFiltro,
                                          builder: (context, filtro) {
                                            return ListView.builder(
                                                itemCount:
                                                    publicacoesxxx.data!.length,
                                                shrinkWrap: true,
                                                controller:
                                                    listScrollController,
                                                itemBuilder: (context, index) {
                                                  var item = publicacoesxxx
                                                      .data![index];
                                                  return ItemPublicacao(
                                                      widget.usuario,
                                                      item,
                                                      false,
                                                      widget.moderacao,
                                                      widget.aluno);
                                                });
                                          })
                                      : Center(
                                          child: CircularProgressIndicator(
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Cores().corprincipal),
                                        ));
                                }),
                          )

                  ],
                ),
              ),
              Layout().espacolateral(context),
            ],
          ),
          (widget.filtro != 'aguardandoaprovacao')
              ? StreamBuilder<bool>(
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
                )
              : Container(),
        ],
      ),
    );
  }

  correcaocaca() {
    FirebaseFirestore.instance
        .collection(Nomes().publicacoesbanco)
        .where("tipo", isEqualTo: 'cuidado')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        element.reference.update({'tipo': 'cuidados'});
      });
    });
  }

  buscarcuidados() async {
    if (ultimodoc == null) {
      documentsList.addAll((await FirebaseFirestore.instance
              .collection(Nomes().publicacoesbanco)
              .where("unidade", isEqualTo: widget.unidade)
              .where("parametrosbusca",
                  arrayContainsAny: widget.parametrosbusca)
              .where('tipo', isEqualTo: 'cuidado')
              .orderBy('datacomparar', descending: true)
              .limit(count)
              .get())
          .docs);
      if (documentsList.isNotEmpty) {
        ultimodoc = documentsList.last;
      }
    } else {
      documentsList.addAll((await FirebaseFirestore.instance
              .collection(Nomes().publicacoesbanco)
              .where("unidade", isEqualTo: widget.unidade)
              .where("parametrosbusca",
                  arrayContainsAny: widget.parametrosbusca)
              .where('tipo', isEqualTo: 'cuidado')
              .orderBy('datacomparar', descending: true)
              .limit(count)
              .startAfterDocument(ultimodoc)
              .get())
          .docs);
      if (documentsList.isNotEmpty) {
        ultimodoc = documentsList.last;
      }
    }
    bloc.inputList.add(documentsList);
    bloc.inputrodinha.add(false);
    if (documentsList.isNotEmpty) {
      bloc.inputList.add(documentsList);
    }
  }

  buscarpublicacoes() async {
    if (ultimodoc == null) {
      documentsList.addAll((await FirebaseFirestore.instance
              .collection(Nomes().publicacoesbanco)
              .where("parametrosbusca",
                  arrayContainsAny: widget.parametrosbusca)
              .where('tipo', isEqualTo: widget.filtro)
              .orderBy('datacomparar', descending: true)
              .limit(count)
              .get())
          .docs);
      if (documentsList.isNotEmpty) {
        ultimodoc = documentsList.last;
      }
    } else {
      documentsList.addAll((await FirebaseFirestore.instance
              .collection(Nomes().publicacoesbanco)
              .where("parametrosbusca",
                  arrayContainsAny: widget.parametrosbusca)
              .where('tipo', isEqualTo: widget.filtro)
              .orderBy('datacomparar', descending: true)
              .limit(count)
              .startAfterDocument(ultimodoc)
              .get())
          .docs);
      if (documentsList.isNotEmpty) {
        ultimodoc = documentsList.last;
      }
    }
    bloc.inputList.add(documentsList);
    bloc.inputrodinha.add(false);
    if (documentsList.isNotEmpty) {
      bloc.inputList.add(documentsList);
    }
  }

  buscartodaspublicacoes() async {
    if (ultimodoc == null) {
      documentsList.addAll((await FirebaseFirestore.instance
              .collection(Nomes().publicacoesbanco)
              .where("unidade", isEqualTo: widget.unidade)
              .orderBy('datacomparar', descending: true)
              .limit(count)
              .get())
          .docs);
      if (documentsList.isNotEmpty) {
        ultimodoc = documentsList.last;
      }
    } else {
      documentsList.addAll((await FirebaseFirestore.instance
              .collection(Nomes().publicacoesbanco)
              .where("unidade", isEqualTo: widget.unidade)
              .orderBy('datacomparar', descending: true)
              .limit(count)
              .startAfterDocument(ultimodoc)
              .get())
          .docs);
      if (documentsList.isNotEmpty) {
        ultimodoc = documentsList.last;
      }
    }
    bloc.inputList.add(documentsList);
    bloc.inputrodinha.add(false);
    if (documentsList.isNotEmpty) {
      bloc.inputList.add(documentsList);
    }
  }


}
