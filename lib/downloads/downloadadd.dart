import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
// import 'package:multiple_select/multi_drop_down.dart';
// import 'package:multiple_select/multiple_select.dart';
// import 'package:universal_html/html.dart' as html;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../design.dart';
import '../layout.dart';
import '../pesquisa.dart';

class DownloadAdd extends StatefulWidget {
  DocumentSnapshot usuario;

  DownloadAdd(this.usuario);

  @override
  _DownloadAddState createState() => _DownloadAddState();
}

class _DownloadAddState extends State<DownloadAdd> {
  TextEditingController nomearquivo = TextEditingController();
  TextEditingController nomelink = TextEditingController();
  TextEditingController link = TextEditingController();
  String data='', para='', turma='', unidade='';
  late File pdfapp;
  // late html.File pdfweb;
  late Uint8List pdfbytes;


  int opcao = 0;
  Map<int, Widget> opcoes = const <int, Widget>{
    0: Text("Unidades"),
    1: Text("Cursos"),
    2: Text("Turmas"),
  };
  String curso='';
  List<String> cursos = ['EI', 'EF1', 'EF2', 'EM', 'CN'];
  int opcaopublicacao = 0;
  Map<int, Widget> opcoespublicacao = const <int, Widget>{
    0: Text(
      "PDF",
      style: TextStyle(fontSize: 12.0),
    ),
    1: Text(
      "Link",
      style: TextStyle(fontSize: 12.0),
    ),
  };
  List<String> turmas = [];
  List<String> unidades = [];
  List unidadesselecionadas = [];
  // List<MultipleSelectItem> unidadesmultiple=[];
  List turmasselecionadas = [];
  // List<MultipleSelectItem> turmasmultiple=[];

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
        //       (index) => MultipleSelectItem.build(
        //     value: index,
        //     display: '${turmas[index]}',
        //     content: '${turmas[index]}',
        //   ),
        // );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Layout().appbar("Incluir Downloads"),
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
                  // (unidadesmultiple != null &&
                  //         opcao == 0 &&
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
                                    child: Layout().dropdownitem("Selecione o curso",
                                        curso, mudarCurso, cursos),
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
                                    child: Layout().dropdownitem("Selecione o curso",
                                        curso, mudarCurso, cursos),
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
                  Layout().titulo('Tipo de Publicação:'),
                  Layout().segmented(opcoespublicacao, opcaopublicacao,
                      mudaropcaopublicacao, context),
                  (opcaopublicacao == 0)
                      ? Column(
                          children: [
                            Container(
                                margin: EdgeInsets.only(top: 15.0),
                                child: Layout().caixadetexto(
                                  1,
                                  1,
                                  TextInputType.text,
                                  nomearquivo,
                                  "Nome do Arquivo",
                                  TextCapitalization.words,
                                )),
                            // (pdfapp != null || pdfweb != null)
                            //     ? Layout().titulo('PDF Carregado.')
                            //     : Container()
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                                margin: EdgeInsets.only(top: 15.0),
                                child: Layout().caixadetexto(
                                  1,
                                  1,
                                  TextInputType.text,
                                  nomelink,
                                  "Escreva o nome do link",
                                  TextCapitalization.words,
                                )),
                            Container(
                                margin: EdgeInsets.only(top: 15.0),
                                child: Layout().caixadetexto(
                                  1,
                                  1,
                                  TextInputType.text,
                                  link,
                                  "Escreva o link",
                                  TextCapitalization.none,
                                )),
                          ],
                        ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  (opcao == 0 && widget.usuario['perfil'] != 'Professor' && List<String>.from(widget.usuario['curso'])[0] == 'Todos') ?
                  botaosalvar(context) : Container(),
                  (opcao == 1 && widget.usuario['perfil'] != 'Professor') ?
                  botaosalvar(context) : Container(),
                  (opcao == 2) ? botaosalvar(context): Container()
                ],
              ),
            ),
          ),
          Layout().espacolateral(context),
        ],
      ),
      floatingActionButton: (opcaopublicacao == 1)
          ? Container()
          : FloatingActionButton(
              onPressed: () {
                  getFile();
              },
              child: Icon(Icons.folder)),
    );
  }
  //   getFileWeb() async {
  //   // html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  //   uploadInput.multiple = false;
  //   uploadInput.draggable = true;
  //   uploadInput.accept = '.pdf';
  //   uploadInput.click();
  //   html.document.body?.append(uploadInput);
  //   uploadInput.onChange.listen((e) {
  //     final files = uploadInput.files;
  //     final file = files![0];
  //     final reader = new html.FileReader();
  //     reader.onLoadEnd.listen((e) {
  //       var _bytesData =
  //           Base64Decoder().convert(reader.result.toString().split(",").last);
  //       setState(() {
  //         pdfweb = file;
  //         pdfbytes = _bytesData;
  //       });
  //     });
  //     reader.readAsDataUrl(file);
  //   });
  //   uploadInput.remove();
  // }
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

  void salvar(context) {
    if (opcaopublicacao == 0 && nomearquivo.text.isEmpty) {
      Layout().dialog1botao(
          context, 'Nome do arquivo', 'Escreva o nome do arquivo');
    } else if (opcaopublicacao == 1 && (nomelink.text.isEmpty ||
        link.text.isEmpty)) {
      Layout()
          .dialog1botao(context, 'Nome do link e link', 'Complete os campos');
    } else if



    (opcao == 0 && List<String>.from(widget.usuario['curso'])[0] == 'Todos' && widget.usuario['perfil'] != 'Professor') {
      salvarunidade(context);
    }

    if (opcao == 1) {
      if (unidade == null || unidade == 'Todas' || curso == null) {
        Layout().dialog1botao(
            context, "Unidade e Curso", "Selecione a unidade e o curso");
      } else {
        if (opcaopublicacao == 1) {
          salvarlinkcurso(widget.usuario['unidade'], context);
        }

        if (opcaopublicacao == 0) {
          // if (pdfapp == null && pdfweb == null) {
          //   Layout().dialog1botao(context, 'Arquivo', 'Selecione o arquivo');
          // } else {
          //   salvarpdfcurso(context);
          // }
        }
      }
    }

    if (opcao == 2) {
      if (turmasselecionadas.length == 0) {
        Layout().dialog1botao(context, "Turma", "Selecione a turma");
      } else {
        if (opcaopublicacao == 1) {
          salvarlinkturmas(context);
        }
        if (opcaopublicacao == 0) {
          // if (pdfapp == null && pdfweb == null) {
          //   Layout().dialog1botao(context, 'Arquivo', 'Selecione o arquivo');
          // } else {
          //   salvarpdfturmas(context);
          // }
        }
      }
    }
  }

  void salvarunidade(context) {
         if (unidadesselecionadas.length == 0 &&
        widget.usuario['unidade'] == "Todas as unidades") {
      Layout().dialog1botao(context, "Unidade", "Selecione a unidade");
    } else if (widget.usuario['unidade'] != "Todas as unidades") {
      if (opcaopublicacao == 1) {
        salvarlinkunidade(widget.usuario['unidade'], context);
      }
      if (opcaopublicacao == 0) {
        // if (pdfapp == null && pdfweb == null) {
        //   Layout().dialog1botao(context, 'Arquivo', 'Selecione o arquivo');
        // } else {
        //   salvarpdfunidade(widget.usuario['unidade'], context);
        // }
      }
    } else if (unidadesselecionadas.contains(0)) {
      if (opcaopublicacao == 1) {
        salvarlinkunidade('Todas', context);
      }
      if (opcaopublicacao == 0) {
        // if (pdfapp == null && pdfweb == null) {
        //   Layout().dialog1botao(context, 'Arquivo', 'Selecione o arquivo');
        // } else {
        //   salvarpdfunidade('Todas', context);
        // }
      }
    } else {
      if (opcaopublicacao == 1) {
        salvarlinkunidades(context);
      }
      if (opcaopublicacao == 0) {
        // if (pdfapp == null && pdfweb == null) {
        //   Layout().dialog1botao(context, 'Arquivo', 'Selecione o arquivo');
        // } else {
        //   salvarpdfunidades(context);
        // }
      }
    }
  }

  salvarpdfunidade(parametros, context) {
      Map<String, dynamic> map = Map();
      map['responsavel'] = widget.usuario['nome'];
      map['parametrosbusca'] = [parametros];
      map['unidade'] = parametros;
      map['createdAt'] = DateTime.now().toIso8601String();
      map['data'] = Pesquisa().hoje();
      map['datacomparar'] = DateTime.now();
      map['tipo'] = 'pdf';
      map['nome'] = nomearquivo.text;

      // Pesquisa().salvarfirebasepdf(Nomes().downloadsbanco, map, pdfapp, pdfweb);
      Layout().dialog1botaofecha2(context, 'Salvo', 'O download foi salvo');
  }

  salvarpdfunidades(context) {
    Map<String, dynamic> map = Map();
    map['responsavel'] = widget.usuario['nome'];
    map['createdAt'] = DateTime.now().toIso8601String();
    map['data'] = Pesquisa().hoje();
    map['datacomparar'] = DateTime.now();
    map['tipo'] = 'pdf';
    map['nome'] = nomearquivo.text;
    // Pesquisa().salvardownloadsunidades(map, pdfapp, pdfweb,
    //     indexturmas: unidadesselecionadas, unidades: unidades);
    Layout().dialog1botaofecha2(context, 'Salvo', 'O download foi salvo');
  }

  salvarpdfcurso(context) {
    Map<String, dynamic> map = Map();
    map['responsavel'] = widget.usuario['nome'];
    map['parametrosbusca'] = [curso + ' - ' + unidade];
    map['unidade'] = unidade;
    map['createdAt'] = DateTime.now().toIso8601String();
    map['data'] = Pesquisa().hoje();
    map['datacomparar'] = DateTime.now();
    map['tipo'] = 'pdf';
    map['nome'] = nomearquivo.text;

    // Pesquisa().salvarfirebasepdf(Nomes().downloadsbanco, map, pdfapp, pdfweb);
    Layout().dialog1botaofecha2(context, 'Salvo', 'O download foi salvo');
  }


  salvarpdfturmas(context) {
      Map<String, dynamic> map = Map();
      map['responsavel'] = widget.usuario['nome'];
      map['createdAt'] = DateTime.now().toIso8601String();
      map['data'] = Pesquisa().hoje();
      map['datacomparar'] = DateTime.now();
      map['tipo'] = 'pdf';
      map['unidade'] = unidade;
      map['nome'] = nomearquivo.text;
      // Pesquisa().salvardownloadsturmas(map, pdfapp, pdfweb,
      //     indexturmas: turmasselecionadas, turmas: turmas);
      Layout().dialog1botaofecha2(context, 'Salvo', 'O download foi salvo');
  }

  salvarlinkunidade(parametros, context) {
      Map<String, dynamic> map = Map();
      map['responsavel'] = widget.usuario['nome'];
      map['parametrosbusca'] = [parametros];
      map['unidade'] = parametros;
      map['createdAt'] = DateTime.now().toIso8601String();
      map['data'] = Pesquisa().hoje();
      map['datacomparar'] = DateTime.now();
      map['tipo'] = 'link';
      map['nome'] = nomelink.text;
      map['link'] = link.text;
      Pesquisa().salvarfirebase(Nomes().downloadsbanco, map, null, null);
      Layout().dialog1botaofecha2(context, 'Salvo', 'O download foi salvo');
  }
  salvarlinkcurso(parametros, context) {
    Map<String, dynamic> map = Map();
    map['responsavel'] = widget.usuario['nome'];
    map['parametrosbusca'] = [curso + ' - ' + unidade];
    map['unidade'] = unidade;
    map['createdAt'] = DateTime.now().toIso8601String();
    map['data'] = Pesquisa().hoje();
    map['datacomparar'] = DateTime.now();
    map['tipo'] = 'link';
    map['nome'] = nomelink.text;
    map['link'] = link.text;
    Pesquisa().salvarfirebase(Nomes().downloadsbanco, map, null, null);
    Layout().dialog1botaofecha2(context, 'Salvo', 'O download foi salvo');
  }

  salvarlinkunidades(context) {
      Map<String, dynamic> map = Map();
      map['responsavel'] = widget.usuario['nome'];
      map['createdAt'] = DateTime.now().toIso8601String();
      map['data'] = Pesquisa().hoje();
      map['datacomparar'] = DateTime.now();
      map['tipo'] = 'link';
      map['nome'] = nomelink.text;
      map['link'] = link.text;

      Pesquisa().salvardownloadslinksunidades(map,
          indexunidade: unidadesselecionadas, unidades: unidades);
      Layout().dialog1botaofecha2(context, 'Salvo', 'O download foi salvo');

  }

  salvarlinkturmas(context) {
      Map<String, dynamic> map = Map();
      map['responsavel'] = widget.usuario['nome'];
      map['createdAt'] = DateTime.now().toIso8601String();
      map['data'] = Pesquisa().hoje();
      map['datacomparar'] = DateTime.now();
      map['tipo'] = 'link';
      map['unidade'] = unidade;
      map['nome'] = nomelink.text;
      map['link'] = link.text;

      Pesquisa().salvardownloadslinksturmas(map,
          indexturmas: turmasselecionadas, turmas: turmas);
      Layout().dialog1botaofecha2(context, 'Salvo', 'O download foi salvo');

  }

  Future<File?> getFile() async {
    if(!kIsWeb){
    final file = await FilePicker.platform.pickFiles(
        allowMultiple: true);
    setState(() {
      pdfapp = file as File;
    });
    }else{
      // getFileWeb();
    }
  }

  void mudardosegmento(val) {
    setState(() {
      opcao = val;
      curso = '';
    });
  }

  void mudaropcaopublicacao(val) {
    setState(() {
      opcaopublicacao = val;
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

    if (opcao == 2 && List<String>.from(widget.usuario['turma'])[0] == 'Todas') {
      buscarturmas(curso, unidade);
    }
  }

  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
    });
  }
}
