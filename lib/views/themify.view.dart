import 'package:flutter/material.dart';


class ThemifyView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ThemifyViewState();
  }
}

class ThemifyViewState extends State<ThemifyView> {
  static final data = [{'name': 'Test', 'description': 'this a test'}];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Themify'),),
      body: ListView.builder(
        itemBuilder: (BuildContext context, idx) => ListTile(title: Text(data[idx]['name']), subtitle: Text(data[idx]['description'])),
      ),
    );
  }
}