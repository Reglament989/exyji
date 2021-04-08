import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Not have account? Sign up >",
          style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.5)),
        ),
        Row(
          children: [
            Text("Change server",
                style: TextStyle(
                    fontSize: 13, color: Colors.black.withOpacity(0.5))),
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.info,
                  size: 18,
                  color: Colors.black.withOpacity(0.5),
                ))
          ],
        )
      ],
    );
  }
}
