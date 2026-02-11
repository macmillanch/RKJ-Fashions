import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/auth_service.dart';
import 'data/services/database_service.dart';
import 'data/providers/cart_provider.dart';
import 'data/providers/wishlist_provider.dart';
import 'core/theme/user_theme.dart';
import 'core/theme/admin_theme.dart';
import 'ui/admin/admin_home_screen.dart';
import 'ui/user/user_home_screen.dart';
import 'data/services/update_service.dart';
import 'ui/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => DatabaseService()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProxyProvider2<
          AuthService,
          DatabaseService,
          WishlistProvider
        >(
          create: (_) => WishlistProvider(),
          update: (_, auth, db, wishlist) =>
              wishlist!..update(db, auth.currentUser?.id),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp(
            title: 'RKJ Fashions',
            debugShowCheckedModeBanner: false,
            // Simple role-based theme
            theme: authService.isAdmin ? AdminTheme.theme : UserTheme.theme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Try auto-login on startup
    Future.microtask(() async {
      if (mounted) {
        await context.read<AuthService>().tryAutoLogin();
        // Check for updates after auto-login attempt
        if (mounted) {
          UpdateService.checkForUpdates(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 150),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    if (authService.currentUser != null) {
      if (authService.isAdmin) {
        return const AdminHomeScreen();
      }
      return const UserHomeScreen();
    }

    // Default to UserHomeScreen for guests
    return const UserHomeScreen();
  }
}
