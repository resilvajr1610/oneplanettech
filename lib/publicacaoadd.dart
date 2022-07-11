import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:multiple_select/multi_drop_down.dart';
// import 'package:multiple_select/multiple_select.dart';
//
// import 'package:universal_html/html.dart' as html;

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'pesquisa.dart';
import 'design.dart';
import 'layout.dart';
import 'dart:async';

class PublicacaoAdd extends StatefulWidget {
  final DocumentSnapshot usuario;
  final String linkcompartilhado;
  bool moderacao;

  PublicacaoAdd(this.usuario, this.linkcompartilhado, this.moderacao);

  @override
  _PublicacaoAddState createState() => _PublicacaoAddState();
}

class _PublicacaoAddState extends State<PublicacaoAdd> {
  String data='', para='', turma='', unidade='', aluno='', alunoid='';
  late DocumentSnapshot alunodoc;
  List<String> turmas = [];
  List<String> unidades = [];
  Map<String, dynamic> alunosid = Map();
  Map<String, dynamic> map = Map();
  List unidadesselecionadas = [];
  // List<MultipleSelectItem> unidadesmultiple=[];
  List turmasselecionadas = [];
  // List<MultipleSelectItem> turmasmultiple=[];
  List<String> alunos = [];
  List<Asset> images = [];
  TextEditingController mensagem = TextEditingController();
  TextEditingController linkyoutube = TextEditingController();
  TextEditingController linkescondidoimagem = TextEditingController();
  TextEditingController nomearquivo = TextEditingController();
  late Uint8List imageFromWeb;
  late File videoapp, pdfapp, imagemcamera;
  // late html.File videoweb, pdfweb, fileimageFromWeb;
  String curso='';
  List<String> cursos = ['EI', 'EF1', 'EF2', 'EM', 'CN'];
  bool enviarlinkyoutube = false, agendado = false, linkescondido = false;
  TextEditingController dataagenda = TextEditingController();
  late DateTime datacompararagenda;
  String horaagenda='';
  List<String> horariosagenda = ['8h00', '13h00', '18h00'];

  int opcao = 0;
  Map<int, Widget> opcoes = const <int, Widget>{
    0: Text("Unidades"),
    1: Text('Cursos'),
    2: Text("Turmas"),
    3: Text("Alunos"),
  };

  int opcaopublicacao = 0;
  Map<int, Widget> opcoespublicacao = const <int, Widget>{
    0: Text(
      "Normal",
      style: TextStyle(fontSize: 12.0),
    ),
    1: Text(
      "Informativo",
      style: TextStyle(fontSize: 12.0),
    ),
    2: Text(
      "Enquete",
      style: TextStyle(fontSize: 12.0),
    ),
    3: Text(
      "Documento",
      style: TextStyle(fontSize: 12.0),
    ),
  };

  @override
  void dispose() {
    super.dispose();
    dataagenda.dispose();
  }

  void mudarHorario(String text) {
    setState(() {
      horaagenda = text;
    });
  }

  @override
  void initState() {
    data = Pesquisa().hoje();

    if (widget.usuario['unidade'] == 'Todas as unidades') {
      buscarunidades();
    } else {
      unidade = widget.usuario['unidade'];
    }
    if (List<String>.from(widget.usuario['curso'])[0] != 'Todos') {
      cursos = List<String>.from(widget.usuario['curso']);
      if(cursos.length == 1){
        curso = cursos[0];
      }
    }

    if (List<String>.from(widget.usuario['turma'])[0] != 'Todas') {
      turmas = List<String>.from(widget.usuario['turma']);
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
    }
    if (widget.linkcompartilhado != null) {
      linkyoutube.text = widget.linkcompartilhado;
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().publicacoesAdd);
    super.initState();
  }

