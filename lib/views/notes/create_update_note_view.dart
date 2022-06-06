import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:notes2/services/auth/auth_service.dart';
import 'package:notes2/services/crud/notes_service.dart';
import 'package:notes2/utilities/generics/get_arguments.dart';

class CreateUpdateView extends StatefulWidget {
  const CreateUpdateView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateView> createState() => _CreateUpdateViewState();
}

class _CreateUpdateViewState extends State<CreateUpdateView> {
  // Variables to keep hold of: Note, noteService, textediting controller
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _saveNoteIfTextNotEmpty();
    _deleteNoteIfTextEmpty();
    _textController.dispose();
    super.dispose();
  }

  void _deleteNoteIfTextEmpty() {
    final note = _note;
    final text = _textController.text;
    log('deleteNoteIfEmpty');
    log(text);
    if (text.isEmpty && note != null) {
      log('Text controller empty');
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    log('saveNoteIfNotEmpty');
    final note = _note;
    final text = _textController.text;
    log(text);
    if (text.isNotEmpty && note != null) {
      log(text);
      await _notesService.updateNote(note: note, text: text);
    }
  }

  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNote>();
    if (widgetNote != null) {
      // it means that the user has tapped on an existing note => we want to UPDATE it
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }
    // otherwiae, if the wigetNote is null, then we create the note
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    log('Inside createNewNote');
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    log(email);
    final owner = await _notesService.getUser(email: email);
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      note: note,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              log('connection done');
              if (snapshot.hasData) {
                //_note = snapshot.data as DatabaseNote?;
                _setupTextControllerListener();
                return TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                      hintText: 'Start typing your note...'),
                );
              } else {
                return const Text('Error: No data');
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
