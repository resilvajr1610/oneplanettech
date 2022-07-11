import 'package:flutter/material.dart';

import '../design.dart';


class ItemCheckBox extends StatefulWidget {
  String texto;
  List<String> list;
  ItemCheckBox(this.texto, this.list);
  @override
  _ItemCheckBoxState createState() => _ItemCheckBoxState();
}

class _ItemCheckBoxState extends State<ItemCheckBox> {
  late bool boolean;

  @override
  void initState() {
    super.initState();
    if(widget.list.isNotEmpty && widget.list.contains(widget.texto)){
      boolean = true;
    }else {
      boolean = false;
    }
  }



  @override
  Widget build(BuildContext context) {
    return checkBox(widget.texto, widget.list);
  }
  Widget checkBox(texto, list) {
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
                list.add(texto);
                print(list);
              } else{
                list.remove(texto);
              }
            }),
        Text(texto),
      ],
    );
  }
}
