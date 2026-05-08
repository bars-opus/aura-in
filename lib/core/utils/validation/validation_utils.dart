// lib/core/utils/validation_utils.dart
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Configuration for validation rules and messages
class ValidationConfig {
  final String languageCode;
  final ValidationMessages messages;

  ValidationConfig({this.languageCode = 'en', ValidationMessages? messages})
    : messages = messages ?? ValidationMessages();

  factory ValidationConfig.en() => ValidationConfig(languageCode: 'en');

  factory ValidationConfig.es() =>
      ValidationConfig(languageCode: 'es', messages: ValidationMessages.es());
}

/// Localized validation messages
class ValidationMessages {
  final String required;
  final String invalidEmail;
  final String disposableEmail;
  final String passwordLength;
  final String passwordUppercase;
  final String passwordLowercase;
  final String passwordDigit;
  final String passwordSpecialChar;
  final String weakPassword;
  final String invalidPhone;
  final String invalidUrl;
  final String urlHttpsRequired;
  final String nameLength;
  final String nameInvalidChars;
  final String nameMultipleSpaces;
  final String invalidNumber;
  final String numberMin;
  final String numberMax;
  final String dateFutureNotAllowed;
  final String dateBeforeMin;
  final String dateAfterMax;

  ValidationMessages({
    String? required,
    String? invalidEmail,
    String? disposableEmail,
    String? passwordLength,
    String? passwordUppercase,
    String? passwordLowercase,
    String? passwordDigit,
    String? passwordSpecialChar,
    String? weakPassword,
    String? invalidPhone,
    String? invalidUrl,
    String? urlHttpsRequired,
    String? nameLength,
    String? nameInvalidChars,
    String? nameMultipleSpaces,
    String? invalidNumber,
    String? numberMin,
    String? numberMax,
    String? dateFutureNotAllowed,
    String? dateBeforeMin,
    String? dateAfterMax,
  }) : required = required ?? 'This field is required',
       invalidEmail = invalidEmail ?? 'Please enter a valid email address',
       disposableEmail =
           disposableEmail ?? 'Please use a permanent email address',
       passwordLength =
           passwordLength ?? 'Password must be at least {length} characters',
       passwordUppercase =
           passwordUppercase ??
           'Password must include at least one uppercase letter',
       passwordLowercase =
           passwordLowercase ??
           'Password must include at least one lowercase letter',
       passwordDigit =
           passwordDigit ?? 'Password must include at least one number',
       passwordSpecialChar =
           passwordSpecialChar ??
           'Password must include at least one special character',
       weakPassword = weakPassword ?? 'This password is too common',
       invalidPhone = invalidPhone ?? 'Please enter a valid phone number',
       invalidUrl = invalidUrl ?? 'Please enter a valid URL',
       urlHttpsRequired = urlHttpsRequired ?? 'URL must start with https://',
       nameLength = nameLength ?? '{field} must be at least 2 characters',
       nameInvalidChars =
           nameInvalidChars ??
           '{field} can only contain letters, spaces, and hyphens',
       nameMultipleSpaces =
           nameMultipleSpaces ?? '{field} cannot contain multiple spaces',
       invalidNumber = invalidNumber ?? 'Please enter a valid number',
       numberMin = numberMin ?? '{field} must be at least {min}',
       numberMax = numberMax ?? '{field} must be at most {max}',
       dateFutureNotAllowed =
           dateFutureNotAllowed ?? 'Date cannot be in the future',
       dateBeforeMin = dateBeforeMin ?? 'Date must be after {min}',
       dateAfterMax = dateAfterMax ?? 'Date must be before {max}';

  factory ValidationMessages.es() => ValidationMessages(
    required: 'Este campo es requerido',
    invalidEmail: 'Por favor ingresa un correo válido',
    disposableEmail: 'Por favor usa un correo electrónico permanente',
    passwordLength: 'La contraseña debe tener al menos {length} caracteres',
    passwordUppercase:
        'La contraseña debe incluir al menos una letra mayúscula',
    passwordLowercase:
        'La contraseña debe incluir al menos una letra minúscula',
    passwordDigit: 'La contraseña debe incluir al menos un número',
    passwordSpecialChar:
        'La contraseña debe incluir al menos un carácter especial',
    weakPassword: 'Esta contraseña es demasiado común',
    invalidPhone: 'Por favor ingresa un número de teléfono válido',
    invalidUrl: 'Por favor ingresa una URL válida',
    urlHttpsRequired: 'La URL debe comenzar con https://',
    nameLength: '{field} debe tener al menos 2 caracteres',
    nameInvalidChars: '{field} solo puede contener letras, espacios y guiones',
    nameMultipleSpaces: '{field} no puede contener múltiples espacios',
    invalidNumber: 'Por favor ingresa un número válido',
    numberMin: '{field} debe ser al menos {min}',
    numberMax: '{field} debe ser como máximo {max}',
    dateFutureNotAllowed: 'La fecha no puede ser futura',
    dateBeforeMin: 'La fecha debe ser después de {min}',
    dateAfterMax: 'La fecha debe ser antes de {max}',
  );
}

/// Password validation requirements
class PasswordRequirements {
  final int minLength;
  final int? maxLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireDigits;
  final bool requireSpecialChars;
  final List<String>? customDisallowedPasswords;
  final bool checkCommonPasswords;

  const PasswordRequirements({
    this.minLength = 8,
    this.maxLength,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireDigits = true,
    this.requireSpecialChars = false,
    this.customDisallowedPasswords,
    this.checkCommonPasswords = true,
  });

  /// Strong password requirements (recommended)
  static const strong = PasswordRequirements(
    minLength: 12,
    requireUppercase: true,
    requireLowercase: true,
    requireDigits: true,
    requireSpecialChars: true,
    checkCommonPasswords: true,
  );

  /// Medium password requirements
  static const medium = PasswordRequirements(
    minLength: 8,
    requireUppercase: true,
    requireLowercase: true,
    requireDigits: true,
    requireSpecialChars: false,
  );

  /// Basic password requirements
  static const basic = PasswordRequirements(
    minLength: 6,
    requireUppercase: false,
    requireLowercase: true,
    requireDigits: true,
    requireSpecialChars: false,
  );
}

/// Email validation configuration
class EmailValidationOptions {
  final bool checkDisposableDomains;
  final List<String> additionalDisposableDomains;
  final bool allowPlusAlias;
  final RegExp? customEmailRegex;

  const EmailValidationOptions({
    this.checkDisposableDomains = true,
    this.additionalDisposableDomains = const [],
    this.allowPlusAlias = true,
    this.customEmailRegex,
  });
}

