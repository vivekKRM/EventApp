import 'package:event/constants/styles.dart';
import 'package:event/utils/appManager.dart';
import 'package:event/widgets/headerAndFooterWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../json/eventResponse.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({
    Key? key,
    required this.title,
    required this.appManager,
  }) : super(key: key);

  final String title;
  final AppManager appManager;

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String token = '';
  late SharedPreferences prefs;
  int user_id = 0;
  late FToast fToast;
  List<Result?> events = [];
  String name = '';
  String _appVersion = 'Unknown';

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion =
          'Version: ${info.version}, Build Number: ${info.buildNumber}';
    });
  }

  Future<void> getDashboard(int user_id) async {
    if (user_id == 0) {
      final requestBody = {"user_id": user_id};
      widget.appManager.apis
          .getDashboardRequest(
              requestBody, (prefs.getString('authToken') ?? ''), _appVersion)
          .then((response) async {
        // Handle successful response
        if (response?.status == 200) {
          setState(() {
            events = response?.event_data ?? [];
          });
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
    int user_id = prefs.getInt('sId') ?? 0;
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
    user_id = prefs.getInt('sId') ?? 0;
    _initPackageInfo();
    getDashboard(user_id);
  }

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
        keepFooter: true,
        fabFunction: null,
        homeFunction: () {
          Navigator.pushNamed(context, 'home');
        },
        profileFunction: null,
        appManager: widget.appManager,
        bodyWidget: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: List.generate(
                (events.length / 2).ceil(),
                (index) {
                  int currentIndex = index * 2;
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left item
                        if (currentIndex < events.length)
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // Handle onTap event
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Image covering half the height
                                    Container(
                                      height: 80, // Adjust height as needed
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                        image: DecorationImage(
                                          image: AssetImage('assets/event.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    // Three labels below the image
                                    Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            events[currentIndex]?.name ?? '',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                              events[currentIndex]?.sub_title ??
                                                  ''),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_month,
                                                size: 20,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                '${events[currentIndex]?.start_month ?? ''} ${events[currentIndex]?.start_date ?? ''} - ${events[currentIndex]?.month_name ?? ''} ${events[currentIndex]?.end_date ?? ''}, ${events[currentIndex]?.year ?? ''}',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        // Right item
                        if (currentIndex + 1 < events.length)
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // Handle onTap event
                              },
                              child: Container(
                                margin: EdgeInsets.only(left: 10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Image covering half the height
                                    Container(
                                      height: 80, // Adjust height as needed
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20)),
                                        image: DecorationImage(
                                          image: AssetImage('assets/event.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    // Three labels below the image
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            events[currentIndex + 1]?.name ??
                                                '',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(events[currentIndex + 1]
                                                  ?.sub_title ??
                                              ''),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_month,
                                                size: 20,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                '${events[currentIndex]?.start_month ?? ''} ${events[currentIndex]?.start_date ?? ''} - ${events[currentIndex]?.month_name ?? ''} ${events[currentIndex]?.end_date ?? ''}, ${events[currentIndex]?.year ?? ''}',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
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

