import 'package:file_picker/file_picker.dart';
// import 'package:multiple_select/multi_drop_down.dart';
// import 'package:multiple_select/multiple_select.dart';
// import 'package:universal_html/html.dart' as html;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../layout.dart';
import '../pesquisa.dart';
import '../design.dart';

class CardapioAdd extends StatefulWidget {
  final DocumentSnapshot usuario;

  CardapioAdd(this.usuario);

  @override
  _CardapioAddState createState() => _CardapioAddState();
}

class _CardapioAddState extends State<CardapioAdd> {
  late File imagem, pdfapp;
  String cardapio = "Selecione o tipo";
  List cardapios = [];
  List<String> turmas = [];
  List<String> unidades = [];
  List unidadesselecionadas = [];
  // List<MultipleSelectItem> unidadesmultiple=[];
  List turmasselecionadas = [];
  // List<MultipleSelectItem> turmasmultiple=[];
  String data='', para='', turma='', unidade='';
  // late html.File pdfweb, imagemweb;
  TextEditingController ctitulo = TextEditingController();

  int opcao = 0;
  Map<int, Widget> opcoes = const <int, Widget>{
    0: Text("Unidades"),
    1: Text("Cursos"),
    2: Text("Turmas"),
  };
  String curso='';
  List<String> cursos = [];

  @override
  void initState() {
    cardapios.add("Selecione o tipo");
    FirebaseFirestore.instance
        .collection(Nomes().tipocardapio)
        .orderBy("tipo")
        .get()
        .then((documents) {
      documents.docs.forEach((doc) {
        setState(() {
          cardapios.add(doc['tipo']);
        });
      });
    });

    if (widget.usuario['unidade'] == 'Todas as unidades') {
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
    } else {
      unidades.add(widget.usuario['unidade']);
      unidade = widget.usuario['unidade'];
      buscarcursos();
    }

    super.initState();
  }

