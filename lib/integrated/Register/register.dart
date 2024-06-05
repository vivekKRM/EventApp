import 'package:event/constants/styles.dart';
import 'package:event/utils/appManager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  Register({Key? key, required this.title, required this.appManager})
      : super(key: key);

  final String title;
  final AppManager appManager;

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String email = '';
  String password = '';
  String token = '';
  bool loginError = false;
  bool obscureText = true;
  bool obscureText1 = true;
  late FToast fToast;
  late SharedPreferences prefs;
  List<String> texts = [
    'Email',
    'Password',
    'Confirm Password',
  ];

  List<bool> isError = [
    false,
    false,
    false,
  ];

  TextEditingController _passwordController = TextEditingController();
  TextEditingController _cpasswordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  Future<void> submitPersonalDetails() async {
    final requestBody = {
      'eamil': _emailController.text,
      'password': _passwordController.text,
      'cpassword': _cpasswordController.text,
    };
    print(requestBody);
    widget.appManager.apis
        .sendRegister(requestBody, (prefs.getString('authToken') ?? ''))
        .then((response) {
      // Handle successful response
      if (response.status == 200) {
        showToast(response?.message ?? '', 2, kPositiveToastColor, context);
        // prefs.setInt('sId', response?.user_id ?? 0);
        // prefs.setString('username', _usernameController.text ?? '');
      } else if (response.status == 201) {
        showToast(response?.message ?? '', 2, kToastColor, context);
      } else {
        print("Failed to register");
      }
    }).catchError((error) {
      // Handle error
      print("Failed to register: $error");
    });
  }

  bool isValidForm() {
    isError.clear();
    isError = [
      false,
      false,
      false,
    ];
    // Email regex pattern
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailPattern.hasMatch(_emailController.text)) {
      showToast('Please enter valid email address', 2, kToastColor, context);
      setState(() {
        isError[0] = true;
      });
      return false;
    } else if (_passwordController.text == '') {
      showToast('Please enter password', 2, kToastColor, context);
      setState(() {
        isError[1] = true;
      });
      return false;
    } else if (_passwordController.text.contains(' ')) {
      showToast('Password cannot contain spaces', 2, kToastColor, context);
      setState(() {
        isError[1] = true;
      });
      return false;
    } else if (_passwordController.text.length < 6) {
      showToast('Please enter strong password', 2, kToastColor, context);
      setState(() {
        isError[1] = true;
      });
      return false;
    } else if (_cpasswordController.text == '') {
      showToast('Please enter confirm password', 2, kToastColor, context);
      setState(() {
        isError[2] = true;
      });
      return false;
    } else if (_cpasswordController.text.contains(' ')) {
      showToast(
          'Confirm password cannot contain spaces', 2, kToastColor, context);
      setState(() {
        isError[2] = true;
      });
      return false;
    } else if (_cpasswordController.text.length < 6) {
      showToast(
          'please enter strong confirm password', 2, kToastColor, context);
      setState(() {
        isError[2] = true;
      });
      return false;
    } else if (_passwordController.text != _cpasswordController.text) {
      showToast('Please match password and  confirm password', 2, kToastColor,
          context);
      setState(() {
        isError[2] = true;
      });
      return false;
    } else {
      print("Proceed");
      FocusScope.of(context).unfocus();
      return true;
    }
  }

  void showToast(
      String msg, int duration, Color bgColor, BuildContext context) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: duration,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // this.jumpToHomeIfRequired();
    fToast = FToast();
    getPrefs();
    fToast.init(context);
  }

  getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    token = prefs.getString('authToken') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async {
          // Disable back button
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: topHeaderBar, //kAppBarColor
            surfaceTintColor: topHeaderBar, //kAppBarColor
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Signup',
              style: kHeaderTextStyle,
            ),
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Container(
                color: backgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/Nyka.png',
                      height: size.height * 0.12,
                      width: size.width * 0.6,
                      fit: BoxFit.contain,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Nyka', style: kLoginTextStyle),
                          SizedBox(height: 20),
                          Text(
                            "Create your account to get started .",
                            style: kObsText,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 42),
                          Container(
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              // scrollDirection: Axis.vertical,
                              itemCount: texts
                                  .length, // Change this number as per your requirement
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 14, horizontal: 15),
                                        //  margin: EdgeInsets.only(bottom: 20),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: kLoginTextFieldFillColor,
                                          border: isError[index]
                                              ? Border.all(color: Colors.red)
                                              : Border.all(
                                                  color:
                                                      kLoginTextFieldFillColor),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                                index == 1 || index == 2
                                                    ? Icons.lock_open_outlined
                                                    : Icons.email_outlined,
                                                size: 20,
                                                color: kLoginIconColor),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: TextFormField(
                                                controller: index == 0
                                                    ? _emailController
                                                    : index == 1
                                                        ? _passwordController
                                                        : index == 2
                                                            ? _cpasswordController
                                                            : null,
                                                obscureText: index == 1
                                                    ? obscureText
                                                    : index == 2
                                                        ? obscureText1
                                                        : false,
                                                onTapAlwaysCalled: true,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  hintText: '${texts[index]}',
                                                  hintStyle:
                                                      kLoginTextFieldTextStyle,
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    index == 0
                                                        ? _emailController
                                                            .text = value
                                                        : index == 1
                                                            ? _passwordController
                                                                .text = value
                                                            : index == 2
                                                                ? _cpasswordController
                                                                        .text =
                                                                    value
                                                                : null;
                                                  });
                                                },
                                              ),
                                            ),
                                            index == 1
                                                ? GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        obscureText =
                                                            !obscureText;
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0.0),
                                                      child: Icon(
                                                        obscureText
                                                            ? Icons.visibility
                                                            : Icons
                                                                .visibility_off,
                                                        color: kButtonColor,
                                                      ),
                                                    ),
                                                  )
                                                : index == 2
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            obscureText1 =
                                                                !obscureText1;
                                                          });
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.0),
                                                          child: Icon(
                                                            obscureText1
                                                                ? Icons
                                                                    .visibility
                                                                : Icons
                                                                    .visibility_off,
                                                            color: kButtonColor,
                                                          ),
                                                        ),
                                                      )
                                                    : Container(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            height: 280,
                          ),
                          Container(
                            width: size.width,
                            height: 65,
                            margin: EdgeInsets.only(bottom: 30, top: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: kButtonColor,
                              ),
                              child: Text('SignUp', style: kButtonTextStyle),
                              onPressed: () {
                                if (isValidForm()) {
                                  // submitPersonalDetails();
                                  Navigator.pushNamed(context, "/fregister");
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
