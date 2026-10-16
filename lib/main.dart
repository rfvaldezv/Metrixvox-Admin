import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/router.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..bootstrap(),
      child: const MetrixVoxAdminApp(),
    ),
  );
}

class MetrixVoxAdminApp extends StatefulWidget {
  const MetrixVoxAdminApp({super.key});

  @override
  State<MetrixVoxAdminApp> createState() => _MetrixVoxAdminAppState();
}

class _MetrixVoxAdminAppState extends State<MetrixVoxAdminApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.build(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MetrixVox Admin',
      theme: AdminTheme.light(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
