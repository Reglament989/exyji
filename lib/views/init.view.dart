import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InitView extends StatefulWidget {
  static final routeName = '/init';
  @override
  State<StatefulWidget> createState() {
    return InitViewState();
  }
}

class InitViewState extends State<InitView> {
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      Future.delayed(Duration.zero,
              () => {Navigator.of(context).pushReplacementNamed('/home')});
    } else {
      Future.delayed(Duration.zero, () =>
          Navigator.of(context).pushReplacementNamed('/login'));
    }
    return Scaffold(
      body: Center(),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
