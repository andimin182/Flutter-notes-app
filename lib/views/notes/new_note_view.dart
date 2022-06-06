import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:notes2/services/auth/auth_service.dart';
import 'package:notes2/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({Key? key}) : super(key: key);

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  // Variables to keep hold of: Note, noteService, textediting controller
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;
  late Future<DatabaseNote> _futureNote;

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    _futureNote = createNewNote();
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

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    log('Inside createNewNote');
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    log(email);
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
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
        future: _futureNote,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              log('connection done');
              if (snapshot.hasData) {
                _note = snapshot.data as DatabaseNote?;
                log('note from snap: $_note');

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
