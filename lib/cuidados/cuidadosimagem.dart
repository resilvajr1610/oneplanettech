import 'dart:io';
import 'dart:typed_data';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as I;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs.dart';
import '../design.dart';
import 'package:csv/csv.dart';
import '../layout.dart';
import '../pesquisa.dart';

class CuidadosImagem extends StatefulWidget {
  @override
  _CuidadosImagemState createState() => _CuidadosImagemState();
}

class _CuidadosImagemState extends State<CuidadosImagem> {
  final bloc = BlocProvider.getBloc<ConsultaImagemBloc>();
  TextEditingController controller = TextEditingController();
  List<Asset> images = [];

//0 otimo, B para bom, X pra recusou
  @override
  void initState() {
    bloc.inputTurma.add('Todas');
    bloc.inputTextoImagem.add('');
    buscarturmas();
    super.initState();
  }

  void buscarturmas() {
    FirebaseFirestore.instance
        .collection(Nomes().turmabanco)
        .orderBy("turma")
     .get()
        .then((documents) {
      List<String> turmas = [];
      turmas.add('Todas');
      documents.docs.forEach((doc) {
        turmas.add(doc['turma']);
      });
      bloc.inputTurmas.add(turmas);
      print(turmas.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> turmas = [];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Cores().corprincipal,
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              await gerarcsv();
            },
            child: Text(
              'CSV',
              style: TextStyle(color: Colors.white),
            ),
          ),
          StreamBuilder<String>(
              stream: bloc.outputTextoImagem,
              builder: (context, snapshot) {
                return (snapshot.data != null)
                    ? (snapshot.data!.isNotEmpty)
                        ? FlatButton(
                            child: Text(
                              'SALVAR',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              Layout().dialog1botao(context, "Salvando",
                                  'Estamos fazendo o possível para salvar.\n Verifique na tela inicial.');
                              Pesquisa().salvarCuidadoImagem(controller.text);
                              controller.text = '';
                            },
                          )
                        : Container()
                    : Container();
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<List<String>>(
            stream: bloc.outputTurmas,
            builder: (context, turmas) {
              if (turmas.hasError) {
                return Text('Isto é um erro. Por gentileza, contate o suporte.');
              }
              return (turmas.data != null)
                  ? Column(
                      children: <Widget>[
                        StreamBuilder<String>(
                            stream: bloc.outputTurma,
                            builder: (context, turma) {
                              if (turma.hasError) {
                                return Text('Isto é um erro. Por gentileza, contate o suporte.');
                              }
                              return (turma.data != null)
                                  ? Layout().dropdownitem("Selecione a Turma",
                                      turma.data, mudarTurma, turmas.data)
                                  : Container();
                            }),
                        Text(
                          'INSTRUÇÕES:',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Utilize a câmera do celular e tire foto da tabela de Cuidados em posição retatro e mais reta possível .\nClique no botão abaixo para ler a foto.\n Atenção aos seguintes pontos:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  '• Em cima de cada nome de aluno DEVE ter ---\nCaso não tenha, clique em cima do nome e coloque.'),
                              Text('• Confira o nome dos alunos'),
                              Text('• Confira o texto abaixo dos nomes'),
                              Text('• Após a conferência, clique em Salvar'),
                            ],
                          ),
                        ),
                        StreamBuilder<String>(
                            stream: bloc.outputTextoImagem,
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                if (snapshot.data!.startsWith('x') ||
                                    snapshot.data!.startsWith('X')) {
                                  controller.text +=
                                      snapshot.data!.replaceAll('x', '');
                                } else {
                                  controller.text += snapshot.data!;
                                }
                              }
                              return (snapshot.data != null)
                                  ? (snapshot.data!.isNotEmpty)
                                      ? Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          child: TextField(
                                            maxLines: 500,
                                            controller: controller,
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Cores().corprincipal,
                                                    width: 1.5),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                    width: 1.5),
                                              ),
                                              labelText: 'Cuidados',
                                              labelStyle: TextStyle(
                                                  letterSpacing: 1.0,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            textCapitalization:
                                                TextCapitalization.words,
                                            autofocus: false,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        )
                                      : Container()
                                  : Container();
                            }),
                      ],
                    )
                  : Container();
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
        //  await pegarimagem();
        },
        child: Icon(Icons.photo),
      ),
    );
  }

  // Future pegarimagem() async {
  //   List<Asset> imagema = await loadAssets();
  //  // FirebaseVisionImage ourImage;
  //   I.Image _img = I.decodeImage(
  //       (await imagema[0].getByteData()).buffer.asUint8List().toList());
  //   Directory tempDir = await getApplicationDocumentsDirectory();
  //
  //   String tempPath = tempDir.path;
  //
  //   File file = await File("$tempPath/image.jpg")
  //       .writeAsBytes(Uint8List.fromList(I.encodeJpg(_img)));
  //
  //   ourImage = FirebaseVisionImage.fromFile(file);
  //
  //   await reconhecimentoTexto(ourImage);
  // }

  Future<List<Asset>?> loadAssets() async {
    List<Asset> resultList = [];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
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
      return resultList;
    } on Exception catch (e) {}
  }

  //
  //
  // Future reconhecimentoTexto(FirebaseVisionImage ourImage) async {
  //   TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
  //   VisionText readText = await recognizeText.processImage(ourImage);
  //   String conteudo = "";
  //   int i = 0;
  //   int j = 0;
  //   List<String> linhas = [];
  //   readText.blocks.forEach((block) {
  //     block.lines.forEach((line) {
  //       print('bloco:$j --$i -- ' + line.text);
  //       print(line.text);
  //       if (line.text != '' && line.text != 'Todas') {
  //         linhas.add(line.text);
  //       }
  //
  //       if (!line.text.contains('&') && !line.text.startsWith('8')) {
  //         if (!line.text.startsWith('3') &&
  //             (!line.text.contains('Otimo') ||
  //                 !line.text.contains('Bem') ||
  //                 !line.text.contains('Recusou') ||
  //                 !line.text.contains('Normal') ||
  //                 !line.text.contains('Amolecido'))) {
  //           if (line.text.contains('Otimo') ||
  //               line.text.contains('Bem') ||
  //               line.text.contains('Recusou') ||
  //               line.text.contains('Normal') ||
  //               line.text.contains('Amolecido') ||
  //               line.text.contains('1') ||
  //               line.text.contains('2') ||
  //               line.text.contains('3') ||
  //               line.text.contains('4') ||
  //               line.text.contains('5') ||
  //               line.text.contains('6') ||
  //               line.text.contains('7') ||
  //               line.text.contains('8') ||
  //               line.text.contains('9') ||
  //               line.text.contains('0') ||
  //               line.text == '&') {
  //             conteudo += line.text + '\n';
  //           } else {
  //             conteudo += '---\n' + line.text + '\n';
  //           }
  //         }
  //       }
  //       i++;
  //     });
  //     j++;
  //   });
  //   bloc.inputTextoImagem.add(conteudo);
  // }

  Future gerarcsv() async {
    if (bloc.turmaSelecionada != 'Todas') {
      FirebaseFirestore.instance
          .collection(Nomes().alunosbanco)
          .where('ano',
          arrayContainsAny: [Pesquisa().getAno()])
          .where("turma", isEqualTo: bloc.turmaSelecionada)
          .orderBy("nome")
        .get()
          .then((docs) {
        List<List<String>> csvData = [];

        docs.docs.forEach((doc) {
          csvData.add(<String>['', doc['nome']]);
          csvData.add(<String>[
            '',
            '&Manha Otimo',
            '',
            '',
            '&Manha Bem',
            '',
            '',
            '&Manha Recusou'
          ]);
          csvData.add(<String>[
            '',
            '&Almoco Otimo',
            '',
            '',
            '&Almoco Bem',
            '',
            '',
            '&Almoco Recusou'
          ]);
          csvData.add(<String>[
            '',
            '&Lanche Otimo',
            '',
            '',
            '&Lanche Bem',
            '',
            '',
            '&Lanche Recusou'
          ]);
          csvData.add(<String>[
            '',
            '&Jantar Otimo',
            '',
            '',
            '&Jantar Bem',
            '',
            '',
            '&Jantar Recusou'
          ]);
          csvData.add(<String>['', '&Soninho']);
          csvData.add(<String>[
            '',
            '&09h',
            '&10h',
            '&11h',
            '&12h',
            '&13h',
            '&14h',
            '&15h',
            '&16h',
            '&17h',
            '&18h'
          ]);
          csvData.add(<String>[
            ' ',
            ' ',
            ' ',
            ' ',
            '&00',
            '&10',
            '&20',
            '&30',
            '&40',
            '&50'
          ]);
          csvData.add(<String>[
            '',
            '&09h',
            '&10h',
            '&11h',
            '&12h',
            '&13h',
            '&14h',
            '&15h',
            '&16h',
            '&17h',
            '&18h'
          ]);
          csvData.add(<String>[
            ' ',
            ' ',
            ' ',
            ' ',
            '&00',
            '&10',
            '&20',
            '&30',
            '&40',
            '&50'
          ]);
          csvData.add(<String>[
            '',
            '&Evacuou Normal',
            '',
            '',
            '',
            '&Evacuou Amolecido'
          ]);
        });
        // String csv = ListToCsvConverter().convert(csvData, fieldDelimiter: ';');
        // Uint8List arquive = Uint8List.fromList(csv.codeUnits);
        // StorageReference storageReference = FirebaseStorage.instance
        //     .ref()
        //     .child('csv/' + DateTime.now().toIso8601String() + ".csv");
        // StorageUploadTask uploadTask = storageReference.putData(arquive);
        // uploadTask.onComplete.then((value) {
        //   value.ref.getDownloadURL().then((value) async {
        //     var url = '${value.toString()}';
        //     if (await canLaunch(url)) {
        //       await launch(url);
        //     } else {
        //       throw 'Could not launch $url';
        //     }
        //   });
        // });
      });
    } else {
      Layout().dialog1botao(context, 'Ops', 'Selecione a turma');
    }
  }

  void mudarTurma(String option) {
    bloc.inputTurma.add(option);
  }
}
