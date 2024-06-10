import 'package:event/constants/constants.dart';
import 'package:event/constants/styles.dart';
import 'package:event/utils/appManager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewUser extends StatefulWidget {
  const NewUser({ Key? key, 
  required this.title, required this.appManager, 
  required this.email }) : super(key: key);


  final String title;
  final AppManager appManager;
  final String email;

  @override
  _NewUserState createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
 TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
  String email = '';
  late SharedPreferences prefs;
  String password = '';
  String confirmpassword = '';
  bool obscureText = true;
  bool _loading = false;
  bool loginn = false;
  String? errorText;
  late FToast fToast;
  Map _userObj = {};


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
            top: 100.0,
          );
        });
  }



bool isValidEmailAndPassword(String email, String password, String confirmPassword) {
  // Email regex pattern
  final emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  if (!emailPattern.hasMatch(email)) {
    Fluttertoast.showToast(
      msg: 'Please enter a valid email address',
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.red,
    );
    return false;
  } else if (password.contains(' ')) {
    Fluttertoast.showToast(
      msg: 'Password cannot contain spaces',
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.red,
    );
    return false;
  } else if (password.length < 6) {
    Fluttertoast.showToast(
      msg: 'Password must be at least 6 characters long',
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.red,
    );
    return false;
  } else if (password != confirmPassword) {
    Fluttertoast.showToast(
      msg: 'Passwords do not match',
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.red,
    );
    return false;
  } else {
    Navigator.pushNamed(context, "/fregister",arguments: email);



    return true;
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
                    padding: const EdgeInsets.only(top:10.0),
                    child: Image.asset(
                      'assets/Nyka.png',
                      height: size.height * 0.12,
                      width: size.width * 0.6,
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(top:40.0),
                    child: Text('Sign up', style: kLoginTextStyle),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Create password here',
                        style: kLoginSubTextStyle),
                  ),
                  const SizedBox(height: 25),
                 Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 15),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 15),
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
                
               Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 15),
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
                                controller: confirmpasswordController,
                                obscureText: obscureText,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  // contentPadding:
                                  //     EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                                  isDense: true,
                                  hintText: 'Confirm Password',
                                  hintStyle: kLoginTextFieldTextStyle,
                                ),
                                onChanged: (value) {
                                  this.setState(() {
                                    confirmpassword = value;
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
                          text: 'Continue',
                          onPressed: () {
                            if (isValidEmailAndPassword(emailController.text, 
                            passwordController.text, confirmpasswordController.text)) {
                             // login();
                            }
                          },
                        ),
                  SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     
                      
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