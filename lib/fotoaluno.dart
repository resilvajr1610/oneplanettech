import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
//import 'package:universal_html/html.dart' as html;

import 'design.dart';
import 'pesquisa.dart';


class FotoAluno extends StatefulWidget {
  DocumentSnapshot alunodoc;
  FotoAluno(this.alunodoc);

  @override
  _FotoAlunoState createState() => _FotoAlunoState();
}

class _FotoAlunoState extends State<FotoAluno> {
  String foto='';

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('Alunos').doc(widget.alunodoc.id).snapshots().listen((event) {
      if(event.exists){
        if(event['foto']!= null){
          setState(() {
            foto = event['foto'];
          });
        } else {
          setState(() {
            foto = '';
          });
        }
      }
    });
    Pesquisa().sendAnalyticsEvent(tela: Nomes().fotoAluno);
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:appbar(funcao, widget.alunodoc['nome'], 'Trocar Foto', context),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child:    Hero(
          tag: widget.alunodoc.id,
          child: (foto != null)? PhotoView(
            initialScale: PhotoViewComputedScale.contained,
            backgroundDecoration:
            BoxDecoration(color: Colors.transparent),
            imageProvider: NetworkImage(foto),
          ) : Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image:  AssetImage('images/picture.png'),
                    fit: BoxFit.contain),
              )
          ),
        ) ,
      ),
    );
  }

  appbar(funcao, nomebarra, nomebotao, context) {
    return AppBar(
      elevation: 0.0,
      backgroundColor: Cores().corprincipal,
      actions: <Widget>[
        FlatButton(
          textColor: Colors.white,
          onPressed: () {
            funcao(context);
          },
          child: Text(
            nomebotao,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
          ),
        ),
        FlatButton(
          onPressed: () {
            if(widget.alunodoc['foto']!= null){
              widget.alunodoc.reference.update({
                'foto': FieldValue.delete()
              });
              Pesquisa().deletarstorage(widget.alunodoc['foto']);
            }
          },
          child: Icon(
           Icons.delete,
            color: Colors.white,
          ),
        ),
      ],
      title: Text(nomebarra),
    );
  }

  funcao(context){
    if (kIsWeb) {
      //pegarImageweb();
    } else {
      pegarfoto();
    }
  }

  Future pegarfoto() async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxWidth: 600,
        maxHeight: 600);
    if (image != null) {
      Pesquisa().salvarAlunoDetalhe(widget.alunodoc, File(image.path), null, context);
    }
  }

  // pegarImageweb() async {
  //   html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  //   uploadInput.multiple = false;
  //   uploadInput.draggable = true;
  //   uploadInput.accept = 'image/*';
  //   uploadInput.click();
  //   html.document.body?.append(uploadInput);
  //   uploadInput.onChange.listen((e) async {
  //     final files = uploadInput.files;
  //     html.File file = files![0];
  //     Pesquisa().salvarAlunoDetalhe(widget.alunodoc, null, file, context);
  //   });
  //   uploadInput.remove();
  // }
}


