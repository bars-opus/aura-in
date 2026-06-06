// test/dashboard/data/exceptions/client_notes_exceptions_test.dart
//
// Locks the shape contract of the ClientNoteException hierarchy.
// The UI switches on `code` and renders `userMessage` directly; any
// change here is intentional and should be reviewed against UI copy
// at the same time.

import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/client_notes_exceptions.dart';

void main() {
  group('ClientNoteException (base)', () {
    test('default code is NOTE_GENERIC', () {
      final e = ClientNoteException('boom');
      expect(e.code, 'NOTE_GENERIC');
    });

    test('default userMessage is safe to render', () {
      final e = ClientNoteException('boom');
      expect(e.userMessage, 'Something went wrong. Please try again.');
      expect(e.userMessage, isNot(contains('boom')));
    });

    test('toString embeds code + internal message', () {
      final e = ClientNoteException('boom');
      expect(e.toString(), 'ClientNoteException(NOTE_GENERIC): boom');
    });
  });

  group('Subtype contracts', () {
    test('NoteAccessDeniedException', () {
      final e = NoteAccessDeniedException();
      expect(e.code, 'NOTE_ACCESS_DENIED');
      expect(e.userMessage, "You don't have access to this note.");
    });

    test('NotePayloadInvalidException', () {
      final e = NotePayloadInvalidException();
      expect(e.code, 'NOTE_PAYLOAD_INVALID');
      expect(e.userMessage, 'Please re-check the note.');
    });

    test('NoteTooLongException', () {
      final e = NoteTooLongException();
      expect(e.code, 'NOTE_TOO_LONG');
      expect(e.userMessage, 'The note is too long. Please shorten it.');
    });

    test('NoteSaveFailedException', () {
      final e = NoteSaveFailedException();
      expect(e.code, 'NOTE_SAVE_FAILED');
      expect(e.userMessage, "We couldn't save the note. Please try again.");
    });
  });
}
