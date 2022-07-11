import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'itens/itemCiente.dart';
// import 'package:universal_html/html.dart' as html;

import 'design.dart';
import 'layout.dart';
import 'pesquisa.dart';

class VisualizarCiente extends StatefulWidget {
  final DocumentSnapshot document;
  final String tipo;

  VisualizarCiente(this.document, this.tipo);

  @override
  _VisualizarCienteState createState() => _VisualizarCienteState();
}

class _VisualizarCienteState extends State<VisualizarCiente> {
  List<dynamic> cientes = [];
  String palavrapesquisada='';

  @override
  void initState() {
    super.initState();
    if (widget.document != null && widget.document[widget.tipo] != null) {
      setState(() {
        cientes = widget.document[widget.tipo];
      });
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().visualizarCliente);
  }

  gerarcsv(context) async {
    Layout().dialog1botao(context, "Gerando CSV",
        'Conforme o tamanho da lista, pode haver demora. Aguarde!');
    List<List<String>> csvData = [];

    // await cientes.forEach((element) async {
    //   await FirebaseFirestore.instance
    //       .collection(Nomes().usersbanco)
    //       .doc(element)
    //       .get()
    //       .then((user) {
    //     if (user.exists && user != null) {
    //       if (user['alunos'] != null) {
    //         List<String>.from(user['alunos']).forEach((element2) async {
    //           await FirebaseFirestore.instance
    //               .collection(Nomes().alunosbanco)
    //               .doc(element2)
    //               .get()
    //               .then((value) async {
    //             await csvData.add(<String>[
    //               user['nome'],
    //               user['parentesco'] ?? user['perfil'],
    //               value['nome'],
    //               value['turma'],
    //               value['curso'],
    //               value['unidade']
    //             ]);
    //
    //             if (element == cientes.last) {
    //               jogarcsv(csvData);
    //             }
    //           });
    //         });
    //       } else {
    //         csvData.add(
    //             <String>[user['nome'], user['parentesco'] ?? user['perfil']]);
    //       }
    //     }
    //   });
    // });
  }

  // jogarcsv(List<List<String>> csvData) {
  //   String csv = ListToCsvConverter().convert(csvData, fieldDelimiter: ';');
  //   if (kIsWeb) {
  //     // prepare
  //     final blob = html.Blob([Uint8List.fromList(csv.codeUnits)]);
  //     final url = html.Url.createObjectUrlFromBlob(blob);
  //     final anchor = html.document.createElement('a') as html.AnchorElement
  //       ..href = url
  //       ..style.display = 'none'
  //       ..download = '${DateTime.now().toIso8601String()}.csv';
  //     html.document.body!.children.add(anchor);
  //     // download
  //     anchor.click();
  //     // cleanup
  //     html.document.body!.children.remove(anchor);
  //     html.Url.revokeObjectUrl(url);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbarcombotaosimples(
          gerarcsv, widget.tipo.toUpperCase(), kIsWeb  ? 'CSV' : '', context, deletar: false, userid: ''),
      body: Row(
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: Column(
              children: [
                Layout().campopesquisa((text) {
                  setState(() {
                    palavrapesquisada = text;
                  });
                }),
                Expanded(
                  child: ListView.builder(
                    itemCount: cientes.length,
                    itemBuilder: (context, index) {
                      var item = cientes[index];
                      return (cientes.isNotEmpty) ? ItemCiente(item, palavrapesquisada) : Container();
                    },
                  ),
                ),
              ],
            ),
          ),
          Layout().espacolateral(context),
        ],
      ),
    );
  }
}
