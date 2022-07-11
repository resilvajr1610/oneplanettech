import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scalifra/layout.dart';
import 'package:url_launcher/url_launcher.dart';

import 'design.dart';
import 'fotodetalhe.dart';
import 'pesquisa.dart';

class GaleriaDeFotos extends StatefulWidget {
  DocumentSnapshot document;

  GaleriaDeFotos(this.document);

  @override
  _GaleriaDeFotosState createState() => _GaleriaDeFotosState();
}

class _GaleriaDeFotosState extends State<GaleriaDeFotos> {
  @override
  void initState() {
    super.initState();
    Pesquisa().sendAnalyticsEvent(tela: Nomes().galeriaDeFotos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Layout().appbar('Galeria de Fotos'),
      body: GridView.count(
        crossAxisCount: 2,
        scrollDirection: Axis.vertical,
        children: List.generate(
          widget.document['fotos'].length,
          (int index) {
            return GestureDetector(
              onTap: () {
                Pesquisa().sendAnalyticsEvent(tela: Nomes().detalheGaleria);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FotoDetalhe(widget.document['fotos'][index])));
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Hero(
                  tag: widget.document['fotos'][index],
                  child: widget.document['fotos'][index].toString().isNotEmpty
                      ? GestureDetector(
                          onTap: () async {
                            if (widget.document['linkescondidoimagem'] !=
                                    null &&
                                widget.document['linkescondidoimagem']
                                    .isNotEmpty) {
                              var url = widget.document['linkescondidoimagem'];
                              if (await canLaunch(url) != null) {
                                await launch(url);
                              } else {
                                throw 'Não conseguimos abrir $url';
                              }
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FotoDetalhe(
                                          widget.document['fotos'][index])));
                            }
                            Pesquisa().sendAnalyticsEvent(
                                tela: Nomes().detalheGaleria);
                          },
                          child: (!kIsWeb)
                              ? Layout().imagemshimmer(widget.document['fotos']
                              .toString()
                              .contains('.jpg-reescrito')
                              ? widget.document['fotos'][index]
                                .toString()
                                .replaceAll('.jpg-reescrito','.jpg-reescrito_500x500')
                                : widget.document['fotos'][index].toString()
                              .replaceAll('.jpg','_500x500.jpg'))
                              : Image.network(widget.document['fotos'][index]
                                      .toString()
                                      .contains('.jpg-reescrito')
                                  ? widget.document['fotos'][index]
                                   .toString()
                                   .replaceAll('.jpg-reescrito','.jpg-reescrito_500x500')
                                  : widget.document['fotos'][index].toString()
                                   .replaceAll('.jpg','_500x500.jpg')),
                        )
                      : Container(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
