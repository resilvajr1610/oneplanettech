import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:scalifra/webviewbasica.dart';
import 'package:simple_rc4/simple_rc4.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase/firebase.dart' as fb;

import 'blocs.dart';
import 'design.dart';
import 'layout.dart';
import 'utils/User.dart';

class Pesquisa {
  String replaceforpush(String texto) {
    String newtexto = texto.toLowerCase()
        .replaceAll(RegExp(' '), '')
        .replaceAll(RegExp('ç'), 'c')
        .replaceAll(RegExp('/'), '')
        .replaceAll(RegExp('-'), '')
        .replaceAll(RegExp('ê'), 'e')
        .replaceAll(RegExp('á'), 'a')
        .replaceAll(RegExp('º'), '')
        .replaceAll(RegExp('ã'), 'a')
        .replaceAll(RegExp('â'), 'a');
    return newtexto;
  }



  void launchURL(String url, BuildContext context) async {
    if (kIsWeb) {
      Pesquisa().sendAnalyticsEvent(tela: Nomes().clicouLogo);
      if (await canLaunch(url) != null) {
        await launch(url);
      } else {
        Toast.show('Não conseguimos abrir a página.', textStyle: context);
        throw 'Não conseguimos abrir a página.';
      }
    } else {
      irpara(WebviewBasic(url), context);
    }
  }

  /*
  exemplo: calendario_parentesco_unidade
se for controle: calendario_perfil_unidade
   */

  Future<void> sendAnalyticsEvent({required String tela}) async {
    User u = User();
    Map<String, dynamic> map = Map();

    if (u.controle != null) {
      String unidade = u.unidade.replaceAll(' ', '_');
      String name = tela + "_" + unidade;
      String fullName = name.substring(0, min(name.length, 39));

      map = {
        'plataforma': u.plataforma,
        'curso': u.cursos.toString().replaceAll(' ', '_'),
        'perfil': u.perfil.toString(),
        'turmas': u.turmas.toString().replaceAll(' ', '_'),
      };

      await FirebaseAnalytics.instance.logEvent(name: fullName, parameters: map);
    } else {
      String name = tela + "_" + u.unidade;
      String fullName = name.substring(0, min(name.length, 39));

      map = {
        'plataforma': u.plataforma,
        'curso': u.curso,
        'turma': u.turma,
        'perfil': u.parentesco,
        'responsavelfinanceiro': u.responsavelfinanceiro.toString(),
      };

      await FirebaseAnalytics.instance.logEvent(
          name: fullName.substring(0, min(fullName.length, 39)),
          parameters: map);
    }
  }

  Future<void> sendAnalyticsEventAntigo(
      {required String tela,
      required DocumentSnapshot usuario,
      required DocumentSnapshot alunoDoc}) async {
    print(usuario.data.toString());

    if (usuario[Nomes().controle] != null) {
      String unidade = usuario['unidade'];
      String perfil = usuario['perfil'];
      String fullName = tela + '_' + perfil + '_' + unidade;

      await FirebaseAnalytics.instance.logEvent(name: fullName, parameters: {
        'nome': usuario['nome'],
        'email': usuario['email'],
        'plataforma': usuario['platform'],
        'curso': usuario['curso'],
        'turma': usuario['turma'],
      });
    } else {
      String unidade = alunoDoc['unidade'];
      String parentesco = usuario['parentesco'];
      String fullName = tela + '_' + parentesco + '_' + unidade;

      await FirebaseAnalytics.instance.logEvent(name: fullName, parameters: {
        'nome': usuario['nome'],
        'email': usuario['email'],
        'curso': alunoDoc['curso'],
        'turma': alunoDoc['turma'],
        'plataforma': usuario['platform'],
        'responsavelfinanceiro': usuario['responsavelfinanceiro'],
      });
    }
  }

  responderrecado(document, resposta, moderacao, usuario, context) {
    Map<String, dynamic> map = Map();
    map['resposta'] = resposta;
    map['respondidopor'] = usuario['nome'];
    map['ciente'] = true;
    if (moderacao && usuario['perfil'] != 'Professor') {
      map['enviarresposta'] = true;
    }
    if (moderacao && usuario['perfil'] == 'Professor') {
      map['enviarresposta'] = false;
    }
    if (!moderacao) {
      map['enviarresposta'] = true;
    }
    document.reference.updateData(map).then((data) {
      Layout().dialog1botao(context, "Salvo", "Sua resposta foi salva");
      if (moderacao && usuario['moderador'] != null && usuario['moderador']) {
        enviarnotificacao(
            Nomes().push + document['para'], "Professor respondeu seu recado");
      }
    });
  }

  addpesoaltura(alunoid, peso, altura, idadeMeses, context) {
    Map<String, dynamic> map = Map();
    map['aluno'] = alunoid;
    map['peso'] = peso;
    map['altura'] = altura;
    map['idade'] = idadeMeses;
    map['data'] = hoje();
    map['createdAt'] = DateTime.now().toIso8601String();
    map['datacomparar'] = DateTime.now();
    FirebaseFirestore.instance
        .collection("${Nomes().pesoalturabanco}")
        .where("aluno", isEqualTo: alunoid.toString())
        .where('idade', isEqualTo: idadeMeses.toString())
        .get()
        .then((query) {
      if (query.docs.length > 0) {
        query.docs[0].reference.update(map).then((doc) {
          Layout().dialog1botao(
              context, "Salvo", "Os dados de peso e altura foram salvos");
        });
      } else {
        FirebaseFirestore.instance
            .collection(Nomes().pesoalturabanco)
            .add(map)
            .then((document) {
          Layout().dialog1botao(
              context, "Salvo", "Os dados de peso e altura foram salvos");
        });
      }
    });
  }

  String alterardata(int i, data) {
    String date = data;
    var dataseparada = date.split("/");
    var datadolabel = DateTime.parse(
        '${dataseparada[2]}-${dataseparada[1]}-${dataseparada[0]} 00:00:00.000');
    var alterardia = datadolabel.add(new Duration(days: i));
    String dataalterada = DateFormat('dd/MM/yyyy').format(alterardia);
    return dataalterada;
  }

  enviarnotificacao(topic, mensagem) {
    Map<String, Object> noti = Map();
    noti['topic'] = Pesquisa().replaceforpush(topic) + "2022";
    noti['title'] = Nomes().nomerede;
    noti['mensagem'] = mensagem;
    FirebaseFunctions.instance
        .httpsCallable("enviarnotificacao")
        .call(noti);
  }

  enviarnotificacaotoken(token, mensagem) {
    Map<String, Object> noti = Map();
    noti['token'] = token;
    noti['title'] = Nomes().nomerede;
    noti['mensagem'] = mensagem;
    FirebaseFunctions.instance
        .httpsCallable("enviarnotificacaotoken")
        .call(noti);
  }

  salvarCardapio(imagem, imagefromweb, tipo, context) async {
    if (imagem != null) {
      String nomeImagem =
          "Cardapios/" + DateTime.now().toIso8601String() + ".jpg";
      Reference storageReference =
          FirebaseStorage.instance.ref().child(nomeImagem);
      // StorageUploadTask uploadTask = storageReference.putFile(imagem);
      // uploadTask.onComplete.then((value) {
      //   value.ref.getDownloadURL().then((value) {
      //     Map<String, dynamic> map = Map();
      //     map['imagem'] = value.toString();
      //     map['nomeImagem'] = nomeImagem;
      //     if (tipo != null) {
      //       map['tipo'] = tipo;
      //     }
      //     map['data'] = hoje();
      //     map['createdAt'] = DateTime.now().toIso8601String();
      //     map['datacomparar'] = DateTime.now();
      //     Firestore.instance.collection(Nomes().cardapiobanco).add(map);
      //   });
      // });
    } else {
      String nomearquivo = "Cardapios/" + DateTime.now().toIso8601String();

      Uri imageUri = await salvarfileweb(nomearquivo, imagefromweb);
      Map<String, dynamic> map = Map();
      map['imagem'] = imageUri.toString();
      if (tipo != null) {
        map['tipo'] = tipo;
      }
      map['data'] = hoje();
      map['createdAt'] = DateTime.now().toIso8601String();
      map['datacomparar'] = DateTime.now();
      FirebaseFirestore.instance.collection(Nomes().cardapiobanco).add(map);
    }
  }

  salvarpdfweb(caminho, nomedoc, pdfweb, DocumentSnapshot doc) async {
    String nomearquivo = caminho + '${DateTime.now().toIso8601String()}.pdf';

    Uri value = await salvarfileweb(nomearquivo, pdfweb);

    doc.reference.update({
      'documento': value.toString(),
      'nomedocumento': nomedoc,
      'nomearquivo': nomearquivo
    });
  }

  salvarunidade(map, filebarra, filemenu, filewebbarra, filewebmenu) async {
    if (filebarra != null) {
      String nomearquivo =
          'Unidades/${map['unidade']}/${DateTime.now().toIso8601String()}barra.jpg';
      Reference storageReference =
          FirebaseStorage.instance.ref().child(nomearquivo);
      // StorageUploadTask uploadTask = storageReference.putFile(filebarra);
      // uploadTask.onComplete.then((value) {
      //   value.ref.getDownloadURL().then((value) {
      //     Map<String, dynamic> novomapa = Map();
      //     String imagest = value.toString();
      //     novomapa['logobarra'] = imagest;
      //     novomapa['storagerefbarra'] = nomearquivo;
      //     FirebaseFirestore.instance
      //         .collection(Nomes().unidadebanco)
      //         .doc(map['unidade'])
      //         .update(novomapa);
      //   });
      // });
    }

    if (filemenu != null) {
      String nomearquivo =
          'Unidades/${map['unidade']}/${DateTime.now().toIso8601String()}menu.jpg';
      Reference storageReference =
          FirebaseStorage.instance.ref().child(nomearquivo);
      // StorageUploadTask uploadTask = storageReference.putFile(filebarra);
      // uploadTask.onComplete.then((value) {
      //   value.ref.getDownloadURL().then((value) {
      //     Map<String, dynamic> novomapa = Map();
      //     String imagest = value.toString();
      //     novomapa['logomenu'] = imagest;
      //     novomapa['storagerefmenu'] = nomearquivo;
      //     FirebaseFirestore.instance
      //         .collection(Nomes().unidadebanco)
      //         .doc(map['unidade'])
      //         .update(novomapa);
      //   });
      // });
    }

    if (filewebbarra != null) {
      String nomearquivo =
          'Unidades/${map['unidade']}/${DateTime.now().toIso8601String()}barra.jpg';

      fb.StorageReference storageRef = fb.storage().ref(nomearquivo);
      fb.UploadTaskSnapshot uploadTaskSnapshot =
          await storageRef.put(filewebbarra).future;
      Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
      Map<String, dynamic> novomapa = Map();
      String imagest = imageUri.toString();

      novomapa['logobarra'] = imagest;
      novomapa['storagerefbarra'] = nomearquivo;
      await FirebaseFirestore.instance
          .collection(Nomes().unidadebanco)
          .doc(map['unidade'])
          .update(novomapa);
    }
    if (filewebmenu != null) {
      String nomearquivo =
          'Unidades/${map['unidade']}/${DateTime.now().toIso8601String()}menu.jpg';

      fb.StorageReference storageRef = fb.storage().ref(nomearquivo);
      fb.UploadTaskSnapshot uploadTaskSnapshot =
          await storageRef.put(filewebmenu).future;
      Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
      Map<String, dynamic> novomapa = Map();
      String imagest = imageUri.toString();

      novomapa['logomenu'] = imagest;
      novomapa['storagerefmenu'] = nomearquivo;
      await FirebaseFirestore.instance
          .collection(Nomes().unidadebanco)
          .doc(map['unidade'])
          .update(novomapa);
    }
  }

