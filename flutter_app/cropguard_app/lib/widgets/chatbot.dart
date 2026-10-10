import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/language_provider.dart';

// ── Chatbot message model ─────────────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isBot;
  final List<String>? suggestions;
  _ChatMessage(
      {required this.text, required this.isBot, this.suggestions});
}

// ── Rule-based response engine ────────────────────────────────────────────────

class _ChatEngine {
  final String langCode;
  _ChatEngine(this.langCode);

  String get _greeting {
    switch (langCode) {
      case 'rw':
        return '👋 Muraho! Ndi umufasha wa CropGuard AI.\n\nNshobora kugufasha gute uyu munsi?\n\n'
            'Andika cyangwa hitamo ikintu:';
      case 'fr':
        return '👋 Bonjour! Je suis l\'assistant CropGuard AI.\n\nComment puis-je vous aider aujourd\'hui?\n\n'
            'Tapez ou choisissez un sujet:';
      default:
        return '👋 Hello! I\'m the CropGuard AI assistant.\n\nI can help you understand:\n\n'
            'Type a question or tap a suggestion below:';
    }
  }

  List<String> get greetingSuggestions {
    switch (langCode) {
      case 'rw':
        return [
          '🗺️ Ikarita y\'ingaruka',
          '🌾 Amakuru y\'umusaruro',
          '⚠️ Ibimenyi by\'ingaruka',
          '🏭 Ibigo byo kubika',
          '📱 Ubutumwa bwa SMS',
          '📊 Incamake y\'igihugu',
        ];
      case 'fr':
        return [
          '🗺️ Carte des risques',
          '🌾 Données de récolte',
          '⚠️ Indicateurs de risque',
          '🏭 Installations de stockage',
          '📱 Alertes SMS',
          '📊 Résumé national',
        ];
      default:
        return [
          '🗺️ Risk Map',
          '🌾 Crop Data',
          '⚠️ Risk Indicators',
          '🏭 Storage Facilities',
          '📱 SMS Alerts',
          '📊 National Summary',
        ];
    }
  }

