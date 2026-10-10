/// CropGuard AI — UI string translations
/// Languages: English (en), Kinyarwanda (rw), French (fr)

class AppStrings {
  final String languageCode;
  const AppStrings._(this.languageCode);

  static const AppStrings en = AppStrings._('en');
  static const AppStrings rw = AppStrings._('rw');
  static const AppStrings fr = AppStrings._('fr');

  static AppStrings fromCode(String code) {
    switch (code) {
      case 'rw': return rw;
      case 'fr': return fr;
      default:   return en;
    }
  }

  // ── App general ─────────────────────────────────────────────
  String get appTagline => const {
    'en': 'Better Insights. Higher Yields.',
    'rw': 'Amakuru Menshi. Umusaruro Mwinshi.',
    'fr': 'Meilleures Analyses. Rendements Plus Élevés.',
  }[languageCode]!;

  // ── Nav items ────────────────────────────────────────────────
  String get navDashboard => const {
    'en': 'Dashboard',
    'rw': 'Ikibaho',
    'fr': 'Tableau de Bord',
  }[languageCode]!;

  String get navMap => const {
    'en': 'Map & Analytics',
    'rw': 'Ikarita & Isesengura',
    'fr': 'Carte & Analyses',
  }[languageCode]!;

  String get navAlerts => const {
    'en': 'Alerts',
    'rw': 'Ibimenyi',
    'fr': 'Alertes',
  }[languageCode]!;

  String get navSummary => const {
    'en': 'National Summary',
    'rw': 'Incamake y\'Igihugu',
    'fr': 'Résumé National',
  }[languageCode]!;

  String get navFacilities => const {
    'en': 'Facilities',
    'rw': 'Ibigo',
    'fr': 'Installations',
  }[languageCode]!;

  String get navFeedback => const {
    'en': 'Feedback',
    'rw': 'Ibitekerezo',
    'fr': 'Commentaires',
  }[languageCode]!;

  String get navCropMonitoring => const {
    'en': 'Crop Monitoring',
    'rw': 'Gukurikirana Imyaka',
    'fr': 'Surveillance des Cultures',
  }[languageCode]!;

  String get navWeather => const {
    'en': 'Weather',
    'rw': 'Ibihe',
    'fr': 'Météo',
  }[languageCode]!;

  String get navReports => const {
    'en': 'Reports',
    'rw': 'Raporo',
    'fr': 'Rapports',
  }[languageCode]!;

  String get navSettings => const {
    'en': 'Settings',
    'rw': 'Igenamiterere',
    'fr': 'Paramètres',
  }[languageCode]!;

  // ── Dashboard header ─────────────────────────────────────────
  String get dashboardTitle => const {
    'en': 'Rwanda Agricultural Dashboard',
    'rw': 'Ikibaho cy\'Ubuhinzi mu Rwanda',
    'fr': 'Tableau de Bord Agricole du Rwanda',
  }[languageCode]!;

  String get dashboardSubtitle => const {
    'en': 'Real-time insights for healthier crops and higher yields',
    'rw': 'Amakuru yo kuri igihe ku myaka myiza n\'umusaruro mwinshi',
    'fr': 'Analyses en temps réel pour des cultures saines et de meilleurs rendements',
  }[languageCode]!;

  // ── Weather card ──────────────────────────────────────────────
  String get weatherTitle => const {
    'en': 'Weather',
    'rw': 'Ibihe',
    'fr': 'Météo',
  }[languageCode]!;

  String get weatherPartlyCloudy => const {
    'en': 'Partly Cloudy',
    'rw': 'Ibicu bike',
    'fr': 'Partiellement Nuageux',
  }[languageCode]!;

  String get weatherHumidity => const {
    'en': 'Humidity',
    'rw': 'Ubuhehere',
    'fr': 'Humidité',
  }[languageCode]!;

  String get weatherPrecip => const {
    'en': 'Precip.',
    'rw': 'Imvura',
    'fr': 'Précip.',
  }[languageCode]!;

  String get weatherWind => const {
    'en': 'Wind',
    'rw': 'Umuyaga',
    'fr': 'Vent',
  }[languageCode]!;

  // ── Crop yield card ───────────────────────────────────────────
  String get cropYieldTitle => const {
    'en': 'Crop Yield Overview',
    'rw': 'Incamake y\'Umusaruro',
    'fr': 'Aperçu du Rendement',
  }[languageCode]!;

