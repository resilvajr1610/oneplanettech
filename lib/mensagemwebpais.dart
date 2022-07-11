import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scalifra/publicar.dart';

import 'design.dart';
import 'layout.dart';
import 'mensagem.dart';
import 'pesquisa.dart';


class MensagemWebPais extends StatefulWidget {
  DocumentSnapshot usuario, alunodoc;
  bool controle;

  MensagemWebPais(this.usuario, this.alunodoc, this.controle);

  @override
  _MensagemWebPaisState createState() => _MensagemWebPaisState();
}

class _MensagemWebPaisState extends State<MensagemWebPais> {
  String para='', alunoid='', paiuser='';
  late bool controle;
  late DocumentSnapshot professor;

  @override
  void initState() {
    super.initState();
    alunoid = widget.alunodoc.id;
    Pesquisa().sendAnalyticsEvent(tela: Nomes().mensagemWebPais);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundomaisclaro,
      appBar: Layout()
          .appbarcombotaosimples(floatingaction, 'Mensagens', 'Nova', context),
      body: Row(
        children: [
          Flexible(flex: 2, child: InkWell(child: listamensagem())),
          Expanded(
              flex: 3,
              child: (para != null)
                  ? Mensagem(
                      para,
                      widget.usuario,
                      alunoid,
                      paiuser,
                      widget.controle,
                      professor: professor,
                    )
                  : Container()),
        ],
      ),
    );
  }

  void floatingaction(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Publicar(widget.usuario, widget.alunodoc)));
  }

  Widget listamensagem() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(Nomes().mensagensbanco)
            .orderBy("datacomparar", descending: true)
            .where("origem", isEqualTo: widget.usuario.id)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Text('Isto é um erro. Por gentileza, contate o suporte.');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Container();
            default:
              return (snapshot.data!.docs.length >= 1)
                  ? ListView(
                      children: snapshot.data!.docs
                          .map((DocumentSnapshot document) {
                        return itemMensagemTela(
                            document, widget.usuario, false, 'pais', context);
                      }).toList(),
                    )
                  : Center(
                      child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Não há mensagens ainda.\nPara enviar nova mensagem, clique em Nova na barra.',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ));
          }
        });
  }

  Widget itemMensagemTela(
      DocumentSnapshot document, user, controle, tipo, context) {
    return Card(
      elevation: 1.0,
      child: InkWell(
        onTap: () {
          if (document['para'] == 'Professor') {
            FirebaseFirestore.instance
                .collection(Nomes().usersbanco)
                .doc(document['professorid'])
                .get()
                .then((value) {
              setState(() {
                para = document['para'];
                alunoid = document['aluno'];
                paiuser = document['origem'];
                professor = value;
              });
            });
          } else {
            setState(() {
              professor = '' as DocumentSnapshot<Object?>;
              para = document['para'];
              alunoid = document['aluno'];
              paiuser = document['origem'];
            });
          }
        },
        onLongPress: () {
          return Layout().marcarcomolida(document, context);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    document['para'],
                    style: TextStyle(
                        color: Cores().corprincipal,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                        fontSize: 17.0),
                  ),
                  Spacer(),
                  Text(
                    document['data'],
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
                                        image: NetworkImage(document['logo']),
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
                          Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                document['mensagem'],
                                style: TextStyle(color: Colors.grey),
                              )),
                          ((tipo == 'escola' && document['nova'] == 'escola') ||
                                  (tipo == 'pais' &&
                                      document['nova'] == 'pais'))
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.add_alert,
                                      color: Colors.red,
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
}
