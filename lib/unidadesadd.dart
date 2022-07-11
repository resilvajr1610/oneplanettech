import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:universal_html/html.dart' as html;

import 'pesquisa.dart';
import 'design.dart';
import 'layout.dart';

class UnidadesAdd extends StatefulWidget {
  DocumentSnapshot usuario, unidadedoc;

  UnidadesAdd(this.usuario, this.unidadedoc);

  @override
  _UnidadesAddState createState() => _UnidadesAddState();
}

class _UnidadesAddState extends State<UnidadesAdd> {
  TextEditingController unidade = TextEditingController();
  TextEditingController linkportalaluno = TextEditingController();
  TextEditingController linkportalfinanceiro = TextEditingController();
  TextEditingController linkportalprofessor = TextEditingController();
  late File imagembarra, imagemmenu;
  late Uint8List imageFromWebBarra, imageFromWebMenu;
  //late html.File imagemwebbarra, imagemwebmenu;
  String logobarra='', logomenu='';

  @override
  void initState() {
    if (widget.unidadedoc != null) {
      unidade.text = widget.unidadedoc['unidade'];
      linkportalaluno.text = widget.unidadedoc['linkportalaluno'];
      linkportalfinanceiro.text = widget.unidadedoc['linkportalfinanceiro'];
      linkportalprofessor.text = widget.unidadedoc['linkportalprofessor'];
      logobarra = widget.unidadedoc['logobarra'];
      logomenu = widget.unidadedoc['logomenu'];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Layout()
          .appbarcombotaosimples(parasalvar, "Unidade", "Salvar", context, deletar: false,userid: ''),
      body: Row(
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Layout().caixadetexto(
                    1,
                    1,
                    TextInputType.text,
                    unidade,
                    "Nome da Unidade",
                    TextCapitalization.words,
                  ),
                  Layout().caixadetexto(
                    1,
                    2,
                    TextInputType.text,
                    linkportalaluno,
                    "Link Portal Aluno",
                    TextCapitalization.none,
                  ),
                  Layout().caixadetexto(
                    1,
                    2,
                    TextInputType.text,
                    linkportalfinanceiro,
                    "Link Portal Financeiro",
                    TextCapitalization.none,
                  ),
                  Layout().caixadetexto(
                    1,
                   2,
                    TextInputType.text,
                    linkportalprofessor,
                    "Link Portal Professor",
                    TextCapitalization.none,
                  ),
                  Layout().titulo('Incluir logo da unidade para barra'),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: () {
                        if (kIsWeb) {
                          // pegarImageweb('barra');
                        } else {
                          pegarfoto('barra');
                        }
                      },
                      child: Container(
                        width: 200.0,
                        height: 200.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: (imagembarra != null)
                                    ? FileImage(
                                        imagembarra,
                                      )
                                    : (imageFromWebBarra != null)
                                        ? MemoryImage(
                                            imageFromWebBarra,
                                          )
                                        : (logobarra != null)
                                            ? NetworkImage(logobarra)

                                           : AssetImage("images/camera.png") as ImageProvider,
                                fit: BoxFit.contain)),
                      ),
                    ),
                  ),
                  Layout().titulo('Incluir logo da unidade para menu'),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: () {
                        if (kIsWeb) {
                          // pegarImageweb('menu');
                        } else {
                          pegarfoto('menu');
                        }
                      },
                      child: Container(
                        width: 200.0,
                        height: 200.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: (imagemmenu != null)
                                    ? FileImage(
                                  imagemmenu,
                                )
                                    : (imageFromWebMenu != null)
                                    ? MemoryImage(
                                  imageFromWebMenu,
                                )
                                    : (logomenu != null)
                                    ? NetworkImage(logomenu)
                                    : AssetImage("images/camera.png")as ImageProvider,
                                fit: BoxFit.contain)),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
          Layout().espacolateral(context),
        ],
      ),
    );
  }

  Future pegarfoto(tipo) async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 600,
        maxHeight: 600);
    if(tipo == 'barra'){
    setState(() {
      imagembarra = File(image!.path);
    });}
    if(tipo == 'menu'){
      setState(() {
        imagemmenu = File(image!.path);
      });}
  }

  // pegarImageweb(tipo) async {
  //   html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  //   uploadInput.multiple = false;
  //   uploadInput.draggable = true;
  //   uploadInput.accept = 'image/*';
  //   uploadInput.click();
  //   html.document.body?.append(uploadInput);
  //   uploadInput.onChange.listen((e) async {
  //     final files = uploadInput.files;
  //     html.File file = files![0];
  //     final reader = new html.FileReader();
  //
  //     reader.onLoadEnd.listen((e) {
  //       var _bytesData =
  //           Base64Decoder().convert(reader.result.toString().split(",").last);
  //       if(tipo == 'barra') {
  //         setState(() {
  //           imageFromWebBarra = _bytesData;
  //           imagemwebbarra = file;
  //         });
  //       }
  //       if(tipo == 'menu'){
  //         setState(() {
  //           imageFromWebMenu = _bytesData;
  //           imagemwebmenu = file;
  //         });
  //       }
  //     });
  //     reader.readAsDataUrl(file);
  //   });
  //   uploadInput.remove();
  // }

  void parasalvar(BuildContext context) {
    if (unidade.text.trim().isEmpty) {
      Layout().dialog1botao(
          context, "Nome da Unidade", "Escreva o nome da unidade");
    }  else {
      Map<String, dynamic> map = Map();
      map['unidade'] = unidade.text.trim();
      map['linkportalaluno'] = linkportalaluno.text.trim();
      map['linkportalprofessor'] = linkportalprofessor.text.trim();
      map['linkportalfinanceiro'] = linkportalfinanceiro.text.trim();
      map['responsavel'] = widget.usuario['nome'];
      map['data'] = Pesquisa().getDataeHora();

      if(widget.unidadedoc ==  null){
        FirebaseFirestore.instance
            .collection(Nomes().unidadebanco)
            .doc(map['unidade'])
            .set(map);
      } else {
        FirebaseFirestore.instance
            .collection(Nomes().unidadebanco)
            .doc(map['unidade'])
            .update(map);
      }
      // Pesquisa().salvarunidade( map, imagembarra,imagemmenu ,imagemwebbarra, imagemwebmenu );
      Pesquisa().sendAnalyticsEvent(tela: Nomes().unidadeAdd);
      Layout().dialog1botaofecha2(context, 'Salva', 'A unidade foi salva');
    }
  }
}
