import 'package:flutter/material.dart';

class PopItem extends StatelessWidget {
  final IconData icon;
  final String descript;

  const PopItem({Key? key, required this.icon, required this.descript})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(icon),
        ),
        Text(descript)
      ],
    );
  }
}
