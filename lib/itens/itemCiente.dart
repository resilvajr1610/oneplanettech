import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../design.dart';

class ItemCiente extends StatefulWidget {
  String ciente, palavrapesquisada;

  ItemCiente(this.ciente, this.palavrapesquisada);

  @override
  _ItemCienteState createState() => _ItemCienteState();
}

class _ItemCienteState extends State<ItemCiente> {
  late DocumentSnapshot usuario;
  List<DocumentSnapshot> listalunos = [];
  List<String> nomesalunos = [];

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection(Nomes().usersbanco)
        .doc(widget.ciente)
        .get()
        .then((user) {
      if (user.exists && mounted) {
        setState(() {
          usuario = user;
        });
        if (user != null && user['alunos'] != null) {
          List<String>.from(usuario['alunos']).forEach((element) {
            FirebaseFirestore.instance
                .collection(Nomes().alunosbanco)
                .doc(element)
                .get()
                .then((value) {
              if (mounted) {
                setState(() {
                  listalunos.add(value);
                  nomesalunos.add(value['nome']);
                });
              }
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return (usuario != null)
        ? itemciente(usuario, listalunos, nomesalunos,  widget.palavrapesquisada, context)
        : Container();
  }

  Widget itemciente(usuario, List<DocumentSnapshot> alunos, List<String> nomesal, String palavrapesquisada, context) {
    return (palavrapesquisada == null || usuario['nome'].toString().toLowerCase().contains(palavrapesquisada.toString().toLowerCase()) ) ? Container(
      width: MediaQuery.of(context).size.width,
      child: Card(
        elevation: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AutoSizeText(
                usuario['nome'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              (usuario['parentesco'] != null)
                  ? Text(usuario['parentesco'])
                  : Container(),
              (usuario['perfil'] != null)
                  ? Text(usuario['perfil'])
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: alunos.map((aluno) {
                  return itemaluno(aluno);
                }).toList(),
              )
            ],
          ),
        ),
      ),
    ): Container();
  }

  Widget itemaluno(aluno) {
    return Flexible(
        child: Column(
      children: [
        (aluno['foto'] != null)
            ? Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(aluno['foto']), fit: BoxFit.cover),
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
      ],
    ));
  }
}
