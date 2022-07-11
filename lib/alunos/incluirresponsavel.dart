import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../design.dart';
import '../layout.dart';

class IncluirResponsavel extends StatefulWidget {
  DocumentSnapshot aluno;

  IncluirResponsavel(this.aluno);

  @override
  _IncluirResponsavelState createState() => _IncluirResponsavelState();
}

class _IncluirResponsavelState extends State<IncluirResponsavel> {
  String perfil='';
  late DocumentSnapshot aluno;
  bool respfinanceiro = false;
  TextEditingController cnome = TextEditingController();
  TextEditingController cparentesco = TextEditingController();
  TextEditingController cemail = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbar(aluno['nome']),
      body: Row(
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Layout().titulo("Adicionar Responsável Funcionário"),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Layout().caixadetexto(
                                  1,
                                  2,
                                  TextInputType.text,
                                  cnome,
                                  "Nome do responsável",
                                  TextCapitalization.words,
                                ),
                                Layout().caixadetexto(
                                  1,
                                  1,
                                  TextInputType.text,
                                  cparentesco,
                                  "Parentesco",
                                  TextCapitalization.words,
                                ),
                                Layout().caixadetexto(
                                  1,
                                  1,
                                  TextInputType.emailAddress,
                                  cemail,
                                  "Escreva o e-mail",
                                  TextCapitalization.none,
                                ),
                                Layout().checkBox(respfinanceiro, (bool) {
                                  setState(() {
                                    respfinanceiro = bool;
                                  });
                                }, 'Responsável Financeiro')
                              ],
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Cancelar"),
                                  ),
                                  onTap: () {
                                    cnome.text = "";
                                    cemail.text = "";
                                    cparentesco.text = "";
                                    respfinanceiro = false;
                                    Navigator.pop(context);
                                  }),
                              Spacer(),
                              GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Adicionar",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  onTap: () {
                                    if (cnome.text.isEmpty ||
                                        cparentesco.text.isEmpty ||
                                        cemail.text.isEmpty) {
                                      Layout().dialog1botao(context, "Erro",
                                          "Preencha todos os dados");
                                    } else {
                                      FirebaseFirestore.instance
                                          .collection('Users')
                                          .where('email',
                                              isEqualTo: cemail.text.trim())
                                          .get()
                                          .then((value) {
                                        if (value.docs.isEmpty) {
                                          Layout().dialog1botao(
                                              context,
                                              'Confira o e-mail',
                                              'Não encontramos este e-mail cadastrado como funcionário.');
                                        } else {
                                          value.docs.first.reference
                                              .update({
                                            'parentesco': cparentesco.text,
                                            'responsavelfinanceiro':
                                                respfinanceiro,
                                            'alunos': FieldValue.arrayUnion(
                                                [widget.aluno.id])
                                          }).then((value) {
                                            Layout().dialog1botaofecha2(
                                                context,
                                                'Adicionado',
                                                'O usuário foi adicionado. Solicite para que feche e abra o app novamente.');
                                          });
                                        }
                                      });
                                    }
                                  })
                            ],
                          ),
                          Divider(
                            thickness: 0.6,
                            color: Cores().corprincipal,
                          ),
                        ],
                      ),
                      // Expanded(
                      //     child: StreamBuilder<QuerySnapshot>(
                      //         stream: Firestore.instance
                      //             .collection(Nomes().usersbanco)
                      //             .orderBy('email')
                      //             .snapshots(),
                      //         builder: (BuildContext context,
                      //             AsyncSnapshot<QuerySnapshot> snapshot) {
                      //           if (snapshot.hasError)
                      //             return Text('Error: ${snapshot.error}');
                      //           switch (snapshot.connectionState) {
                      //             case ConnectionState.waiting:
                      //               return Container();
                      //             default:
                      //               return (snapshot.data.documents.length >= 1)
                      //                   ? ListView(
                      //                       children:
                      //                           snapshot.data.documents.map((doc) {
                      //                         if (doc['email'] != 'teste@oneplanet.tech') {
                      //                           if (doc['aluno1'] == aluno.documentID ||
                      //                               doc['aluno2'] == aluno.documentID ||
                      //                               doc['aluno3'] == aluno.documentID) {
                      //                             return Layout()
                      //                                 .itempai(doc, perfil, context);
                      //                           }
                      //                           return Container();
                      //                         }
                      //                         return Container();
                      //                       }).toList(),
                      //                     )
                      //                   : Container();
                      //           }
                      //         }))
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
}
