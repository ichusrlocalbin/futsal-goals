import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/futsal_score_screen.dart';
import 'screens/yearly_score_screen.dart';
import 'screens/login_screen.dart';
import 'screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Futsal Scoreboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) => AuthenticationWrapper(settings),
    );
  }
}

class AuthenticationWrapper extends MaterialPageRoute {
  final RouteSettings settings;
  AuthenticationWrapper(
    this.settings,
  ) : super(
          builder: (context) {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              return LoginPage();
            }
            if (settings.name == Screen.futsalScore.name) {
              return const FutsalScorePage(title: '得点記録');
            } else if (settings.name == Screen.yearlyScore.name) {
              return YearlyScorePage();
            } else {
              return const FutsalScorePage(title: '得点記録');
            }
          }
      );
}