  String get cropYieldTotal => const {
    'en': 'Total Yield (Rwanda)',
    'rw': 'Umusaruro Wose (Rwanda)',
    'fr': 'Rendement Total (Rwanda)',
  }[languageCode]!;

  String get cropMaize => const {
    'en': 'Maize',
    'rw': 'Ibigori',
    'fr': 'Maïs',
  }[languageCode]!;

  String get cropBeans => const {
    'en': 'Beans',
    'rw': 'Ibishyimbo',
    'fr': 'Haricots',
  }[languageCode]!;

  String get cropCassava => const {
    'en': 'Cassava',
    'rw': 'Imyumbati',
    'fr': 'Manioc',
  }[languageCode]!;

  String get cropPotato => const {
    'en': 'Irish Potato',
    'rw': 'Ibirayi',
    'fr': 'Pomme de Terre',
  }[languageCode]!;

  // ── Risk indicators ───────────────────────────────────────────
  String get riskTitle => const {
    'en': 'Risk Indicators',
    'rw': 'Ibimenyetso by\'Ingaruka',
    'fr': 'Indicateurs de Risque',
  }[languageCode]!;

  String get riskNationwide => const {
    'en': 'Nation-wide assessment',
    'rw': 'Isuzuma ku gihugu cyose',
    'fr': 'Évaluation nationale',
  }[languageCode]!;

  String get riskPlantDisease => const {
    'en': 'Plant Disease Risk',
    'rw': 'Ingaruka z\'Indwara z\'Imyaka',
    'fr': 'Risque de Maladie des Plantes',
  }[languageCode]!;

  String get riskDrought => const {
    'en': 'Drought Risk',
    'rw': 'Ingaruka z\'Amapfa',
    'fr': 'Risque de Sécheresse',
  }[languageCode]!;

  String get riskFlood => const {
    'en': 'Flood Risk',
    'rw': 'Ingaruka z\'Umwuzure',
    'fr': 'Risque d\'Inondation',
  }[languageCode]!;

  String get riskPest => const {
    'en': 'Pest Infestation',
    'rw': 'Ingaruka z\'Ibyonnyi',
    'fr': 'Infestation de Ravageurs',
  }[languageCode]!;

  String get riskHigh => const {
    'en': 'High',
    'rw': 'Iteye Ubwoba',
    'fr': 'Élevé',
  }[languageCode]!;

  String get riskModerate => const {
    'en': 'Moderate',
    'rw': 'Hagati',
    'fr': 'Modéré',
  }[languageCode]!;

  String get riskLow => const {
    'en': 'Low',
    'rw': 'Nto',
    'fr': 'Faible',
  }[languageCode]!;

  String get viewDetailedAnalytics => const {
    'en': 'View Detailed Analytics →',
    'rw': 'Reba Isesengura Ryimbitse →',
    'fr': 'Voir les Analyses Détaillées →',
  }[languageCode]!;

  // ── Alerts bar ────────────────────────────────────────────────
  String get recentAlerts => const {
    'en': 'Recent Alerts',
    'rw': 'Ibimenyi Biheruka',
    'fr': 'Alertes Récentes',
  }[languageCode]!;

  String get viewAll => const {
    'en': 'View All',
    'rw': 'Reba Byose',
    'fr': 'Voir Tout',
  }[languageCode]!;

  String get viewDetails => const {
    'en': 'View Details →',
    'rw': 'Reba Birambuye →',
    'fr': 'Voir les Détails →',
  }[languageCode]!;

  // ── Alert messages ────────────────────────────────────────────
  String get alertHighRisk => const {
    'en': 'High risk of post-harvest loss. Emergency storage required.',
    'rw': 'Ingaruka nini zo gukomereka nyuma y\'isarura. Ububiko bw\'ubutaramye burakenewe.',
    'fr': 'Risque élevé de perte après récolte. Stockage d\'urgence requis.',
  }[languageCode]!;

  String get alertModerateRisk => const {
    'en': 'Moderate risk. Plan drying within 48h.',
    'rw': 'Ingaruka hagati. Teganya gukama mu masaha 48.',
    'fr': 'Risque modéré. Planifier le séchage dans 48h.',
  }[languageCode]!;

  String get alertLowRisk => const {
    'en': 'Healthy crop conditions. Safe to harvest.',
    'rw': 'Imyaka iri mu bihe byiza. Birashoboka gutsinda.',
    'fr': 'Bonnes conditions de culture. Sûr pour la récolte.',
  }[languageCode]!;

