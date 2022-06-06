import 'package:flutter/material.dart';
import 'package:notes2/constants/routes.dart';
import 'package:notes2/services/auth/auth_service.dart';
import 'package:notes2/views/email_verification.dart';
import 'package:notes2/views/login.dart';
import 'package:notes2/views/notes/notes_view.dart';
import 'package:notes2/views/register.dart';

import 'views/notes/create_update_note_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        loginRoute: (context) => const LoginPage(),
        registerRoute: ((context) => const RegisterPage()),
        notesRoute: ((context) => const NotesPage()),
        verifyEmailRoute: ((context) => const VerifyEmailView()),
        createOrUpdateNoteRoute: ((context) => const CreateUpdateView()),
      },
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
                  return const NotesPage();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginPage();
              }

            default:
              {
                return const CircularProgressIndicator();
              }
          }
        });
  }
}
