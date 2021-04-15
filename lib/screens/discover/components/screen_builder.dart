import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_reload/constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DiscoverScreen extends StatelessWidget {
  final String header;
  final String lorem;
  final String lottieAsset;
  final Color backgroundColor;
  final Function nextScreen;
  final bool isSkiped;
  final String buttonTitle;

  const DiscoverScreen({
    Key? key,
    required this.header,
    required this.lorem,
    required this.lottieAsset,
    required this.backgroundColor,
    required this.nextScreen,
    this.isSkiped = false,
    this.buttonTitle = "Next",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 30, right: 30),
        child: Column(
          children: [
            if (isSkiped)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 50),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.red.withOpacity(0.8)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0)))),
                      child: Text(
                        "Skip",
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      ),
                      onPressed: () {
                        nextScreen();
                      },
                    ),
                  )
                ],
              ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 30),
                      width: 150,
                      height: 150,
                      child: Lottie.asset(this.lottieAsset)),
                  Container(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Text(
                      header,
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    lorem,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)))),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                      child: Text(
                        buttonTitle,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    onPressed: () {
                      if (buttonTitle != "Next") {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRouter.home);
                        return;
                      }
                      nextScreen();
                    },
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