  // ── Post harvest alert banner ─────────────────────────────────
  String get postHarvestAlert => const {
    'en': 'Post-Harvest Alert',
    'rw': 'Ikimenyetso nyuma y\'Isarura',
    'fr': 'Alerte Post-Récolte',
  }[languageCode]!;

  String postHarvestAlertBody(String districtName) => {
    'en': '$districtName is at risk of quality loss due to high humidity.',
    'rw': '$districtName iri mu ngaruka zo gutakaza ubwiza kubera ubuhehere bwinshi.',
    'fr': '$districtName est à risque de perte de qualité en raison d\'une humidité élevée.',
  }[languageCode]!;

  // ── Profile ───────────────────────────────────────────────────
  String get profileName => const {
    'en': 'Rwanda Farmer',
    'rw': 'Umuhinzi w\'u Rwanda',
    'fr': 'Agriculteur Rwandais',
  }[languageCode]!;

  String get profileRole => const {
    'en': 'Manager',
    'rw': 'Umuyobozi',
    'fr': 'Gestionnaire',
  }[languageCode]!;

  // ── Map ───────────────────────────────────────────────────────
  String get mapLowRisk => const {
    'en': 'Low Risk',
    'rw': 'Ingaruka Nto',
    'fr': 'Risque Faible',
  }[languageCode]!;

  String get mapModerateRisk => const {
    'en': 'Moderate Risk',
    'rw': 'Ingaruka Hagati',
    'fr': 'Risque Modéré',
  }[languageCode]!;

  String get mapHighRisk => const {
    'en': 'High Risk',
    'rw': 'Ingaruka Nini',
    'fr': 'Risque Élevé',
  }[languageCode]!;

  // ── Landing page ──────────────────────────────────────────────
  String get landingScrollHint => const {
    'en': 'Scroll to explore',
    'rw': 'Kururuka urebe',
    'fr': 'Défiler pour explorer',
  }[languageCode]!;

  String get landingExploreCta => const {
    'en': 'Explore Live Dashboard',
    'rw': 'Fungura Ikibaho cy\'Amakuru',
    'fr': 'Explorer le Tableau de Bord',
  }[languageCode]!;

  String get landingFooter => const {
    'en': 'Empowering Rwanda\'s agricultural planners with data-driven insights',
    'rw': 'Gutera inkunga abategura ubuhinzi bw\'u Rwanda amakuru ashingiye ku makuru',
    'fr': 'Soutenir les planificateurs agricoles du Rwanda avec des analyses basées sur les données',
  }[languageCode]!;

  // ── Collapse sidebar ──────────────────────────────────────────
  String get collapse => const {
    'en': 'Collapse',
    'rw': 'Funga',
    'fr': 'Réduire',
  }[languageCode]!;

  // ── District detail screen ────────────────────────────────────
  String get riskScore => const {
    'en': 'Risk Score',
    'rw': 'Amanota y\'Ingaruka',
    'fr': 'Score de Risque',
  }[languageCode]!;

  String get expectedHarvest => const {
    'en': 'Expected Harvest Volume',
    'rw': 'Umusaruro Uteganijwe',
    'fr': 'Volume de Récolte Prévu',
  }[languageCode]!;

  String get nirsBaseline => const {
    'en': 'NISR SAS Baseline Estimates',
    'rw': 'Ibipimo bya NISR SAS',
    'fr': 'Estimations de Base NISR SAS',
  }[languageCode]!;

  String get weatherOutlook => const {
    'en': '14-Day Weather Outlook',
    'rw': 'Iteganyagihe ry\'iminsi 14',
    'fr': 'Prévisions Météo 14 Jours',
  }[languageCode]!;

  String get openMeteoData => const {
    'en': 'Open-Meteo Forecast Data',
    'rw': 'Amakuru ya Open-Meteo',
    'fr': 'Données Prévisions Open-Meteo',
  }[languageCode]!;

  String get riskBreakdown => const {
    'en': 'Risk Score Breakdown',
    'rw': 'Uburyo bwo Kubara Ingaruka',
    'fr': 'Décomposition du Score de Risque',
  }[languageCode]!;

  String get recommendedAction => const {
    'en': 'RECOMMENDED ACTION',
    'rw': 'IGIKORWA GITEGANIJWE',
    'fr': 'ACTION RECOMMANDÉE',
  }[languageCode]!;

  String get findNearestStorage => const {
    'en': 'Find nearest storage NOW',
    'rw': 'Shaka ububiko buri hafi UBU',
    'fr': 'Trouver le stockage le plus proche MAINTENANT',
  }[languageCode]!;

