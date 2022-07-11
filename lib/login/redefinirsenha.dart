import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../design.dart';
import 'package:flutter/material.dart';

import '../layout.dart';
import '../main.dart';

class Redefinirsenha extends StatefulWidget {
  @override
  _RedefinirsenhaState createState() => _RedefinirsenhaState();
}

class _RedefinirsenhaState extends State<Redefinirsenha> with TickerProviderStateMixin {
  late AnimationController controller, controller1;
  late Animation<double> fade;
  late Animation<double> buttonSqueeze;
  late Animation<double> textOpacity;
  late Animation<double> offset;
  FirebaseAuth _auth = FirebaseAuth.instance;
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


          if (cemail.text.isNotEmpty) {
            Layout().dialog1botao(
                context,
                "Recuperação de senha",
                "Um e-mail foi enviado!\nVerifique sua caixa de entrada e spam\nLembre-se de realizar a redefinição em até 1 hora.", destino: MyHomePage());
            _auth
                .sendPasswordResetEmail(
                email: cemail.text.toLowerCase().trim());
            controller1.reset();

          } else {
            Layout().dialog1botao(
                context,
                "Escreva seu e-mail",
                "Primeiro escreva seu e-mail no campo acima\ne clique aqui novamente.");
            controller1.reset();

          }
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
                                      borderRadius: BorderRadius.circular(40.0)),
                                  elevation: 20.0,
                                  child: Container(
                                    child: Row(
                                      children: <Widget>[
                                        Container(

                                          alignment: Alignment.topCenter,
                                          width: MediaQuery.of(context).size.width /
                                              4.3,
                                          height:
                                              MediaQuery.of(context).size.height,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage("images/fundoapp.png"),
                                                  fit: BoxFit.fill)),
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                top: 40.0,
                                                bottom: 5.0),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    "Funcionário da Rede\nRedefina sua senha",
                                                    style: TextStyle(
                                                        color: Cores().corprincipal,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 35.0,
                                                       ),
                                                  ),
                                                  SizedBox(height: 20.0,),
                                                  Text('Você receberá um e-mail com um link para redefinição da senha.\nEste link tem validade de 1 hora.\nVerifique também em sua caixa de spam.'),
                                                  const SizedBox(height: 21.0),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width*0.3,
                                                      child: Layout().caixadetexto(1, 1, TextInputType.text, cemail, "E-mail", TextCapitalization.none,  obs:  false )),
                                                  SizedBox(height: 20.0),


                                                  Center(child: loginAnimation()),
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
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "Funcionário da Rede\nRedefina sua senha",
                                          style: TextStyle(
                                            color: Cores().corprincipal,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        SizedBox(height: 20.0,),
                                        Text('Você receberá um e-mail com um link para redefinição da senha.\nEste link tem validade de 1 hora.\nVerifique também em sua caixa de spam.'),
                                        const SizedBox(height: 21.0),
                                        Container(
                                            width: 300.0,
                                            child: Layout().caixadetexto(1, 1, TextInputType.text, cemail, "E-mail", TextCapitalization.none,  obs:  false )),
                                        SizedBox(height: 20.0),
                                        Center(child: loginAnimation()),
                                      ],
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
                    if (cemail.text.isNotEmpty) {
                      controller1.forward();
                    } else {
                      Layout().dialog1botao(
                          context,
                          "Escreva seu e-mail",
                          "Primeiro escreva seu e-mail no campo acima\ne clique aqui novamente.");
                    }
                  },
                  child: buttonSqueeze.value >= 70
                      ? Center(
                          child: Text(
                          "Enviar e-mail",
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
    properties.add(DiagnosticsProperty<Animation<double>>('buttonSqueeze', buttonSqueeze));
  }

}
