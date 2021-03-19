import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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
      Future.delayed(Duration.zero, () => Navigator.of(context).pushReplacementNamed('/login'));
    }
    return Scaffold(
        body: Center(),
    );
  }
  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        Navigator.pushNamed(context, deepLink.path);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      Navigator.pushNamed(context, deepLink.path);
    }
  }

  @override
  void initState() {
    super.initState();
    this.initDynamicLinks();
  }
}
