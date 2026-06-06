// lib/presentation/features/shops/dashboard/data/exceptions/client_notes_exceptions.dart
//
// ClientNoteException hierarchy. Same shape as BusinessHoursException
// and ServiceManagementException: every subtype carries a stable `code`
// the UI can switch on without parsing English strings, plus a
// `userMessage` safe to render directly. `message` is internal/debug
// only and MUST NOT reach the UI.

class ClientNoteException implements Exception {
  /// Internal/debug message. Logs only. May contain ids.
  final String message;

  /// Stable identifier the UI maps to localized copy.
  final String code;

  /// Sanitized, user-facing message safe to show as-is.
  final String userMessage;

  ClientNoteException(
    this.message, {
    this.code = 'NOTE_GENERIC',
    String? userMessage,
  }) : userMessage = userMessage ?? 'Something went wrong. Please try again.';

  @override
  String toString() => 'ClientNoteException($code): $message';
}

class NoteAccessDeniedException extends ClientNoteException {
  NoteAccessDeniedException()
      : super(
          'Caller is not the shop owner (42501)',
          code: 'NOTE_ACCESS_DENIED',
          userMessage: "You don't have access to this note.",
        );
}

class NotePayloadInvalidException extends ClientNoteException {
  NotePayloadInvalidException()
      : super(
          'Note payload failed server-side validation (22023)',
          code: 'NOTE_PAYLOAD_INVALID',
          userMessage: 'Please re-check the note.',
        );
}

class NoteTooLongException extends ClientNoteException {
  NoteTooLongException()
      : super(
          'Note body exceeded 2000 chars',
          code: 'NOTE_TOO_LONG',
          userMessage: 'The note is too long. Please shorten it.',
        );
}

class NoteSaveFailedException extends ClientNoteException {
  NoteSaveFailedException()
      : super(
          'upsert_client_note RPC failed (unmapped error)',
          code: 'NOTE_SAVE_FAILED',
          userMessage: "We couldn't save the note. Please try again.",
        );
}
