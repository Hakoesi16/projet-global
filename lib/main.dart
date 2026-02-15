import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send/executt/begin.dart';
import 'package:send/executt/five.dart';
import 'package:send/executt/succes.dart';

import 'cubit/authcubit.dart';

void main() {
  runApp(
      BlocProvider(
        create: (_) => AuthCubit(),
        child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Begin(),
    );
  }
}