  salvarfirebase(collection, map, file, fileweb) async {
    if (file != null) {
      String nomearquivo =
          '$collection/${map['userid']}/${DateTime.now().toIso8601String()}.jpg';
      Reference storageReference =
          FirebaseStorage.instance.ref().child(nomearquivo);
      // StorageUploadTask uploadTask = storageReference.putFile(file);
      // uploadTask.onComplete.then((value) {
      //   value.ref.getDownloadURL().then((value) {
      //     String imagest = value.toString();
      //     map['documento'] = imagest;
      //     map['storageref'] = nomearquivo;
      //     FirebaseFirestore.instance.collection(collection).add(map);
      //   });
      // });
    } else if (fileweb != null) {
      String nomearquivo =
          '$collection/${map['userid']}/${DateTime.now().toIso8601String()}.jpg';

      fb.StorageReference storageRef = fb.storage().ref(nomearquivo);
      fb.UploadTaskSnapshot uploadTaskSnapshot =
          await storageRef.put(fileweb).future;
      Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();

      String imagest = imageUri.toString();

      map['documento'] = imagest;
      map['storageref'] = nomearquivo;
      await FirebaseFirestore.instance.collection(collection).add(map);
    } else {
      FirebaseFirestore.instance.collection(collection).add(map);
    }
  }

  salvarfirebasepdf(collection, map, file, fileweb) async {
    if (file != null) {
      String nomearquivo =
          '$collection/${map['unidade']}/${DateTime.now().toIso8601String()}.pdf';
      Reference storageReference =
          FirebaseStorage.instance.ref().child(nomearquivo);
      // StorageUploadTask uploadTask = storageReference.putFile(file);
      // uploadTask.onComplete.then((value) {
      //   value.ref.getDownloadURL().then((value) {
      //     String imagest = value.toString();
      //     map['documento'] = imagest;
      //     map['storageref'] = nomearquivo;
      //     FirebaseFirestore.instance.collection(collection).add(map);
      //   });
      // });
    } else if (fileweb != null) {
      String nomearquivo =
          '$collection/${map['unidade']}/${DateTime.now().toIso8601String()}.pdf';

      fb.StorageReference storageRef = fb.storage().ref(nomearquivo);
      fb.UploadTaskSnapshot uploadTaskSnapshot =
          await storageRef.put(fileweb).future;
      Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();

      String imagest = imageUri.toString();

      map['documento'] = imagest;
      map['storageref'] = nomearquivo;
      await FirebaseFirestore.instance.collection(collection).add(map);
    } else {
      FirebaseFirestore.instance.collection(collection).add(map);
    }
  }

  atualizarfirebase(
      DocumentSnapshot document, collection, map, file, fileweb) async {
    if (file != null) {
      String nomearquivo =
          '$collection/${map['userid']}/${DateTime.now().toIso8601String()}.jpg';
      Reference storageReference =
          FirebaseStorage.instance.ref().child(nomearquivo);
      // StorageUploadTask uploadTask = storageReference.putFile(file);
      // uploadTask.onComplete.then((value) {
      //   value.ref.getDownloadURL().then((value) {
      //     map['documento'] = value.toString();
      //     map['storageref'] = nomearquivo;
      //     document.reference.update(map);
      //   });
      // });
    } else if (fileweb != null) {
      String nomearquivo =
          '$collection/${map['userid']}/${DateTime.now().toIso8601String()}.jpg';

      fb.StorageReference storageRef = fb.storage().ref(nomearquivo);
      fb.UploadTaskSnapshot uploadTaskSnapshot =
          await storageRef.put(fileweb).future;
      Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();

      String imagest = imageUri.toString();
      map['documento'] = imagest;
      map['storageref'] = nomearquivo;

      await document.reference.update(map);
    } else {
      document.reference.update(map);
    }

    FirebaseFirestore.instance
        .collection(collection)
        .doc(document.id)
        .update(map);
  }

  Future<Uri> salvarfileweb(nomearquivo, file) async {
    fb.StorageReference storageRef = fb.storage().ref(nomearquivo);
    fb.UploadTaskSnapshot uploadTaskSnapshot =
        await storageRef.put(file).future;

    Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
    return imageUri;
  }

  salvarEnquete(List turmasSelecionadas, List indexturmas, pergunta, sede,
      usuario, context) {
    Navigator.pop(context);
    Navigator.pop(context);
    for (int i = 0; i < indexturmas.length; i++) {
      Map<String, dynamic> map = Map();
      map['data'] = hoje();
      map['para'] = turmasSelecionadas[indexturmas[i]];
      map['parametrosbusca'] = [turmasSelecionadas[indexturmas[i]]];
      map['turma'] = turmasSelecionadas[indexturmas[i]];
      if (sede) {
        map['sede'] = usuario['sede'];
      }
      map['pergunta'] = pergunta;
      map['tipo'] = "enquete";
      map['createdAt'] = DateTime.now().toIso8601String();
      map['datacomparar'] = DateTime.now();
      FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .add(map)
          .then((document) {
        if (turmasSelecionadas[indexturmas[i]] == "Todas") {
          enviarnotificacao(Nomes().push, "Nova enquete");
        } else {
          enviarnotificacao(Nomes().push + turmasSelecionadas[indexturmas[i]],
              "Nova enquete");
        }
      });
    }
  }

  salvarLinkVideo(List turmasSelecionadas, List indexturmas, String link, sede,
      usuario, context) {
    Navigator.pop(context);
    Navigator.pop(context);
    if (!link.contains('youtu')) {
      return;
    }
    for (int i = 0; i < indexturmas.length; i++) {
      Map<String, dynamic> map = Map();
      map['data'] = hoje();
      map['para'] = turmasSelecionadas[indexturmas[i]];
      map['parametrosbusca'] = [turmasSelecionadas[indexturmas[i]]];
      map['turma'] = turmasSelecionadas[indexturmas[i]];
      map['nome'] = turmasSelecionadas[indexturmas[i]];
      if (sede) {
        map['sede'] = usuario['sede'];
      }
      map['link'] = link;
      map['tipo'] = "video";
      map['createdAt'] = DateTime.now().toIso8601String();
      map['datacomparar'] = DateTime.now();
      FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .add(map)
          .then((document) {
        if (turmasSelecionadas[indexturmas[i]] == "Todas") {
          enviarnotificacao(Nomes().push, "Novo vídeo");
        } else {
          enviarnotificacao(
              Nomes().push + turmasSelecionadas[indexturmas[i]], "Novo vídeo");
        }
      });
    }
  }

  salvarLinkGoogle(List turmasSelecionadas, List indexturmas, String link,
      String titulo, sede, usuario, context) {
    Navigator.pop(context);
    Navigator.pop(context);
    for (int i = 0; i < indexturmas.length; i++) {
      Map<String, dynamic> map = Map();
      map['data'] = hoje();
      map['para'] = turmasSelecionadas[indexturmas[i]];
      map['parametrosbusca'] = [turmasSelecionadas[indexturmas[i]]];
      map['turma'] = turmasSelecionadas[indexturmas[i]];
      map['nome'] = turmasSelecionadas[indexturmas[i]];
      if (sede) {
        map['sede'] = usuario['sede'];
      }
      map['link'] = link;
      map['titulo'] = titulo;
      map['tipo'] = "apresentacao";
      map['createdAt'] = DateTime.now().toIso8601String();
      map['datacomparar'] = DateTime.now();
      FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .add(map)
          .then((document) {
        if (turmasSelecionadas[indexturmas[i]] == "Todas") {
          enviarnotificacao(Nomes().push, "Nova apresentação");
        } else {
          enviarnotificacao(Nomes().push + turmasSelecionadas[indexturmas[i]],
              "Nova apresentação");
        }
      });
    }
  }

  incluirparametros() {
    FirebaseFirestore.instance
        .collection(Nomes().publicacoesbanco)
        .get()
        .then((documents) {
      documents.docs.forEach((doc) {
        doc.reference.update({
          'parametrosbusca': [doc['para']]
        });
      });
    });
  }

  getPublicacoes(
      alunoitem, mapalunos, filtro, count, sede, usuario, turma) async {
    final bloc = BlocProvider.getBloc<MainEscolaBloc>();
    StreamSubscription<QuerySnapshot>? listenerquery;
    if (alunoitem != null && alunoitem != "Todos") {
      String idAluno='';
      mapalunos.forEach((id, lista) {
        if (lista[0] == alunoitem) {
          idAluno = id;
        }
      });

      if (filtro == "todas") {
        if (listenerquery != null) {
          listenerquery.cancel();
        }
        listenerquery = FirebaseFirestore.instance
            .collection(Nomes().publicacoesbanco)
            .where("para", isEqualTo: idAluno)
            .orderBy("datacomparar", descending: true)
            .limit(count)
            .snapshots()
            .listen((query) {
          if (query.docs.length > 0) {
            bloc.inputUltimodoc.add(query.docs.last);
          }
          bloc.inputList.add(query.docs);
        });
      } else {
        if (listenerquery != null) {
          listenerquery.cancel();
        }
        listenerquery = FirebaseFirestore.instance
            .collection(Nomes().publicacoesbanco)
            .where("para", isEqualTo: idAluno)
            .where("tipo", isEqualTo: filtro)
            .orderBy("datacomparar", descending: true)
            .limit(count)
            .snapshots()
            .listen((query) {
          if (query.docs.length > 0) {
            bloc.inputUltimodoc.add(query.docs.last);
          }
          bloc.inputList.add(query.docs);
        });
      }
    } else if (turma != "Todas") {
      if (filtro == "todas") {
        if (listenerquery != null) {
          listenerquery.cancel();
        }
        listenerquery = FirebaseFirestore.instance
            .collection(Nomes().publicacoesbanco)
            .where("turma", isEqualTo: turma)
            .orderBy("datacomparar", descending: true)
            .limit(count)
            .snapshots()
            .listen((query) {
          if (query.docs.length > 0) {
            bloc.inputUltimodoc.add(query.docs.last);
          }
          bloc.inputList.add(query.docs);
        });
      } else {
        if (listenerquery != null) {
          listenerquery.cancel();
        }
        listenerquery = FirebaseFirestore.instance
            .collection(Nomes().publicacoesbanco)
            .where("turma", isEqualTo: turma)
            .where("tipo", isEqualTo: filtro)
            .orderBy("datacomparar", descending: true)
            .limit(count)
            .snapshots()
            .listen((query) {
          if (query.docs.length > 0) {
            bloc.inputUltimodoc.add(query.docs.last);
          }
          bloc.inputList.add(query.docs);
        });
      }
    } else if (sede && usuario['sede'] != null && usuario['sede'] != 'Todas') {
      if (filtro == "todas") {
        if (listenerquery != null) {
          listenerquery.cancel();
        }
        listenerquery = FirebaseFirestore.instance
            .collection(Nomes().publicacoesbanco)
            .where("sede", isEqualTo: usuario['sede'])
            .orderBy("datacomparar", descending: true)
            .limit(count)
            .snapshots()
            .listen((query) {
          if (query.docs.length > 0) {
            bloc.inputUltimodoc.add(query.docs.last);
          }
          bloc.inputList.add(query.docs);
        });
      } else {
        if (listenerquery != null) {
          listenerquery.cancel();
        }
        listenerquery = FirebaseFirestore.instance
            .collection(Nomes().publicacoesbanco)
            .where("sede", isEqualTo: usuario['sede'])
            .where("tipo", isEqualTo: filtro)
            .orderBy("datacomparar", descending: true)
            .limit(count)
            .snapshots()
            .listen((query) {
          if (query.docs.length > 0) {
            bloc.inputUltimodoc.add(query.docs.last);
          }
          bloc.inputList.add(query.docs);
        });
      }
    } else {
      if (filtro == "todas") {
        if (listenerquery != null) {
          listenerquery.cancel();
        }
        listenerquery = FirebaseFirestore.instance
            .collection(Nomes().publicacoesbanco)
            .orderBy("datacomparar", descending: true)
            .limit(count)
            .snapshots()
            .listen((query) {
          if (query.docs.length > 0) {
            bloc.inputUltimodoc.add(query.docs.last);
          }
          bloc.inputList.add(query.docs);
        });
      } else {
        if (listenerquery != null) {
          listenerquery.cancel();
        }
        listenerquery = FirebaseFirestore.instance
            .collection(Nomes().publicacoesbanco)
            .orderBy("datacomparar", descending: true)
            .where("tipo", isEqualTo: filtro)
            .limit(count)
            .snapshots()
            .listen((query) {
          if (query.docs.length > 0) {
            bloc.inputUltimodoc.add(query.docs.last);
          }
          bloc.inputList.add(query.docs);
        });
      }
    }
  }