  void buscarturmas(uni, curs) {
    turmas.clear();
    FirebaseFirestore.instance
        .collection(Nomes().turmabanco)
        .where('unidade', isEqualTo: uni)
        .where('curso', isEqualTo: curs)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbar('Adicionar Publicação'),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Layout().titulo('Tipo de Publicação:'),
                  Layout().segmented(opcoespublicacao, opcaopublicacao,
                      mudaropcaopublicacao, context),
                  Layout().titulo('Para:'),
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
                          List<String>.from(widget.usuario['curso'])[0] ==
                              'Todos')
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
                  (opcao == 3)
                      ? Column(
                        children: [
                          Row(
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
                                (turmas != null && turmas.length > 0)
                                    ? Flexible(
                                        flex: 1,
                                        child: Layout().dropdownitem(
                                            "Selecione a turma",
                                            turma,
                                            mudarTurma,
                                            turmas),
                                      )
                                    : Container(),
                              ],
                            ),
                          (alunos != null && alunos.length > 0)
                              ? Layout().dropdownitem(
                                  "Selecione o Aluno",
                                  aluno,
                                  mudarAluno,
                                  alunos)
                              : Container()
                        ],
                      )
                      : Container(),

                  itemDiario(widget.usuario, context),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Cores().corprincipal),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        onPressed: () {
                          setState(() {
                            agendado = !agendado;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Agendar'),
                        ),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Cores().corprincipal),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        onPressed: () {
                          parasalvar(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Publicar Agora'),
                        ),
                      ),
                    ],
                  ),
                  (agendado) ? cardagendar() : Container(),
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

  cardagendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Spacer(),
                  Text("Data: "),
                  GestureDetector(
                      onTap: () {
                        escolherprazo(context);
                      },
                      child: Layout().titulo(dataagenda.text)),
                  Spacer(),
                ],
              ),
              Layout().dropdownitem('Selecione o horário', horaagenda,
                  mudarHorario, horariosagenda),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        botaosalvar(context),
      ],
    );
  }

  escolherprazo(BuildContext context) async {
    var pickDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2040));
    if (pickDate != null) {
      setState(() {
        datacompararagenda = pickDate;
        dataagenda.text = Pesquisa().formatData(
            year: pickDate.year, month: pickDate.month, day: pickDate.day);
      });
    }
  }

  Widget botaosalvar(context) {
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

  void salvar(BuildContext context) {
    if (datacompararagenda == null) {
      Layout().dialog1botao(context, 'Data', 'Selecione a data');
    } else if (horaagenda.isEmpty) {
      Layout().dialog1botao(context, 'Horário', 'Selecione um horário');
    } else {
      parasalvar(context);
    }
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
                      pegarimagens();
                    }),
                ListTile(
                    leading: new Icon(Icons.video_library),
                    title: new Text('Link vídeo YouTube'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        enviarlinkyoutube = true;
                      });
                    }),
                ListTile(
                    leading: new Icon(Icons.link),
                    title: new Text('Link escondido na imagem'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        linkescondido = true;
                      });
                    }),
                ListTile(
                  leading: new Icon(Icons.videocam),
                  title: new Text('Video'),
                  onTap: () {
                    Navigator.pop(context);
                    pegarvideo();
                  },
                ),
                ListTile(
                  leading: new Icon(Icons.picture_as_pdf),
                  title: new Text('Arquivo PDF'),
                  onTap: () {
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
                    Navigator.pop(context);
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
  //       nomearquivo.text = file.name;
  //     });
  //   });
  //   uploadInput.remove();
  // }

  Future pegarvideo() async {
    if (kIsWeb) {
      //getVideoWeb();
    } else {
      var video = await ImagePicker().getVideo(
          source: ImageSource.gallery, maxDuration: Duration(minutes: 15));
      File videofile = File(video!.path);
      setState(() {
        videoapp = videofile;
      });
    }
  }

  // getVideoWeb() async {
  //   html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  //   uploadInput.multiple = false;
  //   uploadInput.draggable = true;
  //   uploadInput.accept = 'video/*';
  //   uploadInput.click();
  //   html.document.body?.append(uploadInput);
  //   uploadInput.onChange.listen((e) async {
  //     final files = uploadInput.files;
  //     html.File file = files![0];
  //     setState(() {
  //       videoweb = file;
  //     });
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
      imagemcamera = File(image!.path);
    });
  }

  Widget itemDiario(usuario, context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Card(
        elevation: 1.0,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(top: 8.0, right: 12.0, left: 12.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: (usuario['foto'] != null)
                          ? Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: (!kIsWeb)
                                        ? CachedNetworkImageProvider(
                                            usuario['foto'])
                                        : NetworkImage(usuario['foto'])as ImageProvider,
                                    fit: BoxFit.contain),
                              ))
                          : Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: AssetImage("images/picture.png"),
                                      fit: BoxFit.contain),
                                  color: Colors.black26)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(usuario['nome'],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0,
                              )),
                          Text(
                            data,
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15.0),
                          ),
                        ],
                      ),
                    ),
                    (opcaopublicacao == 1)
                        ? Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Container(
                              width: 70.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Icon(
                                    Icons.announcement,
                                    color: Colors.yellow[700],
                                  ),
                                  AutoSizeText(
                                    'Informativo',
                                    maxLines: 1,
                                    style: TextStyle(color: Colors.black54),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    (opcaopublicacao == 2)
                        ? Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Container(
                              width: 60.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Icon(
                                    Icons.question_answer,
                                    color: Cores().corenquete,
                                  ),
                                  AutoSizeText(
                                    'Enquetes',
                                    maxLines: 1,
                                    style: TextStyle(color: Colors.black54),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    (opcaopublicacao == 3)
                        ? Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Container(
                              width: 70.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Icon(
                                    Icons.folder,
                                    color: Colors.green[100],
                                  ),
                                  AutoSizeText(
                                    'Documento',
                                    maxLines: 1,
                                    style: TextStyle(color: Colors.black54),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Layout().caixadetexto(
                    5,
                    40,
                    TextInputType.multiline,
                    mensagem,
                    'Escreva a mensagem',
                    TextCapitalization.sentences),
              ),
              (imagemcamera != null) ?
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(height: 200, width: 200, child: Image.file(imagemcamera, filterQuality: FilterQuality.medium,),),
                  )
                  : Container(),
              (linkyoutube.text.isNotEmpty || enviarlinkyoutube)
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Layout().caixadetexto(1, 2, TextInputType.text,
                          linkyoutube, 'Link Youtube', TextCapitalization.none),
                    )
                  : Container(),
              (linkescondido)
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Layout().caixadetexto(
                          1,
                          2,
                          TextInputType.text,
                          linkescondidoimagem,
                          'Link - abre ao clicar nas imagens',
                          TextCapitalization.none),
                    )
                  : Container(),
              // (opcaopublicacao == 3 || pdfapp != null || pdfweb != null)
              //     ? Row(
              //         children: [
              //           Expanded(
              //               child: Layout().caixadetexto(
              //                   1,
              //                   2,
              //                   TextInputType.text,
              //                   nomearquivo,
              //                   'Nome do arquivo',
              //                   TextCapitalization.sentences)),
              //           Container(
              //             width: 80.0,
              //             child: AutoSizeText(
              //               (pdfweb != null || pdfapp != null) ? 'Anexado' : '',
              //               maxLines: 1,
              //             ),
              //           ),
              //           IconButton(
              //             icon: Icon(Icons.delete),
              //             onPressed: () {
              //               setState(() {
              //                 nomearquivo.text = '';
              //                 pdfapp = '' as File;
              //                 pdfweb = '' as html.File ;
              //               });
              //             },
              //           )
              //         ],
              //       )
              //     : Container(),
              (images.length > 0)
                  ? Text('Pré-visualização em resolução menor.')
                  : Container(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: (images.length > 0)
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: mostrarimagens())
                    : Container(),
              ),
              (imageFromWeb != null)
                  ? ClipRRect(
                      borderRadius: new BorderRadius.circular(4.0),
                      child: Image.memory(
                        imageFromWeb,
                        scale: 0.5,
                        fit: BoxFit.contain,
                        height: 120.0,
                        width: MediaQuery.of(context).size.width,
                      ),
                    )
                  : Container(),
              // (videoweb != null || videoapp != null)
              //     ? Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Text('Vídeo anexado'),
              //           IconButton(
              //             icon: Icon(Icons.delete),
              //             onPressed: () {
              //               setState(() {
              //                 videoweb = '' as html.File ;
              //                 videoapp = '' as File;
              //               });
              //             },
              //           )
              //         ],
              //       )
              //     : Container(),
              Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, bottom: 8.0, right: 33.0, left: 33.0),
                child: Divider(
                  thickness: 1.0,
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (opcaopublicacao == 0)
                        ? Row(
                            children: <Widget>[
                              Icon(Icons.favorite_border, color: Colors.grey),
                              Text("Curtir"),
                            ],
                          )
                        : Spacer(),
                    (opcaopublicacao == 2)
                        ? Row(
                            children: <Widget>[
                              Icon(Icons.assignment_ind, color: Colors.grey),
                              Text("Responder"),
                            ],
                          )
                        : Spacer(),
                    (opcaopublicacao == 1 || opcaopublicacao == 3)
                        ? Row(
                            children: <Widget>[
                              Icon(Icons.check_circle_outline,
                                  color: Colors.grey),
                              Text("Dar ciência"),
                            ],
                          )
                        : Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void parasalvar(BuildContext context) {
    if (widget.usuario['perfil'] == 'Professor' && (opcao == 0 || opcao == 1)) {
      Layout().dialog1botao(
          context,
          'Selecione Publicação para Turmas ou Alunos',
          'Com o perfil de professor, é possível publicar para Turmas ou Alunos');
    }
    if (opcao == 0 &&
        widget.usuario['perfil'] != 'Professor' &&
        List<String>.from(widget.usuario['curso'])[0] == 'Todos') {
      // parasalvarunidade(context);
    }
    if (opcao == 0 &&
        widget.usuario['perfil'] != 'Professor' &&
        List<String>.from(widget.usuario['curso'])[0] != 'Todos') {
      Layout().dialog1botao(context, 'Erro',
          'Não é possível publicar para a unidade. Selecione outras opcões');
    }
    if (opcao == 1 && widget.usuario['perfil'] != 'Professor') {
      // parasalvarcurso(context);
    }
    if (opcao == 2) {
      // parasalvarturma(context);
    }
    if (opcao == 3) {
      // parasalvaraluno(context);
    }
  }

  // void parasalvarunidade(BuildContext context) {
  //   if (unidadesselecionadas.length == 0 &&
  //       widget.usuario['unidade'] == "Todas as unidades") {
  //     Layout().dialog1botao(context, "Unidade", "Selecione a unidade");
  //   } else if (widget.usuario['unidade'] != "Todas as unidades") {
  //     Pesquisa().salvarpublicacaounidade(
  //         widget.usuario,
  //         widget.usuario['unidade'],
  //         (opcaopublicacao == 0)
  //             ? 'diario'
  //             : (opcaopublicacao == 1)
  //                 ? 'bilhete'
  //                 : (opcaopublicacao == 2)
  //                     ? 'enquete'
  //                     : 'documento',
  //         mensagem.text,
  //         images,
  //         fileimageFromWeb,
  //         pdfapp,
  //         pdfweb,
  //         nomearquivo.text,
  //         videoapp,
  //         videoweb,
  //         linkyoutube.text,
  //         linkescondidoimagem.text,
  //         agendado,
  //         dataagenda.text,
  //         horaagenda,
  //         datacompararagenda,
  //         imagemcamera);
  //
  //     Layout().dialog1botaofecha2(
  //         context, "Estamos Salvando", "O conteúdo aparecerá na tela inicial.");
  //   } else if (unidadesselecionadas.contains(0)) {
  //     Pesquisa().salvarpublicacaounidade(
  //         widget.usuario,
  //         'Todas',
  //         (opcaopublicacao == 0)
  //             ? 'diario'
  //             : (opcaopublicacao == 1)
  //                 ? 'bilhete'
  //                 : (opcaopublicacao == 2)
  //                     ? 'enquete'
  //                     : 'documento',
  //         mensagem.text,
  //         images,
  //         fileimageFromWeb,
  //         pdfapp,
  //         pdfweb,
  //         nomearquivo.text,
  //         videoapp,
  //         videoweb,
  //         linkyoutube.text,
  //         linkescondidoimagem.text,
  //         agendado,
  //         dataagenda.text,
  //         horaagenda,
  //         datacompararagenda,
  //         imagemcamera);
  //
  //     Layout().dialog1botaofecha2(
  //         context, "Estamos Salvando", "O conteúdo aparecerá na tela inicial.");
  //   } else {
  //     Pesquisa().salvarpublicacaounidades(
  //         widget.usuario,
  //         (opcaopublicacao == 0)
  //             ? 'diario'
  //             : (opcaopublicacao == 1)
  //                 ? 'bilhete'
  //                 : (opcaopublicacao == 2)
  //                     ? 'enquete'
  //                     : 'documento',
  //         mensagem.text,
  //         images,
  //         fileimageFromWeb,
  //         pdfapp,
  //         pdfweb,
  //         nomearquivo.text,
  //         videoapp,
  //         videoweb,
  //         linkyoutube.text,
  //         linkescondidoimagem.text,
  //         agendado,
  //         dataagenda.text,
  //         horaagenda,
  //         datacompararagenda,
  //         imagemcamera,
  //         unidadesSelecionadas: unidades,
  //         indexturmas: unidadesselecionadas);
  //     Layout().dialog1botaofecha2(
  //         context, "Estamos Salvando", "O conteúdo aparecerá na tela inicial.");
  //   }
  // }

  // void parasalvarcurso(BuildContext context) {
  //   if (curso == null) {
  //     Layout().dialog1botao(context, "Curso", "Selecione o curso");
  //   } else {
  //     Pesquisa().salvarpublicacaocurso(
  //         widget.usuario,
  //         curso,
  //         unidade,
  //         (opcaopublicacao == 0)
  //             ? 'diario'
  //             : (opcaopublicacao == 1)
  //                 ? 'bilhete'
  //                 : (opcaopublicacao == 2)
  //                     ? 'enquete'
  //                     : 'documento',
  //         mensagem.text,
  //         images,
  //         fileimageFromWeb,
  //         pdfapp,
  //         pdfweb,
  //         nomearquivo.text,
  //         videoapp,
  //         videoweb,
  //         linkyoutube.text,
  //         linkescondidoimagem.text,
  //         agendado,
  //         dataagenda.text,
  //         horaagenda,
  //         datacompararagenda,
  //         imagemcamera);
  //
  //     Layout().dialog1botaofecha2(
  //         context, "Estamos Salvando", "O conteúdo aparecerá na tela inicial.");
  //   }
  // }

  // void parasalvarturma(BuildContext context) {
  //   if(curso == null) {
  //     Layout().dialog1botao(context, "Curso", "Selecione o curso");
  //   } else if (turmasselecionadas.length == 0) {
  //     Layout().dialog1botao(context, "Turma", "Selecione a turma");
  //   } else {
  //     Pesquisa().salvarpublicacaoturmas(
  //         widget.usuario,
  //         unidade,
  //         curso,
  //         widget.moderacao,
  //         (opcaopublicacao == 0)
  //             ? 'diario'
  //             : (opcaopublicacao == 1)
  //                 ? 'bilhete'
  //                 : (opcaopublicacao == 2)
  //                     ? 'enquete'
  //                     : 'documento',
  //         mensagem.text,
  //         images,
  //         fileimageFromWeb,
  //         pdfapp,
  //         pdfweb,
  //         nomearquivo.text,
  //         videoapp,
  //         videoweb,
  //         linkyoutube.text,
  //         linkescondidoimagem.text,
  //         agendado,
  //         dataagenda.text,
  //         horaagenda,
  //         datacompararagenda,
  //         imagemcamera,
  //         turmasSelecionadas: turmas,
  //         indexturmas: turmasselecionadas);
  //     Layout().dialog1botaofecha2(
  //         context, "Estamos Salvando", "O conteúdo aparecerá na tela inicial.");
  //   }
  // }

  // void parasalvaraluno(BuildContext context) {
  //   if (aluno == null) {
  //     Layout().dialog1botao(context, "Aluno", "Selecione o aluno");
  //   } else {
  //     Pesquisa().salvarpublicacaoaluno(
  //         widget.usuario,
  //         alunodoc,
  //         widget.moderacao,
  //         (opcaopublicacao == 0)
  //             ? 'diario'
  //             : (opcaopublicacao == 1)
  //                 ? 'bilhete'
  //                 : (opcaopublicacao == 2)
  //                     ? 'enquete'
  //                     : 'documento',
  //         mensagem.text,
  //         images,
  //         fileimageFromWeb,
  //         pdfapp,
  //         pdfweb,
  //         nomearquivo.text,
  //         videoapp,
  //         videoweb,
  //         linkyoutube.text,
  //         linkescondidoimagem.text,
  //         agendado,
  //         dataagenda.text,
  //         horaagenda,
  //         datacompararagenda,
  //         imagemcamera);
  //     Layout().dialog1botaofecha2(
  //         context, "Estamos Salvando", "O conteúdo aparecerá na tela inicial.");
  //   }
  // }

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

  void mudarCurso(String text) {
    setState(() {
      curso = text;
    });
    if ((opcao == 2 || opcao == 3) &&
        List<String>.from(widget.usuario['turma'])[0] == 'Todas') {
      buscarturmas(unidade, curso);
    }
  }

  Widget mostrarimagens() {
    return GridView.count(
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
    );
  }

  Future<void> pegarimagens() async {
    if (!kIsWeb) {
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
      if (!mounted) return;
    } else {
      // getImageWeb();
    }
  }

  // getImageWeb() async {
  //   // html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
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
  //         // fileimageFromWeb = file;
  //       });
  //     });
  //     reader.readAsDataUrl(file);
  //   });
  //   uploadInput.remove();
  // }

  void mudarTurma(String text) {
    setState(() {
      turma = text;
    });
    buscarAlunos(turma);
  }

  void mudarAluno(String text) {
    setState(() {
      aluno = text;
      alunosid.forEach((String nome, dynamic doc) {
        if (nome == aluno) {
          alunodoc = doc;
        }
      });
    });
  }

  void mudarUnidade(String text) {
    setState(() {
      unidade = text;
    });
  }

  void buscarAlunos(turm) {
    alunos.clear();
    alunosid.clear();
    FirebaseFirestore.instance
        .collection(Nomes().alunosbanco)
        .where('ano',
        arrayContainsAny: [Pesquisa().getAno()])
        .where("unidade", isEqualTo: unidade)
        .where("turma", isEqualTo: turm)
        .orderBy('nome')
        .get()
        .then((documents) {
      documents.docs.forEach((doc) {
        setState(() {
          if (doc != null) {
            alunos.add(doc['nome']);
            alunosid[doc['nome']] = doc;
          }
        });
      });
    });
  }
}
