import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'itens/itemcheckbox.dart';
import 'layout.dart';
import 'pesquisa.dart';
import 'design.dart';

class Funcionalidades extends StatefulWidget {
  final DocumentSnapshot usuario;

  Funcionalidades(this.usuario);

  @override
  _FuncionalidadesState createState() => _FuncionalidadesState();
}

class _FuncionalidadesState extends State<Funcionalidades> {
  List<String> unidades = [];
  List<String> cursos = ['EI', 'EF1', 'EF2', 'EM', 'CN'];
  List<String> cursosselecionadoscardapios = [];
  List<String> cursosselecionadoshorarios = [];
  List<String> cursosselecionadosavaliacoes = [];
  List<String> cursosselecionadosrecados = [];
  String unidade='';
  bool aniversariantes = false,
      aniversariantesapenasescola = false,
      mostrarTurma = false,
      cardapios = false,
      cuidados = false,
      horarios = false,
      avaliacoes = false,
      chatinterno = false,
      horariopublicacao = false,
      recadosprofessor = false,
      moderacao = false,
      encerrarmenu = false;

  @override
  void initState() {
    super.initState();
    Pesquisa().sendAnalyticsEvent(tela: Nomes().funcionalidades);
    if (widget.usuario['unidade'] == 'Todas as unidades') {
      buscarunidades();
    } else {
      unidades = [widget.usuario['unidade']];
      unidade = widget.usuario['unidade'];
      buscainicial(unidade);
    }
  }

