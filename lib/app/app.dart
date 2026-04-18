import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class CatoApp extends StatefulWidget {
  const CatoApp({super.key});

  @override
  State<CatoApp> createState() => _CatoAppState();
}

class _CatoAppState extends State<CatoApp> {
  late final _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cato',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