  salvarLink(List turmasSelecionadas, List indexturmas, link, nomelink, usuario,
      context) {
    print(turmasSelecionadas.toString());
    print(indexturmas.toString());
    for (int i = 0; i < indexturmas.length; i++) {
      Map<String, dynamic> map = Map();
      map['createdAt'] = DateTime.now().toIso8601String();
      map['data'] = hoje();
      map['datacomparar'] = DateTime.now();
      map['link'] = link;
      map['nomelink'] = nomelink;
      map['turma'] = turmasSelecionadas[indexturmas[i]];
      map['turmabusca'] = [turmasSelecionadas[indexturmas[i]]];
      if (usuario['sede'] != null) {
        map['sede'] = usuario['sede'];
      }
      FirebaseFirestore.instance
          .collection(Nomes().linksbanco)
          .add(map)
          .then((document) {
        if (turmasSelecionadas[indexturmas[i]] == "Todas") {
          enviarnotificacao(Nomes().push, "Novo link");
        } else {
          enviarnotificacao(
              Nomes().push + turmasSelecionadas[indexturmas[i]], "Novo link");
        }
      });
    }
  }

  enviarnotiperso(opcao, selectedValues, texto, turmas, alunoid) {
    if (opcao == 0) {
      if (selectedValues.contains(0)) {
        Pesquisa().enviarnotificacao(Nomes().push, texto);
      } else {
        for (int i = 0; i < selectedValues.length; i++) {
          Pesquisa().enviarnotificacao(
              Nomes().push +
                  Pesquisa().replaceforpush(turmas[selectedValues[i]]),
              texto);
        }
      }
    } else {
      Pesquisa().enviarnotificacao(Nomes().push + alunoid, texto);
    }
  }

  adicionarfoto() {
    FirebaseFirestore.instance
        .collection(Nomes().alunosbanco)
        .where('unidade', isEqualTo: 'SANTANNA')
        .orderBy('nome')
        .get()
        .then((value) async {
      value.docs.forEach((alunodoc) async {
        fb.StorageReference storageRef = fb.storage().ref(
            'Alunos/${alunodoc['unidade']}/' + alunodoc['codigo'] + '.jpg');
        if (storageRef != null)
          storageRef.getDownloadURL().then((uri) {
            alunodoc.reference.update({'foto': uri.toString()});
          }).catchError((error, stacktracker) {
            print(alunodoc['nome']);
            alunodoc.reference.update({'foto': FieldValue.delete()});
          });
      });
    });
  }

  salvarCuidados(
      usuario,
      nome,
      turma,
      unidade,
      alunoid,
      xixi,
      mamadeirahorario,
      sono,
      cc,
      cchorario,
      qtdademamadeira,
      manha,
      almoco,
      lanche,
      fruta,
      jantar,
      obs,
      context) {
    Map<String, dynamic> map = Map();
    map['data'] = hoje();
    map['nome'] = nome;
    map['turma'] = turma;
    map['tipo'] = "cuidado";
    map['responsavel'] = usuario['nome'];
    map['para'] = alunoid;
    map['parametrosbusca'] = [alunoid, usuario.documentID];
    map['xixi'] = xixi;
    map['mamadeirahorario'] = mamadeirahorario;
    map['sono'] = sono;
    map['cc'] = cc;
    map['obs'] = obs;
    map['cchorario'] = cchorario;
    map['qtdademamadeira'] = qtdademamadeira;
    map['manha'] = manha;
    map['almoco'] = almoco;
    map['lanche'] = lanche;
    map['enviar'] = true;
    map['fruta'] = fruta;
    map['jantar'] = jantar;
    map['unidade'] = unidade;
    map['curso'] = 'EI';
    map['createdAt'] = DateTime.now().toIso8601String();
    map['datacomparar'] = DateTime.now();
    String publiid = "$alunoid${hoje().replaceAll('/', '')}";
    FirebaseFirestore.instance
        .collection(Nomes().publicacoesbanco)
        .doc(publiid)
        .set(map)
        .then((doc) {
      FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .doc(publiid)
          .get()
          .then((value) {
        salvarlogousuario(usuario, value);
      });
    });
  }

  salvarImagensWeb(caminho, imagem, DocumentSnapshot doc) async {
    if (imagem != null) {
      Uri imageUri = await salvarfileweb(
          caminho + DateTime.now().toIso8601String() + ".jpg", imagem);

      String linkfoto = imageUri.toString();
      await doc.reference.update({
        "fotos": FieldValue.arrayUnion([linkfoto])
      });
    }
  }

  salvarImagemWeb(caminho, imagem, DocumentSnapshot doc) async {
    if (imagem != null) {
      Uri imageUri = await salvarfileweb(
          caminho + DateTime.now().toIso8601String() + ".jpg", imagem);

      String linkfoto = imageUri.toString();
      await doc.reference.update({"imagem": linkfoto});
    }
  }

  salvarVideoWebDiario(turma, videoweb, DocumentSnapshot doc) async {
    if (videoweb != null) {
      String nomearquivo = "FeedPrincipal/Videos/$turma/${DateTime.now()}";

      Uri imageUri = await salvarfileweb(nomearquivo, videoweb);

      String link = imageUri.toString();
      doc.reference.update({"video": link});
    }
  }

  saveImageFromCamera(File image, String caminho, DocumentSnapshot doc) {
    String nomeImagem =
        caminho + DateTime.now().toIso8601String() + "0" + ".jpg";

    Reference storageReference =
        FirebaseStorage.instance.ref().child(nomeImagem);

    // StorageUploadTask uploadTask = storageReference.putFile(
    //     image, StorageMetadata(contentType: 'image/jpeg'));
    //
    // uploadTask.onComplete.then((caminho) {
    //   caminho.ref.getDownloadURL().then((link) {
    //     String linkfoto = link.toString();
    //     doc.reference.update({
    //       "fotos": FieldValue.arrayUnion([linkfoto])
    //     });
    //   });
    // });
  }

  salvarImagemDiario(caminho, List<Asset> imagem, DocumentSnapshot doc) {
    if (imagem.isNotEmpty) {
      for (int i = 0; i < imagem.length; i++) {
        String nomeImagem =
            caminho + DateTime.now().toIso8601String() + i.toString() + ".jpg";

        Reference storageReference =
            FirebaseStorage.instance.ref().child(nomeImagem);

        imagem[i].getByteData(quality: 50).then((value) {
          Uint8List image = value.buffer.asUint8List();

          // StorageUploadTask uploadTask = storageReference.putData(
          //     image, StorageMetadata(contentType: 'image/jpeg'));
          //
          // uploadTask.onComplete.then((caminho) {
          //   caminho.ref.getDownloadURL().then((link) {
          //     String linkfoto = link.toString();
          //
          //     doc.reference.update({
          //       "fotos": FieldValue.arrayUnion([linkfoto])
          //     });
          //   });
          // });
        });
      }
    }
  }

  salvarPDFAPP(caminho, nomedoc, pdfapp, DocumentSnapshot doc) {
    if (pdfapp != null) {
      String nomepdf = caminho + DateTime.now().toIso8601String() + ".pdf";

      Reference storageReference =
          FirebaseStorage.instance.ref().child(nomepdf);
      // StorageUploadTask uploadTask = storageReference.putFile(pdfapp);
      // uploadTask.onComplete.then((value) {
      //   value.ref.getDownloadURL().then((value) {
      //     doc.reference.update({
      //       'documento': value.toString(),
      //       'nomeArquivo': nomepdf,
      //       'nomedocumento': nomedoc
      //     });
      //   });
      // });
    }
  }

  salvarVideoApp(caminho, videoapp, DocumentSnapshot doc) {
    String nomeImagem = caminho + DateTime.now().toIso8601String();
    Reference storageReference =
        FirebaseStorage.instance.ref().child(nomeImagem);
    // StorageUploadTask uploadTask = storageReference.putFile(videoapp);
    // uploadTask.onComplete.then((value) {
    //   value.ref.getDownloadURL().then((value) {
    //     doc.reference.update({'video': value.toString()});
    //   });
    // });
  }

  Future salvarCuidadoImagem(text) async {
    List<String> listainfoalunos = text.split('---');
    print('listainfoalunos' + listainfoalunos.toString());
    print(listainfoalunos.length);

    listainfoalunos.forEach((alunoindividual) async {
      if (alunoindividual.isNotEmpty &&
          alunoindividual.split('\n').length > 1) {
        String nomealuno, infoaluno;
        nomealuno = alunoindividual
            .split('\n')[1]
            .replaceAll('-', '')
            .replaceAll('_', '')
            .trimRight()
            .trimLeft();
        infoaluno = alunoindividual
            .replaceAll('Y', '')
            .replaceAll('y', '')
            .replaceAll(nomealuno, '')
            .trimRight()
            .trimLeft();
        print('nomeKKKK' + nomealuno + '\n' + infoaluno);
        print(nomealuno + 'foi 1');

        List<DocumentSnapshot> alunodocs = (await FirebaseFirestore.instance
                .collection('${Nomes().alunosbanco}')
                .where('nome', isEqualTo: nomealuno)
                .get())
            .docs;

        if (alunodocs.isNotEmpty &&
            alunodocs[0].exists &&
            infoaluno.isNotEmpty) {
          DocumentSnapshot doc = alunodocs[0];
          String publiid = "${doc.id}${hoje().replaceAll('/', '')}";
          print(nomealuno + 'achou banco');
          await FirebaseFirestore.instance
              .collection(Nomes().publicacoesbanco)
              .doc(publiid)
              .set({
            'createdAt': DateTime.now().toIso8601String(),
            'data': hoje(),
            'turma': '${doc['turma']}',
            'tipo': 'cuidado',
            'nome': '${doc['nome']}',
            'obs': '$infoaluno',
            'para': '${doc.id}',
            'datacomparar': DateTime.now()
          });
        }
      }
    });
  }

  void salvarpublicacaocurso(
      usuario,
      curso,
      unidade,
      tipo,
      mensagem,
      List<Asset> imagem,
      imagemweb,
      pdfapp,
      pdfweb,
      nomepdf,
      videoapp,
      videoweb,
      linkyoutube,
      linkescondidoimagem,
      agendar,
      data,
      hora,
      datacomparar,
      File imageFromCamera) {
    Map<String, dynamic> map = Map();
    map['createdAt'] = DateTime.now().toIso8601String();
    map['data'] = hoje();
    map['datacomparar'] = DateTime.now();
    map['enviar'] = true;
    if (agendar) {
      map['enviar'] = false;
      map['agendado'] = true;
      map['enviardata'] = data;
      map['enviarhora'] = hora;
      map['enviardatacomparar'] = datacomparar;
    }
    map['linkyoutube'] = linkyoutube;
    map['linkescondidoimagem'] = linkescondidoimagem;
    map['mensagem'] = mensagem;
    map['nome'] = curso;
    map['para'] = curso + ' - ' + unidade;
    map['parametrosbusca'] = [curso + ' - ' + unidade, usuario.documentID];
    map['responsavel'] = usuario['nome'];
    map['tipo'] = tipo;
    map['unidade'] = unidade;
    map['curso'] = curso;
    map['enviarnotificacao'] = Pesquisa().replaceforpush(curso + unidade);

    FirebaseFirestore.instance
        .collection(Nomes().publicacoesbanco)
        .add(map)
        .then((document) {
      document.get().then((value) {
        salvarlogousuario(usuario, value);

        if (!agendar) {
          Pesquisa().enviarnotificacao(
            Pesquisa().replaceforpush(curso + unidade),
            (tipo == 'diario')
                ? 'Nova Publicação.'
                : (tipo == 'bilhete')
                    ? 'Novo Informativo.'
                    : (tipo == 'enquete')
                        ? 'Nova enquete.'
                        : 'Novo documento',
          );
        }
      });

      if (imagem != null && imagem.length > 0) {
        document.get().then((value) {
          salvarImagemDiario(
              'FeedPrincipal/$unidade/Fotos/$curso/', imagem, value);
        });
      } else if (imagemweb != null) {
        document.get().then((value) {
          salvarImagensWeb(
              'FeedPrincipal/$unidade/Fotos/$curso/', imagemweb, value);
        });
      }

      if (pdfapp != null) {
        document.get().then((value) {
          salvarPDFAPP(
              'FeedPrincipal/$unidade/PDF/$curso/', nomepdf, pdfapp, value);
        });
      } else if (pdfweb != null) {
        document.get().then((value) {
          salvarpdfweb(
              'FeedPrincipal/$unidade/PDF/$curso/', nomepdf, pdfweb, value);
        });
      }

      if (videoapp != null) {
        document.get().then((value) {
          salvarVideoApp(
              'FeedPrincipal/$unidade/Videos/$curso/', videoapp, value);
        });
      } else if (videoweb != null) {
        document.get().then((value) {
          salvarVideoWebDiario(
              'FeedPrincipal/$unidade/Videos/$curso/', videoweb, value);
        });
      }
      if (imageFromCamera != null) {
        String caminho = 'FeedPrincipal/$unidade/Fotos/$curso/';

        document.get().then(
            (value) => saveImageFromCamera(imageFromCamera, caminho, value));
      }
    });
    Pesquisa().sendAnalyticsEvent(tela: Nomes().pubCursos);
  }

