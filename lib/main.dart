import 'package:event/EmailVerify/EmailVerify.dart';
import 'package:event/NewUser/NewUser.dart';
import 'package:event/integrated/Dashboard/dashboard.dart';
import 'package:event/integrated/Forget/forgetPassword.dart';
import 'package:event/integrated/Login/login.dart';
import 'package:event/integrated/OnBoarding/initial.dart';
import 'package:event/integrated/Register/finalRegister.dart';
import 'package:event/integrated/Register/register.dart';
import 'package:event/utils/appManager.dart';
import 'package:flutter/material.dart';
// Added on 29 Feb
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences pref = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: pref));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key, required this.prefs}) : super(key: key);
  final SharedPreferences prefs;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppManager appManager;
  late Map<String, WidgetBuilder> routes;

  @override
  void initState() {
    super.initState();
    var envMode = "prod";
    appManager = AppManager(envMode, widget.prefs);

    appManager.hasLoggedIn().then((result) {
      if (result['hasLoggedIn']) {
        appManager.initSocket(result['authToken']);
      }
    });

    routes = {
      // Integrated routes
      '/': (context) =>
          InitialScreen(title: 'SplashScreen', appManager: appManager),
      '/emailverify': (context) =>
          EmailVerify(title: 'Email Verify', appManager: appManager),
      
      '/forgetPassword': (context) =>
          ForgetPassword(title: 'Forget Password', appManager: appManager),
      '/home': (context) => DashboardScreen(
          title: 'Home', appManager: appManager, isRegister: false),
      '/register': (context) =>
          Register(title: 'Register', appManager: appManager),
      '/fregister': (context) =>
          FinalRegister(title: 'Register', appManager: appManager),
      // Add more routes as needed
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event App',
      onGenerateRoute: _getRoute,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      builder: (context, child) {
        widget.prefs.setDouble(
            "textScalingFactor", MediaQuery.of(context).textScaleFactor);
        return MediaQuery(
          child: child ?? Container(),
          data: MediaQuery.of(context).copyWith(textScaleFactor: 0.845),
        );
      },
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    appManager.currentPage = settings.name ?? '';
    Widget temp;
    return PageRouteBuilder(
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        switch (settings.name) {
          case '/login':
            final String someValue = settings.arguments as String;
            temp = Login(
              title: 'Login',
              appManager: appManager,
              email: someValue,
            );
            break;

            case '/newuser':
            final String value = settings.arguments as String;
            temp = NewUser(title: 'New User',
             appManager: appManager, 
             email: value);
             break;
          default:
            temp = routes[settings.name]!(context);
        }
        this.appManager.currentPageObject = temp;
        return temp;
      },
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) =>
          SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return MaterialPageRoute(
      settings: settings,
      builder: (ctx) => builder,
    );
  }

  void _launchStoreURL() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      final Uri url = Uri.parse('docuvitals://');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        const playStorePackageName = 'com.docuvitals.health';
        final playStoreURL =
            'https://play.google.com/store/apps/details?id=$playStorePackageName';

        if (await canLaunch(playStoreURL)) {
          await launch(playStoreURL);
        } else {
          throw 'Could not launch Play Store URL';
        }
      }
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      final Uri url = Uri.parse('docuvitals://');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        const appStoreID = '1554906931';
        final appStoreURL = 'https://apps.apple.com/app/$appStoreID';

        if (await canLaunch(appStoreURL)) {
          await launch(appStoreURL);
        } else {
          throw 'Could not launch App Store URL';
        }
      }
    }
  }
}

class NotFoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page Not Found')),
      body: Center(child: Text('Page Not Found')),
    );
  }
}
