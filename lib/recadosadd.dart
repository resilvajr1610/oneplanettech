import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
//import 'package:universal_html/html.dart' as html;

import 'design.dart';
import 'layout.dart';
import 'pesquisa.dart';

class RecadosAdd extends StatefulWidget {
  DocumentSnapshot alunodoc, usuario, profe;


  RecadosAdd(this.alunodoc, this.usuario,  this.profe);

  @override
  _RecadosAddState createState() => _RecadosAddState();
}

class _RecadosAddState extends State<RecadosAdd> {
  String recado='', data='';
  List<Asset> images = [];
  late File imagem;
  late Uint8List imageFromWeb;

  @override
  void initState() {
    super.initState();
    data = Pesquisa().hoje();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Cores().corprincipal,
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              onPressed: () {
                if (recado == null || recado.isEmpty) {
                  Layout()
                      .dialog1botao(context, "Mensagem", "Escreva a mensagem");
                } else if (widget.profe == null){
                  Pesquisa().salvarLembrete(
                      widget.alunodoc, widget.usuario['nome'], recado, images, imageFromWeb, context);
                  Layout().dialog1pushreplacement(context, "Salvando Lembrete",
                      "Aguarde o carregamento na tela inicial.");
                  Pesquisa().sendAnalyticsEvent(tela: Nomes().lembreteAdd);
                } else if (widget.profe != null){

                  Pesquisa().salvarRecado(
                      widget.alunodoc, widget.profe, recado, images, imageFromWeb, context);
                  Layout().dialog1pushreplacement(context, "Salvando Recado",
                      "Aguarde o carregamento na tela inicial.");
                  Pesquisa().sendAnalyticsEvent(tela: Nomes().recadoAdd);
                }
              },
              child: Text(
                "Salvar",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    color: Colors.white),
              ),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
          ],
          title: Text(" "),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Layout().espacolateral(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    (widget.profe!= null)?  Text('Recado para:') : Container(),
                    (widget.profe!= null)? Layout().titulo(widget.profe['nome']) : Container(),
                    Layout().itemRecadoadd(widget.alunodoc['nome'],
                        widget.alunodoc['turma'], mudar, context),
                    (imageFromWeb != null)
                        ? Container(
                            height: 250.0,
                            width: 250.0,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: MemoryImage(imageFromWeb))),
                          )
                        : Container(),
                    (images.length > 0) ? mostrarimagens() : Container(),
                  ],
                ),
              ),
            ),
            Layout().espacolateral(context),
          ],
        ),
        floatingActionButton: Layout().floatingactionbar(
            pegarimagens, Icons.camera_alt, "Foto", context));
  }

  Future<void> pegarimagens() async {
    if (kIsWeb) {
      //pegarImageweb();
    } else {
      List<Asset> resultList = [];
      try {
        resultList = await MultiImagePicker.pickImages(
          maxImages: 30,
          enableCamera: true,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "fotos"),
          materialOptions: MaterialOptions(
            actionBarColor: "#0288D1",
            actionBarTitle: "Galeria",
            allViewTitle: "Todas as fotos",
            useDetailsView: false,
            selectCircleStrokeColor: "#000000",
          ),
        );
        setState(() {
          images = resultList;
        });
      } on Exception catch (e) {}
      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;
    }
  }

  // pegarImageweb() async {
  //   html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  //
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
  //       setState(() {
  //         imageFromWeb = _bytesData;
  //       });
  //     });
  //     reader.readAsDataUrl(file);
  //   });
  //   uploadInput.remove();
  // }

  Widget mostrarimagens() {
    return Column(
      children: <Widget>[
        Text('Pré-visualização em resolução menor.'),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.25,
          child: GridView.count(
            crossAxisCount: 1,
            scrollDirection: Axis.horizontal,
            children: List.generate(images.length, (index) {
              Asset asset = images[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      images.removeAt(index);
                    });
                  },
                  child: AssetThumb(
                    asset: asset,
                    width: 300,
                    height: 300,
                    quality: 15,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  void mudar(String text) {
    setState(() {
      recado = text;
    });
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty('imageFromWeb', imageFromWeb));
  }
}
