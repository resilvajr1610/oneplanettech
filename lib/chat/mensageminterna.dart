import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:universal_html/html.dart' as html;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../design.dart';
import '../layout.dart';
import '../pesquisa.dart';


class Mensageminterna extends StatefulWidget {
  final DocumentSnapshot usuario;
  final DocumentSnapshot outrouserdoc;

  Mensageminterna(this.usuario, this.outrouserdoc);

  @override
  _MensageminternaState createState() => _MensageminternaState();
}

class _MensageminternaState extends State<Mensageminterna> {
  TextEditingController mensagemcontroller = TextEditingController();

  // late html.File videoweb, pdfweb, fileimageFromWeb;
  late File imagem, pdfapp;
  String nova='', emissor='', nomeoutrouser='';
  String token='';
  bool teclado = false;
  late Uint8List imagebytes;
  List<String> ids = [];

  @override
  void initState() {
    super.initState();
    ids = [widget.usuario.id, widget.outrouserdoc.id];
    ids.sort();
print(widget.outrouserdoc);
    setState(() {
      if(widget.outrouserdoc['sobrenome'] != null){
        nomeoutrouser =
            widget.outrouserdoc['nome'] + ' ' +  widget.outrouserdoc['sobrenome'] ?? '';
      } else {
        nomeoutrouser =
            widget.outrouserdoc['nome'];
      }

      token = widget.outrouserdoc['token'];
    });

    FirebaseFirestore.instance
        .collection(Nomes().mensagensinternasbanco)
        .doc(ids[0] + ids[1])
        .get()
        .then((doc) {
      if (doc.exists) {
        if (doc['novamsg'] == widget.usuario.id) {
          Map<String, dynamic> map = Map();
          map['novamsg'] = "lida";
          FirebaseFirestore.instance
              .collection(Nomes().mensagensinternasbanco)
              .doc(ids[0] + ids[1])
              .update(map);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Layout().appbar('Chat Interno'),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 3, left: 20.0),
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Layout().texto(
                        nomeoutrouser, 20.0,
                        FontWeight.normal, Cores().corprincipal,
                        align: TextAlign.start,
                        height: 5,
                        overflow: TextOverflow.ellipsis,
                        textDecoration: TextDecoration.none,
                        maxLines: 1
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection(Nomes().conversasinternasbanco)
                        .where("mensagemid", isEqualTo: ids[0] + ids[1])
                        .orderBy("createdAt", descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return Text(
                            'Isto é um erro. Por gentileza, contate o suporte.');
                      }
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return Text("Sem conexão");
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                        default:
                          return (snapshot.data!.docs.length >= 1)
                              ? ListView(
                                  reverse: true,
                                  children: snapshot.data!.docs
                                      .map((DocumentSnapshot document) {
                                    return Layout().itemmensageminterna(document, widget.usuario, context);
                                  }).toList(),
                                )
                              : Container();
                      }
                    }),
              ),

              bottomlayout(),
            ],
          ),
        ],
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
                (!kIsWeb)
                    ? ListTile(
                        leading: new Icon(Icons.camera_alt),
                        title: new Text('Câmera'),
                        onTap: () {
                          Navigator.pop(context);
                          tirarfoto();
                        })
                    : Container(),
                ListTile(
                    leading: new Icon(Icons.photo),
                    title: new Text('Galeria de Fotos'),
                    onTap: () {
                      Navigator.pop(context);
                      pegarfoto();
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
                          gravarmensagem('PDF');
                        }
                      });
                    } else {
                      // getFileWeb();
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<FilePickerResult?> getFile() async {
    var pickedFiles = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf']);
    return pickedFiles;
  }

  // getImageWeb() async {
  //   html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  //   uploadInput.multiple = false;
  //   uploadInput.draggable = true;
  //   uploadInput.accept = 'image/*';
  //   uploadInput.click();
  //   html.document.body?.append(uploadInput);
  //   uploadInput.onChange.listen((e) {
  //     final files = uploadInput.files;
  //     final file = files![0];
  //     final reader = new html.FileReader();
  //
  //     reader.onLoadEnd.listen((e) {
  //       var _bytesData =
  //           Base64Decoder().convert(reader.result.toString().split(",").last);
  //       setState(() {
  //         fileimageFromWeb = file;
  //         imagebytes = _bytesData;
  //       });
  //       gravarmensagem('Foto');
  //     });
  //     reader.readAsDataUrl(file);
  //   });
  //   uploadInput.remove();
  // }

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
  //     gravarmensagem('PDF');
  //   });
  //   uploadInput.remove();
  // }

  Future tirarfoto() async {
    var image = await ImagePicker().getImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 600,
        maxHeight: 600);
    setState(() {
      imagem = File(image!.path);
    });
    gravarmensagem('Foto');
  }

  Widget bottomlayout() {
    return Container(
      height: 55,
      color: Colors.grey[100],
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Icon(Icons.attach_file),
            ),
            color: Cores().corprincipal,
            onPressed: () {
              modalbottom(context);
            },
          ),
          SizedBox(width: 16),
          Expanded(
            child: CupertinoTextField(
              controller: mensagemcontroller,
              placeholder: "Digite sua mensagem aqui",
              maxLines: 10,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              // decoration: BoxDecoration(border: Border.all(color: Colors.grey),
            ),
          ),
          SizedBox(
            width: 6.0,
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (mensagemcontroller.text.isNotEmpty) {
                gravarmensagem(mensagemcontroller.text);
              } else {
                Layout()
                    .dialog1botao(context, "Ups", "Escreva a mensagem");
              }
            },
            color: mensagemcontroller.text.isEmpty
                ? Colors.grey
                : Cores().corprincipal,
          ),
          SizedBox(
            width: 6.0,
          ),
        ],
      ),
    );
  }

  Future pegarfoto() async {
    if (!kIsWeb) {
      var image = await ImagePicker().getImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 600,
          maxHeight: 600);
      setState(() {
        imagem = File(image!.path);
      });
      gravarmensagem('Foto');
    } else {
      // getImageWeb();
    }
  }

  enviarnotificacao() {
    if (!Pesquisa().saboudom() &&
        int.parse(Pesquisa().getHora().replaceAll(RegExp(':'), '')) >
            Nomes().horanotificacaoinicial &&
        int.parse(Pesquisa().getHora().replaceAll(RegExp(':'), '')) <
            Nomes().horanotificacaofinal) {
      Pesquisa().enviarnotificacaotoken(
          token, 'Nova mensagem');
    }
  }

  gravarmensagem(msg) {
    if (msg == 'Foto') {
      salvarMensagemFoto();
    } else if (msg == 'PDF') {
      salvarMensagemPDF();
    } else {
      salvarMensagem();
    }

    Map<String, dynamic> mapConversa = Map<String, dynamic>();

    mapConversa['para'] = widget.outrouserdoc.id;
    mapConversa['novamsg'] = widget.outrouserdoc.id;
    mapConversa['emissor'] = widget.usuario.id;
    mapConversa['buscaparametros'] = [ids[0], ids[1]];
    mapConversa['user1'] = ids[0];
    mapConversa['user2'] = ids[1];
    mapConversa['mensagem'] = msg;
    mapConversa['datacomparar'] = DateTime.now();
    mapConversa['data'] = Pesquisa().getDataeHora();
    mapConversa['nomeuser1'] = widget.usuario['nome'];
    mapConversa['nomeuser2'] = widget.outrouserdoc['nome'];
    mapConversa['fotouser1'] = widget.usuario['foto'];
    mapConversa['fotouser2'] = widget.outrouserdoc['foto'];

    FirebaseFirestore.instance
        .collection(Nomes().mensagensinternasbanco)
        .doc(ids[0] + ids[1])
        .set(mapConversa);
  }

  salvarMensagem() {
    Map<String, dynamic> map = Map();

    map['data'] = Pesquisa().getDataeHora();
    map['emissor'] = widget.usuario.id;
    map['mensagem'] = mensagemcontroller.text.trim();
    map['mensagemid'] = ids[0] + ids[1];
    map['createdAt'] = DateTime.now().toIso8601String();
    map['datacomparar'] = DateTime.now();
    FirebaseFirestore.instance
        .collection(Nomes().conversasinternasbanco)
        .add(map)
        .then((document) {
      enviarnotificacao();
      setState(() {
        mensagemcontroller.clear();
      });
    });
  }

  salvarMensagemFoto() {
    if (!kIsWeb) {
      String nomeImagem =
          "Mensagens/Fotos/" + DateTime.now().toIso8601String() + ".jpg";
      Reference storageReference =
          FirebaseStorage.instance.ref().child(nomeImagem);
      if (imagem != null) {
        //StorageUploadTask uploadTask = storageReference.putFile(imagem);

        // uploadTask.onComplete.then((value) {
        //   value.ref.getDownloadURL().then((value) {
        //     Map<String, dynamic> map = Map();
        //
        //     map['data'] = Pesquisa().getDataeHora();
        //     map['emissor'] = widget.usuario.id;
        //     map['mensagemid'] = ids[0] + ids[1];
        //     map['foto'] = value.toString();
        //     map['createdAt'] = DateTime.now().toIso8601String();
        //     map['datacomparar'] = DateTime.now();
        //     Firestore.instance
        //         .collection(Nomes().conversasinternasbanco)
        //         .add(map)
        //         .then((document) {
        //       enviarnotificacao();
        //       setState(() {
        //         mensagemcontroller.text = "";
        //       });
        //     });
        //   });
        // });
      }
    } else {
      Map<String, dynamic> map = Map();
      map['data'] = Pesquisa().getDataeHora();
      map['emissor'] = widget.usuario.id;
      map['mensagemid'] = ids[0] + ids[1];
      map['createdAt'] = DateTime.now().toIso8601String();
      map['datacomparar'] = DateTime.now();
      FirebaseFirestore.instance
          .collection(Nomes().conversasinternasbanco)
          .add(map)
          .then((document) async {
        enviarnotificacao();
        String nomearquivo =
            "Mensagens/Fotos/" + DateTime.now().toIso8601String() + ".jpg";

        Uri imageUri = await Pesquisa().salvarfileweb(nomearquivo, imagebytes);

        String linkfoto = imageUri.toString();
        await document.update({"foto": linkfoto});
        setState(() {
          mensagemcontroller.text = "";
        });
      });
    }
  }

  salvarMensagemPDF() {
    if (!kIsWeb) {
      String nomeImagem =
          "Mensagens/PDF/" + DateTime.now().toIso8601String() + ".pdf";
      // StorageReference storageReference =
      //     FirebaseStorage.instance.ref().child(nomeImagem);
      // StorageUploadTask uploadTask = storageReference.putFile(pdfapp);
      // uploadTask.onComplete.then((value) {
      //   value.ref.getDownloadURL().then((pdfurl) {
      //     Map<String, dynamic> map = Map();
      //     map['data'] = Pesquisa().getDataeHora();
      //     map['emissor'] = widget.usuario.id;
      //     map['mensagemid'] = ids[0] + ids[1];
      //     map['documento'] = pdfurl.toString();
      //     map['createdAt'] = DateTime.now().toIso8601String();
      //     map['datacomparar'] = DateTime.now();
      //     FirebaseFirestore.instance
      //         .collection(Nomes().conversasinternasbanco)
      //         .add(map)
      //         .then((document) async {
      //       enviarnotificacao();
      //       setState(() {
      //         mensagemcontroller.text = "";
      //       });
      //     });
      //   });
      // });
    } else {
      Map<String, dynamic> map = Map();
      map['data'] = Pesquisa().getDataeHora();
      map['emissor'] = widget.usuario.id;
      map['mensagemid'] = ids[0] + ids[1];
      map['createdAt'] = DateTime.now().toIso8601String();
      map['datacomparar'] = DateTime.now();
      FirebaseFirestore.instance
          .collection(Nomes().conversasinternasbanco)
          .add(map)
          .then((document) async {
        enviarnotificacao();
        String nomearquivo =
            "Mensagens/PDF/" + DateTime.now().toIso8601String() + ".pdf";

        // Uri pdfUri = await Pesquisa().salvarfileweb(nomearquivo, pdfweb);
        // String link = pdfUri.toString();
        // await document.update({"documento": link});
        setState(() {
          mensagemcontroller.text = "";
        });
      });
    }
  }
}