  void salvarpublicacaoaluno(
      usuario,
      DocumentSnapshot aluno,
      moderacao,
      tipo,
      mensagem,
      List<Asset> imagem,
      imagemweb,
      pdfapp,
      pdfweb,
      nomepdf,
      videoapp,
      videoweb,
      linkyoutube,
      linkescondidoimagem,
      agendar,
      data,
      hora,
      datacomparar,
      File imageFromCamera) {
    Map<String, dynamic> map = Map();
    map['createdAt'] = DateTime.now().toIso8601String();
    map['data'] = hoje();
    map['datacomparar'] = DateTime.now();
    if (moderacao && usuario['perfil'] != 'Professor') {
      map['enviar'] = true;
    }
    if (moderacao && usuario['perfil'] == 'Professor') {
      map['enviar'] = false;
    }
    if (!moderacao) {
      map['enviar'] = true;
    }
    if (agendar) {
      map['enviar'] = false;
      map['agendado'] = true;
      map['enviardata'] = data;
      map['enviarhora'] = hora;
      map['enviardatacomparar'] = datacomparar;
    }
    map['linkyoutube'] = linkyoutube;
    map['linkescondidoimagem'] = linkescondidoimagem;
    map['mensagem'] = mensagem;
    map['nome'] = aluno['nome'];
    map['para'] = aluno.id;
    map['parametrosbusca'] = [aluno.id, usuario.id];
    map['responsavel'] = usuario['nome'];
    map['tipo'] = tipo;
    map['turma'] = aluno['turma'];
    map['curso'] = aluno['curso'];
    map['unidade'] = aluno['unidade'];
    if (aluno['tokens'] != null) {
      map['enviarnotificacaotoken'] = List<String>.from(aluno['tokens']);
    }

    FirebaseFirestore.instance
        .collection(Nomes().publicacoesbanco)
        .add(map)
        .then((document) {
      document.get().then((value) {
        salvarlogousuario(usuario, value);

        if (moderacao && usuario['perfil'] == 'Professor') {
        } else if (aluno['tokens'] != null && !agendar) {
          Pesquisa().enviarnotificacaotoken(
            List<String>.from(aluno['tokens']),
            (tipo == 'diario')
                ? 'Nova Publicação.'
                : (tipo == 'bilhete')
                    ? 'Novo Informativo.'
                    : (tipo == 'enquete')
                        ? 'Nova enquete.'
                        : 'Novo documento',
          );
        }
      });

      if (imagem != null && imagem.length > 0) {
        document.get().then((value) {
          salvarImagemDiario(
              'FeedPrincipal/${aluno['unidade']}/Fotos/${aluno['turma']}/${aluno['nome']}',
              imagem,
              value);
        });
      } else if (imagemweb != null) {
        document.get().then((value) {
          salvarImagensWeb(
              'FeedPrincipal/${aluno['unidade']}/Fotos/${aluno['turma']}/${aluno['nome']}',
              imagemweb,
              value);
        });
      }

      if (imageFromCamera != null) {
        String caminho =
            'FeedPrincipal/${aluno['unidade']}/Fotos/${aluno['turma']}/${aluno['nome']}';

        document.get().then(
            (value) => saveImageFromCamera(imageFromCamera, caminho, value));
      }

      if (pdfapp != null) {
        document.get().then((value) {
          salvarPDFAPP(
              'FeedPrincipal/${aluno['unidade']}/PDF/${aluno['turma']}/',
              nomepdf,
              pdfapp,
              value);
        });
      } else if (pdfweb != null) {
        document.get().then((value) {
          salvarpdfweb(
              'FeedPrincipal/${aluno['unidade']}/PDF/${aluno['turma']}/',
              nomepdf,
              pdfweb,
              value);
        });
      }

      if (videoapp != null) {
        document.get().then((value) {
          salvarVideoApp(
              'FeedPrincipal/${aluno['unidade']}/Videos/${aluno['turma']}/',
              videoapp,
              value);
        });
      } else if (videoweb != null) {
        document.get().then((value) {
          salvarVideoWebDiario(
              'FeedPrincipal/${aluno['unidade']}/Videos/${aluno['turma']}/',
              videoweb,
              value);
        });
      }
    });
    Pesquisa().sendAnalyticsEvent(tela: Nomes().pubAluno);
  }

  void salvarhorariounidade(
      usuario, unidade, imagem, imagemweb, pdfapp, pdfweb, titulo) {
    Map<String, dynamic> map = Map();
    map['createdAt'] = DateTime.now().toIso8601String();
    map['data'] = hoje();
    map['titulo'] = titulo;
    map['datacomparar'] = DateTime.now();
    map['para'] = unidade;
    map['parametrosbusca'] = [unidade];
    map['responsavel'] = usuario['nome'];
    map['turma'] = unidade;
    map['unidade'] = unidade;

    FirebaseFirestore.instance
        .collection(Nomes().horariosescola)
        .add(map)
        .then((document) {
      if (imagem != null) {
        document.get().then((value) {
          salvarimagemstorage('Horarios/$unidade/Imagens/', imagem, value);
        });
      } else if (imagemweb != null) {
        document.get().then((value) {
          salvarImagemWeb('Horarios/$unidade/Imagens/', imagemweb, value);
        });
      }

      if (pdfapp != null) {
        document.get().then((value) {
          salvarPDFAPP('Horarios/$unidade/PDF/', 'Horario' + hojesembarra(),
              pdfapp, value);
        });
      } else if (pdfweb != null) {
        document.get().then((value) {
          salvarpdfweb('Horarios/$unidade/PDF/', 'Horario' + hojesembarra(),
              pdfweb, value);
        });
      }
    });
  }

  void salvaravaliacoesunidade(
      usuario, unidade, imagem, imagemweb, pdfapp, pdfweb, titulo) {
    Map<String, dynamic> map = Map();
    map['createdAt'] = DateTime.now().toIso8601String();
    map['data'] = hoje();
    map['datacomparar'] = DateTime.now();
    map['para'] = unidade;
    map['titulo'] = titulo;
    map['parametrosbusca'] = [unidade];
    map['responsavel'] = usuario['nome'];
    map['turma'] = unidade;
    map['unidade'] = unidade;

    FirebaseFirestore.instance
        .collection(Nomes().avaliacoesescola)
        .add(map)
        .then((document) {
      if (imagem != null) {
        document.get().then((value) {
          salvarimagemstorage('Avaliacoes/$unidade/Imagens/', imagem, value);
        });
      } else if (imagemweb != null) {
        document.get().then((value) {
          salvarImagemWeb('Avaliacoes/$unidade/Imagens/', imagemweb, value);
        });
      }

      if (pdfapp != null) {
        document.get().then((value) {
          salvarPDFAPP('Avaliacoes/$unidade/PDF/',
              'Avaliacoes' + hojesembarra(), pdfapp, value);
        });
      } else if (pdfweb != null) {
        document.get().then((value) {
          salvarpdfweb('Avaliacoes/$unidade/PDF/',
              'Avaliacoes' + hojesembarra(), pdfweb, value);
        });
      }
    });
  }

  void salvarcardapioounidade(
      usuario, unidade, imagem, imagemweb, pdfapp, pdfweb, titulo) {
    Map<String, dynamic> map = Map();
    map['createdAt'] = DateTime.now().toIso8601String();
    map['data'] = hoje();
    map['titulo'] = titulo;
    map['datacomparar'] = DateTime.now();
    map['para'] = unidade;
    map['parametrosbusca'] = [unidade];
    map['responsavel'] = usuario['nome'];
    map['turma'] = unidade;
    map['unidade'] = unidade;

    FirebaseFirestore.instance
        .collection(Nomes().cardapiobanco)
        .add(map)
        .then((document) {
      enviarnotificacao(
          Pesquisa().replaceforpush(unidade), 'Novo cardápio adicionado');

      if (imagem != null) {
        document.get().then((value) {
          salvarimagemstorage('Cardapios/$unidade/Imagens/', imagem, value);
        });
      } else if (imagemweb != null) {
        document.get().then((value) {
          salvarImagemWeb('Cardapios/$unidade/Imagens/', imagemweb, value);
        });
      }

      if (pdfapp != null) {
        document.get().then((value) {
          salvarPDFAPP('Cardapios/$unidade/PDF/', 'Cardapio' + hojesembarra(),
              pdfapp, value);
        });
      } else if (pdfweb != null) {
        document.get().then((value) {
          salvarpdfweb('Cardapios/$unidade/PDF/', 'Cardapio' + hojesembarra(),
              pdfweb, value);
        });
      }
    });
  }

  void salvarhorariocurso(
      usuario, unidade, curso, imagem, imagemweb, pdfapp, pdfweb, titulo) {
    Map<String, dynamic> map = Map();
    map['createdAt'] = DateTime.now().toIso8601String();
    map['data'] = hoje();
    map['titulo'] = titulo;
    map['datacomparar'] = DateTime.now();
    map['para'] = curso + ' - ' + unidade;
    map['parametrosbusca'] = [curso + ' - ' + unidade];
    map['responsavel'] = usuario['nome'];
    map['turma'] = unidade;
    map['unidade'] = unidade;

    FirebaseFirestore.instance
        .collection(Nomes().horariosescola)
        .add(map)
        .then((document) {
      if (imagem != null) {
        document.get().then((value) {
          salvarimagemstorage(
              'Horarios/$unidade/Imagens/$curso', imagem, value);
        });
      } else if (imagemweb != null) {
        document.get().then((value) {
          salvarImagemWeb('Horarios/$unidade/Imagens/$curso', imagemweb, value);
        });
      }

      if (pdfapp != null) {
        document.get().then((value) {
          salvarPDFAPP('Horarios/$unidade/PDF/$curso',
              'Horario' + hojesembarra(), pdfapp, value);
        });
      } else if (pdfweb != null) {
        document.get().then((value) {
          salvarpdfweb('Horarios/$unidade/PDF/$curso',
              'Horario' + hojesembarra(), pdfweb, value);
        });
      }
    });
  }