  buscarunidades() {
    FirebaseFirestore.instance
        .collection(Nomes().unidadebanco)
        .get()
        .then((docs) {
      docs.docs.forEach((doc) {
        setState(() {
          unidades.add(doc['unidade']);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbarcombotaosimples(
          parasalvar, 'Funcionalidades', 'Salvar', context),
      body: Row(
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: Card(
              child: Column(
                children: [
                  Layout().dropdownitem('Selecione a unidade', unidade,
                      (String text) {
                    setState(() {
                      aniversariantes = false;
                      aniversariantesapenasescola = false;
                      cardapios = false;
                      cuidados = false;
                      horarios = false;
                      avaliacoes = false;
                      horariopublicacao = false;
                      chatinterno = false;
                      mostrarTurma = false;
                      recadosprofessor = false;
                      moderacao = false;
                      encerrarmenu = false;
                      cursosselecionadosavaliacoes = [];
                      cursosselecionadoscardapios.clear();
                      cursosselecionadoshorarios.clear();
                      cursosselecionadosrecados.clear();
                      unidade = text;
                    });
                    buscainicial(unidade);
                  }, unidades),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Layout().checkBox(aniversariantes, (bool value) {
                              setState(() {
                                aniversariantes = value;
                              });
                            }, 'Aniversariantes para Administração'),
                            textoexplicacao(
                                'Lista de aniversariantes separado por mês, visualização por turma'),
                            Divider(
                              thickness: 1.0,
                            ),
                            Layout().checkBox(avaliacoes, (bool value) {
                              setState(() {
                                avaliacoes = value;
                                if (value == false) {
                                  cursosselecionadosavaliacoes.clear();
                                }
                              });
                            }, 'Avaliações'),
                            textoexplicacao(
                                'Calendário de avaliações por turmas, anexados por imagem ou pdf.'),
                            (avaliacoes)
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Column(
                                      children: cursos.map((String document) {
                                        return ItemCheckBox(document,
                                            cursosselecionadosavaliacoes);
                                      }).toList(),
                                    ),
                                  )
                                : Container(),
                            Divider(
                              thickness: 1.0,
                            ),
                            Layout().checkBox(cardapios, (bool value) {
                              setState(() {
                                cardapios = value;
                                if (value == false) {
                                  cursosselecionadoscardapios.clear();
                                }
                              });
                            }, 'Cardápios'),
                            textoexplicacao(
                                'Cardápio anexado a partir de uma imagem ou pdf'),
                            (cardapios)
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Column(
                                      children: cursos.map((String document) {
                                        return ItemCheckBox(document,
                                            cursosselecionadoscardapios);
                                      }).toList(),
                                    ),
                                  )
                                : Container(),
                            Divider(
                              thickness: 1.0,
                            ),
                            Layout().checkBox(horarios, (bool value) {
                              setState(() {
                                horarios = value;
                                if (value == false) {
                                  cursosselecionadoshorarios.clear();
                                }
                              });
                            }, 'Horários'),
                            textoexplicacao(
                                'Horários divididos por turmas, anexados por imagem ou pdf.'),
                            (horarios)
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Column(
                                      children: cursos.map((String document) {
                                        return ItemCheckBox(document,
                                            cursosselecionadoshorarios);
                                      }).toList(),
                                    ),
                                  )
                                : Container(),
                            Divider(
                              thickness: 1.0,
                            ),
                            Layout().checkBox(recadosprofessor, (bool value) {
                              setState(() {
                                recadosprofessor = value;
                                if (value == false) {
                                  cursosselecionadosrecados.clear();
                                }
                              });
                            }, 'Recados para Professores'),
                            textoexplicacao(
                                'Alunos e Responsáveis podem enviar mensagens de texto e imagens para os professores.'),
                            (recadosprofessor)
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Column(
                                      children: cursos.map((String document) {
                                        return ItemCheckBox(document,
                                            cursosselecionadosrecados);
                                      }).toList(),
                                    ),
                                  )
                                : Container(),
                            Divider(
                              thickness: 1.0,
                            ),
                            Layout().checkBox(cuidados, (bool value) {
                              setState(() {
                                cuidados = value;
                              });
                            }, 'Cuidados Diários da Educação Infantil'),
                            textoexplicacao(
                                'Envio de informações sobre: alimentação, uso do banheiro, mamadeira, soninho.'),
                            Divider(
                              color: Cores().corprincipal,
                              thickness: 1.0,
                            ),
                            Layout().checkBox(horariopublicacao, (bool value) {
                              setState(() {
                                horariopublicacao = value;
                              });
                            }, 'Fotos e Atividades após as 17h45'),
                            textoexplicacao(
                                'Visualização pelos responsáveis das publicações de Fotos e Atividades após as 17h45.'),
                            Divider(
                              thickness: 1.0,
                            ),
                            Layout().checkBox(chatinterno, (bool value) {
                              setState(() {
                                chatinterno = value;
                              });
                            }, 'Chat Interno de Funcionários'),
                            textoexplicacao(
                                'Mensagens em forma de chat entre os funcionários da unidade'),
                            Divider(
                              thickness: 1.0,
                            ),
                            Layout().checkBox(mostrarTurma, (bool value) {
                              setState(() {
                                mostrarTurma = value;
                              });
                            }, 'Mostrar turma no Perfil do Aluno'),
                            textoexplicacao(
                                ''),
                            Divider(
                              thickness: 1.0,
                            ),
                            Layout().checkBox(moderacao, (bool value) {
                              setState(() {
                                moderacao = value;
                              });
                            }, 'Moderação'),
                            textoexplicacao(
                                'As publicações dos professores devem ser aprovadas por Coordenadores ou Direção antes de ser enviadas aos responsáveis.'),
                            Divider(
                              color: Cores().corprincipal,
                              thickness: 1.0,
                            ),
                            Layout().checkBox(encerrarmenu, (bool value) {
                              setState(() {
                                encerrarmenu = value;
                              });
                            }, 'Encerrar no Menu'),
                            textoexplicacao(
                                'Botão Encerrar Sessão (LogOut) será incluído no menu na página principal.'),
                            Divider(
                              color: Cores().corprincipal,
                              thickness: 1.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Layout().espacolateral(context),
        ],
      ),
    );
  }

  textoexplicacao(texto) {
    return Padding(
      padding: const EdgeInsets.only(left: 35.0),
      child: Text(
        texto,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  void buscainicial(uni) {
    FirebaseFirestore.instance
        .collection('Funcionalidades')
        .doc(uni)
        .get()
        .then((doc) {
      setState(() {
        aniversariantes = doc['aniversariantes'];
        aniversariantesapenasescola = doc['aniversariantesapenasescola'];
        moderacao = doc['moderacao'];
        encerrarmenu = doc['encerrarmenu'];
        cuidados = doc['cuidados'];
        horariopublicacao = doc['horariopublicacao'];
        chatinterno = doc['chatinterno'];
        mostrarTurma = doc['mostrarTurma'];
        if (List<String>.from(doc['cardapios']).isNotEmpty) {
          cardapios = true;
          cursosselecionadoscardapios = List<String>.from(doc['cardapios']);
        }
        if (List<String>.from(doc['avaliacoes']).isNotEmpty) {
          avaliacoes = true;
          cursosselecionadosavaliacoes = List<String>.from(doc['avaliacoes']);
        }

        if (List<String>.from(doc['horarios']).isNotEmpty) {
          horarios = true;
          cursosselecionadoshorarios = List<String>.from(doc['horarios']);
        }
        if (List<String>.from(doc['recados']).isNotEmpty) {
          recadosprofessor = true;
          cursosselecionadosrecados = List<String>.from(doc['recados']);
        }
      });
    });
  }

  void parasalvar(BuildContext context) {
    if (unidade == null) {
      Layout().dialog1botao(context, 'Unidade', 'Selecione a unidade.');
    } else {
      Layout().dialog1botao(context, 'Perfeito', 'As alterações foram salvas');

      Map<String, dynamic> map = Map();
      map['createdAt'] = DateTime.now().toIso8601String();
      map['datacomparar'] = DateTime.now();
      map['responsavel'] = widget.usuario['nome'];
      map['aniversariantes'] = aniversariantes;
      map['aniversariantesapenasescola'] = aniversariantesapenasescola;
      map['cardapios'] = cursosselecionadoscardapios;
      map['horarios'] = cursosselecionadoshorarios;
      map['avaliacoes'] = cursosselecionadosavaliacoes;
      map['recados'] = cursosselecionadosrecados;
      map['moderacao'] = moderacao;
      map['encerrarmenu'] = encerrarmenu;
      map['cuidados'] = cuidados;
      map['horariopublicacao'] = horariopublicacao;
      map['chatinterno'] = chatinterno;
      map['mostrarTurma'] = mostrarTurma;
      map['data'] = Pesquisa().hoje();

      FirebaseFirestore.instance
          .collection('Funcionalidades')
          .doc(unidade)
          .set(map);
    }
  }
}
