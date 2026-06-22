// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Nano Embryo';

  @override
  String get appDescription => 'Seu aplicativo inovador';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonLogin => 'Entrar';

  @override
  String get commonLogout => 'Sair';

  @override
  String get commonDone => 'Concluído';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String get commonAccept => 'Aceitar';

  @override
  String get commonReject => 'Rejeitar';

  @override
  String get introGetStarted => 'Começar';

  @override
  String get actionsBlock => 'Bloquear usuário';

  @override
  String get actionsReport => 'Denunciar usuário';

  @override
  String get actionsSend => 'Enviar para o chat';

  @override
  String get actionsShare => 'Compartilhar';

  @override
  String get actionsCopy => 'Copiar link';

  @override
  String get appInfoVersion => 'Versão';

  @override
  String get appInfoReleased => 'Lançado';

  @override
  String get appInfoPackageName => 'Nome do Pacote';

  @override
  String get appInfoDeveloper => 'Nome do Desenvolvedor';

  @override
  String get appInfoSupportEmail => 'Email de Suporte';

  @override
  String get appInfoTechnicalDetails => 'Detalhes Técnicos';

  @override
  String get appInfoBundleID => 'ID do Pacote';

  @override
  String get appInfoBuildVersion => 'Versão da Compilação';

  @override
  String get appInfoBuildNumber => 'Número da Compilação';

  @override
  String get appInfoReleaseDate => 'Data de Lançamento';

  @override
  String get appInfoAppSize => 'Tamanho do App';

  @override
  String appInfoOverview(String appName) {
    return '$appName é um aplicativo móvel moderno construído com segurança robusta e funcionalidade, projetado para fornecer uma experiência de usuário excepcional com arquitetura limpa e otimização de desempenho.';
  }

  @override
  String introTitle(String appName) {
    return 'Bem-vindo ao $appName';
  }

  @override
  String get introFeature1Title => 'Veja Seu Progresso';

  @override
  String get introFeature1Description => 'Acompanhe seus marcos de desenvolvimento com análises detalhadas e insights';

  @override
  String get introFeature2Title => 'Explore Modelos';

  @override
  String get introFeature2Description => 'Descubra componentes e telas pré-construídos para desenvolvimento rápido';

  @override
  String get introFeature3Title => 'Comece Rapidamente';

  @override
  String get introFeature3Description => 'Inicie seu projeto com configuração zero e melhores práticas';

  @override
  String get appleSignIn => 'Entrar com Apple';

  @override
  String get googleSignIn => 'Entrar com Google';

  @override
  String get appleRegister => 'Registrar com Apple';

  @override
  String get googleRegister => 'Registrar com Google';

  @override
  String get emailAndPassword => 'Digitar e-mail e senha';

  @override
  String get signInTitle => 'Entrar';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get legalConsentPart1 => 'Por favor, leia os ';

  @override
  String get legalConsentPart2 => 'termos e condições';

  @override
  String legalConsentPart3(String appName) {
    return ' e outros documentos legais que regem o seu uso do $appName.';
  }

  @override
  String get emailTitle => 'E-mail';

  @override
  String get passwordTitle => 'Senha';

  @override
  String get loginEmailLabel => 'Endereço de e-mail';

  @override
  String get loginEmailHint => 'Digite seu e-mail';

  @override
  String get loginPasswordLabel => 'Senha';

  @override
  String get loginPasswordHint => 'Digite sua senha';

  @override
  String get loginForgotPasswordPart1 => 'Esqueceu sua senha? ';

  @override
  String get loginForgotPasswordPart2 => 'Toque aqui';

  @override
  String get loginForgotPasswordPart3 => ' para redefinir sua senha?';

  @override
  String get commonConfirmPasswordLabel => 'Confirmar Senha';

  @override
  String get commonConfirmPasswordHint => 'Por favor, confirme sua senha';

  @override
  String get commonPasswordsDoNotMatch => 'As senhas não correspondem';

  @override
  String get commonPasswordConfirmRequired => 'Por favor, confirme sua senha';

  @override
  String commonFieldIsValid(String field) {
    return '$field é válido';
  }

  @override
  String get commonPleaseWait => 'Aguarde a conclusão da operação atual';

  @override
  String get commonUnexpectedError => 'Ocorreu um erro inesperado. Por favor tente novamente.';

  @override
  String get commonSomethingWentWrong => 'Algo deu errado. Por favor tente novamente.';

  @override
  String get commonEnterEmailAndRetry => 'Por favor digite seu endereço de e-mail e tente novamente';

  @override
  String get commonLearnMore => 'Saiba mais';

  @override
  String get authSignUpVerificationSent => 'E-mail de verificação enviado! Por favor verifique sua caixa de entrada.';

  @override
  String authSignUpFailed(String error) {
    return 'Registro falhou: $error';
  }

  @override
  String get authForgotPasswordTitle => 'Esqueceu sua senha?';

  @override
  String get authForgotPasswordSubtitle => 'Digite seu e-mail e enviaremos um link para redefinir sua senha.';

  @override
  String get authSendResetLink => 'Enviar link de redefinição';

  @override
  String get authBackToSignIn => 'Voltar para login';

  @override
  String get authUsernameScreenTitle => 'Escolha seu nome de usuário';

  @override
  String get authUsernameScreenSubtitle => 'Assim é como os outros te veem. Você pode mudar isto mais tarde.';

  @override
  String get authUsernameLabel => 'Nome de usuário';

  @override
  String get authUsernameHint => 'Digite um nome de usuário';

  @override
  String authUsernameMinLength(int min) {
    return 'O nome de usuário deve ter pelo menos $min caracteres';
  }

  @override
  String authUsernameMaxLength(int max) {
    return 'O nome de usuário deve ter no máximo $max caracteres';
  }

  @override
  String get authUsernameFormatError => 'Apenas letras, números e sublinhados são permitidos';

  @override
  String get authUsernameTaken => 'Este nome de usuário já está sendo usado';

  @override
  String get authUsernameCheckError => 'Não foi possível verificar a disponibilidade. Por favor tente novamente.';

  @override
  String get authUsernameSaveError => 'Não foi possível salvar seu nome de usuário. Por favor tente novamente.';

  @override
  String get authUsernameSavedSuccess => 'Nome de usuário salvo com sucesso!';

  @override
  String get authUpdatePasswordTitle => 'Criar nova senha';

  @override
  String get authUpdatePasswordButton => 'Atualizar senha';

  @override
  String get authUpdatePasswordSuccess => 'Senha atualizada com sucesso. Por favor faça login novamente.';

  @override
  String get authPasswordResetSentTitle => 'Verifique seu e-mail';

  @override
  String get authPasswordResetSentBody => 'Enviamos um link de redefinição de senha para';

  @override
  String get authPasswordResetSentNote => 'Toque no link no e-mail para definir uma nova senha. O link expira em 1 hora.';

  @override
  String get authGuestHello => 'Olá!';

  @override
  String authGuestOverview(String appName) {
    return 'Você está navegando $appName como convidado. Faça login ou crie uma conta para começar a gerenciar sua loja – leva menos de 5 segundos. Temos uma variedade de ferramentas para ajudar a crescer seu negócio, tudo gratuitamente.';
  }

  @override
  String authIntroTitle(String appName) {
    return 'Bem-vindo a\n$appName';
  }

  @override
  String get authIntroSubtitle => 'Bem-vindo à plataforma que construímos para você. Aproveite e divirta-se – o melhor está esperando.';

  @override
  String get authReadLegalities => 'Ler avisos legais';

  @override
  String get authPasswordRequired => 'Por favor digite sua senha';

  @override
  String get authCreatingAccount => 'Criando conta...';

  @override
  String get authAccountCreatedSuccess => 'Conta criada com sucesso!';

  @override
  String get authCheckEmailToConfirm => 'Por favor verifique seu e-mail para confirmar sua conta';

  @override
  String get authSigningInWithGoogle => 'Entrando com Google...';

  @override
  String authGoogleSignInFailed(String error) {
    return 'Falha ao entrar com Google: $error';
  }

  @override
  String get authAuthenticatingWithApple => 'Autenticando com Apple...';

  @override
  String authAppleSignInFailed(String error) {
    return 'Falha ao entrar com Apple: $error';
  }

  @override
  String get authSendingResetEmail => 'Enviando email de redefinição...';

  @override
  String get authResetEmailSent => 'Email de redefinição enviado. Verifique sua caixa de entrada.';

  @override
  String authPasswordResetFailed(String error) {
    return 'Falha ao redefinir senha: $error';
  }

  @override
  String get authVerifyEmailTitle => 'Verifique seu e-mail';

  @override
  String get authVerifyEmailSubtitle => 'Enviamos um link de confirmação para';

  @override
  String get authVerifyEmailNote => 'Toque no link no e-mail para verificar sua conta e continuar.';

  @override
  String get authConfirmationResent => 'Email de confirmação reenviado. Verifique sua caixa de entrada.';

  @override
  String get authResendFailed => 'Falha ao reenviar o email. Por favor tente novamente.';

  @override
  String get authResendEmailButton => 'Reenviar email de confirmação';

  @override
  String authResendEmailCooldown(int seconds) {
    return 'Reenviar email (${seconds}s)';
  }

  @override
  String get currencySelectorPlaceholder => 'Selecionar moeda';

  @override
  String get currencySelectorNoSelected => 'Nenhuma moeda selecionada';

  @override
  String get currencySelectorTitle => 'Selecionar moeda';

  @override
  String get currencySelectorSearchHint => 'Pesquisar por moeda, código ou bandeira...';

  @override
  String get currencySelectorNoResults => 'Nenhuma moeda encontrada';

  @override
  String get discoverScreenTitle => 'Descobrir';

  @override
  String get discoverSearchHint => 'Pesquisar...';

  @override
  String get discoverAllShopsRegion => 'Todas as lojas em sua região';

  @override
  String get discoverAllFreelancers => 'Todos os freelancers perto de você';

  @override
  String get discoverMarketplaceTitle => 'Mercado';

  @override
  String get discoverMarketplaceSubtitle => 'Compre produtos de beleza com pagamento na entrega';

  @override
  String get discoverBrowseProducts => 'Procurar produtos';

  @override
  String get discoverMyOrders => 'Meus pedidos';

  @override
  String get discoverCartTooltip => 'Carrinho';

  @override
  String get homeScheduleTabLabel => 'Cronograma';

  @override
  String get homeDashboardTabLabel => 'Painel';

  @override
  String get homeMapTabLabel => 'Mapa';

  @override
  String get validationRequired => 'Este campo é obrigatório';

  @override
  String get validationEmailInvalid => 'Digite um endereço de e-mail válido';

  @override
  String validationPasswordLength(int minLength) {
    return 'A senha deve ter pelo menos $minLength caracteres';
  }

  @override
  String get validationPasswordUppercase => 'A senha deve incluir pelo menos uma letra maiúscula';

  @override
  String get loggingInIndicatorText => 'Entrando...';

  @override
  String get loginSuccessful => 'Login bem-sucedido!\nBem-vindo de volta';

  @override
  String get errorLoginFailed => 'Falha no login. Verifique suas credenciais';

  @override
  String get errorNetwork => 'Erro de rede. Verifique sua conexão';

  @override
  String get homeTitle => 'Início';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get chatTitle => 'Chat';

  @override
  String get editProfileNameFieldTitle => 'Nome';

  @override
  String get editProfileNameFieldLabel => 'Nome completo';

  @override
  String get editProfileUserFieldNameTitle => 'Nome de usuário';

  @override
  String get editProfileUsernameFieldLabel => '@nomedeusuario';

  @override
  String get editProfileBioFieldTitle => 'Biografia';

  @override
  String get editProfileBioFieldLabel => 'Conte-nos sobre você';

  @override
  String get editProfileScreenTitle => 'Editar perfil';

  @override
  String get editProfileSettingTitle => 'Configurações da conta';

  @override
  String get editProfileSettingSubtitle => 'Gerencie sua conta';

  @override
  String get editProfileScreenEditShopTitle => 'Editar Loja';

  @override
  String get editProfileScreenEditShopSubtitle => 'Altere as informações da sua loja';

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
  String get languageScreenSubtitle => 'Escolha seu idioma preferido para a interface do app. Isso não afetará as configurações do seu dispositivo.';

  @override
  String get languageScreeUseDeviceLang => 'Usar Idioma do Dispositivo.';

  @override
  String get languageScreeUseDeviceLangNote => 'Isso será redefinido para coincidir com o idioma do sistema do seu dispositivo.';

  @override
  String get settingsScreenTitle => 'Configurações';

  @override
  String get accountSectionTitle => 'Conta';

  @override
  String get accountSectionSubtitle => '';

  @override
  String get profileItemTitle => 'Perfil';

  @override
  String get profileItemSubtitle => 'Gerencie seus dados pessoais';

  @override
  String get locationItemTitle => 'Alterar Localização';

  @override
  String get locationItemSubtitle => 'Altere sua cidade atual';

  @override
  String get saveItemTitle => 'Conteúdos Salvos';

  @override
  String get saveItemSubtitle => 'Conteúdos que você salvou';

  @override
  String get notificationsItemTitle => 'Notificações';

  @override
  String get notificationsItemSubtitle => 'Gerencie notificações push e email';

  @override
  String get blockedItemTitle => 'Contas Bloqueadas';

  @override
  String get blockedItemSubtitle => 'Contas que você bloqueou';

  @override
  String get qrCodeItemTitle => 'Compartilhar Código QR';

  @override
  String get qrCodeItemSubtitle => 'Compartilhe seu código QR da conta';

  @override
  String get shareProfileItemTitle => 'Compartilhar Perfil';

  @override
  String get shareProfileItemSubtitle => 'Compartilhe seu perfil com amigos';

  @override
  String get appSettingsSectionTitle => 'Configurações do App';

  @override
  String get appSettingsSectionSubtitle => 'Personalize sua experiência';

  @override
  String get themeItemTitle => 'Tema';

  @override
  String get themeItemSubtitle => 'Claro, Escuro ou Sistema';

  @override
  String get languageItemTitle => 'Idioma';

  @override
  String get languageItemSubtitle => 'Altere o idioma do app';

  @override
  String get biometricItemTitle => 'Login Biométrico';

  @override
  String get biometricItemSubtitle => 'Use Face ID ou Touch ID';

  @override
  String get supportSectionTitle => 'Suporte';

  @override
  String get supportSectionSubtitle => '';

  @override
  String get guideItemTitle => 'Guia do Usuário';

  @override
  String get guideItemSubtitle => 'Documentação e tutoriais';

  @override
  String get helpItemTitle => 'Contatar Suporte';

  @override
  String get helpItemSubtitle => 'Obtenha ajuda com o app';

  @override
  String get feedbackItemTitle => 'Enviar Feedback';

  @override
  String get feedbackItemSubtitle => 'Compartilhe seus pensamentos';

  @override
  String get rateItemTitle => 'Avaliar o App';

  @override
  String get rateItemSubtitle => 'Deixe uma avaliação';

  @override
  String appInfoItemTitle(String appName) {
    return 'Sobre o $appName';
  }

  @override
  String get appInfoItemSubtitle => 'Informações técnicas';

  @override
  String get legalSectionTitle => 'Legal';

  @override
  String get legalSectionSubtitle => '';

  @override
  String get termsItemTitle => 'Termos, Privacidade e Políticas';

  @override
  String get termsItemSubtitle => 'Leia nossos termos';

  @override
  String get licensesItemTitle => 'Licenças de Código Aberto';

  @override
  String get licensesItemSubtitle => 'Bibliotecas e licenças de terceiros';

  @override
  String get accountActionsSectionTitle => 'Ações da Conta';

  @override
  String get accountActionsSectionSubtitle => '';

  @override
  String get updatePasswordItemTitle => 'Atualizar senha';

  @override
  String get updatePasswordItemSubtitle => 'Altere a senha atual da sua conta';

  @override
  String get deactivateItemTitle => 'Desativar';

  @override
  String get deactivateItemSubtitle => 'Oculte e desative sua conta temporariamente';

  @override
  String get deleteItemTitle => 'Excluir Conta';

  @override
  String get deleteItemSubtitle => 'Solicite a exclusão permanente da sua conta';

  @override
  String get logoutItemTitle => 'Sair';

  @override
  String get logoutItemSubtitle => 'Saia da sua conta';

  @override
  String get logoutConfirmTitle => 'Tem certeza de que deseja sair?';

  @override
  String get logoutConfirmMessage => 'Você precisará entrar novamente para acessar sua conta e seus dados.';

  @override
  String get logoutConfirmButton => 'Sair';

  @override
  String get logoutSuccessMessage => 'Sessão encerrada com sucesso';

  @override
  String logoutFailedMessage(String error) {
    return 'Falha ao sair: $error';
  }

  @override
  String get accountDeactivateTitle => 'Desativar conta';

  @override
  String get accountDeleteTitle => 'Excluir conta';

  @override
  String get accountRestoreTitle => 'Restaurar conta';

  @override
  String get accountDeactivateWarningTitle => 'Sua conta será ocultada';

  @override
  String get accountDeactivateWarningBody => 'Seu perfil, lojas, produtos, perfil freelancer e links de reserva serão ocultados. Você pode restaurar o acesso entrando novamente.';

  @override
  String get accountDeleteWarningTitle => 'A exclusão é agendada por 30 dias';

  @override
  String get accountDeleteWarningBody => 'Sua presença pública será ocultada agora. Você pode restaurar sua conta em até 30 dias; depois disso, os dados pessoais do perfil serão removidos.';

  @override
  String get accountPasswordConfirmLabel => 'Confirmar senha';

  @override
  String get accountPasswordConfirmHint => 'Digite sua senha';

  @override
  String accountPhraseConfirmLabel(String phrase) {
    return 'Digite $phrase para confirmar';
  }

  @override
  String get accountReasonLabel => 'Motivo (opcional)';

  @override
  String get accountReasonHint => 'Conte-nos por que você está saindo';

  @override
  String accountPhraseMismatch(String phrase) {
    return 'Digite $phrase para continuar';
  }

  @override
  String get accountActionBlocked => 'Resolva reservas, pedidos ou saques ativos antes de continuar.';

  @override
  String get accountActionLoadFailed => 'Não foi possível carregar os requisitos da conta. Tente novamente.';

  @override
  String get accountActionGenericError => 'Não foi possível concluir esta ação da conta. Tente novamente.';

  @override
  String get accountRecentAuthRequired => 'Entre novamente antes de continuar.';

  @override
  String get accountReasonTooLong => 'O motivo deve ter 1000 caracteres ou menos.';

  @override
  String get accountDeactivateButton => 'Desativar conta';

  @override
  String get accountDeleteButton => 'Solicitar exclusão';

  @override
  String get accountDeactivatedSuccess => 'Sua conta foi desativada.';

  @override
  String get accountDeletionRequestedSuccess => 'A exclusão da conta foi agendada.';

  @override
  String get accountRestoreButton => 'Restaurar conta';

  @override
  String get accountRestoredSuccess => 'Sua conta foi restaurada.';

  @override
  String get accountRestoreFailed => 'Não foi possível restaurar esta conta.';

  @override
  String get accountRestoreMissingProfile => 'Não foi possível carregar seu perfil.';

  @override
  String get accountDeactivatedTitle => 'Conta desativada';

  @override
  String get accountDeactivatedBody => 'Sua conta está oculta. Restaure-a para continuar usando o aplicativo.';

  @override
  String get accountPendingDeleteTitle => 'Conta pendente de exclusão';

  @override
  String accountPendingDeleteBody(String date) {
    return 'Sua conta está agendada para exclusão em $date. Restaure-a antes disso para manter sua conta.';
  }

  @override
  String get accountDeletedTitle => 'Conta excluída';

  @override
  String get accountDeletedBody => 'Esta conta foi excluída e não pode mais ser restaurada.';

  @override
  String get accountBlockersTitle => 'Resolva isto primeiro';

  @override
  String accountBlockerActiveBookings(int count) {
    return '$count reserva(s) ativa(s)';
  }

  @override
  String accountBlockerOwnedShopActiveBookings(int count) {
    return '$count reserva(s) ativa(s) da loja';
  }

  @override
  String accountBlockerActiveOrders(int count) {
    return '$count pedido(s) ativo(s)';
  }

  @override
  String accountBlockerOwnedShopActiveOrders(int count) {
    return '$count pedido(s) ativo(s) da loja';
  }

  @override
  String accountBlockerActiveWithdrawals(int count) {
    return '$count saque(s) pendente(s)';
  }

  @override
  String get loadingDefaultMessage => 'Carregando...';

  @override
  String emptyStateNoDataTitle(String dataType) {
    return 'Nenhum(a) $dataType ainda';
  }

  @override
  String emptyStateNoDataSubtitle(String dataType) {
    return 'Quando $dataType estiver disponível, aparecerão aqui.';
  }

  @override
  String get emptyStateNoResultsTitle => 'Nenhum resultado encontrado';

  @override
  String emptyStateNoResultsSubtitle(String dataType) {
    return 'Tente ajustar sua pesquisa ou filtros para encontrar $dataType.';
  }

  @override
  String get emptyStateNoInternetTitle => 'Sem conexão com a internet';

  @override
  String get emptyStateNoInternetSubtitle => 'Verifique sua conexão e tente novamente.';

  @override
  String get emptyStateNoFavoritesTitle => 'Nenhum favorito ainda';

  @override
  String get emptyStateNoFavoritesSubtitle => 'Comece adicionando itens à sua lista de favoritos.';

  @override
  String get emptyStateNoMessagesTitle => 'Nenhuma mensagem';

  @override
  String get emptyStateNoMessagesSubtitle => 'Inicie uma conversa para ver mensagens aqui.';

  @override
  String get emptyStateRefresh => 'Atualizar';

  @override
  String get emptyStateClearFilters => 'Limpar filtros';

  @override
  String get emptyStateRetry => 'Tentar novamente';

  @override
  String get emptyStateExplore => 'Explorar';

  @override
  String get emptyStateStartChat => 'Iniciar chat';

  @override
  String get errorNetworkTitle => 'Erro de conexão';

  @override
  String get errorNetworkSubtitle => 'Não foi possível conectar ao servidor. Verifique sua conexão com a internet.';

  @override
  String get errorServerTitle => 'Erro do servidor';

  @override
  String get errorServerSubtitle => 'Algo deu errado do nosso lado. Por favor, tente novamente mais tarde.';

  @override
  String get errorClientTitle => 'Erro na solicitação';

  @override
  String get errorClientSubtitle => 'Houve um problema com sua solicitação. Por favor, verifique e tente novamente.';

  @override
  String get errorParsingTitle => 'Erro de dados';

  @override
  String errorParsingSubtitle(String dataType) {
    return 'Não foi possível processar o(a) $dataType. Isso pode ser um problema temporário.';
  }

  @override
  String get errorPermissionTitle => 'Acesso negado';

  @override
  String errorPermissionSubtitle(String dataType) {
    return 'Você não tem permissão para acessar este(a) $dataType.';
  }

  @override
  String get errorGenericTitle => 'Algo deu errado';

  @override
  String errorGenericSubtitle(String dataType) {
    return 'Ocorreu um erro inesperado ao carregar $dataType. Por favor, tente novamente.';
  }

  @override
  String get errorRetry => 'Tentar novamente';

  @override
  String get errorCheckSettings => 'Verificar configurações';

  @override
  String get errorReport => 'Reportar problema';

  @override
  String get errorGoBack => 'Voltar';

  @override
  String get errorRefresh => 'Atualizar';

  @override
  String get errorRequestAccess => 'Solicitar acesso';

  @override
  String get errorContactSupport => 'Contatar suporte';

  @override
  String get dataTypeUsers => 'usuários';

  @override
  String get dataTypeUser => 'usuário';

  @override
  String get dataTypeProducts => 'produtos';

  @override
  String get dataTypeProduct => 'produto';

  @override
  String get dataTypeOrders => 'pedidos';

  @override
  String get dataTypeOrder => 'pedido';

  @override
  String get dataTypeMessages => 'mensagens';

  @override
  String get dataTypeMessage => 'mensagem';

  @override
  String get dataTypeFavorites => 'favoritos';

  @override
  String get dataTypeFavorite => 'favorito';

  @override
  String get dataTypeData => 'dados';

  @override
  String get dataTypeContent => 'conteúdo';

  @override
  String get dataTypeItems => 'itens';

  @override
  String get dataTypeItem => 'item';

  @override
  String get eulaTitle => 'Contrato de Licença de Usuário Final';

  @override
  String eulaContent(String appName, String supportEmail) {
    return 'Este Contrato de Licença de Usuário Final (\"EULA\") é um acordo legal entre você e a Bars Opus, Ltd. para $appName.\n\nAo instalar, acessar ou usar $appName, você concorda em ficar vinculado aos termos deste EULA. $appName é licenciado, não vendido, para seu uso apenas sob os termos desta licença. A Bars Opus, Ltd. reserva-se todos os direitos não expressamente concedidos a você neste EULA.\n\nVocê não pode modificar, fazer engenharia reversa, descompilar ou desmontar $appName. Esta licença é válida até ser rescindida por você ou pela Bars Opus, Ltd. Seus direitos sob esta licença terminarão automaticamente sem aviso se você não cumprir qualquer termo.\n\nTodos os direitos de propriedade intelectual sobre $appName pertencem à Bars Opus, Ltd. Este EULA é regido pelas leis da Inglaterra e do País de Gales.\n\nPara perguntas sobre este EULA, entre em contato: $supportEmail.';
  }

  @override
  String get eulaFooter => 'Ao concordar, você reconhece que leu e entendeu este Contrato de Licença de Usuário Final.';

  @override
  String get privacyPolicyTitle => 'Política de Privacidade';

  @override
  String privacyPolicyContent(String appName) {
    return 'Esta Política de Privacidade explica como a Bars Opus, Ltd. (\"nós\", \"nosso\") coleta, usa e protege suas informações quando você usa $appName.\n\nColetamos informações que você fornece diretamente, como quando cria uma conta, completa seu perfil ou entra em contato com o suporte. Coletamos automaticamente certas informações sobre seu dispositivo e como você usa $appName. Usamos cookies e tecnologias de rastreamento semelhantes para rastrear a atividade e armazenar determinadas informações.\n\nUsamos as informações que coletamos para fornecer, manter e melhorar $appName. Podemos compartilhar suas informações com provedores de serviços terceirizados que realizam serviços em nosso nome. Podemos divulgar suas informações se exigido por lei ou para proteger nossos direitos e segurança.\n\nVocê tem o direito de acessar, corrigir ou excluir suas informações pessoais. Implementamos medidas técnicas e organizacionais adequadas para proteger suas informações. Podemos atualizar esta Política de Privacidade periodicamente. Iremos notificá-lo sobre quaisquer alterações.';
  }

  @override
  String privacyPolicyFooter(String appName, DateTime currentDate) {
    final intl.DateFormat currentDateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String currentDateString = currentDateDateFormat.format(currentDate);

    return 'Política de Privacidade do $appName - Última atualização: $currentDateString';
  }

  @override
  String get termsTitle => 'Termos de Serviço';

  @override
  String termsContent(String appName, String supportEmail) {
    return 'Estes Termos de Serviço (\"Termos\") regem seu acesso e uso de $appName. Ao acessar ou usar $appName, você concorda em ficar vinculado a estes Termos.\n\nVocê deve ter pelo menos 13 anos para usar $appName. Você é responsável por proteger suas credenciais de conta e por todas as atividades sob sua conta. Você não pode usar $appName para qualquer finalidade ilegal ou não autorizada.\n\nReservamo-nos o direito de modificar, suspender ou descontinuar $appName a qualquer momento. Todo o conteúdo incluído em $appName é propriedade da Bars Opus, Ltd. ou de seus licenciadores.\n\nPodemos encerrar ou suspender seu acesso a $appName imediatamente se você violar estes Termos. Estes Termos serão regidos e interpretados de acordo com as leis da Inglaterra e do País de Gales.\n\nPara quaisquer perguntas sobre estes Termos, entre em contato conosco em $supportEmail.';
  }

  @override
  String get dataSharingTitle => 'Acordo de Compartilhamento de Dados';

  @override
  String dataSharingContent(String appName) {
    return 'Este Acordo de Compartilhamento de Dados descreve como suas informações podem ser compartilhadas quando você usa os recursos sociais do $appName.\n\nQuando você se conecta com amigos no $appName, certos dados de atividade podem ser visíveis para eles. Os dados de atividade compartilhados podem incluir duração do treino, calorias queimadas, minutos de exercício e emblemas de conquistas. Suas informações de perfil (nome de exibição e foto do perfil) são visíveis para amigos com quem você se conecta.\n\nSeu endereço de e-mail e informações de contato permanecem privados e nunca são compartilhados com outros usuários. Você controla quais dados são compartilhados através das suas configurações de privacidade do $appName. Você pode revogar as permissões de compartilhamento a qualquer momento nas configurações do aplicativo.\n\nOs dados compartilhados com amigos são criptografados durante a transmissão e armazenamento. Mantemos os dados compartilhados apenas pelo tempo necessário para fornecer a funcionalidade de compartilhamento. As integrações de terceiros podem ter suas próprias práticas de compartilhamento de dados, que recomendamos revisar.';
  }

  @override
  String dataSharingFooter(String appName) {
    return 'O compartilhamento de dados no $appName ajuda a criar uma comunidade de apoio, respeitando suas escolhas de privacidade.';
  }

  @override
  String get dashboardTitle => 'Painel de Controle';

  @override
  String get dashboardSubtitle => 'Gerencie as atividades da sua loja de forma eficiente';

  @override
  String get dashboardSectionTitle => 'Painel de Controle';

  @override
  String get dashboardSectionSubtitle => 'Visão geral do desempenho e métricas principais da sua loja';

  @override
  String get dashboardPayoutTitle => 'Solicitar Pagamento';

  @override
  String get dashboardPayoutContent => 'Proprietários de lojas podem solicitar pagamentos semanais. Navegue até a seção Ganhos, revise seu saldo e envie uma solicitação de pagamento. Os fundos geralmente são processados em 3-5 dias úteis.';

  @override
  String get dashboardAnalyticsTitle => 'Painel Analítico';

  @override
  String get dashboardAnalyticsContent => 'Acompanhe o desempenho da sua loja com análises em tempo real. Monitore tendências de vendas, engajamento do cliente e níveis de estoque por meio de gráficos interativos e relatórios.';

  @override
  String get dashboardScreenshotTitle => 'Visão Geral do Painel';

  @override
  String get dashboardScreenshotContent => 'O painel principal fornece uma visão abrangente das principais métricas da sua loja, atividades recentes e acesso rápido a recursos essenciais.';

  @override
  String get categoryFeatures => 'Recursos';

  @override
  String get categoryDashboard => 'Painel de Controle';

  @override
  String get faqDashboard1Question => 'Quando posso solicitar um pagamento?';

  @override
  String get faqDashboard1Answer => 'Você pode solicitar seu pagamento uma vez por semana, todo sábado. O corte semanal é sexta-feira às 23:59. Os pagamentos são processados em 3-5 dias úteis.';

  @override
  String get faqDashboard2Question => 'Onde posso solicitar meu pagamento?';

  @override
  String get faqDashboard2Answer => 'Navegue até seu painel de controle e clique na seção \'Ganhos\'. De lá, você verá seu saldo atual e um botão \'Solicitar Pagamento\'. Siga as instruções para completar sua solicitação.';

  @override
  String get profileScreenCantChatWithYourself => 'Você não pode conversar consigo mesmo';

  @override
  String get profileScreenStartingConversation => 'Iniciando conversa...';

  @override
  String get profileScreenNoActiveSession => 'Nenhuma sessão ativa — faça login novamente.';

  @override
  String get profileScreenSignInToChatMessage => 'Você deve fazer login para enviar uma mensagem';

  @override
  String get profileScreenFollowFeatureComingSoon => 'Recurso de seguimento em breve';

  @override
  String get profileScreenEnterBioPlaceholder => 'Digite uma biografia para que as pessoas o conheçam';

  @override
  String get profileScreenNoBioYet => 'Nenhuma biografia ainda';

  @override
  String get profileScreenErrorLoadingProfileBody => 'Não foi possível carregar o perfil. Verifique sua conexão de internet e tente novamente.';

  @override
  String get profileScreenLoadingNotifications => 'Carregando...';

  @override
  String get profileHeaderBookingsStatLabel => 'Reservas';

  @override
  String get profileHeaderOrdersStatLabel => 'Pedidos';

  @override
  String get profileHeaderEditProfileButton => 'Editar perfil';

  @override
  String get profileHeaderMessageButton => 'Mensagem';

  @override
  String get editableProfileAvatarTakePhoto => 'Tire uma foto';

  @override
  String get editableProfileAvatarChooseGallery => 'Escolher da galeria';

  @override
  String get editProfileScreenAccountTypeLabel => 'Tipo de conta';

  @override
  String get editProfileScreenAccountTypeSubtitle => 'Selecione como deseja usar este aplicativo. Isso determina quais recursos estão disponíveis para você.';

  @override
  String get editProfileScreenUpdatingAccountType => 'Atualizando tipo de conta...';

  @override
  String get editProfileScreenPleaseLogIn => 'Faça login por favor';

  @override
  String get editProfileScreenNameLabel => 'Nome';

  @override
  String get editProfileScreenNameHint => 'Insira seu nome';

  @override
  String get editProfileScreenUsernameLabel => 'Nome de usuário';

  @override
  String get editProfileScreenUsernameHint => 'Insira o nome de usuário';

  @override
  String get editProfileScreenBioLabel => 'Biografia';

  @override
  String get editProfileScreenBioHint => 'Conte-nos sobre você';

  @override
  String get editProfileScreenEditWorkProfileTitle => 'Editar perfil de trabalho';

  @override
  String get profileTabsAppointments => 'Compromissos';

  @override
  String get profileTabsBuys => 'Compras';

  @override
  String get profileTabsSaves => 'Salvos';

  @override
  String get searchScreenSearchHint => 'Pesquise lojas, profissionais, produtos...';

  @override
  String get searchScreenNoResultsFound => 'Nenhum resultado encontrado';

  @override
  String searchScreenNoResultsCategory(String category) {
    return 'Nenhum $category encontrado';
  }

  @override
  String searchScreenSearchedFor(String query) {
    return 'Pesquisado: \"$query\"';
  }

  @override
  String get searchScreenSomethingWentWrong => 'Algo deu errado';

  @override
  String get searchAppBarSearchHint => 'Pesquisar...';

  @override
  String get searchSuggestionsHint => 'Pesquise lojas, profissionais de serviços domiciliares ou produtos para cabelo para comprar';

  @override
  String get searchSuggestionsRecentSearches => 'Pesquisas recentes';

  @override
  String get searchSuggestionsClearAll => 'Limpar tudo';

  @override
  String get searchEmptyStateNoResults => 'Nenhum resultado encontrado';

  @override
  String searchEmptyStateCouldNotFind(String query) {
    return 'Não encontramos nada para \"$query\"';
  }

  @override
  String get searchEmptyStateTryThese => 'Tente estes:';

  @override
  String get searchResultsShopsHeader => 'Lojas';

  @override
  String get searchResultsSeeAll => 'Ver tudo';

  @override
  String searchResultsTitle(String category) {
    return 'Resultados de $category';
  }

  @override
  String searchResultsSearchingFor(String query) {
    return 'Pesquisando \"$query\"';
  }

  @override
  String get searchResultsTryDifferent => 'Tente palavras-chave diferentes ou remova filtros';

  @override
  String get searchResultsSomethingWentWrong => 'Algo deu errado';

  @override
  String nearYouShopsTitle(int km) {
    return 'Perto de você\ndenro de ${km}km';
  }

  @override
  String nearYouShopsBody(int km) {
    return 'Lojas localizadas dentro de $km km da sua localização atual, mostradas da mais próxima para a mais distante. Simplesmente defina sua localização uma vez, e mostraremos o que está por perto—seja em casa, no trabalho ou explorando um novo bairro. Útil para reservas de última hora ou quando você prefere caminhar.';
  }

  @override
  String get nearYouShopsEmptyNoFilter => 'Nenhuma loja encontrada perto de você';

  @override
  String nearYouShopsEmptyWithFilter(String luxury) {
    return 'Nenhuma loja $luxury encontrada perto de você';
  }

  @override
  String nearYouShopsEmptySubtitle(String location) {
    return 'As lojas em $location seriam exibidas aqui assim que ficassem disponíveis';
  }

  @override
  String get premiumShopsScreenTitle => 'Lojas Premium';

  @override
  String get premiumShopsEmpty => 'Nenhuma loja premium encontrada';

  @override
  String get premiumShopsHorizontalTitle => 'Lojas premium\npara looks premium';

  @override
  String get premiumShopsHorizontalBody => 'Salões e spas de luxo cuidadosamente selecionados que oferecem experiências luxuosas. Estas lojas são classificadas como Luxo ou Ultra-Luxo com base em seus serviços, preços e avaliações de clientes. Perfeito quando você quer aquele toque extra de elegância.';

  @override
  String get premiumShopsHorizontalEmptyNoFilter => 'Nenhuma loja premium disponível';

  @override
  String premiumShopsHorizontalEmptyWithFilter(String luxury) {
    return 'Nenhuma loja premium $luxury disponível';
  }

  @override
  String get premiumShopsHorizontalEmptySubtitle => 'As lojas seriam exibidas aqui uma vez que ficassem disponíveis';

  @override
  String get topRatedShopsHorizontalTitle => 'Mais bem avaliado';

  @override
  String topRatedShopsHorizontalTitleWithLocation(String location) {
    return 'Mais bem avaliado \nem $location';
  }

  @override
  String get topRatedShopsHorizontalBody => 'Lojas com as avaliações mais altas de clientes (4,5+ estrelas) e muitas resenhas. Estes são os favoritos da nossa comunidade—constantemente elogiados por qualidade, serviço e profissionalismo. Um ótimo lugar para começar se você quer opções confiáveis e aprovadas pela multidão.';

  @override
  String get topRatedShopsHorizontalEmptyNoFilter => 'Nenhuma loja bem avaliada disponível';

  @override
  String topRatedShopsHorizontalEmptyWithFilter(String luxury) {
    return 'Nenhuma loja premium $luxury disponível';
  }

  @override
  String get topRatedShopsHorizontalEmptySubtitle => 'As lojas seriam exibidas aqui uma vez que ficassem disponíveis';

  @override
  String get topRatedShopsScreenTitle => 'Lojas Mais Bem Avaliadas';

  @override
  String get topRatedShopsEmpty => 'Nenhuma loja bem avaliada encontrada';

  @override
  String get nearYouFreelancersScreenTitle => 'Freelancers perto de você';

  @override
  String get nearYouFreelancersEmpty => 'Nenhum freelancer encontrado perto';

  @override
  String get nearYouFreelancersEmptySubtitle => 'Tente expandir sua área de pesquisa ou mude de localização';

  @override
  String get topRatedFreelancersScreenTitle => 'Freelancers mais bem avaliados';

  @override
  String get topRatedFreelancersEmpty => 'Nenhum freelancer bem avaliado encontrado';

  @override
  String get topRatedFreelancersEmptySubtitle => 'Tente ajustar sua área de pesquisa';

  @override
  String topRatedFreelancersHorizontalTitle(String location) {
    return 'Mais bem avaliados \nem $location';
  }

  @override
  String get topRatedFreelancersHorizontalBody => 'Profissionais altamente qualificados cuidadosamente selecionados que oferecem experiências luxuosas. Estes freelancers são classificados como mais bem avaliados com base na qualidade de seu trabalho, preços e avaliações de clientes. Perfeito para aquele toque extra de excelência.';

  @override
  String nearYouFreelancersHorizontalTitle(String location) {
    return 'Freelancers Perto de Você em $location';
  }

  @override
  String get nearYouFreelancersHorizontalBody => 'Profissionais qualificados localizados perto de você. Estes freelancers estão disponíveis para reservas rápidas e oferecem serviço local conveniente. Perfeito quando você busca confiabilidade e proximidade.';

  @override
  String get nearYouFreelancersHorizontalEmpty => 'Nenhum freelancer bem avaliado disponível';

  @override
  String get nearYouFreelancersHorizontalEmptySubtitle => 'Os freelancers seriam exibidos aqui uma vez que ficassem disponíveis';

  @override
  String get shopNoLocationSetTitle => 'Defina sua localização para descobrir';

  @override
  String get shopNoLocationSetContent => 'Defina sua localização para descobrir lojas premium e bem avaliadas perto de você.';

  @override
  String get providerTypeShops => 'Lojas';

  @override
  String get providerTypeFreelancers => 'Freelancers';

  @override
  String get providerTypeBuy => 'Comprar';

  @override
  String get luxuryLevelChipsAll => 'Todos';

  @override
  String get searchRadiusSliderTitle => 'Raio de exploração';

  @override
  String searchRadiusSliderSubtitle(int km) {
    return 'Mostrando resultados dentro de ${km}km da sua localização';
  }

  @override
  String validationPasswordMaxLength(int max) {
    return 'A senha não deve exceder $max caracteres';
  }

  @override
  String get validationPasswordRepeatingChars => 'A senha contém muitos caracteres repetidos';

  @override
  String get validationPasswordSequential => 'A senha contém caracteres sequenciais';

  @override
  String validationPhoneDigits(int digits) {
    return 'O número de telefone deve ter $digits dígitos';
  }

  @override
  String get validationPhoneUK => 'Número de telefone britânico inválido';

  @override
  String validationUrlScheme(String schemes) {
    return 'A URL deve começar com $schemes';
  }

  @override
  String get validationUrlDomain => 'Nome de domínio inválido';

  @override
  String get validationUrlPublicAddress => 'A URL deve apontar para um endereço público';

  @override
  String validationNameMaxLength(String field, int max) {
    return '$field não deve exceder $max caracteres';
  }

  @override
  String validationNameConsecutiveChars(String field) {
    return '$field não pode conter hífens ou espaços consecutivos';
  }

  @override
  String get validationCreditCardFormat => 'Por favor, digite um número de cartão de crédito válido';

  @override
  String get validationCreditCardInvalid => 'Número de cartão de crédito inválido';

  @override
  String get validationDatePastNotAllowed => 'A data não pode ser no passado';

  @override
  String get validationPostalCodeZip => 'Por favor, digite um CEP válido (ex. 12345 ou 12345-6789)';

  @override
  String get validationPostalCodeCanadian => 'Por favor, digite um código postal canadense válido (ex. A1A 1A1)';

  @override
  String get validationPostalCodeGeneric => 'Por favor, digite um código postal válido';

  @override
  String get validationSSNFormat => 'Por favor, digite um SSN válido (ex. 123-45-6789)';

  @override
  String get validationSSNInvalid => 'SSN inválido';

  @override
  String get validationEmailTooLong => 'O endereço de e-mail é muito longo (máx. 254 caracteres)';

  @override
  String get validationEmailLocalPartTooLong => 'A parte local do endereço de e-mail é muito longa';

  @override
  String get categoriesAll => 'Todos';

  @override
  String get categoriesSalon => 'Salões';

  @override
  String get categoriesBarbershop => 'Barbearias';

  @override
  String get categoriesSpa => 'Spas';

  @override
  String get categoriesNailSalon => 'Salões de Unhas';

  @override
  String get categoriesLashStudio => 'Estúdios de Cílios';

  @override
  String get categoriesWaxing => 'Depilação';

  @override
  String get categoriesMassage => 'Massagem';

  @override
  String get categoriesMakeup => 'Maquiagem';

  @override
  String get categoriesSkincare => 'Cuidados com a Pele';

  @override
  String get luxuryLevelModerate => 'Moderado';

  @override
  String get luxuryLevelLuxury => 'Luxo';

  @override
  String get luxuryLevelUltraLuxury => 'Ultra Luxo';

  @override
  String get dashboardTabRevenue => 'Receita';

  @override
  String get dashboardTabAnalytics => 'Análise';

  @override
  String get dashboardTabInsights => 'Insights';

  @override
  String get dashboardTabTools => 'Ferramentas';

  @override
  String get dashboardTabClients => 'Clientes';

  @override
  String get dashboardTabStaff => 'Equipe';

  @override
  String get walletRecentTransactions => 'Transações Recentes';

  @override
  String get walletLoadError => 'Não conseguimos carregar sua carteira no momento.';

  @override
  String get walletTransactionLoadError => 'Não foi possível carregar as transações recentes.';

  @override
  String get walletPaymentProcessing => 'Aguarde o processamento do pagamento e retorne ao seu aplicativo para completar sua reserva.';

  @override
  String get analyticsRevenue => 'Receita';

  @override
  String get analyticsServices => 'Serviços';

  @override
  String get analyticsWorkers => 'Funcionários';

  @override
  String get analyticsLoadError => 'Falha ao carregar análises';

  @override
  String get analyticsEmpty => 'Nenhum dado disponível para análises.';

  @override
  String get analyticsEmptySubtitle => 'Estatísticas de reservas e receitas apareceriam aqui';

  @override
  String get insightsReports => 'Relatórios';

  @override
  String get insightsSeeAll => 'Ver Tudo';

  @override
  String get insightsLoadError => 'Não foi possível carregar os relatórios. Puxe para atualizar.';

  @override
  String get insightsNoAlerts => 'Tudo bem! Sem alertas';

  @override
  String get insightsHeatmapError => 'Não foi possível carregar o mapa de calor de reservas.';

  @override
  String get insightsNoHeatmapData => 'Nenhum dado de mapa de calor disponível';

  @override
  String get toolsAdminTools => 'Ferramentas de Administração';

  @override
  String get toolsConfigure => 'Configurar →';

  @override
  String get toolsManage => 'Gerenciar →';

  @override
  String get toolsExport => 'Exportar →';

  @override
  String get toolsAutomatedReminders => 'Lembretes Automatizados';

  @override
  String get toolsPromotionsManager => 'Gerenciador de Promoções';

  @override
  String get toolsExportReports => 'Exportar Relatórios';

  @override
  String get toolsPaymentSettings => 'Configurações de Pagamento';

  @override
  String get toolsLoadingDetails => 'Carregando detalhes da loja…';

  @override
  String get toolsBusinessHours => 'Horário de Funcionamento';

  @override
  String get toolsServiceManagement => 'Gerenciamento de Serviços';

  @override
  String get clientsSearchHint => 'Pesquisar por nome...';

  @override
  String get clientsLoadError => 'Falha ao carregar clientes';

  @override
  String get clientsNotFound => 'Nenhum Cliente Encontrado';

  @override
  String get clientsEmpty => 'Nenhum Cliente Ainda';

  @override
  String clientsSearchEmpty(String query) {
    return 'Nenhum cliente corresponde a \"$query\"';
  }

  @override
  String get clientsEmptySubtitle => 'Os clientes aparecerão aqui quando fizerem sua primeira reserva.';

  @override
  String get walletLabel => 'Carteira';

  @override
  String get walletAvailableBalance => 'Saldo Disponível';

  @override
  String get walletWithdrawFunds => 'Sacar Fundos';

  @override
  String get walletTotalEarned => 'Total Ganho';

  @override
  String get walletTotalWithdrawn => 'Total Sacado';

  @override
  String get transactionDepositReceived => 'Depósito Recebido';

  @override
  String get transactionServicePayment => 'Pagamento de Serviço';

  @override
  String get transactionWithdrawal => 'Saque';

  @override
  String get transactionRefund => 'Reembolso';

  @override
  String get transactionPlatformFee => 'Taxa da Plataforma';

  @override
  String get transactionAdjustment => 'Ajuste';

  @override
  String get transactionToday => 'Hoje';

  @override
  String get transactionYesterday => 'Ontem';

  @override
  String get withdrawalTitle => 'Sacar';

  @override
  String withdrawalInfo(double fee, String currency, double minFee) {
    return 'Os saques são processados imediatamente e enviados para sua conta conectada. Uma taxa de $fee% (mín $currency $minFee) é aplicada.';
  }

  @override
  String withdrawalAvailableBalance(String currency, String amount) {
    return 'Saldo disponível: $currency $amount';
  }

  @override
  String withdrawalAmountInputLabel(String currency) {
    return 'Valor ($currency)';
  }

  @override
  String get withdrawalAmountHint => 'Digite o valor a sacar';

  @override
  String get withdrawalAmountRequired => 'Por favor, digite um valor';

  @override
  String get withdrawalAmountInvalid => 'Por favor, digite um valor válido';

  @override
  String withdrawalMinimum(String currency, double min) {
    return 'O saque mínimo é $currency $min';
  }

  @override
  String withdrawalMaximum(String currency, double max) {
    return 'O saque máximo por transação é $currency $max';
  }

  @override
  String withdrawalInsufficientBalance(String currency, String available) {
    return 'Saldo insuficiente. Disponível: $currency $available';
  }

  @override
  String get withdrawalBreakdownAmount => 'Valor a sacar:';

  @override
  String withdrawalFeeLabel(Object fee) {
    return 'Taxa ($fee%):';
  }

  @override
  String get withdrawalNetAmount => 'Você receberá:';

  @override
  String get withdrawalProcessing => 'Processando...';

  @override
  String get withdrawalRequestButton => 'Solicitar Saque';

  @override
  String get withdrawalNoPaymentMethod => 'Nenhum método de pagamento conectado';

  @override
  String get withdrawalSuccess => 'Solicitação de saque enviada com sucesso!';

  @override
  String get deadLetterTitle => 'Saque precisa de revisão';

  @override
  String deadLetterSingle(String currency, String amount) {
    return '$currency $amount preso — toque para detalhes';
  }

  @override
  String deadLetterMultiple(String currency, String amount, int count) {
    return '$currency $amount preso em $count saques — toque para detalhes';
  }

  @override
  String get deadLetterReason => 'Motivo:';

  @override
  String get deadLetterContactSupport => 'Entre em contato com o suporte';

  @override
  String get paymentSetupTitle => 'Completar configuração de pagamento';

  @override
  String get paymentSetupContent => 'Conecte sua conta de pagamento para começar a sacar dinheiro de sua carteira. Pode ser seu número de celular ou sua conta bancária.';

  @override
  String get calendarErrorLoading => 'Erro ao carregar o calendário';

  @override
  String get calendarErrorLoadingBookings => 'Erro ao carregar as reservas';

  @override
  String get calendarNoAppointmentsDay => 'Sem compromissos neste dia';

  @override
  String get calendarNoBookingsDay => 'Sem reservas neste dia';

  @override
  String calendarAppointmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'compromissos',
      one: 'compromisso',
    );
    return '$count $_temp0';
  }

  @override
  String get monthJanuary => 'Jan';

  @override
  String get monthFebruary => 'Fev';

  @override
  String get monthMarch => 'Mar';

  @override
  String get monthApril => 'Abr';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJune => 'Jun';

  @override
  String get monthJuly => 'Jul';

  @override
  String get monthAugust => 'Ago';

  @override
  String get monthSeptember => 'Set';

  @override
  String get monthOctober => 'Out';

  @override
  String get monthNovember => 'Nov';

  @override
  String get monthDecember => 'Dez';

  @override
  String get dayMonday => 'Seg';

  @override
  String get dayTuesday => 'Ter';

  @override
  String get dayWednesday => 'Qua';

  @override
  String get dayThursday => 'Qui';

  @override
  String get dayFriday => 'Sex';

  @override
  String get daySaturday => 'Sab';

  @override
  String get daySunday => 'Dom';

  @override
  String calendarNoAppointmentsSnackbar(String date) {
    return 'Sem compromissos neste dia\n$date';
  }

  @override
  String reviewsScreenTitle(String shopName) {
    return 'Avaliações para $shopName';
  }

  @override
  String get reviewsLoadError => 'Não foi possível carregar as avaliações';

  @override
  String get reviewsNoReviews => 'Sem avaliações ainda';

  @override
  String get reviewsRateProduct => 'Avaliar produto';

  @override
  String get reviewsYourReview => 'Sua avaliação';

  @override
  String get reviewsReviewHint => 'Compartilhe sua experiência com este produto...';

  @override
  String get reviewsSubmitButton => 'Enviar avaliação';

  @override
  String get reviewsThankYou => 'Obrigado pela sua avaliação!';

  @override
  String reviewsSubmitError(String error) {
    return 'Não foi possível enviar a avaliação: $error';
  }

  @override
  String get bookingServiceAddress => 'Endereço do serviço';

  @override
  String get bookingFindingAvailableTimes => 'Procurando horários disponíveis...';

  @override
  String bookingErrorLoadingWorkers(String error) {
    return 'Erro ao carregar funcionários: $error';
  }

  @override
  String bookingErrorValidatingDistance(String error) {
    return 'Erro ao validar distância: $error';
  }

  @override
  String get bookingAddSpecialRequirements => 'Adicionar';

  @override
  String get bookingCancelSpecialRequirements => 'Cancelar';

  @override
  String get bookingSaveSpecialRequirements => 'Salvar';

  @override
  String bookingFailedSaveRequirements(String error) {
    return 'Erro ao salvar: $error';
  }

  @override
  String get bookingInvitationSent => 'Convite enviado com sucesso';

  @override
  String get bookingSavingAssignments => 'Salvando atribuições...';

  @override
  String get bookingAssignmentsSaved => 'Atribuições salvas com sucesso';

  @override
  String bookingAssignmentsError(String error) {
    return 'Erro: $error';
  }

  @override
  String get scheduleTitle => 'Cronograma';

  @override
  String get scheduleTabDaily => 'Diário';

  @override
  String get scheduleTabMonthly => 'Mensal';

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
  String get docsGettingStartedTitle => 'Começar';

  @override
  String get docsGettingStartedSubtitle => 'Aprenda o básico';

  @override
  String get docsGettingStartedWhatIsTitle => 'O que é Aura In?';

  @override
  String get docsGettingStartedWhatIsSubtitle => 'Entenda a plataforma';

  @override
  String get docsGettingStartedWelcomeIntroContent => 'Aura In é um marketplace móvel que conecta profissionais de serviços com clientes. Se você oferece cortes de cabelo, massagens, serviços freelancer ou vende produtos, esta plataforma ajuda seu negócio a crescer.';

  @override
  String get docsGettingStartedWhoUsesTitle => 'Quem usa Aura In?';

  @override
  String get docsGettingStartedWhoUsesContent => 'Dois tipos de usuários alimentam a plataforma:';

  @override
  String get docsGettingStartedWhoUsesProviders => 'Prestadores de serviços - Salões, spas, barbearias, freelancers que oferecem serviços';

  @override
  String get docsGettingStartedWhoUsesCustomers => 'Clientes - Pessoas que buscam e reservam serviços em sua área';

  @override
  String get docsGettingStartedWhoUsesSellers => 'Vendedores de produtos - Lojas que vendem produtos de varejo ou artigos feitos à mão';

  @override
  String get docsGettingStartedHowItWorksTitle => 'Como funciona';

  @override
  String get docsGettingStartedHowItWorksContent => 'Prestadores de serviços criam um perfil, listam seus serviços com preços e aceitam reservas de clientes. Clientes buscam por localização, navegam por serviços e reservam compromissos. Tudo é gerenciado através do app.';

  @override
  String get docsGettingStartedThreeWaysTitle => 'Três formas de usar Aura In';

  @override
  String get docsGettingStartedThreeWaysSubtitle => 'Escolha seu papel';

  @override
  String get docsGettingStartedOption1Title => 'Opção 1: Navegar e reservar serviços (Cliente)';

  @override
  String get docsGettingStartedOption1Content => 'Procure por salões, massoterapeutas, barbeiros ou freelancers perto de você. Veja seus serviços, preços e disponibilidade. Reserve compromissos diretamente pelo app e pague com segurança.';

  @override
  String get docsGettingStartedGuestBookingTitle => 'Reserva de convidado (sem necessidade de download do app)';

  @override
  String get docsGettingStartedGuestBookingContent => 'Não quer baixar o app? Prestadores de serviços podem compartilhar um link de reserva - você pode reservar e pagar diretamente através desse link sem criar uma conta. Seus detalhes de reserva e recibo serão enviados para WhatsApp.';

  @override
  String get docsGettingStartedOption2Title => 'Opção 2: Oferecer serviços (Proprietário de loja ou Freelancer)';

  @override
  String get docsGettingStartedOption2Content => 'Crie um perfil de loja ou freelancer, liste seus serviços com preços e duração, defina seus horários de trabalho e gerencie reservas. Ganhe dinheiro com cada serviço reservado.';

  @override
  String get docsGettingStartedOption3Title => 'Opção 3: Vender produtos (Vendedor de produtos)';

  @override
  String get docsGettingStartedOption3Content => 'Se você fabrica itens artesanais ou vende produtos de varejo, você pode listá-los à venda. Clientes navegam e compram diretamente de sua loja.';

  @override
  String get docsGettingStartedBookingPaymentTitle => 'Sistema de reserva e pagamento';

  @override
  String get docsGettingStartedBookingPaymentSubtitle => 'Como funcionam reservas de serviços e pagamentos';

  @override
  String get docsGettingStartedBookingOverviewContent => 'Clientes reservam compromissos com prestadores de serviços. Pagamentos são processados com segurança através do app usando Paystack (África) ou Stripe (Global).';

  @override
  String get docsGettingStartedDepositPaymentTitle => 'Depósito (30%)';

  @override
  String get docsGettingStartedDepositPaymentContent => 'Ao reservar um serviço, clientes pagam 30% antecipadamente como depósito para garantir o horário. Isso confirma que a reserva é real e está reservada.';

  @override
  String get docsGettingStartedPlatformFeeTitle => 'Taxa de plataforma';

  @override
  String get docsGettingStartedPlatformFeeContent => 'Uma pequena taxa de plataforma (2%) é adicionada para nos ajudar a manter a plataforma e fornecer suporte. Ela é calculada sobre o valor total da reserva.';

  @override
  String get docsGettingStartedRemainingPaymentTitle => 'Pagamento restante (70%)';

  @override
  String get docsGettingStartedRemainingPaymentContent => 'Os 70% restantes podem ser pagos de duas formas: (1) em dinheiro quando o serviço for concluído, ou (2) online através do app antes do compromisso.';

  @override
  String get docsGettingStartedGuestBookingPaymentTitle => 'Pagamento de reserva de convidado';

  @override
  String get docsGettingStartedGuestBookingPaymentContent => 'Sem necessidade de download do app! Clientes recebem um link de reserva do prestador de serviços. Eles pagam 30% para garantir o horário, e seu recibo é enviado para WhatsApp.';

  @override
  String get docsGettingStartedProductOrderingTitle => 'Pedido e entrega de produtos';

  @override
  String get docsGettingStartedProductOrderingSubtitle => 'Como funciona a venda de produtos';

  @override
  String get docsGettingStartedProductOverviewContent => 'Clientes navegam por produtos, adicionam itens ao carrinho e concluem o checkout. Produtos são entregues na localização do cliente.';

  @override
  String get docsGettingStartedCODPaymentTitle => 'Pagamento na entrega (COD)';

  @override
  String get docsGettingStartedCODPaymentContent => 'Para pedidos de produtos, o pagamento é feito como pagamento na entrega. Clientes pagam o vendedor quando recebem os itens - sem pagamento antecipado necessário.';

  @override
  String get docsGettingStartedShareYourProfileTitle => 'Compartilhe seu perfil';

  @override
  String get docsGettingStartedShareYourProfileSubtitle => 'Facilite para os clientes encontrarem você';

  @override
  String get docsGettingStartedShareLinkContent => 'Como prestador de serviços, você recebe um link de reserva único. Compartilhe-o no WhatsApp, redes sociais ou email. Clientes podem reservar serviços sem baixar o app.';

  @override
  String get docsGettingStartedCustomURLTitle => 'URL personalizada (opcional)';

  @override
  String get docsGettingStartedCustomURLContent => 'Você pode personalizar seu slug de link de reserva (por ex. aura.in/glamour-salon em vez de aura.in/abc123). Facilita compartilhar e lembrar.';

  @override
  String get docsGettingStartedGetHelpTitle => 'Obtenha ajuda';

  @override
  String get docsGettingStartedGetHelpSubtitle => 'Onde encontrar respostas';

  @override
  String get docsGettingStartedHelpDocumentationContent => 'Este app tem documentação completa para cada recurso. Quando você precisar de ajuda, consulte o guia relevante - há um para seu papel e o recurso que você está usando.';

  @override
  String get docsGettingStartedFAQ1Question => 'O que é Aura In?';

  @override
  String get docsGettingStartedFAQ1Answer => 'Aura In é um marketplace móvel para negócios baseados em serviços. Clientes encontram e reservam serviços (cortes de cabelo, massagens, etc.), prestadores de serviços gerenciam reservas e receita, e vendedores de produtos listam itens à venda.';

  @override
  String get docsGettingStartedFAQ2Question => 'Preciso pagar para usar o app?';

  @override
  String get docsGettingStartedFAQ2Answer => 'O app é gratuito para baixar e usar. Prestadores de serviços pagam apenas uma pequena comissão quando clientes pagam por serviços. Processadores de pagamento (Paystack/Stripe) cobram uma taxa.';

  @override
  String get docsGettingStartedFAQ3Question => 'Qual é a diferença entre proprietário de loja e freelancer?';

  @override
  String get docsGettingStartedFAQ3Answer => 'Proprietários de lojas têm um local fixo com uma equipe de trabalhadores. Freelancers trabalham de forma independente e podem se deslocar até os clientes. Escolha com base em seu modelo de negócio.';

  @override
  String get docsGettingStartedFAQ4Question => 'Como sou pago?';

  @override
  String get docsGettingStartedFAQ4Answer => 'Quando clientes pagam por serviços, o dinheiro vai para sua carteira. Você pode sacar para sua conta bancária usando Paystack (África) ou Stripe (Global).';

  @override
  String get docsGettingStartedFAQ5Question => 'Minhas informações de pagamento são seguras?';

  @override
  String get docsGettingStartedFAQ5Answer => 'Sim. Aura In usa Paystack e Stripe, processadores de pagamento líderes com segurança em nível bancário. Nunca vemos seus detalhes de pagamento.';

  @override
  String get docsGettingStartedFAQ6Question => 'Como sei se prestadores de serviços perto de mim são confiáveis?';

  @override
  String get docsGettingStartedFAQ6Answer => 'Todo prestador de serviços tem avaliações e comentários de clientes que reservaram com eles. Leia os comentários antes de reservar. Avaliações altas significam serviço consistente e de qualidade.';

  @override
  String get docsGettingStartedFAQ7Question => 'Posso reservar sem baixar o app?';

  @override
  String get docsGettingStartedFAQ7Answer => 'Sim! Prestadores de serviços compartilham um link de reserva único. Você pode reservar diretamente através desse link sem baixar o app. Seu recibo será enviado para WhatsApp.';

  @override
  String get docsGettingStartedFAQ8Question => 'Quanto pago antecipadamente para reservas?';

  @override
  String get docsGettingStartedFAQ8Answer => 'Você paga 30% do valor total do serviço antecipadamente para garantir o horário da reserva (mais uma taxa de plataforma de 2%). Os 70% restantes podem ser pagos em dinheiro ou online antes/no momento do serviço.';

  @override
  String get docsGettingStartedFAQ9Question => 'Como pago por produtos?';

  @override
  String get docsGettingStartedFAQ9Answer => 'Produtos usam pagamento na entrega (COD). Você paga o vendedor quando recebe os itens. Isso permite verificar a qualidade antes de pagar e funciona bem para entregas locais.';

  @override
  String get docsGettingStartedFAQ10Question => 'Por que a taxa de plataforma de 2%?';

  @override
  String get docsGettingStartedFAQ10Answer => 'A taxa de plataforma nos ajuda a manter Aura In, processar pagamentos, fornecer suporte ao cliente e melhorar continuamente os recursos para clientes e prestadores de serviços.';

  @override
  String get docsBookingStartedTitle => 'Primeiros passos com reservas';

  @override
  String get docsBookingStartedSubtitle => 'Um guia simples para entender como funcionam as reservas';

  @override
  String get docsBookingIntroTitle => 'Bem-vindo ao sistema de reservas';

  @override
  String get docsBookingIntroSubtitle => 'Tudo o que você precisa saber sobre reservar serviços, seja como cliente ou como proprietário de loja.';

  @override
  String get docsBookingWhatIsTitle => 'O que é o sistema de reservas?';

  @override
  String get docsBookingWhatIsContent => 'O sistema de reservas é seu portal para agendar serviços em suas lojas favoritas. Quer você precise de um corte de cabelo, aparar a barba, tranças ou qualquer outro serviço, o sistema facilita o agendamento de consultas no seu tempo.';

  @override
  String get docsBookingWhoIsForTitle => 'Para quem é este guia?';

  @override
  String get docsBookingWhoIsForContent => 'Este guia foi desenvolvido para dois tipos de usuários:';

  @override
  String get docsBookingWhoIsForClients => 'Clientes: Pessoas que desejam reservar serviços em lojas';

  @override
  String get docsBookingWhoIsForGuests => 'Reservadores de hóspedes: Pessoas que desejam reservar via link sem criar uma conta';

  @override
  String get docsBookingWhoIsForOwners => 'Proprietários de lojas: Pessoas que gerenciam lojas, serviços e funcionários';

  @override
  String get docsBookingGuestIntroTitle => 'Novo: Reservar sem baixar o app';

  @override
  String get docsBookingGuestIntroContent => 'Sem conta? Sem problema! Se um proprietário de loja compartilhar um link de reserva com você, poderá reservar diretamente sem baixar o app. Seu recibo é enviado para WhatsApp.';

  @override
  String get docsBookingWelcomeTip => 'Nenhum conhecimento técnico necessário! Este guia usa linguagem simples e exemplos reais para ajudá-lo a entender tudo.';

  @override
  String get docsBookingAccountTitle => 'Crie sua conta (ou reserve como hóspede)';

  @override
  String get docsBookingAccountSubtitle => 'Comece em minutos - com ou sem conta';

  @override
  String get docsBookingTwoWaysTitle => 'Duas formas de reservar';

  @override
  String get docsBookingTwoWaysContent => 'Você pode reservar de duas formas:';

  @override
  String get docsBookingTwoWaysAccount => 'Com conta: Baixe o app, crie conta, reserve a qualquer momento';

  @override
  String get docsBookingTwoWaysGuest => 'Como hóspede: Use link de reserva, nenhum app necessário, recibo via WhatsApp';

  @override
  String get docsBookingAccountStepsTitle => 'Como criar uma conta';

  @override
  String get docsBookingAccountStepsContent => 'Siga estes passos simples para criar sua conta:';

  @override
  String get docsBookingAccountTypesTitle => 'Tipos de conta';

  @override
  String get docsBookingAccountTypesContent => 'Existem dois tipos de conta:';

  @override
  String get docsBookingAccountTypesClient => 'Conta de cliente: Para reservar serviços em lojas';

  @override
  String get docsBookingAccountTypesShop => 'Conta de proprietário de loja: Para gerenciar sua própria loja (requer aprovação)';

  @override
  String get docsBookingGuestOptionTitle => 'Reserve como hóspede (sem conta)';

  @override
  String get docsBookingGuestOptionContent => 'Se alguém compartilhar um link de reserva com você, poderá reservar diretamente sem criar uma conta. Basta clicar no link e seguir as etapas. Seu recibo é enviado para seu WhatsApp.';

  @override
  String get docsBookingVerificationNote => 'Você pode procurar e reservar sem uma conta usando um link de reserva. Criar uma conta dá acesso ao histórico de reservas, pagamentos salvos e recompensas de fidelidade.';

  @override
  String get docsBookingFirstBookingTitle => 'Sua primeira reserva';

  @override
  String get docsBookingFirstBookingSubtitle => 'Uma visão geral rápida';

  @override
  String get docsBookingPaymentTitle => 'Como funciona o pagamento';

  @override
  String get docsBookingPaymentContent => 'Quando você reserva um serviço, é assim que o pagamento funciona:';

  @override
  String get docsBookingPaymentDeposit => 'Depósito de 30% necessário: Para garantir sua reserva, você paga 30% do custo total do serviço antecipadamente';

  @override
  String get docsBookingPaymentNonRefundable => 'Não reembolsável: Este depósito não é reembolsado se você cancelar ou não aparecer';

  @override
  String get docsBookingPaymentRemaining => 'Saldo restante: Os 70% restantes são pagos após a conclusão do seu serviço';

  @override
  String get docsBookingPaymentSecure => 'Pagamento seguro: Todos os pagamentos são processados com segurança pelos nossos parceiros de pagamento';

  @override
  String get docsBookingDepositNote => 'O depósito de 30% o protege e protege a loja. Garante que seu horário seja reservado exclusivamente para você e compensa o funcionário se você cancelar no último momento.';

  @override
  String get docsBookingBookingTip => 'Dica profissional: Reserve pelo menos 24 horas antes para obter a melhor seleção de horários, especialmente para serviços populares.';

  @override
  String get docsBookingAfterTitle => 'Após sua reserva';

  @override
  String get docsBookingAfterSubtitle => 'O que acontece a seguir';

  @override
  String get docsBookingWhatsNextTitle => 'Sua reserva está confirmada!';

  @override
  String get docsBookingWhatsNextContent => 'Aqui está o que você pode fazer após a reserva:';

  @override
  String get docsBookingRemindersTitle => 'Lembretes de reserva';

  @override
  String get docsBookingRemindersContent => 'Você receberá lembretes em:';

  @override
  String get docsBookingAfterServiceTitle => 'Após seu serviço';

  @override
  String get docsBookingAfterServiceContent => 'Uma vez que seu serviço seja concluído:';

  @override
  String get docsPaymentTitle => 'Pagamento e taxas explicados';

  @override
  String get docsPaymentSubtitle => 'Como funcionam depósitos de 30%, taxas de plataforma e reservas de hóspedes';

  @override
  String get docsPaymentOverviewTitle => 'Como funciona o pagamento';

  @override
  String get docsPaymentOverviewSubtitle => 'Simples, transparente, seguro';

  @override
  String get docsPaymentSummaryTitle => 'Pagamento em um relance';

  @override
  String get docsPaymentSummaryContent => 'Nosso sistema de pagamento foi projetado para ser justo para clientes e proprietários de lojas. Aqui está o resumo simples:';

  @override
  String get docsPaymentDeposit30 => 'Depósito de 30%: Pago na reserva para garantir seu compromisso';

  @override
  String get docsPaymentPlatformFee => 'Taxa de plataforma: Pequena taxa fixa (ex. GHS 2) cobrada pelo app';

  @override
  String get docsPaymentRemaining70 => '70% restantes: Pagos após a conclusão do seu serviço';

  @override
  String get docsPaymentTwoWays => 'Duas formas de pagar o restante: Dinheiro ou via app';

  @override
  String get docsPaymentQuickExampleTitle => 'Exemplo rápido';

  @override
  String get docsPaymentQuickExampleContent => 'Custo do serviço: GHS 100\nNa reserva: Pague GHS 30 (depósito) + GHS 2 (taxa) = GHS 32\nApós o serviço: Pague GHS 70 (dinheiro ou app)\nTotal para a loja: GHS 100\nTaxa de plataforma: GHS 2';

  @override
  String get docsPaymentImportantNote => 'A taxa de plataforma é cobrada pelo app, não pela loja. Nos ajuda a manter a plataforma e oferecer uma ótima experiência de reserva.';

  @override
  String get docsPaymentGuestBookingTitle => 'Reserva de hóspede (sem download do app)';

  @override
  String get docsPaymentGuestBookingContent => 'Não tem o app? Sem problema! Você ainda pode reservar através do link de reserva do seu provedor sem criar uma conta. Você paga o mesmo depósito de 30% + taxa de plataforma, e seu recibo é enviado para WhatsApp.';

  @override
  String get docsDepositTitle => 'O depósito de 30%';

  @override
  String get docsDepositSubtitle => 'Por que é necessário e como funciona';

  @override
  String get docsDepositWhyTitle => 'Por que exigimos um depósito?';

  @override
  String get docsDepositWhyContent => 'O depósito de 30% o protege e protege a loja:';

  @override
  String get docsDepositProtectsYou => 'Para você: Seu horário é garantido – ninguém mais pode reservá-lo';

  @override
  String get docsDepositProtectsShop => 'Para a loja: Os funcionários são compensados se você cancelar no último minuto';

  @override
  String get docsDepositProtectsEveryone => 'Para todos: Reduz faltas, mantendo os preços justos';

  @override
  String get docsDepositCalcTitle => 'Como o depósito é calculado';

  @override
  String get docsDepositCalcContent => 'O depósito é sempre 30% do custo total do serviço. Isso inclui:';

  @override
  String get docsDepositCalcSingle => 'Serviço único: 30% desse preço de serviço';

  @override
  String get docsDepositCalcMultiple => 'Múltiplos serviços: 30% de todos os serviços combinados';

  @override
  String get docsDepositCalcGroup => 'Reservas em grupo: 30% do total para todas as pessoas';

  @override
  String get docsDepositExamplesTitle => 'Exemplos de depósito';

  @override
  String get docsDepositExamplesSingle => 'Serviço único:\nCorte de cabelo (GHS 45) → Depósito GHS 13,50';

  @override
  String get docsDepositExamplesMultiple => 'Múltiplos serviços:\nCorte de cabelo (GHS 45) + Aparador de barba (GHS 25) = GHS 70 total\nDepósito: GHS 21';

  @override
  String get docsDepositExamplesGroup => 'Reserva em grupo (3 pessoas):\n3 × Corte de cabelo (GHS 45 cada) = GHS 135 total\nDepósito: GHS 40,50';

  @override
  String get docsDepositRefundTitle => 'Política de reembolso de depósito';

  @override
  String get docsDepositRefundContent => 'O depósito de 30% não é reembolsável. Isso significa:';

  @override
  String get docsDepositRefundCancel => 'Se você cancelar: O depósito não é devolvido';

  @override
  String get docsDepositRefundNoShow => 'Se você não aparecer: O depósito não é devolvido';

  @override
  String get docsDepositRefundReschedule => 'Se você reagendar: O depósito é transferido para o novo horário';

  @override
  String get docsDepositRefundShop => 'Se a loja cancelar: Depósito completo reembolsado';

  @override
  String get docsDepositWarning => 'Certifique-se de que tem certeza sobre sua reserva antes de pagar o depósito. Embora você possa reagendar, o depósito não pode ser reembolsado se você cancelar.';

  @override
  String get docsFeeTitle => 'Taxa de plataforma';

  @override
  String get docsFeeSubtitle => 'A pequena taxa que mantém o app funcionando';

  @override
  String get docsFeeWhatTitle => 'O que é a taxa de plataforma?';

  @override
  String get docsFeeWhatContent => 'A taxa de plataforma é uma pequena cobrança fixa (ex. GHS 2) que vai para o app, não para a loja. Ela cobre:';

  @override
  String get docsFeeAppDev => 'Desenvolvimento e manutenção do app';

  @override
  String get docsFeeSupport => 'Suporte ao cliente e resolução de disputas';

  @override
  String get docsFeeProcessing => 'Custos de processamento de pagamento';

  @override
  String get docsFeeFeatures => 'Novos recursos e melhorias';

  @override
  String get docsFeeHowTitle => 'Como a taxa é cobrada';

  @override
  String get docsFeeHowContent => 'Coisas importantes a saber sobre a taxa de plataforma:';

  @override
  String get docsFeeFixed => 'Valor fixo (não uma porcentagem) – ex. GHS 2 por reserva';

  @override
  String get docsFeePerbooking => 'Cobrada uma vez por reserva – não por serviço ou pessoa';

  @override
  String get docsFeeNonRefundable => 'Não reembolsável – mesmo se você cancelar';

  @override
  String get docsFeeShown => 'Claramente exibida antes de confirmar o pagamento';

  @override
  String get docsFeeExamplesTitle => 'Exemplos de taxa de plataforma';

  @override
  String get docsFeeExamplesSingle => 'Uma pessoa, um serviço: Taxa GHS 2';

  @override
  String get docsFeeExamplesMultiple => 'Uma pessoa, múltiplos serviços: Taxa GHS 2 (ainda uma reserva!)';

  @override
  String get docsFeeExamplesGroup => 'Família de 4 reservando juntos: Taxa GHS 2 (grupo inteiro)';

  @override
  String get docsFeeExamplesSeparate => 'Compare com reservas separadas:\n4 reservas separadas = 4 × GHS 2 = GHS 8 em taxas\n1 reserva em grupo = Taxa GHS 2 – você economiza GHS 6!';

  @override
  String get docsFeeGroupTip => 'Reservar em grupo economiza taxas! Em vez de pagar a taxa de plataforma para cada pessoa, você paga apenas uma taxa para toda a reserva em grupo.';

  @override
  String get docsPaymentRemainingTitle => 'Pagamento dos 70% restantes';

  @override
  String get docsPaymentRemainingSubtitle => 'Dinheiro ou online - sua escolha';

  @override
  String get docsPaymentRemainingOptionsTitle => 'Duas opções de pagamento';

  @override
  String get docsPaymentRemainingOptionsContent => 'Após a conclusão do seu serviço, você tem duas formas de pagar os 70% restantes:';

  @override
  String get docsPaymentCashOption => 'Dinheiro: Pague diretamente à loja ou ao funcionário';

  @override
  String get docsPaymentAppOption => 'Via app: Pague através do app usando seu método de pagamento salvo';

  @override
  String get docsPaymentRemainingTip => 'Ambos os métodos de pagamento são igualmente válidos. Escolha o que for mais conveniente para você no momento do serviço.';

  @override
  String get docsCancellationTitle => 'Cancelamentos e reembolsos';

  @override
  String get docsCancellationSubtitle => 'O que acontece se você precisar cancelar';

  @override
  String get docsCancellationInfoTitle => 'Política de cancelamento';

  @override
  String get docsCancellationInfoContent => 'Entenda o que acontece quando você cancela:';

  @override
  String get docsCancellationUpTo24 => 'Cancelar até 24 horas antes: O depósito e a taxa não são reembolsáveis';

  @override
  String get docsCancellationLessThan24 => 'Cancelar menos de 24 horas antes: Mesma política – depósito e taxa não reembolsáveis';

  @override
  String get docsCancellationReschedule => 'Reagendar em vez disso: Seu depósito é transferido para o novo horário (gratuito para reagendar)';

  @override
  String get docsCancellationNoShow => 'Não aparecer: Depósito e taxa perdidos, e pode afetar o status da sua conta';

  @override
  String get docsHowToBookTitle => 'Como reservar serviços';

  @override
  String get docsHowToBookSubtitle => 'Um guia passo a passo para reservar seus compromissos';

  @override
  String get docsHowToBookOverviewTitle => 'Reserva em um relance';

  @override
  String get docsHowToBookOverviewSubtitle => 'O processo de reserva em etapas simples';

  @override
  String get docsHowToBookTwoWaysTitle => 'Duas formas de reservar';

  @override
  String get docsHowToBookTwoWaysContent => 'Você pode reservar de duas formas:';

  @override
  String get docsHowToBookTwoWaysWithApp => 'Com conta de app: Baixe o app, crie conta, reserve a qualquer momento';

  @override
  String get docsHowToBookTwoWaysGuest => 'Como hóspede: Use link de reserva, nenhum app, recibo via WhatsApp';

  @override
  String get docsHowToBookStepsTitle => 'Sua jornada de reserva (Com conta)';

  @override
  String get docsHowToBookStepsContent => 'Reservar um serviço leva apenas alguns minutos. Aqui está o que você fará:';

  @override
  String get docsHowToBookStep1 => 'Etapa 1: Encontre uma loja e explore serviços';

  @override
  String get docsHowToBookStep2 => 'Etapa 2: Selecione seus serviços e quantidades';

  @override
  String get docsHowToBookStep3 => 'Etapa 3: Escolha seu funcionário preferido (se disponível)';

  @override
  String get docsHowToBookStep4 => 'Etapa 4: Escolha uma data e hora';

  @override
  String get docsHowToBookStep5 => 'Etapa 5: Pague depósito de 30% + pequena taxa para confirmar';

  @override
  String get docsHowToBookStep6 => 'Etapa 6: Após o serviço, pague os 70% restantes em dinheiro ou via app';

  @override
  String get docsHowToBookGuestTitle => 'Reserva de hóspede (sem app)';

  @override
  String get docsHowToBookGuestContent => 'Você não tem o app? Se uma loja compartilhar um link de reserva com você, siga os passos acima, mas sem precisar criar uma conta. Sua confirmação e recibo vão para seu WhatsApp.';

  @override
  String get docsHowToBookTimeTip => 'Todo o processo geralmente leva menos de 2 minutos. Seu progresso é salvo conforme você avança, então você pode se dedicar ao seu tempo.';

  @override
  String get docsBookingStep1Title => 'Etapa 1: Encontre sua loja e serviços';

  @override
  String get docsBookingStep1Subtitle => 'Descubra o lugar perfeito para suas necessidades';

  @override
  String get docsBookingFindShopTitle => 'Como encontrar uma loja';

  @override
  String get docsBookingFindShopContent => 'Você pode encontrar lojas de várias maneiras:';

  @override
  String get docsBookingFindShopHome => 'Tela inicial: Procure lojas recomendadas perto de você';

  @override
  String get docsBookingFindShopSearch => 'Pesquisa: Procure lojas ou serviços específicos por nome';

  @override
  String get docsBookingFindShopCategories => 'Categorias: Filtre por tipo de serviço (Corte, Tranças, Barba, etc.)';

  @override
  String get docsBookingFindShopFavorites => 'Favoritos: Acesso rápido a lojas que você salvou';

  @override
  String get docsBookingBrowseServicesTitle => 'Procurar serviços';

  @override
  String get docsBookingBrowseServicesContent => 'Depois de selecionar uma loja, você verá todos os seus serviços disponíveis. Cada serviço mostra:';

  @override
  String get docsBookingServiceName => 'Nome do serviço (ex., Corte Afro, Tranças Box)';

  @override
  String get docsBookingServiceDuration => 'Duração (quanto tempo leva)';

  @override
  String get docsBookingServicePrice => 'Preço (custo do serviço - vai para a loja)';

  @override
  String get docsBookingServiceDescription => 'Descrição (o que está incluído)';

  @override
  String get docsBookingServiceWorker => 'Requisito de funcionário (se você pode escolher quem faz)';

  @override
  String get docsBookingServiceExampleTitle => 'Exemplo';

  @override
  String get docsBookingServiceExampleContent => 'Serviço de corte de cabelo:\n• Nome: Corte Afro\n• Duração: 1 hora\n• Preço: GHS 45 (pago à loja)\n• Descrição: Corte afro profissional com penteado\n• Funcionário: Você pode escolher seu barbeiro preferido';

  @override
  String get docsBookingStep2Title => 'Etapa 2: Selecione seus serviços';

  @override
  String get docsBookingStep2Subtitle => 'Escolha o que você deseja e quantas pessoas';

  @override
  String get docsBookingSelectServicesTitle => 'Seleção de serviços';

  @override
  String get docsBookingSelectServicesContent => 'Para selecionar um serviço, simplesmente toque nele. Você o verá destacado. Você pode selecionar múltiplos serviços de uma vez:';

  @override
  String get docsBookingSelectServicesTap => 'Toque em um serviço para selecioná-lo';

  @override
  String get docsBookingSelectServicesCheckmark => 'Serviços selecionados mostram uma marca de seleção';

  @override
  String get docsBookingSelectServicesMultiple => 'Você pode selecionar múltiplos serviços (ex., Corte + Aparador de barba)';

  @override
  String get docsBookingSelectServicesDeselect => 'Toque novamente para desselecionar';

  @override
  String get docsBookingGroupBookingTitle => 'Reserva para múltiplas pessoas';

  @override
  String get docsBookingGroupBookingContent => 'Se você está reservando para um grupo (como você e seus filhos), você pode aumentar a quantidade:';

  @override
  String get docsBookingGroupBookingQuantity => 'Depois de selecionar um serviço, você verá um botão + e -';

  @override
  String get docsBookingGroupBookingIncrease => 'Toque em + para aumentar o número de pessoas';

  @override
  String get docsBookingGroupBookingPrice => 'O preço atualiza automaticamente';

  @override
  String get docsBookingGroupBookingLimit => 'Quantidade máxima é mostrada (alguns serviços têm limites)';

  @override
  String get docsBookingGroupExampleTitle => 'Exemplo: Reserva familiar';

  @override
  String get docsBookingGroupExampleContent => 'Pai quer cortes de cabelo para ele e seus dois filhos:\n• Selecione o serviço \"Corte de cabelo\"\n• Toque em + até que a quantidade mostre 3\n• O preço total mostra 3 × GHS 45 = GHS 135 (para a loja)\n• Você escolherá funcionários para cada pessoa depois';

  @override
  String get docsBookingQuantityTip => 'O recurso de quantidade é perfeito para famílias, grupos de amigos ou qualquer pessoa que reserve para várias pessoas de uma vez.';

  @override
  String get docsGroupBookingsTitle => 'Reservas em grupo';

  @override
  String get docsGroupBookingsSubtitle => 'Como reservar serviços para você e outros';

  @override
  String get docsGroupIntroTitle => 'O que são reservas em grupo?';

  @override
  String get docsGroupIntroSubtitle => 'Reserva para família, amigos ou grupos simplificada';

  @override
  String get docsGroupExplainedTitle => 'Reserva para múltiplas pessoas';

  @override
  String get docsGroupExplainedContent => 'As reservas em grupo permitem que você reserve serviços para mais de uma pessoa por vez. Isso é perfeito para:';

  @override
  String get docsGroupExplainedFamilies => 'Famílias: Pais reservando cortes de cabelo para si mesmos e seus filhos';

  @override
  String get docsGroupExplainedFriends => 'Amigos: Grupo de amigos obtendo serviços juntos';

  @override
  String get docsGroupExplainedEvents => 'Eventos: Festas nupciais, aniversários ou ocasiões especiais';

  @override
  String get docsGroupExplainedColleagues => 'Colegas: Team building ou saídas de trabalho';

  @override
  String get docsGroupRealExampleTitle => 'Exemplo da vida real';

  @override
  String get docsGroupRealExampleContent => 'A família Mensah precisa de cortes de cabelo:\n• Pai: Quer um corte fade\n• Mãe: Quer um corte\n• Filho (10): Quer um corte infantil\n• Filha (8): Quer tranças\n\nEm vez de fazer 4 reservas separadas, eles podem reservar tudo junto de uma vez!';

  @override
  String get docsGroupBenefitsTitle => 'Benefícios da reserva em grupo';

  @override
  String get docsGroupBenefitsContent => 'Reservar como grupo lhe dá:';

  @override
  String get docsGroupBenefitsTransaction => 'Uma transação: Pague depósitos para todos de uma vez';

  @override
  String get docsGroupBenefitsTiming => 'Horário coordenado: Todos recebem o serviço mais ou menos na mesma hora';

  @override
  String get docsGroupBenefitsWorkers => 'Diferentes funcionários: Cada pessoa pode escolher seu funcionário preferido';

  @override
  String get docsGroupBenefitsManagement => 'Gerenciamento simplificado: Visualize e gerencie todas as reservas juntas';

  @override
  String get docsGroupBenefitsPlanning => 'Melhor planejamento: A loja pode se preparar para seu grupo';

  @override
  String get docsGroupTip => 'As reservas em grupo são perfeitas para famílias! Você pode reservar para você e seus filhos de uma vez, escolhendo diferentes funcionários para cada pessoa. Sem conta? Use um link de reserva compartilhado pela loja!';

  @override
  String get docsGroupHowTitle => 'Como fazer uma reserva em grupo';

  @override
  String get docsGroupHowSubtitle => 'Guia passo a passo';

  @override
  String get docsGroupStep1Title => 'Etapa 1: Selecione seu serviço';

  @override
  String get docsGroupStep1Content => 'Comece encontrando uma loja e selecionando o serviço desejado. Por exemplo, toque em \"Corte de cabelo\".';

  @override
  String get docsGroupStep2Title => 'Etapa 2: Escolha a quantidade';

  @override
  String get docsGroupStep2Content => 'Depois de selecionar um serviço, você verá os botões + e -. Use-os para definir quantas pessoas precisam deste serviço:';

  @override
  String get docsGroupStep2Plus => 'Toque em + para aumentar o número';

  @override
  String get docsGroupStep2Minus => 'Toque em - para diminuir';

  @override
  String get docsGroupStep2Price => 'O preço é atualizado automaticamente';

  @override
  String get docsGroupStep2Max => 'Você não pode exceder a quantidade máxima mostrada';

  @override
  String get docsGroupStep2ExampleTitle => 'Exemplo';

  @override
  String get docsGroupStep2ExampleContent => 'Para uma família de 3 que precisa de cortes de cabelo:\n• Selecione o serviço \"Corte de cabelo\"\n• Toque em + duas vezes (ou até que a quantidade mostre 3)\n• O preço total mostra: 3 × GHS 45 = GHS 135';

  @override
  String get docsGroupStep3Title => 'Etapa 3: Repita para cada serviço';

  @override
  String get docsGroupStep3Content => 'Se seu grupo precisar de serviços diferentes (por exemplo, alguns querem cortes, outros querem tranças), selecione cada serviço e defina a quantidade para cada:';

  @override
  String get docsGroupStep3Haircut => 'Selecione \"Corte de cabelo\" → defina quantidade 2';

  @override
  String get docsGroupStep3Braids => 'Selecione \"Tranças\" → defina quantidade 1';

  @override
  String get docsGroupStep3Track => 'O sistema rastreia todas as seleções';

  @override
  String get docsGroupStep3ExampleTitle => 'Exemplo: Serviços mistos';

  @override
  String get docsGroupStep3ExampleContent => 'Família de 4 com necessidades diferentes:\n• Pai: Corte de cabelo (quantidade 1)\n• Mãe: Corte (quantidade 1)\n• Filho: Corte infantil (quantidade 1)\n• Filha: Tranças (quantidade 1)\n\nTotal: 4 serviços, mas você os reservou todos de uma vez!';

  @override
  String get docsGroupStep4Title => 'Etapa 4: Escolha os funcionários para cada pessoa';

  @override
  String get docsGroupStep4Content => 'Para serviços que permitem escolher funcionários, você verá uma lista de pessoas. Toque em cada pessoa para atribuir seu funcionário:';

  @override
  String get docsGroupStep4Person1 => 'Pessoa 1: Escolha John (especialista em fade)';

  @override
  String get docsGroupStep4Person2 => 'Pessoa 2: Escolha Sarah (especialista em tranças)';

  @override
  String get docsGroupStep4Person3 => 'Pessoa 3: Escolha Michael (cortes infantis)';

  @override
  String get docsGroupStep4Person4 => 'Pessoa 4: Escolha John (mesmo funcionário para múltiplas pessoas)';

  @override
  String get docsGroupStep4ExampleTitle => 'Exemplo: Diferentes funcionários para diferentes pessoas';

  @override
  String get docsGroupStep4ExampleContent => 'Família de 3 reservando cortes de cabelo:\n• Pessoa 1 (Pai): Escolha John (especialista em fade)\n• Pessoa 2 (Filho): Escolha Michael (ótimo com crianças)\n• Pessoa 3 (Filha): Escolha Sarah (especialista em tranças)\n\nTodos os três serão atendidos durante seu bloco de compromisso.';

  @override
  String get docsGroupStep5Title => 'Etapa 5: Escolha seu horário';

  @override
  String get docsGroupStep5Content => 'Quando você seleciona uma data e hora, o sistema mostra slots que podem acomodar TODAS as pessoas do seu grupo:';

  @override
  String get docsGroupStep5Regular => 'Visualização normal: Mostra slots para cada serviço separadamente';

  @override
  String get docsGroupStep5Combined => 'Visualização combinada: Mostra apenas slots onde todos podem ser atendidos juntos';

  @override
  String get docsGroupStep5Duration => 'Duração: O horário mostrado inclui todos os serviços para todas as pessoas';

  @override
  String get docsGroupStep5ExampleTitle => 'Exemplo: Cálculo de tempo';

  @override
  String get docsGroupStep5ExampleContent => 'Reserva familiar:\n• Corte de cabelo (45 min) × 2 pessoas = 90 min\n• Tranças (2 horas) × 1 pessoa = 120 min\n• Tempo de buffer entre serviços = 15 min\n• Tempo total de compromisso: 3 horas 45 minutos\n\nO sistema cuida de tudo isso automaticamente!';

  @override
  String get docsGroupStep6Title => 'Etapa 6: Pagamento';

  @override
  String get docsGroupStep6Content => 'Para reservas em grupo, você paga:';

  @override
  String get docsGroupStep6Deposit => 'Depósito de 30%: Calculado no TOTAL de todos os serviços';

  @override
  String get docsGroupStep6Fee => 'Taxa de plataforma: Pequena taxa fixa (por exemplo, GHS 2) - cobrada UMA VEZ para todo o grupo';

  @override
  String get docsGroupStep6Remaining => '70% restantes: Pagos após a conclusão de todos os serviços';

  @override
  String get docsGroupStep6Options => 'Opções de pagamento: Dinheiro, cartão, dinheiro móvel ou pagamento via app';

  @override
  String get docsGroupStep6ExampleTitle => 'Exemplo de pagamento';

  @override
  String get docsGroupStep6ExampleContent => 'Total de reserva familiar: GHS 400\n• Depósito na reserva: GHS 120 (30% de GHS 400)\n• Taxa de plataforma: GHS 2 (cobrada UMA VEZ para todo o grupo)\n• Total a pagar agora: GHS 122\n• Restante após o serviço: GHS 280\n• Pagamento depois: Dinheiro para funcionário/loja OU via app (sua escolha)';

  @override
  String get docsGroupPaymentFlexibility => 'Múltiplas opções de pagamento';

  @override
  String get docsGroupPaymentFlexibilityContent => 'Pelos 70% restantes, você tem opções:';

  @override
  String get docsGroupPaymentFlexibilityAllCash => 'Tudo em dinheiro: Todos pagam em dinheiro quando o serviço é concluído';

  @override
  String get docsGroupPaymentFlexibilitySplit => 'Pagamentos divididos: Alguns pagam em dinheiro, outros pagam via app';

  @override
  String get docsGroupPaymentFlexibilityMixed => 'Mistura de dinheiro e app: Pague parte em dinheiro, parte via app';

  @override
  String get docsGroupPaymentFlexibilityIndividual => 'Pagamentos individuais via app: Cada pessoa paga via app';

  @override
  String get docsGroupPaymentFlexibilityTip => 'Escolha o que funciona melhor para seu grupo!';

  @override
  String get docsGroupImportant => 'O depósito e a taxa de plataforma são calculados na reserva de grupo TOTAL, não por pessoa. Você paga uma vez para todo o grupo.';

  @override
  String get docsCreateShopTitle => 'Crie Sua Loja';

  @override
  String get docsCreateShopSubtitle => 'Configure seu negócio';

  @override
  String get docsShopOverviewTitle => 'Primeiros passos com sua loja';

  @override
  String get docsShopOverviewSubtitle => 'Aprenda o básico sobre criar seu perfil de negócio';

  @override
  String get docsWelcomeIntroTitle => 'Bem-vindo ao seu painel de loja';

  @override
  String get docsWelcomeIntroContent => 'Criar uma loja no Aura In leva apenas alguns minutos. Você adicionará suas informações comerciais, definirá seus serviços e horários de trabalho, e estará pronto para aceitar reservas de clientes.';

  @override
  String get docsSetupStepsTitle => 'O que você vai configurar';

  @override
  String get docsSetupStepsContent => 'Aqui está o que você fará ao criar sua loja:';

  @override
  String get docsSetupStepsShopName => 'Adicione o nome e logotipo da sua loja';

  @override
  String get docsSetupStepsDescription => 'Escreva uma breve descrição do seu negócio';

  @override
  String get docsSetupStepsType => 'Escolha seu tipo de loja (salão, barbearia, spa, etc.)';

  @override
  String get docsSetupStepsLocation => 'Defina seu local e endereço de serviço';

  @override
  String get docsSetupStepsHours => 'Adicione seus horários de trabalho';

  @override
  String get docsSetupStepsServices => 'Crie serviços que oferece com preços';

  @override
  String get docsSetupStepsContact => 'Adicione informações de contato';

  @override
  String get docsSetupStepsPhotos => 'Carregue fotos e documentos';

  @override
  String get docsSetupTip => 'Seu trabalho é salvo automaticamente enquanto você preenche o formulário. Você pode voltar a qualquer momento para continuar editando ou publicar quando estiver pronto.';

  @override
  String get docsBasicInfoTitle => 'Informações básicas da loja';

  @override
  String get docsBasicInfoSubtitle => 'Diga aos clientes quem você é';

  @override
  String get docsLogoTitle => 'Adicione o logotipo da sua loja';

  @override
  String get docsLogoContent => 'Seu logotipo é a primeira coisa que os clientes veem. Deve representar claramente seu negócio. Use uma imagem quadrada (por exemplo, 500x500 pixels) para melhores resultados.';

  @override
  String get docsShopNameTitle => 'Nome da loja';

  @override
  String get docsShopNameContent => 'Digite o nome da sua empresa exatamente como deseja que os clientes o vejam. Seja claro e profissional. Exemplo: \"Estúdio de cabelo de Maria\" ou \"Barbearia da cidade\"';

  @override
  String get docsShopTypeTitle => 'Escolha seu tipo de loja';

  @override
  String get docsShopTypeContent => 'Selecione o tipo de negócio que você gerencia. Isso ajuda os clientes a encontrá-lo na pesquisa. Os tipos disponíveis incluem:';

  @override
  String get docsShopTypeSalon => 'Salão de beleza - para cortes de cabelo, coloração, estilo';

  @override
  String get docsShopTypeBarber => 'Barbearia - para cortes de cabelo masculino e grooming';

  @override
  String get docsShopTypeSpa => 'Spa - para massagens, faciais, serviços de bem-estar';

  @override
  String get docsShopTypeBeauty => 'Serviços de beleza - maquiagem, unhas e outros tratamentos de beleza';

  @override
  String get docsShopTypeOther => 'Outros serviços - para negócios não listados acima';

  @override
  String get docsDescriptionTitle => 'Descrição da loja';

  @override
  String get docsDescriptionContent => 'Escreva uma breve descrição de sua loja (100-200 palavras). Diga aos clientes o que o torna especial. Exemplo: \"Nos especializamos em cuidados naturais de cabelo e estilo moderno para todos os tipos de cabelo. Ambiente familiar com estilistas profissionais.\"';

  @override
  String get docsTermsTitle => 'Termos e condições';

  @override
  String get docsTermsContent => 'Adicione as regras importantes que os clientes devem conhecer. Exemplos: política de cancelamento, restrições de idade, requisitos de depósito, código de vestimenta ou restrições de saúde.';

  @override
  String get docsLocationTitle => 'Local e horas';

  @override
  String get docsLocationSubtitle => 'Onde os clientes podem encontrá-lo e quando você trabalha';

  @override
  String get docsLocationIntroTitle => 'Defina seu local';

  @override
  String get docsLocationIntroContent => 'Os clientes precisam saber onde encontrá-lo. Você pode:';

  @override
  String get docsLocationPin => 'Marque seu local no mapa (arraste o marcador)';

  @override
  String get docsLocationSearch => 'Pesquise seu endereço na caixa de pesquisa';

  @override
  String get docsLocationManual => 'Digite seu endereço manualmente';

  @override
  String get docsLocationAccuracy => 'Certifique-se de que seu local é preciso. Os clientes o usam para encontrá-lo e calcular o tempo de viagem.';

  @override
  String get docsWorkingHoursTitle => 'Defina seus horários de trabalho';

  @override
  String get docsWorkingHoursContent => 'Os clientes só podem reservar quando você está aberto. Defina seus horários para cada dia da semana.';

  @override
  String get docsHoursExampleTitle => 'Cronograma de exemplo';

  @override
  String get docsHoursExampleContent => 'Segunda - Sexta: 9h às 18h\nSábado: 10h às 16h\nDomingo: Fechado';

  @override
  String get docsHoursTip => 'Você pode definir diferentes horários para dias diferentes, ou marcar qualquer dia como fechado quando não está trabalhando.';

  @override
  String get docsServicesTitle => 'Serviços e preços';

  @override
  String get docsServicesSubtitle => 'Diga aos clientes o que você oferece e quanto custa';

  @override
  String get docsServicesIntroTitle => 'Adicione seus serviços';

  @override
  String get docsServicesIntroContent => 'Cada serviço é algo que os clientes podem reservar e pagar. Exemplos: \"Corte de cabelo\", \"Coloração de cabelo\", \"Massagem\", \"Tratamento facial\".';

  @override
  String get docsServiceDetailsTitle => 'Para cada serviço, adicione:';

  @override
  String get docsServiceDetailsContent => 'Quando você cria um serviço, precisa fornecer:';

  @override
  String get docsServiceName => 'Nome do serviço - o que você está oferecendo (por exemplo, \"Corte de cabelo\")';

  @override
  String get docsServiceDescription => 'Descrição - detalhes breves sobre o que está incluído';

  @override
  String get docsServicePrice => 'Preço - quanto o serviço custa';

  @override
  String get docsServiceDuration => 'Duração - quanto tempo leva (por exemplo, 30 minutos, 1 hora)';

  @override
  String get docsServiceCategory => 'Categoria - que tipo de serviço é';

  @override
  String get docsPricingTipTitle => 'Dica de preço';

  @override
  String get docsPricingTipContent => 'Seja claro com seus preços. Você pode oferecer diferentes níveis de serviço (por exemplo, \"Corte básico\" vs \"Corte premium\") a preços diferentes.';

  @override
  String get docsDurationImportant => 'Defina a duração com precisão. Os clientes reservam com base neste tempo, e a equipe precisa saber quanto tempo reservar.';

  @override
  String get docsTeamTitle => 'Gerencie sua equipe';

  @override
  String get docsTeamSubtitle => 'Adicione membros da equipe e atribua-os a serviços';

  @override
  String get docsWorkersIntroTitle => 'Adicione sua equipe';

  @override
  String get docsWorkersIntroContent => 'Se você tem membros da equipe trabalhando em sua loja, você pode adicioná-los aqui. Isso ajuda você a gerenciar quem está disponível para reservas.';

  @override
  String get docsAddWorkerTitle => 'Como adicionar um membro da equipe';

  @override
  String get docsAddWorkerContent => 'Quando você adiciona um trabalhador, você precisa:';

  @override
  String get docsFreelancerTitle => 'Torne-se um Freelancer';

  @override
  String get docsFreelancerSubtitle => 'Trabalhe independentemente';

  @override
  String get docsFreelancerOverviewTitle => 'Primeiros passos como freelancer';

  @override
  String get docsFreelancerOverviewSubtitle => 'Aprenda como configurar seu perfil e começar a aceitar clientes';

  @override
  String get docsFreelancerWelcomeTitle => 'Bem-vindo ao trabalho autônomo';

  @override
  String get docsFreelancerWelcomeContent => 'Como freelancer no Aura In, você oferece serviços diretamente aos clientes em sua área. Ao contrário de uma loja tradicional, você trabalha de seu próprio local e pode viajar para encontrar clientes. Configure seu perfil em apenas alguns minutos e comece a aceitar reservas.';

  @override
  String get docsFreelancerVsShopTitle => 'Freelancer vs Loja: Qual é a diferença?';

  @override
  String get docsFreelancerVsShopContent => 'Assim é como o trabalho freelancer funciona:';

  @override
  String get docsFreelancerIndependent => 'Você trabalha de forma independente - nenhuma loja fixa necessária';

  @override
  String get docsFreelancerTravel => 'Você pode viajar para clientes dentro de seu raio escolhido';

  @override
  String get docsFreelancerHours => 'Você define seus próprios horários e disponibilidade';

  @override
  String get docsFreelancerManage => 'Você gerencia seu próprio cronograma e clientes';

  @override
  String get docsFreelancerBooking => 'Os clientes o reservam diretamente para serviços';

  @override
  String get docsFreelancerRequirementsTitle => 'O que você vai precisar';

  @override
  String get docsFreelancerRequirementsContent => 'Para começar como freelancer, você precisa de: seu nome, um tipo de profissão (cabeleireiro, terapeuta de massagem, etc.), local, raio de viagem, serviços e seus horários de trabalho. Uma foto profissional ajuda os clientes a confiar em você.';

  @override
  String get docsProfileSetupTitle => 'Crie seu perfil';

  @override
  String get docsProfileSetupSubtitle => 'Diga aos clientes quem você é';

  @override
  String get docsProfilePhotoTitle => 'Adicione sua foto de perfil';

  @override
  String get docsProfilePhotoContent => 'Um retrato profissional cria confiança com os clientes. Use uma foto clara e bem iluminada de si mesmo. Os clientes querem saber com quem estão reservando.';

  @override
  String get docsYourNameTitle => 'Seu nome';

  @override
  String get docsYourNameContent => 'Digite seu nome completo exatamente como deseja que os clientes o vejam. Seja profissional e claro.';

  @override
  String get docsProfessionTypeTitle => 'Escolha sua profissão';

  @override
  String get docsProfessionTypeContent => 'Selecione o que você faz. Exemplos: Cabeleireiro, Terapeuta de Massagem, Maquiador, Barbeiro, Esteticista ou outros serviços especializados.';

  @override
  String get docsBioDescriptionTitle => 'Escreva sua biografia';

  @override
  String get docsBioDescriptionContent => 'Escreva uma breve descrição sobre você e sua experiência (50-150 palavras). Diga aos clientes o que o torna especial. Exemplo: \"Sou especializado em cuidados naturais de cabelo com 5 anos de experiência. Certificado em coloração e styling.\"';

  @override
  String get docsTermsGuidelinesTitle => 'Adicione suas diretrizes';

  @override
  String get docsTermsGuidelinesContent => 'Compartilhe regras ou políticas importantes. Exemplos: restrições de idade, política de cancelamento, requisitos de saúde ou instruções de preparação.';

  @override
  String get docsServiceAreaTitle => 'Defina sua área de serviço';

  @override
  String get docsServiceAreaSubtitle => 'Defina onde você trabalha';

  @override
  String get docsBaseLocationTitle => 'Defina seu local base';

  @override
  String get docsBaseLocationContent => 'É onde você normalmente trabalha. Os clientes dentro de seu raio de viagem podem reservá-lo. Você pode marcar no mapa ou pesquisar seu endereço.';

  @override
  String get docsTravelRadiusTitle => 'Raio de viagem';

  @override
  String get docsTravelRadiusContent => 'Até que distância você está disposto a viajar para encontrar clientes? Defina isto em quilômetros. Exemplo: \"raio de 5 km\" significa que os clientes até 5 km de seu local podem reservá-lo.';

  @override
  String get docsMobileVsFixedTitle => 'Móvel ou local fixo?';

  @override
  String get docsMobileVsFixedContent => 'Escolha se viaja para clientes ou os encontra em um único local. Se for móvel, os clientes podem solicitá-lo em sua casa ou escritório.';

  @override
  String get docsServiceAddressTip => 'Os clientes verão seu raio de viagem ao pesquisar. Seja preciso para que saibam se você pode servir sua área.';

  @override
  String get docsToolsSetupTitle => 'Liste suas ferramentas e equipamentos';

  @override
  String get docsToolsSetupSubtitle => 'Mostre aos clientes o que você traz';

  @override
  String get docsToolsIntroTitle => 'O que são ferramentas?';

  @override
  String get docsToolsIntroContent => 'Ferramentas são o equipamento ou habilidades que você possui. Eles ajudam os clientes a entender o que você pode fazer e o que esperar.';

  @override
  String get docsToolExamplesTitle => 'Ferramentas de exemplo';

  @override
  String get docsToolExamplesContent => 'Para diferentes profissões:';

  @override
  String get docsToolHairdresser => 'Cabeleireiro: Secador de cabelo, chapinha, ondulador, tesoura';

  @override
  String get docsToolMassage => 'Terapeuta de Massagem: Maca de massagem, pedras quentes, óleos aromáticos';

  @override
  String get docsToolMakeup => 'Maquiador: Pincéis de maquiagem, aerógrafo, luz LED';

  @override
  String get docsToolBarber => 'Barbeiro: Máquinas de barbear elétricas, navalha, creme para pentear';

  @override
  String get docsToolSelectionTitle => 'Seleção de ferramentas';

  @override
  String get docsToolSelectionContent => 'Escolha todas as ferramentas e equipamentos que você usa profissionalmente. Os clientes querem saber que você tem o equipamento certo para seu serviço.';

  @override
  String get docsServicesSetupTitle => 'Serviços e preços';

  @override
  String get docsServicesSetupSubtitle => 'Diga aos clientes o que você oferece';

  @override
  String get docsServiceBasicsTitle => 'Adicione seus serviços';

  @override
  String get docsServiceBasicsContent => 'Cada serviço é algo que os clientes podem reservar. Exemplos: \"Corte de cabelo\", \"Massagem corporal completa\", \"Aplicação de maquiagem\".';

  @override
  String get docsServiceInfoTitle => 'Para cada serviço, adicione:';

  @override
  String get docsServiceInfoContent => 'Você precisa:';

  @override
  String get docsServiceInfoName => 'Nome do serviço - o que você está oferecendo';

  @override
  String get docsServiceInfoDescription => 'Descrição - o que está incluído';

  @override
  String get docsServiceInfoPrice => 'Preço - quanto custa';

  @override
  String get docsServiceInfoDuration => 'Duração - quanto tempo leva (30 min, 1 hora, etc.)';

  @override
  String get docsPricingStrategyTitle => 'Dicas de preço';

  @override
  String get docsPricingStrategyContent => 'Pesquise o que outros cobram pelos serviços similares em sua área. Preço competitivo mas justo para seu nível de experiência.';

  @override
  String get docsDurationImportanceFreelancer => 'Defina a duração com precisão. É assim que você bloqueia o tempo para cada reserva. Os clientes confiam neste tempo.';

  @override
  String get docsHoursSetupTitle => 'Defina sua disponibilidade';

  @override
  String get docsHoursSetupSubtitle => 'Quando você está disponível para trabalhar';

  @override
  String get docsHoursIntroTitle => 'Horários de trabalho';

  @override
  String get docsHoursIntroContent => 'Os clientes podem reservar apenas durante os horários que você marca como disponível. Defina seus horários para cada dia da semana.';

  @override
  String get docsFlexibleHoursTitle => 'Flexível ou rigoroso?';

  @override
  String get docsFlexibleHoursContent => 'Você decide. Se quiser horários consistentes, defina-os. Se preferir flexibilidade, pode ajustar diariamente conforme necessário.';

  @override
  String get docsBlockTimeTip => 'Quando um cliente o reserva, esse tempo é bloqueado em seu calendário. Defina as horas com sabedoria para evitar conflitos.';

  @override
  String get docsContactCredentialsTitle => 'Informações de contato e credenciais';

  @override
  String get docsContactCredentialsSubtitle => 'Ajude os clientes a contatá-lo e ganhe confiança';

  @override
  String get docsCreateProductTitle => 'Vender produtos online';

  @override
  String get docsCreateProductSubtitle => 'Liste itens para venda e alcance clientes em sua área';

  @override
  String get docsProductOverviewTitle => 'Primeiros passos na venda de produtos';

  @override
  String get docsProductOverviewSubtitle => 'Aprenda a listar e vender itens';

  @override
  String get docsProductWelcomeTitle => 'Bem-vindo à venda de produtos';

  @override
  String get docsProductWelcomeContent => 'Venda produtos físicos diretamente aos clientes em sua área. De itens artesanais a bens de varejo, você pode alcançar clientes procurando o que oferece.';

  @override
  String get docsPhoneRequirementTitle => 'Você precisa de um número de telefone verificado';

  @override
  String get docsPhoneRequirementContent => 'Antes de começar a vender produtos, você deve verificar seu número de telefone. Isso é para comunicação com o cliente e para validar sua identidade.';

  @override
  String get docsAddPhoneNumberTitle => 'Como adicionar seu número de telefone';

  @override
  String get docsAddPhoneNumberContent => 'Vá para as configurações do seu perfil e adicione seu número de telefone. Você receberá um código de verificação por SMS para confirmar que é realmente seu número. Isso leva apenas um minuto.';

  @override
  String get docsWhyPhoneVerifiedTitle => 'Por que verificação de telefone?';

  @override
  String get docsWhyPhoneVerifiedContent => 'Um número de telefone verificado cria confiança do cliente e nos permite contatá-lo se houver problemas. Também ajuda a prevenir fraudes.';

  @override
  String get docsPhoneImportant => 'Você não pode listar produtos até ter um número de telefone verificado. Isso é obrigatório para todos os vendedores.';

  @override
  String get docsProductBasicsTitle => 'Informações básicas do produto';

  @override
  String get docsProductBasicsSubtitle => 'O que dizer aos clientes sobre seu produto';

  @override
  String get docsProductNameTitle => 'Nome do produto';

  @override
  String get docsProductNameContent => 'Digite o nome do seu produto claramente. Os clientes pesquisam por nome do produto, então seja específico. Exemplo: \"Carteira de couro feito à mão - Marrom\" em vez de apenas \"Carteira\".';

  @override
  String get docsProductDescriptionTitle => 'Descrição do produto';

  @override
  String get docsProductDescriptionContent => 'Escreva uma descrição detalhada. Diga aos clientes o que é, do que é feito, como usá-lo e por que é bom. Seja honesto sobre a condição (novo, usado, recondicionado).';

  @override
  String get docsCategorySelectionTitle => 'Escolha uma categoria';

  @override
  String get docsCategorySelectionContent => 'Selecione a categoria correta. Os clientes procuram por categoria para encontrar itens, então a precisão é importante. Escolha a categoria mais específica disponível.';

  @override
  String get docsProductConditionTitle => 'Condição do produto';

  @override
  String get docsProductConditionContent => 'Seja claro sobre a condição: Novo (nunca usado), Como novo (usado uma vez), Bom (desgaste leve), Regular (desgaste visível) ou Conforme apresentado. A honestidade cria confiança.';

  @override
  String get docsPricingStockTitle => 'Preço e disponibilidade';

  @override
  String get docsPricingStockSubtitle => 'Defina seu preço e gerencie o inventário';

  @override
  String get docsPricingTitle => 'Defina seu preço';

  @override
  String get docsPricingContent => 'Defina um preço justo baseado na condição, valor de mercado e demanda local. Os clientes podem ver itens similares, então a precificação competitiva ajuda.';

  @override
  String get docsCurrencyTitle => 'Moeda';

  @override
  String get docsCurrencyContent => 'Os preços são mostrados na moeda da sua loja. Certifique-se de que a moeda da sua loja está definida corretamente antes de adicionar produtos.';

  @override
  String get docsStockQuantityTitle => 'Quantidade de estoque';

  @override
  String get docsStockQuantityContent => 'Digite quantos itens você tem. Quando o estoque acaba, o produto é exibido como indisponível. Atualize isso conforme vende itens.';

  @override
  String get docsStockTip => 'Mantenha o estoque preciso. Os clientes ficam frustrados se pedirem algo fora de estoque. Atualize regularmente conforme vende.';

  @override
  String get docsProductPhotosTitle => 'Fotos do produto';

  @override
  String get docsProductPhotosSubtitle => 'Mostre aos clientes o que estão comprando';

  @override
  String get docsPhotosImportanceTitle => 'As fotos são o mais importante';

  @override
  String get docsPhotosImportanceContent => 'Fotos boas são críticas. Os clientes decidem se comprar com base em fotos. Fotos ruins = menos vendas.';

  @override
  String get docsWhatPhotosTitle => 'O que fotografar';

  @override
  String get docsWhatPhotosContent => 'Tire fotos que mostrem o produto real:';

  @override
  String get docsPhotoFull => 'Produto completo de vários ângulos';

  @override
  String get docsPhotoCloseups => 'Close-ups de detalhes e qualidade';

  @override
  String get docsPhotoCondition => 'Fotos mostrando condição (se usado)';

  @override
  String get docsPhotoScale => 'Fotos ao lado de algo para escala (como moeda ou mão)';

  @override
  String get docsPhotoDamage => 'Fotos de danos ou desgaste (honestidade cria confiança)';

  @override
  String get docsPhotoTipsTitle => 'Dicas de qualidade de foto';

  @override
  String get docsPhotoTipsContent => 'Use luz natural. Tire fotos com fundo limpo. Mostre cores com precisão. Não use filtros que mudem a aparência do produto.';

  @override
  String get docsPhotoCountTitle => 'Quantas fotos?';

  @override
  String get docsPhotoCountContent => 'Carregue pelo menos 3 fotos claras. Mais fotos ajudam os clientes a entender melhor o produto. Limite a 10 fotos por produto.';

  @override
  String get docsToolsTitle => 'Ferramentas comerciais';

  @override
  String get docsToolsSubtitle => 'Recursos poderosos para automatizar, promover e gerenciar seu negócio';

  @override
  String get docsToolsOverviewTitle => 'Visão geral das ferramentas';

  @override
  String get docsToolsOverviewSubtitle => 'O que cada ferramenta faz e como usá-la';

  @override
  String get docsToolsWelcomeTitle => 'Bem-vindo às ferramentas comerciais';

  @override
  String get docsToolsWelcomeContent => 'A aba Ferramentas tem 8 recursos poderosos para ajudá-lo a automatizar, promover e gerenciar seu negócio de forma mais eficaz. Cada ferramenta resolve um problema comercial específico.';

  @override
  String get docsToolsListTitle => 'Ferramentas disponíveis';

  @override
  String get docsToolsListContent => 'Você tem acesso a essas 8 ferramentas:';

  @override
  String get docsToolsReminders => 'Lembretes automatizados - Enviar lembretes aos clientes';

  @override
  String get docsToolsPromotions => 'Gerenciador de promoções - Criar e gerenciar descontos';

  @override
  String get docsToolsExport => 'Exportar relatórios - Baixar seus dados comerciais';

  @override
  String get docsToolsPayment => 'Configurações de pagamento - Configure como você recebe pagamentos';

  @override
  String get docsToolsHours => 'Horário comercial - Defina seu cronograma de trabalho';

  @override
  String get docsToolsServices => 'Gerenciamento de serviços - Adicione e edite seus serviços';

  @override
  String get docsToolsLoyalty => 'Programa de fidelidade - Recompense clientes leais';

  @override
  String get docsToolsBroadcasts => 'Transmissões - Enviar mensagens para seus clientes';

  @override
  String get docsRemindersTitle => '1. Lembretes automatizados';

  @override
  String get docsRemindersSubtitle => 'Enviar lembretes automáticos aos clientes';

  @override
  String get docsReminderPurposeTitle => 'O que faz';

  @override
  String get docsReminderPurposeContent => 'Enviar automaticamente mensagens de lembrete aos clientes antes de suas reservas. Reduz ausências e mantém os clientes informados.';

  @override
  String get docsReminderBenefitsTitle => 'Benefícios';

  @override
  String get docsReminderBenefitsContent => 'Lembretes automatizados ajudam você a:';

  @override
  String get docsReminderBenefitNoShow => 'Reduzir ausências - clientes têm menos probabilidade de esquecer';

  @override
  String get docsReminderBenefitExperience => 'Melhorar a experiência do cliente - eles sabem quando chegar';

  @override
  String get docsReminderBenefitTime => 'Economizar tempo - sem necessidade de ligar ou enviar mensagens manualmente';

  @override
  String get docsReminderBenefitReliability => 'Aumentar confiabilidade - lembretes saem automaticamente';

  @override
  String get docsReminderSetupTitle => 'Como configurar';

  @override
  String get docsReminderSetupContent => 'Clique em \"Configurar lembretes automatizados\" para definir o tempo: enviar lembretes 24 horas antes, 2 horas antes ou na manhã do compromisso.';

  @override
  String get docsReminderImpact => 'Lojas que usam lembretes automatizados veem 20-30% menos ausências. Isso afeta diretamente sua receita.';

  @override
  String get docsPromosTitle => '2. Gerenciador de promoções';

  @override
  String get docsPromosSubtitle => 'Criar ofertas especiais e descontos';

  @override
  String get docsPromosPurposeTitle => 'O que faz';

  @override
  String get docsPromosPurposeContent => 'Crie promoções e descontos por tempo limitado. Ofereça porcentagem de desconto, valor fixo de desconto ou complementos gratuitos para atrair mais clientes.';

  @override
  String get docsPromosExamplesTitle => 'Ideias de promoção';

  @override
  String get docsPromosExamplesContent => 'Você pode criar promoções como:';

  @override
  String get docsPromosExample1 => '20% de desconto em cortes de cabelo nas segundas';

  @override
  String get docsPromosExample2 => 'Óleo de massagem grátis com qualquer reserva de massagem';

  @override
  String get docsPromosExample3 => '50 de desconto em um pacote de serviço completo';

  @override
  String get docsPromosExample4 => 'Cliente pela primeira vez: 30% de desconto';

  @override
  String get docsPromosExample5 => 'Bônus de fidelidade: 5o serviço com metade do preço';

  @override
  String get docsPromosStrategyTitle => 'Estratégia de promoção';

  @override
  String get docsPromosStrategyContent => 'Use promoções durante períodos lentos para aumentar reservas. Rastreie quais promoções funcionam melhor através de sua análise.';

  @override
  String get docsExportTitle => '3. Exportar relatórios';

  @override
  String get docsExportSubtitle => 'Baixe seus dados para análise';

  @override
  String get docsExportPurposeTitle => 'O que faz';

  @override
  String get docsExportPurposeContent => 'Baixe relatórios detalhados de seus dados comerciais em formato de planilha. Analise reservas, receita, clientes e mais.';

  @override
  String get docsExportTypesTitle => 'Relatórios disponíveis';

  @override
  String get docsExportTypesContent => 'Você pode exportar:';

  @override
  String get docsExportBookings => 'Relatórios de reserva - todas as reservas com detalhes';

  @override
  String get docsExportRevenue => 'Relatórios de receita - lucros por intervalo de datas';

  @override
  String get docsExportCustomers => 'Relatórios de clientes - sua lista de clientes';

  @override
  String get docsExportServices => 'Relatórios de serviços - desempenho por serviço';

  @override
  String get docsExportWorkers => 'Relatórios de funcionários - métricas de desempenho da equipe';

  @override
  String get docsExportUsesTitle => 'Por que exportar dados?';

  @override
  String get docsExportUsesContent => 'Use dados exportados no Excel para análise personalizada, manutenção de registros, fins fiscais ou para compartilhar com contador.';

  @override
  String get docsTimeSlotsTitle => 'Intervalos de tempo explicados';

  @override
  String get docsTimeSlotsSubtitle => 'Entenda como funcionam os horários de reserva';

  @override
  String get docsTimeSlotsOverviewTitle => 'O que são intervalos de tempo?';

  @override
  String get docsTimeSlotsOverviewSubtitle => 'Aprenda como o sistema de agendamento funciona';

  @override
  String get docsTimeSlotsWelcomeTitle => 'Bem-vindo aos intervalos de tempo';

  @override
  String get docsTimeSlotsWelcomeContent => 'Intervalos de tempo são os horários disponíveis em que os clientes podem reservar seus serviços. Compreender como funcionam ajuda a gerenciar seu cronograma de forma eficiente.';

  @override
  String get docsTimeSlotsBasicsTitle => 'Noções básicas de intervalos de tempo';

  @override
  String get docsTimeSlotsBasicsContent => 'Assim é como funcionam os intervalos de tempo:';

  @override
  String get docsTimeSlotsPoint1 => 'Cada serviço tem uma duração (quanto tempo leva)';

  @override
  String get docsTimeSlotsPoint2 => 'Você define suas horas disponíveis (quando trabalha)';

  @override
  String get docsTimeSlotsPoint3 => 'O sistema cria intervalos de tempo com base na duração do serviço';

  @override
  String get docsTimeSlotsPoint4 => 'Os clientes só podem reservar intervalos disponíveis';

  @override
  String get docsTimeSlotsExampleTitle => 'Exemplo: Criando intervalos de tempo';

  @override
  String get docsTimeSlotsExampleContent => 'Se você oferecer um corte de cabelo de 30 minutos e trabalhar de 9h às 17h:\n• 9:00 - 9:30 (Intervalo 1)\n• 9:30 - 10:00 (Intervalo 2)\n• 10:00 - 10:30 (Intervalo 3)\n...e assim por todo o dia';

  @override
  String get docsTimeSlotsOverlapTitle => 'E se os serviços se sobrepuserem?';

  @override
  String get docsTimeSlotsOverlapContent => 'Se você tiver vários funcionários, cada pessoa tem seu próprio cronograma. Se trabalhar sozinho, apenas um cliente pode reservar por vez — o sistema bloqueia automaticamente horários conflitantes.';

  @override
  String get docsTimeSlotsGapTitle => 'Definindo lacunas entre serviços';

  @override
  String get docsTimeSlotsGapContent => 'Você pode definir tempo de buffer entre reservas. Exemplo: 15 minutos de intervalo após cada corte de cabelo para limpeza. Isso reduz os intervalos disponíveis, mas lhe dá tempo para respirar.';

  @override
  String get docsTimeSlotsGroupTitle => 'Reservas em grupo e intervalos de tempo';

  @override
  String get docsTimeSlotsGroupContent => 'Para reservas em grupo, o sistema encontra horários que funcionam para TODAS as pessoas do grupo. Isso torna mais difícil encontrar intervalos disponíveis, mas garante que todos sejam atendidos juntos.';

  @override
  String get docsTimeSlotsBlockingTitle => 'Tempo de bloqueio';

  @override
  String get docsTimeSlotsBlockingContent => 'Você pode bloquear manualmente o tempo para almoço, pausas ou compromissos pessoais. O tempo bloqueado não aparecerá como disponível para os clientes.';

  @override
  String get docsTimeSlotsUtilizationTitle => 'Maximizando seus intervalos de tempo';

  @override
  String get docsTimeSlotsUtilizationContent => 'Dicas para usar seus intervalos de forma eficiente:\n• Combine a duração do serviço com a realidade (não subestime)\n• Defina lacunas realistas entre serviços\n• Use tempo de buffer estrategicamente\n• Revise e ajuste com base no feedback do cliente';

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

  @override
  String get docsBookingStartedBookingIntro_title => 'Welcome to the Booking System';

  @override
  String get docsBookingStartedBookingIntro_subtitle => 'Everything you need to know about booking services, whether you\'re a client or a shop owner.';

  @override
  String get docsBookingStartedBookingIntro_whatIsBooking_title => 'What is the Booking System?';

  @override
  String get docsBookingStartedBookingIntro_whatIsBooking_content => 'The booking system is your gateway to scheduling services at your favorite shops. Whether you need a haircut, beard trim, braiding, or any other service, the system makes it easy to book appointments at your convenience.';

  @override
  String get docsBookingStartedBookingIntro_whoItsFor_title => 'Who is this guide for?';

  @override
  String get docsBookingStartedBookingIntro_whoItsFor_content => 'This guide is designed for two types of users:';

  @override
  String get docsBookingStartedBookingIntro_whoItsFor_bullet1 => 'Clients: People who want to book services at shops';

  @override
  String get docsBookingStartedBookingIntro_whoItsFor_bullet2 => 'Guest Bookers: People who want to book via a link without creating an account';

  @override
  String get docsBookingStartedBookingIntro_whoItsFor_bullet3 => 'Shop Owners: People who manage shops, services, and workers';

  @override
  String get docsBookingStartedBookingIntro_guestBookingIntro_title => 'New: Book Without Downloading the App';

  @override
  String get docsBookingStartedBookingIntro_guestBookingIntro_content => 'No account? No problem! If a shop owner shares a booking link with you, you can book directly without downloading the app. Your receipt is sent to WhatsApp.';

  @override
  String get docsBookingStartedBookingIntro_welcomeNote_content => 'No technical knowledge needed! This guide uses simple language and real examples to help you understand everything.';

  @override
  String get docsBookingStartedCreatingAccount_title => 'Creating Your Account (Or Booking as Guest)';

  @override
  String get docsBookingStartedCreatingAccount_subtitle => 'Get started in minutes - with or without an account';

  @override
  String get docsBookingStartedCreatingAccount_twoWaysToBook_title => 'Two Ways to Book';

  @override
  String get docsBookingStartedCreatingAccount_twoWaysToBook_content => 'You can book in two ways:';

  @override
  String get docsBookingStartedCreatingAccount_twoWaysToBook_bullet1 => 'With Account: Download app, create account, book anytime';

  @override
  String get docsBookingStartedCreatingAccount_twoWaysToBook_bullet2 => 'As Guest: Use booking link, no app needed, receipt via WhatsApp';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_title => 'How to Create an Account';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_content => 'Follow these simple steps to create your account:';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_bullet1 => 'Download the app from App Store or Google Play';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_bullet2 => 'Tap \"Sign Up\" on the welcome screen';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_bullet3 => 'Enter your email address and create a password';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_bullet4 => 'Add your name and profile picture (optional)';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_bullet5 => 'Verify your email address';

  @override
  String get docsBookingStartedCreatingAccount_accountSteps_bullet6 => 'You\'re ready to start booking!';

  @override
  String get docsBookingStartedCreatingAccount_accountTypes_title => 'Account Types';

  @override
  String get docsBookingStartedCreatingAccount_accountTypes_content => 'There are two types of accounts:';

  @override
  String get docsBookingStartedCreatingAccount_accountTypes_bullet1 => 'Client Account: For booking services at shops';

  @override
  String get docsBookingStartedCreatingAccount_accountTypes_bullet2 => 'Shop Owner Account: For managing your own shop (requires approval)';

  @override
  String get docsBookingStartedCreatingAccount_guestBookingOption_title => 'Booking as a Guest (No Account)';

  @override
  String get docsBookingStartedCreatingAccount_guestBookingOption_content => 'If someone shares a booking link with you, you can book directly without creating an account. Just click the link and follow the steps. Your receipt is sent to your WhatsApp.';

  @override
  String get docsBookingStartedCreatingAccount_verificationNote_content => 'You can browse and book without an account using a booking link. Creating an account gives you access to booking history, saved payments, and loyalty rewards.';

  @override
  String get docsBookingStartedFirstBooking_title => 'Your First Booking';

  @override
  String get docsBookingStartedFirstBooking_subtitle => 'A quick walkthrough';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_title => 'How to make your first booking';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_content => 'Here\'s what you\'ll do:';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_bullet1 => 'Find a shop you like';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_bullet2 => 'Browse their services';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_bullet3 => 'Select the services you want';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_bullet4 => 'Choose your preferred worker (if available)';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_bullet5 => 'Pick a date and time';

  @override
  String get docsBookingStartedFirstBooking_bookingSteps_bullet6 => 'Review and confirm your booking';

  @override
  String get docsBookingStartedFirstBooking_whatHappensNext_title => 'What happens after you book?';

  @override
  String get docsBookingStartedFirstBooking_whatHappensNext_content => 'Once you confirm your booking:';

  @override
  String get docsBookingStartedFirstBooking_whatHappensNext_bullet1 => 'You\'ll get an instant confirmation';

  @override
  String get docsBookingStartedFirstBooking_whatHappensNext_bullet2 => 'The booking appears in \"My Bookings\"';

  @override
  String get docsBookingStartedFirstBooking_whatHappensNext_bullet3 => 'You\'ll receive a reminder before your appointment';

  @override
  String get docsBookingStartedFirstBooking_whatHappensNext_bullet4 => 'The shop gets notified of your booking';

  @override
  String get docsBookingStartedFirstBooking_whatHappensNext_bullet5 => 'You can reschedule or cancel if plans change';

  @override
  String get docsBookingStartedFirstBooking_paymentProcess_title => 'How Payment Works';

  @override
  String get docsBookingStartedFirstBooking_paymentProcess_content => 'When you book a service, here\'s how payment works:';

  @override
  String get docsBookingStartedFirstBooking_paymentProcess_bullet1 => '30% Deposit Required: To secure your booking, you pay 30% of the total service cost upfront';

  @override
  String get docsBookingStartedFirstBooking_paymentProcess_bullet2 => 'Platform Fee: A small fixed fee (e.g., GHS 2) is added to help maintain the platform';

  @override
  String get docsBookingStartedFirstBooking_paymentProcess_bullet3 => 'Non-Refundable: Deposit and fee are non-refundable if you cancel or don\'t show up';

  @override
  String get docsBookingStartedFirstBooking_paymentProcess_bullet4 => 'Remaining 70%: Paid after service - either in cash or via app';

  @override
  String get docsBookingStartedFirstBooking_paymentProcess_bullet5 => 'Secure Payment: All payments are processed securely through our payment partners';

  @override
  String get docsBookingStartedFirstBooking_remainingPaymentOptions_title => 'Flexible Payment for Remaining Balance';

  @override
  String get docsBookingStartedFirstBooking_remainingPaymentOptions_content => 'After your service, you have options for paying the remaining 70%:';

  @override
  String get docsBookingStartedFirstBooking_remainingPaymentOptions_bullet1 => 'Pay in Cash: Hand cash directly to worker or shop counter';

  @override
  String get docsBookingStartedFirstBooking_remainingPaymentOptions_bullet2 => 'Pay via App: Use card, mobile money, or digital payment through the app';

  @override
  String get docsBookingStartedFirstBooking_remainingPaymentOptions_bullet3 => 'You choose: Either option is available at the time of service';

  @override
  String get docsBookingStartedFirstBooking_depositNote_content => 'The 30% deposit protects both you and the shop. It ensures your slot is reserved exclusively for you, and compensates the worker if you cancel last minute. The platform fee helps us maintain secure payments and customer support.';

  @override
  String get docsBookingStartedFirstBooking_bookingTip_content => 'Pro tip: Book at least 24 hours in advance for the best selection of time slots, especially for popular services.';

  @override
  String get docsBookingStartedNavigation_title => 'Finding Your Way Around';

  @override
  String get docsBookingStartedNavigation_subtitle => 'Key screens and what they do';

  @override
  String get docsBookingStartedNavigation_mainScreens_title => 'Main Screens';

  @override
  String get docsBookingStartedNavigation_mainScreens_content => 'The app has several key screens to help you navigate:';

  @override
  String get docsBookingStartedNavigation_mainScreens_bullet1 => 'Home: Discover shops and services near you';

  @override
  String get docsBookingStartedNavigation_mainScreens_bullet2 => 'Search: Find specific shops or services';

  @override
  String get docsBookingStartedNavigation_mainScreens_bullet3 => 'My Bookings: View and manage your appointments';

  @override
  String get docsBookingStartedNavigation_mainScreens_bullet4 => 'Profile: Your account settings and preferences';

  @override
  String get docsBookingStartedNavigation_mainScreens_bullet5 => 'Favorites: Save shops you love for quick access';

  @override
  String get docsBookingStartedNavigation_bookingFlow_title => 'The Booking Flow';

  @override
  String get docsBookingStartedNavigation_bookingFlow_content => 'When you start booking, you\'ll go through these steps:';

  @override
  String get docsBookingStartedNavigation_bookingFlow_bullet1 => 'Services: Choose what you want';

  @override
  String get docsBookingStartedNavigation_bookingFlow_bullet2 => 'Workers: Pick who you want (if applicable)';

  @override
  String get docsBookingStartedNavigation_bookingFlow_bullet3 => 'Time: Select your preferred date and time';

  @override
  String get docsBookingStartedNavigation_bookingFlow_bullet4 => 'Confirm: Review and finalize your booking';

  @override
  String get docsBookingStartedNavigation_navigationTip_content => 'You can always go back to previous steps using the back button. Your selections are saved as you move through the flow.';

  @override
  String get docsBookingStartedBasics_title => 'Booking Basics';

  @override
  String get docsBookingStartedBasics_subtitle => 'Key concepts explained simply';

  @override
  String get docsBookingStartedBasics_keyTerms_title => 'Important Terms to Know';

  @override
  String get docsBookingStartedBasics_keyTerms_content => 'Here are some terms you\'ll encounter:';

  @override
  String get docsBookingStartedBasics_keyTerms_bullet1 => 'Service: What you want done (haircut, braids, etc.)';

  @override
  String get docsBookingStartedBasics_keyTerms_bullet2 => 'Worker: The person who performs the service';

  @override
  String get docsBookingStartedBasics_keyTerms_bullet3 => 'Slot: A specific date and time for your appointment';

  @override
  String get docsBookingStartedBasics_keyTerms_bullet4 => 'Group Booking: Booking for multiple people at once';

  @override
  String get docsBookingStartedBasics_keyTerms_bullet5 => 'Buffer Time: Clean-up time between appointments (you won\'t see this)';

  @override
  String get docsBookingStartedBasics_whatYouNeed_title => 'What You Need Before Booking';

  @override
  String get docsBookingStartedBasics_whatYouNeed_content => 'Before you start, have this information ready:';

  @override
  String get docsBookingStartedBasics_whatYouNeed_bullet1 => 'The service you want';

  @override
  String get docsBookingStartedBasics_whatYouNeed_bullet2 => 'Preferred date and time (flexibility helps!)';

  @override
  String get docsBookingStartedBasics_whatYouNeed_bullet3 => 'Number of people (if booking for a group)';

  @override
  String get docsBookingStartedBasics_whatYouNeed_bullet4 => 'Worker preference (if you have one)';

  @override
  String get docsBookingStartedBasics_depositExplained_title => 'Understanding the Deposit';

  @override
  String get docsBookingStartedBasics_depositExplained_content => 'Here\'s a real example of how the deposit works:';

  @override
  String get docsBookingStartedBasics_depositExample_title => 'Example';

  @override
  String get docsBookingStartedBasics_depositExample_content => 'Sarah books a haircut that costs GHS 100.\n• At booking: She pays GHS 30 (30% deposit)\n• After service: She pays GHS 70 (remaining balance)\n• Total paid: GHS 100\n\nIf Sarah cancels: She loses the GHS 30 deposit, but isn\'t charged the remaining GHS 70.\n\nIf Sarah doesn\'t show up: Same as cancellation - the GHS 30 deposit is kept.';

  @override
  String get docsBookingStartedBasics_depositTip_content => 'The deposit is applied toward your total bill. You\'re not paying extra - you\'re just paying part of it upfront to secure your spot.';

  @override
  String get docsBookingStartedBasics_basicsImportant_content => 'All times shown in the app are in your local timezone. No need to worry about timezone conversions!';

  @override
  String get docsBookingStartedFaq1Q => 'Can I book without an account?';

  @override
  String get docsBookingStartedFaq1A => 'You can browse shops and services without an account, but you\'ll need to sign up to actually book appointments. This helps us keep track of your bookings and send you reminders.';

  @override
  String get docsBookingStartedFaq2Q => 'Does it cost anything to use the booking system?';

  @override
  String get docsBookingStartedFaq2A => 'The booking system is completely free for clients. You only pay for the services you book. Shop owners pay a small commission on each booking.';

  @override
  String get docsBookingStartedFaq3Q => 'Can I book at multiple shops at the same time?';

  @override
  String get docsBookingStartedFaq3A => 'Yes! You can book appointments at different shops. Just make sure the times don\'t overlap if you\'re planning to attend them all yourself.';

  @override
  String get docsBookingStartedFaq4Q => 'Is the deposit refundable if I cancel?';

  @override
  String get docsBookingStartedFaq4A => 'No, the 30% deposit is non-refundable. This policy helps shops protect their time in case of last-minute cancellations or no-shows. You can cancel up to 24 hours before your appointment to avoid being charged the remaining 70%, but the deposit will not be refunded.';

  @override
  String get docsBookingStartedFaq5Q => 'Why 30%? Why not a fixed amount?';

  @override
  String get docsBookingStartedFaq5A => 'The 30% deposit scales with the cost of your service. For expensive services, the deposit is higher (protecting the shop more), and for cheaper services, it\'s lower (fairer for you). This percentage was chosen as a balanced approach that works for both clients and shops.';

  @override
  String get docsBookingStartedFaq6Q => 'If I book multiple services, do I pay 30% of the total?';

  @override
  String get docsBookingStartedFaq6A => 'Yes! The 30% deposit is calculated based on the total cost of all services you\'re booking. So if your total is GHS 200, you\'ll pay GHS 60 upfront, and the remaining GHS 140 after your appointment.';

  @override
  String get docsBookingStartedFaq7Q => 'What if I have a genuine emergency?';

  @override
  String get docsBookingStartedFaq7A => 'We understand that emergencies happen. While the deposit is officially non-refundable, you can contact the shop directly through the app to explain your situation. Some shops may offer credit toward a future booking at their discretion.';

  @override
  String get docsBookingStartedFaq8Q => 'Will I get reminders about my booking?';

  @override
  String get docsBookingStartedFaq8A => 'Yes! You\'ll receive reminders 24 hours before your appointment and again 1 hour before. You can adjust reminder settings in your profile.';

  @override
  String get docsBookingStartedFaq9Q => 'When do I pay for my booking?';

  @override
  String get docsBookingStartedFaq9A => 'Payment is handled at the time of booking. You can pay using credit card, debit card, or other payment methods available in your region.';

  @override
  String get docsBookingStartedFaq10Q => 'I own a shop. How do I get started?';

  @override
  String get docsBookingStartedFaq10A => 'Great! Create an account and select \"Shop Owner\" during signup. You\'ll need to provide some information about your shop and wait for approval. Once approved, you can start adding services and workers.';

  @override
  String get docsBookingStartedFaq11Q => 'Can I book without creating an account?';

  @override
  String get docsBookingStartedFaq11A => 'Yes! If a shop owner shares a booking link with you, you can book directly without an account. Just click the link and follow the booking steps. Your receipt is sent to your WhatsApp. You can create an account later if you want to track all your bookings in one place.';

  @override
  String get docsBookingStartedFaq12Q => 'What is the platform fee and why do I pay it?';

  @override
  String get docsBookingStartedFaq12A => 'The platform fee is a small fixed charge (e.g., GHS 2) added to your booking. It helps us maintain the app, process payments securely, provide customer support, and develop new features. Only one platform fee per booking, even for multiple services or people.';

  @override
  String get docsBookingStartedFaq13Q => 'Can I pay the remaining 70% in cash?';

  @override
  String get docsBookingStartedFaq13A => 'Yes! You have flexibility. You can pay the remaining 70% either in cash directly to the shop/worker, or through the app using your preferred payment method. The choice is yours at the time of service.';

  @override
  String get docsBookingStartedFaq14Q => 'As a guest, how do I get my booking details?';

  @override
  String get docsBookingStartedFaq14A => 'Your booking confirmation and receipt are sent to your WhatsApp number. You\'ll receive appointment reminders and can track everything through WhatsApp without downloading the app.';

  @override
  String get docsHowBooktitle => 'How to Book Services';

  @override
  String get docsHowBooksubtitle => 'How to Book Services';

  @override
  String get docsHowBookBookingOverview_title => 'Booking at a Glance';

  @override
  String get docsHowBookBookingOverview_subtitle => 'The booking process in simple steps';

  @override
  String get docsHowBookBookingOverview_twoBookingWays_title => 'Two Ways to Book';

  @override
  String get docsHowBookBookingOverview_twoBookingWays_content => 'You can book in two ways:';

  @override
  String get docsHowBookBookingOverview_twoBookingWays_bullet1 => '**With App Account:** Download app, create account, book anytime';

  @override
  String get docsHowBookBookingOverview_twoBookingWays_bullet2 => '**As Guest:** Use booking link, no app needed, receipt via WhatsApp';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_title => 'Your Booking Journey (With Account)';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_content => 'Booking a service takes just a few minutes. Here\'s what you\'ll do:';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_bullet1 => '**Step 1:** Find a shop and browse services';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_bullet2 => '**Step 2:** Select your services and quantities';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_bullet3 => '**Step 3:** Choose your preferred worker (if available)';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_bullet4 => '**Step 4:** Pick a date and time';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_bullet5 => '**Step 5:** Pay 30% deposit + small fee to confirm';

  @override
  String get docsHowBookBookingOverview_bookingStepsOverview_bullet6 => '**Step 6:** After service, pay remaining 70% in cash or via app';

  @override
  String get docsHowBookBookingOverview_guestBookingNote_title => 'Guest Booking (No App)';

  @override
  String get docsHowBookBookingOverview_guestBookingNote_content => 'Don\'t have the app? If a shop shares a booking link with you, follow the same steps above but without needing to create an account. Your confirmation and receipt go to your WhatsApp.';

  @override
  String get docsHowBookBookingOverview_bookingTimeNote_content => 'The entire process usually takes less than 2 minutes. Your progress is saved as you go, so you can take your time.';

  @override
  String get docsHowBookStepOne_title => 'Step 1: Find Your Shop & Services';

  @override
  String get docsHowBookStepOne_subtitle => 'Discover the perfect place for your needs';

  @override
  String get docsHowBookStepOne_findShop_title => 'How to find a shop';

  @override
  String get docsHowBookStepOne_findShop_content => 'You can find shops in several ways:';

  @override
  String get docsHowBookStepOne_findShop_bullet1 => '**Home Screen:** Browse recommended shops near you';

  @override
  String get docsHowBookStepOne_findShop_bullet2 => '**Search:** Look for specific shops or services by name';

  @override
  String get docsHowBookStepOne_findShop_bullet3 => '**Categories:** Filter by service type (Haircut, Braiding, Beard, etc.)';

  @override
  String get docsHowBookStepOne_findShop_bullet4 => '**Favorites:** Quick access to shops you\'ve saved';

  @override
  String get docsHowBookStepOne_browseServices_title => 'Browsing Services';

  @override
  String get docsHowBookStepOne_browseServices_content => 'Once you select a shop, you\'ll see all their available services. Each service shows:';

  @override
  String get docsHowBookStepOne_browseServices_bullet1 => '**Service name** (e.g., \"Afro Haircut\", \"Box Braids\")';

  @override
  String get docsHowBookStepOne_browseServices_bullet2 => '**Duration** (how long it takes)';

  @override
  String get docsHowBookStepOne_browseServices_bullet3 => '**Price** (cost of the service - this goes to the shop)';

  @override
  String get docsHowBookStepOne_browseServices_bullet4 => '**Description** (what\'s included)';

  @override
  String get docsHowBookStepOne_browseServices_bullet5 => '**Worker requirement** (whether you can choose who does it)';

  @override
  String get docsHowBookStepOne_serviceExample_title => 'Example';

  @override
  String get docsHowBookStepOne_serviceExample_content => '**Haircut Service:**\n• Name: Afro Haircut\n• Duration: 1 hour\n• Price: GHS 45 (paid to shop)\n• Description: Professional afro haircut with styling\n• Worker: You can choose your preferred barber';

  @override
  String get docsHowBookStepTwo_title => 'Step 2: Select Your Services';

  @override
  String get docsHowBookStepTwo_subtitle => 'Choose what you want and how many people';

  @override
  String get docsHowBookStepTwo_selectServices_title => 'Selecting Services';

  @override
  String get docsHowBookStepTwo_selectServices_content => 'To select a service, simply tap on it. You\'ll see it become highlighted. You can select multiple services at once:';

  @override
  String get docsHowBookStepTwo_selectServices_bullet1 => 'Tap a service to select it';

  @override
  String get docsHowBookStepTwo_selectServices_bullet2 => 'Selected services show a checkmark';

  @override
  String get docsHowBookStepTwo_selectServices_bullet3 => 'You can select multiple services (e.g., Haircut + Beard Trim)';

  @override
  String get docsHowBookStepTwo_selectServices_bullet4 => 'Tap again to deselect';

  @override
  String get docsHowBookStepTwo_groupBooking_title => 'Booking for Multiple People';

  @override
  String get docsHowBookStepTwo_groupBooking_content => 'If you\'re booking for a group (like yourself and your children), you can increase the quantity:';

  @override
  String get docsHowBookStepTwo_groupBooking_bullet1 => 'After selecting a service, you\'ll see a **+** and **-** button';

  @override
  String get docsHowBookStepTwo_groupBooking_bullet2 => 'Tap **+** to increase the number of people';

  @override
  String get docsHowBookStepTwo_groupBooking_bullet3 => 'The price updates automatically';

  @override
  String get docsHowBookStepTwo_groupBooking_bullet4 => 'Maximum quantity is shown (some services have limits)';

  @override
  String get docsHowBookStepTwo_groupExample_title => 'Example: Family Booking';

  @override
  String get docsHowBookStepTwo_groupExample_content => '**Dad wants haircuts for himself and his two sons:**\n• Select \"Haircut\" service\n• Tap **+** until quantity shows 3\n• Total price shows 3 × GHS 45 = GHS 135 (for the shop)\n• You\'ll choose workers for each person later';

  @override
  String get docsHowBookStepTwo_quantityTip_content => 'The quantity feature is perfect for families, groups of friends, or anyone booking for multiple people at once.';

  @override
  String get docsHowBookStepThree_title => 'Step 3: Choose Your Workers';

  @override
  String get docsHowBookStepThree_subtitle => 'Pick who will perform your services';

  @override
  String get docsHowBookStepThree_workerSelection_title => 'When You Can Choose a Worker';

  @override
  String get docsHowBookStepThree_workerSelection_content => 'Some services let you choose your preferred worker, while others assign whoever is available:';

  @override
  String get docsHowBookStepThree_workerSelection_bullet1 => '**Services with worker choice:** You\'ll see a \"Choose Worker\" button';

  @override
  String get docsHowBookStepThree_workerSelection_bullet2 => '**Services without worker choice:** The system will assign an available worker';

  @override
  String get docsHowBookStepThree_workerSelection_bullet3 => '**Group bookings:** You can choose different workers for each person';

  @override
  String get docsHowBookStepThree_choosingWorker_title => 'How to Choose a Worker';

  @override
  String get docsHowBookStepThree_choosingWorker_content => 'If a service lets you choose a worker:';

  @override
  String get docsHowBookStepThree_choosingWorker_bullet1 => 'Tap \"Choose Worker\" for that service';

  @override
  String get docsHowBookStepThree_choosingWorker_bullet2 => 'You\'ll see a list of available workers';

  @override
  String get docsHowBookStepThree_choosingWorker_bullet3 => 'Each worker shows their name, photo, specialties, and rating';

  @override
  String get docsHowBookStepThree_choosingWorker_bullet4 => 'Tap on a worker to select them';

  @override
  String get docsHowBookStepThree_choosingWorker_bullet5 => 'For group bookings, you\'ll choose a worker for each person';

  @override
  String get docsHowBookStepThree_workerExample_title => 'Example: Group with Different Workers';

  @override
  String get docsHowBookStepThree_workerExample_content => '**Family of 3 booking haircuts:**\n• Person 1 (Dad): Choose John (fade specialist)\n• Person 2 (Son 1): Choose Michael (kids cuts)\n• Person 3 (Son 2): Choose Michael (same worker)\n• All three will be served during your appointment time';

  @override
  String get docsHowBookStepThree_workerTip_content => 'You can see each worker\'s availability in real-time. If your preferred worker isn\'t available at your desired time, you\'ll need to choose a different time or worker.';

  @override
  String get docsHowBookStepFour_title => 'Step 4: Pick Your Date & Time';

  @override
  String get docsHowBookStepFour_subtitle => 'Select when you want your appointment';

  @override
  String get docsHowBookStepFour_dateSelection_title => 'Choosing a Date';

  @override
  String get docsHowBookStepFour_dateSelection_content => 'First, pick your preferred date from the calendar:';

  @override
  String get docsHowBookStepFour_dateSelection_bullet1 => 'Dates with available slots are highlighted';

  @override
  String get docsHowBookStepFour_dateSelection_bullet2 => 'Past dates are greyed out';

  @override
  String get docsHowBookStepFour_dateSelection_bullet3 => 'Today is marked with \"Today\"';

  @override
  String get docsHowBookStepFour_dateSelection_bullet4 => 'You can scroll forward up to 30 days';

  @override
  String get docsHowBookStepFour_timeSelection_title => 'Two Ways to View Time Slots';

  @override
  String get docsHowBookStepFour_timeSelection_content => 'Once you pick a date, you\'ll see available time slots. You can switch between two views:';

  @override
  String get docsHowBookStepFour_timeSelection_bullet1 => '**Regular View:** Shows slots for each service separately';

  @override
  String get docsHowBookStepFour_timeSelection_bullet2 => '**Combined View:** Shows only slots where ALL your services can be booked together';

  @override
  String get docsHowBookStepFour_regularVsCombined_title => 'Regular vs Combined View';

  @override
  String get docsHowBookStepFour_regularVsCombined_content => '**Regular View Example (2 services):**\n• Haircut: 9:00 AM, 9:30 AM, 10:00 AM...\n• Beard Trim: 9:00 AM, 9:30 AM, 10:00 AM...\n\n**Combined View Example (same 2 services):**\n• 9:00 AM - 10:30 AM (both services together)\n• 9:30 AM - 11:00 AM\n• 10:00 AM - 11:30 AM';

  @override
  String get docsHowBookStepFour_viewSwitch_content => 'Use the toggle switch to switch between Regular and Combined view. Combined view is especially useful when booking multiple services.';

  @override
  String get docsHowBookStepFive_title => 'Step 5: Payment & Confirmation';

  @override
  String get docsHowBookStepFive_subtitle => 'Secure your booking with a 30% deposit';

  @override
  String get docsHowBookStepFive_paymentOverview_title => 'How Payment Works';

  @override
  String get docsHowBookStepFive_paymentOverview_content => 'To secure your booking, you\'ll pay a 30% deposit plus a small processing fee. Here\'s what you need to know:';

  @override
  String get docsHowBookStepFive_paymentOverview_bullet1 => '**30% Deposit:** Required at the time of booking (goes to the shop)';

  @override
  String get docsHowBookStepFive_paymentOverview_bullet2 => '**Processing Fee:** Small fixed fee charged by the platform (e.g., GHS 2 per booking)';

  @override
  String get docsHowBookStepFive_paymentOverview_bullet3 => '**Non-Refundable Deposit:** The 30% deposit is not refunded if you cancel or don\'t show up';

  @override
  String get docsHowBookStepFive_paymentOverview_bullet4 => '**Processing Fee Non-Refundable:** The platform fee is also non-refundable';

  @override
  String get docsHowBookStepFive_paymentOverview_bullet5 => '**Secure Processing:** All payments are encrypted and secure';

  @override
  String get docsHowBookStepFive_paymentExample_title => 'Payment Example';

  @override
  String get docsHowBookStepFive_paymentExample_content => '**Sarah books services totaling GHS 200:**\n• At booking: Pays GHS 60 (30% deposit for shop) + GHS 2 (platform fee) = GHS 62\n• After service: Pays remaining GHS 140 to the shop (in cash or via app)\n• Total paid: GHS 200 to shop + GHS 2 platform fee\n\n**If Sarah cancels:** She loses the GHS 60 deposit and GHS 2 fee\n**If Sarah doesn\'t show up:** Same as cancellation';

  @override
  String get docsHowBookStepFive_paymentStep_title => 'The Payment Screen';

  @override
  String get docsHowBookStepFive_paymentStep_content => 'On the confirmation screen, you\'ll see:';

  @override
  String get docsHowBookStepFive_paymentStep_bullet1 => '**Summary:** All services, quantities, and workers';

  @override
  String get docsHowBookStepFive_paymentStep_bullet2 => '**Total Price:** Full cost of all services (for the shop)';

  @override
  String get docsHowBookStepFive_paymentStep_bullet3 => '**Deposit Amount:** 30% payable now';

  @override
  String get docsHowBookStepFive_paymentStep_bullet4 => '**Platform Fee:** Small processing fee (e.g., GHS 2)';

  @override
  String get docsHowBookStepFive_paymentStep_bullet5 => '**Total Due Now:** Deposit + platform fee';

  @override
  String get docsHowBookStepFive_paymentStep_bullet6 => '**Remaining Balance:** 70% to pay after service (cash or app)';

  @override
  String get docsHowBookStepFive_paymentStep_bullet7 => '**Payment Methods:** Choose how to pay the deposit';

  @override
  String get docsHowBookStepFive_feeExplanation_title => 'Understanding the Platform Fee';

  @override
  String get docsHowBookStepFive_feeExplanation_content => 'The processing fee (e.g., GHS 2 per booking) is charged by the platform, not the shop. This fee helps us maintain the app and provide you with a great booking experience. The fee is:';

  @override
  String get docsHowBookStepFive_feeExplanation_bullet1 => '**Fixed amount** (not a percentage)';

  @override
  String get docsHowBookStepFive_feeExplanation_bullet2 => '**Charged once per booking** (not per service)';

  @override
  String get docsHowBookStepFive_feeExplanation_bullet3 => '**Non-refundable** even if you cancel';

  @override
  String get docsHowBookStepFive_feeExplanation_bullet4 => '**Clearly shown** before you confirm';

  @override
  String get docsHowBookStepFive_paymentImportant_content => 'The 30% deposit goes to the shop and is applied toward your total bill. The platform fee is separate and helps keep the app running. You\'re not paying extra to the shop - just paying part of your bill upfront.';

  @override
  String get docsHowBookStepFive_remainingPayment_title => 'Paying the Remaining 70%';

  @override
  String get docsHowBookStepFive_remainingPayment_content => 'After your service is complete, you have two options to pay the remaining balance:';

  @override
  String get docsHowBookStepFive_remainingPayment_bullet1 => '**Cash:** Pay the worker or shop directly';

  @override
  String get docsHowBookStepFive_remainingPayment_bullet2 => '**Via App:** Pay through the app using your preferred payment method';

  @override
  String get docsHowBookStepFive_remainingPayment_bullet3 => '**Receipt:** You\'ll get a receipt regardless of how you pay';

  @override
  String get docsHowBookStepFive_confirmation_title => 'After Payment';

  @override
  String get docsHowBookStepFive_confirmation_content => 'Once your deposit payment is successful:';

  @override
  String get docsHowBookStepFive_confirmation_bullet1 => 'You\'ll see a confirmation screen';

  @override
  String get docsHowBookStepFive_confirmation_bullet2 => 'The booking appears in \"My Bookings\"';

  @override
  String get docsHowBookStepFive_confirmation_bullet3 => 'You\'ll receive an email confirmation';

  @override
  String get docsHowBookStepFive_confirmation_bullet4 => 'The shop is notified of your booking';

  @override
  String get docsHowBookStepFive_confirmation_bullet5 => 'You\'ll get a reminder before your appointment';

  @override
  String get docsHowBookStepFive_paymentWarning_content => 'The 30% deposit and platform fee are non-refundable. Please be sure about your booking before confirming. You can reschedule up to 24 hours before, but the deposit and fee remain non-refundable.';

  @override
  String get docsHowBookAfterBooking_title => 'After You Book';

  @override
  String get docsHowBookAfterBooking_subtitle => 'What happens next';

  @override
  String get docsHowBookAfterBooking_whatsNext_title => 'Your Booking is Confirmed!';

  @override
  String get docsHowBookAfterBooking_whatsNext_content => 'Here\'s what you can do after booking:';

  @override
  String get docsHowBookAfterBooking_whatsNext_bullet1 => '**View Booking:** Check details in \"My Bookings\"';

  @override
  String get docsHowBookAfterBooking_whatsNext_bullet2 => '**Reschedule:** Change the time (up to 24 hours before)';

  @override
  String get docsHowBookAfterBooking_whatsNext_bullet3 => '**Cancel:** Cancel if needed (deposit and fee are non-refundable)';

  @override
  String get docsHowBookAfterBooking_whatsNext_bullet4 => '**Contact Shop:** Message the shop directly';

  @override
  String get docsHowBookAfterBooking_whatsNext_bullet5 => '**Add to Calendar:** Export to your phone\'s calendar';

  @override
  String get docsHowBookAfterBooking_reminders_title => 'Booking Reminders';

  @override
  String get docsHowBookAfterBooking_reminders_content => 'You\'ll receive reminders at:';

  @override
  String get docsHowBookAfterBooking_reminders_bullet1 => '**24 hours before:** Check you\'re still coming';

  @override
  String get docsHowBookAfterBooking_reminders_bullet2 => '**1 hour before:** Time to head to the shop';

  @override
  String get docsHowBookAfterBooking_reminders_bullet3 => '**After appointment:** Option to leave a review and pay remaining balance';

  @override
  String get docsHowBookAfterBooking_afterService_title => 'After Your Service';

  @override
  String get docsHowBookAfterBooking_afterService_content => 'Once your service is complete:';

  @override
  String get docsHowBookAfterBooking_afterService_bullet1 => '**Pay Remaining 70%:** In cash or through the app';

  @override
  String get docsHowBookAfterBooking_afterService_bullet2 => '**Rate Your Experience:** Leave a review for the shop and worker';

  @override
  String get docsHowBookAfterBooking_afterService_bullet3 => '**Tip Your Worker:** Optional tip can be added';

  @override
  String get docsHowBookAfterBooking_afterService_bullet4 => '**Book Again:** Easily rebook with the same shop or worker';

  @override
  String get docsHowBookAfterBooking_afterTip_content => 'Arrive 5-10 minutes before your appointment time to check in. This gives you time to settle in before your service starts.';

  @override
  String get docsHowBookFaq11 => 'How do I cancel a booking?';

  @override
  String get docsHowBookFaq21 => 'Go to \"My Bookings\", find the booking, and tap \"Cancel\". You can cancel up to 24 hours before the appointment. The 30% deposit and platform fee are non-refundable, but you won\'t be charged the remaining 70%.';

  @override
  String get docsHowBookFaq32 => 'Can I change my appointment time?';

  @override
  String get docsHowBookFaq42 => 'Yes! Go to \"My Bookings\", find your booking, and tap \"Reschedule\". You can choose a new time if available. The deposit and fee remain applied to your new booking.';

  @override
  String get docsHowBookFaq53 => 'Why do I need to pay a deposit?';

  @override
  String get docsHowBookFaq63 => 'The 30% deposit protects both you and the shop. It ensures your slot is reserved exclusively for you, and compensates the worker if you cancel last minute. The deposit goes toward your total bill.';

  @override
  String get docsHowBookFaq74 => 'What is the platform fee?';

  @override
  String get docsHowBookFaq84 => 'The platform fee (e.g., GHS 2 per booking) is a small fixed charge by the app, not the shop. It helps us maintain the platform and provide you with a smooth booking experience. The fee is clearly shown before you confirm.';

  @override
  String get docsHowBookFaq95 => 'Is the deposit ever refundable?';

  @override
  String get docsHowBookFaq105 => 'The deposit and platform fee are non-refundable by policy. However, in genuine emergency situations, you can contact the shop directly through the app. Some shops may offer credit toward a future booking at their discretion, but the platform fee cannot be refunded.';

  @override
  String get docsHowBookFaq116 => 'How do I pay the remaining 70%?';

  @override
  String get docsHowBookFaq126 => 'After your service, you have two options: pay in cash directly to the shop, or pay through the app using your preferred payment method. Both options are accepted at participating shops.';

  @override
  String get docsHowBookFaq137 => 'Can I book multiple services at once?';

  @override
  String get docsHowBookFaq147 => 'Absolutely! You can select multiple services (like haircut + beard trim) and book them together. The system will find time slots where all services can be done.';

  @override
  String get docsHowBookFaq158 => 'How do I book for multiple people?';

  @override
  String get docsHowBookFaq168 => 'After selecting a service, use the **+** button to increase the quantity. For example, if you\'re booking haircuts for yourself and two children, set quantity to 3. You can then choose different workers for each person.';

  @override
  String get docsHowBookFaq179 => 'Can I change my chosen worker after booking?';

  @override
  String get docsHowBookFaq189 => 'Yes, you can change your worker up to 24 hours before the appointment. Go to \"My Bookings\", find your booking, and look for the option to change worker. The new worker must be available at your booked time.';

  @override
  String get docsHowBookFaq191 => 'What payment methods are accepted for the deposit?';

  @override
  String get docsHowBookFaq201 => 'We accept various payment methods depending on your region, including credit/debit cards, mobile money, and bank transfers. Available options will be shown during checkout.';

  @override
  String get docsHowBookFaq211 => 'When should I use Combined View?';

  @override
  String get docsHowBookFaq221 => 'Use Combined View when you\'ve selected multiple services. It shows only time slots where all your services can be done together, saving you from trying to coordinate separate times.';

  @override
  String get docsHowBookFaq231 => 'What happens if I don\'t show up?';

  @override
  String get docsHowBookFaq241 => 'If you don\'t show up for your appointment, the 30% deposit and platform fee are kept. You may also be marked as a \"no-show\". Repeated no-shows may result in restrictions on your account.';

  @override
  String get docsHowBookFaq251 => 'Can I really pay the remaining amount in cash?';

  @override
  String get docsHowBookFaq261 => 'Yes! Many shops accept cash for the remaining 70%. You can also choose to pay through the app if you prefer. The choice is yours at the time of service.';

  @override
  String get docsHowBookFaq271 => 'Is the platform fee charged per service or per booking?';

  @override
  String get docsHowBookFaq281 => 'The platform fee is charged **per booking**, not per service. So whether you book one service or multiple services together, you pay the platform fee only once.';

  @override
  String get docsHowBookFaq291 => 'Can I book without creating an account?';

  @override
  String get docsHowBookFaq301 => 'Yes! If a shop shares a booking link with you, you can book directly without an account or downloading the app. Follow the same booking steps, and your confirmation and receipt are sent to your WhatsApp.';

  @override
  String get docsHowBookFaq1Q => 'How do I cancel a booking?';

  @override
  String get docsHowBookFaq1A => 'Go to \"My Bookings\", find the booking, and tap \"Cancel\". You can cancel up to 24 hours before the appointment. The 30% deposit and platform fee are non-refundable, but you won\'t be charged the remaining 70%.';

  @override
  String get docsHowBookFaq2Q => 'Can I change my appointment time?';

  @override
  String get docsHowBookFaq2A => 'Yes! Go to \"My Bookings\", find your booking, and tap \"Reschedule\". You can choose a new time if available. The deposit and fee remain applied to your new booking.';

  @override
  String get docsHowBookFaq3Q => 'Why do I need to pay a deposit?';

  @override
  String get docsHowBookFaq3A => 'The 30% deposit protects both you and the shop. It ensures your slot is reserved exclusively for you, and compensates the worker if you cancel last minute. The deposit goes toward your total bill.';

  @override
  String get docsHowBookFaq4Q => 'What is the platform fee?';

  @override
  String get docsHowBookFaq4A => 'The platform fee (e.g., GHS 2 per booking) is a small fixed charge by the app, not the shop. It helps us maintain the platform and provide you with a smooth booking experience. The fee is clearly shown before you confirm.';

  @override
  String get docsHowBookFaq5Q => 'Is the deposit ever refundable?';

  @override
  String get docsHowBookFaq5A => 'The deposit and platform fee are non-refundable by policy. However, in genuine emergency situations, you can contact the shop directly through the app. Some shops may offer credit toward a future booking at their discretion, but the platform fee cannot be refunded.';

  @override
  String get docsHowBookFaq6Q => 'How do I pay the remaining 70%?';

  @override
  String get docsHowBookFaq6A => 'After your service, you have two options: pay in cash directly to the shop, or pay through the app using your preferred payment method. Both options are accepted at participating shops.';

  @override
  String get docsHowBookFaq7Q => 'Can I book multiple services at once?';

  @override
  String get docsHowBookFaq7A => 'Absolutely! You can select multiple services (like haircut + beard trim) and book them together. The system will find time slots where all services can be done.';

  @override
  String get docsHowBookFaq8Q => 'How do I book for multiple people?';

  @override
  String get docsHowBookFaq8A => 'After selecting a service, use the **+** button to increase the quantity. For example, if you\'re booking haircuts for yourself and two children, set quantity to 3. You can then choose different workers for each person.';

  @override
  String get docsHowBookFaq9Q => 'Can I change my chosen worker after booking?';

  @override
  String get docsHowBookFaq9A => 'Yes, you can change your worker up to 24 hours before the appointment. Go to \"My Bookings\", find your booking, and look for the option to change worker. The new worker must be available at your booked time.';

  @override
  String get docsHowBookFaq10Q => 'What payment methods are accepted for the deposit?';

  @override
  String get docsHowBookFaq10A => 'We accept various payment methods depending on your region, including credit/debit cards, mobile money, and bank transfers. Available options will be shown during checkout.';

  @override
  String get docsHowBookFaq11Q => 'When should I use Combined View?';

  @override
  String get docsHowBookFaq11A => 'Use Combined View when you\'ve selected multiple services. It shows only time slots where all your services can be done together, saving you from trying to coordinate separate times.';

  @override
  String get docsHowBookFaq12Q => 'What happens if I don\'t show up?';

  @override
  String get docsHowBookFaq12A => 'If you don\'t show up for your appointment, the 30% deposit and platform fee are kept. You may also be marked as a \"no-show\". Repeated no-shows may result in restrictions on your account.';

  @override
  String get docsHowBookFaq13Q => 'Can I really pay the remaining amount in cash?';

  @override
  String get docsHowBookFaq13A => 'Yes! Many shops accept cash for the remaining 70%. You can also choose to pay through the app if you prefer. The choice is yours at the time of service.';

  @override
  String get docsHowBookFaq14Q => 'Is the platform fee charged per service or per booking?';

  @override
  String get docsHowBookFaq14A => 'The platform fee is charged **per booking**, not per service. So whether you book one service or multiple services together, you pay the platform fee only once.';

  @override
  String get docsHowBookFaq15Q => 'Can I book without creating an account?';

  @override
  String get docsHowBookFaq15A => 'Yes! If a shop shares a booking link with you, you can book directly without an account or downloading the app. Follow the same booking steps, and your confirmation and receipt are sent to your WhatsApp.';

  @override
  String get docsGroupBookingsIntro_title => 'What Are Group Bookings?';

  @override
  String get docsGroupBookingsIntro_subtitle => 'Booking for family, friends, or groups made simple';

  @override
  String get docsGroupBookingsHowTo_title => 'How to Make a Group Booking';

  @override
  String get docsGroupBookingsHowTo_subtitle => 'Step-by-step guide';

  @override
  String get docsGroupBookingsWorker_title => 'Worker Selection for Groups';

  @override
  String get docsGroupBookingsWorker_subtitle => 'How workers are assigned';

  @override
  String get docsGroupBookingsTime_title => 'Time Slots for Groups';

  @override
  String get docsGroupBookingsTime_subtitle => 'How appointment times work for groups';

  @override
  String get docsGroupBookingsPayment_title => 'Payment for Group Bookings';

  @override
  String get docsGroupBookingsPayment_subtitle => 'How deposits and fees work';

  @override
  String get docsGroupBookingsScenarios_title => 'Common Group Scenarios';

  @override
  String get docsGroupBookingsScenarios_subtitle => 'Real examples to help you understand';

  @override
  String get docsGroupBookingsIntro_explained_title => 'Booking for Multiple People';

  @override
  String get docsGroupBookingsIntro_explained_content => 'Group bookings allow you to book services for more than one person at a time. This is perfect for:';

  @override
  String get docsGroupBookingsIntro_explained_bullet1 => '**Families:** Parents booking haircuts for themselves and their children';

  @override
  String get docsGroupBookingsIntro_explained_bullet2 => '**Friends:** Group of friends getting services together';

  @override
  String get docsGroupBookingsIntro_explained_bullet3 => '**Events:** Bridal parties, birthdays, or special occasions';

  @override
  String get docsGroupBookingsIntro_explained_bullet4 => '**Colleagues:** Team building or work outings';

  @override
  String get docsGroupBookingsIntro_example_title => 'Real-Life Example';

  @override
  String get docsGroupBookingsIntro_example_content => '**The Mensah Family needs haircuts:**\n• Father: Wants a fade haircut\n• Mother: Wants a trim\n• Son (10): Wants a kids haircut\n• Daughter (8): Wants braids\n\nInstead of making 4 separate bookings, they can book everything together in one go!';

  @override
  String get docsGroupBookingsIntro_benefits_title => 'Benefits of Group Booking';

  @override
  String get docsGroupBookingsIntro_benefits_content => 'Booking as a group gives you:';

  @override
  String get docsGroupBookingsIntro_benefits_bullet1 => '**One transaction:** Pay deposits for everyone at once';

  @override
  String get docsGroupBookingsIntro_benefits_bullet2 => '**Coordinated timing:** Everyone gets served around the same time';

  @override
  String get docsGroupBookingsIntro_benefits_bullet3 => '**Different workers:** Each person can choose their preferred worker';

  @override
  String get docsGroupBookingsIntro_benefits_bullet4 => '**Simplified management:** View and manage all bookings together';

  @override
  String get docsGroupBookingsIntro_benefits_bullet5 => '**Better planning:** Shop can prepare for your group';

  @override
  String get docsGroupBookingsIntro_tip_content => 'Group bookings are perfect for families! You can book for yourself and your children in one go, choosing different workers for each person. No account needed? Use a booking link shared by the shop!';

  @override
  String get docsGroupBookingsHowTo_step1_title => 'Step 1: Select Your Service';

  @override
  String get docsGroupBookingsHowTo_step1_content => 'Start by finding a shop and selecting the service you want. For example, tap on \"Haircut\".';

  @override
  String get docsGroupBookingsHowTo_step2_title => 'Step 2: Choose the Quantity';

  @override
  String get docsGroupBookingsHowTo_step2_content => 'After selecting a service, you\'ll see **+** and **-** buttons. Use these to set how many people need this service:';

  @override
  String get docsGroupBookingsHowTo_step2_bullet1 => 'Tap **+** to increase the number';

  @override
  String get docsGroupBookingsHowTo_step2_bullet2 => 'Tap **-** to decrease';

  @override
  String get docsGroupBookingsHowTo_step2_bullet3 => 'The price updates automatically';

  @override
  String get docsGroupBookingsHowTo_step2_bullet4 => 'You cannot exceed the maximum quantity shown';

  @override
  String get docsGroupBookingsHowTo_step2Example_title => 'Example';

  @override
  String get docsGroupBookingsHowTo_step2Example_content => '**For a family of 3 needing haircuts:**\n• Select \"Haircut\" service\n• Tap **+** twice (or until quantity shows 3)\n• Total price shows: 3 × GHS 45 = GHS 135';

  @override
  String get docsGroupBookingsHowTo_step3_title => 'Step 3: Repeat for Each Service';

  @override
  String get docsGroupBookingsHowTo_step3_content => 'If your group needs different services (e.g., some want haircuts, others want braids), select each service and set the quantity for each:';

  @override
  String get docsGroupBookingsHowTo_step3_bullet1 => 'Select \"Haircut\" → set quantity 2';

  @override
  String get docsGroupBookingsHowTo_step3_bullet2 => 'Select \"Braids\" → set quantity 1';

  @override
  String get docsGroupBookingsHowTo_step3_bullet3 => 'The system keeps track of all selections';

  @override
  String get docsGroupBookingsHowTo_step3Example_title => 'Example: Mixed Services';

  @override
  String get docsGroupBookingsHowTo_step3Example_content => '**Family of 4 with different needs:**\n• Dad: Haircut (quantity 1)\n• Mom: Trim (quantity 1)\n• Son: Kids Haircut (quantity 1)\n• Daughter: Braids (quantity 1)\n\nTotal: 4 services, but you booked them all in one go!';

  @override
  String get docsGroupBookingsHowTo_step4_title => 'Step 4: Choose Workers for Each Person';

  @override
  String get docsGroupBookingsHowTo_step4_content => 'For services that let you choose workers, you\'ll see a list of people. Tap on each person to assign their worker:';

  @override
  String get docsGroupBookingsHowTo_step4_bullet1 => '**Person 1:** Choose John (fade specialist)';

  @override
  String get docsGroupBookingsHowTo_step4_bullet2 => '**Person 2:** Choose Sarah (braiding expert)';

  @override
  String get docsGroupBookingsHowTo_step4_bullet3 => '**Person 3:** Choose Michael (kids cuts)';

  @override
  String get docsGroupBookingsHowTo_step4_bullet4 => '**Person 4:** Choose John (same worker for multiple people)';

  @override
  String get docsGroupBookingsHowTo_step4Example_title => 'Example: Different Workers for Different People';

  @override
  String get docsGroupBookingsHowTo_step4Example_content => '**Family of 3 booking haircuts:**\n• Person 1 (Dad): Choose John (fade specialist)\n• Person 2 (Son): Choose Michael (great with kids)\n• Person 3 (Daughter): Choose Sarah (braiding expert)\n\nAll three will be served during your appointment block.';

  @override
  String get docsGroupBookingsHowTo_step5_title => 'Step 5: Pick Your Time';

  @override
  String get docsGroupBookingsHowTo_step5_content => 'When you select a date and time, the system will show slots that can accommodate ALL people in your group:';

  @override
  String get docsGroupBookingsHowTo_step5_bullet1 => '**Regular View:** Shows slots for each service separately';

  @override
  String get docsGroupBookingsHowTo_step5_bullet2 => '**Combined View:** Shows only slots where everyone can be served together';

  @override
  String get docsGroupBookingsHowTo_step5_bullet3 => '**Duration:** The time shown includes all services for all people';

  @override
  String get docsGroupBookingsHowTo_step5Example_title => 'Example: Time Calculation';

  @override
  String get docsGroupBookingsHowTo_step5Example_content => '**Family booking:**\n• Haircut (45 min) × 2 people = 90 min\n• Braids (2 hours) × 1 person = 120 min\n• Buffer time between services = 15 min\n• **Total appointment time: 3 hours 45 min**\n\nThe system handles all this automatically!';

  @override
  String get docsGroupBookingsHowTo_step6_title => 'Step 6: Payment';

  @override
  String get docsGroupBookingsHowTo_step6_content => 'For group bookings, you pay:';

  @override
  String get docsGroupBookingsHowTo_step6_bullet1 => '**30% deposit:** Calculated on the TOTAL cost of all services';

  @override
  String get docsGroupBookingsHowTo_step6_bullet2 => '**Platform fee:** Small fixed fee (e.g., GHS 2) - charged ONCE for entire group';

  @override
  String get docsGroupBookingsHowTo_step6_bullet3 => '**Remaining 70%:** Paid after all services are complete';

  @override
  String get docsGroupBookingsHowTo_step6_bullet4 => '**Payment options:** Cash, card, mobile money, or app payment';

  @override
  String get docsGroupBookingsHowTo_step6Example_title => 'Payment Example';

  @override
  String get docsGroupBookingsHowTo_step6Example_content => '**Family booking total: GHS 400**\n• Deposit at booking: GHS 120 (30% of GHS 400)\n• Platform fee: GHS 2 (charged once for entire group)\n• **Total to pay now: GHS 122**\n• Remaining after service: GHS 280\n• **Payment after:** Cash to worker/shop OR via app (your choice)';

  @override
  String get docsGroupBookingsHowTo_important_content => 'The deposit and platform fee are calculated on the TOTAL group booking, not per person. You pay once for the whole group.';

  @override
  String get docsGroupBookingsWorker_intro_title => 'One Worker or Multiple Workers?';

  @override
  String get docsGroupBookingsWorker_intro_content => 'When booking for a group, you have flexibility in how workers are assigned:';

  @override
  String get docsGroupBookingsWorker_intro_bullet1 => '**Same worker for everyone:** If one worker can handle everyone (sequentially)';

  @override
  String get docsGroupBookingsWorker_intro_bullet2 => '**Different workers:** Each person can have their preferred worker';

  @override
  String get docsGroupBookingsWorker_intro_bullet3 => '**Mix and match:** Some people share a worker, others have different ones';

  @override
  String get docsGroupBookingsWorker_same_title => 'Same Worker for Everyone';

  @override
  String get docsGroupBookingsWorker_same_content => 'If you choose the same worker for everyone, they will serve each person one after another. The total time is the sum of all services plus buffers.';

  @override
  String get docsGroupBookingsWorker_different_title => 'Different Workers for Different People';

  @override
  String get docsGroupBookingsWorker_different_content => 'When you choose different workers, they can work in parallel. This might reduce the total time needed. Example:';

  @override
  String get docsGroupBookingsWorker_different_bullet1 => '**Worker A:** Serves Person 1 (haircut)';

  @override
  String get docsGroupBookingsWorker_different_bullet2 => '**Worker B:** Serves Person 2 (braids) at the same time';

  @override
  String get docsGroupBookingsWorker_different_bullet3 => '**Worker A:** Then serves Person 3 (beard trim)';

  @override
  String get docsGroupBookingsWorker_different_bullet4 => '**Result:** Everyone finishes faster!';

  @override
  String get docsGroupBookingsWorker_interface_title => 'How to Assign Workers';

  @override
  String get docsGroupBookingsWorker_interface_content => 'In the worker selection screen, you\'ll see each person listed separately:';

  @override
  String get docsGroupBookingsWorker_example_title => 'What You\'ll See';

  @override
  String get docsGroupBookingsWorker_example_content => '**For a group of 3 booking haircuts:**\n• **Person 1:** [Choose Worker] → John\n• **Person 2:** [Choose Worker] → Michael\n• **Person 3:** [Choose Worker] → John (again)\n\nTap each person to select their worker from the available list.';

  @override
  String get docsGroupBookingsWorker_tip_content => 'If a worker is already chosen for one person, they remain available for others unless fully booked. The system shows real-time availability.';

  @override
  String get docsGroupBookingsTime_calculation_title => 'How Duration is Calculated';

  @override
  String get docsGroupBookingsTime_calculation_content => 'For group bookings, the total appointment time is calculated based on:';

  @override
  String get docsGroupBookingsTime_calculation_bullet1 => '**Service duration × quantity** for each service type';

  @override
  String get docsGroupBookingsTime_calculation_bullet2 => '**Buffer time** between services (for cleanup)';

  @override
  String get docsGroupBookingsTime_calculation_bullet3 => '**Parallel work** if multiple workers are assigned';

  @override
  String get docsGroupBookingsTime_sequential_title => 'Example: Sequential (Same Worker)';

  @override
  String get docsGroupBookingsTime_sequential_content => '**One worker doing 3 haircuts (45 min each):**\n• Haircut 1: 9:00 - 9:45\n• Buffer: 9:45 - 9:50 (5 min)\n• Haircut 2: 9:50 - 10:35\n• Buffer: 10:35 - 10:40\n• Haircut 3: 10:40 - 11:25\n• **Total: 2 hours 25 min**';

  @override
  String get docsGroupBookingsTime_parallel_title => 'Example: Parallel (Different Workers)';

  @override
  String get docsGroupBookingsTime_parallel_content => '**Three workers each doing one haircut (45 min each):**\n• Worker A: Person 1 (9:00 - 9:45)\n• Worker B: Person 2 (9:00 - 9:45) at same time\n• Worker C: Person 3 (9:00 - 9:45) at same time\n• **Total: 45 min**';

  @override
  String get docsGroupBookingsTime_combined_title => 'Combined View for Groups';

  @override
  String get docsGroupBookingsTime_combined_content => 'When booking for a group, Combined View is especially useful. It shows only time slots where ALL people in your group can be accommodated together, with the correct total duration.';

  @override
  String get docsGroupBookingsTime_tip_content => 'If your group is large or has many services, consider booking earlier in the day to ensure enough time before the shop closes.';

  @override
  String get docsGroupBookingsPayment_deposit_title => 'Deposit Calculation';

  @override
  String get docsGroupBookingsPayment_deposit_content => 'For group bookings, the 30% deposit is calculated on the **total cost of all services for all people**.';

  @override
  String get docsGroupBookingsPayment_deposit_bullet1 => '**Total cost:** Sum of all services × quantities';

  @override
  String get docsGroupBookingsPayment_deposit_bullet2 => '**Deposit:** 30% of total cost';

  @override
  String get docsGroupBookingsPayment_deposit_bullet3 => '**Platform fee:** One fixed fee for the entire group booking';

  @override
  String get docsGroupBookingsPayment_deposit_bullet4 => '**Total due now:** Deposit + platform fee';

  @override
  String get docsGroupBookingsPayment_example_title => 'Payment Example';

  @override
  String get docsGroupBookingsPayment_example_content => '**Family of 4 with total GHS 500:**\n• Deposit (30%): GHS 150\n• Platform fee: GHS 2\n• **Pay now: GHS 152**\n• Pay after: GHS 350 (cash or app)';

  @override
  String get docsGroupBookingsPayment_cancellation_title => 'Cancellation for Groups';

  @override
  String get docsGroupBookingsPayment_cancellation_content => 'If you cancel a group booking:';

  @override
  String get docsGroupBookingsPayment_cancellation_bullet1 => '**Full group cancellation:** Entire deposit and fee are non-refundable';

  @override
  String get docsGroupBookingsPayment_cancellation_bullet2 => '**Partial cancellation:** If some people can\'t make it, you may lose their portion of the deposit';

  @override
  String get docsGroupBookingsPayment_cancellation_bullet3 => '**Rescheduling:** You can reschedule the whole group (deposit transfers)';

  @override
  String get docsGroupBookingsPayment_important_content => 'The platform fee is charged once per group booking, not per person. You save on fees by booking as a group! For example: 4 separate bookings = GHS 8 in fees, but 1 group booking = GHS 2 fee. You save GHS 6!';

  @override
  String get docsGroupBookingsPayment_flexibility_title => 'Flexible Payment After Service';

  @override
  String get docsGroupBookingsPayment_flexibility_content => 'After your group service, paying the remaining 70% is flexible:';

  @override
  String get docsGroupBookingsPayment_flexibility_bullet1 => '**One person pays all:** Pay total in cash or via app';

  @override
  String get docsGroupBookingsPayment_flexibility_bullet2 => '**Split the payment:** Each person pays their share in cash';

  @override
  String get docsGroupBookingsPayment_flexibility_bullet3 => '**Mix methods:** Some people use cash, others use app';

  @override
  String get docsGroupBookingsPayment_flexibility_bullet4 => '**Individual app payments:** Each person can pay their portion through the app';

  @override
  String get docsGroupBookingsScenarios_family_title => 'Scenario 1: Family Haircut Day';

  @override
  String get docsGroupBookingsScenarios_family_content => '**The Mensah family (4 people) needs haircuts:**\n• Dad: Fade haircut (45 min, GHS 40)\n• Mom: Trim (30 min, GHS 35)\n• Son (10): Kids haircut (30 min, GHS 25)\n• Daughter (8): Braids (2 hours, GHS 80)\n\n**What they do:**\n1. Select \"Haircut\" → set quantity 3\n2. Select \"Braids\" → set quantity 1\n3. Choose workers: Dad → John, Son → Michael, Daughter → Sarah\n4. Pick a time that works for everyone\n5. Pay deposit: GHS 54 (30% of GHS 180) + GHS 2 fee = GHS 56\n6. After service, pay remaining GHS 126';

  @override
  String get docsGroupBookingsScenarios_friends_title => 'Scenario 2: Friends Day Out';

  @override
  String get docsGroupBookingsScenarios_friends_content => '**Three friends want different services:**\n• Friend 1: Beard trim (30 min, GHS 25)\n• Friend 2: Haircut + Beard (75 min, GHS 65)\n• Friend 3: Full color (2 hours, GHS 120)\n\n**What they do:**\n1. Select each service with quantity 1\n2. Choose their preferred workers\n3. System finds a time that works for all\n4. Pay deposit: GHS 63 (30% of GHS 210) + GHS 2 fee = GHS 65';

  @override
  String get docsGroupBookingsScenarios_bridal_title => 'Scenario 3: Bridal Party';

  @override
  String get docsGroupBookingsScenarios_bridal_content => '**Bride + 3 bridesmaids getting ready:**\n• Bride: Hair + Makeup (3 hours, GHS 300)\n• Each bridesmaid: Hair styling (1 hour, GHS 80 each)\n\n**What they do:**\n1. Select Bride services with quantity 1\n2. Select Hair styling with quantity 3\n3. Assign different workers to each person\n4. Book a morning slot to have enough time\n5. Pay deposit: GHS 162 (30% of GHS 540) + GHS 2 fee = GHS 164';

  @override
  String get docsGroupBookingsFaq1Q => 'What is a group booking?';

  @override
  String get docsGroupBookingsFaq1A => 'A group booking allows you to book services for multiple people at once. Instead of making separate bookings for each person, you can book everything together in one go. This is perfect for families, friends, or any group wanting services together.';

  @override
  String get docsGroupBookingsFaq2Q => 'How do I increase the number of people?';

  @override
  String get docsGroupBookingsFaq2A => 'After selecting a service, look for the **+** and **-** buttons. Tap **+** to increase the quantity (number of people) for that service. The price updates automatically. You cannot exceed the maximum quantity shown for that service.';

  @override
  String get docsGroupBookingsFaq3Q => 'Can we book different services for different people?';

  @override
  String get docsGroupBookingsFaq3A => 'Absolutely! You can select multiple services and set different quantities for each. For example, you can book 2 haircuts and 1 braid service all in the same booking. The system handles everything together.';

  @override
  String get docsGroupBookingsFaq4Q => 'Can different people have different workers?';

  @override
  String get docsGroupBookingsFaq4A => 'Yes! When you book for a group, you\'ll see each person listed separately. You can tap on each person to choose their preferred worker. This is great when different people have different preferences.';

  @override
  String get docsGroupBookingsFaq5Q => 'How is payment calculated for groups?';

  @override
  String get docsGroupBookingsFaq5A => 'The 30% deposit is calculated on the TOTAL cost of all services for all people. The platform fee is charged once for the entire group booking (not per person). After service, you pay the remaining 70% total (cash or app).';

  @override
  String get docsGroupBookingsFaq6Q => 'What if one person cancels?';

  @override
  String get docsGroupBookingsFaq6A => 'If someone in your group cancels, the deposit for their portion is non-refundable. The rest of the group can still proceed. Contact the shop through the app to adjust the booking.';

  @override
  String get docsGroupBookingsFaq7Q => 'How is the total appointment time calculated?';

  @override
  String get docsGroupBookingsFaq7A => 'The system calculates total time based on: service durations × quantities, plus buffer times between services. If you choose different workers who can work in parallel, the total time may be shorter.';

  @override
  String get docsGroupBookingsFaq8Q => 'Is there a maximum group size?';

  @override
  String get docsGroupBookingsFaq8A => 'Each service has a maximum quantity limit shown when booking. If you need to book for a very large group, you may need to make multiple bookings or contact the shop directly.';

  @override
  String get docsGroupBookingsFaq9Q => 'Can I book for my children?';

  @override
  String get docsGroupBookingsFaq9A => 'Yes! Group bookings are perfect for families. You can book for yourself and your children together. Just set the quantity to include everyone. For kids services, look for \"Kids\" options.';

  @override
  String get docsGroupBookingsFaq10Q => 'How does check-in work for groups?';

  @override
  String get docsGroupBookingsFaq10A => 'When you arrive, let the shop know you have a group booking. They\'ll check the main booking and direct everyone to their assigned workers. Arrive 10-15 minutes early for large groups.';

  @override
  String get docsGroupBookingsFaq11Q => 'Can we split the payment?';

  @override
  String get docsGroupBookingsFaq11A => 'The deposit is paid by the person making the booking. After service, you can split the remaining 70% however you like - cash, individual app payments, or one person paying for all.';

  @override
  String get docsGroupBookingsFaq12Q => 'Can we reschedule a group booking?';

  @override
  String get docsGroupBookingsFaq12A => 'Yes, you can reschedule the entire group booking up to 24 hours before the appointment. The deposit transfers to the new time. If only some people need to reschedule, contact the shop.';

  @override
  String get docsGroupBookingsFaq13Q => 'Can we book as a group without an account?';

  @override
  String get docsGroupBookingsFaq13A => 'Yes! If the shop shares a group booking link, everyone can use it without downloading the app or creating accounts. The booking confirmation and receipt details are sent to your WhatsApp.';

  @override
  String get docsGroupBookingsFaq14Q => 'Do we all have to pay in cash or can we use the app?';

  @override
  String get docsGroupBookingsFaq14A => 'You have full flexibility! You can pay the remaining 70% in cash (to the shop/worker), via the app individually, or any combination. Some people can pay cash while others use the app for their portion.';

  @override
  String get docsPaymentFeesExplainedPaymentOverview_title => 'How Payment Works';

  @override
  String get docsPaymentFeesExplainedPaymentOverview_subtitle => 'Simple, transparent, secure';

  @override
  String get docsPaymentFeesExplainedPaymentSummary_title => 'Payment at a Glance';

  @override
  String get docsPaymentFeesExplainedPaymentSummary_content => 'Our payment system is designed to be fair for both clients and shop owners. Here\'s the simple breakdown:';

  @override
  String get docsPaymentFeesExplainedPaymentSummary_bullet1 => '**30% Deposit:** Paid at booking to secure your appointment';

  @override
  String get docsPaymentFeesExplainedPaymentSummary_bullet2 => '**Platform Fee:** Small fixed fee (e.g., GHS 2) charged by the app';

  @override
  String get docsPaymentFeesExplainedPaymentSummary_bullet3 => '**Remaining 70%:** Paid after your service is complete';

  @override
  String get docsPaymentFeesExplainedPaymentSummary_bullet4 => '**Two Ways to Pay Remaining:** Cash or via app';

  @override
  String get docsPaymentFeesExplainedPaymentExampleQuick_title => 'Quick Example';

  @override
  String get docsPaymentFeesExplainedPaymentExampleQuick_content => '**Service cost: GHS 100**\n• At booking: Pay GHS 30 (deposit) + GHS 2 (fee) = GHS 32\n• After service: Pay GHS 70 (cash or app)\n• Total to shop: GHS 100\n• Platform fee: GHS 2';

  @override
  String get docsPaymentFeesExplainedPaymentImportant_content => 'The platform fee is charged by the app, not the shop. It helps us maintain the platform and provide you with a great booking experience.';

  @override
  String get docsPaymentFeesExplainedGuestBookingNote_title => 'Guest Booking (No App Download)';

  @override
  String get docsPaymentFeesExplainedGuestBookingNote_content => 'Don\'t have the app? No problem! You can still book through your provider\'s booking link without creating an account. You pay the same 30% deposit + platform fee, and your receipt is sent to WhatsApp.';

  @override
  String get docsPaymentFeesExplainedDepositExplained_title => 'The 30% Deposit';

  @override
  String get docsPaymentFeesExplainedDepositExplained_subtitle => 'Why it\'s needed and how it works';

  @override
  String get docsPaymentFeesExplainedDepositWhy_title => 'Why Do We Require a Deposit?';

  @override
  String get docsPaymentFeesExplainedDepositWhy_content => 'The 30% deposit protects both you and the shop:';

  @override
  String get docsPaymentFeesExplainedDepositWhy_bullet1 => '**For you:** Your slot is guaranteed – no one else can book it';

  @override
  String get docsPaymentFeesExplainedDepositWhy_bullet2 => '**For the shop:** Workers are compensated if you cancel last minute';

  @override
  String get docsPaymentFeesExplainedDepositWhy_bullet3 => '**For everyone:** Reduces no-shows, keeping prices fair';

  @override
  String get docsPaymentFeesExplainedDepositCalculation_title => 'How the Deposit is Calculated';

  @override
  String get docsPaymentFeesExplainedDepositCalculation_content => 'The deposit is always **30% of the total service cost**. This includes:';

  @override
  String get docsPaymentFeesExplainedDepositCalculation_bullet1 => '**Single service:** 30% of that service price';

  @override
  String get docsPaymentFeesExplainedDepositCalculation_bullet2 => '**Multiple services:** 30% of all services combined';

  @override
  String get docsPaymentFeesExplainedDepositCalculation_bullet3 => '**Group bookings:** 30% of total for all people';

  @override
  String get docsPaymentFeesExplainedDepositExamples_title => 'Deposit Examples';

  @override
  String get docsPaymentFeesExplainedDepositExamples_content => '**Single Service:**\n• Haircut (GHS 45) → Deposit GHS 13.50\n\n**Multiple Services:**\n• Haircut (GHS 45) + Beard Trim (GHS 25) = GHS 70 total\n• Deposit: GHS 21\n\n**Group Booking (3 people):**\n• 3 × Haircut (GHS 45 each) = GHS 135 total\n• Deposit: GHS 40.50';

  @override
  String get docsPaymentFeesExplainedDepositNonRefundable_title => 'Deposit Refund Policy';

  @override
  String get docsPaymentFeesExplainedDepositNonRefundable_content => 'The 30% deposit is **non-refundable**. This means:';

  @override
  String get docsPaymentFeesExplainedDepositNonRefundable_bullet1 => '**If you cancel:** Deposit is not returned';

  @override
  String get docsPaymentFeesExplainedDepositNonRefundable_bullet2 => '**If you don\'t show up:** Deposit is not returned';

  @override
  String get docsPaymentFeesExplainedDepositNonRefundable_bullet3 => '**If you reschedule:** Deposit transfers to new time';

  @override
  String get docsPaymentFeesExplainedDepositNonRefundable_bullet4 => '**If shop cancels:** Full deposit refunded';

  @override
  String get docsPaymentFeesExplainedDepositWarning_content => 'Please be sure about your booking before paying the deposit. While you can reschedule, the deposit cannot be refunded if you cancel.';

  @override
  String get docsPaymentFeesExplainedPlatformFee_title => 'Platform Fee';

  @override
  String get docsPaymentFeesExplainedPlatformFee_subtitle => 'The small fee that keeps the app running';

  @override
  String get docsPaymentFeesExplainedFeeWhat_title => 'What is the Platform Fee?';

  @override
  String get docsPaymentFeesExplainedFeeWhat_content => 'The platform fee is a small fixed charge (e.g., GHS 2) that goes to the app, not the shop. It covers:';

  @override
  String get docsPaymentFeesExplainedFeeWhat_bullet1 => '**App development** and maintenance';

  @override
  String get docsPaymentFeesExplainedFeeWhat_bullet2 => '**Customer support** and dispute resolution';

  @override
  String get docsPaymentFeesExplainedFeeWhat_bullet3 => '**Payment processing** costs';

  @override
  String get docsPaymentFeesExplainedFeeWhat_bullet4 => '**New features** and improvements';

  @override
  String get docsPaymentFeesExplainedFeeHow_title => 'How the Fee is Charged';

  @override
  String get docsPaymentFeesExplainedFeeHow_content => 'Important things to know about the platform fee:';

  @override
  String get docsPaymentFeesExplainedFeeHow_bullet1 => '**Fixed amount** (not a percentage) – e.g., GHS 2 per booking';

  @override
  String get docsPaymentFeesExplainedFeeHow_bullet2 => '**Charged once per booking** – not per service or per person';

  @override
  String get docsPaymentFeesExplainedFeeHow_bullet3 => '**Non-refundable** – even if you cancel';

  @override
  String get docsPaymentFeesExplainedFeeHow_bullet4 => '**Clearly shown** before you confirm payment';

  @override
  String get docsPaymentFeesExplainedFeeExamples_title => 'Platform Fee Examples';

  @override
  String get docsPaymentFeesExplainedFeeExamples_content => '**Single person, one service:** GHS 2 fee\n**Single person, multiple services:** GHS 2 fee (still one booking!)\n**Family of 4 booking together:** GHS 2 fee (entire group)\n\n**Compare to booking separately:**\n• 4 separate bookings = 4 × GHS 2 = GHS 8 in fees\n• 1 group booking = GHS 2 fee – **you save GHS 6!**';

  @override
  String get docsPaymentFeesExplainedFeeTip_content => 'Booking as a group saves you money on fees! Instead of paying the platform fee for each person, you pay just one fee for the entire group booking.';

  @override
  String get docsPaymentFeesExplainedRemainingPayment_title => 'Paying the Remaining 70%';

  @override
  String get docsPaymentFeesExplainedRemainingPayment_subtitle => 'Two convenient options';

  @override
  String get docsPaymentFeesExplainedRemainingOverview_title => 'After Your Service';

  @override
  String get docsPaymentFeesExplainedRemainingOverview_content => 'Once your service is complete, you have two ways to pay the remaining 70%:';

  @override
  String get docsPaymentFeesExplainedRemainingOverview_bullet1 => '**Option 1: Cash** – Pay the worker or shop directly';

  @override
  String get docsPaymentFeesExplainedRemainingOverview_bullet2 => '**Option 2: Via App** – Pay through the app using your preferred method';

  @override
  String get docsPaymentFeesExplainedRemainingCash_title => 'Paying with Cash';

  @override
  String get docsPaymentFeesExplainedRemainingCash_content => 'If you choose to pay the remaining balance in cash:';

  @override
  String get docsPaymentFeesExplainedRemainingCash_bullet1 => 'Simply hand the cash to your worker or at the counter';

  @override
  String get docsPaymentFeesExplainedRemainingCash_bullet2 => 'You\'ll still receive a receipt through the app';

  @override
  String get docsPaymentFeesExplainedRemainingCash_bullet3 => 'The shop will mark the payment as received';

  @override
  String get docsPaymentFeesExplainedRemainingCash_bullet4 => 'No additional fees';

  @override
  String get docsPaymentFeesExplainedRemainingApp_title => 'Paying Through the App';

  @override
  String get docsPaymentFeesExplainedRemainingApp_content => 'If you prefer to pay via the app:';

  @override
  String get docsPaymentFeesExplainedRemainingApp_bullet1 => 'Open your booking in \"My Bookings\"';

  @override
  String get docsPaymentFeesExplainedRemainingApp_bullet2 => 'Tap \"Pay Remaining Balance\"';

  @override
  String get docsPaymentFeesExplainedRemainingApp_bullet3 => 'Choose your payment method (card, mobile money, etc.)';

  @override
  String get docsPaymentFeesExplainedRemainingApp_bullet4 => 'Complete payment – instant confirmation';

  @override
  String get docsPaymentFeesExplainedRemainingApp_bullet5 => 'Receipt saved in the app';

  @override
  String get docsPaymentFeesExplainedRemainingChoice_title => 'Which Option Should You Choose?';

  @override
  String get docsPaymentFeesExplainedRemainingChoice_content => '**Choose cash if:** You prefer physical payment, have cash on hand, or want to tip in cash\n\n**Choose app if:** You want a digital record, don\'t carry cash, or prefer using mobile money/cards';

  @override
  String get docsPaymentFeesExplainedRemainingImportant_content => 'The remaining 70% is paid to the shop, not the platform. No additional platform fee is charged at this stage.';

  @override
  String get docsPaymentFeesExplainedPaymentTiming_title => 'When Payments Happen';

  @override
  String get docsPaymentFeesExplainedPaymentTiming_subtitle => 'A timeline of when you pay';

  @override
  String get docsPaymentFeesExplainedTimelineAtBooking_title => 'At Booking Time';

  @override
  String get docsPaymentFeesExplainedTimelineAtBooking_content => '**What you pay:**\n• 30% deposit\n• Platform fee (e.g., GHS 2)\n\n**What happens:** Your slot is secured immediately';

  @override
  String get docsPaymentFeesExplainedTimelineBefore_title => 'Before Appointment';

  @override
  String get docsPaymentFeesExplainedTimelineBefore_content => '**Nothing to pay** – just show up at your scheduled time!\n\nYou\'ll receive reminders 24 hours and 1 hour before.';

  @override
  String get docsPaymentFeesExplainedTimelineAfter_title => 'After Service';

  @override
  String get docsPaymentFeesExplainedTimelineAfter_content => '**What you pay:**\n• Remaining 70% of total cost\n\n**How to pay:**\n• Cash (to worker or shop)\n• Via app (digital payment)';

  @override
  String get docsPaymentFeesExplainedTimelineSummary_title => 'Payment Summary Example';

  @override
  String get docsPaymentFeesExplainedTimelineSummary_content => '**Total bill: GHS 200**\n━━━━━━━━━━━━━━━━━━━━━━━━━━\n**At booking:** GHS 60 (deposit) + GHS 2 (fee) = GHS 62\n**After service:** GHS 140 (remaining)\n**Total to shop:** GHS 200\n**Platform fee:** GHS 2';

  @override
  String get docsPaymentFeesExplainedCancellationRefunds_title => 'Cancellation & Refunds';

  @override
  String get docsPaymentFeesExplainedCancellationRefunds_subtitle => 'What happens when plans change';

  @override
  String get docsPaymentFeesExplainedCancelClient_title => 'If You Cancel';

  @override
  String get docsPaymentFeesExplainedCancelClient_content => '**You cancel more than 24 hours before:**\n• Deposit: ❌ Non-refundable\n• Platform fee: ❌ Non-refundable\n• Remaining 70%: Not charged\n\n**You cancel within 24 hours:**\n• Deposit: ❌ Non-refundable\n• Platform fee: ❌ Non-refundable\n• Remaining 70%: Not charged\n• Note: Last-minute cancellations may affect your account standing';

  @override
  String get docsPaymentFeesExplainedCancelNoShow_title => 'If You Don\'t Show Up';

  @override
  String get docsPaymentFeesExplainedCancelNoShow_content => '**No-show policy:**\n• Deposit: ❌ Forfeited\n• Platform fee: ❌ Forfeited\n• Remaining 70%: Not charged\n• Account: Marked as no-show\n• Repeated no-shows may result in account restrictions';

  @override
  String get docsPaymentFeesExplainedCancelShop_title => 'If the Shop Cancels';

  @override
  String get docsPaymentFeesExplainedCancelShop_content => '**Shop cancels for any reason:**\n• Deposit: ✅ Full refund\n• Platform fee: ✅ Full refund\n• Remaining 70%: Not applicable\n• You\'ll receive notification and refund automatically';

  @override
  String get docsPaymentFeesExplainedCancelReschedule_title => 'Rescheduling vs Cancelling';

  @override
  String get docsPaymentFeesExplainedCancelReschedule_content => '**Rescheduling** (changing time/date):\n• Deposit transfers to new booking\n• Platform fee transfers (no additional fee)\n• Available up to 24 hours before\n\n**Cancelling** (completely):\n• Deposit and fee are forfeited\n• Must rebook and pay deposit again';

  @override
  String get docsPaymentFeesExplainedCancelTip_content => 'If you can\'t make it, try to reschedule instead of cancelling. Your deposit transfers and you won\'t lose your money!';

  @override
  String get docsPaymentFeesExplainedGroupPayment_title => 'Payment for Group Bookings';

  @override
  String get docsPaymentFeesExplainedGroupPayment_subtitle => 'How it works when booking for multiple people';

  @override
  String get docsPaymentFeesExplainedGroupDeposit_title => 'Deposit for Groups';

  @override
  String get docsPaymentFeesExplainedGroupDeposit_content => 'For group bookings, the 30% deposit is calculated on the **total cost for everyone**.';

  @override
  String get docsPaymentFeesExplainedGroupDeposit_bullet1 => '**Example:** 4 people × GHS 50 each = GHS 200 total';

  @override
  String get docsPaymentFeesExplainedGroupDeposit_bullet2 => '**Deposit:** 30% of GHS 200 = GHS 60';

  @override
  String get docsPaymentFeesExplainedGroupDeposit_bullet3 => '**Paid by:** One person (the booker)';

  @override
  String get docsPaymentFeesExplainedGroupFee_title => 'Platform Fee for Groups';

  @override
  String get docsPaymentFeesExplainedGroupFee_content => '**Great news!** The platform fee is charged **once per booking**, not per person.';

  @override
  String get docsPaymentFeesExplainedGroupFee_bullet1 => '**Example:** Family of 4 booking together';

  @override
  String get docsPaymentFeesExplainedGroupFee_bullet2 => '**Fee:** GHS 2 total (not GHS 8)';

  @override
  String get docsPaymentFeesExplainedGroupFee_bullet3 => '**Savings:** GHS 6 compared to booking separately';

  @override
  String get docsPaymentFeesExplainedGroupRemaining_title => 'Paying the Remaining 70% for Groups';

  @override
  String get docsPaymentFeesExplainedGroupRemaining_content => 'After the service, you have flexibility:';

  @override
  String get docsPaymentFeesExplainedGroupRemaining_bullet1 => '**One person pays all:** Pay total remaining in cash or app';

  @override
  String get docsPaymentFeesExplainedGroupRemaining_bullet2 => '**Split the bill:** Each person pays their share (cash to shop or individual app payments)';

  @override
  String get docsPaymentFeesExplainedGroupRemaining_bullet3 => '**Mix and match:** Some pay cash, others use app';

  @override
  String get docsPaymentFeesExplainedGroupCancellation_title => 'Group Cancellations';

  @override
  String get docsPaymentFeesExplainedGroupCancellation_content => '**If one person cancels:**\n• Their portion of the deposit is forfeited\n• The rest of the group can proceed\n• Contact shop to adjust\n\n**If entire group cancels:**\n• Full deposit and fee forfeited (standard policy)';

  @override
  String get docsPaymentFeesExplainedGroupSaving_title => 'Group Savings Example';

  @override
  String get docsPaymentFeesExplainedGroupSaving_content => '**Family of 4 booking separately vs together:**\n\n**Separate bookings:**\n• 4 × GHS 2 platform fee = GHS 8 in fees\n\n**Group booking:**\n• 1 × GHS 2 platform fee = GHS 2\n• **You save GHS 6!**';

  @override
  String get docsPaymentFeesExplainedPaymentMethods_title => 'Accepted Payment Methods';

  @override
  String get docsPaymentFeesExplainedPaymentMethods_subtitle => 'How you can pay';

  @override
  String get docsPaymentFeesExplainedMethodsDeposit_title => 'For Deposits (at booking)';

  @override
  String get docsPaymentFeesExplainedMethodsDeposit_content => 'You can pay your deposit using:';

  @override
  String get docsPaymentFeesExplainedMethodsDeposit_bullet1 => '**Credit/Debit Cards** (Visa, Mastercard, etc.)';

  @override
  String get docsPaymentFeesExplainedMethodsDeposit_bullet2 => '**Mobile Money** (MTN, Vodafone, AirtelTigo)';

  @override
  String get docsPaymentFeesExplainedMethodsDeposit_bullet3 => '**Bank Transfers** (instant payment)';

  @override
  String get docsPaymentFeesExplainedMethodsDeposit_bullet4 => '**Apple Pay / Google Pay** (where available)';

  @override
  String get docsPaymentFeesExplainedMethodsRemaining_title => 'For Remaining Balance (after service)';

  @override
  String get docsPaymentFeesExplainedMethodsRemaining_content => 'After your service, you can pay the remaining 70% via:';

  @override
  String get docsPaymentFeesExplainedMethodsRemaining_bullet1 => '**Cash** (pay directly to worker or shop)';

  @override
  String get docsPaymentFeesExplainedMethodsRemaining_bullet2 => '**Mobile Money** (send to shop number)';

  @override
  String get docsPaymentFeesExplainedMethodsRemaining_bullet3 => '**Card** (if shop has card reader)';

  @override
  String get docsPaymentFeesExplainedMethodsRemaining_bullet4 => '**App Payment** (through the app)';

  @override
  String get docsPaymentFeesExplainedMethodsSecurity_title => 'Payment Security';

  @override
  String get docsPaymentFeesExplainedMethodsSecurity_content => 'All payments through the app are:';

  @override
  String get docsPaymentFeesExplainedMethodsSecurity_bullet1 => '**Encrypted** – your information is safe';

  @override
  String get docsPaymentFeesExplainedMethodsSecurity_bullet2 => '**PCI compliant** – meets security standards';

  @override
  String get docsPaymentFeesExplainedMethodsSecurity_bullet3 => '**Protected** – fraud monitoring in place';

  @override
  String get docsPaymentFeesExplainedMethodsSecurity_bullet4 => '**Receipt provided** – digital record of every payment';

  @override
  String get docsPaymentFeesExplainedMethodsTip_content => 'Save your payment details in the app for faster checkout next time!';

  @override
  String get docsPaymentFeesExplainedGuestBookings_title => 'Guest Bookings (No App Download)';

  @override
  String get docsPaymentFeesExplainedGuestBookings_subtitle => 'Book without creating an account';

  @override
  String get docsPaymentFeesExplainedGuestWhat_title => 'What is a Guest Booking?';

  @override
  String get docsPaymentFeesExplainedGuestWhat_content => 'A guest booking lets you reserve an appointment without downloading the app or creating an account. Your provider shares a link – you click it and book directly.';

  @override
  String get docsPaymentFeesExplainedGuestPayment_title => 'How Guest Booking Payment Works';

  @override
  String get docsPaymentFeesExplainedGuestPayment_content => 'Guest bookings follow the same payment model as app bookings:';

  @override
  String get docsPaymentFeesExplainedGuestPayment_bullet1 => '**30% Deposit** – Pay upfront to secure your slot';

  @override
  String get docsPaymentFeesExplainedGuestPayment_bullet2 => '**Platform Fee** – Small fixed fee added to deposit';

  @override
  String get docsPaymentFeesExplainedGuestPayment_bullet3 => '**70% Balance** – Pay cash or online after service';

  @override
  String get docsPaymentFeesExplainedGuestWhatsapp_title => 'Booking Details via WhatsApp';

  @override
  String get docsPaymentFeesExplainedGuestWhatsapp_content => 'Once you complete your guest booking, your appointment details and payment receipt are sent to your WhatsApp. This way you can track everything without the app.';

  @override
  String get docsPaymentFeesExplainedGuestBenefits_title => 'Why Book as a Guest?';

  @override
  String get docsPaymentFeesExplainedGuestBenefits_content => 'Guest bookings are perfect if:';

  @override
  String get docsPaymentFeesExplainedGuestBenefits_bullet1 => 'You don\'t want to download another app';

  @override
  String get docsPaymentFeesExplainedGuestBenefits_bullet2 => 'You\'re booking for a one-time appointment';

  @override
  String get docsPaymentFeesExplainedGuestBenefits_bullet3 => 'You prefer simple, hassle-free booking';

  @override
  String get docsPaymentFeesExplainedGuestBenefits_bullet4 => 'Your provider shared a direct link with you';

  @override
  String get docsPaymentFeesExplainedGuestConvert_title => 'Convert Guest to Account';

  @override
  String get docsPaymentFeesExplainedGuestConvert_content => 'If you make multiple bookings, you can create a full account anytime to access your booking history, saved payments, and loyalty benefits.';

  @override
  String get docsPaymentFeesExplainedReceipts_title => 'Receipts & Records';

  @override
  String get docsPaymentFeesExplainedReceipts_subtitle => 'Keeping track of your payments';

  @override
  String get docsPaymentFeesExplainedReceiptWhat_title => 'What You\'ll Receive';

  @override
  String get docsPaymentFeesExplainedReceiptWhat_content => 'For every payment, you\'ll get:';

  @override
  String get docsPaymentFeesExplainedReceiptWhat_bullet1 => '**Booking confirmation receipt** (at booking)';

  @override
  String get docsPaymentFeesExplainedReceiptWhat_bullet2 => '**Deposit payment receipt** (immediate)';

  @override
  String get docsPaymentFeesExplainedReceiptWhat_bullet3 => '**Final payment receipt** (after service)';

  @override
  String get docsPaymentFeesExplainedReceiptWhat_bullet4 => '**Email copy** sent to your registered email';

  @override
  String get docsPaymentFeesExplainedReceiptWhat_bullet5 => '**In-app record** in \"My Bookings\"';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_title => 'What\'s on Your Receipt';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_content => 'Each receipt shows:';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_bullet1 => '**Shop name** and location';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_bullet2 => '**Services booked** with quantities';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_bullet3 => '**Workers assigned**';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_bullet4 => '**Date and time** of appointment';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_bullet5 => '**Amount paid** (deposit/fee/remaining)';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_bullet6 => '**Payment method** used';

  @override
  String get docsPaymentFeesExplainedReceiptInfo_bullet7 => '**Transaction reference** number';

  @override
  String get docsPaymentFeesExplainedReceiptAccess_title => 'How to Access Receipts';

  @override
  String get docsPaymentFeesExplainedReceiptAccess_content => 'To view your payment history:';

  @override
  String get docsPaymentFeesExplainedReceiptAccess_bullet1 => 'Go to **Profile** tab';

  @override
  String get docsPaymentFeesExplainedReceiptAccess_bullet2 => 'Tap **Payment History**';

  @override
  String get docsPaymentFeesExplainedReceiptAccess_bullet3 => 'See all transactions';

  @override
  String get docsPaymentFeesExplainedReceiptAccess_bullet4 => 'Tap any receipt to view details';

  @override
  String get docsPaymentFeesExplainedReceiptAccess_bullet5 => 'Share or download as PDF';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ_title => 'Common Payment Questions';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ_subtitle => 'Quick answers';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ1_title => 'Is the deposit really non-refundable?';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ1_content => 'Yes, the 30% deposit is non-refundable by policy. This protects workers\' time and discourages last-minute cancellations. The only exception is if the shop cancels on you.';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ2_title => 'Why a deposit instead of full payment?';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ2_content => 'The deposit system is designed to be fair to everyone:\n• **You:** Only pay 30% upfront, not the full amount\n• **Shop:** Gets some compensation if you cancel\n• **Workers:** Time is valued and protected';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ3_title => 'Can I pay the full amount upfront?';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ3_content => 'Currently, we only collect the 30% deposit at booking. The remaining 70% is paid after service to ensure you\'re happy with the result before paying in full.';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ4_title => 'What if I want to add a tip?';

  @override
  String get docsPaymentFeesExplainedPaymentFAQ4_content => 'Great question! Tips can be added when paying the remaining 70% via the app, or you can tip in cash directly to your worker. 100% of tips go to the worker.';

  @override
  String get docsPaymentFeesExplainedFaq1Q => 'Why is the deposit non-refundable?';

  @override
  String get docsPaymentFeesExplainedFaq1A => 'The deposit compensates workers for holding time exclusively for you. When you book a slot, that time can\'t be sold to someone else. The deposit policy discourages last-minute cancellations and no-shows, which helps keep prices fair for everyone.';

  @override
  String get docsPaymentFeesExplainedFaq2Q => 'What exactly is the platform fee for?';

  @override
  String get docsPaymentFeesExplainedFaq2A => 'The platform fee (e.g., GHS 2) helps us maintain the app, provide customer support, process payments securely, and develop new features. It\'s a small fixed fee that keeps the platform running smoothly for both clients and shops.';

  @override
  String get docsPaymentFeesExplainedFaq3Q => 'Can I really pay the remaining amount in cash?';

  @override
  String get docsPaymentFeesExplainedFaq3A => 'Yes! Many shops accept cash for the remaining 70%. You can also choose to pay through the app if you prefer digital payments. The choice is yours at the time of service.';

  @override
  String get docsPaymentFeesExplainedFaq4Q => 'How is the platform fee calculated for groups?';

  @override
  String get docsPaymentFeesExplainedFaq4A => 'The platform fee is charged **once per booking**, not per person. So if you book for a family of 4, you pay just one GHS 2 fee instead of four separate fees. This makes group bookings more economical!';

  @override
  String get docsPaymentFeesExplainedFaq5Q => 'When would I get a refund?';

  @override
  String get docsPaymentFeesExplainedFaq5A => 'Refunds are issued only if the shop cancels your booking. In that case, both your deposit and platform fee are fully refunded. If you cancel, the deposit and fee are non-refundable by policy.';

  @override
  String get docsPaymentFeesExplainedFaq6Q => 'What payment methods are accepted?';

  @override
  String get docsPaymentFeesExplainedFaq6A => 'For deposits: Credit/debit cards, mobile money, bank transfers, and digital wallets. For remaining balance: Cash or any of the digital methods through the app. Available options may vary by region.';

  @override
  String get docsPaymentFeesExplainedFaq7Q => 'How do I tip my worker?';

  @override
  String get docsPaymentFeesExplainedFaq7A => 'You can tip your worker in two ways:\n1. **Cash:** Give directly to your worker after service\n2. **Via App:** Add a tip when paying the remaining 70%\n\n100% of tips go directly to your worker!';

  @override
  String get docsPaymentFeesExplainedFaq8Q => 'How do I get a receipt?';

  @override
  String get docsPaymentFeesExplainedFaq8A => 'Receipts are automatically generated and sent to your email. You can also access all receipts in the app under Profile → Payment History. Each receipt shows full details of your transaction.';

  @override
  String get docsPaymentFeesExplainedFaq9Q => 'Can we split the bill for group bookings?';

  @override
  String get docsPaymentFeesExplainedFaq9A => 'Yes! For group bookings, you can split the remaining 70% however you like:\n• One person pays all (cash or app)\n• Each person pays their share (cash to shop)\n• Mix of cash and app payments\n\nThe deposit is paid by the person making the booking.';

  @override
  String get docsPaymentFeesExplainedFaq10Q => 'What if I have an emergency and can\'t make it?';

  @override
  String get docsPaymentFeesExplainedFaq10A => 'We understand emergencies happen. While the deposit is officially non-refundable, you can contact the shop directly through the app. Some shops may offer credit toward a future booking at their discretion. The platform fee cannot be refunded.';

  @override
  String get docsPaymentFeesExplainedFaq11Q => 'Can I save my payment details for faster booking?';

  @override
  String get docsPaymentFeesExplainedFaq11A => 'Yes! In your Profile settings, you can save payment methods securely. This makes future bookings faster – just confirm and pay with one tap. Your information is encrypted and stored securely.';

  @override
  String get docsPaymentFeesExplainedFaq12Q => 'Is my payment information secure?';

  @override
  String get docsPaymentFeesExplainedFaq12A => 'Absolutely. All payments are processed through secure, PCI-compliant gateways. Your payment details are encrypted and never stored in plain text. We use industry-standard security measures to protect your information.';

  @override
  String get docsPaymentFeesExplainedFaq13Q => 'What is a guest booking and do I need an account?';

  @override
  String get docsPaymentFeesExplainedFaq13A => 'A guest booking lets you reserve through a provider\'s shared link without downloading the app or creating an account. You pay the same 30% deposit + platform fee, and your receipt is sent to WhatsApp.';

  @override
  String get docsPaymentFeesExplainedFaq14Q => 'How do I get my booking details if I book as a guest?';

  @override
  String get docsPaymentFeesExplainedFaq14A => 'Your appointment details, payment receipt, and reminders are sent to your WhatsApp. You can access everything there without downloading the app.';

  @override
  String get docsPaymentFeesExplainedFaq15Q => 'Can I convert my guest booking to a full account?';

  @override
  String get docsPaymentFeesExplainedFaq15A => 'Yes! After booking as a guest, you can create a full account anytime to access your booking history, saved payments, and other features like loyalty rewards.';

  @override
  String get docsTimeSlotsExplainedTimeIntro_title => 'Why Two Views?';

  @override
  String get docsTimeSlotsExplainedTimeIntro_subtitle => 'Giving you more control over your booking';

  @override
  String get docsTimeSlotsExplainedTimeIntro_timeIntroText_title => 'Two Ways to See Available Times';

  @override
  String get docsTimeSlotsExplainedTimeIntro_timeIntroText_content => 'When you select a date for your booking, you\'ll see available time slots. But did you notice you can switch between two different views? Regular View and Combined View show you the same slots in different ways, each useful for different situations.';

  @override
  String get docsTimeSlotsExplainedTimeIntro_timeSwitch_title => 'How to Switch Views';

  @override
  String get docsTimeSlotsExplainedTimeIntro_timeSwitch_content => 'Look for the toggle switch at the top of the time slot screen. It usually says \"Show Combined Slots\". Tap it to switch between views. The toggle only appears when you have multiple services selected.';

  @override
  String get docsTimeSlotsExplainedTimeIntro_timeImportant_content => 'The toggle switch only appears when you have selected more than one service. For single services, both views would show the same thing, so we keep it simple!';

  @override
  String get docsTimeSlotsExplainedRegularView_title => 'Regular View';

  @override
  String get docsTimeSlotsExplainedRegularView_subtitle => 'See slots for each service separately';

  @override
  String get docsTimeSlotsExplainedRegularView_regularExplained_title => 'What is Regular View?';

  @override
  String get docsTimeSlotsExplainedRegularView_regularExplained_content => 'Regular View shows you available time slots for each service **independently**. You\'ll see separate lists of slots for each service you\'ve selected.';

  @override
  String get docsTimeSlotsExplainedRegularView_regularExample_title => 'Example: Regular View with 2 Services';

  @override
  String get docsTimeSlotsExplainedRegularView_regularExample_content => '**You\'ve selected:**\n• Haircut (1 hour)\n• Beard Trim (30 minutes)\n\n**Regular View shows:**\n━━━━━━━━━━━━━━━━━━━━━━━\n**HAIRCUT SLOTS**\n• 9:00 AM - 10:00 AM\n• 9:30 AM - 10:30 AM\n• 10:00 AM - 11:00 AM\n• 10:30 AM - 11:30 AM\n\n**BEARD TRIM SLOTS**\n• 9:00 AM - 9:30 AM\n• 9:30 AM - 10:00 AM\n• 10:00 AM - 10:30 AM\n• 10:30 AM - 11:00 AM';

  @override
  String get docsTimeSlotsExplainedRegularView_regularWhen_title => 'When to Use Regular View';

  @override
  String get docsTimeSlotsExplainedRegularView_regularWhen_content => 'Regular View is most useful when:';

  @override
  String get docsTimeSlotsExplainedRegularView_regularWhen_bullet1 => '**You haven\'t decided on timing yet** – See all possibilities';

  @override
  String get docsTimeSlotsExplainedRegularView_regularWhen_bullet2 => '**You want flexibility** – Mix and match different times';

  @override
  String get docsTimeSlotsExplainedRegularView_regularWhen_bullet3 => '**You\'re still choosing workers** – See availability per service';

  @override
  String get docsTimeSlotsExplainedRegularView_regularWhen_bullet4 => '**Services have very different durations** – Compare options';

  @override
  String get docsTimeSlotsExplainedRegularView_regularChallenge_title => 'The Challenge with Regular View';

  @override
  String get docsTimeSlotsExplainedRegularView_regularChallenge_content => 'The challenge with Regular View is that you have to find a time that works for ALL your services. For example, you might pick:\n• Haircut at 9:00 AM\n• Beard Trim at 9:30 AM\n\n**Problem:** These overlap! You can\'t be in two places at once.';

  @override
  String get docsTimeSlotsExplainedRegularView_regularTip_content => 'Use Regular View to explore possibilities, then switch to Combined View to find times that actually work together.';

  @override
  String get docsTimeSlotsExplainedCombinedView_title => 'Combined View';

  @override
  String get docsTimeSlotsExplainedCombinedView_subtitle => 'See only slots where ALL services fit together';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedExplained_title => 'What is Combined View?';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedExplained_content => 'Combined View does the hard work for you. It shows only time slots where **ALL your selected services can be booked together** in one continuous appointment.';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedExample_title => 'Example: Combined View with 2 Services';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedExample_content => '**Same services:** Haircut (1 hour) + Beard Trim (30 min)\n\n**Combined View shows:**\n━━━━━━━━━━━━━━━━━━━━━━━\n• 9:00 AM - 10:30 AM (both services)\n• 9:30 AM - 11:00 AM (both services)\n• 10:00 AM - 11:30 AM (both services)\n• 10:30 AM - 12:00 PM (both services)\n\n**Notice:** Each slot is LONGER because it includes BOTH services back-to-back.';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedCalculation_title => 'How Combined Duration is Calculated';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedCalculation_content => 'The system adds up:';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedCalculation_bullet1 => '**Service 1 duration** (e.g., 60 min)';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedCalculation_bullet2 => '**+ Service 2 duration** (e.g., 30 min)';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedCalculation_bullet3 => '**+ Buffer time** between services (5-10 min for cleanup)';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedCalculation_bullet4 => '**= Total appointment time** (e.g., 95-100 min)';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedExampleCalc_title => 'Example Calculation';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedExampleCalc_content => '**Haircut (60 min) + Beard Trim (30 min) + Buffer (5 min):**\n• Start: 9:00 AM\n• Haircut: 9:00 - 10:00\n• Buffer: 10:00 - 10:05 (cleanup)\n• Beard Trim: 10:05 - 10:35\n• **End: 10:35 AM**\n• Slot shown: 9:00 AM - 10:35 AM';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedWhen_title => 'When to Use Combined View';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedWhen_content => 'Combined View is perfect when:';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedWhen_bullet1 => '**You\'re ready to book** – See only realistic options';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedWhen_bullet2 => '**You have multiple services** – Let the system coordinate';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedWhen_bullet3 => '**You want simplicity** – One slot, one time, all services';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedWhen_bullet4 => '**You\'re booking for a group** – Ensure everyone is accommodated';

  @override
  String get docsTimeSlotsExplainedCombinedView_combinedBenefit_content => 'With Combined View, you **cannot** accidentally pick overlapping times. Every slot shown guarantees that all your services can be done in that block without conflicts.';

  @override
  String get docsTimeSlotsExplainedComparison_title => 'Regular vs Combined – Side by Side';

  @override
  String get docsTimeSlotsExplainedComparison_subtitle => 'See the difference clearly';

  @override
  String get docsTimeSlotsExplainedComparison_comparisonTable_title => 'Quick Comparison';

  @override
  String get docsTimeSlotsExplainedComparison_comparisonTable_content => '| Feature | Regular View | Combined View |\n|---------|--------------|---------------|\n| **Shows** | Slots per service | Slots for all services together |\n| **Duration** | Individual service time | Total time for all services |\n| **Risk of overlap** | High – you must check | None – guaranteed to work |\n| **Best for** | Exploring options | Confirming booking |\n| **When to use** | Early in planning | Ready to book |';

  @override
  String get docsTimeSlotsExplainedComparison_comparisonVisual_title => 'Visual Example – 2 Services';

  @override
  String get docsTimeSlotsExplainedComparison_comparisonVisual_content => '**REGULAR VIEW:**\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\nHaircut:    9:00┄┄10:00   9:30┄┄10:30   10:00┄┄11:00\nBeard Trim: 9:00┄┄9:30    9:30┄┄10:00   10:00┄┄10:30\n\n**COMBINED VIEW:**\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\nBoth:       9:00┄┄┄┄┄┄┄┄┄┄10:30\n            9:30┄┄┄┄┄┄┄┄┄┄11:00\n            10:00┄┄┄┄┄┄┄┄┄11:30';

  @override
  String get docsTimeSlotsExplainedComparison_comparisonExample_title => 'Real Booking Example';

  @override
  String get docsTimeSlotsExplainedComparison_comparisonExample_content => '**Sarah wants to book Haircut + Beard Trim for her son.**\n\nUsing **Regular View**, she might pick:\n• Haircut at 9:30 AM\n• Beard Trim at 10:00 AM\n❌ These overlap! The worker can\'t do both.\n\nUsing **Combined View**, she sees:\n• 9:30 AM - 10:35 AM ✅ Works perfectly\n• 10:00 AM - 11:05 AM ✅ Also works\n\nCombined View saves her from making a mistake!';

  @override
  String get docsTimeSlotsExplainedGroupTime_title => 'Time Slots for Group Bookings';

  @override
  String get docsTimeSlotsExplainedGroupTime_subtitle => 'How it works with multiple people';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeIntro_title => 'Groups Make It More Complex';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeIntro_content => 'When you\'re booking for multiple people, time slot calculation becomes more interesting. The system considers:';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeIntro_bullet1 => '**Number of people** (quantity)';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeIntro_bullet2 => '**Service duration × quantity**';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeIntro_bullet3 => '**Worker assignments** (same or different workers)';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeIntro_bullet4 => '**Buffer times** between each person\'s service';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeSameWorker_title => 'Example: Same Worker for Everyone';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeSameWorker_content => '**Family of 3 booking haircuts (45 min each) with the same worker:**\n• Person 1: 9:00 - 9:45\n• Buffer: 9:45 - 9:50\n• Person 2: 9:50 - 10:35\n• Buffer: 10:35 - 10:40\n• Person 3: 10:40 - 11:25\n• **Combined slot: 9:00 AM - 11:25 AM**';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeDiffWorkers_title => 'Example: Different Workers';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeDiffWorkers_content => '**Same family, but with 3 different workers:**\n• Worker A: Person 1 (9:00 - 9:45)\n• Worker B: Person 2 (9:00 - 9:45) at same time\n• Worker C: Person 3 (9:00 - 9:45) at same time\n• **Combined slot: 9:00 AM - 9:45 AM** (much shorter!)';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeCombined_title => 'Combined View for Groups';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeCombined_content => 'When booking for groups, Combined View is **especially valuable**. It shows only time blocks where ALL people can be served, with the correct total duration based on your worker choices.';

  @override
  String get docsTimeSlotsExplainedGroupTime_groupTimeTip_content => 'For large groups, choosing different workers can significantly reduce the total time needed. The system shows you the duration based on your worker selections.';

  @override
  String get docsTimeSlotsExplainedBufferTime_title => 'Understanding Buffer Time';

  @override
  String get docsTimeSlotsExplainedBufferTime_subtitle => 'Why there are gaps between appointments';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferExplained_title => 'What is Buffer Time?';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferExplained_content => 'Buffer time is a short gap (usually 5-15 minutes) between appointments. You won\'t see it in the slot times, but it\'s there behind the scenes.';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferPurpose_title => 'Why Buffer Time Matters';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferPurpose_content => 'Buffer time gives workers a moment to:';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferPurpose_bullet1 => '**Clean and sanitize** their workspace';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferPurpose_bullet2 => '**Prepare tools** for the next client';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferPurpose_bullet3 => '**Take a quick break** between appointments';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferPurpose_bullet4 => '**Handle any unexpected delays**';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferVisibility_title => 'Do You See Buffer Time?';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferVisibility_content => '**No!** Buffer time is invisible to you. The slot you see (e.g., 9:00 - 10:30) is the time you\'ll be at the shop. The system adds buffer automatically behind the scenes to ensure realistic scheduling.';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferExample_title => 'How Buffer Affects Availability';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferExample_content => '**Without buffer:**\n• 9:00 - 10:00 (Service A)\n• 10:00 - 11:00 (Service B) – No time to clean!\n\n**With 5-min buffer (invisible to you):**\n• 9:00 - 10:00 (Service A) – actually ends at 10:05\n• 10:05 - 11:05 (Service B) – starts after cleanup\n\nYou still see \"9:00 - 10:00\" and \"10:05 - 11:05\" as your appointment times.';

  @override
  String get docsTimeSlotsExplainedBufferTime_bufferFairness_content => 'Buffer time ensures workers aren\'t rushed and you get their full attention. It\'s a win-win for everyone!';

  @override
  String get docsTimeSlotsExplainedTimeFaq_title => 'Common Time Slot Questions';

  @override
  String get docsTimeSlotsExplainedTimeFaq_subtitle => 'Quick answers to frequent questions';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq1_title => 'Why are some times not available?';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq1_content => 'Times may be unavailable because:\n• The worker is already booked\n• The shop is closed (check opening hours)\n• There\'s not enough time before closing\n• The worker has marked themselves unavailable (vacation, break)';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq2_title => 'Why do slots start at odd times like 9:05?';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq2_content => 'Slots may start at unusual times because of buffer periods. For example, if a 9:00 appointment ends at 10:05 (including buffer), the next slot starts at 10:05.';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq3_title => 'Can I book a slot that\'s shorter than shown?';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq3_content => 'No, the slot duration shown is the minimum time needed for your services. You cannot book a shorter slot because there wouldn\'t be enough time.';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq4_title => 'What if I need more time than the slot shows?';

  @override
  String get docsTimeSlotsExplainedTimeFaq_timeFaq4_content => 'If you need extra time (e.g., for a more complex service), contact the shop directly. They may have special arrangements.';

  @override
  String get docsTimeSlotsExplainedFaq_regularVsCombined_Q => 'When should I use Regular vs Combined View?';

  @override
  String get docsTimeSlotsExplainedFaq_regularVsCombined_A => 'Use **Regular View** when you\'re exploring options and want to see all possibilities. Switch to **Combined View** when you\'re ready to book and want to see only slots where all your services can be done together without conflicts.';

  @override
  String get docsTimeSlotsExplainedFaq_combinedNotShowing_Q => 'Why is Combined View not showing any slots?';

  @override
  String get docsTimeSlotsExplainedFaq_combinedNotShowing_A => 'If Combined View shows no slots, it means there\'s no single time block where all your selected services can be done together. Try:\n• Selecting a different date\n• Reducing the number of services\n• Choosing different workers\n• Being flexible with morning/afternoon times';

  @override
  String get docsTimeSlotsExplainedFaq_buffer_Q => 'What is buffer time and why is it needed?';

  @override
  String get docsTimeSlotsExplainedFaq_buffer_A => 'Buffer time is a short gap (5-15 minutes) between appointments that allows workers to clean their workspace, prepare tools, and take brief breaks. It ensures quality service and a clean environment for every client. You won\'t see it in your appointment time, but it\'s built into the schedule.';

  @override
  String get docsTimeSlotsExplainedFaq_duration_Q => 'How is the total duration calculated?';

  @override
  String get docsTimeSlotsExplainedFaq_duration_A => 'For multiple services, the system adds:\n• Duration of Service A\n• Duration of Service B (and so on)\n• Buffer time between each service\nThe result is your total appointment time.';

  @override
  String get docsTimeSlotsExplainedFaq_group_Q => 'How does time work for group bookings?';

  @override
  String get docsTimeSlotsExplainedFaq_group_A => 'For groups, total time = (service duration × number of people) + buffer times between people. If you choose different workers who can work in parallel, the total time may be much shorter.';

  @override
  String get docsTimeSlotsExplainedFaq_amPm_Q => 'Are times shown in my local time?';

  @override
  String get docsTimeSlotsExplainedFaq_amPm_A => 'Yes! All times shown in the app are automatically converted to your device\'s local timezone. You don\'t need to worry about timezone conversions.';

  @override
  String get docsTimeSlotsExplainedFaq_lastSlot_Q => 'Why can\'t I book the last slot of the day?';

  @override
  String get docsTimeSlotsExplainedFaq_lastSlot_A => 'The last slot must end before the shop closes, including buffer time. If a service takes 1 hour with 5 min buffer, the last possible start time is 55 minutes before closing.';

  @override
  String get docsTimeSlotsExplainedFaq_change_Q => 'Can I change my time after booking?';

  @override
  String get docsTimeSlotsExplainedFaq_change_A => 'Yes, you can reschedule up to 24 hours before your appointment. Go to \"My Bookings\", find your booking, and tap \"Reschedule\". Available times will be shown.';

  @override
  String get docsTimeSlotsExplainedFaq_slotDisappeared_Q => 'A slot I wanted disappeared – what happened?';

  @override
  String get docsTimeSlotsExplainedFaq_slotDisappeared_A => 'Someone else may have booked it while you were deciding. Slots are reserved only after payment is complete. Try a different time or date.';

  @override
  String get docsTimeSlotsExplainedFaq_workers_Q => 'Does the time change if I choose a different worker?';

  @override
  String get docsTimeSlotsExplainedFaq_workers_A => 'Yes, different workers may have different availability. If you change workers, the system will show times when that worker is free. You may need to adjust your time.';

  @override
  String get docsCreateProductOverview_title => 'Getting Started Selling Products';

  @override
  String get docsCreateProductOverview_subtitle => 'Learn how to list and sell items';

  @override
  String get docsCreateProductOverview_productWelcomeTitle => 'Welcome to Product Selling';

  @override
  String get docsCreateProductOverview_productWelcomeContent => 'Sell physical products directly to customers in your area. From handmade items to retail goods, you can reach customers looking for what you offer.';

  @override
  String get docsCreateProductOverview_phoneRequirementTitle => 'You Need a Verified Phone Number';

  @override
  String get docsCreateProductOverview_phoneRequirementContent => 'Before you can start selling products, you must verify your phone number. This is for customer communication and to validate your identity.';

  @override
  String get docsCreateProductOverview_addPhoneNumberTitle => 'How to Add Your Phone Number';

  @override
  String get docsCreateProductOverview_addPhoneNumberContent => 'Go to your profile settings and add your phone number. You\'ll receive a verification code via SMS to confirm it\'s really your number. This takes just a minute.';

  @override
  String get docsCreateProductOverview_whyPhoneVerifiedTitle => 'Why Phone Verification?';

  @override
  String get docsCreateProductOverview_whyPhoneVerifiedContent => 'A verified phone number builds customer trust and allows us to contact you if there are issues. It also helps prevent fraud.';

  @override
  String get docsCreateProductOverview_phoneImportantContent => 'You cannot list products until you have a verified phone number. This is required for all sellers.';

  @override
  String get docsCreateProductBasics_title => 'Basic Product Information';

  @override
  String get docsCreateProductBasics_subtitle => 'What to tell customers about your product';

  @override
  String get docsCreateProductBasics_productNameTitle => 'Product Name';

  @override
  String get docsCreateProductBasics_productNameContent => 'Enter your product name clearly. Customers search by product name, so be specific. Example: \"Handmade Leather Wallet - Brown\" instead of just \"Wallet\".';

  @override
  String get docsCreateProductBasics_productDescriptionTitle => 'Product Description';

  @override
  String get docsCreateProductBasics_productDescriptionContent => 'Write a detailed description. Tell customers what it is, what it\'s made of, how to use it, and why it\'s good. Be honest about condition (new, used, refurbished).';

  @override
  String get docsCreateProductBasics_categorySelectionTitle => 'Choose a Category';

  @override
  String get docsCreateProductBasics_categorySelectionContent => 'Select the right category. Customers browse by category to find items, so accuracy matters. Pick the most specific category available.';

  @override
  String get docsCreateProductBasics_productConditionTitle => 'Product Condition';

  @override
  String get docsCreateProductBasics_productConditionContent => 'Be clear about condition: New (never used), Like New (used once), Good (light wear), Fair (visible wear), or As-Is. Honesty builds trust.';

  @override
  String get docsCreateProductPricingStock_title => 'Price & Availability';

  @override
  String get docsCreateProductPricingStock_subtitle => 'Set your price and manage inventory';

  @override
  String get docsCreateProductPricingStock_pricingTitle => 'Set Your Price';

  @override
  String get docsCreateProductPricingStock_pricingContent => 'Set a fair price based on condition, market value, and local demand. Customers can see similar items, so competitive pricing helps.';

  @override
  String get docsCreateProductPricingStock_currencyTitle => 'Currency';

  @override
  String get docsCreateProductPricingStock_currencyContent => 'Prices are shown in your shop\'s currency. Make sure your shop currency is set correctly before adding products.';

  @override
  String get docsCreateProductPricingStock_stockQuantityTitle => 'Stock Quantity';

  @override
  String get docsCreateProductPricingStock_stockQuantityContent => 'Enter how many items you have. When stock runs out, the product shows as unavailable. Update this as you sell items.';

  @override
  String get docsCreateProductPricingStock_stockTipContent => 'Keep stock accurate. Customers get frustrated if they order something out of stock. Update regularly as you sell.';

  @override
  String get docsCreateProductPhotos_title => 'Product Photos';

  @override
  String get docsCreateProductPhotos_subtitle => 'Show customers what they\'re buying';

  @override
  String get docsCreateProductPhotos_photosImportanceTitle => 'Photos Matter Most';

  @override
  String get docsCreateProductPhotos_photosImportanceContent => 'Good photos are critical. Customers decide whether to buy based on photos. Poor photos = fewer sales.';

  @override
  String get docsCreateProductPhotos_whatPhotosTitle => 'What to Photograph';

  @override
  String get docsCreateProductPhotos_whatPhotosContent => 'Take photos that show the real product:';

  @override
  String get docsCreateProductPhotos_whatPhotosBullet1 => 'Full product from multiple angles';

  @override
  String get docsCreateProductPhotos_whatPhotosBullet2 => 'Close-ups of details and quality';

  @override
  String get docsCreateProductPhotos_whatPhotosBullet3 => 'Photos showing condition (if used)';

  @override
  String get docsCreateProductPhotos_whatPhotosBullet4 => 'Photos next to something for scale (like a coin or hand)';

  @override
  String get docsCreateProductPhotos_whatPhotosBullet5 => 'Photos of any damage or wear (honesty builds trust)';

  @override
  String get docsCreateProductPhotos_photoTipsTitle => 'Photo Quality Tips';

  @override
  String get docsCreateProductPhotos_photoTipsContent => 'Use natural light. Take photos on a clean background. Show colors accurately. Don\'t use filters that change how the product looks.';

  @override
  String get docsCreateProductPhotos_photoCountTitle => 'Upload Multiple Photos';

  @override
  String get docsCreateProductPhotos_photoCountContent => 'Upload at least 3-5 photos. The first photo is most important - make it clear and appealing. Customers scroll through all photos.';

  @override
  String get docsCreateProductPhotos_photoHonestyContent => 'Honest photos = happy customers. Show exactly what customers will receive, including any flaws.';

  @override
  String get docsCreateProductStatus_title => 'List Your Product';

  @override
  String get docsCreateProductStatus_subtitle => 'Make your product visible to customers';

  @override
  String get docsCreateProductStatus_activeProductTitle => 'Make Your Product Active';

  @override
  String get docsCreateProductStatus_activeProductContent => 'Before customers can see your product, you must mark it as \"Active\". Inactive products are hidden from search.';

  @override
  String get docsCreateProductStatus_whenToActivateTitle => 'When to Activate';

  @override
  String get docsCreateProductStatus_whenToActivateContent => 'Only activate when you have: product name, description, price, photos, and correct stock. If you\'re not ready to sell, keep it inactive.';

  @override
  String get docsCreateProductStatus_pauseListingTitle => 'Pause a Listing';

  @override
  String get docsCreateProductStatus_pauseListingContent => 'If stock runs out or you need to pause, mark it inactive. Customers won\'t see it, but you can reactivate it anytime.';

  @override
  String get docsCreateProductStatus_activeTipContent => 'Only active products with photos and good descriptions get bookmarks and purchases. Make your listings complete before activating.';

  @override
  String get docsCreateProductFaq_title => 'Common Questions';

  @override
  String get docsCreateProductFaq_subtitle => 'Get help with selling products';

  @override
  String get docsCreateProductFaq_howLongTitle => 'How long until my product sells?';

  @override
  String get docsCreateProductFaq_howLongContent => 'It depends on your price, photos, and demand. Good photos + competitive price = faster sales.';

  @override
  String get docsCreateProductFaq_paymentTitle => 'How do I get paid?';

  @override
  String get docsCreateProductFaq_paymentContent => 'When a customer buys, payment goes to your account. You\'ll receive the amount (minus any platform fees) after the transaction completes.';

  @override
  String get docsCreateProductFaq_shippingTitle => 'Do I have to ship?';

  @override
  String get docsCreateProductFaq_shippingContent => 'That depends on your shop settings. You can choose local delivery or shipping. Customers see shipping options before buying.';

  @override
  String get docsCreateProductFaq_editAfterTitle => 'Can I edit after listing?';

  @override
  String get docsCreateProductFaq_editAfterContent => 'Yes! You can edit price, description, photos, and stock anytime. Changes take effect immediately.';

  @override
  String get docsCreateProductFaq_reviewsTitle => 'Do products get reviews?';

  @override
  String get docsCreateProductFaq_reviewsContent => 'Yes. Customers rate products and leave reviews after purchase. Good reviews help future customers trust you.';

  @override
  String get docsCreateProductFaqModel_question1 => 'Do I need a phone number to sell products?';

  @override
  String get docsCreateProductFaqModel_answer1 => 'Yes. You must verify a phone number before you can list products. This is for customer communication and security.';

  @override
  String get docsCreateProductFaqModel_category1 => 'Getting Started';

  @override
  String get docsCreateProductFaqModel_question2 => 'What makes a good product listing?';

  @override
  String get docsCreateProductFaqModel_answer2 => 'Good photos, accurate description, honest condition info, fair pricing, and correct stock quantity. Great photos are the most important.';

  @override
  String get docsCreateProductFaqModel_category2 => 'Setup';

  @override
  String get docsCreateProductFaqModel_question3 => 'Can I sell both products and services?';

  @override
  String get docsCreateProductFaqModel_answer3 => 'Yes! You can run a shop with services, a shop with products, or both. Set up your shop to offer what you want.';

  @override
  String get docsCreateProductFaqModel_category3 => 'Setup';

  @override
  String get docsCreateProductFaqModel_question4 => 'How do I remove a product?';

  @override
  String get docsCreateProductFaqModel_answer4 => 'Mark it as inactive to hide it from customers. If you want to delete it completely, contact support.';

  @override
  String get docsCreateProductFaqModel_category4 => 'Management';

  @override
  String get docsCreateProductFaqModel_question5 => 'What if someone buys but I\'m out of stock?';

  @override
  String get docsCreateProductFaqModel_answer5 => 'Keep your stock accurate to prevent this. If it happens, contact the customer immediately to cancel or offer alternatives.';

  @override
  String get docsCreateProductFaqModel_category5 => 'Management';

  @override
  String get docsCreateProductFaqModel_question6 => 'Can customers return products?';

  @override
  String get docsCreateProductFaqModel_answer6 => 'That\'s up to your shop policy. You can set return policies in your shop settings. Be clear so customers know before buying.';

  @override
  String get docsCreateProductFaqModel_category6 => 'Management';
}
