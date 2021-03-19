import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class InviteViewArguments {
  final String inviteString;

  InviteViewArguments({this.inviteString});
}

class InviteView extends StatefulWidget {
  static final routeName = '/invite';
  @override
  State<StatefulWidget> createState() {
    return InviteViewState();
  }
}

class InviteViewState extends State<InviteView> {
  Uri dynamicUrl;
  InviteViewArguments args;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Share'), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Text("Share this qr code or url for invite someone to your room", textAlign: TextAlign.center, style: TextStyle(
                    fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),),
              ),
              QrImage(
                data: dynamicUrl.toString(),
                version: QrVersions.auto,
                size: 400.0,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 30),
                child: TextButton(onPressed: () => Share.share(dynamicUrl.toString(), subject: 'Link for joining in my room'), child: Text("Click to share link")),
              )
            ],
          ),
        ),
      );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context).settings.arguments;
    this.makeLink();
  }

  Future<void> makeLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://androchat.page.link',
      link: Uri.parse('https://androchat.page.link/${args.inviteString}'),
      androidParameters: AndroidParameters(
        packageName: 'com.andro_x',
      )
    );

    dynamicUrl = (await parameters.buildShortLink()).shortUrl;
  }
}
