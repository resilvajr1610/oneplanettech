import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../design.dart';


class ItemCheckBoxSaveFB extends StatefulWidget {
  String texto;
  DocumentSnapshot doc;
  ItemCheckBoxSaveFB(this.texto, this.doc);
  @override
  _ItemCheckBoxSaveFBState createState() => _ItemCheckBoxSaveFBState();
}

class _ItemCheckBoxSaveFBState extends State<ItemCheckBoxSaveFB> {
  late bool boolean;

  @override
  void initState() {
    super.initState();
    if(widget.doc['cursos']!= null && widget.doc['cursos'].contains(widget.texto)){
      boolean = true;
    }else {
      boolean = false;
    }
  }



  @override
  Widget build(BuildContext context) {
    return checkBox(widget.texto, widget.doc);
  }
  Widget checkBox(texto, doc) {
    return Row(
      children: <Widget>[
        Checkbox(
            checkColor: Cores().corprincipal,
            value: (boolean != null) ? boolean : false,
            onChanged: (value) {
              setState(() {
                boolean = value as bool;
              });
              if(boolean){
                doc.reference.updateData({
                  'cursos': FieldValue.arrayUnion(
                      [texto])
                });


              } else{
                doc.reference.updateData({
                  'cursos': FieldValue.arrayRemove(
                      [texto])
                });
              }
            }),
        Text(texto),
      ],
    );
  }
}
