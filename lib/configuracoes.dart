import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scalifra/design.dart';

import 'funcionalidades.dart';
import 'perfis.dart';
import 'usuarios.dart';
import 'layout.dart';

class Configuracoes extends StatelessWidget {
  DocumentSnapshot usuario;
  Configuracoes(this.usuario);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbar("Configurações"),
      body:  Row(
        children: [
          (MediaQuery.of(context).size.width > 850) ? SizedBox(width: MediaQuery.of(context).size.width*0.2,): Container(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                 Layout().itemdrawer("Funcionalidades", Icons.storage, Funcionalidades(usuario), context),
                  Layout().itemdrawer("Perfis", Icons.check, Perfis(usuario), context),
                  Layout().itemdrawer("Usuários", Icons.supervised_user_circle, Usuarios(usuario), context),
                ],
              ),
            ),
          ),
          (MediaQuery.of(context).size.width > 850) ? SizedBox(width: MediaQuery.of(context).size.width*0.2,): Container(),
        ],
      ),
    );
  }
}


