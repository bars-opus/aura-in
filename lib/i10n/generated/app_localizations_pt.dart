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
  String get languageScreenSubtitle => 'Escolha seu idioma preferido para a interface do app. Isso não afetará as configurações do seu dispositivo.';

  @override
  String get languageScreeUseDeviceLang => 'Use Device Language.';

  @override
  String get languageScreeUseDeviceLangNote => 'This will reset to match your device system language.';

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
  String get deactivateItemTitle => 'Desativar';

  @override
  String get deactivateItemSubtitle => 'Desative sua conta';

  @override
  String get deleteItemTitle => 'Excluir Conta';

  @override
  String get deleteItemSubtitle => 'Remova permanentemente sua conta';

  @override
  String get logoutItemTitle => 'Sair';

  @override
  String get logoutItemSubtitle => 'Saia da sua conta';

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
}
