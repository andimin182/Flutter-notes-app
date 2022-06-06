import 'package:flutter/material.dart';
import 'package:notes2/constants/routes.dart';
import 'package:notes2/enum/menu_enum.dart';
import 'package:notes2/services/auth/auth_service.dart';
import 'package:notes2/services/crud/notes_service.dart';
import 'package:notes2/utilities/dialog/logout_dialog.dart';
import 'package:notes2/views/notes/notes_list_view.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late final NotesService _notesService;
  // Functionality that grabes the user email
  // ! conversion from a nullable to a non nullable type
  String get userEmail => AuthService.firebase().currentUser!.email!;

// Initializing the DB => we need one init for all: SINGLETON
// NOTE: we don't need to open the DB since the function _ensureDbIsOpened is called within the notes_Service
  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  /* Closing the DB when disposing the page => Problem: we close the DB wnever we do a HotReload, hence we
  do not use the dispose for  now
  
  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes'), actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(newNoteRoute);
          },
          icon: const Icon(Icons.add),
        ),
        PopupMenuButton<Menu>(
          itemBuilder: (context) => <PopupMenuEntry<Menu>>[
            const PopupMenuItem<Menu>(
              value: Menu.logout,
              child: Text('Logout'),
            ),
          ],
          onSelected: (value) async {
            switch (value) {
              case Menu.logout:
                final logout = await showLogoutDialog(context);
                if (logout) {
                  await AuthService.firebase().logOut();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                }
            }
          },
        )
      ]),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Text('waiting');
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        return NotesListView(
                          notes: allNotes,
                          onDeletedNote: (note) async {
                            await _notesService.deleteNote(id: note.id);
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );

            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
