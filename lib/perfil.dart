import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:universal_html/html.dart' as html;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'design.dart';
import 'layout.dart';
import 'login/login.dart';
import 'login/loginweb.dart';
import 'pesquisa.dart';

class Perfil extends StatefulWidget {
  DocumentSnapshot alunodoc;
  bool controle, mostrarTurma;

  Perfil(this.alunodoc, this.controle, this.mostrarTurma);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  late File imagem;
  late Uint8List imageFromWeb;

  String foto='';

  @override
  void initState() {
    super.initState();
    if(widget.alunodoc!= null){
      Pesquisa().sendAnalyticsEvent(tela: Nomes().perfilbanco);
    if (widget.controle) {
      buscardadosuser();
    } else{
      buscardadosaluno();
    }}
  }

  buscardadosuser() {
    FirebaseFirestore.instance
        .collection(Nomes().usersbanco)
        .doc(widget.alunodoc.id)
        .snapshots()
        .listen((value) {
      setState(() {
        if (!mounted) {
          return;
        }
        if (value['foto'] != null) {
          foto = value['foto'];
        }
      });
    });
  }

  buscardadosaluno() {
    FirebaseFirestore.instance
        .collection(Nomes().alunosbanco)
        .doc(widget.alunodoc.id)
        .snapshots()
        .listen((value) {
      setState(() {
        if (!mounted) {
          return;
        }
        if (value['foto'] != null) {
          foto = value['foto'];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout()
          .appbarcombotaosimples(parasalvar, 'Meu Perfil', 'Salvar', context),
      body: Row(
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: Card(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Layout().titulo((widget.controle)
                          ? 'Foto do Funcionário'
                          : "Foto do Aluno"),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                          onTap: () {
                            if(widget.controle){
                              if (kIsWeb) {
                                //pegarImageweb();
                              } else {
                                pegarfoto();
                              }
                            }
                          },
                          child: Container(
                            width: 200.0,
                            height: 200.0,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: (imagem != null)
                                        ? FileImage(
                                            imagem,
                                          )
                                        : (imageFromWeb != null)
                                            ? MemoryImage(
                                                imageFromWeb,
                                              )
                                            : (foto != null)
                                                ? NetworkImage(foto)
                                                : AssetImage(
                                                    "images/picture.png") as ImageProvider,
                                    fit: BoxFit.cover)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nome:"),
                            Layout().titulo(widget.alunodoc['nome']),
                            Divider(
                              color: Cores().corprincipal,
                              thickness: 1.0,
                            ),
                            (widget.controle)
                                ? Text("Código do funcionário:")
                                : Text("Código do aluno:"),
                            (widget.alunodoc['codigoaluno'] != null)
                                ? Layout().titulo(widget.alunodoc['codigoaluno'])
                                : Container(),
                            (widget.alunodoc['codigo'] != null)
                                ? Layout().titulo(widget.alunodoc['codigo'])
                                : Container(),
                            Divider(
                              color: Cores().corprincipal,
                              thickness: 1.0,
                            ),
                            Text("Unidade:"),
                            Layout().titulo(widget.alunodoc['unidade']),
                            Divider(
                              color: Cores().corprincipal,
                              thickness: 1.0,
                            ),
                            (!widget.controle)
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Curso:"),
                                      (!widget.controle &&
                                              widget.alunodoc['curso'] != null)
                                          ? Layout()
                                              .titulo(widget.alunodoc['curso'])
                                          : Container(),
                                      Divider(
                                        color: Cores().corprincipal,
                                        thickness: 1.0,
                                      ),
                                      (widget.mostrarTurma) ? Text("Turma:") : Container(),
                                      (!widget.controle &&
                                              widget.alunodoc['turma'] != null && widget.mostrarTurma)
                                          ? Layout()
                                              .titulo(widget.alunodoc['turma'])
                                          : Container(),
                                    ],
                                  )
                                : Container(),
                            (widget.controle)
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Perfil:"),
                                      Layout().titulo(widget.alunodoc['perfil']),
                                      Divider(
                                        color: Cores().corprincipal,
                                        thickness: 1.0,
                                      ),
                                      (widget.alunodoc['horainicio'] != null &&
                                              widget.alunodoc['horafim'] != null)
                                          ? Text("Expediente:")
                                          : Container(),
                                      (widget.alunodoc['horainicio'] != null &&
                                              widget.alunodoc['horafim'] != null)
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                (widget.alunodoc['horainicio'] !=
                                                        null)
                                                    ? Layout().titulo(widget
                                                        .alunodoc['horainicio'])
                                                    : Container(),
                                                Text('às'),
                                                (widget.alunodoc['horainicio'] !=
                                                        null)
                                                    ? Layout().titulo(widget
                                                        .alunodoc['horafim'])
                                                    : Container(),
                                              ],
                                            )
                                          : Container(),
                                      (widget.alunodoc['horainicio2'] != null &&
                                          widget.alunodoc['horafim2'] != null)
                                          ? Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          (widget.alunodoc['horainicio2'] !=
                                              null)
                                              ? Layout().titulo(widget
                                              .alunodoc['horainicio2'])
                                              : Container(),
                                          Text('às'),
                                          (widget.alunodoc['horainicio2'] !=
                                              null)
                                              ? Layout().titulo(widget
                                              .alunodoc['horafim2'])
                                              : Container(),
                                        ],
                                      )
                                          : Container(),
                                      (widget.alunodoc['horainicio3'] != null &&
                                          widget.alunodoc['horafim3'] != null)
                                          ? Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          (widget.alunodoc['horainicio3'] !=
                                              null)
                                              ? Layout().titulo(widget
                                              .alunodoc['horainicio3'])
                                              : Container(),
                                          Text('às'),
                                          (widget.alunodoc['horainicio3'] !=
                                              null)
                                              ? Layout().titulo(widget
                                              .alunodoc['horafim3'])
                                              : Container(),
                                        ],
                                      )
                                          : Container(),
                                      (widget.alunodoc['horainicio'] != null &&
                                              widget.alunodoc['horafim'] != null)
                                          ? Divider(
                                        color: Cores().corprincipal,
                                              thickness: 1.0,
                                            )
                                          : Container(),
                                      (widget.alunodoc['componentes'] != null &&
                                              widget.alunodoc['componentes']
                                                  .isNotEmpty)
                                          ? Text("Componentes Pedagógicos:")
                                          : Container(),
                                      (widget.alunodoc['componentes'] != null &&
                                              widget.alunodoc['componentes']
                                                  .isNotEmpty)
                                          ? Column(
                                              children: List<String>.from(widget
                                                      .alunodoc['componentes'])
                                                  .map((componente) {
                                                return Layout()
                                                    .titulo(componente);
                                              }).toList(),
                                            )
                                          : Container(),
                                      (widget.alunodoc['componentes'] != null &&
                                              widget.alunodoc['componentes']
                                                  .isNotEmpty)
                                          ? Divider(
                                        color: Cores().corprincipal,
                                              thickness: 1.0,
                                            )
                                          : Container(),
                                      Text("Curso:"),
                                      (!widget.controle &&
                                              widget.alunodoc['curso'] != null)
                                          ? Layout()
                                              .titulo(widget.alunodoc['curso'])
                                          : Container(),
                                      (widget.controle &&
                                              widget.alunodoc['curso'] != null)
                                          ? Column(
                                              children: List<String>.from(
                                                      widget.alunodoc['curso'])
                                                  .map((curso) {
                                                return Layout().titulo(curso);
                                              }).toList(),
                                            )
                                          : Container(),
                                      Divider(
                                        color: Cores().corprincipal,
                                        thickness: 1.0,
                                      ),
                                      (widget.mostrarTurma)  ? Text("Turma:"): Container(),
                                      (!widget.controle &&
                                              widget.alunodoc['turma'] != null && widget.mostrarTurma)
                                          ? Layout()
                                              .titulo(widget.alunodoc['turma'])
                                          : Container(),
                                      (widget.controle &&
                                              widget.alunodoc['turma'] != null)
                                          ? Column(
                                              children: List<String>.from(
                                                      widget.alunodoc['turma'])
                                                  .map((turma) {
                                                return Layout().titulo(turma);
                                              }).toList(),
                                            )
                                          : Container(),
                                    ],
                                  )
                                : Container(),
                            SizedBox(
                              height: 20.0,
                            ),
                            FlatButton(
                                color: Colors.red,
                                onPressed: () {
                                  showCupertinoDialog(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoAlertDialog(
                                          title:
                                              new Text("Deseja encerrar sessão?"),
                                          content: new Text(
                                              "Será necessário fazer login com e-mail e senha novamente."),
                                          actions: <Widget>[
                                            CupertinoDialogAction(
                                              isDefaultAction: true,
                                              child: Text("OK",
                                                  style: TextStyle(
                                                      color:
                                                          Cores().corprincipal)),
                                              onPressed: () {
                                                Pesquisa().sendAnalyticsEvent(tela: Nomes().sair);
                                                FirebaseAuth.instance
                                                    .signOut()
                                                    .then((user) {
                                                  Navigator.pop(context);
                                                  if (kIsWeb) {
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                LoginWeb()));
                                                  } else {
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                Login()));
                                                  }
                                                });
                                              },
                                            ),
                                            CupertinoDialogAction(
                                              isDefaultAction: true,
                                              child: Text("CANCELAR",
                                                  style: TextStyle(
                                                      color:
                                                          Cores().corprincipal)),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                },
                                child: Text('Encerrar sessão'))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Layout().espacolateral(context),
        ],
      ),
    );
  }

  void parasalvar(BuildContext context) {
    if (widget.controle) {
      Pesquisa().salvarFuncionarioDetalhe(
          widget.alunodoc, imagem, imageFromWeb, context);
      Layout().dialog1botao(context, "Salvo", "Foto do funcionário foi salva.");
    } else {
      Pesquisa()
          .salvarAlunoDetalhe(widget.alunodoc, imagem, imageFromWeb, context);
      Layout().dialog1botao(context, "Salvo", "Foto do aluno foi salva.");
    }
  }

  Future pegarfoto() async {
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
  }

  // pegarImageweb() async {
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
  //       setState(() {
  //         imageFromWeb = _bytesData;
  //       });
  //     });
  //     reader.readAsDataUrl(file);
  //   });
  //   uploadInput.remove();
  // }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty('imageFromWeb', imageFromWeb));
  }
}