  String get viewDispatchPlan => const {
    'en': 'View dispatch plan',
    'rw': 'Reba gahunda y\'kohereza',
    'fr': 'Voir le plan d\'expédition',
  }[languageCode]!;

  String get subscribeToSms => const {
    'en': 'Subscribe to SMS risk alerts',
    'rw': 'Iyandikishe ku SMS y\'ingaruka',
    'fr': 'S\'abonner aux alertes SMS de risque',
  }[languageCode]!;

  String get subscribedSuccess => const {
    'en': 'Subscribed! You will receive SMS alerts.',
    'rw': 'Wiyandikishije! Uzahabwa SMS z\'ingaruka.',
    'fr': 'Abonné! Vous recevrez des alertes SMS.',
  }[languageCode]!;

  String get totalPrecipitation => const {
    'en': 'Total Precipitation',
    'rw': 'Imvura Yose',
    'fr': 'Précipitations Totales',
  }[languageCode]!;

  String get relativeHumidity => const {
    'en': 'Relative Humidity',
    'rw': 'Ubuhehere Bwisumbuye',
    'fr': 'Humidité Relative',
  }[languageCode]!;

  String get over14Days => const {
    'en': 'Over 14 days',
    'rw': 'Mu minsi 14',
    'fr': 'Sur 14 jours',
  }[languageCode]!;

  String get maximumRecorded => const {
    'en': 'Maximum recorded',
    'rw': 'Byarashyizwe cyane',
    'fr': 'Maximum enregistré',
  }[languageCode]!;

  String get rainfallRiskIndex => const {
    'en': 'Rainfall Risk Index',
    'rw': 'Indice y\'Ingaruka z\'Imvura',
    'fr': 'Indice de Risque Pluie',
  }[languageCode]!;

  String get humidityRiskIndex => const {
    'en': 'Humidity Risk Index',
    'rw': 'Indice y\'Ingaruka z\'Ubuhehere',
    'fr': 'Indice de Risque Humidité',
  }[languageCode]!;

  String get historicalLoss => const {
    'en': 'Historical loss:',
    'rw': 'Gutakaza kwa mbere:',
    'fr': 'Perte historique:',
  }[languageCode]!;

  String get firstReading => const {
    'en': 'First reading',
    'rw': 'Isuzuma rya mbere',
    'fr': 'Première lecture',
  }[languageCode]!;

  // ── Summary screen ────────────────────────────────────────────
  String get nationalOverview => const {
    'en': 'National Overview',
    'rw': 'Incamake y\'Igihugu',
    'fr': 'Aperçu National',
  }[languageCode]!;

  String get nationalDashboard => const {
    'en': 'National Post-Harvest Risk Dashboard',
    'rw': 'Ikibaho cy\'Ingaruka nyuma y\'Isarura ku Gihugu',
    'fr': 'Tableau de Bord National des Risques Post-Récolte',
  }[languageCode]!;

  String get totalDistricts => const {
    'en': 'Total Districts',
    'rw': 'Uduce Twose',
    'fr': 'Total Districts',
  }[languageCode]!;

  String get monitored => const {
    'en': 'Monitored',
    'rw': 'Biri Gukurikiriwa',
    'fr': 'Surveillés',
  }[languageCode]!;

  String get avgRiskScore => const {
    'en': 'Avg Risk Score',
    'rw': 'Amanota y\'Ingaruka Hagati',
    'fr': 'Score de Risque Moyen',
  }[languageCode]!;

  String get atRisk => const {
    'en': 'At Risk',
    'rw': 'Afite Ingaruka',
    'fr': 'À Risque',
  }[languageCode]!;

  String get highAlert => const {
    'en': 'High Alert',
    'rw': 'Impuruza Nini',
    'fr': 'Alerte Élevée',
  }[languageCode]!;

  String get riskDistribution => const {
    'en': 'Risk Distribution',
    'rw': 'Ikwirakwizwa ry\'Ingaruka',
    'fr': 'Distribution des Risques',
  }[languageCode]!;

  String get realTimeClassification => const {
    'en': '30 Districts — Real-time Classification',
    'rw': 'Uduce 30 — Isuzuma rya Kuri Igihe',
    'fr': '30 Districts — Classification en Temps Réel',
  }[languageCode]!;

  String get highRiskDistricts => const {
    'en': 'HIGH RISK DISTRICTS',
    'rw': 'UDUCE DUTEYE UBWOBA',
    'fr': 'DISTRICTS À HAUT RISQUE',
  }[languageCode]!;

