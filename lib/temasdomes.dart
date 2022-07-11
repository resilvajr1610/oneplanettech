
import 'package:firebase/firebase.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'design.dart';
import 'layout.dart';
import 'pesquisa.dart';

class TemasdoMes extends StatefulWidget {

  @override
  _TemasdoMesState createState() => _TemasdoMesState();
}

class _TemasdoMesState extends State<TemasdoMes> {

  String mestratado = Pesquisa().getMesTelaInicial();
  String capa='', mes = Pesquisa().getMes();

  @override
  void initState() {
    buscarcapadomes(mestratado);
    Pesquisa().sendAnalyticsEvent(tela: Nomes().temasdomes);
    super.initState();
  }
  
  buscarcapadomes(mesString){
    Reference   reference = FirebaseStorage.instance.ref().child(
        Nomes().telaInicioMes + mesString + '.png');
    reference.getDownloadURL().then((value) async {
      print(value.toString());
      setState(() {
        capa = value.toString();
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Cores().corfundo,
        appBar: AppBar(
          title: Text('Temas do Mês'),
          centerTitle: true,
          backgroundColor: Cores().corprincipal,
        ),
        body: Row(
          children: [
            (MediaQuery.of(context).size.width > 850)
                ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
            )
                : Container(),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              setState(() {
                                mes = Pesquisa().alterarmes(-1, mes);
                                mestratado = mes.replaceAll(' de ', '');
                                buscarcapadomes(mestratado);
                              });
                            },
                          ),
                          Text(
                            mes,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          (mes != Pesquisa().getMes()) ?  IconButton(
                            icon: Icon(Icons.arrow_forward_ios),
                            onPressed: () {
                              setState(() {
                                mes = Pesquisa().alterarmes(1, mes);
                                mestratado = mes.replaceAll(' de ', '');
                                buscarcapadomes(mestratado);
                              });
                            },
                          ): Container(),
                        ],
                      ),
                    ),
                    (capa != null)  ? Expanded(
                      child: Container(
                          color: Colors.black87,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child:
                         Layout().imagemshimmer(
                            capa
                          )),
                    ): Container(),

                  ],
                ),
              ),
            ),
            (MediaQuery.of(context).size.width > 850)
                ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
            )
                : Container(),
          ],
        ));
  }
}
