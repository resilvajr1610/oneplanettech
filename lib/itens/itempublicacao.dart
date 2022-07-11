import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:scalifra/galeriaDeFotos.dart';

import 'package:scalifra/itens/itemvideo.dart';
import 'package:scalifra/recadoresposta.dart';
import 'package:scalifra/responderenquete.dart';
import 'package:scalifra/respostaEnquete.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cuidados/cuidadosadd.dart';
import '../design.dart';
import '../fotodetalhe.dart';
import '../layout.dart';
import '../pdfviewer.dart';
import '../pesquisa.dart';
import '../visualizarCiente.dart';
import 'itemvideoescola.dart';

class ItemPublicacao extends StatefulWidget {
  final DocumentSnapshot usuario, document, aluno;
  bool controle, moderacao;

  ItemPublicacao(
      this.usuario, this.document, this.controle, this.moderacao, this.aluno);

  @override
  _ItemPublicacaoState createState() => _ItemPublicacaoState();
}

class _ItemPublicacaoState extends State<ItemPublicacao> {
  bool curtiu = false, resposta = false, ciente = false;
  late StreamSubscription<DocumentSnapshot> listen;

  @override
  void initState() {
    super.initState();
    if (widget.usuario['email'] != 'elaine@master.com' && widget.document['enviar'] == true) {
      widget.document.reference.update({
        "visualizado": FieldValue.arrayUnion([widget.usuario.id])
      });
    }
    if (widget.document['curtidas'] != null) {
      if (widget.usuario != null &&
          widget.document['curtidas'].contains(widget.usuario.id)) {
        curtiu = true;
      }
    }
    if (widget.document['respostas'] != null) {
      if (widget.usuario != null &&
          widget.document['respostas'].contains(widget.usuario.id)) {
        resposta = true;
      }
    }
    if (widget.document['cientes'] != null) {
      if (widget.usuario != null &&
          widget.document['cientes'].contains(widget.usuario.id)) {
        ciente = true;
      }
    }
    if (widget.document['tipo'] == 'recado' &&
        widget.document['ciente'] != null &&
        widget.document['ciente']) {
      ciente = true;
    }
    listen = widget.document.reference.snapshots().listen((event) {
      if (event['curtidas'] != null) {
        if (widget.usuario != null &&
            event['curtidas'].contains(widget.usuario.id)) {
          if (!mounted) {
            return;
          }
          setState(() {
            curtiu = true;
          });
        }
      }
      if (event['respostas'] != null) {
        if (widget.usuario != null &&
            event['respostas'].contains(widget.usuario.id)) {
          if (!mounted) {
            return;
          }
          setState(() {
            resposta = true;
          });
        }
      }
      if (event['cientes'] != null) {
        if (widget.usuario != null &&
            event['cientes'].contains(widget.usuario.id)) {
          if (!mounted) {
            return;
          }
          setState(() {
            ciente = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    listen.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return itemPublicacao(widget.document, widget.usuario, context);
  }

  Widget itemPublicacao(DocumentSnapshot document, usuario, context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Card(
        elevation: 1.0,
        child: GestureDetector(
          onLongPress: () {

            if (!widget.controle && document['tipo'] == 'recado') {
              Layout().editar(document, usuario, context);
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                (widget.controle)
                    ? Row(children: [
                        Spacer(),
                        InkWell(
                            onTap: () {
                              if (document['enviar'] == false &&
                                  document['agendado'] == null &&
                                  (usuario['perfil'] == 'Direção' ||
                                      usuario['perfil'] == 'Coordenação')) {
                                document.reference.update({'enviar': true});
                              }
                              if (document['enviar'] == false &&
                                  usuario['perfil'] != 'Direção' &&
                                  usuario['perfil'] != 'Coordenação') {
                                Layout().dialog1botao(
                                    context,
                                    'Não é possível aprovar',
                                    'Apenas o perfil de coordenação ou direção pode aprovar publicações');
                              }
                            },
                            child: Container(
                                color: (document['enviar'])
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.amber.withOpacity(0.2),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    (document['enviar'])
                                        ? 'Item Publicado'
                                        : (document['agendado'])
                                            ? 'Agendado: ${document['enviardata']} ${document['enviarhora']}'
                                            : 'Aguardando Aprovação',
                                    style: Layout().sanslight(),
                                  ),
                                ))),
                        SizedBox(width: 25.0,),
                        IconButton(onPressed: () {
                          if (widget.controle &&
                              widget.usuario['unidade'] == document['unidade'] &&
                              (widget.usuario['perfil'] != 'Professor' ||
                                  (widget.usuario['perfil'] == 'Professor' &&
                                      document['responsavel'] == widget.usuario['nome']))) {
                            Layout().editar(document, usuario, context);
                          }
                          if (widget.controle &&
                              widget.usuario['unidade'] == 'Todas as unidades' &&
                              (widget.usuario['perfil'] != 'Professor' ||
                                  (widget.usuario['perfil'] == 'Professor' &&
                                      document['responsavel'] == widget.usuario['nome']))) {
                            Layout().editar(document, usuario, context);
                          }
                        }, icon: Icon(Icons.menu))
                      ])
                    : Container(),
                (widget.controle &&
                        document['tipo'] == 'recado' &&
                        document['resposta'] != null)
                    ? Row(children: [
                        Spacer(),
                        InkWell(
                            onTap: () {
                              if (usuario['perfil'] == 'Direção' ||
                                  usuario['perfil'] == 'Coordenação') {
                                document.reference
                                    .update({'enviarresposta': true});
                              }
                            },
                            child: Container(
                                color: (document['enviarresposta'])
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.amber.withOpacity(0.2),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    (document['enviarresposta'])
                                        ? 'Resposta Publicada'
                                        : 'Aguardando Aprovação Resposta',
                                    style: Layout().sanslight(),
                                  ),
                                )))
                      ])
                    : Container(),
                (widget.controle)
                    ? Row(
                        children: [
                          Spacer(),
                          document['visualizado'] != null
                              ? Text(
                                  "${List<String>.from(document['visualizado']).length} ",
                                  style: TextStyle(color: Colors.grey),
                                )
                              : Text("0 ",
                                  style: TextStyle(color: Colors.grey)),
                          IconButton(
                            icon:
                                Icon(Icons.remove_red_eye, color: Colors.grey),
                            onPressed: () {
                              if (document['unidade'] != 'Todas' ||
                                  (document['unidade'] == 'Todas' &&
                                      usuario['unidade'] ==
                                          'Todas as unidades')) {
                                Pesquisa().irpara(
                                    VisualizarCiente(document, 'visualizado'),
                                    context);
                              }
                            },
                          ),
                        ],
                      )
                    : Container(),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, right: 12.0, left: 12.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: (document['logo'] != null)
                              ? CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.blueGrey,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.blueGrey,
                                    radius: 24,
                                    backgroundImage: (!kIsWeb)
                                        ? CachedNetworkImageProvider(
                                            document['logo'])
                                        : NetworkImage(document['logo'])as ImageProvider,
                                  ),
                                )
                              : (document['nome'] == 'Todas')
                                  ? CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.blueGrey,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.blueGrey,
                                        radius: 25,
                                        backgroundImage: AssetImage(
                                            'images/logoredondo.png'),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.blueGrey,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.blueGrey,
                                        radius: 24,
                                        backgroundImage:
                                            AssetImage('images/picture.png'),
                                      ),
                                    )),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            (document['nome'] == "Todas")
                                ? Text(Nomes().todasturmas,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.0,
                                    ))
                                : (document['nome'] == document['unidade'] ||
                                        (document['tipo'] == 'lembrete' &&
                                            document['nome'] ==
                                                document['responsavel']))
                                    ? Text(document['nome'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15.0,
                                        ))
                                    : Text(
                                        document['responsavel'] +
                                            '  >  ' +
                                            document['nome'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15.0,
                                        )),
                            Text(
                              document['data'],
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 12.0),
                            ),
                          ],
                        ),
                      ),
                      (document['tipo'] != 'diario')
                          ? Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    (document['tipo'] == 'bilhete')
                                        ? Icon(
                                            Icons.announcement,
                                            color: Colors.yellow[700],
                                          )
                                        : Container(),
                                    (document['tipo'] == 'documento')
                                        ? Icon(
                                            Icons.folder,
                                            color: Colors.green[100],
                                          )
                                        : Container(),
                                    (document['tipo'] == 'proposta')
                                        ? Icon(
                                            Icons.edit,
                                            color: Colors.teal[200],
                                          )
                                        : Container(),
                                    (document['tipo'] == 'enquete')
                                        ? Icon(
                                            Icons.question_answer,
                                            color: Cores().corenquete,
                                          )
                                        : Container(),
                                    (document['tipo'] == 'recado')
                                        ? Icon(
                                            Icons.description,
                                            color: Colors.green[800],
                                          )
                                        : Container(),
                                    (document['tipo'] == 'cuidado')
                                        ? Icon(
                                            Icons.child_care,
                                            color: Cores().corcuidado,
                                          )
                                        : Container(),
                                    AutoSizeText(
                                      (document['tipo'] == 'bilhete')
                                          ? 'Informativo'
                                          : (document['tipo'] == 'documento')
                                              ? 'Documento'
                                              : (document['tipo'] == 'enquete')
                                                  ? 'Enquete'
                                                  : (document['tipo'] ==
                                                          'recado')
                                                      ? 'Recado'
                                                      : (document['tipo'] ==
                                                              'proposta')
                                                          ? 'Proposta'
                                                          : (document['tipo'] ==
                                                                  'cuidado')
                                                              ? 'Cuidados'
                                                              : '',
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
                (document['mensagem'] != null)
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Linkify(
                          onOpen: (link) async {
                            if (await canLaunch(link.url)) {
                              await launch(link.url);
                            } else {
                              throw 'Não foi possível abrir: $link';
                            }
                          },
                          text: document['mensagem'],
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 17.0,
                          ),
                        ),
                      )
                    : Container(),
                (document['fotos'] != null && document['fotos'].length == 1)
                    ? Column(
                        children: List<Widget>.generate(
                        document['fotos'].length,
                        (int index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 3.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FotoDetalhe(
                                            document['fotos'][index])));
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Hero(
                                  tag: document['fotos'][index],
                                  child: document['fotos'][index]
                                          .toString()
                                          .isNotEmpty
                                      ? GestureDetector(
                                          onTap: () async {
                                            if (document[
                                                        'linkescondidoimagem'] !=
                                                    null &&
                                                document['linkescondidoimagem']
                                                    .isNotEmpty) {
                                              var url = document[
                                                  'linkescondidoimagem'];
                                              if (await canLaunch(url) !=
                                                  null) {
                                                await launch(url);
                                              } else {
                                                throw 'Não conseguimos abrir $url';
                                              }
                                            } else {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FotoDetalhe(
                                                              document['fotos']
                                                                  [index])));
                                            }
                                          },
                                          child: (!kIsWeb)
                                              ? Layout().imagemshimmer(
                                                  document['fotos'][index])
                                              : Image.network(
                                                  document['fotos'][index]),
                                        )
                                      : Container(),
                                ),
                              ),
                            ),
                          );
                        },
                      ))
                    : (document['fotos'] != null && document['fotos'].length > 1) ?
                InkWell(
                    onTap: () async {
                      Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GaleriaDeFotos(
                                        document)));
                    },
                    child: Container(
                      color: Cores().corfundo,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(

                          children: <Widget>[
                             Text(
                              "Clique para ver\nGaleria de Fotos",
                              textAlign: TextAlign.center,

                              style: TextStyle(fontSize: 17.0, color: Colors.grey[800]),
                            ),
                            Icon(
                              Icons.photo_library,
                              size: 40.0,
                              color: Cores().corprincipal,
                            ),
                          ],
                        ),
                      ),
                    ))
                    : Container(),
                (document['linkyoutube'] != null &&
                        document['linkyoutube'].isNotEmpty)
                    ? ItemVideo(document)
                    : Container(),
                (document['video'] != null &&
                        document['video'].isNotEmpty &&
                        !kIsWeb)
                    ? ItemVideoEscola(document)
                    : Container(),
                (document['video'] != null &&
                        document['video'].isNotEmpty &&
                        kIsWeb)
                    ? GestureDetector(
                        onTap: () {
                          Pesquisa().abrirsite(document['video']);
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: Image.asset('images/videoplayer.jpg'),
                        ),
                      )
                    : Container(),
                (document['documento'] != null &&
                        document['documento'].isNotEmpty)
                    ? InkWell(
                        onTap: () async {
                          if (kIsWeb) {
                            var url = document['documento'];
                            if (await canLaunch(url) != null) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DocumentoDetalhes(
                                        'doc', document, usuario, false)));
                          }
                        },
                        child: Column(
                          children: <Widget>[
                            (document['nomedocumento'] != null &&
                                    document['nomedocumento'].isNotEmpty)
                                ? Text(
                                    document['nomedocumento'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 17.0),
                                  )
                                : Container(),
                            Icon(
                              Icons.picture_as_pdf,
                              size: 40.0,
                              color: Colors.grey,
                            ),
                          ],
                        ))
                    : Container(),
                (!widget.controle &&
                        document['tipo'] == 'recado' &&
                        document['resposta'] != null &&
                        document['enviarresposta'])
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          color: Colors.green[100],
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  document['resposta'],
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontStyle: FontStyle.italic),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              (document['respondidopor'] != null)
                                  ? Text(
                                      document['respondidopor'],
                                      style: TextStyle(color: Colors.black45),
                                      textAlign: TextAlign.end,
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      )
                    : Container(),
                (widget.controle &&
                        document['tipo'] == 'recado' &&
                        document['resposta'] != null)
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          color: Colors.green[100],
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  document['resposta'],
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontStyle: FontStyle.italic),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              (document['respondidopor'] != null)
                                  ? Text(
                                      document['respondidopor'],
                                      style: TextStyle(color: Colors.black45),
                                      textAlign: TextAlign.end,
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      )
                    : Container(),
                (document['tipo'] == 'cuidado')
                    ? Layout().itemCuidado(document, context)
                    : Container(),
                (document['tipo'] != 'cuidado')
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, right: 33.0, left: 33.0),
                        child: Divider(
                          thickness: 1.0,
                          color: Colors.grey,
                        ),
                      )
                    : Container(),
                (widget.controle &&
                        document['tipo'] == 'cuidado' &&
                        document['data'] != null &&
                        document['data'] == Pesquisa().hoje())
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: 35.0, right: 35.0, top: 10.0, bottom: 10.0),
                        child: Layout().itemdrawer(
                            "Editar",
                            Icons.edit,
                            CuidadosAdd(document['nome'], document['turma'],
                                document['unidade'], document['para'], usuario),
                            context),
                      )
                    : Container(),
                (document['tipo'] != 'cuidado')
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: 30.0, right: 30.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            (document['tipo'] == 'diario')
                                ? InkWell(
                                    onTap: () {
                                      if (curtiu != true) {
                                        if (!mounted) {
                                          return;
                                        }
                                        setState(() {
                                          curtiu = true;
                                        });
                                        document.reference.update({
                                          "curtidas": FieldValue.arrayUnion(
                                              [usuario.documentID])
                                        });
                                        Pesquisa().sendAnalyticsEvent(tela: Nomes().curtiu);
                                      }
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                            (curtiu != null && curtiu == true)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: (curtiu != null &&
                                                    curtiu == true)
                                                ? Colors.red
                                                : Colors.grey),
                                        Text((curtiu != null && curtiu == true)
                                            ? "Curti!"
                                            : "Curtir"),
                                      ],
                                    ),
                                  )
                                : Spacer(),
                            (document['tipo'] == 'recado' && widget.controle)
                                ? InkWell(
                                    onTap: () {
                                      Pesquisa().irpara(
                                          RecadoResposta(document, usuario,
                                              widget.moderacao),
                                          context);
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.assignment_ind,
                                          color: Colors.grey,
                                        ),
                                        Text('Responder'),
                                      ],
                                    ),
                                  )
                                : Container(),
                            (document['tipo'] == 'enquete' && !widget.controle)
                                ? InkWell(
                                    onTap: () {
                                      Pesquisa().irpara(
                                          ResponderEnquete(
                                              document, usuario, widget.aluno),
                                          context);
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.assignment_ind,
                                          color: Colors.grey,
                                        ),
                                        Text(resposta
                                            ? "Verificar Resposta"
                                            : 'Responder'),
                                      ],
                                    ),
                                  )
                                : Spacer(),
                            (document['tipo'] == 'documento' ||
                                    document['tipo'] == 'bilhete' ||
                                    document['tipo'] == 'lembrete')
                                ? InkWell(
                                    onTap: () {
                                      if (ciente != true) {
                                        if (!mounted) {
                                          return;
                                        }
                                        setState(() {
                                          ciente = true;
                                        });
                                        document.reference.update({
                                          "cientes": FieldValue.arrayUnion(
                                              [usuario.documentID])
                                        });
                                      }
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.check_circle_outline,
                                            color: (ciente != null &&
                                                    ciente == true)
                                                ? Colors.green
                                                : Colors.grey),
                                        Text((ciente != null && ciente == true)
                                            ? "Ciente"
                                            : "Dar Ciência"),
                                      ],
                                    ),
                                  )
                                : Spacer(),
                            (document['tipo'] == 'recado')
                                ? InkWell(
                                    onTap: () {
                                      if (widget.controle) {
                                        if (ciente != true) {
                                          if (!mounted) {
                                            return;
                                          }
                                          setState(() {
                                            ciente = true;
                                          });
                                          document.reference
                                              .update({"ciente": true});
                                        }
                                      }
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.check_circle_outline,
                                            color: (ciente != null &&
                                                    ciente == true)
                                                ? Colors.green
                                                : Colors.grey),
                                        Text((ciente != null && ciente == true)
                                            ? "Ciente"
                                            : "Aguardando Ciência"),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      )
                    : Container(),
                (widget.controle &&
                        widget.document['tipo'] != 'cuidado' &&
                        widget.document['tipo'] != 'enquete' &&
                        widget.document['tipo'] != 'recado')
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, right: 33.0, left: 33.0),
                        child: Divider(
                          thickness: 1.0,
                          color: Colors.grey,
                        ),
                      )
                    : Container(),
                (widget.controle && widget.document['tipo'] != 'recado')
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: 30.0, right: 30.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            (document['tipo'] == 'diario' ||
                                    document['tipo'] == 'videoescola' ||
                                    document['tipo'] == 'video' || document['tipo'] == 'Receitas')
                                ? InkWell(
                                    onTap: () {
                                      if (document['unidade'] ==
                                              widget.usuario['unidade'] ||
                                          widget.usuario['unidade'] ==
                                              'Todas as unidades') {
                                        if (document['curtidas'] != null) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      VisualizarCiente(document,
                                                          'curtidas')));
                                        } else {
                                          Layout().dialog1botao(
                                              context, "Não há curtidas", "");
                                        }
                                      }
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.favorite,
                                            color: Colors.grey),
                                        (document['curtidas'] != null)
                                            ? Text(
                                                "${List<String>.from(document['curtidas']).length} Curtidas",
                                                style:
                                                    TextStyle(fontSize: 11.0),
                                              )
                                            : Text('0 Curtidas',
                                                style:
                                                    TextStyle(fontSize: 11.0)),
                                      ],
                                    ),
                                  )
                                : Spacer(),
                            (document['tipo'] == 'enquete')
                                ? InkWell(
                                    onTap: () {
                                      if (document['unidade'] ==
                                              widget.usuario['unidade'] ||
                                          widget.usuario['unidade'] ==
                                              'Todas as unidades') {
                                        if (document['respostas'] != null) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RespostaEnquete(
                                                          document, usuario)));
                                        } else {
                                          Layout().dialog1botao(
                                              context, "Não há respostas", "");
                                        }
                                      }
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.assignment_ind,
                                          color: Colors.grey,
                                        ),
                                        (document['respostas'] != null)
                                            ? Text(
                                                "${List<String>.from(document['respostas']).length} Resposta",
                                                style:
                                                    TextStyle(fontSize: 11.0),
                                              )
                                            : Text('0 Respostas',
                                                style:
                                                    TextStyle(fontSize: 11.0)),
                                      ],
                                    ),
                                  )
                                : Spacer(),
                            (document['tipo'] == 'documento' ||
                                    document['tipo'] == 'bilhete' ||
                                    document['tipo'] == 'lembrete' ||
                                    document['tipo'] == 'recado')
                                ? InkWell(
                                    onTap: () {
                                      if (document['unidade'] ==
                                              widget.usuario['unidade'] ||
                                          widget.usuario['unidade'] ==
                                              'Todas as unidades') {
                                        if (document['cientes'] != null) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      VisualizarCiente(document,
                                                          'cientes')));
                                        } else {
                                          Layout().dialog1botao(
                                              context, "Não há cientes", "");
                                        }
                                      }
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.check_circle_outline,
                                            color: (ciente != null &&
                                                    ciente == true)
                                                ? Colors.green
                                                : Colors.grey),
                                        (document['cientes'] != null)
                                            ? Text(
                                                "${List<String>.from(document['cientes']).length} Ciente",
                                                style:
                                                    TextStyle(fontSize: 11.0),
                                              )
                                            : Text('0 Cientes',
                                                style:
                                                    TextStyle(fontSize: 11.0)),
                                      ],
                                    ),
                                  )
                                : Spacer(),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