  void salvaravaliacoescurso(
      usuario, unidade, curso, imagem, imagemweb, pdfapp, pdfweb, titulo) {
    Map<String, dynamic> map = Map();
    map['createdAt'] = DateTime.now().toIso8601String();
    map['data'] = hoje();
    map['titulo'] = titulo;
    map['datacomparar'] = DateTime.now();
    map['para'] = curso + ' - ' + unidade;
    map['parametrosbusca'] = [curso + ' - ' + unidade];
    map['responsavel'] = usuario['nome'];
    map['turma'] = unidade;
    map['unidade'] = unidade;

    FirebaseFirestore.instance
        .collection(Nomes().avaliacoesescola)
        .add(map)
        .then((document) {
      if (imagem != null) {
        document.get().then((value) {
          salvarimagemstorage(
              'Avaliacoes/$unidade/Imagens/$curso', imagem, value);
        });
      } else if (imagemweb != null) {
        document.get().then((value) {
          salvarImagemWeb(
              'Avaliacoes/$unidade/Imagens/$curso', imagemweb, value);
        });
      }

      if (pdfapp != null) {
        document.get().then((value) {
          salvarPDFAPP('Avaliacoes/$unidade/PDF/$curso',
              'Avaliacoes' + hojesembarra(), pdfapp, value);
        });
      } else if (pdfweb != null) {
        document.get().then((value) {
          salvarpdfweb('Avaliacoes/$unidade/PDF/$curso',
              'Avaliacoes' + hojesembarra(), pdfweb, value);
        });
      }
    });
  }

  void salvarcardapiocurso(
      usuario, unidade, curso, imagem, imagemweb, pdfapp, pdfweb, titulo) {
    Map<String, dynamic> map = Map();
    map['createdAt'] = DateTime.now().toIso8601String();
    map['data'] = hoje();
    map['titulo'] = titulo;
    map['datacomparar'] = DateTime.now();
    map['para'] = curso + ' - ' + unidade;
    map['parametrosbusca'] = [curso + ' - ' + unidade];
    map['responsavel'] = usuario['nome'];
    map['turma'] = unidade;
    map['unidade'] = unidade;

    FirebaseFirestore.instance
        .collection(Nomes().cardapiobanco)
        .add(map)
        .then((document) {
      enviarnotificacao(Pesquisa().replaceforpush(curso + unidade),
          'Novo cardápio adicionado');
      if (imagem != null) {
        document.get().then((value) {
          salvarimagemstorage(
              'Cardapios/$unidade/Imagens/$curso', imagem, value);
        });
      } else if (imagemweb != null) {
        document.get().then((value) {
          salvarImagemWeb(
              'Cardapios/$unidade/Imagens/$curso', imagemweb, value);
        });
      }

      if (pdfapp != null) {
        document.get().then((value) {
          salvarPDFAPP('Cardapios/$unidade/PDF/$curso',
              'Cardapio' + hojesembarra(), pdfapp, value);
        });
      } else if (pdfweb != null) {
        document.get().then((value) {
          salvarpdfweb('Cardapios/$unidade/PDF/$curso',
              'Cardapio' + hojesembarra(), pdfweb, value);
        });
      }
    });
  }

  void salvarpublicacaounidade(
      usuario,
      unidade,
      tipo,
      mensagem,
      List<Asset> imagem,
      imagemweb,
      pdfapp,
      pdfweb,
      nomepdf,
      videoapp,
      videoweb,
      linkyoutube,
      linkescondidoimagem,
      agendar,
      data,
      hora,
      datacomparar,
      File imageFromCamera) {
    Map<String, dynamic> map = Map();
    map['createdAt'] = DateTime.now().toIso8601String();
    map['data'] = hoje();
    map['datacomparar'] = DateTime.now();
    map['enviar'] = true;
    if (agendar) {
      map['enviar'] = false;
      map['agendado'] = true;
      map['enviardata'] = data;
      map['enviarhora'] = hora;
      map['enviardatacomparar'] = datacomparar;
    }
    map['linkyoutube'] = linkyoutube;
    map['linkescondidoimagem'] = linkescondidoimagem;
    map['mensagem'] = mensagem;
    map['nome'] = unidade;
    map['para'] = unidade;
    map['parametrosbusca'] = [unidade, usuario.documentID];
    map['responsavel'] = usuario['nome'];
    map['tipo'] = tipo;
    map['turma'] = unidade;
    map['unidade'] = unidade;
    map['enviarnotificacao'] = (unidade == 'Todas')
        ? Pesquisa().replaceforpush(Nomes().push)
        : Pesquisa().replaceforpush(unidade);

    FirebaseFirestore.instance
        .collection(Nomes().publicacoesbanco)
        .add(map)
        .then((document) {
      if (unidade != 'Todas') {
        document.get().then((value) {
          salvarlogounidade(unidade, value);
          if (!agendar) {
            Pesquisa().enviarnotificacao(
              (unidade == 'Todas')
                  ? Pesquisa().replaceforpush(Nomes().push)
                  : Pesquisa().replaceforpush(unidade),
              (tipo == 'diario')
                  ? 'Nova Publicação.'
                  : (tipo == 'bilhete')
                      ? 'Novo Informativo.'
                      : (tipo == 'enquete')
                          ? 'Nova enquete.'
                          : 'Novo documento',
            );
          }
        });
      }
      if (imagem != null && imagem.length > 0) {
        document.get().then((value) {
          salvarImagemDiario('FeedPrincipal/$unidade/Fotos/', imagem, value);
        });
      } else if (imagemweb != null) {
        document.get().then((value) {
          salvarImagensWeb('FeedPrincipal/$unidade/Fotos/', imagemweb, value);
        });
      }

      if (pdfapp != null) {
        document.get().then((value) {
          salvarPDFAPP('FeedPrincipal/$unidade/PDF/', nomepdf, pdfapp, value);
        });
      } else if (pdfweb != null) {
        document.get().then((value) {
          salvarpdfweb('FeedPrincipal/$unidade/PDF/', nomepdf, pdfweb, value);
        });
      }

      if (videoapp != null) {
        document.get().then((value) {
          salvarVideoApp('FeedPrincipal/$unidade/Videos/', videoapp, value);
        });
      } else if (videoweb != null) {
        document.get().then((value) {
          salvarVideoWebDiario(
              'FeedPrincipal/$unidade/Videos/', videoweb, value);
        });
      }

      if (imageFromCamera != null) {
        String caminho = 'FeedPrincipal/$unidade/Fotos/';
        document.get().then(
            (value) => saveImageFromCamera(imageFromCamera, caminho, value));
      }
    });
    Pesquisa().sendAnalyticsEvent(tela: Nomes().pubUnidade);
  }

  void salvarpublicacaounidades(
      usuario,
      tipo,
      mensagem,
      List<Asset> imagem,
      imagemweb,
      pdfapp,
      pdfweb,
      nomepdf,
      videoapp,
      videoweb,
      linkyoutube,
      linkescondidoimagem,
      agendar,
      data,
      hora,
      datacomparar,
      File imageFromCamera,
      {required List indexturmas,
      required List unidadesSelecionadas}) {
    for (int i = 0; i < indexturmas.length; i++) {
      Map<String, dynamic> map = Map();
      map['createdAt'] = DateTime.now().toIso8601String();
      map['data'] = hoje();
      map['datacomparar'] = DateTime.now();
      map['enviar'] = true;
      if (agendar) {
        map['enviar'] = false;
        map['agendado'] = true;
        map['enviardata'] = data;
        map['enviarhora'] = hora;
        map['enviardatacomparar'] = datacomparar;
      }
      map['linkyoutube'] = linkyoutube;
      map['linkescondidoimagem'] = linkescondidoimagem;
      map['mensagem'] = mensagem;
      map['nome'] = unidadesSelecionadas[indexturmas[i]];
      map['para'] = unidadesSelecionadas[indexturmas[i]];
      map['parametrosbusca'] = [
        unidadesSelecionadas[indexturmas[i]],
        usuario.documentID
      ];
      map['responsavel'] = usuario['nome'];
      map['tipo'] = tipo;
      map['turma'] = unidadesSelecionadas[indexturmas[i]];
      map['unidade'] = unidadesSelecionadas[indexturmas[i]];
      map['enviarnotificacao'] =
          Pesquisa().replaceforpush(unidadesSelecionadas[indexturmas[i]]);

      FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .add(map)
          .then((document) {
        if (!agendar) {
          Pesquisa().enviarnotificacao(
            Pesquisa().replaceforpush(unidadesSelecionadas[indexturmas[i]]),
            (tipo == 'diario')
                ? 'Nova Publicação.'
                : (tipo == 'bilhete')
                    ? 'Novo Informativo.'
                    : (tipo == 'enquete')
                        ? 'Nova enquete.'
                        : 'Novo documento',
          );
        }
        if (unidadesSelecionadas[indexturmas[i]] != 'Todas') {
          document.get().then((value) {
            salvarlogounidade(unidadesSelecionadas[indexturmas[i]], value);
          });
        }

        if (imagem != null && imagem.length > 0) {
          document.get().then((value) {
            salvarImagemDiario(
                'FeedPrincipal/${unidadesSelecionadas[indexturmas[i]]}/Fotos/',
                imagem,
                value);
          });
        } else if (imagemweb != null) {
          document.get().then((value) {
            salvarImagensWeb(
                'FeedPrincipal/${unidadesSelecionadas[indexturmas[i]]}/Fotos/',
                imagemweb,
                value);
          });
        }

        if (pdfapp != null) {
          document.get().then((value) {
            salvarPDFAPP(
                'FeedPrincipal/${unidadesSelecionadas[indexturmas[i]]}/PDF/',
                nomepdf,
                pdfapp,
                value);
          });
        } else if (pdfweb != null) {
          document.get().then((value) {
            salvarpdfweb(
                'FeedPrincipal/${unidadesSelecionadas[indexturmas[i]]}/PDF/',
                nomepdf,
                pdfweb,
                value);
          });
        }

        if (videoapp != null) {
          document.get().then((value) {
            salvarVideoApp(
                'FeedPrincipal/${unidadesSelecionadas[indexturmas[i]]}/Videos/',
                videoapp,
                value);
          });
        } else if (videoweb != null) {
          document.get().then((value) {
            salvarVideoWebDiario(
                'FeedPrincipal/${unidadesSelecionadas[indexturmas[i]]}/Videos/',
                videoweb,
                value);
          });
        }

        if (imageFromCamera != null) {
          String caminho =
              'FeedPrincipal/${unidadesSelecionadas[indexturmas[i]]}/Fotos/';

          document.get().then(
              (value) => saveImageFromCamera(imageFromCamera, caminho, value));
        }
      });
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().pubUnidades);
  }

  void salvardownloadsunidades(map, pdfapp, pdfweb,
      {required List indexturmas, required List unidades}) {
    for (int i = 0; i < indexturmas.length; i++) {
      map['parametrosbusca'] = [unidades[indexturmas[i]]];
      map['unidade'] = unidades[indexturmas[i]];

      FirebaseFirestore.instance
          .collection(Nomes().downloadsbanco)
          .add(map)
          .then((document) {
        if (pdfapp != null) {
          document.get().then((value) {
            salvarPDFAPP('Downloads/${unidades[indexturmas[i]]}/', map['nome'],
                pdfapp, value);
          });
        } else if (pdfweb != null) {
          document.get().then((value) {
            salvarpdfweb('Downloads/${unidades[indexturmas[i]]}/', map['nome'],
                pdfweb, value);
          });
        }
      });
    }
  }

  void salvardownloadsturmas(map, pdfapp, pdfweb,
      {required List indexturmas, required List turmas}) {
    for (int i = 0; i < indexturmas.length; i++) {
      map['parametrosbusca'] = [
        turmas[indexturmas[i]] + ' - ' + map['unidade']
      ];
      FirebaseFirestore.instance
          .collection(Nomes().downloadsbanco)
          .add(map)
          .then((document) {
        if (pdfapp != null) {
          document.get().then((value) {
            salvarPDFAPP(
                'Downloads/${map['unidade']}/${turmas[indexturmas[i]]}/',
                map['nome'],
                pdfapp,
                value);
          });
        } else if (pdfweb != null) {
          document.get().then((value) {
            salvarpdfweb(
                'Downloads/${map['unidade']}/${turmas[indexturmas[i]]}/',
                map['nome'],
                pdfweb,
                value);
          });
        }
      });
    }
  }

