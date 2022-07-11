import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../design.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../layout.dart';
import '../main.dart';
import '../pesquisa.dart';
import 'redefinirsenha.dart';

class LoginWeb extends StatefulWidget {
  @override
  _LoginWebState createState() => _LoginWebState();
}

class _LoginWebState extends State<LoginWeb> with TickerProviderStateMixin {
  late AnimationController controller, controller1;
  late Animation<double> fade;
  late Animation<double> buttonSqueeze;
  late Animation<double> textOpacity;
  late Animation<double> offset;
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController csenha = TextEditingController();
  TextEditingController cemail = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1750));
    controller1 =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    controller1.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _auth
            .signInWithEmailAndPassword(
                email: cemail.text.toLowerCase().trim(),
                password: csenha.text.trim())
            .then((user) async {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MyHomePage()));
          controller1.reset();
        }).catchError((error) async {
          switch (error.toString()) {
            case 'FirebaseError: The email address is badly formatted. (auth/invalid-email)':
              Layout().dialog1botao(context, 'Erro',
                  'O e-mail digitado é inválido.\n Tente novamente.');
              break;
            case 'FirebaseError: There is no user record corresponding to this identifier. The user may have been deleted. (auth/user-not-found)':
              Layout().dialog1botao(context, 'Erro',
                  'Não existe usuário com este e-mail cadastrado.\n Tente com outro e-mail.');
              break;
            case 'FirebaseError: The password is invalid or the user does not have a password. (auth/wrong-password)':
              Layout().dialog1botao(context, 'Erro',
                  'A senha digitada está incorreta.\n Tente novamente.');
              break;
          }

          controller1.reset();
        });
      }
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    textOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeInCirc)));
    offset = Tween(begin: MediaQuery.of(context).size.width, end: 0.0).animate(
        CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, 0.85, curve: Curves.easeInOutQuad)));
    buttonSqueeze = Tween(
            begin: MediaQuery.of(context).size.width / 4.5, end: 60.0)
        .animate(
            CurvedAnimation(parent: controller1, curve: Interval(0.0, 0.5)));
    return Scaffold(
        backgroundColor: Colors.white24,
        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/fundoweb.png"),
                      fit: BoxFit.cover)),
            ),
            AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(offset.value, 0.0),
                    child: Opacity(
                      opacity: textOpacity.value,
                      child: Container(
                        child: MediaQuery.of(context).size.width > 800
                            ? Padding(
                                padding: EdgeInsets.only(
                                    top: 150.0,
                                    bottom: 150.0,
                                    left: 200.0,
                                    right: 200.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(40.0)),
                                  elevation: 20.0,
                                  child: Container(
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.topCenter,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4.3,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      "images/fundoapp.png"),
                                                  fit: BoxFit.contain)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 40.0),
                                            child: Container(
                                              width: 200.0,
                                              height: 200.0,
                                             // child:
                                              // Image.asset(
                                              //   "images/logovertical.png",
                                              //   fit: BoxFit.contain,
                                              // ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                top: 40.0, bottom: 5.0),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    "Acessar",
                                                    style: TextStyle(
                                                      color:
                                                          Cores().corprincipal,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 35.0,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 21.0),
                                                  Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: Layout()
                                                          .caixadetexto(
                                                              1,
                                                              1,
                                                              TextInputType
                                                                  .text,
                                                              cemail,
                                                              "Identificação",
                                                              TextCapitalization
                                                                  .none,
                                                              obs: false)),
                                                  SizedBox(height: 20.0),
                                                  Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: Layout()
                                                          .caixadetexto(
                                                              1,
                                                              1,
                                                              TextInputType
                                                                  .text,
                                                              csenha,
                                                              "Senha",
                                                              TextCapitalization
                                                                  .none,
                                                              obs: true)),
                                                  SizedBox(height: 10.0),
                                                  Center(
                                                      child: loginAnimation()),
                                                  (kIsWeb) ? TextButton(
                                                    child: Text(
                                                        'Acesso Funcionários'),
                                                    onPressed: () {
                                                      Pesquisa().irpara(
                                                          Redefinirsenha(),
                                                          context);
                                                    },
                                                  ) : Container()
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(100.0),
                                  child: Card(
                                    color: Colors.white70,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(40.0)),
                                    elevation: 5.0,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Acesso",
                                            style: TextStyle(
                                                color: Cores().corprincipal,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 35.0,
                                                fontFamily: 'Merriweather'),
                                          ),
                                          const SizedBox(height: 21.0),

                                          //InputField Widget from the widgets folder
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12.0),
                                            child: Layout().caixadetexto(
                                                1,
                                                1,
                                                TextInputType.emailAddress,
                                                cemail,
                                                "Identificação",
                                                TextCapitalization.none,
                                                obs: false),
                                          ),
                                          SizedBox(height: 12.0),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12.0),
                                            child: Layout().caixadetexto(
                                                1,
                                                1,
                                                TextInputType.text,
                                                csenha,
                                                "Senha",
                                                TextCapitalization.none,
                                                obs: true),
                                          ),
                                          SizedBox(height: 12.0),
                                          loginAnimation(),
                                          (kIsWeb) ? TextButton(
                                            child: Text(
                                                'Acesso Funcionários'),
                                            onPressed: () {
                                              Pesquisa().irpara(
                                                  Redefinirsenha(),
                                                  context);
                                            },
                                          ): Container()
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  );
                }),
          ],
        ));
  }

  Widget loginAnimation() {
    return AnimatedBuilder(
        animation: controller1,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Container(
              width: buttonSqueeze.value,
              height: MediaQuery.of(context).size.height * 0.1,
              child: Card(
                color: Cores().corprincipal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                margin: EdgeInsets.all(10.0),
                elevation: 5.0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15.0),
                  splashColor: Colors.grey.withAlpha(30),
                  onTap: () {
                    if (csenha.text != null && cemail.text != null) {
                      if (csenha.text.isNotEmpty && cemail.text.isNotEmpty) {
                        controller1.forward();
                      } else {
                        return Layout().dialog1botao(
                            context, "Ups", "Preencha dados válidos.");
                      }
                    } else {
                      Layout().dialog1botao(
                          context, "Ups", "Preencha dados válidos.");
                    }
                  },
                  child: buttonSqueeze.value >= 70
                      ? Center(
                          child: Text(
                          "ACESSAR",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              letterSpacing: 1.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w400),
                        ))
                      : Container(
                          alignment: Alignment.center,
                          width: buttonSqueeze.value,
                          height: 45.0,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 1.0,
                          )),
                ),
              ),
            ),
          );
        });
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Animation<double>>('fade', fade));
    properties.add(DiagnosticsProperty<Animation<double>>('offset', offset));
  }
}
