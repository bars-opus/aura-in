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

  @override
  String get docsGettingStartedTitle => 'Primeros Pasos';

  @override
  String get docsGettingStartedSubtitle => 'Aprende lo básico';

  @override
  String get docsGettingStartedWhatIsTitle => '¿Qué es Aura In?';

  @override
  String get docsGettingStartedWhatIsSubtitle => 'Entender la plataforma';

  @override
  String get docsGettingStartedWelcomeIntroContent => 'Aura In es un mercado móvil que conecta profesionales de servicios con clientes. Ya sea que ofrezca cortes de cabello, masajes, servicios independientes o venda productos, esta plataforma ayuda a que su negocio crezca.';

  @override
  String get docsGettingStartedWhoUsesTitle => '¿Quién usa Aura In?';

  @override
  String get docsGettingStartedWhoUsesContent => 'Dos tipos de usuarios impulsan la plataforma:';

  @override
  String get docsGettingStartedWhoUsesProviders => 'Proveedores de servicios - Salones, spas, barberos, freelancers que ofrecen servicios';

  @override
  String get docsGettingStartedWhoUsesCustomers => 'Clientes - Personas que buscan y reservan servicios en su área';

  @override
  String get docsGettingStartedWhoUsesSellers => 'Vendedores de productos - Tiendas que venden productos minoristas o artículos hechos a mano';

  @override
  String get docsGettingStartedHowItWorksTitle => 'Cómo funciona';

  @override
  String get docsGettingStartedHowItWorksContent => 'Los proveedores de servicios crean un perfil, enumeran sus servicios con precios y aceptan reservas de clientes. Los clientes buscan por ubicación, exploran servicios y reservan citas. Todo se gestiona a través de la aplicación.';

  @override
  String get docsGettingStartedThreeWaysTitle => 'Tres formas de usar Aura In';

  @override
  String get docsGettingStartedThreeWaysSubtitle => 'Elige tu rol';

  @override
  String get docsGettingStartedOption1Title => 'Opción 1: Explorar y reservar servicios (Cliente)';

  @override
  String get docsGettingStartedOption1Content => 'Busque salones, masajistas, barberos o freelancers cerca de usted. Vea sus servicios, precios y disponibilidad. Reserve citas directamente a través de la aplicación y pague de forma segura.';

  @override
  String get docsGettingStartedGuestBookingTitle => 'Reserva de invitado (sin necesidad de descargar la aplicación)';

  @override
  String get docsGettingStartedGuestBookingContent => '¿No desea descargar la aplicación? Los proveedores de servicios pueden compartir un enlace de reserva - puede reservar y pagar directamente a través de ese enlace sin crear una cuenta. Sus detalles de reserva y recibo se enviarán a WhatsApp.';

  @override
  String get docsGettingStartedOption2Title => 'Opción 2: Ofrecer servicios (Propietario de tienda o Freelancer)';

  @override
  String get docsGettingStartedOption2Content => 'Cree un perfil de tienda o freelancer, enumere sus servicios con precios y duración, establezca sus horas de trabajo y administre reservas. Gane dinero con cada servicio reservado.';

  @override
  String get docsGettingStartedOption3Title => 'Opción 3: Vender productos (Vendedor de productos)';

  @override
  String get docsGettingStartedOption3Content => 'Si fabrica artículos hechos a mano o vende productos minoristas, puede enumerarlos para la venta. Los clientes exploran y compran directamente de su tienda.';

  @override
  String get docsGettingStartedBookingPaymentTitle => 'Sistema de reserva y pago';

  @override
  String get docsGettingStartedBookingPaymentSubtitle => 'Cómo funcionan las reservas de servicios y los pagos';

  @override
  String get docsGettingStartedBookingOverviewContent => 'Los clientes reservan citas con proveedores de servicios. Los pagos se procesan de forma segura a través de la aplicación mediante Paystack (África) o Stripe (Global).';

  @override
  String get docsGettingStartedDepositPaymentTitle => 'Depósito (30%)';

  @override
  String get docsGettingStartedDepositPaymentContent => 'Al reservar un servicio, los clientes pagan el 30% por adelantado como depósito para asegurar la ranura horaria. Esto confirma que la reserva es real y está reservada.';

  @override
  String get docsGettingStartedPlatformFeeTitle => 'Tarifa de plataforma';

  @override
  String get docsGettingStartedPlatformFeeContent => 'Se agrega una pequeña tarifa de plataforma (2%) para ayudarnos a mantener la plataforma y proporcionar soporte. Se calcula sobre el monto total de la reserva.';

  @override
  String get docsGettingStartedRemainingPaymentTitle => 'Pago restante (70%)';

  @override
  String get docsGettingStartedRemainingPaymentContent => 'El 70% restante se puede pagar de cualquiera de dos formas: (1) en efectivo cuando se complete el servicio, o (2) en línea a través de la aplicación antes de la cita.';

  @override
  String get docsGettingStartedGuestBookingPaymentTitle => 'Pago de reserva de invitado';

  @override
  String get docsGettingStartedGuestBookingPaymentContent => '¡Sin necesidad de descargar la aplicación! Los clientes reciben un enlace de reserva del proveedor de servicios. Pagan el 30% para asegurar la ranura, y su recibo se envía a WhatsApp.';

  @override
  String get docsGettingStartedProductOrderingTitle => 'Pedido y entrega de productos';

  @override
  String get docsGettingStartedProductOrderingSubtitle => 'Cómo funciona la venta de productos';

  @override
  String get docsGettingStartedProductOverviewContent => 'Los clientes exploran productos, agregan artículos al carrito y completan el proceso de pago. Los productos se entregan en la ubicación del cliente.';

  @override
  String get docsGettingStartedCODPaymentTitle => 'Pago contra entrega (COD)';

  @override
  String get docsGettingStartedCODPaymentContent => 'Para pedidos de productos, el pago se maneja como pago contra entrega. Los clientes pagan al vendedor cuando reciben los artículos, sin pago por adelantado.';

  @override
  String get docsGettingStartedShareYourProfileTitle => 'Compartir su perfil';

  @override
  String get docsGettingStartedShareYourProfileSubtitle => 'Facilite que los clientes lo encuentren';

  @override
  String get docsGettingStartedShareLinkContent => 'Como proveedor de servicios, obtiene un enlace de reserva único. Compártalo en WhatsApp, redes sociales o correo electrónico. Los clientes pueden reservar servicios sin descargar la aplicación.';

  @override
  String get docsGettingStartedCustomURLTitle => 'URL personalizada (opcional)';

  @override
  String get docsGettingStartedCustomURLContent => 'Puede personalizar el slug de su enlace de reserva (por ejemplo, aura.in/glamour-salon en lugar de aura.in/abc123). Facilita compartir y recordar.';

  @override
  String get docsGettingStartedGetHelpTitle => 'Obtener ayuda';

  @override
  String get docsGettingStartedGetHelpSubtitle => 'Dónde encontrar respuestas';

  @override
  String get docsGettingStartedHelpDocumentationContent => 'Esta aplicación tiene documentación completa para cada función. Cuando necesite ayuda, consulte la guía relevante: hay una para su rol y la función que está utilizando.';

  @override
  String get docsGettingStartedFAQ1Question => '¿Qué es Aura In?';

  @override
  String get docsGettingStartedFAQ1Answer => 'Aura In es un mercado móvil para negocios basados en servicios. Los clientes encuentran y reservan servicios (cortes de cabello, masajes, etc.), los proveedores de servicios administran reservas e ingresos, y los vendedores de productos enumeran artículos para la venta.';

  @override
  String get docsGettingStartedFAQ2Question => '¿Necesito pagar para usar la aplicación?';

  @override
  String get docsGettingStartedFAQ2Answer => 'La aplicación es gratuita para descargar y usar. Los proveedores de servicios solo pagan una pequeña comisión cuando los clientes pagan por servicios. Los procesadores de pago (Paystack/Stripe) cobran una tarifa.';

  @override
  String get docsGettingStartedFAQ3Question => '¿Cuál es la diferencia entre propietario de tienda y freelancer?';

  @override
  String get docsGettingStartedFAQ3Answer => 'Los propietarios de tiendas tienen una ubicación fija con un equipo de trabajadores. Los freelancers trabajan de forma independiente y pueden viajar a los clientes. Elija según su modelo de negocio.';

  @override
  String get docsGettingStartedFAQ4Question => '¿Cómo me pagan?';

  @override
  String get docsGettingStartedFAQ4Answer => 'Cuando los clientes pagan por servicios, el dinero va a su billetera. Puede retirar a su cuenta bancaria usando Paystack (África) o Stripe (Global).';

  @override
  String get docsGettingStartedFAQ5Question => '¿Mi información de pago es segura?';

  @override
  String get docsGettingStartedFAQ5Answer => 'Sí. Aura In utiliza Paystack y Stripe, procesadores de pago líderes con seguridad de nivel bancario. Nunca vemos sus datos de pago.';

  @override
  String get docsGettingStartedFAQ6Question => '¿Cómo sé si los proveedores de servicios cerca de mí son confiables?';

  @override
  String get docsGettingStartedFAQ6Answer => 'Cada proveedor de servicios tiene calificaciones y reseñas de clientes que han reservado con ellos. Lea las reseñas antes de reservar. Las calificaciones altas significan servicio consistente y de calidad.';

  @override
  String get docsGettingStartedFAQ7Question => '¿Puedo reservar sin descargar la aplicación?';

  @override
  String get docsGettingStartedFAQ7Answer => '¡Sí! Los proveedores de servicios comparten un enlace de reserva único. Puede reservar directamente a través de ese enlace sin descargar la aplicación. Su recibo se enviará a WhatsApp.';

  @override
  String get docsGettingStartedFAQ8Question => '¿Cuánto pago por adelantado para las reservas?';

  @override
  String get docsGettingStartedFAQ8Answer => 'Paga el 30% del total del servicio por adelantado para asegurar la ranura de reserva (más una tarifa de plataforma del 2%). El 70% restante se puede pagar en efectivo o en línea antes/en el servicio.';

  @override
  String get docsGettingStartedFAQ9Question => '¿Cómo pago por productos?';

  @override
  String get docsGettingStartedFAQ9Answer => 'Los productos utilizan el pago contra entrega (COD). Usted paga al vendedor cuando recibe los artículos. Esto le permite verificar la calidad antes de pagar y funciona bien para entregas locales.';

  @override
  String get docsGettingStartedFAQ10Question => '¿Por qué la tarifa de plataforma del 2%?';

  @override
  String get docsGettingStartedFAQ10Answer => 'La tarifa de plataforma nos ayuda a mantener Aura In, procesar pagos, proporcionar soporte al cliente y mejorar continuamente las funciones para clientes y proveedores de servicios.';

  @override
  String get docsBookingStartedTitle => 'Primeros pasos con reservas';

  @override
  String get docsBookingStartedSubtitle => 'Una guía sencilla para entender cómo funcionan las reservas';

  @override
  String get docsBookingIntroTitle => 'Bienvenido al sistema de reservas';

  @override
  String get docsBookingIntroSubtitle => 'Todo lo que necesita saber sobre reservar servicios, ya sea como cliente o como propietario de tienda.';

  @override
  String get docsBookingWhatIsTitle => '¿Qué es el sistema de reservas?';

  @override
  String get docsBookingWhatIsContent => 'El sistema de reservas es su puerta de entrada para programar servicios en sus tiendas favoritas. Ya sea que necesite un corte de cabello, un recorte de barba, trenzas u otro servicio, el sistema facilita reservar citas en su conveniencia.';

  @override
  String get docsBookingWhoIsForTitle => '¿Para quién es esta guía?';

  @override
  String get docsBookingWhoIsForContent => 'Esta guía está diseñada para dos tipos de usuarios:';

  @override
  String get docsBookingWhoIsForClients => 'Clientes: Personas que desean reservar servicios en tiendas';

  @override
  String get docsBookingWhoIsForGuests => 'Reservadores de invitados: Personas que desean reservar a través de un enlace sin crear una cuenta';

  @override
  String get docsBookingWhoIsForOwners => 'Propietarios de tienda: Personas que administran tiendas, servicios y trabajadores';

  @override
  String get docsBookingGuestIntroTitle => 'Nuevo: Reserva sin descargar la aplicación';

  @override
  String get docsBookingGuestIntroContent => '¿Sin cuenta? ¡Sin problema! Si el propietario de una tienda comparte un enlace de reserva con usted, puede reservar directamente sin descargar la aplicación. Su recibo se envía a WhatsApp.';

  @override
  String get docsBookingWelcomeTip => '¡No se requieren conocimientos técnicos! Esta guía utiliza un lenguaje simple y ejemplos reales para ayudarle a entender todo.';

  @override
  String get docsBookingAccountTitle => 'Crear su cuenta (O reservar como invitado)';

  @override
  String get docsBookingAccountSubtitle => 'Comience en minutos - con o sin cuenta';

  @override
  String get docsBookingTwoWaysTitle => 'Dos formas de reservar';

  @override
  String get docsBookingTwoWaysContent => 'Puede reservar de dos formas:';

  @override
  String get docsBookingTwoWaysAccount => 'Con cuenta: Descargar aplicación, crear cuenta, reservar en cualquier momento';

  @override
  String get docsBookingTwoWaysGuest => 'Como invitado: Usar enlace de reserva, sin necesidad de aplicación, recibo por WhatsApp';

  @override
  String get docsBookingAccountStepsTitle => 'Cómo crear una cuenta';

  @override
  String get docsBookingAccountStepsContent => 'Siga estos sencillos pasos para crear su cuenta:';

  @override
  String get docsBookingAccountTypesTitle => 'Tipos de cuenta';

  @override
  String get docsBookingAccountTypesContent => 'Hay dos tipos de cuentas:';

  @override
  String get docsBookingAccountTypesClient => 'Cuenta de cliente: Para reservar servicios en tiendas';

  @override
  String get docsBookingAccountTypesShop => 'Cuenta de propietario de tienda: Para administrar su propia tienda (requiere aprobación)';

  @override
  String get docsBookingGuestOptionTitle => 'Reservar como invitado (sin cuenta)';

  @override
  String get docsBookingGuestOptionContent => 'Si alguien comparte un enlace de reserva con usted, puede reservar directamente sin crear una cuenta. Simplemente haga clic en el enlace y siga los pasos. Su recibo se envía a su WhatsApp.';

  @override
  String get docsBookingVerificationNote => 'Puede examinar y reservar sin una cuenta usando un enlace de reserva. Crear una cuenta le da acceso al historial de reservas, pagos guardados y recompensas de lealtad.';

  @override
  String get docsBookingFirstBookingTitle => 'Su primera reserva';

  @override
  String get docsBookingFirstBookingSubtitle => 'Un rápido repaso';

  @override
  String get docsBookingPaymentTitle => 'Cómo funciona el pago';

  @override
  String get docsBookingPaymentContent => 'Cuando reserva un servicio, así es como funciona el pago:';

  @override
  String get docsBookingPaymentDeposit => 'Se requiere depósito del 30%: Para asegurar su reserva, paga el 30% del costo total del servicio por adelantado';

  @override
  String get docsBookingPaymentNonRefundable => 'No reembolsable: Este depósito no se reembolsa si cancela o no se presenta';

  @override
  String get docsBookingPaymentRemaining => 'Saldo restante: El 70% restante se paga después de que se complete su servicio';

  @override
  String get docsBookingPaymentSecure => 'Pago seguro: Todos los pagos se procesan de forma segura a través de nuestros socios de pago';

  @override
  String get docsBookingDepositNote => 'El depósito del 30% le protege a usted y a la tienda. Garantiza que su espacio esté reservado exclusivamente para usted y compensa al trabajador si cancela en el último momento.';

  @override
  String get docsBookingBookingTip => 'Consejo profesional: Reserva al menos 24 horas antes para obtener la mejor selección de franjas horarias, especialmente para servicios populares.';

  @override
  String get docsBookingAfterTitle => 'Después de reservar';

  @override
  String get docsBookingAfterSubtitle => 'Qué sucede después';

  @override
  String get docsBookingWhatsNextTitle => '¡Su reserva está confirmada!';

  @override
  String get docsBookingWhatsNextContent => 'Esto es lo que puede hacer después de reservar:';

  @override
  String get docsBookingRemindersTitle => 'Recordatorios de reserva';

  @override
  String get docsBookingRemindersContent => 'Recibirá recordatorios en:';

  @override
  String get docsBookingAfterServiceTitle => 'Después de su servicio';

  @override
  String get docsBookingAfterServiceContent => 'Una vez que se complete su servicio:';

  @override
  String get docsPaymentTitle => 'Pago y tarifas explicados';

  @override
  String get docsPaymentSubtitle => 'Cómo funcionan los depósitos del 30%, las tarifas de plataforma y las reservas de invitados';

  @override
  String get docsPaymentOverviewTitle => 'Cómo funciona el pago';

  @override
  String get docsPaymentOverviewSubtitle => 'Simple, transparente, seguro';

  @override
  String get docsPaymentSummaryTitle => 'Pago de un vistazo';

  @override
  String get docsPaymentSummaryContent => 'Nuestro sistema de pago está diseñado para ser justo tanto para clientes como para propietarios de tiendas. Aquí está el desglose simple:';

  @override
  String get docsPaymentDeposit30 => 'Depósito del 30%: Pagado al reservar para asegurar su cita';

  @override
  String get docsPaymentPlatformFee => 'Tarifa de plataforma: Pequeña tarifa fija (p. ej., GHS 2) cobrada por la aplicación';

  @override
  String get docsPaymentRemaining70 => '70% restante: Pagado después de completar su servicio';

  @override
  String get docsPaymentTwoWays => 'Dos formas de pagar lo restante: Efectivo o a través de la aplicación';

  @override
  String get docsPaymentQuickExampleTitle => 'Ejemplo rápido';

  @override
  String get docsPaymentQuickExampleContent => 'Costo del servicio: GHS 100\nAl reservar: Pague GHS 30 (depósito) + GHS 2 (tarifa) = GHS 32\nDespués del servicio: Pague GHS 70 (efectivo o aplicación)\nTotal a la tienda: GHS 100\nTarifa de plataforma: GHS 2';

  @override
  String get docsPaymentImportantNote => 'La tarifa de plataforma la cobra la aplicación, no la tienda. Nos ayuda a mantener la plataforma y a proporcionarle una excelente experiencia de reserva.';

  @override
  String get docsPaymentGuestBookingTitle => 'Reserva de invitado (sin descargar la aplicación)';

  @override
  String get docsPaymentGuestBookingContent => '¿No tiene la aplicación? ¡Sin problema! Aún puede reservar a través del enlace de reserva de su proveedor sin crear una cuenta. Paga el mismo depósito del 30% + tarifa de plataforma, y su recibo se envía a WhatsApp.';

  @override
  String get docsDepositTitle => 'El depósito del 30%';

  @override
  String get docsDepositSubtitle => 'Por qué es necesario y cómo funciona';

  @override
  String get docsDepositWhyTitle => '¿Por qué requerimos un depósito?';

  @override
  String get docsDepositWhyContent => 'El depósito del 30% lo protege a usted y a la tienda:';

  @override
  String get docsDepositProtectsYou => 'Para usted: Su espacio está garantizado – nadie más puede reservarlo';

  @override
  String get docsDepositProtectsShop => 'Para la tienda: Los trabajadores se compensan si cancela a último momento';

  @override
  String get docsDepositProtectsEveryone => 'Para todos: Reduce las ausencias, manteniendo los precios justos';

  @override
  String get docsDepositCalcTitle => 'Cómo se calcula el depósito';

  @override
  String get docsDepositCalcContent => 'El depósito es siempre el 30% del costo total del servicio. Esto incluye:';

  @override
  String get docsDepositCalcSingle => 'Servicio único: 30% de ese precio de servicio';

  @override
  String get docsDepositCalcMultiple => 'Múltiples servicios: 30% de todos los servicios combinados';

  @override
  String get docsDepositCalcGroup => 'Reservas grupales: 30% del total para todas las personas';

  @override
  String get docsDepositExamplesTitle => 'Ejemplos de depósito';

  @override
  String get docsDepositExamplesSingle => 'Servicio único:\nCorte de cabello (GHS 45) → Depósito GHS 13.50';

  @override
  String get docsDepositExamplesMultiple => 'Múltiples servicios:\nCorte de cabello (GHS 45) + Recorte de barba (GHS 25) = GHS 70 total\nDepósito: GHS 21';

  @override
  String get docsDepositExamplesGroup => 'Reserva grupal (3 personas):\n3 × Corte de cabello (GHS 45 c/u) = GHS 135 total\nDepósito: GHS 40.50';

  @override
  String get docsDepositRefundTitle => 'Política de reembolso de depósito';

  @override
  String get docsDepositRefundContent => 'El depósito del 30% no es reembolsable. Esto significa:';

  @override
  String get docsDepositRefundCancel => 'Si cancela: El depósito no se devuelve';

  @override
  String get docsDepositRefundNoShow => 'Si no se presenta: El depósito no se devuelve';

  @override
  String get docsDepositRefundReschedule => 'Si reprograma: El depósito se transfiere al nuevo tiempo';

  @override
  String get docsDepositRefundShop => 'Si la tienda cancela: Depósito completo reembolsado';

  @override
  String get docsDepositWarning => 'Asegúrese de estar seguro de su reserva antes de pagar el depósito. Aunque puede reprogramar, el depósito no se puede reembolsar si cancela.';

  @override
  String get docsFeeTitle => 'Tarifa de plataforma';

  @override
  String get docsFeeSubtitle => 'La pequeña tarifa que mantiene la aplicación en funcionamiento';

  @override
  String get docsFeeWhatTitle => '¿Qué es la tarifa de plataforma?';

  @override
  String get docsFeeWhatContent => 'La tarifa de plataforma es un pequeño cargo fijo (p. ej., GHS 2) que va a la aplicación, no a la tienda. Cubre:';

  @override
  String get docsFeeAppDev => 'Desarrollo y mantenimiento de la aplicación';

  @override
  String get docsFeeSupport => 'Soporte al cliente y resolución de disputas';

  @override
  String get docsFeeProcessing => 'Costos de procesamiento de pagos';

  @override
  String get docsFeeFeatures => 'Nuevas características y mejoras';

  @override
  String get docsFeeHowTitle => 'Cómo se cobra la tarifa';

  @override
  String get docsFeeHowContent => 'Cosas importantes que debe saber sobre la tarifa de plataforma:';

  @override
  String get docsFeeFixed => 'Cantidad fija (no un porcentaje) – p. ej., GHS 2 por reserva';

  @override
  String get docsFeePerbooking => 'Cobrado una vez por reserva – no por servicio o por persona';

  @override
  String get docsFeeNonRefundable => 'No reembolsable – incluso si cancela';

  @override
  String get docsFeeShown => 'Se muestra claramente antes de confirmar el pago';

  @override
  String get docsFeeExamplesTitle => 'Ejemplos de tarifa de plataforma';

  @override
  String get docsFeeExamplesSingle => 'Una persona, un servicio: Tarifa GHS 2';

  @override
  String get docsFeeExamplesMultiple => 'Una persona, múltiples servicios: Tarifa GHS 2 (¡aún una reserva!)';

  @override
  String get docsFeeExamplesGroup => 'Familia de 4 reservando juntos: Tarifa GHS 2 (grupo completo)';

  @override
  String get docsFeeExamplesSeparate => 'Compare con reservas por separado:\n4 reservas separadas = 4 × GHS 2 = GHS 8 en tarifas\n1 reserva grupal = Tarifa GHS 2 – ¡ahorra GHS 6!';

  @override
  String get docsFeeGroupTip => '¡Reservar como grupo ahorra dinero en tarifas! En lugar de pagar la tarifa de plataforma por cada persona, paga solo una tarifa para toda la reserva grupal.';

  @override
  String get docsPaymentRemainingTitle => 'Pago del 70% restante';

  @override
  String get docsPaymentRemainingSubtitle => 'Efectivo u online - su elección';

  @override
  String get docsPaymentRemainingOptionsTitle => 'Dos opciones de pago';

  @override
  String get docsPaymentRemainingOptionsContent => 'Después de completar su servicio, tiene dos formas de pagar el 70% restante:';

  @override
  String get docsPaymentCashOption => 'Efectivo: Pague directamente a la tienda o trabajador';

  @override
  String get docsPaymentAppOption => 'A través de la aplicación: Pague a través de la aplicación con su método de pago guardado';

  @override
  String get docsPaymentRemainingTip => 'Ambos métodos de pago son igualmente válidos. Elija lo que sea más conveniente para usted en el momento del servicio.';

  @override
  String get docsCancellationTitle => 'Cancelaciones y reembolsos';

  @override
  String get docsCancellationSubtitle => 'Qué sucede si necesita cancelar';

  @override
  String get docsCancellationInfoTitle => 'Política de cancelación';

  @override
  String get docsCancellationInfoContent => 'Comprenda qué sucede cuando cancela:';

  @override
  String get docsCancellationUpTo24 => 'Cancelar hasta 24 horas antes: El depósito y la tarifa no son reembolsables';

  @override
  String get docsCancellationLessThan24 => 'Cancelar menos de 24 horas antes: Misma política – depósito y tarifa no reembolsables';

  @override
  String get docsCancellationReschedule => 'Reprogramar en su lugar: Su depósito se transfiere al nuevo tiempo (libre para reprogramar)';

  @override
  String get docsCancellationNoShow => 'No presentarse: Depósito y tarifa perdidos, y puede afectar el estado de su cuenta';

  @override
  String get docsHowToBookTitle => 'Cómo reservar servicios';

  @override
  String get docsHowToBookSubtitle => 'Una guía paso a paso para reservar sus citas';

  @override
  String get docsHowToBookOverviewTitle => 'Reserva de un vistazo';

  @override
  String get docsHowToBookOverviewSubtitle => 'El proceso de reserva en pasos simples';

  @override
  String get docsHowToBookTwoWaysTitle => 'Dos formas de reservar';

  @override
  String get docsHowToBookTwoWaysContent => 'Puede reservar de dos formas:';

  @override
  String get docsHowToBookTwoWaysWithApp => 'Con cuenta de app: Descargar app, crear cuenta, reservar en cualquier momento';

  @override
  String get docsHowToBookTwoWaysGuest => 'Como invitado: Usar enlace de reserva, sin app, recibo por WhatsApp';

  @override
  String get docsHowToBookStepsTitle => 'Su viaje de reserva (Con cuenta)';

  @override
  String get docsHowToBookStepsContent => 'Reservar un servicio toma solo unos pocos minutos. Esto es lo que hará:';

  @override
  String get docsHowToBookStep1 => 'Paso 1: Encuentre una tienda y explore servicios';

  @override
  String get docsHowToBookStep2 => 'Paso 2: Seleccione sus servicios y cantidades';

  @override
  String get docsHowToBookStep3 => 'Paso 3: Elija su trabajador preferido (si está disponible)';

  @override
  String get docsHowToBookStep4 => 'Paso 4: Elija una fecha y hora';

  @override
  String get docsHowToBookStep5 => 'Paso 5: Pague depósito del 30% + pequeña tarifa para confirmar';

  @override
  String get docsHowToBookStep6 => 'Paso 6: Después del servicio, pague el 70% restante en efectivo o a través de la app';

  @override
  String get docsHowToBookGuestTitle => 'Reserva de invitado (sin app)';

  @override
  String get docsHowToBookGuestContent => '¿No tiene la app? Si una tienda comparte un enlace de reserva con usted, siga los pasos anteriores pero sin necesidad de crear una cuenta. Su confirmación y recibo van a su WhatsApp.';

  @override
  String get docsHowToBookTimeTip => 'Todo el proceso generalmente toma menos de 2 minutos. Su progreso se guarda sobre la marcha, así que puede tomarse su tiempo.';

  @override
  String get docsBookingStep1Title => 'Paso 1: Encuentre su tienda y servicios';

  @override
  String get docsBookingStep1Subtitle => 'Descubra el lugar perfecto para sus necesidades';

  @override
  String get docsBookingFindShopTitle => 'Cómo encontrar una tienda';

  @override
  String get docsBookingFindShopContent => 'Puede encontrar tiendas de varias formas:';

  @override
  String get docsBookingFindShopHome => 'Pantalla de inicio: Explore tiendas recomendadas cerca de usted';

  @override
  String get docsBookingFindShopSearch => 'Buscar: Busque tiendas o servicios específicos por nombre';

  @override
  String get docsBookingFindShopCategories => 'Categorías: Filtre por tipo de servicio (Corte, Trenzas, Barba, etc.)';

  @override
  String get docsBookingFindShopFavorites => 'Favoritos: Acceso rápido a tiendas que ha guardado';

  @override
  String get docsBookingBrowseServicesTitle => 'Explorar servicios';

  @override
  String get docsBookingBrowseServicesContent => 'Una vez que selecciona una tienda, verá todos sus servicios disponibles. Cada servicio muestra:';

  @override
  String get docsBookingServiceName => 'Nombre del servicio (p. ej., Corte Afro, Trenzas Box)';

  @override
  String get docsBookingServiceDuration => 'Duración (cuánto tiempo toma)';

  @override
  String get docsBookingServicePrice => 'Precio (costo del servicio - va a la tienda)';

  @override
  String get docsBookingServiceDescription => 'Descripción (qué incluye)';

  @override
  String get docsBookingServiceWorker => 'Requisito de trabajador (si puede elegir quién lo hace)';

  @override
  String get docsBookingServiceExampleTitle => 'Ejemplo';

  @override
  String get docsBookingServiceExampleContent => 'Servicio de corte de cabello:\n• Nombre: Corte Afro\n• Duración: 1 hora\n• Precio: GHS 45 (pagado a la tienda)\n• Descripción: Corte afro profesional con estilo\n• Trabajador: Puede elegir su barbero preferido';

  @override
  String get docsBookingStep2Title => 'Paso 2: Seleccione sus servicios';

  @override
  String get docsBookingStep2Subtitle => 'Elija lo que desea y cuántas personas';

  @override
  String get docsBookingSelectServicesTitle => 'Selección de servicios';

  @override
  String get docsBookingSelectServicesContent => 'Para seleccionar un servicio, simplemente tóquelo. Lo verá destacado. Puede seleccionar múltiples servicios a la vez:';

  @override
  String get docsBookingSelectServicesTap => 'Toque un servicio para seleccionarlo';

  @override
  String get docsBookingSelectServicesCheckmark => 'Los servicios seleccionados muestran una marca de verificación';

  @override
  String get docsBookingSelectServicesMultiple => 'Puede seleccionar múltiples servicios (p. ej., Corte + Recorte de barba)';

  @override
  String get docsBookingSelectServicesDeselect => 'Toque de nuevo para deseleccionar';

  @override
  String get docsBookingGroupBookingTitle => 'Reserva para múltiples personas';

  @override
  String get docsBookingGroupBookingContent => 'Si está reservando para un grupo (como usted y sus hijos), puede aumentar la cantidad:';

  @override
  String get docsBookingGroupBookingQuantity => 'Después de seleccionar un servicio, verá un botón + y -';

  @override
  String get docsBookingGroupBookingIncrease => 'Toque + para aumentar el número de personas';

  @override
  String get docsBookingGroupBookingPrice => 'El precio se actualiza automáticamente';

  @override
  String get docsBookingGroupBookingLimit => 'Se muestra la cantidad máxima (algunos servicios tienen límites)';

  @override
  String get docsBookingGroupExampleTitle => 'Ejemplo: Reserva familiar';

  @override
  String get docsBookingGroupExampleContent => 'Papá quiere cortes de cabello para él y sus dos hijos:\n• Seleccione el servicio \"Corte de cabello\"\n• Toque + hasta que la cantidad muestre 3\n• El precio total muestra 3 × GHS 45 = GHS 135 (para la tienda)\n• Elegirá trabajadores para cada persona más tarde';

  @override
  String get docsBookingQuantityTip => 'La función de cantidad es perfecta para familias, grupos de amigos o cualquiera que reserve para múltiples personas a la vez.';

  @override
  String get docsGroupBookingsTitle => 'Reservas de grupo';

  @override
  String get docsGroupBookingsSubtitle => 'Cómo reservar servicios para usted y otros';

  @override
  String get docsGroupIntroTitle => '¿Qué son las reservas de grupo?';

  @override
  String get docsGroupIntroSubtitle => 'Reserva para familia, amigos o grupos hecha simple';

  @override
  String get docsGroupExplainedTitle => 'Reserva para múltiples personas';

  @override
  String get docsGroupExplainedContent => 'Las reservas de grupo le permiten reservar servicios para más de una persona a la vez. Esto es perfecto para:';

  @override
  String get docsGroupExplainedFamilies => 'Familias: Padres que reservan cortes de cabello para sí mismos y sus hijos';

  @override
  String get docsGroupExplainedFriends => 'Amigos: Grupo de amigos obteniendo servicios juntos';

  @override
  String get docsGroupExplainedEvents => 'Eventos: Brindis nupciales, cumpleaños u ocasiones especiales';

  @override
  String get docsGroupExplainedColleagues => 'Colegas: Construcción de equipos o salidas de trabajo';

  @override
  String get docsGroupRealExampleTitle => 'Ejemplo de la vida real';

  @override
  String get docsGroupRealExampleContent => 'La familia Mensah necesita cortes de cabello:\n• Padre: Quiere un corte fade\n• Madre: Quiere un recorte\n• Hijo (10): Quiere un corte infantil\n• Hija (8): Quiere trenzas\n\n¡En lugar de hacer 4 reservas separadas, pueden reservar todo junto de una sola vez!';

  @override
  String get docsGroupBenefitsTitle => 'Beneficios de reserva de grupo';

  @override
  String get docsGroupBenefitsContent => 'Reservar como grupo le da:';

  @override
  String get docsGroupBenefitsTransaction => 'Una transacción: Pague depósitos para todos a la vez';

  @override
  String get docsGroupBenefitsTiming => 'Tiempo coordinado: Todos reciben servicio alrededor de la misma hora';

  @override
  String get docsGroupBenefitsWorkers => 'Diferentes trabajadores: Cada persona puede elegir su trabajador preferido';

  @override
  String get docsGroupBenefitsManagement => 'Gestión simplificada: Ver y gestionar todas las reservas juntas';

  @override
  String get docsGroupBenefitsPlanning => 'Mejor planificación: La tienda puede prepararse para su grupo';

  @override
  String get docsGroupTip => '¡Las reservas de grupo son perfectas para familias! Puede reservar para usted y sus hijos de una sola vez, eligiendo diferentes trabajadores para cada persona. ¿Sin cuenta? ¡Use un enlace de reserva compartido por la tienda!';

  @override
  String get docsGroupHowTitle => 'Cómo hacer una reserva de grupo';

  @override
  String get docsGroupHowSubtitle => 'Guía paso a paso';

  @override
  String get docsGroupStep1Title => 'Paso 1: Seleccione su servicio';

  @override
  String get docsGroupStep1Content => 'Comience por encontrar una tienda y seleccionar el servicio que desea. Por ejemplo, toque \"Corte de cabello\".';

  @override
  String get docsGroupStep2Title => 'Paso 2: Elija la cantidad';

  @override
  String get docsGroupStep2Content => 'Después de seleccionar un servicio, verá botones + y -. Úselos para establecer cuántas personas necesitan este servicio:';

  @override
  String get docsGroupStep2Plus => 'Toque + para aumentar el número';

  @override
  String get docsGroupStep2Minus => 'Toque - para disminuir';

  @override
  String get docsGroupStep2Price => 'El precio se actualiza automáticamente';

  @override
  String get docsGroupStep2Max => 'No puede exceder la cantidad máxima mostrada';

  @override
  String get docsGroupStep2ExampleTitle => 'Ejemplo';

  @override
  String get docsGroupStep2ExampleContent => 'Para una familia de 3 que necesita cortes de cabello:\n• Seleccione el servicio \"Corte de cabello\"\n• Toque + dos veces (o hasta que la cantidad muestre 3)\n• El precio total muestra: 3 × GHS 45 = GHS 135';

  @override
  String get docsGroupStep3Title => 'Paso 3: Repita para cada servicio';

  @override
  String get docsGroupStep3Content => 'Si su grupo necesita servicios diferentes (p. ej., algunos quieren cortes, otros quieren trenzas), seleccione cada servicio y establezca la cantidad para cada uno:';

  @override
  String get docsGroupStep3Haircut => 'Seleccione \"Corte de cabello\" → establezca cantidad 2';

  @override
  String get docsGroupStep3Braids => 'Seleccione \"Trenzas\" → establezca cantidad 1';

  @override
  String get docsGroupStep3Track => 'El sistema mantiene un registro de todas las selecciones';

  @override
  String get docsGroupStep3ExampleTitle => 'Ejemplo: Servicios mixtos';

  @override
  String get docsGroupStep3ExampleContent => 'Familia de 4 con necesidades diferentes:\n• Papá: Corte de cabello (cantidad 1)\n• Mamá: Recorte (cantidad 1)\n• Hijo: Corte infantil (cantidad 1)\n• Hija: Trenzas (cantidad 1)\n\n¡Total: 4 servicios, pero los reservó todo de una sola vez!';

  @override
  String get docsGroupStep4Title => 'Paso 4: Elija trabajadores para cada persona';

  @override
  String get docsGroupStep4Content => 'Para servicios que le permiten elegir trabajadores, verá una lista de personas. Toque en cada persona para asignar su trabajador:';

  @override
  String get docsGroupStep4Person1 => 'Persona 1: Elegir John (especialista en fade)';

  @override
  String get docsGroupStep4Person2 => 'Persona 2: Elegir Sarah (experta en trenzas)';

  @override
  String get docsGroupStep4Person3 => 'Persona 3: Elegir Michael (cortes infantiles)';

  @override
  String get docsGroupStep4Person4 => 'Persona 4: Elegir John (mismo trabajador para múltiples personas)';

  @override
  String get docsGroupStep4ExampleTitle => 'Ejemplo: Diferentes trabajadores para diferentes personas';

  @override
  String get docsGroupStep4ExampleContent => 'Familia de 3 que reserva cortes de cabello:\n• Persona 1 (Papá): Elegir John (especialista en fade)\n• Persona 2 (Hijo): Elegir Michael (excelente con niños)\n• Persona 3 (Hija): Elegir Sarah (experta en trenzas)\n\nLos tres serán atendidos durante su bloque de cita.';

  @override
  String get docsGroupStep5Title => 'Paso 5: Elija su hora';

  @override
  String get docsGroupStep5Content => 'Cuando selecciona una fecha y hora, el sistema mostrará espacios que pueden acomodar a TODAS las personas en su grupo:';

  @override
  String get docsGroupStep5Regular => 'Vista normal: Muestra espacios para cada servicio por separado';

  @override
  String get docsGroupStep5Combined => 'Vista combinada: Muestra solo espacios donde todos pueden ser atendidos juntos';

  @override
  String get docsGroupStep5Duration => 'Duración: El tiempo mostrado incluye todos los servicios para todas las personas';

  @override
  String get docsGroupStep5ExampleTitle => 'Ejemplo: Cálculo de tiempo';

  @override
  String get docsGroupStep5ExampleContent => 'Reserva familiar:\n• Corte de cabello (45 min) × 2 personas = 90 min\n• Trenzas (2 horas) × 1 persona = 120 min\n• Tiempo de amortiguamiento entre servicios = 15 min\n• Tiempo total de cita: 3 horas 45 minutos\n\n¡El sistema maneja todo esto automáticamente!';

  @override
  String get docsGroupStep6Title => 'Paso 6: Pago';

  @override
  String get docsGroupStep6Content => 'Para reservas de grupo, usted paga:';

  @override
  String get docsGroupStep6Deposit => 'Depósito del 30%: Calculado en el TOTAL de todos los servicios';

  @override
  String get docsGroupStep6Fee => 'Tarifa de plataforma: Tarifa fija pequeña (p. ej., GHS 2) - cobrada UNA SOLA VEZ para todo el grupo';

  @override
  String get docsGroupStep6Remaining => '70% restante: Pagado después de completar todos los servicios';

  @override
  String get docsGroupStep6Options => 'Opciones de pago: Efectivo, tarjeta, dinero móvil o pago de aplicación';

  @override
  String get docsGroupStep6ExampleTitle => 'Ejemplo de pago';

  @override
  String get docsGroupStep6ExampleContent => 'Total de reserva familiar: GHS 400\n• Depósito en reserva: GHS 120 (30% de GHS 400)\n• Tarifa de plataforma: GHS 2 (cobrada UNA SOLA VEZ para todo el grupo)\n• Total a pagar ahora: GHS 122\n• Restante después del servicio: GHS 280\n• Pago después: Efectivo a trabajador/tienda O a través de la aplicación (su elección)';

  @override
  String get docsGroupPaymentFlexibility => 'Múltiples opciones de pago';

  @override
  String get docsGroupPaymentFlexibilityContent => 'Para el 70% restante, tiene opciones:';

  @override
  String get docsGroupPaymentFlexibilityAllCash => 'Todo efectivo: Todos pagan en efectivo cuando se completa el servicio';

  @override
  String get docsGroupPaymentFlexibilitySplit => 'Pagos divididos: Algunos pagan en efectivo, otros pagan por aplicación';

  @override
  String get docsGroupPaymentFlexibilityMixed => 'Mezcla de efectivo y aplicación: Pague parte en efectivo, parte por aplicación';

  @override
  String get docsGroupPaymentFlexibilityIndividual => 'Pagos individuales de aplicación: Cada persona paga por aplicación';

  @override
  String get docsGroupPaymentFlexibilityTip => '¡Elija lo que mejor funcione para su grupo!';

  @override
  String get docsGroupImportant => 'El depósito y la tarifa de plataforma se calculan en la reserva de grupo TOTAL, no por persona. Usted paga una sola vez para todo el grupo.';

  @override
  String get docsCreateShopTitle => 'Crea tu Tienda';

  @override
  String get docsCreateShopSubtitle => 'Configura tu negocio';

  @override
  String get docsShopOverviewTitle => 'Primeros pasos con su tienda';

  @override
  String get docsShopOverviewSubtitle => 'Aprenda los conceptos básicos de crear su perfil comercial';

  @override
  String get docsWelcomeIntroTitle => 'Bienvenido a su panel de tienda';

  @override
  String get docsWelcomeIntroContent => 'Crear una tienda en Aura In toma solo unos minutos. Agregará su información comercial, establecerá sus servicios y horarios de trabajo, ¡y estará listo para aceptar reservas de clientes!';

  @override
  String get docsSetupStepsTitle => 'Lo que configurará';

  @override
  String get docsSetupStepsContent => 'Aquí está lo que hará al crear su tienda:';

  @override
  String get docsSetupStepsShopName => 'Agregue el nombre y logotipo de su tienda';

  @override
  String get docsSetupStepsDescription => 'Escriba una breve descripción de su negocio';

  @override
  String get docsSetupStepsType => 'Elija su tipo de tienda (salón, barbería, spa, etc.)';

  @override
  String get docsSetupStepsLocation => 'Establezca su ubicación y dirección de servicio';

  @override
  String get docsSetupStepsHours => 'Agregue sus horas de trabajo';

  @override
  String get docsSetupStepsServices => 'Cree servicios que ofrece con precios';

  @override
  String get docsSetupStepsContact => 'Agregue información de contacto';

  @override
  String get docsSetupStepsPhotos => 'Cargue fotos y documentos';

  @override
  String get docsSetupTip => 'Su trabajo se guarda automáticamente mientras completa el formulario. Puede regresar en cualquier momento para continuar editando o publicar cuando esté listo.';

  @override
  String get docsBasicInfoTitle => 'Información básica de la tienda';

  @override
  String get docsBasicInfoSubtitle => 'Dígales a los clientes quién es usted';

  @override
  String get docsLogoTitle => 'Agregue el logotipo de su tienda';

  @override
  String get docsLogoContent => 'Su logotipo es lo primero que ven los clientes. Debe representar claramente su negocio. Use una imagen cuadrada (por ejemplo, 500x500 píxeles) para obtener los mejores resultados.';

  @override
  String get docsShopNameTitle => 'Nombre de la tienda';

  @override
  String get docsShopNameContent => 'Ingrese el nombre de su negocio exactamente como desea que los clientes lo vean. Sea claro y profesional. Ejemplo: \"Estudio de Cabello de María\" o \"Barbería de la Ciudad\"';

  @override
  String get docsShopTypeTitle => 'Elija su tipo de tienda';

  @override
  String get docsShopTypeContent => 'Seleccione el tipo de negocio que ejecuta. Esto ayuda a los clientes a encontrarlo en la búsqueda. Los tipos disponibles incluyen:';

  @override
  String get docsShopTypeSalon => 'Salón de belleza - para cortes de cabello, coloración, estilismo';

  @override
  String get docsShopTypeBarber => 'Barbería - para cortes de cabello y aseo para hombres';

  @override
  String get docsShopTypeSpa => 'Spa - para masajes, faciales, servicios de bienestar';

  @override
  String get docsShopTypeBeauty => 'Servicios de belleza - maquillaje, uñas y otros tratamientos de belleza';

  @override
  String get docsShopTypeOther => 'Otros servicios - para negocios no enumerados arriba';

  @override
  String get docsDescriptionTitle => 'Descripción de la tienda';

  @override
  String get docsDescriptionContent => 'Escriba una breve descripción sobre su tienda (100-200 palabras). Dígales a los clientes qué lo hace especial. Ejemplo: \"Nos especializamos en el cuidado natural del cabello y el estilismo moderno para todo tipo de cabello. Ambiente familiar con estilistas profesionales.\"';

  @override
  String get docsTermsTitle => 'Términos y condiciones';

  @override
  String get docsTermsContent => 'Agregue cualquier regla importante que los clientes deben conocer. Ejemplos: política de cancelación, restricciones de edad, requisitos de depósito, código de vestimenta o restricciones de salud.';

  @override
  String get docsLocationTitle => 'Ubicación y horas';

  @override
  String get docsLocationSubtitle => 'Dónde pueden encontrarlo los clientes y cuándo trabaja';

  @override
  String get docsLocationIntroTitle => 'Establezca su ubicación';

  @override
  String get docsLocationIntroContent => 'Los clientes necesitan saber dónde encontrarlo. Puede:';

  @override
  String get docsLocationPin => 'Marque su ubicación en el mapa (arrastra el marcador)';

  @override
  String get docsLocationSearch => 'Busque su dirección en el cuadro de búsqueda';

  @override
  String get docsLocationManual => 'Ingrese su dirección de calle manualmente';

  @override
  String get docsLocationAccuracy => 'Asegúrese de que su ubicación sea precisa. Los clientes la usan para encontrarlo y calcular el tiempo de viaje.';

  @override
  String get docsWorkingHoursTitle => 'Establezca sus horas de trabajo';

  @override
  String get docsWorkingHoursContent => 'Los clientes solo pueden reservar cuando estén abiertos. Establezca sus horas para cada día de la semana.';

  @override
  String get docsHoursExampleTitle => 'Horario de ejemplo';

  @override
  String get docsHoursExampleContent => 'Lunes - Viernes: 9:00 AM a 6:00 PM\nSábado: 10:00 AM a 4:00 PM\nDomingo: Cerrado';

  @override
  String get docsHoursTip => 'Puede establecer diferentes horas para diferentes días, o marcar cualquier día como cerrado cuando no esté trabajando.';

  @override
  String get docsServicesTitle => 'Servicios y precios';

  @override
  String get docsServicesSubtitle => 'Dígales a los clientes qué ofrece y cuánto cuesta';

  @override
  String get docsServicesIntroTitle => 'Agregue sus servicios';

  @override
  String get docsServicesIntroContent => 'Cada servicio es algo que los clientes pueden reservar y pagar. Ejemplos: \"Corte de cabello\", \"Coloración capilar\", \"Masaje\", \"Tratamiento facial\".';

  @override
  String get docsServiceDetailsTitle => 'Para cada servicio, agregue:';

  @override
  String get docsServiceDetailsContent => 'Cuando crea un servicio, necesita proporcionar:';

  @override
  String get docsServiceName => 'Nombre del servicio - lo que está ofreciendo (p. ej., \"Corte de cabello\")';

  @override
  String get docsServiceDescription => 'Descripción - detalles breves sobre lo que se incluye';

  @override
  String get docsServicePrice => 'Precio - cuánto cuesta el servicio';

  @override
  String get docsServiceDuration => 'Duración - cuánto tiempo toma (p. ej., 30 minutos, 1 hora)';

  @override
  String get docsServiceCategory => 'Categoría - qué tipo de servicio es';

  @override
  String get docsPricingTipTitle => 'Consejo de fijación de precios';

  @override
  String get docsPricingTipContent => 'Sea claro con sus precios. Puede ofrecer diferentes niveles de servicio (p. ej., \"Corte básico\" vs \"Corte premium\") a diferentes precios.';

  @override
  String get docsDurationImportant => 'Establezca la duración con precisión. Los clientes reservan en función de este tiempo, y el personal necesita saber cuánto tiempo reservar.';

  @override
  String get docsTeamTitle => 'Administre su equipo';

  @override
  String get docsTeamSubtitle => 'Agregue miembros del personal y asígnelos a servicios';

  @override
  String get docsWorkersIntroTitle => 'Agregue su personal';

  @override
  String get docsWorkersIntroContent => 'Si tiene miembros del equipo trabajando en su tienda, puede agregarlos aquí. Esto le ayuda a administrar quién está disponible para las reservas.';

  @override
  String get docsAddWorkerTitle => 'Cómo agregar un miembro del personal';

  @override
  String get docsAddWorkerContent => 'Cuando agregue un trabajador, necesita:';

  @override
  String get docsFreelancerTitle => 'Conviértete en Freelancer';

  @override
  String get docsFreelancerSubtitle => 'Trabaja de forma independiente';

  @override
  String get docsFreelancerOverviewTitle => 'Primeros pasos como freelancer';

  @override
  String get docsFreelancerOverviewSubtitle => 'Aprenda a configurar su perfil y comience a aceptar clientes';

  @override
  String get docsFreelancerWelcomeTitle => 'Bienvenido al trabajo freelance';

  @override
  String get docsFreelancerWelcomeContent => 'Como freelancer en Aura In, ofrece servicios directamente a clientes en su área. A diferencia de una tienda tradicional, trabaja desde su propia ubicación y puede viajar para reunirse con clientes. Configure su perfil en solo unos minutos y comience a aceptar reservas.';

  @override
  String get docsFreelancerVsShopTitle => 'Freelancer vs Tienda: ¿Cuál es la diferencia?';

  @override
  String get docsFreelancerVsShopContent => 'Así es como funciona el trabajo freelance:';

  @override
  String get docsFreelancerIndependent => 'Trabaja de forma independiente - no se requiere tienda fija';

  @override
  String get docsFreelancerTravel => 'Puede viajar a clientes dentro de su radio elegido';

  @override
  String get docsFreelancerHours => 'Establece tus propias horas y disponibilidad';

  @override
  String get docsFreelancerManage => 'Administra tu propio horario y clientes';

  @override
  String get docsFreelancerBooking => 'Los clientes lo reservan directamente para los servicios';

  @override
  String get docsFreelancerRequirementsTitle => 'Lo que necesitarás';

  @override
  String get docsFreelancerRequirementsContent => 'Para comenzar como freelancer, necesita: su nombre, un tipo de profesión (peluquero, terapeuta de masaje, etc.), ubicación, radio de viaje, servicios y sus horas de trabajo. Una foto profesional ayuda a los clientes a confiar en usted.';

  @override
  String get docsProfileSetupTitle => 'Cree su perfil';

  @override
  String get docsProfileSetupSubtitle => 'Dígales a los clientes quién es';

  @override
  String get docsProfilePhotoTitle => 'Agregue su foto de perfil';

  @override
  String get docsProfilePhotoContent => 'Un retrato profesional genera confianza con los clientes. Use una foto clara y bien iluminada de usted mismo. Los clientes quieren saber con quién están reservando.';

  @override
  String get docsYourNameTitle => 'Tu nombre';

  @override
  String get docsYourNameContent => 'Ingrese su nombre completo exactamente como desea que los clientes lo vean. Sea profesional y claro.';

  @override
  String get docsProfessionTypeTitle => 'Elige tu profesión';

  @override
  String get docsProfessionTypeContent => 'Seleccione lo que hace. Ejemplos: Peluquero, Terapeuta de Masaje, Maquillador, Barbero, Esteticien o otros servicios especializados.';

  @override
  String get docsBioDescriptionTitle => 'Escriba su biografía';

  @override
  String get docsBioDescriptionContent => 'Escriba una breve descripción sobre usted y su experiencia (50-150 palabras). Dígales a los clientes qué lo hace especial. Ejemplo: \"Me especializo en el cuidado natural del cabello con 5 años de experiencia. Certificado en coloración y estilo.\"';

  @override
  String get docsTermsGuidelinesTitle => 'Agregue sus pautas';

  @override
  String get docsTermsGuidelinesContent => 'Comparta reglas o políticas importantes. Ejemplos: restricciones de edad, política de cancelación, requisitos de salud o instrucciones de preparación.';

  @override
  String get docsServiceAreaTitle => 'Establezca su área de servicio';

  @override
  String get docsServiceAreaSubtitle => 'Defina dónde trabaja';

  @override
  String get docsBaseLocationTitle => 'Establezca su ubicación base';

  @override
  String get docsBaseLocationContent => 'Aquí es donde normalmente trabaja. Los clientes dentro de su radio de viaje pueden reservarlo. Puede marcar en el mapa o buscar su dirección.';

  @override
  String get docsTravelRadiusTitle => 'Radio de viaje';

  @override
  String get docsTravelRadiusContent => '¿Qué tan lejos está dispuesto a viajar para reunirse con clientes? Establezca esto en kilómetros. Ejemplo: \"radio de 5 km\" significa que los clientes hasta 5 km de su ubicación pueden reservarlo.';

  @override
  String get docsMobileVsFixedTitle => '¿Móvil o ubicación fija?';

  @override
  String get docsMobileVsFixedContent => 'Elija si viaja a los clientes o se reúne con ellos en un lugar. Si es móvil, los clientes pueden solicitarlo en su hogar u oficina.';

  @override
  String get docsServiceAddressTip => 'Los clientes verán su radio de viaje al buscar. Sea preciso para que sepan si puede servir su área.';

  @override
  String get docsToolsSetupTitle => 'Liste sus herramientas y equipos';

  @override
  String get docsToolsSetupSubtitle => 'Muestre a los clientes lo que trae';

  @override
  String get docsToolsIntroTitle => '¿Qué son las herramientas?';

  @override
  String get docsToolsIntroContent => 'Las herramientas son el equipo o habilidades que tiene. Ayudan a los clientes a entender qué puede hacer y qué esperar.';

  @override
  String get docsToolExamplesTitle => 'Herramientas de ejemplo';

  @override
  String get docsToolExamplesContent => 'Para diferentes profesiones:';

  @override
  String get docsToolHairdresser => 'Peluquero: Secador, plancha alisadora, rizador, tijeras';

  @override
  String get docsToolMassage => 'Terapeuta de masaje: Mesa de masaje, piedras calientes, aceites aromaterápicos';

  @override
  String get docsToolMakeup => 'Maquillador: Pinceles de maquillaje, aerógrafo, luz LED';

  @override
  String get docsToolBarber => 'Barbero: Cortadoras eléctricas, navaja de afeitar, crema para peinar';

  @override
  String get docsToolSelectionTitle => 'Selección de herramientas';

  @override
  String get docsToolSelectionContent => 'Elija todas las herramientas y equipos que utiliza profesionalmente. Los clientes quieren saber que tiene el equipo adecuado para su servicio.';

  @override
  String get docsServicesSetupTitle => 'Servicios y precios';

  @override
  String get docsServicesSetupSubtitle => 'Dígales a los clientes qué ofrece';

  @override
  String get docsServiceBasicsTitle => 'Agregue sus servicios';

  @override
  String get docsServiceBasicsContent => 'Cada servicio es algo que los clientes pueden reservar. Ejemplos: \"Corte de cabello\", \"Masaje corporal completo\", \"Aplicación de maquillaje\".';

  @override
  String get docsServiceInfoTitle => 'Para cada servicio, agregue:';

  @override
  String get docsServiceInfoContent => 'Necesitas:';

  @override
  String get docsServiceInfoName => 'Nombre del servicio - lo que está ofreciendo';

  @override
  String get docsServiceInfoDescription => 'Descripción - qué incluye';

  @override
  String get docsServiceInfoPrice => 'Precio - cuánto cuesta';

  @override
  String get docsServiceInfoDuration => 'Duración - cuánto tiempo toma (30 min, 1 hora, etc.)';

  @override
  String get docsPricingStrategyTitle => 'Consejos de fijación de precios';

  @override
  String get docsPricingStrategyContent => 'Investigue lo que otros cobran por servicios similares en su área. Establezca precios competitivos pero justos para su nivel de experiencia.';

  @override
  String get docsDurationImportanceFreelancer => 'Establezca la duración con precisión. Así es como bloquea el tiempo para cada reserva. Los clientes dependen de este tiempo.';

  @override
  String get docsHoursSetupTitle => 'Establezca su disponibilidad';

  @override
  String get docsHoursSetupSubtitle => 'Cuándo está disponible para trabajar';

  @override
  String get docsHoursIntroTitle => 'Horas de trabajo';

  @override
  String get docsHoursIntroContent => 'Los clientes solo pueden reservar durante horas que marca como disponibles. Establezca sus horas para cada día de la semana.';

  @override
  String get docsFlexibleHoursTitle => '¿Flexible o estricto?';

  @override
  String get docsFlexibleHoursContent => 'Tú decides. Si desea horas consistentes, establézcalas. Si prefiere flexibilidad, puede ajustar diariamente según sea necesario.';

  @override
  String get docsBlockTimeTip => 'Cuando un cliente lo reserva, esa hora se bloquea en su calendario. Establezca las horas con prudencia para evitar conflictos.';

  @override
  String get docsContactCredentialsTitle => 'Información de contacto e identificación';

  @override
  String get docsContactCredentialsSubtitle => 'Ayude a los clientes a comunicarse con usted y genere confianza';

  @override
  String get docsCreateProductTitle => 'Vender productos en línea';

  @override
  String get docsCreateProductSubtitle => 'Liste artículos para la venta y llegue a clientes en su área';

  @override
  String get docsProductOverviewTitle => 'Primeros pasos en la venta de productos';

  @override
  String get docsProductOverviewSubtitle => 'Aprenda a listar y vender artículos';

  @override
  String get docsProductWelcomeTitle => 'Bienvenido a la venta de productos';

  @override
  String get docsProductWelcomeContent => 'Venda productos físicos directamente a clientes en su área. Desde artículos hechos a mano hasta bienes minoristas, puede llegar a clientes que buscan lo que ofrece.';

  @override
  String get docsPhoneRequirementTitle => 'Necesita un número de teléfono verificado';

  @override
  String get docsPhoneRequirementContent => 'Antes de poder comenzar a vender productos, debe verificar su número de teléfono. Esto es para la comunicación con clientes y para validar su identidad.';

  @override
  String get docsAddPhoneNumberTitle => 'Cómo agregar su número de teléfono';

  @override
  String get docsAddPhoneNumberContent => 'Vaya a la configuración de su perfil y agregue su número de teléfono. Recibirá un código de verificación por SMS para confirmar que es realmente su número. Esto toma solo un minuto.';

  @override
  String get docsWhyPhoneVerifiedTitle => '¿Por qué la verificación de teléfono?';

  @override
  String get docsWhyPhoneVerifiedContent => 'Un número de teléfono verificado genera confianza en los clientes y nos permite ponernos en contacto con usted si hay problemas. También ayuda a prevenir el fraude.';

  @override
  String get docsPhoneImportant => 'No puede listar productos hasta que tenga un número de teléfono verificado. Esto es obligatorio para todos los vendedores.';

  @override
  String get docsProductBasicsTitle => 'Información básica del producto';

  @override
  String get docsProductBasicsSubtitle => 'Lo que debe decirle a los clientes sobre su producto';

  @override
  String get docsProductNameTitle => 'Nombre del producto';

  @override
  String get docsProductNameContent => 'Ingrese el nombre de su producto claramente. Los clientes buscan por nombre de producto, así que sea específico. Ejemplo: \"Cartera de cuero hecha a mano - Marrón\" en lugar de solo \"Cartera\".';

  @override
  String get docsProductDescriptionTitle => 'Descripción del producto';

  @override
  String get docsProductDescriptionContent => 'Escriba una descripción detallada. Dígales a los clientes qué es, de qué está hecho, cómo usarlo y por qué es bueno. Sea honesto sobre el estado (nuevo, usado, reacondicionado).';

  @override
  String get docsCategorySelectionTitle => 'Elija una categoría';

  @override
  String get docsCategorySelectionContent => 'Seleccione la categoría correcta. Los clientes navegan por categoría para encontrar artículos, así que la precisión es importante. Elija la categoría más específica disponible.';

  @override
  String get docsProductConditionTitle => 'Condición del producto';

  @override
  String get docsProductConditionContent => 'Sea claro sobre la condición: Nuevo (nunca usado), Como nuevo (usado una vez), Bueno (desgaste ligero), Regular (desgaste visible) o Tal cual. La honestidad genera confianza.';

  @override
  String get docsPricingStockTitle => 'Precio y disponibilidad';

  @override
  String get docsPricingStockSubtitle => 'Establezca su precio y gestione el inventario';

  @override
  String get docsPricingTitle => 'Establezca su precio';

  @override
  String get docsPricingContent => 'Establezca un precio justo basado en condición, valor de mercado y demanda local. Los clientes pueden ver artículos similares, por lo que los precios competitivos ayudan.';

  @override
  String get docsCurrencyTitle => 'Moneda';

  @override
  String get docsCurrencyContent => 'Los precios se muestran en la moneda de su tienda. Asegúrese de que la moneda de su tienda esté configurada correctamente antes de agregar productos.';

  @override
  String get docsStockQuantityTitle => 'Cantidad de inventario';

  @override
  String get docsStockQuantityContent => 'Ingrese cuántos artículos tiene. Cuando se agota el stock, el producto se muestra como no disponible. Actualice esto a medida que venda artículos.';

  @override
  String get docsStockTip => 'Mantenga el stock preciso. Los clientes se frustran si piden algo que no está en stock. Actualice regularmente a medida que venda.';

  @override
  String get docsProductPhotosTitle => 'Fotos del producto';

  @override
  String get docsProductPhotosSubtitle => 'Muéstrale a los clientes lo que están comprando';

  @override
  String get docsPhotosImportanceTitle => 'Las fotos son lo más importante';

  @override
  String get docsPhotosImportanceContent => 'Las buenas fotos son críticas. Los clientes deciden si comprar en función de las fotos. Fotos deficientes = menos ventas.';

  @override
  String get docsWhatPhotosTitle => 'Qué fotografiar';

  @override
  String get docsWhatPhotosContent => 'Toma fotos que muestren el producto real:';

  @override
  String get docsPhotoFull => 'Producto completo desde múltiples ángulos';

  @override
  String get docsPhotoCloseups => 'Primer plano de detalles y calidad';

  @override
  String get docsPhotoCondition => 'Fotos que muestren la condición (si está usado)';

  @override
  String get docsPhotoScale => 'Fotos junto a algo para escala (como una moneda o mano)';

  @override
  String get docsPhotoDamage => 'Fotos de daño o desgaste (la honestidad genera confianza)';

  @override
  String get docsPhotoTipsTitle => 'Consejos de calidad de foto';

  @override
  String get docsPhotoTipsContent => 'Use luz natural. Toma fotos con fondo limpio. Muestra colores con precisión. No uses filtros que cambien la apariencia del producto.';

  @override
  String get docsPhotoCountTitle => '¿Cuántas fotos?';

  @override
  String get docsPhotoCountContent => 'Cargue al menos 3 fotos claras. Más fotos ayudan a los clientes a entender mejor el producto. Límite a 10 fotos por producto.';

  @override
  String get docsToolsTitle => 'Herramientas comerciales';

  @override
  String get docsToolsSubtitle => 'Características poderosas para automatizar, promover y administrar su negocio';

  @override
  String get docsToolsOverviewTitle => 'Descripción general de herramientas';

  @override
  String get docsToolsOverviewSubtitle => 'Lo que hace cada herramienta y cómo usarla';

  @override
  String get docsToolsWelcomeTitle => 'Bienvenido a herramientas empresariales';

  @override
  String get docsToolsWelcomeContent => 'La pestaña Herramientas tiene 8 características poderosas para ayudarlo a automatizar, promover y administrar su negocio de manera más efectiva. Cada herramienta resuelve un problema comercial específico.';

  @override
  String get docsToolsListTitle => 'Herramientas disponibles';

  @override
  String get docsToolsListContent => 'Tiene acceso a estas 8 herramientas:';

  @override
  String get docsToolsReminders => 'Recordatorios automatizados - Enviar recordatorios a clientes';

  @override
  String get docsToolsPromotions => 'Gestor de promociones - Crear y administrar descuentos';

  @override
  String get docsToolsExport => 'Exportar informes - Descargar sus datos comerciales';

  @override
  String get docsToolsPayment => 'Configuración de pagos - Configure cómo recibe pagos';

  @override
  String get docsToolsHours => 'Horarios comerciales - Establezca su horario de trabajo';

  @override
  String get docsToolsServices => 'Gestión de servicios - Agregue y edite sus servicios';

  @override
  String get docsToolsLoyalty => 'Programa de fidelidad - Recompense clientes leales';

  @override
  String get docsToolsBroadcasts => 'Transmisiones - Enviar mensajes a sus clientes';

  @override
  String get docsRemindersTitle => '1. Recordatorios automatizados';

  @override
  String get docsRemindersSubtitle => 'Enviar recordatorios automáticos a los clientes';

  @override
  String get docsReminderPurposeTitle => 'Qué hace';

  @override
  String get docsReminderPurposeContent => 'Enviar automáticamente mensajes de recordatorio a los clientes antes de sus reservas. Reduce las ausencias y mantiene informados a los clientes.';

  @override
  String get docsReminderBenefitsTitle => 'Beneficios';

  @override
  String get docsReminderBenefitsContent => 'Los recordatorios automatizados lo ayudan a:';

  @override
  String get docsReminderBenefitNoShow => 'Reducir ausencias - es menos probable que los clientes olviden';

  @override
  String get docsReminderBenefitExperience => 'Mejorar la experiencia del cliente - saben cuándo llegar';

  @override
  String get docsReminderBenefitTime => 'Ahorrar tiempo - sin necesidad de llamar o enviar mensajes manualmente';

  @override
  String get docsReminderBenefitReliability => 'Aumentar confiabilidad - recordatorios salven automáticamente';

  @override
  String get docsReminderSetupTitle => 'Cómo configurarlo';

  @override
  String get docsReminderSetupContent => 'Haga clic en \"Configurar recordatorios automatizados\" para establecer el tiempo: envía recordatorios 24 horas antes, 2 horas antes o en la mañana de la cita.';

  @override
  String get docsReminderImpact => 'Las tiendas que utilizan recordatorios automatizados ven 20-30% menos ausencias. Esto afecta directamente sus ingresos.';

  @override
  String get docsPromosTitle => '2. Gestor de promociones';

  @override
  String get docsPromosSubtitle => 'Crear ofertas especiales y descuentos';

  @override
  String get docsPromosPurposeTitle => 'Qué hace';

  @override
  String get docsPromosPurposeContent => 'Crear promociones y descuentos por tiempo limitado. Ofrecer porcentaje de descuento, cantidad fija o complementos gratuitos para atraer más clientes.';

  @override
  String get docsPromosExamplesTitle => 'Ideas de promoción';

  @override
  String get docsPromosExamplesContent => 'Puede crear promociones como:';

  @override
  String get docsPromosExample1 => '20% de descuento en cortes de cabello los lunes';

  @override
  String get docsPromosExample2 => 'Aceite de masaje gratis con cualquier reserva de masaje';

  @override
  String get docsPromosExample3 => '50 de descuento en un paquete de servicio completo';

  @override
  String get docsPromosExample4 => 'Cliente por primera vez: 30% de descuento';

  @override
  String get docsPromosExample5 => 'Bonificación de lealtad: 5to servicio a mitad de precio';

  @override
  String get docsPromosStrategyTitle => 'Estrategia de promoción';

  @override
  String get docsPromosStrategyContent => 'Use promociones durante períodos lentos para impulsar reservas. Siga qué promociones funcionan mejor a través de su análisis.';

  @override
  String get docsExportTitle => '3. Exportar informes';

  @override
  String get docsExportSubtitle => 'Descargar sus datos para análisis';

  @override
  String get docsExportPurposeTitle => 'Qué hace';

  @override
  String get docsExportPurposeContent => 'Descargar informes detallados de sus datos comerciales en formato de hoja de cálculo. Analice reservas, ingresos, clientes y más.';

  @override
  String get docsExportTypesTitle => 'Informes disponibles';

  @override
  String get docsExportTypesContent => 'Puede exportar:';

  @override
  String get docsExportBookings => 'Informes de reserva - todas las reservas con detalles';

  @override
  String get docsExportRevenue => 'Informes de ingresos - ganancias por rango de fechas';

  @override
  String get docsExportCustomers => 'Informes de clientes - su lista de clientes';

  @override
  String get docsExportServices => 'Informes de servicio - rendimiento por servicio';

  @override
  String get docsExportWorkers => 'Informes de trabajadores - métricas de desempeño del personal';

  @override
  String get docsExportUsesTitle => '¿Por qué exportar datos?';

  @override
  String get docsExportUsesContent => 'Use datos exportados en Excel para análisis personalizado, mantenimiento de registros, propósitos fiscales o para compartir con contador.';

  @override
  String get docsTimeSlotsTitle => 'Espacios de tiempo explicados';

  @override
  String get docsTimeSlotsSubtitle => 'Comprenda cómo funcionan los tiempos de reserva';

  @override
  String get docsTimeSlotsOverviewTitle => '¿Cuáles son las ranuras horarias?';

  @override
  String get docsTimeSlotsOverviewSubtitle => 'Aprenda cómo funciona el sistema de programación';

  @override
  String get docsTimeSlotsWelcomeTitle => 'Bienvenido a espacios de tiempo';

  @override
  String get docsTimeSlotsWelcomeContent => 'Los espacios de tiempo son los horarios disponibles cuando los clientes pueden reservar sus servicios. Comprender cómo funcionan lo ayuda a administrar su cronograma de manera eficiente.';

  @override
  String get docsTimeSlotsBasicsTitle => 'Conceptos básicos de ranura horaria';

  @override
  String get docsTimeSlotsBasicsContent => 'Así es como funcionan los espacios de tiempo:';

  @override
  String get docsTimeSlotsPoint1 => 'Cada servicio tiene una duración (cuánto tiempo tarda)';

  @override
  String get docsTimeSlotsPoint2 => 'Establecer sus horas disponibles (cuándo trabaja)';

  @override
  String get docsTimeSlotsPoint3 => 'El sistema crea espacios de tiempo basados en la duración del servicio';

  @override
  String get docsTimeSlotsPoint4 => 'Los clientes solo pueden reservar espacios disponibles';

  @override
  String get docsTimeSlotsExampleTitle => 'Ejemplo: Crear espacios de tiempo';

  @override
  String get docsTimeSlotsExampleContent => 'Si ofrece un corte de cabello de 30 minutos y trabaja de 9 AM a 5 PM:\n• 9:00 AM - 9:30 AM (Espacio 1)\n• 9:30 AM - 10:00 AM (Espacio 2)\n• 10:00 AM - 10:30 AM (Espacio 3)\n...y así durante todo el día';

  @override
  String get docsTimeSlotsOverlapTitle => '¿Qué pasa si se superponen servicios?';

  @override
  String get docsTimeSlotsOverlapContent => 'Si tiene varios empleados, cada persona tiene su propio horario. Si trabaja solo, solo un cliente puede reservar a la vez — el sistema bloquea automáticamente tiempos conflictivos.';

  @override
  String get docsTimeSlotsGapTitle => 'Establecer espacios entre servicios';

  @override
  String get docsTimeSlotsGapContent => 'Puede establecer tiempo de amortiguamiento entre reservas. Ejemplo: 15 minutos de espacio después de cada corte de cabello para limpiar. Esto reduce los espacios disponibles pero te da espacio para respirar.';

  @override
  String get docsTimeSlotsGroupTitle => 'Reservas grupales y espacios de tiempo';

  @override
  String get docsTimeSlotsGroupContent => 'Para reservas de grupo, el sistema encuentra horas que funcionan para TODAS las personas del grupo. Esto hace más difícil encontrar espacios disponibles, pero garantiza que todos sean servidos juntos.';

  @override
  String get docsTimeSlotsBlockingTitle => 'Tiempo de bloqueo';

  @override
  String get docsTimeSlotsBlockingContent => 'Puede bloquear manualmente el tiempo para almuerzo, descansos o citas personales. El tiempo bloqueado no se mostrará disponible a los clientes.';

  @override
  String get docsTimeSlotsUtilizationTitle => 'Maximizar sus espacios de tiempo';

  @override
  String get docsTimeSlotsUtilizationContent => 'Consejos para usar sus espacios de manera eficiente:\n• Haga coincidir la duración del servicio con la realidad (no subestime)\n• Establezca espacios realistas entre servicios\n• Use tiempo amortiguador estratégicamente\n• Revise y ajuste según comentarios del cliente';

  @override
  String get docsGettingStartedWhatIsNanoembryo_title => 'What is Aura In?';

  @override
  String get docsGettingStartedWhatIsNanoembryo_subtitle => 'Understand the platform';

  @override
  String get docsGettingStartedWhatIsNanoembryo_welcomeIntroTitle => 'Welcome to Aura In';

  @override
  String get docsGettingStartedWhatIsNanoembryo_welcomeIntroContent => 'Aura In is a mobile marketplace connecting service professionals with customers. Whether you offer haircuts, massages, freelance services, or sell products, this platform helps you grow your business.';

  @override
  String get docsGettingStartedWhatIsNanoembryo_whoUsesAppTitle => 'Who Uses Aura In?';

  @override
  String get docsGettingStartedWhatIsNanoembryo_whoUsesAppContent => 'Two types of users power the platform:';

  @override
  String get docsGettingStartedWhatIsNanoembryo_whoUsesAppBullet1 => 'Service Providers - Salons, spas, barbers, freelancers who offer services';

  @override
  String get docsGettingStartedWhatIsNanoembryo_whoUsesAppBullet2 => 'Customers - People searching for and booking services in their area';

  @override
  String get docsGettingStartedWhatIsNanoembryo_whoUsesAppBullet3 => 'Product Sellers - Shops selling retail products or handmade items';

  @override
  String get docsGettingStartedWhatIsNanoembryo_howItWorksTitle => 'How It Works';

  @override
  String get docsGettingStartedWhatIsNanoembryo_howItWorksContent => 'Service providers create a profile, list their services with pricing, and accept bookings from customers. Customers search by location, browse services, and book appointments. Everything is managed through the app.';

  @override
  String get docsGettingStartedThreeUserTypes_title => 'Three Ways to Use Aura In';

  @override
  String get docsGettingStartedThreeUserTypes_subtitle => 'Choose your role';

  @override
  String get docsGettingStartedThreeUserTypes_optionCustomerTitle => 'Option 1: Browse & Book Services (Customer)';

  @override
  String get docsGettingStartedThreeUserTypes_optionCustomerContent => 'Search for salons, massage therapists, barbers, or freelancers near you. View their services, pricing, and availability. Book appointments directly through the app and pay securely.';

  @override
  String get docsGettingStartedThreeUserTypes_guestBookingTitle => 'Guest Booking (No App Download Needed)';

  @override
  String get docsGettingStartedThreeUserTypes_guestBookingContent => 'Don\'t want to download the app? Service providers can share a booking link - you can book and pay directly through that link without creating an account. Your booking details and receipt will be sent to your WhatsApp.';

  @override
  String get docsGettingStartedThreeUserTypes_optionProviderTitle => 'Option 2: Offer Services (Shop Owner or Freelancer)';

  @override
  String get docsGettingStartedThreeUserTypes_optionProviderContent => 'Create a shop or freelancer profile, list your services with pricing and duration, set your working hours, and manage bookings. Get paid for every service booked.';

  @override
  String get docsGettingStartedThreeUserTypes_optionSellerTitle => 'Option 3: Sell Products (Product Seller)';

  @override
  String get docsGettingStartedThreeUserTypes_optionSellerContent => 'If you make handmade items or sell products, you can list them for sale. Customers browse and purchase directly from your shop.';

  @override
  String get docsGettingStartedKeyFeatures_title => 'Platform Features';

  @override
  String get docsGettingStartedKeyFeatures_subtitle => 'What you can do';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewTitle => 'Core Platform Features';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewContent => 'Aura In includes everything you need to run a service business:';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet1 => 'Booking System - Customers book services, you manage calendar';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet2 => 'Secure Payments - Accept payments via Paystack or Stripe';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet3 => 'Real-time Chat - Communicate with customers before/after bookings';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet4 => 'Location-based Search - Customers find you by location using Google Maps';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet5 => 'Business Dashboard - Analytics, revenue tracking, client management';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet6 => 'Team Management - Add staff members and assign them to services';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet7 => 'Automated Reminders - Send appointment reminders to reduce no-shows';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet8 => 'Promotions & Loyalty - Run discounts and reward repeat customers';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet9 => 'Product Selling - List items for sale if you offer products';

  @override
  String get docsGettingStartedKeyFeatures_featuresOverviewBullet10 => 'Reviews & Ratings - Build trust through customer feedback';

  @override
  String get docsGettingStartedForCustomers_title => 'For Customers';

  @override
  String get docsGettingStartedForCustomers_subtitle => 'How to find and book services';

  @override
  String get docsGettingStartedForCustomers_customerStartTitle => 'Getting Started as a Customer';

  @override
  String get docsGettingStartedForCustomers_customerStartContent => 'Create an account, set your location, and start searching for services. You can view service providers near you, read reviews, check pricing, and book appointments.';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesTitle => 'Customer Capabilities';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesContent => 'As a customer, you can:';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet1 => 'Search services by location (using Google Maps)';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet2 => 'Filter by type of service, price range, or ratings';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet3 => 'View detailed service provider profiles and reviews';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet4 => 'Book appointments and select preferred staff member';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet5 => 'Chat with providers before booking';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet6 => 'Pay securely through the app';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet7 => 'Receive appointment reminders';

  @override
  String get docsGettingStartedForCustomers_customerFeaturesBullet8 => 'Rate and review services after completion';

  @override
  String get docsGettingStartedFaq1Q => 'What is Aura In?';

  @override
  String get docsGettingStartedFaq1A => 'Aura In is a mobile marketplace for service-based businesses. Customers find and book services (haircuts, massages, etc.), service providers manage bookings and revenue, and product sellers list items for sale.';

  @override
  String get docsGettingStartedFaq2Q => 'Do I need to pay to use the app?';

  @override
  String get docsGettingStartedFaq2A => 'The app is free to download and use. Service providers only pay a small commission when customers pay for services. Payment processors (Paystack/Stripe) take a fee.';

  @override
  String get docsGettingStartedFaq3Q => 'What is the difference between Shop Owner and Freelancer?';

  @override
  String get docsGettingStartedFaq3A => 'Shop owners have a fixed location with a team of workers. Freelancers work independently and can travel to clients. Choose based on your business model.';

  @override
  String get docsGettingStartedFaq4Q => 'How do I get paid?';

  @override
  String get docsGettingStartedFaq4A => 'When customers pay for services, money goes to your wallet. You can withdraw to your bank account using Paystack (Africa) or Stripe (Global).';

  @override
  String get docsGettingStartedFaq5Q => 'Is my payment information secure?';

  @override
  String get docsGettingStartedFaq5A => 'Yes. Aura In uses Paystack and Stripe, industry-leading payment processors with bank-level security. We never see your payment details.';

  @override
  String get docsCreateShopShopOverview_title => 'Getting Started with Your Shop';

  @override
  String get docsCreateShopShopOverview_subtitle => 'Learn the basics of creating your business profile';

  @override
  String get docsCreateShopShopOverview_welcomeIntroTitle => 'Welcome to Your Shop Dashboard';

  @override
  String get docsCreateShopShopOverview_welcomeIntroContent => 'Creating a shop on Aura In takes just a few minutes. You\'ll add your business information, set your services and working hours, and you\'re ready to accept bookings from customers.';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewTitle => 'What You\'ll Set Up';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewContent => 'Here\'s what you\'ll do when creating your shop:';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet1 => 'Add your shop name and logo';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet2 => 'Write a brief description of your business';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet3 => 'Choose your shop type (salon, barber, spa, etc.)';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet4 => 'Set your location and service address';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet5 => 'Add your working hours';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet6 => 'Create services you offer with pricing';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet7 => 'Add contact information';

  @override
  String get docsCreateShopShopOverview_setupStepsOverviewBullet8 => 'Upload photos and documents';

  @override
  String get docsCreateShopShopOverview_saveProgressTipContent => 'Your work is saved automatically as you fill in the form. You can come back anytime to continue editing or publish when ready.';

  @override
  String get docsCreateShopBasicInfo_title => 'Basic Shop Information';

  @override
  String get docsCreateShopBasicInfo_subtitle => 'Tell customers who you are';

  @override
  String get docsCreateShopBasicInfo_logoSectionTitle => 'Add Your Shop Logo';

  @override
  String get docsCreateShopBasicInfo_logoSectionContent => 'Your logo is the first thing customers see. It should clearly represent your business. Use a square image (e.g., 500x500 pixels) for best results.';

  @override
  String get docsCreateShopBasicInfo_shopNameTitle => 'Shop Name';

  @override
  String get docsCreateShopBasicInfo_shopNameContent => 'Enter your business name exactly as you want customers to see it. Be clear and professional. Example: \"Marie\'s Hair Studio\" or \"City Barbershop\"';

  @override
  String get docsCreateShopBasicInfo_shopTypeTitle => 'Choose Your Shop Type';

  @override
  String get docsCreateShopBasicInfo_shopTypeContent => 'Select the type of business you run. This helps customers find you in search. Available types include:';

  @override
  String get docsCreateShopBasicInfo_shopTypeBullet1 => 'Hair Salon - for haircuts, coloring, styling';

  @override
  String get docsCreateShopBasicInfo_shopTypeBullet2 => 'Barber Shop - for men\'s haircuts and grooming';

  @override
  String get docsCreateShopBasicInfo_shopTypeBullet3 => 'Spa - for massages, facials, wellness services';

  @override
  String get docsCreateShopBasicInfo_shopTypeBullet4 => 'Beauty Services - makeup, nails, and other beauty treatments';

  @override
  String get docsCreateShopBasicInfo_shopTypeBullet5 => 'Other Services - for businesses not listed above';

  @override
  String get docsCreateShopBasicInfo_descriptionTitle => 'Shop Description';

  @override
  String get docsCreateShopBasicInfo_descriptionContent => 'Write a short description about your shop (100-200 words). Tell customers what makes you special. Example: \"We specialize in natural hair care and modern styling for all hair types. Family-friendly environment with professional stylists.\"';

  @override
  String get docsCreateShopBasicInfo_termsInfoTitle => 'Terms & Conditions';

  @override
  String get docsCreateShopBasicInfo_termsInfoContent => 'Add any important rules customers should know. Examples: cancellation policy, age restrictions, deposit requirements, dress code, or health restrictions.';

  @override
  String get docsCreateShopLocationSetup_title => 'Location & Hours';

  @override
  String get docsCreateShopLocationSetup_subtitle => 'Where customers can find you and when you work';

  @override
  String get docsCreateShopLocationSetup_locationIntroTitle => 'Set Your Location';

  @override
  String get docsCreateShopLocationSetup_locationIntroContent => 'Customers need to know where to find you. You can either:';

  @override
  String get docsCreateShopLocationSetup_locationIntroBullet1 => 'Pin your location on the map (drag the marker)';

  @override
  String get docsCreateShopLocationSetup_locationIntroBullet2 => 'Search for your address in the search box';

  @override
  String get docsCreateShopLocationSetup_locationIntroBullet3 => 'Enter your street address manually';

  @override
  String get docsCreateShopLocationSetup_locationAccuracyContent => 'Make sure your location is accurate. Customers use it to find you and calculate travel time.';

  @override
  String get docsCreateShopLocationSetup_workingHoursTitle => 'Set Your Working Hours';

  @override
  String get docsCreateShopLocationSetup_workingHoursContent => 'Customers can only book times when you\'re open. Set your hours for each day of the week.';

  @override
  String get docsCreateShopLocationSetup_hoursExampleTitle => 'Example Hours';

  @override
  String get docsCreateShopLocationSetup_hoursExampleContent => 'Monday - Friday: 9:00 AM to 6:00 PM\nSaturday: 9:00 AM to 5:00 PM\nSunday: Closed';

  @override
  String get docsCreateShopLocationSetup_hoursTipContent => 'You can set different hours for different days, or mark any day as closed when you\'re not working.';

  @override
  String get docsCreateShopServicesSetup_title => 'Services & Pricing';

  @override
  String get docsCreateShopServicesSetup_subtitle => 'Tell customers what you offer and how much it costs';

  @override
  String get docsCreateShopServicesSetup_servicesIntroTitle => 'Add Your Services';

  @override
  String get docsCreateShopServicesSetup_servicesIntroContent => 'Each service is something customers can book and pay for. Examples: \"Haircut\", \"Hair Color\", \"Massage\", \"Facial Treatment\".';

  @override
  String get docsCreateShopServicesSetup_serviceDetailsTitle => 'For Each Service, Add:';

  @override
  String get docsCreateShopServicesSetup_serviceDetailsContent => 'When you create a service, you need to provide:';

  @override
  String get docsCreateShopServicesSetup_serviceDetailsBullet1 => 'Service name - what you\'re offering (e.g., \"Haircut\")';

  @override
  String get docsCreateShopServicesSetup_serviceDetailsBullet2 => 'Description - brief details about what\'s included';

  @override
  String get docsCreateShopServicesSetup_serviceDetailsBullet3 => 'Price - how much the service costs';

  @override
  String get docsCreateShopServicesSetup_serviceDetailsBullet4 => 'Duration - how long it takes (e.g., 30 minutes, 1 hour)';

  @override
  String get docsCreateShopServicesSetup_serviceDetailsBullet5 => 'Category - what type of service it is';

  @override
  String get docsCreateShopServicesSetup_pricingTipTitle => 'Pricing Tip';

  @override
  String get docsCreateShopServicesSetup_pricingTipContent => 'Be clear with your prices. You can offer different service tiers (e.g., \"Basic Haircut\" vs \"Premium Haircut\") at different prices.';

  @override
  String get docsCreateShopServicesSetup_durationImportantContent => 'Set the duration accurately. Customers book based on this time, and staff need to know how long to reserve.';

  @override
  String get docsCreateShopFaq1Q => 'How long does it take to create a shop?';

  @override
  String get docsCreateShopFaq1A => 'Most businesses can set up a shop in 5-15 minutes. You just need your business name, location, at least one service, and working hours.';

  @override
  String get docsCreateShopFaq2Q => 'What do I need to start?';

  @override
  String get docsCreateShopFaq2A => 'You need: your business name, location address, shop type, at least one service with pricing, and your working hours. A logo and photos are optional but recommended.';

  @override
  String get docsCreateShopFaq3Q => 'Can I change things after publishing?';

  @override
  String get docsCreateShopFaq3A => 'Yes! You can edit everything after your shop is live. Go to \"My Shops\", click on your shop, and click \"Edit\". All changes take effect immediately.';

  @override
  String get docsCreateShopFaq4Q => 'Do I need team members to start?';

  @override
  String get docsCreateShopFaq4A => 'No. If you\'re a solo business, you can start immediately. You can add team members anytime from your shop settings.';

  @override
  String get docsFreelancerFreelancerOverview_title => 'Getting Started as a Freelancer';

  @override
  String get docsFreelancerFreelancerOverview_subtitle => 'Learn how to set up your profile and start taking clients';

  @override
  String get docsFreelancerFreelancerOverview_freelancerWelcomeTitle => 'Welcome to Freelancing';

  @override
  String get docsFreelancerFreelancerOverview_freelancerWelcomeContent => 'As a freelancer on Aura In, you offer services directly to customers in your area. Unlike a traditional shop, you work from your own location and can travel to meet clients. Set up your profile in just a few minutes and start accepting bookings.';

  @override
  String get docsFreelancerFreelancerOverview_freelancerVsShopTitle => 'Freelancer vs Shop: What\'s the Difference?';

  @override
  String get docsFreelancerFreelancerOverview_freelancerVsShopContent => 'Here\'s how freelancing works:';

  @override
  String get docsFreelancerFreelancerOverview_freelancerVsShopBullet1 => 'You work independently - no fixed storefront required';

  @override
  String get docsFreelancerFreelancerOverview_freelancerVsShopBullet2 => 'You can travel to clients within your chosen radius';

  @override
  String get docsFreelancerFreelancerOverview_freelancerVsShopBullet3 => 'You set your own hours and availability';

  @override
  String get docsFreelancerFreelancerOverview_freelancerVsShopBullet4 => 'You manage your own schedule and clients';

  @override
  String get docsFreelancerFreelancerOverview_freelancerVsShopBullet5 => 'Customers book you directly for services';

  @override
  String get docsFreelancerFreelancerOverview_freelancerRequirementsTitle => 'What You\'ll Need';

  @override
  String get docsFreelancerFreelancerOverview_freelancerRequirementsContent => 'To start as a freelancer, you need: your name, a profession type (hairdresser, massage therapist, etc.), location, travel radius, services, and your working hours. A professional photo helps customers trust you.';

  @override
  String get docsFreelancerProfileSetup_title => 'Create Your Profile';

  @override
  String get docsFreelancerProfileSetup_subtitle => 'Tell customers who you are';

  @override
  String get docsFreelancerProfileSetup_profilePhotoTitle => 'Add Your Profile Photo';

  @override
  String get docsFreelancerProfileSetup_profilePhotoContent => 'A professional headshot or portrait builds trust with customers. Use a clear, well-lit photo of yourself. Customers want to know who they\'re booking with.';

  @override
  String get docsFreelancerProfileSetup_yourNameTitle => 'Your Name';

  @override
  String get docsFreelancerProfileSetup_yourNameContent => 'Enter your full name exactly as you want customers to see it. Be professional and clear.';

  @override
  String get docsFreelancerProfileSetup_professionTypeTitle => 'Choose Your Profession';

  @override
  String get docsFreelancerProfileSetup_professionTypeContent => 'Select what you do. Examples: Hairdresser, Massage Therapist, Makeup Artist, Barber, Esthetician, or other specialized services.';

  @override
  String get docsFreelancerProfileSetup_bioDescriptionTitle => 'Write Your Bio';

  @override
  String get docsFreelancerProfileSetup_bioDescriptionContent => 'Write a short description about yourself and your experience (50-150 words). Tell customers what makes you unique. Example: \"I specialize in natural hair care with 5 years of experience. Certified in color and styling.\"';

  @override
  String get docsFreelancerProfileSetup_termsGuidelinesTitle => 'Add Your Guidelines';

  @override
  String get docsFreelancerProfileSetup_termsGuidelinesContent => 'Share any important rules or policies. Examples: age restrictions, cancellation policy, health requirements, or preparation instructions.';

  @override
  String get docsFreelancerServiceArea_title => 'Set Your Service Area';

  @override
  String get docsFreelancerServiceArea_subtitle => 'Define where you work';

  @override
  String get docsFreelancerServiceArea_baseLocationTitle => 'Set Your Base Location';

  @override
  String get docsFreelancerServiceArea_baseLocationContent => 'This is where you normally work from. Customers within your travel radius can book you. You can either pin on the map or search for your address.';

  @override
  String get docsFreelancerServiceArea_travelRadiusTitle => 'Travel Radius';

  @override
  String get docsFreelancerServiceArea_travelRadiusContent => 'How far are you willing to travel to meet clients? Set this in kilometers. Example: \"5 km radius\" means clients up to 5 km from your location can book you.';

  @override
  String get docsFreelancerServiceArea_mobileVsFixedTitle => 'Mobile or Fixed Location?';

  @override
  String get docsFreelancerServiceArea_mobileVsFixedContent => 'Choose whether you travel to clients or meet them at one location. If you\'re mobile, customers can request you at their home or office.';

  @override
  String get docsFreelancerServiceArea_serviceAddressTipContent => 'Customers will see your travel radius when searching. Be accurate so they know if you can serve their area.';

  @override
  String get docsFreelancerFaq1Q => 'What\'s the difference between a freelancer and a shop owner?';

  @override
  String get docsFreelancerFaq1A => 'A freelancer works independently, often traveling to clients. A shop owner has a fixed location. Freelancers are more flexible, shops are more established.';

  @override
  String get docsFreelancerFaq2Q => 'How do customers find me?';

  @override
  String get docsFreelancerFaq2A => 'Your profile appears in customer searches based on your location, profession, and services. A good photo and portfolio help you get found more.';

  @override
  String get docsFreelancerFaq3Q => 'Can I work for multiple platforms?';

  @override
  String get docsFreelancerFaq3A => 'Yes! You can set up profiles on multiple platforms. Just make sure your availability matches across all platforms.';

  @override
  String get docsFreelancerFaq4Q => 'How do payments work?';

  @override
  String get docsFreelancerFaq4A => 'Customers pay through the app. You receive payment to your account after the service is completed.';

  @override
  String get docsFreelancerFaq5Q => 'What if I need to cancel a booking?';

  @override
  String get docsFreelancerFaq5A => 'You can cancel before the booking time. Contact support if you need to reschedule. Be fair to customers - frequent cancellations hurt your rating.';
}
