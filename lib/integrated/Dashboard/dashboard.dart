import 'package:event/constants/styles.dart';
import 'package:event/utils/appManager.dart';
import 'package:event/widgets/headerAndFooterWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen(
      {Key? key,
      required this.title,
      required this.appManager,
      required this.isRegister})
      : super(key: key);

  final String title;
  final AppManager appManager;
  final bool isRegister;

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String token = '';
  late SharedPreferences prefs;
  String user_id = '';
  late FToast fToast;
  String name = '';

  Future<void> getDashboard(String user_id) async {
    if (user_id != "") {
      final requestBody = {"user_id": user_id};
      widget.appManager.apis
          .getDashboardRequest(
              requestBody, (prefs.getString('authToken') ?? ''))
          .then((response) async {
        // Handle successful response
        if (response?.status == 200) {
          //Success
          prefs.setString('sId', response?.user?.id ?? '');
          prefs.setString('authToken', response?.token ?? '');
          setState(() {
            name = response?.user?.first_name ??
                '' +
                    ' ' +
                    (response?.user?.middle_name ?? '') +
                    ' ' +
                    (response?.user?.last_name ?? '');
          });
          await widget.appManager.markLoggedIn(response?.token ?? '');
          await widget.appManager.initSocket(response?.token ?? '');
          var loggedIn = await widget.appManager.hasLoggedIn();
        } else if (response?.status == 201) {
          showToast(response?.message ?? '', 2, kToastColor, context);
        } else if (response?.status == 502) {
          showLogoutDialog(BuildContext context) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return LogoutAlert(
                  title: 'Active/Inactive Status',
                  subtitle: response?.message ?? '',
                  islogout: false,
                  logoutAction: () async {
                    await widget.appManager.clearLoggedIn();
                    if (widget.appManager.islogout == true) {
                      widget.appManager.utils.isPatientExitDialogShown = false;
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/obs', (route) => false);
                    }
                  },
                );
              },
            );
          }
        } else {
          print("Failed to get dashboard data");
        }
      }).catchError((error) {
        // Handle error
        print("Failed to get dashboard data: $error");
      });
    } else {
      showToast('Please get user_id', 2, kToastColor, context);
    }
  }

  Future<void> logout() async {
    String user_id = prefs.getString('sId') ?? '';
    final requestBody = {
      '': '',
    };
    widget.appManager.apis
        .logout(requestBody, (prefs.getString('authToken') ?? ''))
        .then((response) async {
      // Handle successful response
      if (response.status == 200) {
        // showToast(response?.message ?? '', 2, kPositiveToastColor, context);
        print('Performing logout action...');
        await widget.appManager.clearLoggedIn();
        if (widget.appManager.islogout == true) {
          widget.appManager.utils.isPatientExitDialogShown = false;
          Navigator.pushNamedAndRemoveUntil(context, '/obs', (route) => false);
        }
      } else if (response.status == 201) {
        showToast(response?.message ?? '', 2, kToastColor, context);
      } else {
        print("Failed to submit job details");
      }
    }).catchError((error) {
      // Handle error
      print("Failed to submit job details: $error");
    });
  }

  showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LogoutAlert(
          title: 'Logout Confirmation',
          subtitle: 'Are you sure you want to logout?',
          islogout: true,
          logoutAction: () async {
            Navigator.pop(context);
            logout();
          },
        );
      },
    );
  }

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          // child: Stack(
          //   clipBehavior: Clip.none,
          //   children: [
          child: Container(
            height: 280,
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 0, top: 0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/congrats.gif',
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 10),
                Text(
                  textAlign: TextAlign.center,
                  widget.isRegister
                      ? "Welcome to SeaJob"
                      : 'Welcome back to SeaJob',
                  style: kCongratsTextStyle,
                ),
                SizedBox(height: 34),
                Container(
                  width: size.width,
                  height: 65,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: kButtonColor,
                    ),
                    child: Text('Continue', style: kButtonTextStyle),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
          //     Positioned(
          //       right: -12,
          //       top: -10,
          //       child: GestureDetector(
          //         onTap: () {
          //           Navigator.of(context).pop();
          //         },
          //         child: Image.asset(
          //           'assets/cross.png',
          //           width: 40,
          //           height: 40,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        );
      },
    );
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
    fToast = FToast();
    getPrefs();
    fToast.init(context);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Navigator.pushNamed(context, "/welcome", arguments: widget.isRegister);
    // });
  }

  getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    token = prefs.getString('authToken') ?? '';
    user_id = prefs.getString('sId') ?? '';
    getDashboard(user_id);
  }

  final List<String> items = [
    'My Profile',
    'Job Search',
    'Bulk Resume Post',
    'Change Password',
    'Viewed By Company',
    'Hide/Unhide Company',
    'Shipping Companies(India)',
    'Logout',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        // Disable back button
        return false;
      },
      child: HeaderAndFooter(
        messageCount: 0,
        leading: Image.asset(
          'assets/appicon.png',
          width: 35, // Adjust width as needed
          height: 35, // Adjust height as needed
        ),
        titleText: 'Dashboard',
        fabFunction: null,
        homeFunction: () {
          Navigator.pushNamed(context, 'home');
        },
        profileFunction: null,
        appManager: widget.appManager,
        bodyWidget: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/searchjob");
                  },
                  child: Image.asset(
                    'assets/job.png', // Replace with your image path
                    width: size.width * 0.9, // Adjust image width as needed
                    height: 200, // Adjust image height as needed
                  ),
                ),
                
                Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 12.0, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, "/profile");
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color(0xFFe4f2fe),
                              ),
                              width: size.width * 0.43,
                              height: 130,
                              padding: EdgeInsets.fromLTRB(
                                  15, 10, 15, 10), // Padding from left and top
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: CircularIconContainer(
                                      icon: Icons
                                          .person_4_outlined, // Replace with your desired icon
                                      iconSize:
                                          25.0, // Adjust icon size as needed
                                      containerSize:
                                          45.0, // Adjust container size as needed
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'My Profile',
                                    style: kCardInactiveHeadingTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, "/searchjob");
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: kSecondBoxColor,
                              ),
                              width: size.width * 0.43,
                              height: 130,
                              padding: EdgeInsets.fromLTRB(
                                  15, 10, 0, 0), // Padding from left and top
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 13),
                                    child: Image.asset(
                                      'assets/search.png', // Replace with your image path
                                      width: 45, // Adjust image width as needed
                                      height:
                                          45, // Adjust image height as needed
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Job Search',
                                    style: kCardInactiveHeadingTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //2 Box Option

                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 12.0, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, "/bulkresume");
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: kSecondBoxColor,
                              ),
                              width: size.width * 0.43,
                              // height: 130,
                              padding: EdgeInsets.fromLTRB(
                                  15, 10, 0, 0), // Padding from left and top
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 13),
                                    child: Image.asset(
                                      'assets/resume.png', // Replace with your image path
                                      width: 45, // Adjust image width as needed
                                      height:
                                          45, // Adjust image height as needed
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 15, right: 10),
                                    child: Text(
                                      'Bulk Resume Post',
                                      style: kCardInactiveHeadingTextStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                "/resetPassword",
                                arguments: {
                                  'title': 'Reset Password',
                                  'appManager': widget.appManager,
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color(0xFFe4f2fe),
                              ),
                              width: size.width * 0.43,
                              // height: 130,
                              padding: EdgeInsets.fromLTRB(
                                  15, 10, 0, 0), // Padding from left and top
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: CircularIconContainer(
                                      icon: Icons
                                          .lock_open, // Replace with your desired icon
                                      iconSize:
                                          25.0, // Adjust icon size as needed
                                      containerSize:
                                          45.0, // Adjust container size as needed
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: Text(
                                      'Change Password',
                                      style: kCardInactiveHeadingTextStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //Horizontal Options
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/viewedcompany",
                        );
                      },
                      child: Container(
                        width: size.width * 0.92,
                        margin: EdgeInsets.only(top: 15, bottom: 12),
                        padding:
                            EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: backgroundColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircularIconContainer(
                              icon: Icons
                                  .factory, // Replace with your desired icon
                              iconSize: 25.0, // Adjust icon size as needed
                              containerSize:
                                  45.0, // Adjust container size as needed
                            ),
                            // Image.asset(
                            //   'assets/company.png', // Replace with your image path
                            //   width: 45, // Adjust image width as needed
                            //   height: 45, // Adjust image height as needed
                            // ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(
                                'Viewed By Company',
                                style: kCardInactiveHeadingTextStyle,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: kButtonColor,
                            )
                          ],
                        ),
                      ),
                    ),
                    //2nd container
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/hidecompany",
                            arguments: 'hide');
                      },
                      child: Container(
                        width: size.width * 0.92,
                        margin: EdgeInsets.only(top: 15, bottom: 12),
                        padding:
                            EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: backgroundColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/hide.png', // Replace with your image path
                              width: 45, // Adjust image width as needed
                              height: 45, // Adjust image height as needed
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(
                                'Hide/Unhide Company',
                                style: kCardInactiveHeadingTextStyle,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: kButtonColor,
                            )
                          ],
                        ),
                      ),
                    ),
                    //3rd company

                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/shipcompany",
                        );
                      },
                      child: Container(
                        width: size.width * 0.92,
                        margin: EdgeInsets.only(top: 15, bottom: 12),
                        padding:
                            EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: backgroundColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/ship.png', // Replace with your image path
                              width: 45, // Adjust image width as needed
                              height: 45, // Adjust image height as needed
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(
                                'Shipping Companies(India)',
                                style: kCardInactiveHeadingTextStyle,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: kButtonColor,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//Logout Class
class LogoutAlert extends StatelessWidget {
  final VoidCallback logoutAction; // Callback for logout action
  final String title;
  final String subtitle;
  final bool islogout;
  LogoutAlert(
      {required this.logoutAction,
      required this.title,
      required this.subtitle,
      required this.islogout});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: kHeaderTextStyle,
      ),
      content: Text(
        subtitle,
        style: kObsText,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(
            islogout ? 'Cancel' : 'Ok',
            style: kBackTextStyle,
          ),
        ),
        islogout
            ? TextButton(
                onPressed: logoutAction,
                child: Text(
                  'Logout',
                  style: kBackTextStyle,
                ),
              )
            : Container(),
      ],
    );
  }
}

class Content {
  final String text;
  final Color color;

  Content({required this.text, required this.color});
}

class CircularIconContainer extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final double containerSize;

  const CircularIconContainer({
    required this.icon,
    required this.iconSize,
    required this.containerSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kButtonColor, // Background color of the container
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: Colors.white, // Color of the icon
      ),
    );
  }
}
