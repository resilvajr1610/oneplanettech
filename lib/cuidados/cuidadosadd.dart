import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../pesquisa.dart';
import '../design.dart';
import '../layout.dart';

class CuidadosAdd extends StatefulWidget {
 final String nome, turma, alunoid, unidade;
 final DocumentSnapshot usuario;
  CuidadosAdd(this.nome, this.turma, this.unidade, this.alunoid,  this.usuario);

  @override
  _CuidadosAddState createState() => _CuidadosAddState();
}

class _CuidadosAddState extends State<CuidadosAdd> {
  String
  foto='',manha='',almoco='',lanche='',fruta='',jantar='',mamadeira='',cc='';

  List<String> turmas = [];
  TextEditingController cmamadeira = TextEditingController();
  TextEditingController csono = TextEditingController();
  TextEditingController cxixi = TextEditingController();
  TextEditingController ccc = TextEditingController();
  TextEditingController cobs = TextEditingController();
  int opcao = 0;



  Map<int, Widget> opcoes = const <int, Widget>{
    0: Text("Nenhum"),
    1: Text("Bem"),
    2: Text("Pouco"),
    3: Text("Recusou"),
  };
  Map<int, Widget> opcoesfruta = const <int, Widget>{
    0: Text("Nenhum"),
    1: Text("Aceitou"),
    2: Text("Recusou"),
  };
  Map<int, Widget> opcoesMamadeira = const <int, Widget>{
    0: Text("Nenhum"),
    1: Text("120ml"),
    2: Text("150ml"),
    3: Text("180ml"),
    4: Text("210ml"),
  };
  Map<int, Widget> opcoesCoco = const <int, Widget>{
    0: Text("Nenhum"),
    1: Text("Normal"),
    2: Text("Amolecido"),
  };

