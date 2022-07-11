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
//import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'design.dart';
import 'layout.dart';
import 'pesquisa.dart';
import 'package:toast/toast.dart';

class Mensagem extends StatefulWidget {
  String para, paiuserid, alunoid;
  DocumentSnapshot usuario, professor;
  bool controle;

  Mensagem(this.para, this.usuario, this.alunoid, this.paiuserid, this.controle,
      {required this.professor});

  @override
  _MensagemState createState() => _MensagemState();
}

class _MensagemState extends State<Mensagem> {
  //FlutterAudioRecorder _recorder;
  //Recording _current;
  //RecordingStatus _currentStatus = RecordingStatus.Unset;
  TextEditingController mensagemcontroller = TextEditingController();

  // late html.File videoweb, pdfweb, fileimageFromWeb;
  late File imagem, audio, pdfapp;
  String nova='', emissor='', nome='';
  bool teclado = false, gravando = false, expandMsgDetails = true;
  late DocumentSnapshot paiuser, alunodoc;
  late Uint8List imagebytes;

  bool _keyboardIsVisible() {
    return !(MediaQuery.of(context).viewInsets.bottom == 0.0);
  }

  @override
  void initState() {
    super.initState();
   //inicializadorRecorder();
    nome = '';
    pegarpaidoc();

    pegaralunodoc();

    updatestatus();

    atualizarmsg();

    Pesquisa().sendAnalyticsEvent(tela: Nomes().mensagem);
  }

  void updatestatus() {
     if (widget.controle) {
      nova = 'pais';
      emissor = 'escola';
    } else {
      nova = 'escola';
      emissor = widget.paiuserid;
    }
  }