  void salvardownloadslinksunidades(map, {required List indexunidade, required List unidades}) {
    for (int i = 0; i < indexunidade.length; i++) {
      map['parametrosbusca'] = [unidades[indexunidade[i]]];
      map['unidade'] = unidades[indexunidade[i]];
      FirebaseFirestore.instance.collection(Nomes().downloadsbanco).add(map);
    }
  }

  void salvardownloadslinksturmas(map, {required List indexturmas, required List turmas}) {
    for (int i = 0; i < indexturmas.length; i++) {
      map['parametrosbusca'] = [
        turmas[indexturmas[i]] + ' - ' + map['unidade']
      ];
      FirebaseFirestore.instance.collection(Nomes().downloadsbanco).add(map);
    }
  }

  void salvarcalendariounidades(map,
      {required List indexturmas, required List unidadesSelecionadas}) {
    for (int i = 0; i < indexturmas.length; i++) {
      map['parametrosbusca'] = [unidadesSelecionadas[indexturmas[i]]];

      FirebaseFirestore.instance.collection(Nomes().calendariobanco).add(map);
      Pesquisa().enviarnotificacao(
          Pesquisa().replaceforpush(unidadesSelecionadas[indexturmas[i]]),
          'Novo envento adicionado - ${map['data']}');
    }
  }

  void salvarcalendarioturmas(map, unidade,
      {required List indexturmas, required List turmasSelecionadas}) {
    for (int i = 0; i < indexturmas.length; i++) {
      map['parametrosbusca'] = [
        turmasSelecionadas[indexturmas[i]] + " - " + unidade
      ];
      FirebaseFirestore.instance.collection(Nomes().calendariobanco).add(map);
      Pesquisa().enviarnotificacao(
          Pesquisa()
              .replaceforpush(turmasSelecionadas[indexturmas[i]] + unidade),
          'Novo envento adicionado - ${map['data'].text}');
    }
  }

  void salvarpublicacaoturmas(
      usuario,
      unidade,
      curso,
      moderacao,
      tipo,
      mensagem,
      List<Asset> imagem,
      imagemweb,
      pdfapp,
      pdfweb,
      nomepdf,
      videoapp,
      videoweb,
      linkyoutube,
      linkescondidoimagem,
      agendar,
      data,
      hora,
      datacomparar,
      File imageFromCamera,
      {required List indexturmas,
      required List turmasSelecionadas}) {
    for (int i = 0; i < indexturmas.length; i++) {
      Map<String, dynamic> map = Map();
      map['createdAt'] = DateTime.now().toIso8601String();
      map['data'] = hoje();

      map['datacomparar'] = DateTime.now();
      if (moderacao && usuario['perfil'] != 'Professor') {
        map['enviar'] = true;
      }
      if (moderacao && usuario['perfil'] == 'Professor') {
        map['enviar'] = false;
      }
      if (!moderacao) {
        map['enviar'] = true;
      }
      if (agendar) {
        map['enviar'] = false;
        map['agendado'] = true;
        map['enviardata'] = data;
        map['enviarhora'] = hora;
        map['enviardatacomparar'] = datacomparar;
      }
      map['linkyoutube'] = linkyoutube;
      map['linkescondidoimagem'] = linkescondidoimagem;
      map['mensagem'] = mensagem;
      map['nome'] = turmasSelecionadas[indexturmas[i]];
      map['para'] = turmasSelecionadas[indexturmas[i]];
      map['parametrosbusca'] = [
        turmasSelecionadas[indexturmas[i]] + ' - ' + unidade,
        usuario.documentID
      ];
      map['responsavel'] = usuario['nome'];
      map['tipo'] = tipo;
      map['turma'] = turmasSelecionadas[indexturmas[i]];
      map['unidade'] = unidade;
      map['curso'] = curso;
      map['enviarnotificacao'] = Pesquisa()
          .replaceforpush(turmasSelecionadas[indexturmas[i]] + unidade);
      FirebaseFirestore.instance
          .collection(Nomes().publicacoesbanco)
          .add(map)
          .then((document) {
        if (moderacao && usuario['perfil'] == 'Professor') {
        } else if (!agendar) {
          Pesquisa().enviarnotificacao(
            Pesquisa()
                .replaceforpush(turmasSelecionadas[indexturmas[i]] + unidade),
            (tipo == 'diario')
                ? 'Nova Publicação.'
                : (tipo == 'bilhete')
                    ? 'Novo Informativo.'
                    : (tipo == 'enquete')
                        ? 'Nova enquete.'
                        : 'Novo documento',
          );
        }
        document.get().then((value) {
          salvarlogousuario(usuario, value);
        });

        if (imagem != null && imagem.length > 0) {
          document.get().then((value) {
            salvarImagemDiario(
                'FeedPrincipal/$unidade/Fotos/${turmasSelecionadas[indexturmas[i]]}/',
                imagem,
                value);
          });
        } else if (imagemweb != null) {
          document.get().then((value) {
            salvarImagensWeb(
                'FeedPrincipal/$unidade/Fotos/${turmasSelecionadas[indexturmas[i]]}/',
                imagemweb,
                value);
          });
        }

        if (imageFromCamera != null) {
          String caminho =
              'FeedPrincipal/$unidade/Fotos/${turmasSelecionadas[indexturmas[i]]}/';

          document.get().then(
              (value) => saveImageFromCamera(imageFromCamera, caminho, value));
        }

        if (pdfapp != null) {
          document.get().then((value) {
            salvarPDFAPP(
                'FeedPrincipal/$unidade/PDF/${turmasSelecionadas[indexturmas[i]]}/',
                nomepdf,
                pdfapp,
                value);
          });
        } else if (pdfweb != null) {
          document.get().then((value) {
            salvarpdfweb(
                'FeedPrincipal/$unidade/PDF/${turmasSelecionadas[indexturmas[i]]}/',
                nomepdf,
                pdfweb,
                value);
          });
        }

        if (videoapp != null) {
          document.get().then((value) {
            salvarVideoApp(
                'FeedPrincipal/$unidade/Videos/${turmasSelecionadas[indexturmas[i]]}/',
                videoapp,
                value);
          });
        } else if (videoweb != null) {
          document.get().then((value) {
            salvarVideoWebDiario(
                'FeedPrincipal/$unidade/Videos/${turmasSelecionadas[indexturmas[i]]}/',
                videoweb,
                value);
          });
        }
      });
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().pubTurmas);
  }

  void salvarhorarioturmas(
      usuario, unidade, imagem, imagemweb, pdfapp, pdfweb, titulo,
      {required List indexturmas, required List turmasSelecionadas}) {
    for (int i = 0; i < indexturmas.length; i++) {
      Map<String, dynamic> map = Map();
      map['createdAt'] = DateTime.now().toIso8601String();
      map['data'] = hoje();
      map['titulo'] = titulo;
      map['datacomparar'] = DateTime.now();
      map['para'] = turmasSelecionadas[indexturmas[i]];
      map['parametrosbusca'] = [
        turmasSelecionadas[indexturmas[i]] + ' - ' + unidade
      ];
      map['responsavel'] = usuario['nome'];
      map['turma'] = turmasSelecionadas[indexturmas[i]];
      map['unidade'] = unidade;

      FirebaseFirestore.instance
          .collection(Nomes().horariosescola)
          .add(map)
          .then((document) {
        if (imagem != null) {
          document.get().then((value) {
            salvarImagemDiario(
                'Horarios/$unidade/Imagens/${turmasSelecionadas[indexturmas[i]]}/',
                imagem,
                value);
          });
        } else if (imagemweb != null) {
          document.get().then((value) {
            salvarImagemWeb(
                'Horarios/$unidade/Imagens/${turmasSelecionadas[indexturmas[i]]}/',
                imagemweb,
                value);
          });
        }

        if (pdfapp != null) {
          document.get().then((value) {
            salvarPDFAPP(
                'Horarios/$unidade/PDF/${turmasSelecionadas[indexturmas[i]]}/',
                'Horario' + hojesembarra(),
                pdfapp,
                value);
          });
        } else if (pdfweb != null) {
          document.get().then((value) {
            salvarpdfweb(
                'Horarios/$unidade/PDF/${turmasSelecionadas[indexturmas[i]]}/',
                'Horario' + hojesembarra(),
                pdfweb,
                value);
          });
        }
      });
    }
  }

  void salvaravaliacoesturmas(
      usuario, unidade, imagem, imagemweb, pdfapp, pdfweb, titulo,
      {required List indexturmas, required List turmasSelecionadas}) {
    for (int i = 0; i < indexturmas.length; i++) {
      Map<String, dynamic> map = Map();
      map['createdAt'] = DateTime.now().toIso8601String();
      map['data'] = hoje();
      map['titulo'] = titulo;
      map['datacomparar'] = DateTime.now();
      map['para'] = turmasSelecionadas[indexturmas[i]];
      map['parametrosbusca'] = [
        turmasSelecionadas[indexturmas[i]] + ' - ' + unidade
      ];
      map['responsavel'] = usuario['nome'];
      map['turma'] = turmasSelecionadas[indexturmas[i]];
      map['unidade'] = unidade;

      FirebaseFirestore.instance
          .collection(Nomes().avaliacoesescola)
          .add(map)
          .then((document) {
        if (imagem != null) {
          document.get().then((value) {
            salvarImagemDiario(
                'Avaliacoes/$unidade/Imagens/${turmasSelecionadas[indexturmas[i]]}/',
                imagem,
                value);
          });
        } else if (imagemweb != null) {
          document.get().then((value) {
            salvarImagemWeb(
                'Avaliacoes/$unidade/Imagens/${turmasSelecionadas[indexturmas[i]]}/',
                imagemweb,
                value);
          });
        }

        if (pdfapp != null) {
          document.get().then((value) {
            salvarPDFAPP(
                'Avaliacoes/$unidade/PDF/${turmasSelecionadas[indexturmas[i]]}/',
                'Avaliacoes' + hojesembarra(),
                pdfapp,
                value);
          });
        } else if (pdfweb != null) {
          document.get().then((value) {
            salvarpdfweb(
                'Avaliacoes/$unidade/PDF/${turmasSelecionadas[indexturmas[i]]}/',
                'Avaliacoes' + hojesembarra(),
                pdfweb,
                value);
          });
        }
      });
    }
  }

  void salvarcardapioturmas(
      usuario, unidade, imagem, imagemweb, pdfapp, pdfweb, titulo,
      {required List indexturmas, required List turmasSelecionadas}) {
    for (int i = 0; i < indexturmas.length; i++) {
      Map<String, dynamic> map = Map();
      map['createdAt'] = DateTime.now().toIso8601String();
      map['data'] = hoje();
      map['titulo'] = titulo;
      map['datacomparar'] = DateTime.now();
      map['para'] = turmasSelecionadas[indexturmas[i]];
      map['parametrosbusca'] = [
        turmasSelecionadas[indexturmas[i]] + ' - ' + unidade
      ];
      map['responsavel'] = usuario['nome'];
      map['turma'] = turmasSelecionadas[indexturmas[i]];
      map['unidade'] = unidade;

      FirebaseFirestore.instance
          .collection(Nomes().cardapiobanco)
          .add(map)
          .then((document) {
        enviarnotificacao(
            Pesquisa()
                .replaceforpush(turmasSelecionadas[indexturmas[i]] + unidade),
            'Novo cardápio adicionado');
        if (imagem != null) {
          document.get().then((value) {
            salvarImagemDiario(
                'Cardapios/$unidade/Imagens/${turmasSelecionadas[indexturmas[i]]}/',
                imagem,
                value);
          });
        } else if (imagemweb != null) {
          document.get().then((value) {
            salvarImagemWeb(
                'Cardapios/$unidade/Imagens/${turmasSelecionadas[indexturmas[i]]}/',
                imagemweb,
                value);
          });
        }

        if (pdfapp != null) {
          document.get().then((value) {
            salvarPDFAPP(
                'Cardapios/$unidade/PDF/${turmasSelecionadas[indexturmas[i]]}/',
                'Cardapios' + hojesembarra(),
                pdfapp,
                value);
          });
        } else if (pdfweb != null) {
          document.get().then((value) {
            salvarpdfweb(
                'Cardapios/$unidade/PDF/${turmasSelecionadas[indexturmas[i]]}/',
                'Cardapios' + hojesembarra(),
                pdfweb,
                value);
          });
        }
      });
    }
  }