  _ChatMessage respond(String input) {
    final q = input.toLowerCase().trim();

    // Map / risk map
    if (_matches(q, ['map', 'ikarita', 'carte', 'risk map', 'ingaruka', 'risque'])) {
      return _ChatMessage(
        text: _t(
          en: '🗺️ **Map & Analytics**\n\n'
              'Click **Map & Analytics** in the sidebar to see the full interactive Rwanda map.\n\n'
              '• Each dot = one district colored by risk level\n'
              '• 🟢 Green = Low risk (safe to harvest)\n'
              '• 🟡 Yellow = Moderate (dry within 48h)\n'
              '• 🔴 Red = High (emergency storage needed)\n\n'
              'Tap any district dot to see its details.',
          rw: '🗺️ **Ikarita & Isesengura**\n\n'
              'Kanda **Ikarita & Isesengura** ku rubaho kugirango urebe ikarita ya Rwanda yuzuye.\n\n'
              '• Buri ntondo = akarere kamwe gasuzumwe n\'ingaruka\n'
              '• 🟢 Icyatsi = Ingaruka nto (birashoboka gutsinda)\n'
              '• 🟡 Umuhondo = Hagati (kama mu masaha 48)\n'
              '• 🔴 Umutuku = Nini (bubiko bw\'ubutaramye burakenewe)',
          fr: '🗺️ **Carte & Analyses**\n\n'
              'Cliquez sur **Carte & Analyses** dans la barre latérale.\n\n'
              '• Chaque point = un district coloré par niveau de risque\n'
              '• 🟢 Vert = Faible risque\n'
              '• 🟡 Jaune = Modéré (sécher dans 48h)\n'
              '• 🔴 Rouge = Élevé (stockage d\'urgence requis)',
        ),
        isBot: true,
        suggestions: _nextSuggestions(),
      );
    }

    // Risk score / indicators
    if (_matches(q, ['risk', 'ingaruka', 'risque', 'indicator', 'score', 'ibimenyetso'])) {
      return _ChatMessage(
        text: _t(
          en: '⚠️ **Risk Score Formula**\n\n'
              'CropGuard calculates a post-harvest risk score for each district:\n\n'
              '**Score = (Rainfall × 35%) + (Humidity × 25%) + (Loss Rate × 25%) + (Soil Moisture × 15%)**\n\n'
              '• **0–39%** 🟢 Safe harvesting\n'
              '• **40–69%** 🟡 Drying equipment needed\n'
              '• **70–100%** 🔴 Emergency storage dispatch\n\n'
              'Data updates every 6 hours automatically.',
          rw: '⚠️ **Uburyo bwo kubara Ingaruka**\n\n'
              'CropGuard ibara amanota y\'ingaruka ku karere:\n\n'
              '**Amanota = (Imvura × 35%) + (Ubuhehere × 25%) + (Gutakaza × 25%) + (Ubunyihu bw\'Ubutaka × 15%)**\n\n'
              '• **0–39%** 🟢 Birashoboka gutsinda\n'
              '• **40–69%** 🟡 Bikenewe gukama\n'
              '• **70–100%** 🔴 Ububiko bw\'ubutaramye',
          fr: '⚠️ **Formule de Score de Risque**\n\n'
              '**Score = (Pluie × 35%) + (Humidité × 25%) + (Perte × 25%) + (Humidité Sol × 15%)**\n\n'
              '• **0–39%** 🟢 Récolte sûre\n'
              '• **40–69%** 🟡 Séchage requis sous 48h\n'
              '• **70–100%** 🔴 Stockage d\'urgence',
        ),
        isBot: true,
        suggestions: _nextSuggestions(),
      );
    }

    // Facilities / storage
    if (_matches(q, ['facilit', 'storage', 'ibigo', 'kubika', 'stockage', 'installation', 'silo', 'dryer'])) {
      return _ChatMessage(
        text: _t(
          en: '🏭 **Storage Facilities**\n\n'
              'CropGuard tracks **21 post-harvest facilities** across Rwanda:\n\n'
              '☀️ Drying Grounds — for sun/mechanical drying\n'
              '🏛️ Silos — grain storage\n'
              '❄️ Cold Storage — perishables\n'
              '🚛 Mobile Dryers — emergency dispatch\n\n'
              '**How to find facilities:**\n'
              '1. Tap a district on the map\n'
              '2. Tap **Facilities** button\n'
              '3. Call or email directly from the app\n\n'
              'Or click **Facilities** in the sidebar.',
          rw: '🏭 **Ibigo byo Kubika**\n\n'
              'CropGuard ikurikirana **ibigo 21** mu Rwanda:\n\n'
              '☀️ Aho Gukamia — gukamia n\'izuba/mashini\n'
              '🏛️ Ibigega — kubika ibinyampeke\n'
              '❄️ Ubushyuhe buke — ibiribwa bishira vuba\n'
              '🚛 Mashini y\'Gutwara — ubutaramye\n\n'
              '**Uburyo bwo kubona ibigo:**\n'
              '1. Kanda akarere ku ikarita\n'
              '2. Kanda **Ibigo**\n'
              '3. Hamagara cyangwa ohereza imeyili',
          fr: '🏭 **Installations de Stockage**\n\n'
              'CropGuard suit **21 installations** au Rwanda:\n\n'
              '☀️ Aires de séchage\n'
              '🏛️ Silos\n'
              '❄️ Chambres froides\n'
              '🚛 Séchoirs mobiles\n\n'
              '**Pour trouver des installations:**\n'
              '1. Tapez un district sur la carte\n'
              '2. Appuyez sur **Installations**\n'
              '3. Appelez ou envoyez un email',
        ),
        isBot: true,
        suggestions: _nextSuggestions(),
      );
    }

    // SMS alerts
    if (_matches(q, ['sms', 'alert', 'ibimenyi', 'alerte', 'notification', 'phone', 'ussd'])) {
      return _ChatMessage(
        text: _t(
          en: '📱 **SMS & USSD Alerts**\n\n'
              'CropGuard sends **bilingual alerts** (English + Kinyarwanda) by SMS when a district risk escalates.\n\n'
              '**To subscribe:**\n'
              '1. Open any district detail\n'
              '2. Tap **Subscribe to SMS alerts**\n'
              '3. Enter your phone number\n\n'
              '**USSD:** Dial `*123#` on any phone — no internet needed!\n\n'
              'Alerts fire only when risk level *changes* (no spam).',
          rw: '📱 **Ubutumwa bwa SMS & USSD**\n\n'
              'CropGuard ohereza **ubutumwa mu ndimi ebyiri** (Icyongereza + Ikinyarwanda) iyo ingaruka z\'akarere ziyongera.\n\n'
              '**Kwiyandikisha:**\n'
              '1. Fungura amakuru y\'akarere\n'
              '2. Kanda **Kwiyandikisha ku SMS**\n'
              '3. Injiza nimero ya telefoni\n\n'
              '**USSD:** Kanda `*123#` ku telefoni iyo ari yo yose!',
          fr: '📱 **Alertes SMS & USSD**\n\n'
              'CropGuard envoie des alertes **bilingues** (Anglais + Kinyarwanda) par SMS.\n\n'
              '**Pour s\'abonner:**\n'
              '1. Ouvrez les détails d\'un district\n'
              '2. Appuyez sur **S\'abonner aux alertes SMS**\n'
              '3. Entrez votre numéro\n\n'
              '**USSD:** Composez `*123#` — sans internet!',
        ),
        isBot: true,
        suggestions: _nextSuggestions(),
      );
    }

    // Crop data / yield
    if (_matches(q, ['crop', 'imyaka', 'culture', 'yield', 'umusaruro', 'récolte', 'maize', 'beans', 'ibigori', 'ibishyimbo'])) {
      return _ChatMessage(
        text: _t(
          en: '🌾 **Crop Data**\n\n'
              'CropGuard tracks **4 main crops** across all 30 districts using NISR SAS data:\n\n'
              '🌽 **Maize** — 251K tons (+14.2%)\n'
              '🫘 **Beans** — 93K tons (+10.8%)\n'
              '🌿 **Cassava** — 54K tons (+9.7%)\n'
              '🥔 **Irish Potato** — 90K tons (+8.9%)\n\n'
              'Click any district to see its specific harvest volumes.\n\n'
              'Data source: **NISR Seasonal Agricultural Survey (SAS)** — auto-updated every 6h.',
          rw: '🌾 **Amakuru y\'Imyaka**\n\n'
              'CropGuard ikurikirana **imyaka 4 ikomeye** mu tuduce 30 twose:\n\n'
              '🌽 **Ibigori** — 251K tone\n'
              '🫘 **Ibishyimbo** — 93K tone\n'
              '🌿 **Imyumbati** — 54K tone\n'
              '🥔 **Ibirayi** — 90K tone\n\n'
              'Kanda akarere urebe umusaruro wawo.',
          fr: '🌾 **Données des Cultures**\n\n'
              'CropGuard suit **4 cultures principales** dans les 30 districts:\n\n'
              '🌽 **Maïs** — 251K tonnes\n'
              '🫘 **Haricots** — 93K tonnes\n'
              '🌿 **Manioc** — 54K tonnes\n'
              '🥔 **Pomme de terre** — 90K tonnes\n\n'
              'Source: **Enquête Agricole Saisonnière NISR**',
        ),
        isBot: true,
        suggestions: _nextSuggestions(),
      );
    }

    // National summary
    if (_matches(q, ['summary', 'national', 'incamake', 'résumé', 'igihugu', 'overview', 'dashboard'])) {
      return _ChatMessage(
        text: _t(
          en: '📊 **National Summary**\n\n'
              'Click **National Summary** in the sidebar to see:\n\n'
              '• Risk distribution pie chart (Green/Yellow/Red)\n'
              '• Province-by-province breakdown\n'
              '• High-risk district alerts\n'
              '• Policy recommendations for MINAGRI\n'
              '• NST2 alignment indicators\n\n'
              'You can also export a **policy brief** from the Python pipeline.',
          rw: '📊 **Incamake y\'Igihugu**\n\n'
              'Kanda **Incamake y\'Igihugu** ku rubaho kugirango urebe:\n\n'
              '• Ishusho y\'ingaruka (Icyatsi/Umuhondo/Umutuku)\n'
              '• Amakuru y\'intara\n'
              '• Ibimenyi by\'ingaruka nini\n'
              '• Inama z\'inzego za leta',
          fr: '📊 **Résumé National**\n\n'
              'Cliquez sur **Résumé National** pour voir:\n\n'
              '• Diagramme de distribution des risques\n'
              '• Répartition par province\n'
              '• Alertes districts à risque élevé\n'
              '• Recommandations politiques MINAGRI',
        ),
        isBot: true,
        suggestions: _nextSuggestions(),
      );
    }

    // Language / translate
    if (_matches(q, ['language', 'ururimi', 'langue', 'kinyarwanda', 'french', 'français', 'translate', 'en', 'rw', 'fr'])) {
      return _ChatMessage(
        text: _t(
          en: '🌍 **Language Switcher**\n\n'
              'CropGuard supports **3 languages**:\n\n'
              '🇷🇼 **RW** — Kinyarwanda\n'
              '🇬🇧 **EN** — English\n'
              '🇫🇷 **FR** — French\n\n'
              'Click **EN / RW / FR** at the top right to switch.\n'
              'Everything changes instantly — including this chatbot!',
          rw: '🌍 **Guhindura Ururimi**\n\n'
              'CropGuard ishyigikira **indimi 3**:\n\n'
              '🇷🇼 **RW** — Ikinyarwanda\n'
              '🇬🇧 **EN** — Icyongereza\n'
              '🇫🇷 **FR** — Igifaransa\n\n'
              'Kanda **EN / RW / FR** hejuru iburyo guhindura ururimi.',
          fr: '🌍 **Changement de Langue**\n\n'
              'CropGuard supporte **3 langues**:\n\n'
              '🇷🇼 **RW** — Kinyarwanda\n'
              '🇬🇧 **EN** — Anglais\n'
              '🇫🇷 **FR** — Français\n\n'
              'Cliquez sur **EN / RW / FR** en haut à droite.',
        ),
        isBot: true,
        suggestions: _nextSuggestions(),
      );
    }

    // Theme / dark / light
    if (_matches(q, ['theme', 'dark', 'light', 'white', 'color', 'couleur', 'ibara'])) {
      return _ChatMessage(
        text: _t(
          en: '🎨 **Theme Switcher**\n\n'
              'CropGuard has **2 themes**:\n\n'
              '🌙 **Dark** — Deep blue + green neon (default)\n'
              '☀️ **Light** — Clean white + green neon\n\n'
              'Click the **toggle switch** next to EN/RW/FR to switch themes instantly.',
          rw: '🎨 **Guhindura Amabara**\n\n'
              'CropGuard ifite **imiterere 2**:\n\n'
              '🌙 **Ituze** — Buluu nziza + icyatsi cy\'inkuba\n'
              '☀️ **Umweru** — Mweru + icyatsi cy\'inkuba\n\n'
              'Kanda **interuro** hafi ya EN/RW/FR guhindura.',
          fr: '🎨 **Changement de Thème**\n\n'
              'CropGuard a **2 thèmes**:\n\n'
              '🌙 **Sombre** — Bleu foncé + néon vert\n'
              '☀️ **Clair** — Blanc + néon vert\n\n'
              'Cliquez sur le **bouton bascule** à côté de EN/RW/FR.',
        ),
        isBot: true,
        suggestions: _nextSuggestions(),
      );
    }

    // Weather
    if (_matches(q, ['weather', 'ibihe', 'météo', 'rain', 'imvura', 'temperature', 'ubushyuhe'])) {
      return _ChatMessage(
        text: _t(
          en: '🌤️ **Real-time Weather**\n\n'
              'CropGuard fetches **live weather** from Open-Meteo API for each district:\n\n'
              '🌡️ Temperature (current)\n'
              '💧 Humidity (%)\n'
              '🌧️ Precipitation (14-day total)\n'
              '💨 Wind speed (km/h)\n\n'
              'The weather card at the top of the dashboard shows **real data** for the first district.\n'
              'Click any district to see its specific weather.',
          rw: '🌤️ **Ibihe bya Kuri Igihe**\n\n'
              'CropGuard ifata **ibihe by\'ukuri** biva kuri Open-Meteo API:\n\n'
              '🌡️ Ubushyuhe\n'
              '💧 Ubuhehere (%)\n'
              '🌧️ Imvura (iminsi 14)\n'
              '💨 Umuyaga (km/h)\n\n'
              'Kanda akarere urebe ibihe byawo by\'ukuri.',
          fr: '🌤️ **Météo en Temps Réel**\n\n'
              'CropGuard récupère la **météo en direct** depuis Open-Meteo:\n\n'
              '🌡️ Température\n'
              '💧 Humidité\n'
              '🌧️ Précipitations (14 jours)\n'
              '💨 Vitesse du vent\n\n'
              'Cliquez sur un district pour voir sa météo spécifique.',
        ),
        isBot: true,
        suggestions: _nextSuggestions(),
      );
    }

    // Help / what can you do
    if (_matches(q, ['help', 'gufasha', 'aide', 'what', 'ibiki', 'quoi', 'how', 'guide'])) {
      return _ChatMessage(
        text: _t(
          en: '🤖 **I can help you with:**\n\n'
              '🗺️ Understanding the risk map\n'
              '⚠️ Reading risk scores & indicators\n'
              '🌾 Crop yield data\n'
              '🏭 Finding storage facilities\n'
              '📱 Setting up SMS alerts\n'
              '📊 National summary & reports\n'
              '🌍 Changing language\n'
              '🎨 Switching themes\n'
              '🌤️ Reading weather data\n\n'
              'Just type your question or tap a suggestion!',
          rw: '🤖 **Nshobora kugufasha:**\n\n'
              '🗺️ Gusobanukirwa ikarita y\'ingaruka\n'
              '⚠️ Gusoma amanota y\'ingaruka\n'
              '🌾 Amakuru y\'imyaka\n'
              '🏭 Kubona ibigo byo kubika\n'
              '📱 Kwiyandikisha ku SMS\n'
              '📊 Incamake y\'igihugu\n'
              '🌍 Guhindura ururimi\n'
              '🎨 Guhindura amabara',
          fr: '🤖 **Je peux vous aider avec:**\n\n'
              '🗺️ Comprendre la carte des risques\n'
              '⚠️ Lire les scores de risque\n'
              '🌾 Données de récolte\n'
              '🏭 Trouver des installations\n'
              '📱 Alertes SMS\n'
              '📊 Résumé national\n'
              '🌍 Changer la langue\n'
              '🎨 Changer le thème',
        ),
        isBot: true,
        suggestions: _nextSuggestions(),
      );
    }

    // Default fallback
    return _ChatMessage(
      text: _t(
        en: '🤔 I didn\'t quite understand that.\n\nTry asking about:\n• Risk map\n• Crop data\n• Storage facilities\n• SMS alerts\n• Weather\n• Language or theme',
        rw: '🤔 Simbiteye neza icyo uvuga.\n\nGerageza kubaza:\n• Ikarita y\'ingaruka\n• Amakuru y\'imyaka\n• Ibigo byo kubika\n• SMS\n• Ibihe',
        fr: '🤔 Je n\'ai pas bien compris.\n\nEssayez de demander:\n• Carte des risques\n• Données de récolte\n• Installations\n• SMS\n• Météo',
      ),
      isBot: true,
      suggestions: greetingSuggestions,
    );
  }