  void buscarcursos() {
    FirebaseFirestore.instance
        .collection('Funcionalidades')
        .doc(unidade)
        .get()
        .then((value) {
      setState(() {
        cursos = List<String>.from(value['cardapios']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: Layout().appbarcombotaosimples(
      //     parasalvar, "Adicionar Cardápio", "Salvar", context),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Layout().titulo('Enviar para:'),
                  Layout().segmented(opcoes, opcao, mudardosegmento, context),
                  (opcao == 0 &&
                          widget.usuario['unidade'] == "Todas as unidades")
                      ? Layout().dropdownitem('Selecione a unidade', unidade,
                          (text) {
                          setState(() {
                            unidade = text;
                          });
                        }, unidades)
                      : Container(),
                  (opcao == 0 &&
                          widget.usuario['unidade'] != "Todas as unidades" &&
                          List<String>.from(widget.usuario['curso'])[0] ==
                              'Todos')
                      ? Layout().titulo(widget.usuario['unidade'])
                      : Container(),
                  (opcao == 1)
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  (cardapios != null && cardapios.length > 1)
                      ? Layout().dropdownitem(
                          "Todos", cardapio, mudarCardapio, cardapios)
                      : Container(),
                  Layout().caixadetexto(1, 3, TextInputType.text, ctitulo,
                      'Título do documento', TextCapitalization.sentences),
                  // (imagem == null &&
                  //         pdfapp == null &&
                  //         imagemweb == null &&
                  //         pdfweb == null)
                  //     ? Container()
                  //     : Layout().titulo('Arquivo anexado')
                ],
              ),
            ),
          ),
          Layout().espacolateral(context),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Cores().corprincipal,
        onPressed: () {
          modalbottom(context);
        },
        child: new Icon(
          Icons.attach_file,
          color: Colors.white,
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
                    leading: new Icon(Icons.photo),
                    title: new Text('Galeria de Imagens'),
                    onTap: () {
                      Navigator.pop(context);
                      pegarimagens();
                    }),
                ListTile(
                  leading: new Icon(Icons.picture_as_pdf),
                  title: new Text('Arquivo PDF'),
                  onTap: () {
                    Navigator.pop(context);
                    if (!kIsWeb) {
                      getFile().then((file) {
                        if (file != null) {
                          setState(() {
                            pdfapp = file as File;
                          });
                        }
                      });
                    } else {
                      //getFileWeb();
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> pegarimagens() async {
    if (!kIsWeb) {
      var image = await ImagePicker().getImage(
          source: ImageSource.gallery,
          imageQuality: 100,
          maxWidth: 600,
          maxHeight: 600);
      if (image != null) {
        setState(() {
          imagem = File(image.path);
        });
      }
    } else {
      // getImageWeb();
    }
  }

  Future<FilePickerResult?> getFile() async {
    final file = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,);
    return file;
  }

  // getFileWeb() async {
  //   html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  //   uploadInput.multiple = false;
  //   uploadInput.draggable = true;
  //   uploadInput.accept = '.pdf';
  //   uploadInput.click();
  //   html.document.body?.append(uploadInput);
  //   uploadInput.onChange.listen((e) {
  //     final files = uploadInput.files;
  //     final file = files![0];
  //     setState(() {
  //       pdfweb = file;
  //     });
  //   });
  //   uploadInput.remove();
  // }

  // void parasalvar(BuildContext context) {
  //   if (cardapios != null && cardapios.length > 1) {
  //     if (cardapio == "Selecione o tipo") {
  //       Layout().dialog1botao(
  //           context, "Tipo de cardápio", "Selecione o tipo de cardápio");
  //     }
  //   } else if (imagem == null &&
  //       pdfapp == null &&
  //       imagemweb == null &&
  //       pdfweb == null) {
  //     Layout().dialog1botao(context, "Nenhum arquivo selecionado", "  ");
  //   } else {
  //     if (opcao == 0 && unidade != null) {
  //       Pesquisa().salvarcardapioounidade(
  //           widget.usuario, unidade, imagem, imagemweb, pdfapp, pdfweb, ctitulo.text);
  //       Layout().dialog1botaofecha2(
  //           context, "Salvando", "Logo aparecerá em Cardápios. ");
  //     } else if (opcao == 0 && unidade == null) {
  //       Layout().dialog1botao(context, 'Unidade', 'Selecione a unidade');
  //     }
  //     if (opcao == 1 && curso != null) {
  //       Pesquisa().salvarcardapiocurso(
  //           widget.usuario, unidade, curso, imagem, imagemweb, pdfapp, pdfweb, ctitulo.text);
  //
  //       Layout().dialog1botaofecha2(
  //           context, "Salvando", "Logo aparecerá em Cardápios.");
  //     } else if (opcao == 1 && curso == null) {
  //       Layout().dialog1botao(context, 'Curso', 'Selecione o curso');
  //     }
  //
  //     if (opcao == 2) {
  //       if (turmasselecionadas.length == 0) {
  //         Layout().dialog1botao(context, "Turma", "Selecione a turma");
  //       } else {
  //         Pesquisa().salvarcardapioturmas(
  //             widget.usuario, unidade, imagem, imagemweb, pdfapp, pdfweb,  ctitulo.text,
  //             turmasSelecionadas: turmas, indexturmas: turmasselecionadas);
  //         Layout().dialog1botaofecha2(
  //             context, "Salvando", "Logo aparecerá em Cardápios.");
  //       }
  //     }
  //   }
  // }

  mudarCardapio(String text) {
    setState(() {
      cardapio = text;
    });
  }

  // getImageWeb() async {
  //   html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  //   uploadInput.multiple = false;
  //   uploadInput.draggable = true;
  //   uploadInput.accept = 'image/*';
  //   uploadInput.click();
  //   html.document.body?.append(uploadInput);
  //   uploadInput.onChange.listen((e) async {
  //     final files = uploadInput.files;
  //     html.File file = files![0];
  //     setState(() {
  //       imagemweb = file;
  //     });
  //   });
  //   uploadInput.remove();
  // }

  void mudardosegmento(val) {
    setState(() {
      opcao = val;
      curso = '';
    });
  }

  void buscarturmas(curs, uni) {
    turmas.clear();
    FirebaseFirestore.instance
        .collection(Nomes().turmabanco)
        .where('curso', isEqualTo: curs)
        .where('unidade', isEqualTo: uni)
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

  void mudarCurso(String text) {
    setState(() {
      turma = '';
      curso = text;
    });

    if (opcao == 2 &&
        List<String>.from(widget.usuario['turma'])[0] == 'Todas') {
      buscarturmas(curso, unidade);
    }
  }

  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
      curso = '';
      turma = '';
    });
    buscarcursos();
  }
}
