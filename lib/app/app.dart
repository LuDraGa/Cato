import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';
import 'router.dart';
import 'theme.dart';

class CatoApp extends ConsumerStatefulWidget {
  const CatoApp({super.key});

  @override
  ConsumerState<CatoApp> createState() => _CatoAppState();
}

class _CatoAppState extends ConsumerState<CatoApp> {
  late final _router = createRouter();

  @override
  Widget build(BuildContext context) {
    // Rebuild on any aesthetic change (theme, typography, sound, haptic)
    ref.watch(aestheticRevisionProvider);
    ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Cato',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
