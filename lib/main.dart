import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/router.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/providers/tenant_provider.dart';
import 'package:metrixvox_admin/providers/dashboard_provider.dart';
import 'package:metrixvox_admin/providers/kiosks_provider.dart';
import 'package:metrixvox_admin/providers/responses_provider.dart';
import 'package:metrixvox_admin/providers/users_provider.dart';

void main() {
  runApp(
	MultiProvider(
	  providers: [
	    ChangeNotifierProvider(create: (_) => AuthProvider()..bootstrap()),
	    ChangeNotifierProvider(create: (_) => TenantProvider()),
	    ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ChangeNotifierProvider(create: (_) => KiosksProvider()),  // 🆕
      ChangeNotifierProvider(create: (_) => ResponsesProvider()),  // 🆕
      ChangeNotifierProvider(create: (_) => UsersProvider()),      // 🆕
     	],
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
  bool _tenantsLoaded = false;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.build(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    // Cargar tenants cuando el usuario se autentica
    final auth = context.watch<AuthProvider>();

    if (auth.isAuthenticated && !_tenantsLoaded && auth.token != null) {
      _tenantsLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TenantProvider>().loadTenants(auth.token!);
      });
    } else if (!auth.isAuthenticated && _tenantsLoaded) {
      _tenantsLoaded = false;
    }

    return MaterialApp.router(
      title: 'MetrixVox Admin',
      theme: AdminTheme.light(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