  void pegarpaidoc() {
    FirebaseFirestore.instance
        .collection(Nomes().usersbanco)
        .doc(widget.paiuserid)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          paiuser = doc;
        });
      }
    });
  }

  void pegaralunodoc() {
    FirebaseFirestore.instance
        .collection(Nomes().alunosbanco)
        .doc(widget.alunoid)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          alunodoc = doc;
        });
      }
    });
  }

  appbarMsg(nomebarra) {
    return AppBar(
      elevation: 0.0,
      backgroundColor: Cores().corprincipal,
      title: kIsWeb ? Text(nomebarra) : Text(nomebarra, style: TextStyle(fontSize: 14.0),),
      // actions: [
      //   IconButton(onPressed: () => expandDateAndUserMsg(), icon: Icon(Icons.remove_red_eye),)
      // ],
    );
  }

  void expandDateAndUserMsg() {
    setState(() {
      expandMsgDetails = !expandMsgDetails;
    });
  }

  @override
  void didUpdateWidget(Mensagem oldWidget) {
    pegarpaidoc();
    pegaralunodoc();
    updatestatus();
    atualizarmsg();
    super.didUpdateWidget(oldWidget);
  }

  void atualizarmsg() {
    if (widget.professor == null) {
      FirebaseFirestore.instance
          .collection(Nomes().mensagensbanco)
          .doc(widget.para + widget.paiuserid)
          .get()
          .then((doc) {
        alterarStatusNovo(doc);
      });
    } else {
      FirebaseFirestore.instance
          .collection(Nomes().mensagensbanco)
          .doc(
              widget.para + widget.professor.id + widget.paiuserid)
          .get()
          .then((doc) {
        alterarStatusNovo(doc);
      });
    }
  }

  void alterarStatusNovo(DocumentSnapshot doc) {
       if (doc.exists) {
      setState(() {
        nome = doc['nome'];
      });
      if (widget.controle &&
          doc['nova'] == 'escola' &&
          widget.usuario['perfil'] == doc['tipo']) {
        doc.reference.update({'nova': 'lida'});
      } else if (!widget.controle && doc['nova'] == 'pais') {
        doc.reference.update({'nova': 'lida'});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarMsg("Mensagem ${widget.para}"),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/fundowhats.png"),
                    fit: BoxFit.cover)),
          ),
          Column(
            children: <Widget>[
              (nome != null) ? Layout().titulo(nome) : Container(),
              (widget.professor == null && widget.para != 'Professor')
                  ? Expanded(
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection(Nomes().conversasbanco)
                              .where("tipo", isEqualTo: widget.para)
                              .where("origem", isEqualTo: widget.paiuserid)
                              .orderBy("createdAt", descending: true)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              print(snapshot.error);
                              return Text(
                                  'Isto é um erro. Por gentileza, contate o suporte.');
                            }
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                                return Text("Sem conexão");
                              case ConnectionState.waiting:
                                return Center();

                              case ConnectionState.waiting:
                                return Container();
                                break;

                              default:
                                return (snapshot.data!.docs.length >= 1)
                                    ? ListView(
                                        reverse: true,
                                        children: snapshot.data!.docs
                                            .map((DocumentSnapshot document) {
                                          return Layout().itemmensagem(
                                              document, paiuser, widget.controle, context, expandMsgDetails);
                                        }).toList(),
                                      )
                                    : Container();
                            }
                          }),
                    )
                  : Container(),
              (widget.professor != null)
                  ? Expanded(
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection(Nomes().conversasbanco)
                              .where("professorid",
                                  isEqualTo: widget.professor.id)
                              .where("origem", isEqualTo: widget.paiuserid)
                              .orderBy("createdAt", descending: true)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              print(snapshot.error);
                              return Text(
                                  'Isto é um erro. Por gentileza, contate o suporte.');
                            }
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                                return Text("Sem conexão");
                              case ConnectionState.waiting:
                                return Center();

                              case ConnectionState.waiting:
                                return Container();
                                break;

                              default:
                                return (snapshot.data!.docs.length >= 1)
                                    ? ListView(
                                        reverse: true,
                                        children: snapshot.data!.docs
                                            .map((DocumentSnapshot document) {
                                          return Layout().itemmensagem(
                                              document, paiuser, widget.controle, context, expandMsgDetails);
                                        }).toList(),
                                      )
                                    : Container();
                            }
                          }),
                    )
                  : Container(),
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
                      //getFileWeb();
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<FilePickerResult?> getFile() async {
    final file = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf']);
    return file;
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
  //     print('TESTE');
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
          Expanded(
            child: CupertinoTextField(
              controller: mensagemcontroller,
              placeholder: "Mensagem",
              maxLines: 10,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            ),
          ),
          SizedBox(
            width: 6.0,
          ),
          (_keyboardIsVisible() || kIsWeb)
              ? IconButton(
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
                )
              : GestureDetector(
                  onLongPress: () {
                    if (!gravando) {
                      iniciargravar();
                    }
                  },
                  onTap: () {
                    if (gravando) {
                      parargravar();
                    } else {
                      Toast.show("Clique e segure para gravar.", textStyle: context,
                          duration: Toast.lengthLong, gravity: Toast.bottom);
                    }
                  },
                  child: Icon(
                    (!gravando) ? Icons.mic : Icons.stop,
                    color: (!gravando) ? Cores().corprincipal : Colors.red,
                    size: 30.0,
                  ),
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
      //getImageWeb();
    }
  }

  iniciargravar() async {
    try {
      Toast.show("Gravando.", textStyle: context,
          duration: Toast.lengthLong, gravity: Toast.bottom);
      // await _recorder.start();
      // var recording = await _recorder.current(channel: 0);
      // setState(() {
      //   _current = recording;
      //   gravando = true;
      // });
      const tempo = const Duration(minutes: 1);
      // Future.delayed(tempo, () {
      //   if (_currentStatus == RecordingStatus.Recording) {
      //     parargravar();
      //   }
      // });
    } catch (e) {
      print(e);
    }
  }

  parargravar() async {
    // var result = await _recorder.stop();
    //
    // setState(() {
    //   audio = File(result.path);
    //   _current = result;
    //   _currentStatus = _current.status;
    //   gravando = false;
    // });
    gravarmensagem('Áudio');
  }

  enviarnotificacao() {
    if (!widget.controle &&
        widget.para != 'Professor' &&
        !Pesquisa().saboudom() &&
        int.parse(Pesquisa().getHora().replaceAll(RegExp(':'), '')) >
            Nomes().horanotificacaoinicial &&
        int.parse(Pesquisa().getHora().replaceAll(RegExp(':'), '')) <
            Nomes().horanotificacaofinal) {
      String topic = Nomes().controle + widget.para + alunodoc['unidade'];
      Pesquisa().enviarnotificacao(topic, 'Nova mensagem');
    } else if (!widget.controle &&
        widget.para == 'Professor' &&
        !Pesquisa().saboudom() &&
        int.parse(Pesquisa().getHora().replaceAll(RegExp(':'), '')) >
            Nomes().horanotificacaoinicial &&
        int.parse(Pesquisa().getHora().replaceAll(RegExp(':'), '')) <
            Nomes().horanotificacaofinal) {
      Pesquisa()
          .enviarnotificacaotoken(widget.professor['token'], 'Nova mensagem');
    } else if (widget.controle) {
      Pesquisa().enviarnotificacaotoken(paiuser['token'], 'Nova mensagem');
    }
  }

  gravarmensagem(msg) {

    if (msg == 'Foto') {
      salvarConversafoto();
    } else if (msg == 'PDF') {
      salvarconversapdf();
    } else if (msg == 'Áudio') {
      salvarconversaaudio();
    } else {
      salvarConversa();
    }

    Map<String, dynamic> map = Map();
    map['origem'] = paiuser.id;
    map['nome'] = paiuser['nome'];
    map['aluno'] = alunodoc.id;
    map['unidade'] = alunodoc['unidade'];
    map['curso'] = alunodoc['curso'];
    map['turma'] = alunodoc['turma'];
    map['alunonome'] = alunodoc['nome'];
    map['logo'] = alunodoc['foto'];
    if (widget.professor != null) {
      map['professorid'] = widget.professor.id;
    }
    if (paiuser != null) {
      map['parentesco'] = paiuser['parentesco'];
    }
    map['data'] = Pesquisa().getDataeHora();
    map['para'] = widget.para;
    map['paraArray'] = FieldValue.arrayUnion([widget.para]);
    map['nova'] = nova;
    map['emissor'] = emissor;
    map['mensagem'] = msg;
    map['tipo'] = widget.para;
    map['createdAt'] = DateTime.now().toIso8601String();
    map['datacomparar'] = DateTime.now();
    if (widget.professor != null) {
      FirebaseFirestore.instance
          .collection(Nomes().mensagensbanco)
          .doc(
          widget.para + widget.professor.id + paiuser.id)
          .set(map);
    } else {
    }
    FirebaseFirestore.instance
        .collection(Nomes().mensagensbanco)
        .doc(widget.para + paiuser.id)
        .set(map);
  }

  salvarConversa() {
    Map<String, dynamic> map = Map();
    map['origem'] = paiuser.id;
    if (widget.professor != null) {
      map['professorid'] = widget.professor.id;
    }
    map['data'] = Pesquisa().getDataeHora();
    map['emissor'] = emissor;
    map['mensagem'] = mensagemcontroller.text;
    map['tipo'] = widget.para;
    map['responsavel'] = widget.usuario['nome'];
    map['createdAt'] = DateTime.now().toIso8601String();
    map['datacomparar'] = DateTime.now();
    FirebaseFirestore.instance
        .collection(Nomes().conversasbanco)
        .add(map)
        .then((document) {
      enviarnotificacao();
      setState(() {
        mensagemcontroller.text = "";
      });
    });
  }

  salvarConversafoto() {
    if (!kIsWeb) {
      String nomeImagem = "Mensagens/Fotos/" +
          alunodoc['unidade'] +
          '/' +
          DateTime.now().toIso8601String() +
          ".jpg";
      Reference storageReference =
          FirebaseStorage.instance.ref().child(nomeImagem);
      if (imagem != null) {
        // StorageUploadTask uploadTask = storageReference.putFile(imagem);

        // uploadTask.onComplete.then((value) {
        //   value.ref.getDownloadURL().then((value) {
        //     Map<String, dynamic> map = Map();
        //     map['origem'] = paiuser.id;
        //     if (widget.professor != null) {
        //       map['professorid'] = widget.professor.id;
        //     }
        //     map['data'] = Pesquisa().getDataeHora();
        //     map['para'] = paiuser.id;
        //     map['paraArray'] = FieldValue.arrayUnion([widget.para]);
        //     map['emissor'] = emissor;
        //     map['responsavel'] = widget.usuario['nome'];
        //     map['foto'] = value.toString();
        //     map['tipo'] = widget.para;
        //     map['createdAt'] = DateTime.now().toIso8601String();
        //     map['datacomparar'] = DateTime.now();
        //     FirebaseFirestore.instance
        //         .collection(Nomes().conversasbanco)
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
      map['origem'] = paiuser.id;
      if (widget.professor != null) {
        map['professorid'] = widget.professor.id;
      }
      map['data'] = Pesquisa().getDataeHora();
      map['para'] = paiuser.id;
      map['paraArray'] = FieldValue.arrayUnion([widget.para]);
      map['emissor'] = emissor;
      map['tipo'] = widget.para;
      map['createdAt'] = DateTime.now().toIso8601String();
      map['datacomparar'] = DateTime.now();
      FirebaseFirestore.instance
          .collection(Nomes().conversasbanco)
          .add(map)
          .then((document) async {
        enviarnotificacao();
        String nomearquivo = "Mensagens/Fotos/" +
            alunodoc['unidade'] +
            '/' +
            DateTime.now().toIso8601String() +
            ".jpg";

        Uri imageUri = await Pesquisa().salvarfileweb(nomearquivo, imagebytes);

        String linkfoto = imageUri.toString();
        await document.update({"foto": linkfoto});
        setState(() {
          mensagemcontroller.text = "";
        });
      });
    }
  }

  salvarconversapdf() {
    if (!kIsWeb) {
      String nomeImagem = "Mensagens/PDF/" +
          alunodoc['unidade'] +
          '/' +
          DateTime.now().toIso8601String() +
          ".pdf";
      Reference storageReference =
          FirebaseStorage.instance.ref().child(nomeImagem);
      // StorageUploadTask uploadTask = storageReference.putFile(pdfapp);
      // uploadTask.onComplete.then((value) {
      //   value.ref.getDownloadURL().then((pdfurl) {
      //     print('chegou ate aqui 2');
      //     print(pdfurl);
      //     Map<String, dynamic> map = Map();
      //     map['origem'] = paiuser.id;
      //     if (widget.professor != null) {
      //       map['professorid'] = widget.professor.id;
      //     }
      //     map['data'] = Pesquisa().getDataeHora();
      //     map['para'] = paiuser.id;
      //     map['paraArray'] = FieldValue.arrayUnion([widget.para]);
      //     map['responsavel'] = widget.usuario['nome'];
      //     map['emissor'] = emissor;
      //     map['documento'] = pdfurl.toString();
      //     map['tipo'] = widget.para;
      //     map['createdAt'] = DateTime.now().toIso8601String();
      //     map['datacomparar'] = DateTime.now();
      //     FirebaseFirestore.instance
      //         .collection(Nomes().conversasbanco)
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
      map['origem'] = paiuser.id;
      if (widget.professor != null) {
        map['professorid'] = widget.professor.id;
      }
      map['data'] = Pesquisa().getDataeHora();
      map['para'] = paiuser.id;
      map['paraArray'] = FieldValue.arrayUnion([widget.para]);
      map['emissor'] = emissor;
      map['tipo'] = widget.para;
      map['createdAt'] = DateTime.now().toIso8601String();
      map['datacomparar'] = DateTime.now();
      FirebaseFirestore.instance
          .collection(Nomes().conversasbanco)
          .add(map)
          .then((document) async {
        enviarnotificacao();
        String nomearquivo = "Mensagens/PDF/" +
            alunodoc['unidade'] +
            '/' +
            DateTime.now().toIso8601String() +
            ".pdf";

        //Uri pdfUri = await Pesquisa().salvarfileweb(nomearquivo, pdfweb);
        // String link = pdfUri.toString();
        // await document.update({"documento": link});
        setState(() {
          mensagemcontroller.text = "";
        });
      });
    }
  }

  salvarconversaaudio() {
    String nomeImagem = "AudiosMensagens/" +
        alunodoc['unidade'] +
        '/' +
        DateTime.now().toIso8601String() +
        ".wav";

    Reference storageReference =
        FirebaseStorage.instance.ref().child(nomeImagem);
    // StorageUploadTask uploadTask = storageReference.putFile(audio);
    // uploadTask.onComplete.then((value) {
    //   value.ref.getDownloadURL().then((value) {
    //     Map<String, dynamic> map = Map();
    //     map['origem'] = paiuser.id;
    //     if (widget.professor != null) {
    //       map['professorid'] = widget.professor.id;
    //     }
    //     map['data'] = Pesquisa().getDataeHora();
    //     map['para'] = paiuser.id;
    //     map['paraArray'] = [widget.para];
    //     map['emissor'] = emissor;
    //     map['audio'] = value.toString();
    //     map['tipo'] = widget.para;
    //     map['createdAt'] = DateTime.now().toIso8601String();
    //     map['datacomparar'] = DateTime.now();
    //     map['responsavel'] = widget.usuario['nome'];
    //     FirebaseFirestore.instance
    //         .collection(Nomes().conversasbanco)
    //         .add(map)
    //         .then((document) {
    //       enviarnotificacao();
    //     });
    //   });
    // });
  }

  // inicializadorRecorder() async {
  //   try {
  //     if (await FlutterAudioRecorder.hasPermissions) {
  //       String customPath = '/flutter_audio_recorder_';
  //       Directory appDocDirectory = await getApplicationDocumentsDirectory();
  //       if (Platform.isIOS) {
  //         appDocDirectory = await getApplicationDocumentsDirectory();
  //       } else {
  //         appDocDirectory = (await getExternalStorageDirectory())!;
  //       }
  //
  //       // can add extension like ".mp4" ".wav" ".m4a" ".aac"
  //       customPath = appDocDirectory.path +
  //           customPath +
  //           DateTime.now().millisecondsSinceEpoch.toString();
  //
  //       // .wav <---> AudioFormat.WAV
  //       // .mp4 .m4a .aac <---> AudioFormat.AAC
  //       // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
  //       _recorder =
  //           FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);
  //
  //       await _recorder.initialized;
  //       // after initialization
  //       var current = await _recorder.current(channel: 0);
  //       // should be "Initialized", if all working fine
  //       setState(() {
  //         _current = current;
  //         _currentStatus = current.status;
  //       });
  //     } else {
  //       Scaffold.of(context).showSnackBar(
  //           new SnackBar(content: new Text("Por favor, aceite as permissões")));
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}
