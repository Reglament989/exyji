import 'package:exyji/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Text(
              "About us",
              style: TextStyle(fontSize: 24),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text(
                "As if to tell us this is about me and the volunteers",
                style: TextStyle(fontSize: 18),
              ),
            ),
            Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "Maintainer",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  PhotoMember(),
                  Text("Reglament989"),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "Designer",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  PhotoMember(),
                  Text("Dasha03"),
                ],
              ),
            ),
            ReviewBlock()
          ],
        ),
      ),
    );
  }
}

class PhotoMember extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(50))),
    );
  }
}

class ReviewBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: InkWell(
        child: Container(
          width: 60,
          height: 60,
          child: SvgPicture.asset(Assets.github),
        ),
        onTap: () {
          launch("https://github.com/Reglament989/exyji.git");
        },
      ),
    );
  }
}