  salvarlogounidade(unidade, DocumentSnapshot doc) {
    if (unidade != 'Todas') {
      FirebaseFirestore.instance
          .collection(Nomes().unidadebanco)
          .doc(unidade)
          .get()
          .then((value) {
        if (value['logomenu'] != null) {
          doc.reference.update({'logo': value['logomenu']});
        }
      });
    }
  }

  salvarlogousuario(DocumentSnapshot usuario, DocumentSnapshot doc) {
    if (usuario['foto'] != null) {
      doc.reference.update({'logo': usuario['foto']});
    }
  }

  salvarPerfil(usuario, nome, turma, perfil, horainicio, horafim, moderacao,
      moderador, sede, sedest, context) {
    Map<String, dynamic> map = Map();
    map['perfil'] = perfil;
    map['turma'] = turma;
    map['nome'] = nome;
    map['horainicio'] = horainicio;
    map['horafim'] = horafim;
    if (moderacao) {
      map['moderador'] = moderador;
    }
    if (sede) {
      map['sede'] = sedest;
    }
    FirebaseFirestore.instance
        .collection(Nomes().usersbanco)
        .doc(usuario.documentID)
        .update(map)
        .then((data) {
      Layout().dialog1botao(
          context, "Salvo", "As informações do usuário foram atualizadas");
    });
  }

  abrirportalweb(tipo, alunodoc, usuariodoc, unidade, context) async {
    String codigoenviar='', dataenviar='', unidadeenviar='', linkinicial='';
    RC4 rc4 = new RC4('cdx2801tb75');
    RC4 rc4data = new RC4('cdx2801tb75');
    RC4 rc4unidade = new RC4('cdx2801tb75');

    if (tipo == 'Aluno' && alunodoc != null) {
      codigoenviar = rc4.encodeString(alunodoc['codigo']);
      dataenviar = rc4data.encodeString(Pesquisa().hojesembarra());
      unidadeenviar = rc4unidade.encodeString(alunodoc['unidade']);
    }
    if (tipo == 'Professor' && usuariodoc != null) {
      codigoenviar = rc4.encodeString(usuariodoc['codigo']);
      dataenviar = rc4data.encodeString(Pesquisa().hojesembarra());
      unidadeenviar = rc4unidade.encodeString(unidade);
    }

    FirebaseFirestore.instance
        .collection(Nomes().unidadebanco)
        .doc(unidade)
        .get()
        .then((value) async {
      if (tipo == "Aluno") {
        linkinicial = value['linkportalaluno'];
      }
      if (tipo == "Professor") {
        linkinicial = value['linkportalprofessor'];
      }
      var url = '$linkinicial?c=$codigoenviar&d=$dataenviar&u=$unidadeenviar';

      if (await canLaunch(url) != null) {
        await launch(url);
      } else {
        Toast.show('Não conseguimos abrir a página.', textStyle: context);
        throw 'Não conseguimos abrir a página.';
      }
    });
  }

  excluiruser(userid) {
    Map<String, Object> map = Map();
    map['userid'] = userid;

    FirebaseFunctions.instance
        .httpsCallable("deleteUser")
        .call(map);
  }

  adicionarusuario(map) {
    FirebaseFunctions.instance
        .httpsCallable("addFuncionariosControle")
        .call(map)
        .then((value) {});
  }

  void enviaremailsenha(email, unidade) {
    FirebaseFunctions.instance
        .httpsCallable('enviarEmailSenha')
        .call({
      'destinatario': email.toString().trim(),
    }).then((value) {
      print("${value.data}");
    }).catchError((error) => print("${error.toString()}"));
  }

