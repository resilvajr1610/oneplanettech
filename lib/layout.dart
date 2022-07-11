import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:masked_text/masked_text.dart';
import 'package:photo_view/photo_view.dart';
import 'package:scalifra/fotoaluno.dart';
import 'package:scalifra/login/loginweb.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chat/mensageminterna.dart';
import 'cuidados/cuidadosadd.dart';

import 'fotodetalhe.dart';
import 'login/login.dart';
import 'mensagem.dart';
import 'mensagemweb.dart';
import 'pdfviewer.dart';
import 'editar.dart';
import 'main.dart';
import 'recadoresposta.dart';
import 'design.dart';
import 'pesquisa.dart';
import 'respostaEnquete.dart';
import 'turmasadd.dart';
import 'unidadesadd.dart';
import 'usuarioadd.dart';

class Layout {
  Widget floatingactionbar(funcao, icon, tip, context) {
    return FloatingActionButton(
        backgroundColor: Cores().corprincipal,
        onPressed: funcao,
        tooltip: tip,
        child: Icon(icon));
  }

  appbar(nomebarra) {
    return AppBar(
      elevation: 0.0,
      backgroundColor: Cores().corprincipal,
      title: Text(nomebarra),
    );
  }

  imagemshimmer(link) {
    return Container(
      child: CachedNetworkImage(
        imageUrl: link,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Image.asset(
            'images/logovertical.png',
            height: 20.0,
          ),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }

  Widget menuheader(usuario, logo, context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 130.0,
          child: (logo != null)
              ? (kIsWeb)
                  ? Image.network(
                      logo,
                      fit: BoxFit.contain,
                    )
                  : imagemshimmer(logo)
              : Image.asset("images/logoredondo.png", fit: BoxFit.contain),
        ),
        (usuario != null && usuario['nome'] != null)
            ? Text(
                usuario['nome'],
                style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Cores().corprincipal),
              )
            : Text(""),
        (usuario != null && usuario['email'] != null)
            ? Text(
                usuario['email'],
                style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Cores().corprincipal),
              )
            : Container(),
      ],
    );
  }

  Widget footerdesenvolvidopor() {
    return InkWell(
      onTap: () async {
        const url = 'http://www.oneplanet.tech';
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 12.0),
        child: Text(
          "Desenvolvido por OnePlanet Tech",
          style: TextStyle(fontSize: 12.0),
        ),
      ),
    );
  }

  Widget footerversao(version, buildNumber) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 12.0),
      child: Text("Versão: $version - $buildNumber",
          style: TextStyle(fontSize: 12.0)),
    );
  }

  Widget sair(context) {
    return InkWell(
      onTap: () {
        showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: new Text("Deseja encerrar sessão?"),
                content: new Text(
                    "Será necessário fazer login com e-mail e senha novamente."),
                actions: <Widget>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text("OK",
                        style: TextStyle(color: Cores().corprincipal)),
                    onPressed: () {
                      Pesquisa().sendAnalyticsEvent(tela: Nomes().sair);
                      FirebaseAuth.instance.signOut().then((user) {
                        Navigator.pop(context);
                        if (kIsWeb) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginWeb()));
                        } else {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => Login()));
                        }
                      });
                    },
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text("CANCELAR",
                        style: TextStyle(color: Cores().corprincipal)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
      },
      child: ListTile(
        title: Text(
          "Encerrar sessão",
          style: sanslight(),
        ),
        leading: Icon(
          Icons.power_settings_new,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  appbarcombotaosimples(funcao, nomebarra, nomebotao, context,
      {bool deletar=false, String userid=''}) {
    return AppBar(
      elevation: 0.0,
      backgroundColor: Cores().corprincipal,
      actions: <Widget>[
        (deletar != null && deletar)
            ? FlatButton(
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onPressed: () {
                  dialogexcluiruser(userid, context);
                },
              )
            : Container(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.white),
          onPressed: () {
            funcao(context);
          },
          child: Text(
            nomebotao,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
          ),
        ),
      ],
      title: Text(nomebarra),
    );
  }

  dialogexcluiruser(userid, context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text("Excluir usuário"),
            content: new Text("Excluir usuário? Ação não pode ser desfeita"),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Cores().corprincipal),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(
                    "EXCLUIR",
                    style: TextStyle(color: Cores().corprincipal),
                  ),
                  onPressed: () {
                    Pesquisa().excluiruser(userid);
                    Navigator.pop(context);

                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  itemcomponente(doc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Layout().titulo(doc['componente']),
      ),
    );
  }

  Widget itemTurma(document, usuario, destino, context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: InkWell(
        onTap: () {
          if (destino != null) {
            Pesquisa().irpara(destino, context);
          }
        },
        onLongPress: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TurmasAdd(usuario, document, document['unidade'])));
        },
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: (document['logo'] != null)
                      ? Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: (!kIsWeb)
                                    ? CachedNetworkImageProvider(
                                        document['logo'])
                                    : NetworkImage(document['logo'])as ImageProvider,
                                fit: BoxFit.contain),
                          ))
                      : Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("images/logoredondo.png"),
                                  fit: BoxFit.contain),
                              color: Colors.black26)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      document['turma'],
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    (document['curso'] != null)
                        ? AutoSizeText(document['curso'])
                        : Text(''),
                  ],
                ),
              ],
            ),
            Divider(thickness: 0.5, color: Colors.grey)
          ],
        ),
      ),
    );
  }

  Widget espacolateral(context) {
    return (MediaQuery.of(context).size.width > 950)
        ? SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
          )
        : Container();
  }

  Widget itemUnidade(document, usuario, context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: InkWell(
        onLongPress: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UnidadesAdd(usuario, document)));
        },
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: (document['logomenu'] != null)
                      ? Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: (!kIsWeb)
                                    ? CachedNetworkImageProvider(
                                        document['logomenu'])
                                    : NetworkImage(document['logomenu'])as ImageProvider,
                                fit: BoxFit.contain),
                          ))
                      : Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("images/logoredondo.png"),
                                  fit: BoxFit.contain),
                              color: Colors.black26)),
                ),
                Expanded(
                  child: AutoSizeText(
                    document['unidade'],
                    maxLines: 2,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.grey,
              thickness: 0.5,
            )
          ],
        ),
      ),
    );
  }

  Widget itemmenu(text, icon, destino, context) {
    return Card(
      child: InkWell(
        hoverColor: Cores().corprincipal.withOpacity(0.2),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => destino));
        },
        child: ListTile(
          title: Text(
            text,
            style: sanslight(),
          ),
          leading: Icon(
            icon,
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }

  TextStyle sanslight() {
    return TextStyle(
        color: Colors.black, fontFamily: "Sans", fontWeight: FontWeight.w200);
  }

  Widget itemmenuportal(text, icon, funcao, context) {
    return Card(
      child: InkWell(
        hoverColor: Cores().corprincipal.withOpacity(0.2),
        onTap: funcao,
        child: ListTile(
          title: Text(
            text,
            style: sanslight(),
          ),
          leading: Icon(
            icon,
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }

  Widget itemdrawer(text, icon, destino, context) {
    return Card(
      child: InkWell(
        hoverColor: Cores().corprincipal.withOpacity(0.2),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => destino));
        },
        child: ListTile(
          title: Text(
            text,
            style: TextStyle(color: Cores().corprincipal),
          ),
          leading: Icon(
            icon,
            color: Cores().corprincipal,
          ),
        ),
      ),
    );
  }

  itemperfil(doc, boolean, funcao, texto) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Layout().titulo(doc['perfil']),
            ),
            Row(
              children: <Widget>[
                Checkbox(
                    checkColor: Cores().corprincipal,
                    value: (boolean != null) ? boolean : false,
                    onChanged: (value) {
                      funcao(value);
                    }),
                Text(texto),
              ],
            )
          ],
        ),
      ),
    );
  }

  itemdrawerfiltro(text, icon, funcao, context) {
    return Card(
      child: InkWell(
        onTap: () {
          funcao("ok");
        },
        child: ListTile(
          title: Text(
            text,
            style: TextStyle(color: Cores().corprincipal),
          ),
          leading: Icon(icon, color: Cores().corprincipal),
        ),
      ),
    );
  }

 Widget itemMensagemTela(DocumentSnapshot document, user, controle, tipo,
      context, palavrapesquisada) {
    return (palavrapesquisada == null ||
            document['nome']
                .toString()
                .toLowerCase()
                .contains(palavrapesquisada.toString().toLowerCase()) ||
            document['alunonome']
                .toString()
                .toLowerCase()
                .contains(palavrapesquisada.toString().toLowerCase()))
        ? Card(
            elevation: 1.0,
            child: InkWell(
              onTap: () {
                //Pesquisa().sendAnalyticsEvent(tela: Nomes().itemmensagem);
                if (document['para'] == 'Professor') {
                  FirebaseFirestore.instance
                      .collection(Nomes().usersbanco)
                      .doc(document['professorid'])
                      .get()
                      .then((value) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Mensagem(
                                document['para'],
                                user,
                                document['aluno'],
                                document['origem'],
                                controle,
                                professor: value)));
                  });
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Mensagem(
                            document['para'],
                            user,
                            document['aluno'],
                            document['origem'],
                            controle,
                            professor: '' as DocumentSnapshot,
                          )));
                }
              },
              onLongPress: () {
                return marcarcomolida(document, context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Spacer(),
                        Text(
                          document['data'],
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    AutoSizeText(
                      document['para'],
                      style: TextStyle(
                          color: Cores().corprincipal,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                          fontSize: 17.0),
                    ),
                    Row(
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          child: Column(
                            children: <Widget>[
                              (document['parentesco'] != null)
                                  ? Text(
                                      document['parentesco'],
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  : Container(),
                              (document['logo'] != null)
                                  ? Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  document['logo']),
                                              fit: BoxFit.cover)),
                                    )
                                  : Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  "images/picture.png"),
                                              fit: BoxFit.cover)),
                                    ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 12,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  document['nome'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                (document['nome'] != document['alunonome'])
                                    ? Text(
                                        document['alunonome'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      )
                                    : Container(),
                                (document['curso'] != null &&
                                        document['turma'] != null)
                                    ? Text(
                                        document['unidade'] +
                                            ' - ' +
                                            document['curso'] +
                                            ' - ' +
                                            document['turma'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black),
                                      )
                                    : Container(),
                                Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      document['mensagem'],
                                      style: TextStyle(color: Colors.grey),
                                    )),
                                ((tipo == 'escola' &&
                                            document['nova'] == 'escola') ||
                                        (tipo == 'pais' &&
                                            document['nova'] == 'pais'))
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.add_alert,
                                            color: Cores().corprincipal,
                                            size: 25.0,
                                          ),
                                          Text(
                                            'Nova',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container();
  }

  Widget itemMensagemTelaInterna(
      DocumentSnapshot mensagemdoc, DocumentSnapshot user, context) {
    return Card(
      elevation: 1.0,
      child: InkWell(
        onTap: () {
          String outrodoc = (mensagemdoc['user1'] == user.id)
              ? mensagemdoc['user2']
              : mensagemdoc['user1'];
          FirebaseFirestore.instance
              .collection(Nomes().usersbanco)
              .doc(outrodoc)
              .get()
              .then((outrouserdoc) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Mensageminterna(user, outrouserdoc)));
          });
        },
        onLongPress: () {
          return marcarcomolida(mensagemdoc, context);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    mensagemdoc['data'],
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: <Widget>[
                        ((mensagemdoc['fotouser1'] != null &&
                                    mensagemdoc['fotouser1'] != user['foto']) ||
                                (mensagemdoc['fotouser2'] != null &&
                                    mensagemdoc['fotouser2'] != user['foto']))
                            ? Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            (mensagemdoc['fotouser1'] !=
                                                    user['foto'])
                                                ? mensagemdoc['fotouser1']
                                                : mensagemdoc['fotouser2']),
                                        fit: BoxFit.cover)),
                              )
                            : Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: AssetImage("images/picture.png"),
                                        fit: BoxFit.cover)),
                              ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 12,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            mensagemdoc['nomeuser1'] == user['nome']
                                ? mensagemdoc['nomeuser2']
                                : mensagemdoc['nomeuser1'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                mensagemdoc['mensagem'],
                                style: TextStyle(color: Colors.grey),
                              )),
                          (mensagemdoc['novamsg'] == user.id)
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.add_alert,
                                      color: Cores().corprincipal,
                                      size: 25.0,
                                    ),
                                    Text(
                                      'Nova',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              : Container()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textfieldtelefone(
    controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        // maskedTextFieldController: controller,
        maxLength: 15,
        keyboardType: TextInputType.number,
        //mask: "(xx) xxxxx-xxxxx",
        decoration: InputDecoration(
          hintText: '(xx) xxxxx-xxxx',
          hintStyle: TextStyle(
              fontWeight: FontWeight.w500,
              letterSpacing: 1.3,
              color: Colors.black45),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          labelText: 'Telefone',
          labelStyle:
              TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget campopesquisa(funcaopesquisa) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 50.0,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5.0,
                  spreadRadius: 0.0)
            ]),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 10.0),
            child: Theme(
              data: ThemeData(hintColor: Colors.transparent),
              child: TextFormField(
                onChanged: funcaopesquisa,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.search,
                      color: Cores().corprincipal,
                      size: 28.0,
                    ),
                    hintText: "Pesquisa",
                    hintStyle: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  textfieldcep(controller) {
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        // maskedTextFieldController: controller,
        maxLength: 15,
        keyboardType: TextInputType.number,
        // mask: "xx.xxx-xxx",
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          labelText: 'CEP',
          counterText: "",
          labelStyle:
              TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget titulo(texto, {bool smallSize = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        (texto.toString().isNotEmpty) ? texto : "Selecione",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: smallSize ? 15 : 18.0,
            fontFamily: "Sans",
            letterSpacing: 1.5,
            color: texto.toString().isNotEmpty ? Colors.black : Colors.grey),
      ),
    );
  }

  Widget dropdownitem(placeholder, selecionado, funcao, lista) {
    return DropdownButton<String>(
      isExpanded: true,
      value: selecionado,
      hint: Center(
        child: AutoSizeText(
          placeholder,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onChanged: (value) {
        funcao(value);
      },
      items: lista.map<DropdownMenuItem<String>>((value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Center(
            child: AutoSizeText(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget itemCuidado(document, context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: Text(
              "Alimentação",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            )),
          ),
          (document['manha'] != null)
              ? Text("Manhã: " + document['manha'])
              : Container(),
          (document['almoco'] != null)
              ? Text("Almoço: " + document['almoco'])
              : Container(),
          (document['lanche'] != null)
              ? Text("Lanche: " + document['lanche'])
              : Container(),
          (document['fruta'] != null)
              ? Text("Fruta: " + document['fruta'])
              : Container(),
          (document['jantar'] != null)
              ? Text("Jantar: " + document['jantar'])
              : Container(),
          SizedBox(
            height: 8.0,
          ),
          (document['qtdademamadeira'] == null &&
                  (document['mamadeirahorario'] == null ||
                      document['mamadeirahorario'].isEmpty))
              ? Container()
              : Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          width: 500.0,
                          height: 25.0,
                          color: Cores().corcuidado,
                          child: Center(
                              child: Text(
                            "Mamadeira",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ))),
                    ),
                    (document['qtdademamadeira'] != null)
                        ? Text(document['qtdademamadeira'])
                        : Container(),
                    (document['mamadeirahorario'] != null &&
                            document['mamadeirahorario'].isNotEmpty)
                        ? Text(document['mamadeirahorario'])
                        : Container(),
                  ],
                ),
          (document['sono'] != null && document['sono'].isNotEmpty)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      width: 500.0,
                      height: 25.0,
                      color: Cores().corcuidado,
                      child: Center(
                          child: Text(
                        "Soninho",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0),
                      ))),
                )
              : Container(),
          (document['sono'] != null && document['sono'].isNotEmpty)
              ? Text(document['sono'])
              : Container(),
          (document['xixi'] != null && document['xixi'].isNotEmpty ||
                  document['cc'] != null ||
                  (document['cchorario'] != null &&
                      document['cchorario'].isNotEmpty))
              ? Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          width: 500.0,
                          height: 25.0,
                          color: Cores().corcuidado,
                          child: Center(
                              child: Text(
                            "Cuidados",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ))),
                    ),
                    (document['xixi'] != null && document['xixi'].isNotEmpty)
                        ? Text("Xixi: " + document['xixi'])
                        : Container(),
                    (document['cc'] != null ||
                            (document['cchorario'] != null &&
                                document['cchorario'].isNotEmpty))
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Cocô: "),
                              Text(""),
                              (document['cc'] != null)
                                  ? Text(document['cc'])
                                  : Container(),
                              Text(" - "),
                              (document['cchorario'] != null &&
                                      document['cchorario'].isNotEmpty)
                                  ? Text(document['cchorario'])
                                  : Container(),
                            ],
                          )
                        : Container(),
                  ],
                )
              : Container(),
          (document['obs'] != null && document['obs'].isNotEmpty)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    document['obs'],
                    style:
                        TextStyle(fontStyle: FontStyle.italic, fontSize: 16.0),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget itemnovamensagem(context, texto, destino) {
    return Container(
        child: InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => destino));
      },
      child: Card(
        color: Cores().corbilhetes,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_alert,
                color: Colors.red,
                size: 25.0,
              ),
              Text(
                texto,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  itemlink(DocumentSnapshot document, usuario, controle, context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Icon(
                      Icons.web,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              Text(document["data"]),
              Text(
                "Para: " + document["turma"],
              ),
              (document["nomelink"] != null)
                  ? Text(document["nomelink"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ))
                  : Container(),
              InkWell(
                onLongPress: () {
                  if (controle) {
                    editar(document, usuario, context);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw 'Não foi possível abrir o link: $link';
                        }
                      },
                      text: document['link'],
                    ),
                  ),
                ),
              ),
              Divider(
                thickness: 0.6,
                color: Cores().corprincipal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  editar(document, usuario, context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text("Editar Publicação"),
            content: new Text("Deseja editar esta publicação?"),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Cores().corprincipal),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(
                    "DELETAR",
                    style: TextStyle(color: Cores().corprincipal),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    deletar(document, context);
                  }),
              (document['tipo'] != "documento")
                  ? CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text(
                        "EDITAR TEXTO",
                        style: TextStyle(color: Cores().corprincipal),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Editar(document)));
                      })
                  : Container(),
              (usuario['controle'] == Nomes().controle &&
                      (document['tipo'] == "documento" ||
                          document['tipo'] == "bilhete" ||
                          document['tipo'] == "enquete"))
                  ? CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text(
                        "ENVIAR PARA O TOPO",
                        style: TextStyle(color: Cores().corprincipal),
                      ),
                      onPressed: () {
                        document.reference.updateData({
                          'datacomparar': DateTime.now(),
                          'reordenado': true
                        }).then((value) {
                          Navigator.pop(context);
                        });
                      })
                  : Container(),
            ],
          );
        });
  }

  Widget itemCardapio(doc, controle, usuario, size, imagem, context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          height: (doc['documento'] != null)
              ? MediaQuery.of(context).size.height * size * 0.4
              : MediaQuery.of(context).size.height * size,
          width: MediaQuery.of(context).size.width,
          child: GestureDetector(
            onTap: () {
              if (doc['documento'] != null) {
                Pesquisa().irpara(
                    DocumentoDetalhes('', doc, usuario, controle), context);
              }
              if (doc['imagem'] != null) {
                Pesquisa().irpara(FotoDetalhe(doc['imagem']), context);
              }
            },
            onLongPress: () {
              if (controle != null && controle) {
                deletar(doc, context);
              }
            },
            child: Card(
              elevation: 8.0,
              child: ClipRRect(
                  borderRadius: new BorderRadius.circular(4.0),
                  child: Column(
                    children: <Widget>[
                      (doc['tipo'] != null)
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              color: Cores().corprincipal,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${doc['tipo']}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            )
                          : Container(),
                      (doc['imagem'] != null)
                          ? Expanded(
                              child: PhotoView(
                                backgroundDecoration:
                                    BoxDecoration(color: Colors.white),
                                imageProvider: NetworkImage(doc['imagem']),
                              ),
                            )
                          : Container(),
                      (doc['documento'] != null)
                          ? Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(doc['titulo'] ?? ""),
                                  Container(
                                      color: Colors.red,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              "Clique aqui para abrir o arquivo",
                                              style: TextStyle(
                                                  backgroundColor: Colors.red,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Icon(
                                              Icons.picture_as_pdf,
                                              size: 30.0,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Widget itemAniversario(DocumentSnapshot doc, BuildContext context,
      {bool smallSize = false}) {
    String nome = doc['nome'].split(' ')[0];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: <Widget>[
        smallSize
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("images/cake.gif"),
                              fit: BoxFit.cover)),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                doc['datanascimento']
                                    .toString()
                                    .substring(0, 2),
                                style: TextStyle(
                                    fontSize: 15.0,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red),
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              AutoSizeText(
                                nome,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    letterSpacing: 1.5,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(doc['curso'] + ' - ' + doc['turma'],
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.height * 0.2,
                      height: MediaQuery.of(context).size.height * 0.2,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("images/cake.gif"),
                              fit: BoxFit.cover)),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Flexible(
                            flex: 2,
                            child: Row(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      doc['datanascimento']
                                          .toString()
                                          .substring(0, 2),
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          letterSpacing: 1.2,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red),
                                    )
                                  ],
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                AutoSizeText(
                                  nome,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(doc['curso'] + ' - ' + doc['turma'],
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        Divider(
          thickness: 0.6,
          color: Cores().corprincipal,
        ),
      ]),
    );
  }

  Widget itemeventoCalendario(
      {required bool controle,
      required DocumentSnapshot doc,
      required DocumentSnapshot usuario,
      required DocumentSnapshot aluno,
      required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 8.0),
      child: InkWell(
        onLongPress: () {
          if ((controle && usuario['perfil'] != 'Professor') ||
              doc['responsavel'] == (usuario['nome']) ||
              doc['parametrosbusca'].contains(aluno.id)) {
            Layout().deletar(doc, context);
          }
        },
        child: Row(
          children: [
            Icon(Icons.calendar_today),
            SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Layout().titulo(doc['data']),
                      (doc['hora'].toString() != '00h00' &&
                              doc['hora'].toString() != '00:00' &&
                              doc['hora'].toString() != '')
                          ? Layout().titulo('- ' + doc['hora'].toString())
                          : Layout().titulo(' '),
                    ],
                  ),
                  Container(
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw 'Não foi possível abrir: $link';
                        }
                      },
                      text: doc['evento'],
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 17.0,
                      ),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(
              width: 8.0,
            ),
            //caso haja responsavel Container
            // se houver
            Layout().texto(
              doc['responsavel'] != null
                  ? doc['parametrosbusca'][0]
                  : 'Pessoal',
              10.0,
              FontWeight.normal,
              Colors.grey,
              maxLines: 1,
              textDecoration: TextDecoration.none,
              overflow: TextOverflow.ellipsis,
              height: 5,
              align: TextAlign.center
            ),

            Divider(
              thickness: 0.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget itemEnqueteresposta(document, context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 2.0),
        child: Card(
          elevation: 1.0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(top: 8.0, right: 12.0, left: 12.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: (document['logo'] != null)
                          ? Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: (!kIsWeb)
                                        ? CachedNetworkImageProvider(
                                            document['logo'])
                                        : NetworkImage(document['logo'])as ImageProvider,
                                    fit: BoxFit.contain),
                              ))
                          : Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image:
                                          AssetImage("images/logoredondo.png"),
                                      fit: BoxFit.contain),
                                  color: Colors.black26)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          (document['para'] == "Todas")
                              ? Text(Nomes().todasturmas,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.0,
                                  ))
                              : AutoSizeText(document['para'],
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.0,
                                  )),
                          Text(
                            document['data'],
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15.0),
                          ),
                        ],
                      ),
                    ),
                    Padding(
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
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  child: Hero(
                    tag: document.documentID,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Center(
                            child: Text(
                          document['mensagem'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15.0,
                              wordSpacing: 1.5),
                        )),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget checkBox(boolean, funcaosetboolean, texto) {
    return Row(
      children: <Widget>[
        Checkbox(
            checkColor: Cores().corprincipal,
            value: (boolean != null) ? boolean : false,
            onChanged: (value) {
              funcaosetboolean(value);
            }),
        Expanded(child: AutoSizeText(texto)),
      ],
    );
  }

  Widget segmented(opcoes, opcao, funcao, context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: CupertinoSegmentedControl<int>(
            selectedColor: Cores().corprincipal,
            borderColor: Cores().corprincipal,
            children: opcoes,
            onValueChanged: (val) {
              funcao(val);
            },
            groupValue: opcao),
      ),
    );
  }

  Widget itemRecadoadd(nome, turma, funcao, context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: <Widget>[
            Text(
              Pesquisa().hoje(),
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.0),
            ),
            (nome != null) ? Text(nome) : Text(" "),
            (turma != null)
                ? Text(turma,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15.0,
                    ))
                : Container(),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: CupertinoTextField(
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey)),
                textCapitalization: TextCapitalization.sentences,
                autofocus: false,
                minLines: 5,
                maxLines: 20,
                placeholder: "Escreva a mensagem",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    fontSize: 16.0,
                    color: Colors.black,
                    wordSpacing: 1.5),
                onChanged: (text) {
                  funcao(text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget secao(texto, cor) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        width: 500.0,
        height: 25.0,
        color: cor.withOpacity(0.2),
        child: Center(
            child: Text(
          texto,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        )),
      ),
    );
  }

  marcarcomolida(DocumentSnapshot document, context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text("Mensagem Lida"),
            content: new Text("Deseja marcar mensagem como lida?"),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Cores().corprincipal),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(
                    "LIDA",
                    style: TextStyle(color: Cores().corprincipal),
                  ),
                  onPressed: () {
                    Pesquisa().sendAnalyticsEvent(tela: Nomes().msgLida);
                    document.reference.update({'nova': "lida"}).then((val) {
                      Navigator.pop(context);
                    });
                  }),
            ],
          );
        });
  }

  deletar(document, context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text("Deletar Publicação"),
            content: new Text("Deseja deletar esta publicação?"),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Cores().corprincipal),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(
                    "DELETAR",
                    style: TextStyle(color: Cores().corprincipal),
                  ),
                  onPressed: () {
                    document.reference.delete().then((val) {
                      Navigator.pop(context);
                    });
                  }),
            ],
          );
        });
  }

  Widget itemmensageminterna(
      DocumentSnapshot msg, DocumentSnapshot user, context) {
    return Padding(
      padding: (msg['emissor'] == user.id)
          ? const EdgeInsets.only(right: 50.0, top: 3.0, bottom: 3.0)
          : const EdgeInsets.only(left: 50.0, top: 3.0, bottom: 3.0),
      child: InkWell(
        onLongPress: () {
          if (msg['emissor'] == user.id) {
            deletar(msg, context);
          }
        },
        child: Bubble(
          nip: (msg['emissor'] == user.id)
              ? BubbleNip.leftBottom
              : BubbleNip.rightBottom,
          color: (msg['emissor'] == user.id)
              ? Colors.white
              : Colors.teal[100],
          child: Column(
            children: <Widget>[
              (msg['foto'] != null)
                  ? GestureDetector(
                      onTap: () {
                        Pesquisa().irpara(FotoDetalhe(msg['foto']), context);
                      },
                      child: Container(
                          color: Colors.transparent,
                          height: MediaQuery.of(context).size.height * 0.45,
                          width: MediaQuery.of(context).size.width,
                          child: PhotoView(
                            initialScale: PhotoViewComputedScale.contained,
                            backgroundDecoration:
                                BoxDecoration(color: Colors.transparent),
                            imageProvider: NetworkImage(msg['foto']),
                          )),
                    )
                  : Container(),
              (msg['audio'] != null)
                  ? IconButton(
                      icon: Icon(Icons.play_circle_filled,
                          size: 40.0, color: Cores().corprincipal),
                      onPressed: () async {
                        final url = msg['audio'];
                        AudioPlayer audioPlayer = AudioPlayer();
                        await audioPlayer.play(url);
                      },
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: (msg['mensagem'] != null)
                    ? Linkify(
                        onOpen: (link) async {
                          if (await canLaunch(link.url)) {
                            await launch(link.url);
                          } else {
                            throw 'Não foi possível abrir o link: $link';
                          }
                        },
                        text: msg['mensagem'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15.0,
                            wordSpacing: 1.5),
                      )
                    : null,
              ),
              (msg['documento'] != null && msg['documento'].isNotEmpty)
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: InkWell(
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DocumentoDetalhes(
                                        'doc', msg, user, false)));
                          },
                          child: Column(
                            children: <Widget>[
                              Flexible(
                                flex: 2,
                                child: ListTile(
                                  title: Text(
                                    'PDF',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 17.0),
                                  ),
                                ),
                              ),
                              Flexible(
                                  flex: 1,
                                  child: Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.grey,
                                  )),
                            ],
                          )),
                    )
                  : Container(),
              Text(
                msg['data'],
                style: TextStyle(color: Colors.black38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const  double fontSizeDataWeb = 18.0;
  static const double fontSizeDataMobile = 11.0;
  static const  double fontSizeMsgTextWeb = 24.0;
  static const double fontSizeMsgTextMobile = 18.0;

  Widget itemmensagem(DocumentSnapshot msg, paiuser, controle, context, bool expandDetails) {
    return Padding(
      padding: (msg['emissor'] == 'escola')
          ? const EdgeInsets.only(right: 50.0, top: 3.0, bottom: 3.0)
          : const EdgeInsets.only(left: 50.0, top: 3.0, bottom: 3.0),
      child: InkWell(
        onLongPress: () {
          if (msg['emissor'] != "escola") {
            deletar(msg, context);
          }

          if (msg['emissor'] == "escola" && controle) {
            deletar(msg, context);
          }
        },
        child: Bubble(
          nip: (msg['emissor'] == 'escola')
              ? BubbleNip.leftBottom
              : BubbleNip.rightBottom,
          color: (msg['emissor'] == 'escola') ? Colors.white : Colors.teal[100],
          child: Column(
            children: <Widget>[
              (msg['foto'] != null)
                  ? GestureDetector(
                      onTap: () {
                        Pesquisa().irpara(FotoDetalhe(msg['foto']), context);
                      },
                      child: Container(
                          color: Colors.transparent,
                          height: MediaQuery.of(context).size.height * 0.45,
                          width: MediaQuery.of(context).size.width,
                          child: PhotoView(
                            initialScale: PhotoViewComputedScale.contained,
                            backgroundDecoration:
                                BoxDecoration(color: Colors.transparent),
                            imageProvider: NetworkImage(msg['foto']),
                          )),
                    )
                  : Container(),
              (msg['audio'] != null)
                  ? IconButton(
                      icon: Icon(Icons.play_circle_filled,
                          size: 40.0, color: Cores().corprincipal),
                      onPressed: () async {
                        final url = msg['audio'];
                        AudioPlayer audioPlayer = AudioPlayer();
                        await audioPlayer.play(url);
                      },
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: (msg['mensagem'] != null)
                    ? Linkify(
                        onOpen: (link) async {
                          if (await canLaunch(link.url)) {
                            await launch(link.url);
                          } else {
                            throw 'Não foi possível abrir o link: $link';
                          }
                        },
                        text: msg['mensagem'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSans(textStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: kIsWeb ? fontSizeMsgTextWeb : fontSizeMsgTextMobile ,
                            wordSpacing: 1.5),)

                      )
                    : null,
              ),
              (msg['documento'] != null && msg['documento'].isNotEmpty)
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: InkWell(
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DocumentoDetalhes(
                                        'doc', msg, paiuser, false)));
                          },
                          child: Column(
                            children: <Widget>[
                              Flexible(
                                flex: 2,
                                child: ListTile(
                                  title: Text(
                                    'PDF',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 17.0),
                                  ),
                                ),
                              ),
                              Flexible(
                                  flex: 1,
                                  child: Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.grey,
                                  )),
                            ],
                          )),
                    )
                  : Container(),
              expandDetails ?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    msg['data'],
                    style: TextStyle(color: Colors.black38, fontSize: kIsWeb ? fontSizeDataWeb : fontSizeDataMobile )),

                  (msg['responsavel'] != null) ? Text(
                    msg['responsavel'],
                    style: TextStyle(color: Colors.black38, fontSize: kIsWeb ? fontSizeDataWeb : fontSizeDataMobile),
                  )
                  : Container(),
                ],
              )
              : Container()
            ],
          ),
        ),
      ),
    );
  }

  Widget itemRecadoEscola(document, perfil, moderacao, usuario, context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Spacer(),
                  Icon(
                    Icons.face,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Text(
              document['data'],
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.0),
            ),
            Text("Referente a " + document['responsavel']),
            Text(document['turma'],
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0,
                )),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: InkWell(
                  onLongPress: () {
                    if (perfil != null &&
                        perfil != "Professora" &&
                        perfil != "Secretaria") {
                      deletar(document, context);
                    }
                  },
                  child: Card(
                    elevation: 7.0,
                    color: Cores().corquadrorecado,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(50.0),
                          child: Text(
                            document['mensagem'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                fontSize: 15.0,
                                color: Cores().cortextorecado,
                                wordSpacing: 1.5),
                          ),
                        ),
                        (document['fotos'] != null)
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
                                                builder: (context) =>
                                                    FotoDetalhe(
                                                        document['fotos']
                                                            [index])));
                                      },
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        child: Hero(
                                          tag: document['fotos'][index],
                                          child: document['fotos'][index]
                                                  .toString()
                                                  .isNotEmpty
                                              ? PhotoView(
                                                  initialScale:
                                                      PhotoViewComputedScale
                                                          .contained,
                                                  backgroundDecoration:
                                                      BoxDecoration(
                                                    color: Colors.white70,
                                                  ),
                                                  imageProvider: (!kIsWeb)
                                                      ? CachedNetworkImageProvider(
                                                          document['fotos'][index])
                                                      : NetworkImage(document['fotos'][index])as ImageProvider,
                                                )
                                              : Container(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ))
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            (document['ciente'] == true)
                ? Center(
                    child: Row(
                      children: <Widget>[
                        Spacer(),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        Text("Ciente"),
                        Spacer(),
                      ],
                    ),
                  )
                : Center(
                    child: InkWell(
                      onTap: () {
                        Map<String, dynamic> map = Map();
                        map['ciente'] = true;
                        FirebaseFirestore.instance
                            .collection(Nomes().publicacoesbanco)
                            .doc(document.documentID)
                            .update(map);

                        Pesquisa().enviarnotificacao(
                            Nomes().push + document['para'],
                            "Professora ciente do seu recado");
                      },
                      child: Row(
                        children: <Widget>[
                          Spacer(),
                          Icon(
                            Icons.remove_circle,
                            color: Colors.grey[200],
                          ),
                          Text("Aguardando ciência"),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
            InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RecadoResposta(document, usuario, moderacao)));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Resposta"),
                )),
            (document['resposta'] != null)
                ? Container(
                    color: Colors.yellow[50],
                    child: Text(
                      document['resposta'],
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ))
                : Container(),
            (moderacao)
                ? GestureDetector(
                    onTap: () {
                      if (usuario['moderador'] != null &&
                          usuario['moderador']) {
                        document.reference.updateData({
                          'enviar': true,
                        });
                        Pesquisa().enviarnotificacao(
                            Nomes().push + document['para'],
                            "Professora respondeu seu recado");
                      } else {
                        Toast.show("Seu perfil não é moderador", textStyle: context,
                            duration: Toast.lengthLong, gravity: Toast.center);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 50.0, top: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(
                            Icons.check_circle,
                            color: (document['enviar'] == null ||
                                    !document['enviar'])
                                ? Colors.grey
                                : Colors.green,
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(
                thickness: 0.6,
                color: Cores().corprincipal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemRespostaEnquete(
      nome, turma, foto, resposta, nomemae, parentesco, context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 3.0,
        child: Column(
          children: <Widget>[
            Text(nome != null ? nome : "Nome"),
            Text(turma != null ? turma : "Turma"),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: foto != null
                  ? Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: foto != null
                                  ? NetworkImage(foto)
                                  : AssetImage("images/picture.png")as ImageProvider,
                              fit: BoxFit.cover)),
                    )
                  : Container(),
            ),
            Container(
              width: 300.0,
              color: (resposta != null && resposta != "Não respondido")
                  ? Cores().corenquete
                  : Colors.red[100],
              child: Center(
                  child: Text(
                resposta != null ? resposta : "Resposta",
                style: TextStyle(fontStyle: FontStyle.italic),
              )),
            ),
            Text(
              nomemae != null ? nomemae : "",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              parentesco != null ? parentesco : "",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemRespostaRecado(document, context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(
            left: 10.0, right: 10.0, top: 8.0, bottom: 8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              color: Colors.green[100],
              child: GestureDetector(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        document['resposta'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            fontSize: 15.0,
                            color: Colors.black,
                            wordSpacing: 1.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Text(
                        document['nome'],
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            fontSize: 15.0,
                            color: Colors.black54,
                            wordSpacing: 1.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Text(
                        document['data'],
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            fontSize: 15.0,
                            color: Colors.black54,
                            wordSpacing: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget itemEnqueteEscola(sede, document, usuario, context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RespostaEnquete(document, usuario)));
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Center(
            child: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    (document['reordenado'] != null && document['reordenado'])
                        ? Icon(
                            Icons.warning,
                            color: Colors.red[300],
                          )
                        : Container(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Icon(
                      Icons.question_answer,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              Text(
                document['data'],
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.0),
              ),
              (document['para'] == "Todas")
                  ? Text("Para: " + Nomes().todasturmas,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0,
                      ))
                  : Text("Para: " + document['para'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0,
                      )),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  child: InkWell(
                    onLongPress: () {
                      editar(document, usuario, context);
                    },
                    child: Card(
                      elevation: 10.0,
                      color: Cores().corenquete,
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Center(
                            child: Text(
                          document['pergunta'],
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  Icon(
                    Icons.assignment_ind,
                    color: Colors.grey,
                  ),
                  Text("Verificar Resposta"),
                  Spacer(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  thickness: 0.6,
                  color: Cores().corprincipal,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget itemCuidadoIncluir(document, usuario, context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text(document['nome'],
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0,
                )),
            (document['foto'] == null)
                ? Container(
                    height: 60.0,
                    width: 60.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage("images/picture.png"),
                            fit: BoxFit.cover)),
                  )
                : Container(
                    height: 60.0,
                    width: 60.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: NetworkImage(document['foto']),
                            fit: BoxFit.cover)),
                  ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 35.0, right: 35.0, top: 10.0, bottom: 10.0),
              child: itemdrawer(
                  "Incluir",
                  Icons.edit,
                  CuidadosAdd(document['nome'], document['turma'],
                      document['unidade'], document.documentID, usuario),
                  context),
            )
          ],
        ),
      ),
    );
  }

  Widget itemBilheteadd(data, nome, funcao, context) {
    return Center(
      child: Column(
        children: <Widget>[
          Text(
            "$data",
            style: TextStyle(
                fontSize: 17.0,
                color: Cores().corprincipal,
                fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              "$nome",
              style: TextStyle(color: Cores().corprincipal),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 270,
              child: Card(
                color: Colors.yellow,
                elevation: 8.0,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: CupertinoTextField(
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.transparent)),
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: false,
                    maxLines: 15,
                    placeholder: "Escreva o bilhete",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w700),
                    onChanged: (text) {
                      funcao(text);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget itemDiarioadd(data, para, imagem, funcao, buildGridView, context) {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: Card(
        elevation: 7.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {},
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "$data",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("$para",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.0,
                        fontStyle: FontStyle.italic)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoTextField(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Cores().corprincipal)),
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: false,
                  autocorrect: true,
                  enableSuggestions: true,
                  minLines: 3,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  placeholder: "Escreva a mensagem",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w700),
                  onChanged: (text) {
                    funcao(text);
                  },
                ),
              ),
              (imagem.length > 0)
                  ? Text('Pré-visualização em resolução menor.')
                  : Container(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: (imagem.length > 0)
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: buildGridView)
                    : Container(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget caixadetexto(
      min, max, textinputtype, controller, placeholder, capitalization,
      {bool obs: false, color: null}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        minLines: min,
        maxLines: max,
        keyboardType: textinputtype,
        autocorrect: true,
        enableSuggestions: true,
        controller: controller,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Cores().corprincipal, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          labelText: placeholder,
          labelStyle: TextStyle(
              letterSpacing: 1.0,
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              color: Colors.black87),
        ),
        textCapitalization: capitalization,
        autofocus: false,
        obscureText: obs,
        style: TextStyle(
            color: (color == null) ? Colors.black : color,
            fontWeight: FontWeight.w700),
      ),
    );
  }

  dialog1botaopdf(context, titulo, texto) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text(titulo),
            content: new Text(texto),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "OK",
                  style: TextStyle(color: Cores().corprincipal),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  dialog2botoes(
      context, titulo, texto, textobotao, destino, DocumentSnapshot doc) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text(titulo),
            content: new Text(texto),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Cores().corprincipal),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  textobotao,
                  style: TextStyle(color: Cores().corprincipal),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => destino));
                  doc.reference.update(
                      {'matricula': true, 'matriculadata': Pesquisa().hoje()});
                },
              ),
            ],
          );
        });
  }

  dialog1botaofoto(context, titulo, texto) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text(titulo),
            content: new Text(texto),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "OK",
                  style: TextStyle(color: Cores().corprincipal),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  bannerNovaVersao(versaoUser, versaoLoja) {

    int numeroUser = int.parse(versaoUser.toString().replaceAll('.', ''));
    int numeroLoja = int.parse(versaoLoja.toString().replaceAll('.', ''));

    return (versaoLoja != null && !kIsWeb && (numeroUser < numeroLoja))
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 3.0,
              child: Container(
                  color: Cores().corbilhetes,
                  child: Column(
                    children: [
                      Layout().titulo('Nova atualização para a Agenda'),
                      Layout().texto(
                        'Fizemos melhorias no applicativo.\nPor favor, atualize-o.',
                        14,
                        FontWeight.normal,
                        Colors.black87,
                        align: TextAlign.center,
                        height: 5,
                        overflow: TextOverflow.ellipsis,
                        textDecoration: TextDecoration.none,
                        maxLines: 1
                      ),
                      FlatButton(
                          onPressed: () async {
                            var url;
                            if (Platform.isIOS) {
                              url = 'https://bit.ly/AgendaFranciscanaiPhone';
                            } else {
                              url = 'https://bit.ly/AgendaFranciscanaAndroid';
                            }
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          color: Colors.black12,
                          child: Text(
                            'Atualizar',
                            style: TextStyle(color: Colors.white),
                          ))
                    ],
                  )),
            ),
          )
        : Container();
  }

  dialog1botaofecha2(context, titulo, texto) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text(titulo),
            content: new Text(texto),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "OK",
                  style: TextStyle(color: Cores().corprincipal),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Widget itemUsuario(document, usuario, palavrapesquisada, context) {
    return (palavrapesquisada == null ||
            document['nome']
                .toString()
                .toLowerCase()
                .contains(palavrapesquisada.toString().toLowerCase()))
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 3.0,
              child: InkWell(
                hoverColor: Cores().corprincipal.withOpacity(0.2),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UsuarioAdd(usuario, document)));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      (document['nome'] != null)
                          ? Text(
                              document['nome'],
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.0,
                                  color: Cores().corprincipal),
                            )
                          : Text(" "),
                      (document['email'] != null)
                          ? Text(document['email'])
                          : Text(" "),
                      (document['perfil'] != null)
                          ? Text(
                              "Perfil: " + document['perfil'],
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )
                          : Text(" "),
                      (document['curso'] != null)
                          ? Text("Curso: " + document['curso'].toString())
                          : Text(""),
                      (document['turma'] != null)
                          ? Text("Turma: " + document['turma'].toString())
                          : Text(""),
                      (document['horainicio'] != null &&
                              document['horafim'] != null)
                          ? Text(
                              "Expediente: ${document['horainicio']} - ${document['horafim']}")
                          : Container(),
                      (document['ultimoacesso'] != null)
                          ? Text("Último Acesso: ${document['ultimoacesso']}")
                          : Container(),
                      (document['versao'] != null)
                          ? Text("${document['versao']}")
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Container();
  }

  Widget itempai(usuario, paidoc, aluno, perfil, context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 2.0,
        child: InkWell(
          hoverColor: Cores().corprincipal.withOpacity(0.2),
          onTap: () {
            if (perfil != null && perfil != 'Professor') {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Mensagem(
                          perfil, usuario,
                          aluno.documentID, paidoc.documentID, true,professor: '' as DocumentSnapshot,
                      )));
            }
            if (perfil != null && perfil == 'Professor') {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Mensagem(perfil, usuario,
                          aluno.documentID, paidoc.documentID, true,
                          professor: usuario)));
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  (paidoc['responsavelfinanceiro'])
                      ? Row(
                          children: [
                            Spacer(),
                            Container(
                              color: Colors.amber,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Resp. Financeiro'),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  (paidoc['parentesco'] != null)
                      ? Text(
                          paidoc['parentesco'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      : Container(),
                  (paidoc['nome'] != null)
                      ? Text(
                          paidoc['nome'],
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 16.0),
                        )
                      : Container(),
                  SelectableText(
                    paidoc['email'],
                    style: TextStyle(color: Colors.blue),
                  ),
                  Divider(),
                  (paidoc['ultimoacesso'] != null)
                      ? Text("Último Acesso: ${paidoc['ultimoacesso']}")
                      : Container(),
                  (paidoc['versao'] != null)
                      ? Text("${paidoc['versao']}")
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget itemPublicacaoPortal(DocumentSnapshot document, usuario, context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Card(
        elevation: 1.0,
        child: GestureDetector(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, right: 12.0, left: 12.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              document['data'],
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 12.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                (document['mensagem'] != null)
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Linkify(
                          onOpen: (link) async {
                            if (await canLaunch(link.url)) {
                              document.reference.update({'lida': true});
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  texto(texto, size, fontWeight, color,
      {
      required TextAlign align,
      required int maxLines,
      required TextOverflow overflow,
      required TextDecoration textDecoration,
      required double height}) {
    return Text(
      texto,
      overflow: overflow,
      style: TextStyle(
        height: height,
        fontFamily: "Sans",
        color: color,
        fontSize: size?.toDouble(),
        fontWeight: fontWeight,
        decoration: textDecoration,
      ),
      textAlign: align,
      maxLines: maxLines,
    );
  }

  Widget msgIntra(DocumentSnapshot usuario, DocumentSnapshot destinatario,
      palavrapesquisada, context) {
    return (palavrapesquisada == null ||
            destinatario['nome']
                .toString()
                .toLowerCase()
                .contains(palavrapesquisada.toString().toLowerCase()))
        ? Card(
            elevation: 5.0,
            child: InkWell(
              hoverColor: Cores().corprincipal.withOpacity(0.2),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Mensageminterna(usuario, destinatario)));
              },
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: InkWell(
                      onTap: () {
                        // Pesquisa().irpara(FotoAluno(aluno), context);
                      },
                      child: Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: AssetImage('images/picture.png'),
                                fit: BoxFit.cover),
                          )),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: AutoSizeText(
                            destinatario['nome'],
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(destinatario['perfil']),
                        (destinatario['unidade'] != null)
                            ? Text(destinatario['unidade'])
                            : Container(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        : Container();
  }

  Widget itemAluno(DocumentSnapshot usuario, DocumentSnapshot aluno, destino,
      palavrapesquisada, context) {
    return (palavrapesquisada == null ||
            aluno['nome']
                .toString()
                .toLowerCase()
                .contains(palavrapesquisada.toString().toLowerCase()))
        ? Card(
            elevation: 5.0,
            child: InkWell(
              hoverColor: Cores().corprincipal.withOpacity(0.2),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => destino));
              },
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: InkWell(
                      onTap: () {
                        Pesquisa().irpara(FotoAluno(aluno), context);
                      },
                      child: Hero(
                        tag: aluno.id,
                        child: aluno['foto'] != null
                            ? Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: (!kIsWeb)
                                          ? CachedNetworkImageProvider(
                                              aluno['foto'])
                                          : NetworkImage(aluno['foto'])as ImageProvider,
                                      fit: BoxFit.cover),
                                ))
                            : Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: AssetImage('images/picture.png'),
                                      fit: BoxFit.cover),
                                )),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: AutoSizeText(
                            aluno['nome'],
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        (aluno['turma'] != null)
                            ? Text(aluno['curso'] + " - " + aluno['turma'])
                            : Container(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        : Container();
  }

  fotocircular(size, foto) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: (!kIsWeb)
                  ? CachedNetworkImageProvider(foto)
                  : NetworkImage(foto)as ImageProvider,
              fit: BoxFit.cover),
        ));
  }

  dialog1botao(context, titulo, texto, {destino}) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text(titulo),
            content: new Text(texto),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "OK",
                  style: TextStyle(color: Cores().corprincipal),
                ),
                onPressed: () {
                  if (destino == null) {
                    Navigator.pop(context);
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => destino),
                        (Route<dynamic> route) => false);
                  }
                },
              ),
            ],
          );
        });
  }

  dialog1pushreplacement(context, titulo, texto) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text(titulo),
            content: new Text(texto),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "OK",
                  style: TextStyle(color: Cores().corprincipal),
                ),
                onPressed: () {
                  Navigator.pop(context);

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MyApp()));
                },
              ),
            ],
          );
        });
  }
}
