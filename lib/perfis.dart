import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scalifra/perfiladd.dart';

import 'design.dart';
import 'itens/itemcheckbox.dart';
import 'itens/itemcheckboxsaveFB.dart';
import 'layout.dart';
import 'pesquisa.dart';


class Perfis extends StatefulWidget {
  DocumentSnapshot usuario;
  Perfis(this.usuario);
  @override
  _PerfisState createState() => _PerfisState();
}

class _PerfisState extends State<Perfis> {

  late bool chat;
  List<String> unidades = [];
  String unidade='';

  @override
  void initState() {
    super.initState();

    if(widget.usuario['unidade'] == 'Todas as unidades'){
      buscarunidades();
    } else {
     setState(() {
       unidade = widget.usuario['unidade'];
     });
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().perfis);
  }

  buscarunidades() {
    unidades.add('Todas as unidades');
    FirebaseFirestore.instance.collection(Nomes().unidadebanco).get().then((docs) {
      docs.docs.forEach((doc) {
        setState(() {
          unidades.add(doc['unidade']);
        });
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbarcombotaosimples(incluir, 'Perfil', 'Incluir', context),
      body: Row(
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: Column(
              children: <Widget>[
                (widget.usuario['unidade'] == 'Todas as unidades') ? Layout().dropdownitem(
                    'Selecione a unidade', unidade, mudarUnidade, unidades) : Container(),
                Expanded(
                  child: (unidade != null) ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(Nomes().perfilbanco)
                      .where('unidade', isEqualTo: unidade)
                          .orderBy("perfil")
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError){
                          print(snapshot.error);
                          return Text('Isto é um erro. Por gentileza, contate o suporte');
                        }

                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Container();
                          default:
                            return (snapshot.data!.docs.length >= 1)
                                ? ListView(
                              children: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                return itemperfil(document, document['chat'],  'Permitir chat com responsáveis e alunos');
                              }).toList(),
                            )
                                : Container();
                        }
                      }): Container(),
                )
              ],
            ),
          ),
          Layout().espacolateral(context),
        ],
      ),
    );
  }

  Widget itemperfil (DocumentSnapshot doc, boolean,  texto) {
    List<String> cursos = ['EI', 'EF1', 'EF2', 'EM', 'CN'];
    List<String> cursosselecionadosperfis = [];
    return Card(
      child: InkWell(
        onLongPress: (){
          Layout().deletar(doc, context);
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
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
                        doc.reference.update({
                          'chat': value
                        });
                      }),
                  Flexible(child: Text(texto)),
                ],
              ),
               Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Column(
                  children: cursos.map((String curso) {
                    return ItemCheckBoxSaveFB(curso,
                        doc);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  incluir(context){
    if(unidade == null){
      Layout().dialog1botao(context, 'Selecione a unidade', '');
    } else {
      Pesquisa().irpara(PerfilAdd(unidade), context);
    }
  }


  void mudarUnidade(String text) {
    setState(() {
      unidade = text;

    });

  }



}


