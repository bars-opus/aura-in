import 'package:flutter/material.dart';
import 'package:nano_embryo/core/account_lifecycle/config/account_lifecycle_texts.dart';

class AccountLifecycleConfirmationFields extends StatelessWidget {
  final AccountLifecycleTexts texts;
  final bool usesPassword;
  final String phrase;
  final int reasonMaxLength;
  final TextEditingController passwordController;
  final TextEditingController phraseController;
  final TextEditingController reasonController;

  const AccountLifecycleConfirmationFields({
    super.key,
    required this.texts,
    required this.usesPassword,
    required this.phrase,
    required this.reasonMaxLength,
    required this.passwordController,
    required this.phraseController,
    required this.reasonController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (usesPassword)
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: texts.passwordConfirmLabel,
              hintText: texts.passwordConfirmHint,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            obscureText: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.password],
          )
        else
          TextFormField(
            controller: phraseController,
            decoration: InputDecoration(
              labelText: texts.phraseConfirmLabel(phrase),
              hintText: phrase,
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
          ),
        const SizedBox(height: 16),
        TextFormField(
          controller: reasonController,
          decoration: InputDecoration(
            labelText: texts.reasonLabel,
            hintText: texts.reasonHint,
            prefixIcon: const Icon(Icons.notes_outlined),
          ),
          minLines: 3,
          maxLines: 5,
          maxLength: reasonMaxLength,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
