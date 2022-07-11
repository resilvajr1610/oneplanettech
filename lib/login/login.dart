import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scalifra/login/redefinirsenha.dart';

import '../design.dart';
import '../layout.dart';
import '../main.dart';
import '../pesquisa.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
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

    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    controller1 =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    controller.addStatusListener((status) {});
    controller1.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        loginUser().then((user) {
          controller1.reset();
        });
      }
    });
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    controller1.dispose();
    cemail.dispose();
    csenha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    offset = Tween(begin: MediaQuery.of(context).size.width, end: 0.0).animate(
        CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, 0.85, curve: Curves.easeInOutQuad)));
    fade = Tween(begin: 0.0, end: MediaQuery.of(context).size.width * 0.5)
        .animate(CurvedAnimation(
            parent: controller, curve: Interval(0.0, 0.7, curve: Curves.ease)));
    buttonSqueeze =
        Tween(begin: MediaQuery.of(context).size.width / 2, end: 60.0).animate(
            CurvedAnimation(parent: controller1, curve: Interval(0.0, 0.5)));
    textOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeInCirc)));
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [

            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/fundoapp.png"),
                      fit: BoxFit.cover)),
            ),
            Row(
              children: [
                (MediaQuery.of(context).size.width > 850)
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                      )
                    : Container(),
                Expanded(
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.9,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                              ),
                              Column(
                                children: <Widget>[
                                  AnimatedBuilder(
                                    builder: (context, child) {
                                      return Opacity(
                                          opacity: textOpacity.value,
                                          child: Layout().caixadetexto(
                                              1,
                                              1,
                                              TextInputType.emailAddress,
                                              cemail,
                                              "Identificação",
                                              TextCapitalization.none, color: Colors.white, ));
                                    },
                                    animation: controller,
                                  ),
                                  AnimatedBuilder(
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: textOpacity.value,
                                        child: Layout().caixadetexto(
                                            1,
                                            1,
                                            TextInputType.visiblePassword,
                                            csenha,
                                            "senha",
                                            TextCapitalization.none, color: Colors.white),
                                      );
                                    },
                                    animation: controller,
                                  ),
                                  AnimatedBuilder(
                                    builder: (context, child) {
                                      return Opacity(
                                          opacity: textOpacity.value,
                                          child: loginAnimation());
                                    },
                                    animation: controller,
                                  ),
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                (MediaQuery.of(context).size.width > 850)
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                      )
                    : Container(),
              ],
            ),
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
                color: Colors.red[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                margin: EdgeInsets.all(10.0),
                elevation: 5.0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15.0),
                  splashColor: Colors.grey.withAlpha(30),
                  onTap: () {
                    if (csenha.text.isNotEmpty && cemail.text.isNotEmpty) {
                      controller1.forward();
                    } else {
                      return Layout().dialog1botao(
                          context,
                          "Identificação e senha",
                          "Preencha dados válidos.\nCaso tenha esquecido, entre no Portal do Responsável ou em contato com a sua escola.");
                    }
                  },
                  child: buttonSqueeze.value >= 125
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

  loginUser() async {

    try {
      await _auth.signInWithEmailAndPassword(
          email: cemail.text.toLowerCase().trim(),
          password: csenha.text.trim());
      print('logou');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyHomePage()));
    } on Exception catch (e) {
      return Layout().dialog1botao(context, "Confira os dados",
          "Suas credenciais estão incorretas. \n Tente novamente.");
    }
  }
}
