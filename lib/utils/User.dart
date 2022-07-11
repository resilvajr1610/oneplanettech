class User {
  String controle='';
  String curso='';
  List<dynamic> cursos=[];
  String turma='';
  List<dynamic> turmas=[];
  String plataforma='';
  String perfil='';
  String parentesco='';
  String unidade='';
  late bool responsavelfinanceiro;

  User._privateConstructor(
      {String controle='',
      required String curso,
      required List<dynamic> cursos,
       String turma='',
       required List<dynamic> turmas,
       String plataforma='',
        String perfil='',
        String parentesco='',
        String unidade='',
       bool responsavelfinanceiro = false}) {
      if (controle != null) {
        this.controle = controle;
        this.cursos = cursos;
        this.turmas = turmas;
        this.plataforma = plataforma;
        this.perfil = perfil;
        this.unidade = unidade;
      } else {
        this.curso = curso;
        this.turma = turma;
        this.plataforma = plataforma;
        this.parentesco = parentesco;
        this.unidade = unidade;
        this.responsavelfinanceiro = responsavelfinanceiro;
      }
  }

  static final User _instance = User._privateConstructor(curso: '',cursos: [],turmas: []);

  factory User() {
    return _instance;
  }

  @override
  String toString() {
    return 'User{controle: $controle, curso: $curso, cursos: $cursos, turma: $turma, turmas: $turmas, plataforma: $plataforma, perfil: $perfil, parentesco: $parentesco, unidade: $unidade, responsavelfinanceiro: $responsavelfinanceiro}';
  }
}
