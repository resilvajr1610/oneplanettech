
import 'package:flutter/material.dart';

import '../design.dart';


class ItemCheckBoxDocs extends StatefulWidget {
  String doc1edoc2;
  List list;
  ItemCheckBoxDocs(this.list, this.doc1edoc2);
  @override
  _ItemCheckBoxDocsState createState() => _ItemCheckBoxDocsState();
}

class _ItemCheckBoxDocsState extends State<ItemCheckBoxDocs> {
  late bool boolean;

  @override
  void initState() {
    super.initState();
    if(widget.list.isNotEmpty && widget.list.contains(widget.doc1edoc2)){
      boolean = true;
    }else {
      boolean = false;
    }
  }



  @override
  Widget build(BuildContext context) {
    return checkBox(widget.doc1edoc2, widget.list);
  }

  Widget checkBox(String doc1edoc2, list) {
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
                list.add(doc1edoc2);
                print(list);
              } else{
                list.remove(doc1edoc2);
              }
            }),
      ],
    );
  }
}
