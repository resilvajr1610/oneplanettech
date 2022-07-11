import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../layout.dart';

class ItemRespostaEnquete extends StatefulWidget {
  var aluno, enquete;

  ItemRespostaEnquete(this.aluno, this.enquete);

  @override
  _ItemRespostaEnqueteState createState() => _ItemRespostaEnqueteState();
}

class _ItemRespostaEnqueteState extends State<ItemRespostaEnquete> {
  @override
  Widget build(BuildContext context) {
    return itemEnquete(widget.aluno);
  }

  Widget itemEnquete(aluno) {
    return Card(
      child: Column(
        children: [
          (aluno['foto'] != null)
              ? Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(aluno['foto']),
                        fit: BoxFit.cover),
                  ))
              : Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage("images/picture.png"),
                          fit: BoxFit.contain),
                      color: Colors.black26)),
          AutoSizeText(
            (aluno['nome'] != null) ? aluno['nome'] : '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text((aluno['turma'] != null) ? aluno['turma'] : ''),
          SizedBox(height: 5.0,),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Respostas')
                  .where('enquete',
                  isEqualTo: widget.enquete.id)
                  .where('aluno', isEqualTo: widget.aluno.id)
                  .orderBy("datacomparar")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Text(
                      'Isto é um erro. Por gentileza, contate o suporte.');
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Container();
                  default:
                    return (snapshot.data!.docs.length >= 1)
                        ? Column(
                      children: snapshot.data!.docs
                          .map((DocumentSnapshot document) {
                        return Container(
                            width: MediaQuery.of(context)
                                .size
                                .width,
                            child: Layout().itemRespostaRecado(
                                document,
                                context));
                      }).toList(),
                    )
                        : Text('Não respondido', style: TextStyle(color: Colors.red, fontSize: 20.0, fontWeight: FontWeight.bold));
                }
              },
            ),
          )


        ],
      ),
    );
  }
}
