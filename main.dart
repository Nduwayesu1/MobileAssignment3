import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:calculator/theme_provider.dart';
import 'package:calculator/language_provider.dart';
import 'package:calculator/signin.dart';
import 'package:calculator/signup.dart';
import 'package:calculator/calculator.dart';
import 'package:calculator/battery.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Theme provider
        ChangeNotifierProvider(create: (_) => LanguageProvider()), // Language provider
        // Add other providers as needed
      ],
      child: MyApp(),
    ),
  );

  // Initialize connectivity check
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
    bool isConnected = await _checkInternetConnectivity();
    String message = isConnected ? 'Connected' : 'No internet connection';
    MyApp.homeKey.currentState?.updateConnectivity(result, message);
  });
}

Future<bool> _checkInternetConnectivity() async {
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      final response = await http.head(Uri.parse('https://example.com'));
      return response.statusCode == 200;
    }
    return false;
  } catch (e) {
    return false;
  }
}

class MyApp extends StatelessWidget {
  static final GlobalKey<MyHomePageState> homeKey = GlobalKey();

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tab Navigation Demo',
      home: MyHomePage(
        key: homeKey,
        connectivityResult: ConnectivityResult.none, // Initial value, can be updated later
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        // Add more delegates for localization if needed
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('fr', 'FR'),
        // Add more locales as needed
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale!.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first; // Default locale
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ConnectivityResult connectivityResult;

  const MyHomePage({
    Key? key,
    required this.connectivityResult,
  }) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  ConnectivityResult _connectivityResult = ConnectivityResult.none;

  @override
  void initState() {
    super.initState();
    _connectivityResult = widget.connectivityResult;
  }

  void updateConnectivity(ConnectivityResult result, String message) {
    setState(() {
      _connectivityResult = result;
    });
    // Show SnackBar with connectivity message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildBody() {
    if (_connectivityResult == ConnectivityResult.none) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'No internet connection',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => SwitchListTile(
              title: Text('Dark Mode'),
              value: themeProvider.getTheme().brightness == Brightness.dark,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _showLanguagePicker(context);
            },
            child: Text('Select Language'),
          ),
          Expanded(
            child: TabBarView(
              children: [
                SignIn(), // Use SignInScreen widget
                SignUp(), // Use SignUpScreen widget
                Calculator(), // Use CalculatorScreen widget
                BatteryLevelDemo(), // Include BatteryLevelDemo widget
              ],
            ),
          ),
        ],
      );
    }
  }

  // Function to display language selection dialog
  void _showLanguagePicker(BuildContext context) {
    LanguageProvider languageProvider = context.read<LanguageProvider>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languageProvider.getSupportedLocales().map((locale) {
              return ListTile(
                title: Text(locale.languageCode.toUpperCase()),
                onTap: () {
                  languageProvider.changeLanguage(locale);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Color backgroundColor = themeProvider.getBackgroundColor();

    return DefaultTabController(
      length: 4, // Number of tabs including BatteryLevelDemo
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My App'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: Icon(Icons.login),
                title: Text('Sign In'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignIn()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.person_add),
                title: Text('Sign Up'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUp()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.calculate),
                title: Text('Calculator'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Calculator()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.battery_full),
                title: Text('Battery Level'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BatteryLevelDemo()),
                  );
                },
              ),
            ],
          ),
        ),
        body: Container( // Wrap with Container to set background color
          color: backgroundColor,
          child: _buildBody(),
        ),
        bottomNavigationBar: Container(
          color: Color.fromRGBO(93, 13, 231, 1),
          child: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.login), text: 'Sign In'),
              Tab(icon: Icon(Icons.person_add), text: 'Sign Up'),
              Tab(icon: Icon(Icons.calculate), text: 'Calculator'),
              Tab(icon: Icon(Icons.battery_full), text: 'Battery'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            String message = _connectivityResult == ConnectivityResult.none
                ? 'No internet connection'
                : 'Connected';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
          child: Icon(Icons.network_check),
        ),
      ),
    );
  }
}
