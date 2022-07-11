import 'package:rxdart/rxdart.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainBloc extends BlocBase{
  // ignore: close_sinks
  var _list = BehaviorSubject<List<DocumentSnapshot>>();
  // ignore: close_sinks
  var _rodinha = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get outputrodinha => _rodinha.stream;
  Sink<bool> get inputrodinha => _rodinha.sink;



  Stream<List<DocumentSnapshot>> get outputList => _list.stream;
  Sink<List<DocumentSnapshot>> get inputList => _list.sink;




  @override
  void dispose() {
    _list.close();
    _rodinha.close();
    super.dispose();
  }

}

class MainFiltroBloc extends BlocBase{
  // ignore: close_sinks
  var _list = BehaviorSubject<List<DocumentSnapshot>>();
  // ignore: close_sinks
  var _filtro = BehaviorSubject<String>.seeded('todas');
  var _rodinha = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get outputrodinha => _rodinha.stream;
  Sink<bool> get inputrodinha => _rodinha.sink;



  Stream<List<DocumentSnapshot>> get outputList => _list.stream;
  Sink<List<DocumentSnapshot>> get inputList => _list.sink;
  Stream<String> get outputFiltro => _filtro.stream;
  Sink<String> get inputFiltro =>_filtro.sink;



  @override
  void dispose() {
    _list.close();
    _rodinha.close();
    _filtro.close();
    super.dispose();
  }

}

class MainEscolaBloc extends BlocBase{
  // ignore: close_sinks
  var _list = BehaviorSubject<List<DocumentSnapshot>>();
  // ignore: close_sinks
  var _filtro = BehaviorSubject<String>.seeded('todas');
  var _rodinha = BehaviorSubject<bool>.seeded(false);
  var _ultimodoc = BehaviorSubject<DocumentSnapshot>();

  Stream<bool> get outputrodinha => _rodinha.stream;
  Sink<bool> get inputrodinha => _rodinha.sink;

  Stream<List<DocumentSnapshot>> get outputList => _list.stream;
  Sink<List<DocumentSnapshot>> get inputList => _list.sink;

  Stream<DocumentSnapshot> get outputUltimodoc => _ultimodoc.stream;
  Sink<DocumentSnapshot> get inputUltimodoc => _ultimodoc.sink;

  Stream<String> get outputFiltro => _filtro.stream;
  Sink<String> get inputFiltro =>_filtro.sink;



  @override
  void dispose() {
    _list.close();
    _rodinha.close();
    _filtro.close();
    super.dispose();
  }

}



class AlunosBloc extends BlocBase{

  var _listturmas = BehaviorSubject<List<String>>();
  Stream<List<String>> get outputturmas => _listturmas.stream;
  Sink<List<String>> get inputturmas => _listturmas.sink;

  var _turma = BehaviorSubject<String>.seeded('Todas');
  Stream<String> get outputturma => _turma.stream;
  Sink<String> get inputturma => _turma.sink;


  var _numeroalunos = BehaviorSubject<int>();
  Stream<int> get outputnumeroalunos => _numeroalunos.stream;
  Sink<int> get inputnumeroalunos => _numeroalunos.sink;


  String get turma => _turma.value;
  int get numeroalunos => _numeroalunos.value;


  @override
  void dispose() {
    _listturmas.close();
    _turma.close();
    super.dispose();
  }

}

class ConsultaImagemBloc extends BlocBase{

  var _textoImagem = BehaviorSubject<String>.seeded('');
  var _turma = BehaviorSubject<String>.seeded('Todas');
  var _turmas = BehaviorSubject<List<String>>();
  Stream<String> get outputTextoImagem=> _textoImagem.stream;
  Sink<String> get inputTextoImagem => _textoImagem.sink;
  Stream<String> get outputTurma=> _turma.stream;
  Sink<String> get inputTurma => _turma.sink;
  String get turmaSelecionada => _turma.value;
  Stream<List<String>> get outputTurmas=> _turmas.stream;
  Sink<List<String>> get inputTurmas => _turmas.sink;
  @override
  void dispose() {
    _turma.close();
    _turmas.close();
    _textoImagem.close();
    super.dispose();
  }

}