  int opcaoAlmoco = 0;
  int opcaoLanche = 0;
  int opcaoFruta = 0;
  int opcaoJantar = 0;
  int opcaoMamadeira = 0;
  int opcaoCoco = 0;

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection(Nomes().publicacoesbanco)
        .where("para", isEqualTo: widget.alunoid)
        .where("tipo", isEqualTo: "cuidado")
        .where("data", isEqualTo: Pesquisa().hoje())
        .limit(1)
      .get()
        .then((documents) {
      documents.docs.forEach((doc) {
        cmamadeira.text = doc['mamadeirahorario'];
        csono.text = doc['sono'];
        cxixi.text = doc['xixi'];
        ccc.text = doc['cchorario'];
        cobs.text = doc['obs'];
        manha = doc['manha'];
        if (doc['manha'] == "Bem") {
          opcao = 1;
        } else if (doc['manha'] == "Pouco") {
          opcao = 2;
        } else if (doc['manha'] == "Recusou") {
          opcao = 3;
        } else if (doc['manha'] == null) {
          opcao = 0;
        }
        almoco = doc['almoco'];
        if (doc['almoco'] == "Bem") {
          opcaoAlmoco = 1;
        } else if (doc['almoco'] == "Pouco") {
          opcaoAlmoco = 2;
        } else if (doc['almoco'] == "Recusou") {
          opcaoAlmoco = 3;
        } else if (doc['almoco'] == null) {
          opcaoAlmoco = 0;
        }
        lanche = doc['lanche'];
        if (doc['lanche'] == "Bem") {
          opcaoLanche = 1;
        } else if (doc['lanche'] == "Pouco") {
          opcaoLanche = 2;
        } else if (doc['lanche'] == "Recusou") {
          opcaoLanche = 3;
        } else if (doc['lanche'] == null) {
          opcaoLanche = 0;
        }
        jantar = doc['jantar'];
        if (doc['jantar'] == "Bem") {
          opcaoJantar = 1;
        } else if (doc['jantar'] == "Pouco") {
          opcaoJantar = 2;
        } else if (doc['jantar'] == "Recusou") {
          opcaoJantar = 3;
        } else if (doc['jantar'] == null) {
          opcaoJantar = 0;
        }
        fruta = doc['fruta'];
        if (doc['fruta'] == "Aceitou") {
          opcaoFruta = 1;
        } else if (doc['fruta'] == "Recusou") {
          opcaoFruta = 2;
        } else if (doc['fruta'] == null) {
          opcaoFruta = 0;
        }
        mamadeira = doc['qtdademamadeira'];
        if (doc['qtdademamadeira'] == "120 ml") {
          opcaoMamadeira = 1;
        } else if (doc['qtdademamadeira'] == "150ml") {
          opcaoMamadeira = 2;
        } else if (doc['qtdademamadeira'] == "180 ml") {
          opcaoMamadeira = 3;
        } else if (doc['qtdademamadeira'] == "210 ml") {
          opcaoMamadeira = 4;
        } else if (doc['qtdademamadeira'] == null) {
          opcaoMamadeira = 0;
        }
        cc = doc['cc'];
        if (doc['cc'] == "Normal") {
          opcaoCoco = 1;
        } else if (doc['cc'] == "Amolecido") {
          opcaoCoco = 2;
        } else if (doc['cc'] == null) {
          opcaoCoco = 0;
        }
        setState(() {});
      });
    });
    FirebaseFirestore.instance
        .collection(Nomes().alunosbanco)
        .doc(widget.alunoid)
        .get()
        .then((doc) {
      setState(() {
        foto = doc['foto'];
      });
    });
    super.initState();
  }


  @override
  void dispose() {
    cmamadeira.dispose();
    csono.dispose();
    cxixi.dispose();
    ccc.dispose();
    cobs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Layout().appbarcombotaosimples(parasalvar, "Cuidados", "Salvar", context),
      body: Row(
        children: [
          (MediaQuery.of(context).size.width > 850) ? SizedBox(width: MediaQuery.of(context).size.width*0.2,): Container(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  (foto==null)? Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage("images/picture.png"),
                            fit: BoxFit.cover)),
                  ):
                  Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: NetworkImage(foto),
                            fit: BoxFit.cover)),
                  )
                  ,
                  Text(widget.nome,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Alimentação",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Cores().corprincipal),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Manhã",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Layout().segmented(opcoes, opcao, mudarmanha, context),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Almoço",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Layout().segmented(opcoes, opcaoAlmoco, mudaralmoco, context),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Lanche",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Layout().segmented(opcoes, opcaoLanche, mudarlanche, context),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Fruta",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Layout().segmented(opcoesfruta, opcaoFruta, mudarfruta, context),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Jantar",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Layout().segmented(opcoes, opcaoJantar, mudarjantar, context),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Divider(
                      thickness: 0.6,
                      color: Cores().corprincipal,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Mamadeira",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Cores().corprincipal),
                        ),
                      ],
                    ),
                  ),
                  Layout().segmented(
                      opcoesMamadeira, opcaoMamadeira, mudarmamadeira, context),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Horários: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Layout().caixadetexto(1, 1, TextInputType.text, cmamadeira, "Exemplo: 9:40, 11:30, 13:00", TextCapitalization.none,),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Divider(
                      thickness: 0.6,
                      color: Cores().corprincipal,
                    ),
                  ),
                  Text(
                    "Soninho",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Cores().corprincipal),
                  ),
                  Layout().caixadetexto(1, 1,TextInputType.text, csono, "Exemplo: 13:00 - 14:00",TextCapitalization.none,),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Divider(
                      thickness: 0.6,
                      color: Cores().corprincipal,
                    ),
                  ),
                  Text(
                    "Cuidado",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Cores().corprincipal),
                  ),
                  Text(
                    "Xixi:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Layout().caixadetexto(1, 1,TextInputType.text, cxixi, "Exemplo: 09:40, 11:30, 13:00",TextCapitalization.none,),
                  Text(
                    "Cocô",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Layout().segmented(opcoesCoco, opcaoCoco, mudarcoco, context),
                  Layout().caixadetexto(1, 1,TextInputType.text, ccc, "Exemplo: 09:40, 11:30, 13:00",TextCapitalization.none,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:Divider(
                      thickness: 0.6,
                      color: Cores().corprincipal,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Observações importantes:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Cores().corprincipal),
                    ),
                  ),
                  Layout().caixadetexto(1, 8, TextInputType.multiline, cobs, "Informações sobre o dia e saúde.",TextCapitalization.sentences,),
                ],
              ),
            ),
          ),
          (MediaQuery.of(context).size.width > 850) ? SizedBox(width: MediaQuery.of(context).size.width*0.2,): Container(),
        ],
      ),
    );
  }

  void parasalvar(BuildContext context) {
      Pesquisa().salvarCuidados( widget.usuario,
          widget.nome,
          widget.turma,
        widget.unidade,
          widget.alunoid,
        cxixi.text,
        cmamadeira.text,
        csono.text,
        cc,
        ccc.text,
        mamadeira,
        manha,
        almoco,
        lanche,
        fruta,
        jantar,
        cobs.text,
        context);
      Navigator.pop(context);
  }


  void mudarmanha(val) {
    setState(() {
      opcao = val;
      if (opcao == 1) {
        manha = "Bem";
      } else if (opcao == 2) {
        manha = "Pouco";
      } else if (opcao == 3) {
        manha = "Recusou";
      } else {
        manha = "";
      }
    });
  }

  void mudaralmoco(val) {
    setState(() {
      opcaoAlmoco = val;
      if (opcaoAlmoco == 1) {
        almoco = "Bem";
      } else if (opcaoAlmoco == 2) {
        almoco = "Pouco";
      } else if (opcaoAlmoco == 3) {
        almoco = "Recusou";
      } else {
        almoco = "";
      }
    });
  }

  void mudarlanche(val) {
    setState(() {
      opcaoLanche = val;
      if (opcaoLanche == 1) {
        lanche = "Bem";
      } else if (opcaoLanche == 2) {
        lanche = "Pouco";
      } else if (opcaoLanche == 3) {
        lanche = "Recusou";
      } else {
        lanche = "";
      }
    });
  }

  void mudarfruta(val) {
    setState(() {
      opcaoFruta = val;
      if (opcaoFruta == 1) {
        fruta = "Aceitou";
      } else if (opcaoFruta == 2) {
        fruta = "Recusou";
      } else {
        fruta = "";
      }
    });
  }

  void mudarjantar(val) {
    setState(() {
      opcaoJantar = val;
      if (opcaoJantar == 1) {
        jantar = "Bem";
      } else if (opcaoJantar == 2) {
        jantar = "Pouco";
      } else if (opcaoJantar == 3) {
        jantar = "Recusou";
      } else {
        jantar = "";
      }
    });
  }

  void mudarmamadeira(val) {
    setState(() {
      opcaoMamadeira = val;
      if (opcaoMamadeira == 1) {
        mamadeira = "120 ml";
      } else if (opcaoMamadeira == 2) {
        mamadeira = "150 ml";
      } else if (opcaoMamadeira == 3) {
        mamadeira = "180 ml";
      } else if (opcaoMamadeira == 3) {
        mamadeira = "210 ml";
      } else {
        mamadeira = "";
      }
    });
  }

  void mudarcoco(val) {
    setState(() {
      opcaoCoco = val;
      if (opcaoCoco == 1) {
        cc = "Normal";
      } else if (opcaoCoco == 2) {
        cc = "Amolecido";
      } else {
        cc = "";
      }
    });
  }
}
