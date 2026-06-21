/// Strips URLs and schema/table/policy identifiers from provider messages
/// before they leave the repo. Pairs with checklist 2.4 (don't leak
/// internals) and 5.5 (don't surface them in UI).
String feedbackSafeMessage(String raw) {
  return raw
      .replaceAll(RegExp(r'https?://\S+'), '[url]')
      .replaceAll(RegExp(r'"public"\.\w+'), '[table]')
      .replaceAll(RegExp(r'relation "\w+"'), 'relation [table]');
}