  bool _matches(String input, List<String> keywords) =>
      keywords.any((k) => input.contains(k));

  String _t({required String en, required String rw, required String fr}) {
    switch (langCode) {
      case 'rw': return rw;
      case 'fr': return fr;
      default:   return en;
    }
  }

  List<String> _nextSuggestions() {
    switch (langCode) {
      case 'rw':
        return ['🗺️ Ikarita', '🏭 Ibigo', '📱 SMS', '📊 Incamake', '❓ Gufasha'];
      case 'fr':
        return ['🗺️ Carte', '🏭 Installations', '📱 SMS', '📊 Résumé', '❓ Aide'];
      default:
        return ['🗺️ Map', '🏭 Facilities', '📱 SMS', '📊 Summary', '❓ Help'];
    }
  }
}

// ── Chatbot Widget ────────────────────────────────────────────────────────────

class CropGuardChatbot extends StatefulWidget {
  const CropGuardChatbot({super.key});

  @override
  State<CropGuardChatbot> createState() => _CropGuardChatbotState();
}

class _CropGuardChatbotState extends State<CropGuardChatbot>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  String _lastLang = 'en';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _open(String langCode) {
    if (_messages.isEmpty || _lastLang != langCode) {
      _lastLang = langCode;
      final engine = _ChatEngine(langCode);
      _messages.clear();
      _messages.add(_ChatMessage(
        text: engine._greeting,
        isBot: true,
        suggestions: engine.greetingSuggestions,
      ));
    }
    setState(() => _isOpen = true);
    _animController.forward();
  }

  void _close() {
    _animController.reverse().then((_) {
      if (mounted) setState(() => _isOpen = false);
    });
  }

  void _send(String text, String langCode) {
    if (text.trim().isEmpty) return;
    final engine = _ChatEngine(langCode);
    setState(() {
      _messages.add(_ChatMessage(text: text, isBot: false));
    });
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 300), () {
      final reply = engine.respond(text);
      if (mounted) {
        setState(() => _messages.add(reply));
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _placeholder(String langCode) {
    switch (langCode) {
      case 'rw': return 'Andika ikibazo...';
      case 'fr': return 'Tapez votre question...';
      default:   return 'Type a question...';
    }
  }

  String _chatTitle(String langCode) {
    switch (langCode) {
      case 'rw': return 'Umufasha wa CropGuard';
      case 'fr': return 'Assistant CropGuard';
      default:   return 'CropGuard Assistant';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    final langCode = lang.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF112225) : Colors.white;
    final borderColor = isDark
        ? AppColors.primary.withOpacity(0.3)
        : AppColors.primaryDark.withOpacity(0.2);
    final textColor =
        isDark ? Colors.white : const Color(0xFF0B2010);
    final secondaryColor =
        isDark ? AppColors.textSecondary : const Color(0xFF37474F);

    return Stack(
      children: [
        // ── Chat window ─────────────────────────────────────────
        if (_isOpen)
          Positioned(
            bottom: 80,
            right: 0,
            child: ScaleTransition(
              scale: _scaleAnim,
              alignment: Alignment.bottomRight,
              child: Container(
                width: 340,
                height: 480,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00C853),
                            Color(0xFF00E676)
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: Color(0xFF0B1617),
                            child: Text('🌱',
                                style: TextStyle(fontSize: 14)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _chatTitle(langCode),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0B1617),
                                  ),
                                ),
                                const Text(
                                  '● Online',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF0B4020),
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _close,
                            icon: const Icon(Icons.close,
                                color: Color(0xFF0B1617), size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                    // Messages
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          final msg = _messages[i];
                          return Column(
                            crossAxisAlignment: msg.isBot
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                constraints: const BoxConstraints(
                                    maxWidth: 270),
                                decoration: BoxDecoration(
                                  color: msg.isBot
                                      ? (isDark
                                          ? const Color(0xFF1A3035)
                                          : const Color(0xFFE8F5E9))
                                      : AppColors.primary,
                                  borderRadius: BorderRadius.only(
                                    topLeft:
                                        const Radius.circular(12),
                                    topRight:
                                        const Radius.circular(12),
                                    bottomLeft: Radius.circular(
                                        msg.isBot ? 2 : 12),
                                    bottomRight: Radius.circular(
                                        msg.isBot ? 12 : 2),
                                  ),
                                ),
                                child: Text(
                                  msg.text,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: msg.isBot
                                        ? textColor
                                        : const Color(0xFF0B1617),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              // Suggestions
                              if (msg.isBot &&
                                  msg.suggestions != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8),
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: msg.suggestions!
                                        .map((s) => GestureDetector(
                                              onTap: () =>
                                                  _send(s, langCode),
                                              child: Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 10,
                                                    vertical: 4),
                                                decoration:
                                                    BoxDecoration(
                                                  color: AppColors
                                                      .primary
                                                      .withOpacity(
                                                          0.12),
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                              12),
                                                  border: Border.all(
                                                      color: AppColors
                                                          .primary
                                                          .withOpacity(
                                                              0.3)),
                                                ),
                                                child: Text(
                                                  s,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: AppColors
                                                        .primary,
                                                  ),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Input
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: borderColor, width: 1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: _placeholder(langCode),
                                hintStyle: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  borderSide:
                                      BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: AppColors.primary),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                isDense: true,
                              ),
                              onSubmitted: (v) => _send(v, langCode),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                _send(_controller.text, langCode),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.send,
                                  color: Color(0xFF0B1617), size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── FAB toggle button ───────────────────────────────────
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              if (_isOpen) {
                _close();
              } else {
                _open(langCode);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF00E676)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isOpen ? Icons.close : Icons.chat_bubble_outline,
                color: const Color(0xFF0B1617),
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