  String get provincialBreakdown => const {
    'en': 'Provincial Breakdown',
    'rw': 'Amakuru y\'Intara',
    'fr': 'Répartition Provinciale',
  }[languageCode]!;

  String get policyRecommendations => const {
    'en': 'POLICY RECOMMENDATIONS',
    'rw': 'INAMA Z\'INZEGO ZA LETA',
    'fr': 'RECOMMANDATIONS POLITIQUES',
  }[languageCode]!;

  String get standardOperations => const {
    'en': 'Standard Operations',
    'rw': 'Ibikorwa Bisanzwe',
    'fr': 'Opérations Standard',
  }[languageCode]!;

  String get emergencyDeployment => const {
    'en': 'Emergency Resource Deployment',
    'rw': 'Kohereza Ibikenewe by\'Ubutaramye',
    'fr': 'Déploiement d\'Urgence des Ressources',
  }[languageCode]!;

  String get storageCapacityCheck => const {
    'en': 'Storage Capacity Check',
    'rw': 'Gusuzuma Ubushobozi bw\'Ububiko',
    'fr': 'Vérification de la Capacité de Stockage',
  }[languageCode]!;

  String get precautionaryDrying => const {
    'en': 'Precautionary Drying Schedule',
    'rw': 'Gahunda y\'Gukama by\'Ikiteganywa',
    'fr': 'Programme de Séchage Préventif',
  }[languageCode]!;

  String get nst2Alignment => const {
    'en': 'NST2 Alignment: Post-harvest loss reduction',
    'rw': 'NST2: Kugabanya Gutakaza nyuma y\'Isarura',
    'fr': 'Alignement NST2: Réduction des pertes post-récolte',
  }[languageCode]!;

  String get lastUpdated => const {
    'en': 'Last updated:',
    'rw': 'Ivuguruwe bwa nyuma:',
    'fr': 'Dernière mise à jour:',
  }[languageCode]!;

  // ── Facilities screen ─────────────────────────────────────────
  String get facilitiesTitle => const {
    'en': 'Facilities',
    'rw': 'Ibigo',
    'fr': 'Installations',
  }[languageCode]!;

  String get listView => const {
    'en': 'List View',
    'rw': 'Urutonde',
    'fr': 'Vue Liste',
  }[languageCode]!;

  String get mapView => const {
    'en': 'Map View',
    'rw': 'Ikarita',
    'fr': 'Vue Carte',
  }[languageCode]!;

  String get viewOnMap => const {
    'en': 'View on Map',
    'rw': 'Reba ku Ikarita',
    'fr': 'Voir sur la Carte',
  }[languageCode]!;

  String get call => const {
    'en': 'Call',
    'rw': 'Hamagara',
    'fr': 'Appeler',
  }[languageCode]!;

  String get email => const {
    'en': 'Email',
    'rw': 'Imeyili',
    'fr': 'E-mail',
  }[languageCode]!;

  String get highUsage => const {
    'en': 'High usage',
    'rw': 'Bikoreshwa cyane',
    'fr': 'Utilisation élevée',
  }[languageCode]!;

  String get noFacilitiesFound => const {
    'en': 'No facilities found',
    'rw': 'Nta bigo bibonetse',
    'fr': 'Aucune installation trouvée',
  }[languageCode]!;

  // ── Dispatch screen ───────────────────────────────────────────
  String get dispatchPlan => const {
    'en': 'Dispatch Plan',
    'rw': 'Gahunda y\'Kohereza',
    'fr': 'Plan d\'Expédition',
  }[languageCode]!;

  String get reserve => const {
    'en': 'Reserve',
    'rw': 'Bika',
    'fr': 'Réserver',
  }[languageCode]!;

  String get noFacilityFound => const {
    'en': 'No facility with free capacity found nearby',
    'rw': 'Nta kigo gifite ahantu hasigaye habonetse hafi',
    'fr': 'Aucune installation avec capacité libre trouvée à proximité',
  }[languageCode]!;

  String get contactDistrictOffice => const {
    'en': 'Contact the district agricultural office directly',
    'rw': 'Vugana na biro y\'ubuhinzi y\'akarere directly',
    'fr': 'Contactez directement le bureau agricole du district',
  }[languageCode]!;

  // ── Dashboard screen ──────────────────────────────────────────
  String get districtDetails => const {
    'en': 'Dispatch Plan',
    'rw': 'Amakuru y\'Akarere',
    'fr': 'Détails du District',
  }[languageCode]!;
}
