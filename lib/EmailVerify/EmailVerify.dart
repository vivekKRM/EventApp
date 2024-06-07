import 'package:event/NewUser/NewUser.dart';
import 'package:event/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:event/constants/styles.dart';
import 'package:event/utils/appManager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class EmailVerify extends StatefulWidget {
  const EmailVerify({Key? key, required this.title, required this.appManager})
      : super(key: key);
  final String title;
  final AppManager appManager;

  @override
  _EmailVerifyState createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerify> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String email = '';
  late SharedPreferences prefs;
  bool _loading = false;
  String? errorText;
  late FToast fToast;
  Map _userObj = {};

  void emailVerifyAPI() {
    setState(() {
      _loading = true;
    });
    widget.appManager.emailverify(email).then(((response) async {
      if (response?.status == 200) {
        setState(() {
          _loading = false;
        });
        prefs.setString('email', email);
        var loggedIn = await widget.appManager.hasLoggedIn();
        // if (loggedIn['hasLoggedIn']) {
        //   Navigator.pushReplacementNamed(context, '/login', arguments: email);
        // }
        Navigator.pushNamed(context, "/login",arguments: email);

      } else if (response?.status == 202) {
        Navigator.pushNamed(context, "/newuser",arguments: email);
        showToast(response?.message ?? '', 2, kToastColor);
        setState(() {
          _loading = false;
        });
      } else if (response?.status == 502) {
        setState(() {
          _loading = false;
        });
        showToast(response?.message ?? '', 2, kToastColor);
        await this.widget.appManager.clearLoggedIn();

        if (this.widget.appManager.islogout == true) {
          this.widget.appManager.utils.isPatientExitDialogShown = false;
          Navigator.pushNamedAndRemoveUntil(context, '/obs', (route) => false);
        }
      } else {
        setState(() {
          _loading = false;
        });
        showToast(response?.message ?? '', 2, kToastColor);
      }
    }));
  }

  void showToast(String msg, int duration, Color bgColor) {
    Widget toast = Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: Container(
          width: msg.length * 10.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: bgColor,
          ),
          child: Text(
            msg,
            style: kToastTextStyle,
            maxLines: 5,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
    fToast.showToast(
        child: toast,
        toastDuration: Duration(seconds: duration),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            bottom: 100.0,
          );
        });
  }

  bool isValidEmailAndPassword(String email) {
    // Email regex pattern
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailPattern.hasMatch(email)) {
      errorText = 'please enter valid email address';
      Fluttertoast.showToast(
        msg: 'please enter valid email address',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: kToastColor,
      );
      return false;
    } else {
      return true;
    }
  }

  _launchURL(String urlhit) async {
    if (await canLaunch(urlhit)) {
      await launch(urlhit);
    } else {
      throw 'Could not launch $urlhit';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefs();
    fToast = FToast();
    fToast.init(context);
  }

  getPrefs() async {
    this.prefs = await SharedPreferences.getInstance();
    this.email = prefs.getString('email') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 1.0,
        backgroundColor: topHeaderBar,
        surfaceTintColor: topHeaderBar,
      ),
      body: Container(
        color: backgroundColor,
        child: ListView(
          // physics: NeverScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Image.asset(
                      'assets/Nyka.png',
                      height: size.height * 0.12,
                      width: size.width * 0.6,
                      fit: BoxFit.contain,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Text('Login', style: kLoginTextStyle),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('This email address will be public.',
                        style: kLoginSubTextStyle),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: kLoginTextFieldFillColor,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_2_outlined,
                            size: 20, color: kLoginIconColor),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              hintText: 'Email address',
                              hintStyle: kLoginTextFieldTextStyle,
                            ),
                            onChanged: (value) {
                              setState(() {
                                email = value;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  // SizedBox(height: 20),

                  SizedBox(height: 26),
                  _loading
                      ? CircularProgressIndicator()
                      : CustomButton(
                          text: 'Continue',
                          onPressed: () {
                            if (isValidEmailAndPassword(email)) {
                              emailVerifyAPI();
                            }
                          },
                        ),

                  SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
