// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Nano Embryo';

  @override
  String get appDescription => 'Tu aplicación innovadora';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonLogin => 'Iniciar sesión';

  @override
  String get commonLogout => 'Cerrar sesión';

  @override
  String get commonDone => 'Hecho';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonAccept => 'Aceptar';

  @override
  String get commonReject => 'Rechazar';

  @override
  String get introGetStarted => 'Comenzar';

  @override
  String get actionsBlock => 'Bloquear usuario';

  @override
  String get actionsReport => 'Reportar usuario';

  @override
  String get actionsSend => 'Enviar al chat';

  @override
  String get actionsShare => 'Compartir';

  @override
  String get actionsCopy => 'Copiar enlace';

  @override
  String get appInfoVersion => 'Versión';

  @override
  String get appInfoReleased => 'Publicado';

  @override
  String get appInfoPackageName => 'Nombre del Paquete';

  @override
  String get appInfoDeveloper => 'Nombre del Desarrollador';

  @override
  String get appInfoSupportEmail => 'Email de Soporte';

  @override
  String get appInfoTechnicalDetails => 'Detalles Técnicos';

  @override
  String get appInfoBundleID => 'ID del Paquete';

  @override
  String get appInfoBuildVersion => 'Versión de Compilación';

  @override
  String get appInfoBuildNumber => 'Número de Compilación';

  @override
  String get appInfoReleaseDate => 'Fecha de Lanzamiento';

  @override
  String get appInfoAppSize => 'Tamaño de la App';

  @override
  String appInfoOverview(String appName) {
    return '$appName es una aplicación móvil moderna construida con seguridad robusta y funcionalidad, diseñada para proporcionar una experiencia de usuario excepcional con arquitectura limpia y optimización de rendimiento.';
  }

  @override
  String introTitle(String appName) {
    return 'Bienvenido a $appName';
  }

  @override
  String get introFeature1Title => 'Ver Tu Progreso';

  @override
  String get introFeature1Description => 'Sigue tus hitos de desarrollo con análisis detallados y perspectivas';

  @override
  String get introFeature2Title => 'Explorar Plantillas';

  @override
  String get introFeature2Description => 'Descubre componentes y pantallas preconstruidos para desarrollo rápido';

  @override
  String get introFeature3Title => 'Comienza Rápidamente';

  @override
  String get introFeature3Description => 'Inicia tu proyecto con configuración cero y mejores prácticas';

  @override
  String get appleSignIn => 'Iniciar sesión con Apple';

  @override
  String get googleSignIn => 'Iniciar sesión con Google';

  @override
  String get appleRegister => 'Registrarse con Apple';

  @override
  String get googleRegister => 'Registrarse con Google';

  @override
  String get emailAndPassword => 'Ingresar correo y contraseña';

  @override
  String get signInTitle => 'Iniciar sesión';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get legalConsentPart1 => 'Por favor, lea los ';

  @override
  String get legalConsentPart2 => 'términos y condiciones';

  @override
  String legalConsentPart3(String appName) {
    return ' y otros documentos legales que rigen su uso de $appName.';
  }

  @override
  String get emailTitle => 'Correo electrónico';

  @override
  String get passwordTitle => 'Contraseña';

  @override
  String get loginEmailLabel => 'Dirección de correo electrónico';

  @override
  String get loginEmailHint => 'Introduce tu correo electrónico';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginPasswordHint => 'Introduce tu contraseña';

  @override
  String get loginForgotPasswordPart1 => '¿Has olvidado tu contraseña? ';

  @override
  String get loginForgotPasswordPart2 => 'Toca aquí';

  @override
  String get loginForgotPasswordPart3 => ' para restablecer tu contraseña?';

  @override
  String get commonConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get commonConfirmPasswordHint => 'Por favor, confirma tu contraseña';

  @override
  String get commonPasswordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get commonPasswordConfirmRequired => 'Por favor, confirma tu contraseña';

  @override
  String commonFieldIsValid(String field) {
    return '$field es válido';
  }

  @override
  String get commonPleaseWait => 'Por favor, espera a que se complete la operación actual';

  @override
  String get commonUnexpectedError => 'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.';

  @override
  String get commonSomethingWentWrong => 'Algo salió mal. Por favor, inténtalo de nuevo.';

  @override
  String get commonEnterEmailAndRetry => 'Por favor, introduce tu dirección de correo electrónico e inténtalo de nuevo';

  @override
  String get commonLearnMore => 'Aprende más';

  @override
  String get authSignUpVerificationSent => '¡Correo de verificación enviado! Por favor, revisa tu bandeja de entrada.';

  @override
  String authSignUpFailed(String error) {
    return 'Registro fallido: $error';
  }

  @override
  String get authForgotPasswordTitle => '¿Olvidaste tu contraseña?';

  @override
  String get authForgotPasswordSubtitle => 'Introduce tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get authSendResetLink => 'Enviar enlace de restablecimiento';

  @override
  String get authBackToSignIn => 'Volver al inicio de sesión';

  @override
  String get authUsernameScreenTitle => 'Elige tu nombre de usuario';

  @override
  String get authUsernameScreenSubtitle => 'Así es como te ven otros. Puedes cambiarlo más tarde.';

  @override
  String get authUsernameLabel => 'Nombre de usuario';

  @override
  String get authUsernameHint => 'Introduce un nombre de usuario';

  @override
  String authUsernameMinLength(int min) {
    return 'El nombre de usuario debe tener al menos $min caracteres';
  }

  @override
  String authUsernameMaxLength(int max) {
    return 'El nombre de usuario debe tener como máximo $max caracteres';
  }

  @override
  String get authUsernameFormatError => 'Solo se permiten letras, números y guiones bajos';

  @override
  String get authUsernameTaken => 'Este nombre de usuario ya está en uso';

  @override
  String get authUsernameCheckError => 'No se pudo comprobar la disponibilidad. Por favor, inténtalo de nuevo.';

  @override
  String get authUsernameSaveError => 'No se pudo guardar tu nombre de usuario. Por favor, inténtalo de nuevo.';

  @override
  String get authUsernameSavedSuccess => '¡Nombre de usuario guardado exitosamente!';

  @override
  String get authUpdatePasswordTitle => 'Crear nueva contraseña';

  @override
  String get authUpdatePasswordButton => 'Actualizar contraseña';

  @override
  String get authUpdatePasswordSuccess => 'Contraseña actualizada exitosamente. Por favor, inicia sesión de nuevo.';

  @override
  String get authPasswordResetSentTitle => 'Revisa tu correo electrónico';

  @override
  String get authPasswordResetSentBody => 'Enviamos un enlace para restablecer tu contraseña a';

  @override
  String get authPasswordResetSentNote => 'Toca el enlace en el correo electrónico para establecer una nueva contraseña. El enlace expira en 1 hora.';

  @override
  String get authGuestHello => '¡Hola!';

  @override
  String authGuestOverview(String appName) {
    return 'Estás navegando $appName como invitado. Inicia sesión o crea una cuenta para comenzar a gestionar tu tienda – te tomará menos de 5 segundos. Tenemos una variedad de herramientas para ayudarte a hacer crecer tu negocio, todo de forma gratuita.';
  }

  @override
  String authIntroTitle(String appName) {
    return 'Bienvenido a\n$appName';
  }

  @override
  String get authIntroSubtitle => 'Bienvenido a la plataforma que creamos para ti. Disfruta y diviértete – lo mejor está esperándote.';

  @override
  String get authReadLegalities => 'Leer avisos legales';

  @override
  String get authPasswordRequired => 'Por favor, introduce tu contraseña';

  @override
  String get authCreatingAccount => 'Creando cuenta...';

  @override
  String get authAccountCreatedSuccess => '¡Cuenta creada exitosamente!';

  @override
  String get authCheckEmailToConfirm => 'Por favor, revisa tu correo electrónico para confirmar tu cuenta';

  @override
  String get authSigningInWithGoogle => 'Iniciando sesión con Google...';

  @override
  String authGoogleSignInFailed(String error) {
    return 'Error al iniciar sesión con Google: $error';
  }

  @override
  String get authAuthenticatingWithApple => 'Autenticando con Apple...';

  @override
  String authAppleSignInFailed(String error) {
    return 'Error al iniciar sesión con Apple: $error';
  }

  @override
  String get authSendingResetEmail => 'Enviando correo de restablecimiento...';

  @override
  String get authResetEmailSent => 'Correo de restablecimiento enviado. Revisa tu bandeja de entrada.';

  @override
  String authPasswordResetFailed(String error) {
    return 'Error al restablecer contraseña: $error';
  }

  @override
  String get authVerifyEmailTitle => 'Revisa tu correo electrónico';

  @override
  String get authVerifyEmailSubtitle => 'Enviamos un enlace de confirmación a';

  @override
  String get authVerifyEmailNote => 'Toca el enlace en el correo para verificar tu cuenta y continuar.';

  @override
  String get authConfirmationResent => 'Correo de confirmación reenviado. Revisa tu bandeja de entrada.';

  @override
  String get authResendFailed => 'Error al reenviar el correo. Por favor, inténtalo de nuevo.';

  @override
  String get authResendEmailButton => 'Reenviar correo de confirmación';

  @override
  String authResendEmailCooldown(int seconds) {
    return 'Reenviar correo (${seconds}s)';
  }

  @override
  String get currencySelectorPlaceholder => 'Seleccionar moneda';

  @override
  String get currencySelectorNoSelected => 'Ninguna moneda seleccionada';

  @override
  String get currencySelectorTitle => 'Seleccionar moneda';

  @override
  String get currencySelectorSearchHint => 'Buscar por moneda, código o bandera...';

  @override
  String get currencySelectorNoResults => 'No se encontraron monedas';

  @override
  String get discoverScreenTitle => 'Descubrir';

  @override
  String get discoverSearchHint => 'Buscar...';

  @override
  String get discoverAllShopsRegion => 'Todas las tiendas en tu región';

  @override
  String get discoverAllFreelancers => 'Todos los freelancers cerca de ti';

  @override
  String get discoverMarketplaceTitle => 'Mercado';

  @override
  String get discoverMarketplaceSubtitle => 'Compra productos de belleza con pago contra entrega';

  @override
  String get discoverBrowseProducts => 'Explorar productos';

  @override
  String get discoverMyOrders => 'Mis pedidos';

  @override
  String get discoverCartTooltip => 'Carrito';

  @override
  String get homeScheduleTabLabel => 'Horario';

  @override
  String get homeDashboardTabLabel => 'Panel';

  @override
  String get homeMapTabLabel => 'Mapa';

  @override
  String get validationRequired => 'Este campo es obligatorio';

  @override
  String get validationEmailInvalid => 'Por favor, introduce una dirección de correo electrónico válida';

  @override
  String validationPasswordLength(int minLength) {
    return 'La contraseña debe tener al menos $minLength caracteres';
  }

  @override
  String get validationPasswordUppercase => 'La contraseña debe incluir al menos una letra mayúscula';

  @override
  String get loggingInIndicatorText => 'Iniciando sesión...';

  @override
  String get loginSuccessful => '¡Inicio de sesión exitoso!\nBienvenido de nuevo';

  @override
  String get errorLoginFailed => 'Error al iniciar sesión. Por favor, verifica tus credenciales';

  @override
  String get errorNetwork => 'Error de red. Por favor, verifica tu conexión';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get chatTitle => 'Chat';

  @override
  String get editProfileNameFieldTitle => 'Nombre';

  @override
  String get editProfileNameFieldLabel => 'Nombre completo';

  @override
  String get editProfileUserFieldNameTitle => 'Nombre de usuario';

  @override
  String get editProfileUsernameFieldLabel => '@nombredeusuario';

  @override
  String get editProfileBioFieldTitle => 'Biografía';

  @override
  String get editProfileBioFieldLabel => 'Cuéntanos sobre ti';

  @override
  String get editProfileScreenTitle => 'Editar perfil';

  @override
  String get editProfileSettingTitle => 'Configuración de cuenta';

  @override
  String get editProfileSettingSubtitle => 'Administra tu cuenta';

  @override
  String get editProfileScreenEditShopTitle => 'Editar Tienda';

  @override
  String get editProfileScreenEditShopSubtitle => 'Cambia la información de tu tienda';

  @override
  String get editProfileScreenCreateFreelancerTitle => 'Create freelancer profile';

  @override
  String get editProfileScreenCreateFreelancerSubtitle => 'Set up your work profile so clients can find and book you.';

  @override
  String get editProfileScreenCreateShopTitle => 'Create shop';

  @override
  String get editProfileScreenCreateShopSubtitle => 'Set up your shop so clients can find and book your services.';

  @override
  String get editProfileScreenSellProductTitle => 'Sell a product';

  @override
  String get editProfileScreenSellProductSubtitle => 'Sell your beauty products like pomades, shampoos, hairbrushes and more.';

  @override
  String get languageScreenSubtitle => 'Elige tu idioma preferido para la interfaz de la app. Esto no afectará la configuración de tu dispositivo.';

  @override
  String get languageScreeUseDeviceLang => 'Usar Idioma del Dispositivo.';

  @override
  String get languageScreeUseDeviceLangNote => 'Esto se restablecerá para que coincida con el idioma del sistema de tu dispositivo.';

  @override
  String get settingsScreenTitle => 'Configuración';

  @override
  String get accountSectionTitle => 'Cuenta';

  @override
  String get accountSectionSubtitle => '';

  @override
  String get profileItemTitle => 'Perfil';

  @override
  String get profileItemSubtitle => 'Administra tus datos personales';

  @override
  String get locationItemTitle => 'Cambiar Ubicación';

  @override
  String get locationItemSubtitle => 'Cambia tu ciudad actual';

  @override
  String get saveItemTitle => 'Contenidos Guardados';

  @override
  String get saveItemSubtitle => 'Contenidos que has guardado';

  @override
  String get notificationsItemTitle => 'Notificaciones';

  @override
  String get notificationsItemSubtitle => 'Gestiona notificaciones push y por correo';

  @override
  String get blockedItemTitle => 'Cuentas Bloqueadas';

  @override
  String get blockedItemSubtitle => 'Cuentas que has bloqueado';

  @override
  String get qrCodeItemTitle => 'Compartir Código QR';

  @override
  String get qrCodeItemSubtitle => 'Comparte tu código QR de cuenta';

  @override
  String get shareProfileItemTitle => 'Compartir Perfil';

  @override
  String get shareProfileItemSubtitle => 'Comparte tu perfil con amigos';

  @override
  String get appSettingsSectionTitle => 'Configuración de la App';

  @override
  String get appSettingsSectionSubtitle => 'Personaliza tu experiencia';

  @override
  String get themeItemTitle => 'Tema';

  @override
  String get themeItemSubtitle => 'Claro, Oscuro o Sistema';

  @override
  String get languageItemTitle => 'Idioma';

  @override
  String get languageItemSubtitle => 'Cambia el idioma de la app';

  @override
  String get biometricItemTitle => 'Inicio Biométrico';

  @override
  String get biometricItemSubtitle => 'Usa Face ID o Touch ID';

  @override
  String get supportSectionTitle => 'Soporte';

  @override
  String get supportSectionSubtitle => '';

  @override
  String get guideItemTitle => 'Guía de Usuario';

  @override
  String get guideItemSubtitle => 'Documentación y tutoriales';

  @override
  String get helpItemTitle => 'Contactar Soporte';

  @override
  String get helpItemSubtitle => 'Obtén ayuda con la app';

  @override
  String get feedbackItemTitle => 'Enviar Comentarios';

  @override
  String get feedbackItemSubtitle => 'Comparte tus pensamientos';

  @override
  String get rateItemTitle => 'Calificar la App';

  @override
  String get rateItemSubtitle => 'Deja una reseña';

  @override
  String appInfoItemTitle(String appName) {
    return 'Acerca de $appName';
  }

  @override
  String get appInfoItemSubtitle => 'Información técnica';

  @override
  String get legalSectionTitle => 'Legal';

  @override
  String get legalSectionSubtitle => '';

  @override
  String get termsItemTitle => 'Términos, Privacidad y Políticas';

  @override
  String get termsItemSubtitle => 'Lee nuestros términos';

  @override
  String get licensesItemTitle => 'Licencias de Código Abierto';

  @override
  String get licensesItemSubtitle => 'Bibliotecas y licencias de terceros';

  @override
  String get accountActionsSectionTitle => 'Acciones de Cuenta';

  @override
  String get accountActionsSectionSubtitle => '';

  @override
  String get updatePasswordItemTitle => 'Actualizar contraseña';

  @override
  String get updatePasswordItemSubtitle => 'Cambia la contraseña actual de tu cuenta';

  @override
  String get deactivateItemTitle => 'Desactivar';

  @override
  String get deactivateItemSubtitle => 'Oculta y desactiva tu cuenta temporalmente';

  @override
  String get deleteItemTitle => 'Eliminar Cuenta';

  @override
  String get deleteItemSubtitle => 'Solicita la eliminación permanente de tu cuenta';

  @override
  String get logoutItemTitle => 'Cerrar Sesión';

  @override
  String get logoutItemSubtitle => 'Cierra sesión en tu cuenta';

  @override
  String get logoutConfirmTitle => '¿Seguro que quieres cerrar sesión?';

  @override
  String get logoutConfirmMessage => 'Tendrás que iniciar sesión de nuevo para acceder a tu cuenta y datos.';

  @override
  String get logoutConfirmButton => 'Cerrar sesión';

  @override
  String get logoutSuccessMessage => 'Sesión cerrada correctamente';

  @override
  String logoutFailedMessage(String error) {
    return 'Error al cerrar sesión: $error';
  }

  @override
  String get accountDeactivateTitle => 'Desactivar cuenta';

  @override
  String get accountDeleteTitle => 'Eliminar cuenta';

  @override
  String get accountRestoreTitle => 'Restaurar cuenta';

  @override
  String get accountDeactivateWarningTitle => 'Tu cuenta se ocultará';

  @override
  String get accountDeactivateWarningBody => 'Tu perfil, tiendas, productos, perfil freelance y enlaces de reserva se ocultarán. Puedes restaurar el acceso iniciando sesión de nuevo.';

  @override
  String get accountDeleteWarningTitle => 'La eliminación se programa por 30 días';

  @override
  String get accountDeleteWarningBody => 'Tu presencia pública se ocultará ahora. Puedes restaurar tu cuenta dentro de 30 días; después se eliminan los datos personales del perfil.';

  @override
  String get accountPasswordConfirmLabel => 'Confirmar contraseña';

  @override
  String get accountPasswordConfirmHint => 'Ingresa tu contraseña';

  @override
  String accountPhraseConfirmLabel(String phrase) {
    return 'Escribe $phrase para confirmar';
  }

  @override
  String get accountReasonLabel => 'Motivo (opcional)';

  @override
  String get accountReasonHint => 'Cuéntanos por qué te vas';

  @override
  String accountPhraseMismatch(String phrase) {
    return 'Escribe $phrase para continuar';
  }

  @override
  String get accountActionBlocked => 'Resuelve reservas, pedidos o retiros activos antes de continuar.';

  @override
  String get accountActionLoadFailed => 'No pudimos cargar los requisitos de la cuenta. Inténtalo de nuevo.';

  @override
  String get accountActionGenericError => 'No pudimos completar esta acción de cuenta. Inténtalo de nuevo.';

  @override
  String get accountRecentAuthRequired => 'Inicia sesión de nuevo antes de continuar.';

  @override
  String get accountReasonTooLong => 'El motivo debe tener 1000 caracteres o menos.';

  @override
  String get accountDeactivateButton => 'Desactivar cuenta';

  @override
  String get accountDeleteButton => 'Solicitar eliminación';

  @override
  String get accountDeactivatedSuccess => 'Tu cuenta ha sido desactivada.';

  @override
  String get accountDeletionRequestedSuccess => 'La eliminación de la cuenta ha sido programada.';

  @override
  String get accountRestoreButton => 'Restaurar cuenta';

  @override
  String get accountRestoredSuccess => 'Tu cuenta ha sido restaurada.';

  @override
  String get accountRestoreFailed => 'No pudimos restaurar esta cuenta.';

  @override
  String get accountRestoreMissingProfile => 'No pudimos cargar tu perfil.';

  @override
  String get accountDeactivatedTitle => 'Cuenta desactivada';

  @override
  String get accountDeactivatedBody => 'Tu cuenta está oculta. Restáurala para seguir usando la aplicación.';

  @override
  String get accountPendingDeleteTitle => 'Cuenta pendiente de eliminación';

  @override
  String accountPendingDeleteBody(String date) {
    return 'Tu cuenta está programada para eliminarse el $date. Restáurala antes de esa fecha para conservarla.';
  }

  @override
  String get accountDeletedTitle => 'Cuenta eliminada';

  @override
  String get accountDeletedBody => 'Esta cuenta ha sido eliminada y ya no se puede restaurar.';

  @override
  String get accountBlockersTitle => 'Resuelve esto primero';

  @override
  String accountBlockerActiveBookings(int count) {
    return '$count reserva(s) activa(s)';
  }

  @override
  String accountBlockerOwnedShopActiveBookings(int count) {
    return '$count reserva(s) activa(s) de tienda';
  }

  @override
  String accountBlockerActiveOrders(int count) {
    return '$count pedido(s) activo(s)';
  }

  @override
  String accountBlockerOwnedShopActiveOrders(int count) {
    return '$count pedido(s) activo(s) de tienda';
  }

  @override
  String accountBlockerActiveWithdrawals(int count) {
    return '$count retiro(s) pendiente(s)';
  }

  @override
  String get loadingDefaultMessage => 'Cargando...';

  @override
  String emptyStateNoDataTitle(String dataType) {
    return 'No hay $dataType aún';
  }

  @override
  String emptyStateNoDataSubtitle(String dataType) {
    return 'Cuando $dataType esté disponible, aparecerán aquí.';
  }

  @override
  String get emptyStateNoResultsTitle => 'No se encontraron resultados';

  @override
  String emptyStateNoResultsSubtitle(String dataType) {
    return 'Intenta ajustar tu búsqueda o filtros para encontrar $dataType.';
  }

  @override
  String get emptyStateNoInternetTitle => 'Sin conexión a internet';

  @override
  String get emptyStateNoInternetSubtitle => 'Verifica tu conexión e intenta de nuevo.';

  @override
  String get emptyStateNoFavoritesTitle => 'No hay favoritos aún';

  @override
  String get emptyStateNoFavoritesSubtitle => 'Comienza agregando elementos a tu lista de favoritos.';

  @override
  String get emptyStateNoMessagesTitle => 'No hay mensajes';

  @override
  String get emptyStateNoMessagesSubtitle => 'Inicia una conversación para ver mensajes aquí.';

  @override
  String get emptyStateRefresh => 'Actualizar';

  @override
  String get emptyStateClearFilters => 'Limpiar filtros';

  @override
  String get emptyStateRetry => 'Reintentar';

  @override
  String get emptyStateExplore => 'Explorar';

  @override
  String get emptyStateStartChat => 'Iniciar chat';

  @override
  String get errorNetworkTitle => 'Error de conexión';

  @override
  String get errorNetworkSubtitle => 'No se pudo conectar al servidor. Verifica tu conexión a internet.';

  @override
  String get errorServerTitle => 'Error del servidor';

  @override
  String get errorServerSubtitle => 'Algo salió mal de nuestro lado. Por favor, intenta más tarde.';

  @override
  String get errorClientTitle => 'Error en la solicitud';

  @override
  String get errorClientSubtitle => 'Hubo un problema con tu solicitud. Por favor, verifica e intenta de nuevo.';

  @override
  String get errorParsingTitle => 'Error de datos';

  @override
  String errorParsingSubtitle(String dataType) {
    return 'No se pudo procesar el/la $dataType. Esto podría ser un problema temporal.';
  }

  @override
  String get errorPermissionTitle => 'Acceso denegado';

  @override
  String errorPermissionSubtitle(String dataType) {
    return 'No tienes permiso para acceder a este/esta $dataType.';
  }

  @override
  String get errorGenericTitle => 'Algo salió mal';

  @override
  String errorGenericSubtitle(String dataType) {
    return 'Ocurrió un error inesperado al cargar $dataType. Por favor, intenta de nuevo.';
  }

  @override
  String get errorRetry => 'Reintentar';

  @override
  String get errorCheckSettings => 'Verificar configuración';

  @override
  String get errorReport => 'Reportar problema';

  @override
  String get errorGoBack => 'Volver';

  @override
  String get errorRefresh => 'Actualizar';

  @override
  String get errorRequestAccess => 'Solicitar acceso';

  @override
  String get errorContactSupport => 'Contactar soporte';

  @override
  String get dataTypeUsers => 'usuarios';

  @override
  String get dataTypeUser => 'usuario';

  @override
  String get dataTypeProducts => 'productos';

  @override
  String get dataTypeProduct => 'producto';

  @override
  String get dataTypeOrders => 'pedidos';

  @override
  String get dataTypeOrder => 'pedido';

  @override
  String get dataTypeMessages => 'mensajes';

  @override
  String get dataTypeMessage => 'mensaje';

  @override
  String get dataTypeFavorites => 'favoritos';

  @override
  String get dataTypeFavorite => 'favorito';

  @override
  String get dataTypeData => 'datos';

  @override
  String get dataTypeContent => 'contenido';

  @override
  String get dataTypeItems => 'elementos';

  @override
  String get dataTypeItem => 'elemento';

  @override
  String get eulaTitle => 'Acuerdo de Licencia de Usuario Final';

  @override
  String eulaContent(String appName, String supportEmail) {
    return 'Este Acuerdo de Licencia de Usuario Final (\"EULA\") es un acuerdo legal entre usted y Bars Opus, Ltd. para $appName.\n\nAl instalar, acceder o usar $appName, usted acepta estar sujeto a los términos de este EULA. $appName está licenciado, no vendido, para su uso solo bajo los términos de esta licencia. Bars Opus, Ltd. se reserva todos los derechos no expresamente otorgados a usted en este EULA.\n\nNo puede modificar, realizar ingeniería inversa, descompilar o desensamblar $appName. Esta licencia es válida hasta que sea terminada por usted o Bars Opus, Ltd. Sus derechos bajo esta licencia terminarán automáticamente sin previo aviso si incumple cualquier término.\n\nTodos los derechos de propiedad intelectual sobre $appName son propiedad de Bars Opus, Ltd. Este EULA se rige por las leyes de Inglaterra y Gales.\n\nPara preguntas sobre este EULA, por favor contacte: $supportEmail.';
  }

  @override
  String get eulaFooter => 'Al aceptar, usted reconoce que ha leído y comprendido este Acuerdo de Licencia de Usuario Final.';

  @override
  String get privacyPolicyTitle => 'Política de Privacidad';

  @override
  String privacyPolicyContent(String appName) {
    return 'Esta Política de Privacidad explica cómo Bars Opus, Ltd. (\"nosotros\", \"nuestro\") recopila, utiliza y protege su información cuando usa $appName.\n\nRecopilamos información que usted proporciona directamente, como cuando crea una cuenta, completa su perfil o contacta al soporte. Recopilamos automáticamente cierta información sobre su dispositivo y cómo usa $appName. Usamos cookies y tecnologías de seguimiento similares para rastrear la actividad y almacenar cierta información.\n\nUsamos la información que recopilamos para proporcionar, mantener y mejorar $appName. Podemos compartir su información con proveedores de servicios de terceros que realizan servicios en nuestro nombre. Podemos divulgar su información si lo requiere la ley o para proteger nuestros derechos y seguridad.\n\nUsted tiene derecho a acceder, corregir o eliminar su información personal. Implementamos medidas técnicas y organizativas apropiadas para proteger su información. Podemos actualizar esta Política de Privacidad de vez en cuando. Le notificaremos cualquier cambio.';
  }

  @override
  String privacyPolicyFooter(String appName, DateTime currentDate) {
    final intl.DateFormat currentDateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String currentDateString = currentDateDateFormat.format(currentDate);

    return 'Política de Privacidad de $appName - Última actualización: $currentDateString';
  }

  @override
  String get termsTitle => 'Términos de Servicio';

  @override
  String termsContent(String appName, String supportEmail) {
    return 'Estos Términos de Servicio (\"Términos\") rigen su acceso y uso de $appName. Al acceder o usar $appName, usted acepta estar sujeto a estos Términos.\n\nDebe tener al menos 13 años para usar $appName. Usted es responsable de proteger sus credenciales de cuenta y de todas las actividades bajo su cuenta. No puede usar $appName para ningún propósito ilegal o no autorizado.\n\nNos reservamos el derecho de modificar, suspender o descontinuar $appName en cualquier momento. Todo el contenido incluido en $appName es propiedad de Bars Opus, Ltd. o sus licenciantes.\n\nPodemos terminar o suspender su acceso a $appName inmediatamente si viola estos Términos. Estos Términos se regirán e interpretarán de acuerdo con las leyes de Inglaterra y Gales.\n\nPara cualquier pregunta sobre estos Términos, por favor contáctenos en $supportEmail.';
  }

  @override
  String get dataSharingTitle => 'Acuerdo de Compartición de Datos';

  @override
  String dataSharingContent(String appName) {
    return 'Este Acuerdo de Compartición de Datos describe cómo se puede compartir su información cuando usa las funciones sociales de $appName.\n\nCuando se conecta con amigos en $appName, ciertos datos de actividad pueden ser visibles para ellos. Los datos de actividad compartidos pueden incluir duración del entrenamiento, calorías quemadas, minutos de ejercicio y insignias de logros. Su información de perfil (nombre para mostrar y foto de perfil) es visible para los amigos con los que se conecta.\n\nSu dirección de correo electrónico e información de contacto permanecen privadas y nunca se comparten con otros usuarios. Usted controla qué datos se comparten a través de su configuración de privacidad de $appName. Puede revocar los permisos de compartición en cualquier momento en la configuración de la aplicación.\n\nLos datos compartidos con amigos se cifran durante la transmisión y el almacenamiento. Conservamos los datos compartidos solo el tiempo necesario para proporcionar la funcionalidad de compartición. Las integraciones de terceros pueden tener sus propias prácticas de compartición de datos, que recomendamos revisar.';
  }

  @override
  String dataSharingFooter(String appName) {
    return 'La compartición de datos en $appName ayuda a crear una comunidad de apoyo mientras respeta sus elecciones de privacidad.';
  }

  @override
  String get dashboardTitle => 'Panel de Control';

  @override
  String get dashboardSubtitle => 'Gestiona las actividades de tu tienda de manera eficiente';

  @override
  String get dashboardSectionTitle => 'Panel de Control';

  @override
  String get dashboardSectionSubtitle => 'Resumen del rendimiento y métricas clave de tu tienda';

  @override
  String get dashboardPayoutTitle => 'Solicitar Pago';

  @override
  String get dashboardPayoutContent => 'Los propietarios de tiendas pueden solicitar pagos semanales. Navega a la sección de Ganancias, revisa tu saldo y envía una solicitud de pago. Los fondos generalmente se procesan en 3-5 días hábiles.';

  @override
  String get dashboardAnalyticsTitle => 'Panel de Análisis';

  @override
  String get dashboardAnalyticsContent => 'Rastrea el rendimiento de tu tienda con análisis en tiempo real. Monitorea tendencias de ventas, compromiso del cliente y niveles de inventario a través de gráficos interactivos e informes.';

  @override
  String get dashboardScreenshotTitle => 'Vista General del Panel';

  @override
  String get dashboardScreenshotContent => 'El panel principal proporciona una vista integral de las métricas clave de tu tienda, actividades recientes y acceso rápido a funciones esenciales.';

  @override
  String get categoryFeatures => 'Características';

  @override
  String get categoryDashboard => 'Panel de Control';

  @override
  String get faqDashboard1Question => '¿Cuándo puedo solicitar un pago?';

  @override
  String get faqDashboard1Answer => 'Puedes solicitar tu pago una vez a la semana, cada sábado. El corte semanal es el viernes a las 11:59 PM. Los pagos se procesan en 3-5 días hábiles.';

  @override
  String get faqDashboard2Question => '¿Dónde solicito mi pago?';

  @override
  String get faqDashboard2Answer => 'Navega a tu panel de control y haz clic en la sección \'Ganancias\'. Desde allí, verás tu saldo actual y un botón \'Solicitar Pago\'. Sigue las indicaciones para completar tu solicitud.';

  @override
  String get profileScreenCantChatWithYourself => 'No puedes chatear contigo mismo';

  @override
  String get profileScreenStartingConversation => 'Iniciando conversación...';

  @override
  String get profileScreenNoActiveSession => 'No hay sesión activa — por favor inicie sesión de nuevo.';

  @override
  String get profileScreenSignInToChatMessage => 'Debe iniciar sesión para enviar un mensaje';

  @override
  String get profileScreenFollowFeatureComingSoon => 'La función de seguimiento próximamente';

  @override
  String get profileScreenEnterBioPlaceholder => 'Ingrese una biografía para que la gente lo conozca';

  @override
  String get profileScreenNoBioYet => 'Sin biografía aún';

  @override
  String get profileScreenErrorLoadingProfileBody => 'No se pudo cargar el perfil. Verifique su conexión a internet e intente de nuevo.';

  @override
  String get profileScreenLoadingNotifications => 'Cargando...';

  @override
  String get profileHeaderBookingsStatLabel => 'Reservas';

  @override
  String get profileHeaderOrdersStatLabel => 'Pedidos';

  @override
  String get profileHeaderEditProfileButton => 'Editar perfil';

  @override
  String get profileHeaderMessageButton => 'Mensaje';

  @override
  String get editableProfileAvatarTakePhoto => 'Tomar una foto';

  @override
  String get editableProfileAvatarChooseGallery => 'Elegir de la galería';

  @override
  String get editProfileScreenAccountTypeLabel => 'Tipo de cuenta';

  @override
  String get editProfileScreenAccountTypeSubtitle => 'Selecciona cómo deseas usar esta aplicación. Esto determina qué características están disponibles para ti.';

  @override
  String get editProfileScreenUpdatingAccountType => 'Actualizando tipo de cuenta...';

  @override
  String get editProfileScreenPleaseLogIn => 'Por favor inicie sesión';

  @override
  String get editProfileScreenNameLabel => 'Nombre';

  @override
  String get editProfileScreenNameHint => 'Ingrese su nombre';

  @override
  String get editProfileScreenUsernameLabel => 'Nombre de usuario';

  @override
  String get editProfileScreenUsernameHint => 'Ingrese el nombre de usuario';

  @override
  String get editProfileScreenBioLabel => 'Biografía';

  @override
  String get editProfileScreenBioHint => 'Cuéntanos algo sobre ti';

  @override
  String get editProfileScreenEditWorkProfileTitle => 'Editar perfil de trabajo';

  @override
  String get profileTabsAppointments => 'Citas';

  @override
  String get profileTabsBuys => 'Compras';

  @override
  String get profileTabsSaves => 'Guardados';

  @override
  String get searchScreenSearchHint => 'Busca tiendas, profesionales, productos...';

  @override
  String get searchScreenNoResultsFound => 'No se encontraron resultados';

  @override
  String searchScreenNoResultsCategory(String category) {
    return 'No se encontraron $category';
  }

  @override
  String searchScreenSearchedFor(String query) {
    return 'Se buscó: \"$query\"';
  }

  @override
  String get searchScreenSomethingWentWrong => 'Algo salió mal';

  @override
  String get searchAppBarSearchHint => 'Buscar...';

  @override
  String get searchSuggestionsHint => 'Busca tiendas, profesionales de servicios a domicilio o productos de cabello para comprar';

  @override
  String get searchSuggestionsRecentSearches => 'Búsquedas recientes';

  @override
  String get searchSuggestionsClearAll => 'Borrar todo';

  @override
  String get searchEmptyStateNoResults => 'No se encontraron resultados';

  @override
  String searchEmptyStateCouldNotFind(String query) {
    return 'No pudimos encontrar nada para \"$query\"';
  }

  @override
  String get searchEmptyStateTryThese => 'Intenta con estos:';

  @override
  String get searchResultsShopsHeader => 'Tiendas';

  @override
  String get searchResultsSeeAll => 'Ver todos';

  @override
  String searchResultsTitle(String category) {
    return 'Resultados de $category';
  }

  @override
  String searchResultsSearchingFor(String query) {
    return 'Buscando \"$query\"';
  }

  @override
  String get searchResultsTryDifferent => 'Intenta con palabras clave diferentes o elimina filtros';

  @override
  String get searchResultsSomethingWentWrong => 'Algo salió mal';

  @override
  String nearYouShopsTitle(int km) {
    return 'Cerca de ti\ndenro de ${km}km';
  }

  @override
  String nearYouShopsBody(int km) {
    return 'Tiendas ubicadas dentro de $km km de tu ubicación actual, mostradas de la más cercana a la más lejana. Simplemente establece tu ubicación una vez, y te mostraremos qué hay cerca—ya sea en casa, en el trabajo o explorando un barrio nuevo. Útil para reservas de último minuto o cuando prefieres caminar.';
  }

  @override
  String get nearYouShopsEmptyNoFilter => 'No se encontraron tiendas cercanas';

  @override
  String nearYouShopsEmptyWithFilter(String luxury) {
    return 'No se encontraron tiendas $luxury cercanas';
  }

  @override
  String nearYouShopsEmptySubtitle(String location) {
    return 'Las tiendas en $location se mostrarían aquí una vez que estén disponibles';
  }

  @override
  String get premiumShopsScreenTitle => 'Tiendas Premium';

  @override
  String get premiumShopsEmpty => 'No se encontraron tiendas premium';

  @override
  String get premiumShopsHorizontalTitle => 'Tiendas Premium\npara looks premium';

  @override
  String get premiumShopsHorizontalBody => 'Salones y spas de lujo cuidadosamente seleccionados que ofrecen experiencias lujosas. Estas tiendas se clasifican como Lujo o Ultra Lujo según sus servicios, precios y reseñas de clientes. Perfecto cuando buscas ese toque extra de elegancia.';

  @override
  String get premiumShopsHorizontalEmptyNoFilter => 'No hay tiendas premium disponibles';

  @override
  String premiumShopsHorizontalEmptyWithFilter(String luxury) {
    return 'No hay tiendas premium $luxury disponibles';
  }

  @override
  String get premiumShopsHorizontalEmptySubtitle => 'Las tiendas se mostrarían aquí una vez que estén disponibles';

  @override
  String get topRatedShopsHorizontalTitle => 'Mejor valoradas';

  @override
  String topRatedShopsHorizontalTitleWithLocation(String location) {
    return 'Mejor valoradas \nen $location';
  }

  @override
  String get topRatedShopsHorizontalBody => 'Tiendas con las calificaciones más altas de clientes (4.5+ estrellas) y muchas reseñas. Estos son los favoritos de nuestra comunidad—elogiados constantemente por calidad, servicio y profesionalismo. Un excelente lugar para empezar si buscas opciones confiables y aprobadas por la multitud.';

  @override
  String get topRatedShopsHorizontalEmptyNoFilter => 'No hay tiendas mejor valoradas disponibles';

  @override
  String topRatedShopsHorizontalEmptyWithFilter(String luxury) {
    return 'No hay tiendas premium $luxury disponibles';
  }

  @override
  String get topRatedShopsHorizontalEmptySubtitle => 'Las tiendas se mostrarían aquí una vez que estén disponibles';

  @override
  String get topRatedShopsScreenTitle => 'Tiendas Mejor Valoradas';

  @override
  String get topRatedShopsEmpty => 'No se encontraron tiendas mejor valoradas';

  @override
  String get nearYouFreelancersScreenTitle => 'Freelancers cerca de ti';

  @override
  String get nearYouFreelancersEmpty => 'No se encontraron freelancers cercanos';

  @override
  String get nearYouFreelancersEmptySubtitle => 'Intenta expandir tu área de búsqueda o cambia tu ubicación';

  @override
  String get topRatedFreelancersScreenTitle => 'Freelancers mejor valorados';

  @override
  String get topRatedFreelancersEmpty => 'No se encontraron freelancers mejor valorados';

  @override
  String get topRatedFreelancersEmptySubtitle => 'Intenta ajustar tu área de búsqueda';

  @override
  String topRatedFreelancersHorizontalTitle(String location) {
    return 'Mejor valorados \nen $location';
  }

  @override
  String get topRatedFreelancersHorizontalBody => 'Profesionales de alta calidad cuidadosamente seleccionados que ofrecen experiencias lujosas. Estos freelancers se clasifican como mejor valorados según la calidad de su trabajo, precios y reseñas de clientes. Perfecto para ese toque extra de excelencia.';

  @override
  String nearYouFreelancersHorizontalTitle(String location) {
    return 'Freelancers Cerca de Ti en $location';
  }

  @override
  String get nearYouFreelancersHorizontalBody => 'Profesionales calificados ubicados cerca de ti. Estos freelancers están disponibles para reservas rápidas y ofrecen servicio local conveniente. Perfecto cuando buscas confiabilidad y proximidad.';

  @override
  String get nearYouFreelancersHorizontalEmpty => 'No hay freelancers mejor valorados disponibles';

  @override
  String get nearYouFreelancersHorizontalEmptySubtitle => 'Los freelancers se mostrarían aquí una vez que estén disponibles';

  @override
  String get shopNoLocationSetTitle => 'Establece tu ubicación para descubrir';

  @override
  String get shopNoLocationSetContent => 'Establece tu ubicación para descubrir tiendas premium y mejor valoradas cerca de ti.';

  @override
  String get providerTypeShops => 'Tiendas';

  @override
  String get providerTypeFreelancers => 'Freelancers';

  @override
  String get providerTypeBuy => 'Comprar';

  @override
  String get luxuryLevelChipsAll => 'Todas';

  @override
  String get searchRadiusSliderTitle => 'Radio de exploración';

  @override
  String searchRadiusSliderSubtitle(int km) {
    return 'Mostrando resultados dentro de ${km}km de tu ubicación';
  }

  @override
  String validationPasswordMaxLength(int max) {
    return 'La contraseña debe tener como máximo $max caracteres';
  }

  @override
  String get validationPasswordRepeatingChars => 'La contraseña contiene demasiados caracteres repetidos';

  @override
  String get validationPasswordSequential => 'La contraseña contiene caracteres secuenciales';

  @override
  String validationPhoneDigits(int digits) {
    return 'El número de teléfono debe tener $digits dígitos';
  }

  @override
  String get validationPhoneUK => 'Número de teléfono británico inválido';

  @override
  String validationUrlScheme(String schemes) {
    return 'La URL debe comenzar con $schemes';
  }

  @override
  String get validationUrlDomain => 'Nombre de dominio inválido';

  @override
  String get validationUrlPublicAddress => 'La URL debe apuntar a una dirección pública';

  @override
  String validationNameMaxLength(String field, int max) {
    return '$field debe tener como máximo $max caracteres';
  }

  @override
  String validationNameConsecutiveChars(String field) {
    return '$field no puede contener guiones o espacios consecutivos';
  }

  @override
  String get validationCreditCardFormat => 'Por favor ingresa un número de tarjeta de crédito válido';

  @override
  String get validationCreditCardInvalid => 'Número de tarjeta de crédito inválido';

  @override
  String get validationDatePastNotAllowed => 'La fecha no puede ser en el pasado';

  @override
  String get validationPostalCodeZip => 'Por favor ingresa un código postal válido (ej. 12345 o 12345-6789)';

  @override
  String get validationPostalCodeCanadian => 'Por favor ingresa un código postal canadiense válido (ej. A1A 1A1)';

  @override
  String get validationPostalCodeGeneric => 'Por favor ingresa un código postal válido';

  @override
  String get validationSSNFormat => 'Por favor ingresa un SSN válido (ej. 123-45-6789)';

  @override
  String get validationSSNInvalid => 'SSN inválido';

  @override
  String get validationEmailTooLong => 'El correo electrónico es demasiado largo (máx. 254 caracteres)';

  @override
  String get validationEmailLocalPartTooLong => 'La parte local del correo electrónico es demasiado larga';

  @override
  String get categoriesAll => 'Todos';

  @override
  String get categoriesSalon => 'Salones';

  @override
  String get categoriesBarbershop => 'Barberías';

  @override
  String get categoriesSpa => 'Spas';

  @override
  String get categoriesNailSalon => 'Salones de Uñas';

  @override
  String get categoriesLashStudio => 'Estudios de Pestañas';

  @override
  String get categoriesWaxing => 'Depilación';

  @override
  String get categoriesMassage => 'Masaje';

  @override
  String get categoriesMakeup => 'Maquillaje';

  @override
  String get categoriesSkincare => 'Cuidado de la Piel';

  @override
  String get luxuryLevelModerate => 'Moderado';

  @override
  String get luxuryLevelLuxury => 'Lujo';

  @override
  String get luxuryLevelUltraLuxury => 'Ultra Lujo';

  @override
  String get dashboardTabRevenue => 'Ingresos';

  @override
  String get dashboardTabAnalytics => 'Análisis';

  @override
  String get dashboardTabInsights => 'Perspectivas';

  @override
  String get dashboardTabTools => 'Herramientas';

  @override
  String get dashboardTabClients => 'Clientes';

  @override
  String get dashboardTabStaff => 'Personal';

  @override
  String get walletRecentTransactions => 'Transacciones Recientes';

  @override
  String get walletLoadError => 'No pudimos cargar tu billetera en este momento.';

  @override
  String get walletTransactionLoadError => 'No se pudieron cargar las transacciones recientes.';

  @override
  String get walletPaymentProcessing => 'Por favor espera a que el pago se procese y regresa a tu aplicación para completar tu reserva.';

  @override
  String get analyticsRevenue => 'Ingresos';

  @override
  String get analyticsServices => 'Servicios';

  @override
  String get analyticsWorkers => 'Trabajadores';

  @override
  String get analyticsLoadError => 'No se pudieron cargar los análisis';

  @override
  String get analyticsEmpty => 'Sin datos disponibles para análisis.';

  @override
  String get analyticsEmptySubtitle => 'Las estadísticas de reservas e ingresos aparecerían aquí';

  @override
  String get insightsReports => 'Reportes';

  @override
  String get insightsSeeAll => 'Ver Todo';

  @override
  String get insightsLoadError => 'No se pudieron cargar los reportes. Tira hacia abajo para actualizar.';

  @override
  String get insightsNoAlerts => '¡Todo bien! Sin alertas';

  @override
  String get insightsHeatmapError => 'No se pudo cargar el mapa de calor de reservas.';

  @override
  String get insightsNoHeatmapData => 'Sin datos de mapa de calor disponibles';

  @override
  String get toolsAdminTools => 'Herramientas de Administración';

  @override
  String get toolsConfigure => 'Configurar →';

  @override
  String get toolsManage => 'Administrar →';

  @override
  String get toolsExport => 'Exportar →';

  @override
  String get toolsAutomatedReminders => 'Recordatorios Automatizados';

  @override
  String get toolsPromotionsManager => 'Gestor de Promociones';

  @override
  String get toolsExportReports => 'Exportar Reportes';

  @override
  String get toolsPaymentSettings => 'Configuración de Pagos';

  @override
  String get toolsLoadingDetails => 'Cargando detalles de la tienda…';

  @override
  String get toolsBusinessHours => 'Horario de Atención';

  @override
  String get toolsServiceManagement => 'Gestión de Servicios';

  @override
  String get clientsSearchHint => 'Buscar por nombre...';

  @override
  String get clientsLoadError => 'No se pudieron cargar los clientes';

  @override
  String get clientsNotFound => 'No hay Clientes Coincidentes';

  @override
  String get clientsEmpty => 'Sin Clientes Aún';

  @override
  String clientsSearchEmpty(String query) {
    return 'No hay clientes que coincidan con \"$query\"';
  }

  @override
  String get clientsEmptySubtitle => 'Los clientes aparecerán aquí cuando realicen su primera reserva.';

  @override
  String get walletLabel => 'Cartera';

  @override
  String get walletAvailableBalance => 'Saldo Disponible';

  @override
  String get walletWithdrawFunds => 'Retirar Fondos';

  @override
  String get walletTotalEarned => 'Total Ganado';

  @override
  String get walletTotalWithdrawn => 'Total Retirado';

  @override
  String get transactionDepositReceived => 'Depósito Recibido';

  @override
  String get transactionServicePayment => 'Pago de Servicio';

  @override
  String get transactionWithdrawal => 'Retiro';

  @override
  String get transactionRefund => 'Reembolso';

  @override
  String get transactionPlatformFee => 'Comisión de Plataforma';

  @override
  String get transactionAdjustment => 'Ajuste';

  @override
  String get transactionToday => 'Hoy';

  @override
  String get transactionYesterday => 'Ayer';

  @override
  String get withdrawalTitle => 'Retirar';

  @override
  String withdrawalInfo(double fee, String currency, double minFee) {
    return 'Los retiros se procesan inmediatamente y se envían a tu cuenta conectada. Se aplica una comisión de $fee% (mín $currency $minFee).';
  }

  @override
  String withdrawalAvailableBalance(String currency, String amount) {
    return 'Saldo disponible: $currency $amount';
  }

  @override
  String withdrawalAmountInputLabel(String currency) {
    return 'Cantidad ($currency)';
  }

  @override
  String get withdrawalAmountHint => 'Ingresa la cantidad a retirar';

  @override
  String get withdrawalAmountRequired => 'Por favor ingresa una cantidad';

  @override
  String get withdrawalAmountInvalid => 'Por favor ingresa una cantidad válida';

  @override
  String withdrawalMinimum(String currency, double min) {
    return 'El retiro mínimo es $currency $min';
  }

  @override
  String withdrawalMaximum(String currency, double max) {
    return 'El retiro máximo por transacción es $currency $max';
  }

  @override
  String withdrawalInsufficientBalance(String currency, String available) {
    return 'Saldo insuficiente. Disponible: $currency $available';
  }

  @override
  String get withdrawalBreakdownAmount => 'Cantidad a retirar:';

  @override
  String withdrawalFeeLabel(Object fee) {
    return 'Comisión ($fee%):';
  }

  @override
  String get withdrawalNetAmount => 'Recibirás:';

  @override
  String get withdrawalProcessing => 'Procesando...';

  @override
  String get withdrawalRequestButton => 'Solicitar Retiro';

  @override
  String get withdrawalNoPaymentMethod => 'Ningún método de pago conectado';

  @override
  String get withdrawalSuccess => '¡Solicitud de retiro enviada exitosamente!';

  @override
  String get deadLetterTitle => 'Retiro necesita revisión';

  @override
  String deadLetterSingle(String currency, String amount) {
    return '$currency $amount atascado — toca para detalles';
  }

  @override
  String deadLetterMultiple(String currency, String amount, int count) {
    return '$currency $amount atascado en $count retiros — toca para detalles';
  }

  @override
  String get deadLetterReason => 'Razón:';

  @override
  String get deadLetterContactSupport => 'Contactar soporte';

  @override
  String get paymentSetupTitle => 'Completar configuración de pagos';

  @override
  String get paymentSetupContent => 'Conecta tu cuenta de pagos para comenzar a retirar dinero de tu cartera. Esto podría ser tu número de teléfono móvil o tu cuenta bancaria.';

  @override
  String get calendarErrorLoading => 'Error al cargar el calendario';

  @override
  String get calendarErrorLoadingBookings => 'Error al cargar las reservas';

  @override
  String get calendarNoAppointmentsDay => 'Sin citas para este día';

  @override
  String get calendarNoBookingsDay => 'Sin reservas para este día';

  @override
  String calendarAppointmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'citas',
      one: 'cita',
    );
    return '$count $_temp0';
  }

  @override
  String get monthJanuary => 'Ene';

  @override
  String get monthFebruary => 'Feb';

  @override
  String get monthMarch => 'Mar';

  @override
  String get monthApril => 'Abr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'Jun';

  @override
  String get monthJuly => 'Jul';

  @override
  String get monthAugust => 'Ago';

  @override
  String get monthSeptember => 'Sep';

  @override
  String get monthOctober => 'Oct';

  @override
  String get monthNovember => 'Nov';

  @override
  String get monthDecember => 'Dic';

  @override
  String get dayMonday => 'Lun';

  @override
  String get dayTuesday => 'Mar';

  @override
  String get dayWednesday => 'Mié';

  @override
  String get dayThursday => 'Jue';

  @override
  String get dayFriday => 'Vie';

  @override
  String get daySaturday => 'Sáb';

  @override
  String get daySunday => 'Dom';

  @override
  String calendarNoAppointmentsSnackbar(String date) {
    return 'Sin citas en este día\n$date';
  }

  @override
  String reviewsScreenTitle(String shopName) {
    return 'Reseñas para $shopName';
  }

  @override
  String get reviewsLoadError => 'No se pudieron cargar las reseñas';

  @override
  String get reviewsNoReviews => 'Sin reseñas aún';

  @override
  String get reviewsRateProduct => 'Calificar producto';

  @override
  String get reviewsYourReview => 'Tu reseña';

  @override
  String get reviewsReviewHint => 'Comparte tu experiencia con este producto...';

  @override
  String get reviewsSubmitButton => 'Enviar reseña';

  @override
  String get reviewsThankYou => '¡Gracias por tu reseña!';

  @override
  String reviewsSubmitError(String error) {
    return 'No se pudo enviar la reseña: $error';
  }

  @override
  String get bookingServiceAddress => 'Dirección de servicio';

  @override
  String get bookingFindingAvailableTimes => 'Buscando horarios disponibles...';

  @override
  String bookingErrorLoadingWorkers(String error) {
    return 'Error al cargar trabajadores: $error';
  }

  @override
  String bookingErrorValidatingDistance(String error) {
    return 'Error al validar distancia: $error';
  }

  @override
  String get bookingAddSpecialRequirements => 'Añadir';

  @override
  String get bookingCancelSpecialRequirements => 'Cancelar';

  @override
  String get bookingSaveSpecialRequirements => 'Guardar';

  @override
  String bookingFailedSaveRequirements(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String get bookingInvitationSent => 'Invitación enviada con éxito';

  @override
  String get bookingSavingAssignments => 'Guardando asignaciones...';

  @override
  String get bookingAssignmentsSaved => 'Asignaciones guardadas con éxito';

  @override
  String bookingAssignmentsError(String error) {
    return 'Error: $error';
  }

  @override
  String get scheduleTitle => 'Cronograma';

  @override
  String get scheduleTabDaily => 'Diario';

  @override
  String get scheduleTabMonthly => 'Mensual';

  @override
  String get toolsLoyaltyRule => 'Loyalty rule';

  @override
  String get loyaltyTitle => 'Loyalty rule';

  @override
  String get loyaltyRewardHeader => 'Reward every Nth completed booking';

  @override
  String get loyaltyRewardSubheader => 'Clients never see their progress. The discount auto-applies on the qualifying booking as a surprise reward.';

  @override
  String get loyaltyTriggerSectionTitle => 'Trigger every';

  @override
  String get loyaltyTriggerCompletedBookings => 'completed bookings';

  @override
  String get loyaltyDiscountTypeTitle => 'Discount type';

  @override
  String get loyaltyDiscountTypePercent => 'Percent';

  @override
  String get loyaltyDiscountTypeFixed => 'Fixed amount';

  @override
  String get loyaltyPercentOff => 'Percent off';

  @override
  String get loyaltyAmountOff => 'Amount off';

  @override
  String get loyaltyActiveTitle => 'Active';

  @override
  String get loyaltyActiveSubtitle => 'When off, no loyalty codes are generated for this shop.';

  @override
  String get loyaltyLoadFailed => 'We couldn\'t load the loyalty rule.';

  @override
  String get loyaltyRetry => 'Retry';

  @override
  String get loyaltySave => 'Save';

  @override
  String get loyaltySavedSnackbar => 'Loyalty rule saved';

  @override
  String get promoFieldPerClientMaxLabel => 'Per-client redemption limit';

  @override
  String get promoFieldPerClientMaxHint => 'Times one client can use this code';

  @override
  String get promoFieldMinAmountLabel => 'Minimum booking amount (Optional)';

  @override
  String get promoFieldMinAmountHint => 'Code only applies above this total';

  @override
  String get promoFieldServiceRestrictionTitle => 'Restrict to services (Optional)';

  @override
  String get promoFieldServiceRestrictionSubtitle => 'Leave empty to apply to any service. Pick one or more to restrict the discount to bookings that include them.';

  @override
  String get promoFieldServiceRestrictionLoadFailed => 'We couldn\'t load your services.';

  @override
  String get promoFieldServiceRestrictionEmpty => 'No services to restrict against yet.';

  @override
  String get promoFieldArchivedTitle => 'Archived';

  @override
  String get promoFieldArchivedSubtitle => 'Archived promotions are hidden from clients and frees up the code text for re-use.';

  @override
  String get promoValidationPerClientMin => 'Must be at least 1';

  @override
  String get promoValidationMinAmountNonNegative => 'Must be 0 or higher';

  @override
  String get promoListShowSystemCodes => 'Show system codes';

  @override
  String get promoListHideSystemCodes => 'Hide system codes';

  @override
  String get promoSourceOwner => 'Owner';

  @override
  String get promoSourceLoyalty => 'Loyalty';

  @override
  String get promoSourceRecovery => 'Recovery';

  @override
  String get promoSourceAutoGeneratedReadOnly => 'auto-generated · read-only';

  @override
  String get broadcastsTitle => 'Broadcasts';

  @override
  String get broadcastsToolsCardLabel => 'Broadcasts';

  @override
  String get broadcastsEmptyTitle => 'No broadcasts yet';

  @override
  String get broadcastsEmptyBody => 'Tap + to send your first. You can broadcast once per day to up to 1000 clients.';

  @override
  String get broadcastsFabTooltip => 'New broadcast';

  @override
  String get broadcastsLoadFailed => 'We couldn\'t load your broadcasts.';

  @override
  String get broadcastsRetry => 'Retry';

  @override
  String get broadcastCreateTitle => 'New broadcast';

  @override
  String get broadcastSubjectLabel => 'Subject';

  @override
  String get broadcastSubjectHelper => 'Shown as the push notification title.';

  @override
  String get broadcastSubjectRequired => 'Subject is required.';

  @override
  String get broadcastBodyLabel => 'Message';

  @override
  String get broadcastBodyHelper => 'Plain text only. WhatsApp recipients also see your shop name and an opt-out line.';

  @override
  String get broadcastBodyRequired => 'Message is required.';

  @override
  String get broadcastAudienceLabel => 'Audience';

  @override
  String get broadcastAudienceAllClients => 'All';

  @override
  String get broadcastAudienceRecent => 'Recent';

  @override
  String get broadcastAudienceLapsed => 'Lapsed';

  @override
  String get broadcastAudienceByService => 'Service';

  @override
  String get broadcastServiceLabel => 'Service';

  @override
  String get broadcastServicePickRequired => 'Pick a service.';

  @override
  String get broadcastServiceLoadFailed => 'We couldn\'t load your services.';

  @override
  String get broadcastServiceEmpty => 'No active services to pick from.';

  @override
  String get broadcastPromoLabel => 'Attach a promo code (optional)';

  @override
  String get broadcastPromoHelper => 'Only your own promo codes can be attached. Loyalty and recovery codes aren\'t shown.';

  @override
  String get broadcastPromoNone => 'None';

  @override
  String get broadcastPreviewResolving => 'Resolving audience…';

  @override
  String get broadcastPreviewPickAudience => 'Pick an audience to preview.';

  @override
  String get broadcastPreviewPickService => 'Pick a service to preview.';

  @override
  String broadcastPreviewCount(Object count) {
    return 'This will send to $count people.';
  }

  @override
  String get broadcastPreviewCapWarning => 'Audience exceeds the 1000-recipient cap. Try a narrower preset.';

  @override
  String get broadcastPreviewFailed => 'Couldn\'t preview audience.';

  @override
  String get broadcastSendButton => 'Send';

  @override
  String get broadcastConfirmTitle => 'Send broadcast?';

  @override
  String broadcastConfirmBodyAll(Object count) {
    return 'Send to $count all clients? This cannot be undone.';
  }

  @override
  String broadcastConfirmBodyRecent(Object count) {
    return 'Send to $count recent clients? This cannot be undone.';
  }

  @override
  String broadcastConfirmBodyLapsed(Object count) {
    return 'Send to $count lapsed clients? This cannot be undone.';
  }

  @override
  String broadcastConfirmBodyService(Object count) {
    return 'Send to $count clients of this service? This cannot be undone.';
  }

  @override
  String get broadcastConfirmBodyWithPromoSuffix => ' A promo code will be attached.';

  @override
  String get broadcastConfirmCancel => 'Cancel';

  @override
  String get broadcastConfirmSend => 'Send';

  @override
  String broadcastSentToast(Object count) {
    return 'Sent to $count people.';
  }

  @override
  String get broadcastStatusPending => 'Pending';

  @override
  String get broadcastStatusDelivering => 'Sending';

  @override
  String get broadcastStatusDelivered => 'Sent';

  @override
  String get broadcastStatusFailed => 'Failed';

  @override
  String get broadcastDeliveringTooltip => 'WhatsApp template approval is pending. This usually resolves within 24h.';

  @override
  String broadcastAudienceLabelShort(Object audience) {
    return 'Audience: $audience';
  }

  @override
  String broadcastPromoLabelShort(Object id) {
    return 'Promo attached: $id';
  }

  @override
  String broadcastRecipientsLabel(Object count) {
    return 'Recipients: $count';
  }

  @override
  String broadcastDeliveredLabel(Object when) {
    return 'Delivered: $when';
  }

  @override
  String broadcastStatusLabel(Object status) {
    return 'Status: $status';
  }

  @override
  String get broadcastDetailClose => 'Close';

  @override
  String get broadcastRateLimitMessage => 'You\'ve already sent a broadcast today. Try again tomorrow.';

  @override
  String get broadcastInFlightMessage => 'Another broadcast is being processed. Please wait a moment.';

  @override
  String get broadcastInvalidAudienceMessage => 'Please pick a valid audience and (if \'By service\') a service.';

  @override
  String get broadcastPromoInvalidMessage => 'This code is no longer valid. Pick another or remove the code.';

  @override
  String get broadcastCapExceededMessage => 'This audience is larger than the 1000-recipient cap. Try a narrower audience.';

  @override
  String get broadcastSaveFailedMessage => 'Could not send broadcast. Please try again.';

  @override
  String get pricingChipDiscount => 'Discount';

  @override
  String get pricingChipSurcharge => 'Surcharge';

  @override
  String get pricingOverridesTitle => 'Pricing rules';

  @override
  String get pricingOverridesEmptyTitle => 'No rules yet';

  @override
  String pricingOverridesEmptyBody(String serviceName) {
    return 'Add a time-based discount or surcharge for $serviceName.';
  }

  @override
  String get pricingOverridesEmptyCta => 'Create rule';

  @override
  String get pricingOverridesNewCta => 'New rule';

  @override
  String get pricingOverridesRefresh => 'Refresh';

  @override
  String get pricingOverridesLoadFailed => 'Could not load pricing rules.';

  @override
  String get pricingOverridesRetry => 'Retry';

  @override
  String get pricingOverrideArchiveConfirmTitle => 'Archive rule?';

  @override
  String pricingOverrideArchiveConfirmBody(String name) {
    return '\"$name\" will stop applying to new bookings. Existing bookings keep the price they were confirmed at.';
  }

  @override
  String get pricingOverrideArchiveConfirmCancel => 'Cancel';

  @override
  String get pricingOverrideArchiveConfirmArchive => 'Archive';

  @override
  String get pricingOverrideArchiveSuccess => 'Rule archived';

  @override
  String get pricingOverrideArchiveFailed => 'Could not archive the rule. Please try again.';

  @override
  String get pricingOverrideRowActionsTooltip => 'Actions';

  @override
  String get pricingOverrideRowEdit => 'Edit';

  @override
  String get pricingOverrideRowArchive => 'Archive';

  @override
  String get pricingOverrideAllWeek => 'All week';

  @override
  String get pricingOverrideFormTitleNew => 'New rule';

  @override
  String get pricingOverrideFormTitleEdit => 'Edit rule';

  @override
  String get pricingOverrideFormName => 'Name';

  @override
  String get pricingOverrideFormNameHint => 'e.g. Off-peak Tuesday morning';

  @override
  String get pricingOverrideFormNameRequired => 'Required';

  @override
  String get pricingOverrideFormNameTooLong => 'Max 80 characters';

  @override
  String get pricingOverrideFormDayOfWeek => 'Day of week';

  @override
  String get pricingOverrideFormTimeWindow => 'Time window';

  @override
  String get pricingOverrideFormStart => 'Start';

  @override
  String get pricingOverrideFormEnd => 'End';

  @override
  String get pricingOverrideFormWindowError => 'End time must be after start time';

  @override
  String get pricingOverrideFormAdjustment => 'Adjustment';

  @override
  String get pricingOverrideFormKindPercentDiscount => '% off';

  @override
  String get pricingOverrideFormKindPercentSurcharge => '% up';

  @override
  String get pricingOverrideFormKindFixedDiscount => '\$ off';

  @override
  String get pricingOverrideFormKindFixedSurcharge => '\$ up';

  @override
  String get pricingOverrideFormValueRequired => 'Required';

  @override
  String get pricingOverrideFormValueMustBePositive => 'Must be greater than 0';

  @override
  String get pricingOverrideFormValuePercentRange => 'Percent must be 0.01–100';

  @override
  String get pricingOverrideFormValidity => 'Validity (optional)';

  @override
  String get pricingOverrideFormValidityStarts => 'Starts';

  @override
  String get pricingOverrideFormValidityEnds => 'Ends';

  @override
  String get pricingOverrideFormValidityNoExpiry => 'No expiry';

  @override
  String get pricingOverrideFormValidityToday => 'Today';

  @override
  String get pricingOverrideFormValidityError => 'End date must be after start date';

  @override
  String get pricingOverrideFormClearDayHint => 'To clear the day filter, archive this rule and create a new one.';

  @override
  String get pricingOverrideFormClearValidUntilHint => 'To clear the end date, archive this rule and create a new one.';

  @override
  String get pricingOverrideFormPreviewLabel => 'Preview';

  @override
  String pricingOverrideFormPreviewPrompt(String base) {
    return 'Base $base · enter a value to see the effective price.';
  }

  @override
  String pricingOverrideFormPreviewDiscount(String delta, String base) {
    return '(saved $delta vs $base base)';
  }

  @override
  String pricingOverrideFormPreviewSurcharge(String delta, String base) {
    return '(+$delta vs $base base)';
  }

  @override
  String pricingOverrideFormSoftWarnPercent(String value) {
    return 'This is a +$value% surcharge. Double-check before saving.';
  }

  @override
  String get pricingOverrideFormSoftWarnFixed => 'This surcharge is more than 5× the base price. Double-check before saving.';

  @override
  String get pricingOverrideFormSaveNew => 'Create rule';

  @override
  String get pricingOverrideFormSaveEdit => 'Save changes';

  @override
  String get pricingOverrideFormDiscardTitle => 'Discard changes?';

  @override
  String get pricingOverrideFormDiscardBody => 'Your edits will be lost.';

  @override
  String get pricingOverrideFormDiscardKeep => 'Keep editing';

  @override
  String get pricingOverrideFormDiscardConfirm => 'Discard';

  @override
  String get pricingOverrideCreatedToast => 'Rule created';

  @override
  String get pricingOverrideUpdatedToast => 'Rule updated';

  @override
  String get pricingOverrideErrorWindow => 'The end time must be after the start time.';

  @override
  String get pricingOverrideErrorDay => 'Please pick a valid day of the week.';

  @override
  String get pricingOverrideErrorAdjustment => 'Please re-check the discount amount.';

  @override
  String get pricingOverrideErrorValidity => 'The end date must be after the start date.';

  @override
  String get pricingOverrideErrorCap => 'You\'ve reached the 50-rule limit on this service. Archive an old rule to free a slot.';

  @override
  String get pricingOverrideErrorNotFound => 'We couldn\'t find that pricing rule.';

  @override
  String get pricingOverrideErrorSaveFailed => 'We couldn\'t save the rule. Please try again.';

  @override
  String get pricingOverrideDayMonday => 'Monday';

  @override
  String get pricingOverrideDayTuesday => 'Tuesday';

  @override
  String get pricingOverrideDayWednesday => 'Wednesday';

  @override
  String get pricingOverrideDayThursday => 'Thursday';

  @override
  String get pricingOverrideDayFriday => 'Friday';

  @override
  String get pricingOverrideDaySaturday => 'Saturday';

  @override
  String get pricingOverrideDaySunday => 'Sunday';

  @override
  String get pricingOverrideDayShortMon => 'Mon';

  @override
  String get pricingOverrideDayShortTue => 'Tue';

  @override
  String get pricingOverrideDayShortWed => 'Wed';

  @override
  String get pricingOverrideDayShortThu => 'Thu';

  @override
  String get pricingOverrideDayShortFri => 'Fri';

  @override
  String get pricingOverrideDayShortSat => 'Sat';

  @override
  String get pricingOverrideDayShortSun => 'Sun';

  @override
  String get dailyReportTitle => 'Today\'s report';

  @override
  String get dailyReportHistoryTitle => 'Past reports';

  @override
  String get dailyReportNotificationTitle => 'Today\'s report is ready';

  @override
  String get dailyReportRefresh => 'Refresh';

  @override
  String get dailyReportRetry => 'Retry';

  @override
  String get dailyReportLoadFailed => 'We couldn\'t load the report.';

  @override
  String get dailyReportHistoryLoadFailed => 'We couldn\'t load history.';

  @override
  String get dailyReportRevenueLabel => 'Revenue';

  @override
  String get dailyReportBookingsCompleted => 'Completed';

  @override
  String get dailyReportBookingsNoShow => 'No-show';

  @override
  String get dailyReportBookingsCancelled => 'Cancelled';

  @override
  String get dailyReportBookingsConfirmedPastEnd => 'Confirmed past end';

  @override
  String get dailyReportComparisonTitle => 'Comparison';

  @override
  String get dailyReportComparisonYesterday => 'vs yesterday';

  @override
  String get dailyReportComparisonLastWeek => 'vs same day last week';

  @override
  String get dailyReportComparisonNoData => '—';

  @override
  String get dailyReportPerWorkerTitle => 'By staff';

  @override
  String get dailyReportPerServiceTitle => 'By service';

  @override
  String get dailyReportWorkerUnassigned => 'Unassigned';

  @override
  String get dailyReportTomorrowTitle => 'Tomorrow';

  @override
  String dailyReportTomorrowFirstBookingAt(String time) {
    return 'First booking at $time';
  }

  @override
  String dailyReportTomorrowCount(int count) {
    return '$count bookings';
  }

  @override
  String get dailyReportTomorrowGroupFlag => 'Includes group bookings';

  @override
  String get dailyReportTomorrowEmpty => 'No bookings tomorrow.';

  @override
  String get dailyReportFollowUpsTitle => 'Needs your attention';

  @override
  String get dailyReportFollowUpConfirmedPastEnd => 'Confirmed but never closed out';

  @override
  String get dailyReportFollowUpUnpaidBalance => 'Unpaid balance';

  @override
  String get dailyReportFollowUpNoShowNoAction => 'No-show — no note logged';

  @override
  String get dailyReportRegenerate => 'Re-generate';

  @override
  String get dailyReportRegenerateConfirmTitle => 'Re-generate this report?';

  @override
  String get dailyReportRegenerateConfirmBody => 'This rebuilds the report from the current data. The previous version is overwritten.';

  @override
  String get dailyReportRegenerateConfirmCancel => 'Cancel';

  @override
  String get dailyReportRegenerateConfirmAction => 'Re-generate';

  @override
  String get dailyReportRegenerated => 'Report updated.';

  @override
  String get dailyReportEmptyTitle => 'No report yet';

  @override
  String get dailyReportEmptyBody => 'No bookings recorded for this date. Tap Re-generate to build an empty report.';

  @override
  String get dailyReportHistoryEmpty => 'No past reports yet.';

  @override
  String get dailyReportErrorGeneric => 'We couldn\'t build the report. Please try again.';
}
