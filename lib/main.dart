import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:letmegrab_todo/firebase_options.dart';
import 'package:path_provider/path_provider.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/todo_bloc.dart';
import 'data/todo_repository.dart';
import 'models/todo.dart';
import 'pages/login_page.dart';
import 'pages/todo_details_page.dart';
import 'pages/todo_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);

  Hive
    .registerAdapter(TodoStatusAdapter());
   Hive .registerAdapter(TodoAdapter());

  await TodoRepository.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => TodoBloc(TodoRepository.instance)),
      ],
      child: MaterialApp(
        title: 'LetMeGrab TODO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AuthRouter(),
        routes: {
          '/details': (_) => const TodoDetailsPage(),
        },
      ),
    );
  }
}

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          return const TodoListPage();
        }
        return const LoginPage();
      },
    );
  }
}