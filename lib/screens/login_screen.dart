import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'futsal_score_screen.dart';

class LoginPage extends StatelessWidget {
  Future<UserCredential> _signInWithGoogle() async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('email');
    googleProvider.setCustomParameters({'login_hint': 'user@gmail.com'});
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }

  Future<User?> _handleSignIn() async {
    final UserCredential userCredential = await _signInWithGoogle();
    return userCredential.user;
  }

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Future<User?> _handleSignIn() async {
  //   final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //   if (googleUser != null) {
  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //     final UserCredential userCredential = await _auth.signInWithCredential(credential);
  //     return userCredential.user;
  //   }
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ログイン")),
      body: Center(
        child: OutlinedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            onPressed: () async {
              User? user = await _handleSignIn();
              if (user != null) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const FutsalScorePage(title: 'Futsal Scoreboard')));
              }
            },
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage("assets/google_logo.png"),
                    height: 35.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
