import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'design.dart';
import 'layout.dart';
import 'pesquisa.dart';

class PerfilAdd extends StatefulWidget {
  String unidade;
  PerfilAdd(this.unidade);
  @override
  _PerfilAddState createState() => _PerfilAddState();
}

class _PerfilAddState extends State<PerfilAdd> {
  TextEditingController perfil = TextEditingController();

  @override
  void initState() {
    super.initState();
    Pesquisa().sendAnalyticsEvent(tela: Nomes().perfilAdd);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbarcombotaosimples(salvar, 'Incluir Perfil', 'Salvar', context),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                child: Column(children: [
                  Layout().titulo(widget.unidade),
                  Layout().caixadetexto(1, 1, TextInputType.text, perfil, 'Perfil', TextCapitalization.words),
                ],),
              ),
            ),
          ),
          Layout().espacolateral(context),
        ],
      ),
    );
  }

  salvar(context){
    if(perfil.text.isEmpty){
      Layout().dialog1botao(context, 'Perfil', 'Escreva o perfil');
    } else {
      Map<String, dynamic> map = Map();
      map['unidade'] = widget.unidade;
      map['perfil'] = perfil.text;

      Pesquisa().salvarfirebase(Nomes().perfilbanco, map, null, null);
      Layout().dialog1botaofecha2(context, 'Salvo', '');
    }
  }
}
