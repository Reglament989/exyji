import 'package:exyji/blocs/bloc/login_bloc.dart';
import 'package:exyji/ui/login/components/body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    return Scaffold(
      body: BlocBuilder(
        bloc: LoginBloc(),
        builder: (context, state) => Body(),
      ),
    );
  }
}
