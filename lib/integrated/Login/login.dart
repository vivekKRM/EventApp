import 'package:event/constants/constants.dart';
import 'package:event/constants/styles.dart';
import 'package:event/utils/appManager.dart';
import 'package:event/widgets/customAppbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class Login extends StatefulWidget {
  Login(
      {Key? key,
      required this.title,
      required this.appManager,
      required this.email})
      : super(key: key);

  final String title;
  final AppManager appManager;
  final String email;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String email = '';
  late SharedPreferences prefs;
  String password = '';
  bool obscureText = true;
  bool _loading = false;
  bool loginn = false;
  String? errorText;
  late FToast fToast;
  Map _userObj = {};

  void login() {
    setState(() {
      _loading = true;
    });
    widget.appManager
        .login(emailController.text, passwordController.text)
        .then(((response) async {
      print(response);
      if (response?.status == 200) {
        setState(() {
          _loading = false;
        });
        prefs.setString('email', email);
        prefs.setInt('sId', response?.data?.id ?? 0);
        prefs.setString('authToken', response?.data?.token ?? '');
        await widget.appManager.markLoggedIn(response?.data?.token ?? '');
        await widget.appManager.initSocket(response?.data?.token ?? '');
        var loggedIn = await widget.appManager.hasLoggedIn();
        if (loggedIn['hasLoggedIn']) {
          Navigator.pushReplacementNamed(context, '/home', arguments: false);
        }

        showToast(response?.message ?? '', 2, kToastColor);
      } else if (response?.status == 202) {
        showToast(response?.message ?? '', 2, kToastColor);
        setState(() {
          _loading = false;
        });
      } else if (response?.status == 502) {
        setState(() {
          _loading = false;
        });
        showToast(response?.message ?? '', 2, kToastColor);
      } else {
        setState(() {
          _loading = false;
        });
        showToast(response?.message ?? '', 2, kToastColor);
      }
    }));
  }

  void forgetPassword() {
    Navigator.pushNamed(context, "/forgetPassword");
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

  bool isValidEmailAndPassword(String email, String password) {
    // Email regex pattern
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailPattern.hasMatch(email)) {
      errorText = 'please enter valid email address';
      Fluttertoast.showToast(
        msg: 'please enter valid email address',
        toastLength: Toast.LENGTH_LONG,
        // gravity: ToastGravity.TOP,
        backgroundColor: kToastColor,
      );
      return false;
    } else if (password.contains(' ') || password.isEmpty) {
      errorText = 'Password can not be empty or contain spaces';
      Fluttertoast.showToast(
        msg: 'Password can not be empty or contain spaces',
        toastLength: Toast.LENGTH_LONG,
        // gravity: ToastGravity.TOP,
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
    print(widget.email);
  }

  getPrefs() async {
    this.prefs = await SharedPreferences.getInstance();
    this.email = prefs.getString('email') ?? '';
    this.password = prefs.getString('password') ?? '';
    setState(() {
      emailController.text = widget.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBarr(
        backgroundColor: backgroundColor,
        leadingIconColor: Colors.black,
        titleText: '',
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
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
                    padding: const EdgeInsets.only(top: 10.0),
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
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Enter your password here',
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
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                    margin: EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: kLoginTextFieldFillColor,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_open_outlined,
                            size: 20, color: kLoginIconColor),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: obscureText,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              // contentPadding:
                              //     EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                              isDense: true,
                              hintText: 'Password',
                              hintStyle: kLoginTextFieldTextStyle,
                            ),
                            onChanged: (value) {
                              this.setState(() {
                                password = value;
                              });
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Icon(
                              obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: kButtonColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 26),
                  _loading
                      ? CircularProgressIndicator()
                      : CustomButton(
                          text: 'Log in',
                          onPressed: () {
                            if (isValidEmailAndPassword(emailController.text,
                                passwordController.text)) {
                              login();
                            }
                          },
                        ),
                  SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () {
                            this.forgetPassword();
                          },
                          child: Text("Forgot Password? ",
                              style: kForgotDetailTextStyle),
                        ),
                      ),
                    ],
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