  abrirsite(link) async {
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      throw 'Não conseguimos abrir $link';
    }
  }

  salvarTurma(turma, professora, sede, context) {
    Map<String, dynamic> map = Map();
    map['turma'] = turma;
    if (sede != null) {
      map['sede'] = sede;
    }
    map['professora'] = professora;
    map['data'] = hoje();
    map['createdAt'] = DateTime.now().toIso8601String();
    map['datacomparar'] = DateTime.now();
    FirebaseFirestore.instance.collection(Nomes().turmabanco).add(map).then((document) {
      Navigator.pop(context);
    });
  }

  salvarrespostaenquete(
      alterar, usuario, DocumentSnapshot aluno, document, resposta, context) {
    if (!alterar) {
      document.reference.updateData({
        "respostas": FieldValue.arrayUnion([usuario.documentID])
      });

      Map<String, dynamic> map = Map();
      map['data'] = hoje();
      map['usuario'] = usuario.documentID;
      map['nome'] = usuario['nome'];
      map['enquete'] = document.documentID;
      map['resposta'] = resposta;
      if (aluno != null) {
        map['parentesco'] = usuario['parentesco'];
        map['aluno'] = aluno.id;
        map['nomealuno'] = aluno['nomealuno'];
        map['unidade'] = aluno['unidade'];
        map['turma'] = aluno['turma'];
        map['curso'] = aluno['curso'];
      } else {
        map['unidade'] = usuario['unidade'];
        map['perfil'] = usuario['perfil'];
      }
      map['createdAt'] = DateTime.now().toIso8601String();
      map['datacomparar'] = DateTime.now();
      FirebaseFirestore.instance
          .collection(Nomes().respostasenquetes)
          .doc(document.documentID + usuario.documentID)
          .set(map)
          .then((document) {
        Layout()
            .dialog1botao(context, "Salvo", "Agradecemos pela sua resposta.");
      });
      Pesquisa().sendAnalyticsEvent(tela: Nomes().enqueteResposta);
    } else {
      Map<String, dynamic> map = Map();
      map['data'] = hoje();
      map['resposta'] = resposta;
      map['datacomparar'] = DateTime.now();
      FirebaseFirestore.instance
          .collection(Nomes().respostasenquetes)
          .doc(document.documentID + usuario.documentID)
          .update(map)
          .then((document) {
        Layout().dialog1botao(context, "Editada", "Sua resposta foi editada.");
      });
    }
  }

  salvar(map, collection, context) {
    map['data'] = hoje();
    map['createdAt'] = DateTime.now().toIso8601String();
    map['datacomparar'] = DateTime.now();
    FirebaseFirestore.instance.collection(collection).add(map);
  }

  atualizar(map, collection, DocumentSnapshot doc, context) {
    FirebaseFirestore.instance
        .collection(collection)
        .doc(doc.id)
        .update(map);
  }

  substituirpara(destino, context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destino),
    );
  }

  irpara(destino, context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destino),
    );
  }

  salvarAlunoDetalhe(alunodoc, imagem, imagemweb, context) async {
    print(imagemweb);
    if (imagem != null) {
      String nomeImagem = "Alunos/" +
          alunodoc['unidade'] +
          '/' +
          alunodoc['turma'] +
          '/' +
          alunodoc['nome'] +
          ".jpg";

      Reference storageReference =
          FirebaseStorage.instance.ref().child(nomeImagem);
      // StorageUploadTask uploadTask = storageReference.putFile(imagem);
      // uploadTask.onComplete.then((value) {
      //   value.ref.getDownloadURL().then((value) {
      //     FirebaseFirestore.instance
      //         .collection(Nomes().alunosbanco)
      //         .doc(alunodoc.documentID)
      //         .update({"storageref": nomeImagem, "foto": value.toString()});
      //   });
      // });
    } else if (imagemweb != null) {
      String nomearquivo =
          "Alunos/${alunodoc['unidade']}/${alunodoc['turma']}/${alunodoc['nome']}.jpg";
      Uri imageUri = await salvarfileweb(nomearquivo, imagemweb);

      FirebaseFirestore.instance
          .collection(Nomes().alunosbanco)
          .doc(alunodoc.documentID)
          .update({"storageref": nomearquivo, "foto": imageUri.toString()});
    }
  }

  salvarimagemstorage(caminho, imagem, doc) {
    String nomeImagem = caminho + ".jpg";

    Reference storageReference =
        FirebaseStorage.instance.ref().child(nomeImagem);
    // StorageUploadTask uploadTask = storageReference.putFile(imagem);
    // uploadTask.onComplete.then((value) {
    //   value.ref.getDownloadURL().then((value) {
    //     doc.reference
    //         .update({"storageref": nomeImagem, "imagem": value.toString()});
    //   });
    // });
  }

  findPostsWithMoreThanOnePic() {
    List<String> docArray = [];
    FirebaseFirestore.instance
        .collection(Nomes().publicacoesbanco)
        .orderBy('fotos')
        .get()
        .then((query) => query.docs.forEach((doc) {
              if (doc['fotos'].length > 1) {
                docArray.add(doc.id);
              }
            }))
        .then((value) => print(docArray.toString()));
  }

  addNewFieldParaArray() {
    DateTime today = DateTime(2022, 03, 25, 8, 30);
    print(today.toIso8601String());
    FirebaseFirestore.instance
        .collection(Nomes().mensagensbanco)
        .where('datacomparar', isGreaterThanOrEqualTo: today)
        .get()
        .then((query) {
      query.docs.forEach((doc) {
        if (doc['tipo'] != null) {
          String tipo = doc['tipo'];
          doc.reference.update({
            'paraArray': FieldValue.arrayUnion([tipo])
          });
        }
      });
    });
  }

  streamBuilderQuerySnapshot({stream, layout}) {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                return Center(
                    child: Text(
                        'Isto é um erro. Por gentileza, contate a administração.'));
              }
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Container();
                default:
                  // return (snapshot.data!.docs.length >= 1)
                      // ? ListView(
                      //     children: snapshot.data!.docs.map((doc) {
                      //       switch (layout) {
                      //         case 'itemPai':
                      //           return Layout()
                      //               .itempai('', doc, '', '', context);
                      //           break;
                      //       }
                      //     }).toList(),
                      //   )
                      // :
                  return Container();
              }
            }));
  }

  apagarPublicacoes(unidade) {
    FirebaseFirestore.instance
        .collection(Nomes().publicacoesbanco)
        .where('unidade', isEqualTo: unidade)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        element.reference.delete();
      });
    });
  }

  deletarstorage(url) async {
    if (kIsWeb) {
    await fb.storage().refFromURL(url).delete();
    } else {
      // FirebaseStorage.instance
      //     .getReferenceFromUrl(url)
      //     .then((value) => value.delete());
    }
  }

  salvarFuncionarioDetalhe(alunodoc, imagem, imagemweb, context) async {
    if (imagem != null) {
      String nomeImagem = "Funcionarios/" +
          alunodoc['unidade'] +
          '/' +
          alunodoc['nome'] +
          ".jpg";

      Reference storageReference =
          FirebaseStorage.instance.ref().child(nomeImagem);
      // StorageUploadTask uploadTask = storageReference.putFile(imagem);
      // uploadTask.onComplete.then((value) {
      //   value.ref.getDownloadURL().then((value) {
      //     FirebaseFirestore.instance
      //         .collection(Nomes().usersbanco)
      //         .doc(alunodoc.documentID)
      //         .update({"storageref": nomeImagem, "foto": value.toString()});
      //   });
      // });
    } else if (imagemweb != null) {
      String nomearquivo =
          "Funcionarios/${alunodoc['unidade']}/${alunodoc['nome']}.jpg";
      Uri imageUri = await salvarfileweb(nomearquivo, imagemweb);

      FirebaseFirestore.instance
          .collection(Nomes().usersbanco)
          .doc(alunodoc.documentID)
          .update({"storageref": nomearquivo, "foto": imageUri.toString()});
    }
  }

  void push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  void pushReplacement(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  bool saboudom() {
    DateTime now = DateTime.now();
    String formattedDate2 = DateFormat('EEEE').format(now);
    if (formattedDate2 == "Sunday") {
      return true;
    }
    return false;
  }

  salvarRecado(DocumentSnapshot alunodoc, DocumentSnapshot professor, mensagem,
      List<Asset> imagens, imagefromweb, context) {
    Map<String, dynamic> map = Map();
    map['createdAt'] = DateTime.now().toIso8601String();
    map['data'] = hoje();
    map['datacomparar'] = DateTime.now();
    map['mensagem'] = mensagem;
    map['enviar'] = true;
    map['nome'] = professor['nome'];
    map['responsavel'] = alunodoc['nome'];
    map['para'] = professor.id;
    map['parametrosbusca'] = [alunodoc.id, professor.id];
    map['tipo'] = 'recado';
    map['turma'] = alunodoc['turma'];
    map['curso'] = alunodoc['curso'];
    map['unidade'] = alunodoc['unidade'];

    FirebaseFirestore.instance
        .collection(Nomes().publicacoesbanco)
        .add(map)
        .then((document) {
      document.get().then((value) {
        salvarlogousuario(alunodoc, value);
      });
      enviarnotificacaotoken(professor['token'], 'Novo Recado adicionado');

      if (imagefromweb != null) {
        document.get().then((value) {
          salvarImagemRecadoWeb(
              alunodoc['turma'], imagefromweb, value, context);
        });
      }

      if (imagens != null && imagens.length > 0) {
        document.get().then((value) {
          salvarImagemRecado(alunodoc['turma'], imagens, value, context);
        });
      }
    });
  }

  salvarLembrete(DocumentSnapshot alunodoc, responsavel, mensagem,
      List<Asset> imagens, imagefromweb, context) {
    Map<String, dynamic> map = Map();
    map['createdAt'] = DateTime.now().toIso8601String();
    map['data'] = hoje();
    map['datacomparar'] = DateTime.now();
    map['mensagem'] = mensagem;
    map['enviar'] = true;
    map['nome'] = alunodoc['nome'];
    map['responsavel'] = responsavel;
    map['para'] = alunodoc.id;
    map['parametrosbusca'] = [alunodoc.id];
    map['tipo'] = 'lembrete';
    map['turma'] = alunodoc['turma'];
    map['unidade'] = alunodoc['unidade'];

    FirebaseFirestore.instance
        .collection(Nomes().publicacoesbanco)
        .add(map)
        .then((document) {
      document.get().then((value) {
        salvarlogousuario(alunodoc, value);
      });

      if (imagefromweb != null) {
        document.get().then((value) {
          salvarImagemRecadoWeb(
              alunodoc['turma'], imagefromweb, value, context);
        });
      }

      if (imagens != null && imagens.length > 0) {
        document.get().then((value) {
          salvarImagemRecado(alunodoc['turma'], imagens, value, context);
        });
      }
    });
  }

  Future speak(palavra, String idioma) async {
    FlutterTts flutterTts = FlutterTts();
    double pitch = 1.0;

    if (idioma == 'portugues' || idioma == 'moun') {
      await flutterTts.setLanguage("pt-BR");
      await flutterTts.setSpeechRate((!kIsWeb && Platform.isIOS) ? 0.45 : 0.4);
    }
    if (idioma == 'alemao') {
      await flutterTts.setLanguage("de-DE");
      await flutterTts.setSpeechRate(!kIsWeb && Platform.isIOS ? 0.30 : 0.45);
    }

    if (idioma == 'ingles') {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(!kIsWeb && Platform.isIOS ? 0.35 : 0.5);
    }

    await flutterTts.setPitch(pitch);

    if (!kIsWeb && Platform.isIOS) {
      await flutterTts
          .setIosAudioCategory(IosTextToSpeechAudioCategory.ambientSolo, [
        IosTextToSpeechAudioCategoryOptions.duckOthers,
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
      ]);
    }
    await flutterTts.speak(palavra);
  }

  salvarImagemRecado(turma, List<Asset> imagem, DocumentSnapshot doc, context) {
    if (imagem.isNotEmpty) {
      for (int i = 0; i < imagem.length; i++) {
        String nomeImagem = "Recados/" +
            turma +
            "/" +
            DateTime.now().toIso8601String() +
            i.toString() +
            ".jpg";

        Reference storageReference =
            FirebaseStorage.instance.ref().child(nomeImagem);

        imagem[i].getByteData(quality: 50).then((value) {
          Uint8List image = value.buffer.asUint8List();

          // StorageUploadTask uploadTask = storageReference.putData(
          //     image, StorageMetadata(contentType: 'image/jpeg'));

          // uploadTask.onComplete.then((caminho) {
          //   caminho.ref.getDownloadURL().then((link) {
          //     String linkfoto = link.toString();
          //
          //     doc.reference.update({
          //       "fotos": FieldValue.arrayUnion([linkfoto])
          //     }).then((val) {
          //       if (!saboudom() &&
          //           int.parse(getHora().replaceAll(RegExp(':'), '')) > 0800 &&
          //           int.parse(getHora().replaceAll(RegExp(':'), '')) < 1800) {
          //         enviarnotificacao(Nomes().controle + "Professora" + turma,
          //             'Novo Recado para Professora');
          //       }
          //     });
          //   });
          // });
        });
      }
    }
  }

  salvarImagemRecadoWeb(turma, imagemweb, DocumentSnapshot doc, context) async {
    String nomeImagem =
        "Recados/" + turma + "/" + DateTime.now().toIso8601String();

    Uri imageUri = await salvarfileweb(nomeImagem, imagemweb);

    String linkfoto = imageUri.toString();

    doc.reference.update({
      "fotos": FieldValue.arrayUnion([linkfoto])
    });

    if (!saboudom() &&
        int.parse(getHora().replaceAll(RegExp(':'), '')) > 0800 &&
        int.parse(getHora().replaceAll(RegExp(':'), '')) < 1800) {
      enviarnotificacao(Nomes().controle + "Professora" + turma,
          'Novo Recado para Professora');
    }
  }

  String alterarmes(int i, data) {
    String date = data;
    var dataseparada = date.split(" de ");
    var datadolabel =
        DateTime.parse('${dataseparada[1]}-${dataseparada[0]}-01 00:00:00.000');

    DateTime alterardia =
        new DateTime(datadolabel.year, datadolabel.month + i, datadolabel.day);

    String dataalterada = DateFormat('MM').format(alterardia) +
        ' de ' +
        DateFormat('yyyy').format(alterardia);
    return dataalterada;
  }

  String alterarano(int i, data) {
    String date = data;

    var datadolabel = DateTime.parse('$date-01-01 00:00:00.000');

    DateTime alterardia =
        new DateTime(datadolabel.year + i, datadolabel.month, datadolabel.day);

    String dataalterada = DateFormat('yyyy').format(alterardia);
    return dataalterada;
  }

  String hoje() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return formattedDate;
  }

  String diadasemana() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE', 'pt_BR').format(now);
    return formattedDate;
  }

  String hojesembarra() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('ddMMyyyy').format(now);
    return formattedDate;
  }

  String getData1(DateTime data) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(data);
    return formattedDate;
  }

  String formatData({int year=0, int month=0, int day=0}) {
    DateTime data = DateTime(year, month, day);
    String formattedDate = DateFormat('dd/MM/yyyy').format(data);
    return formattedDate;
  }

  String formatHora({int hour=0, int minute=0}) {
    DateTime data = DateTime(0, 1, 1, hour, minute);
    String formattedDate = DateFormat('HH:mm').format(data);
    return formattedDate;
  }

  String getDataeHora() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yy HH:mm').format(now);
    return formattedDate;
  }

  String getHora() {
    DateTime now = DateTime.now();
    String formattedDate1 = DateFormat('HH:mm').format(now);
    return formattedDate1;
  }

  getMes() {
    DateTime now = DateTime.now();
    String formattedDate =
        DateFormat('MM').format(now) + ' de ' + DateFormat('yyyy').format(now);
    return formattedDate;
  }

  getMesTelaInicial() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMyyyy').format(now);
    return formattedDate;
  }

  getAno() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy').format(now);
    return formattedDate;
  }

  salvarListaTransmissao(list, usuario, texto) {
    list.forEach((concatenada) {
      List concatenadasplit = concatenada.split('-');
      String pai = concatenadasplit[0];
      String aluno = concatenadasplit[1];

      FirebaseFirestore.instance
          .collection(Nomes().usersbanco)
          .doc(pai)
          .get()
          .then((paidoc) {
        FirebaseFirestore.instance
            .collection(Nomes().alunosbanco)
            .doc(aluno)
            .get()
            .then((alunodoc) {
          gravarmensagemListaTransmissao(paidoc, alunodoc, usuario, texto);
        });
      });
    });
  }

  gravarmensagemListaTransmissao(paiuser, alunodoc, usuario, texto) {
    salvarConversaListaTransmissao(paiuser, usuario, texto);

    Map<String, dynamic> map = Map();
    map['origem'] = paiuser.documentID;
    map['nome'] = paiuser['nome'];
    map['aluno'] = alunodoc.documentID;
    map['unidade'] = alunodoc['unidade'];
    map['curso'] = alunodoc['curso'];
    map['turma'] = alunodoc['turma'];
    map['alunonome'] = alunodoc['nome'];
    map['logo'] = alunodoc['foto'];
    map['data'] = Pesquisa().getDataeHora();
    map['para'] = usuario['perfil'];
    map['nova'] = 'pais';
    map['emissor'] = 'escola';
    map['mensagem'] = texto;
    map['tipo'] = usuario['perfil'];
    map['createdAt'] = DateTime.now().toIso8601String();
    map['datacomparar'] = DateTime.now();
    if (paiuser != null) {
      map['parentesco'] = paiuser['parentesco'];
    }
    if (usuario['perfil'].toString().contains('Professor')) {
      map['professorid'] = usuario.documentID;
      FirebaseFirestore.instance
          .collection(Nomes().mensagensbanco)
          .doc(usuario['perfil'] + usuario.documentID + paiuser.documentID)
          .set(map);
    } else {
      FirebaseFirestore.instance
          .collection(Nomes().mensagensbanco)
          .doc(usuario['perfil'] + paiuser.documentID)
          .set(map);
    }
  }

  salvarConversaListaTransmissao(paiuser, usuario, texto) {
    Map<String, dynamic> map = Map();
    map['origem'] = paiuser.documentID;
    map['data'] = Pesquisa().getDataeHora();
    map['emissor'] = 'escola';
    map['mensagem'] = texto;
    map['responsavel'] = usuario['nome'];
    map['tipo'] = usuario['perfil'];
    map['createdAt'] = DateTime.now().toIso8601String();
    map['datacomparar'] = DateTime.now();
    if (usuario['perfil'].toString().contains('Professor')) {
      map['professorid'] = usuario.documentID;
    }

    FirebaseFirestore.instance
        .collection(Nomes().conversasbanco)
        .add(map)
        .then((document) {
      enviarnotificacaoListaTransmissao(paiuser);
    });
  }

  enviarnotificacaoListaTransmissao(paiuser) {
    Pesquisa().enviarnotificacaotoken(paiuser['token'], 'Nova mensagem');
  }

  //CORREÇÕES

  verificaralunos() {
    FirebaseFirestore.instance
        .collection('Alunos')
        .orderBy('nome')
        .get()
        .then((value) {
      print('começou');
      value.docs.forEach((element) {
        if (element['email'] == null) {
          FirebaseFirestore.instance
              .collection("Users")
              .where('codigo', isEqualTo: element['codigo'])
              .where('nome', isEqualTo: element['nome'])
              .get()
              .then((value) {
            print(element['codigo'] +
                " - " +
                element['unidade'] +
                " - " +
                element['nome']);
            element.reference
                .update({'email': value.docs.first['email']});
          });
        }
      });
    });
  }

  apagaruserseic() {
    FirebaseFirestore.instance.collection('Users').get().then((value) {
      value.docs.forEach((element) {
        if (element['controle'] == null && element['alunos'].isEmpty) {
          print(element['email']);
          print(element['alunos']);
          Pesquisa().excluiruser(element.id);
        }
      });
    });
  }
}
