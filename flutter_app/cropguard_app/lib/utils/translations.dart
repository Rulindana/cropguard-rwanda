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
      case 'rw':
        return rw;
      case 'fr':
        return fr;
      default:
        return en;
    }
  }

  // ── App general ─────────────────────────────────────────────
  String get appTagline =>
      const {
        'en': 'Better Insights. Higher Yields.',
        'rw': 'Amakuru Menshi. Umusaruro Mwinshi.',
        'fr': 'Meilleures Analyses. Rendements Plus Élevés.',
      }[languageCode]!;

  // ── Nav items ────────────────────────────────────────────────
  String get navDashboard =>
      const {
        'en': 'Dashboard',
        'rw': 'Ikibaho',
        'fr': 'Tableau de Bord',
      }[languageCode]!;

  String get navMap =>
      const {
        'en': 'Map & Analytics',
        'rw': 'Ikarita & Isesengura',
        'fr': 'Carte & Analyses',
      }[languageCode]!;

  String get navAlerts =>
      const {'en': 'Alerts', 'rw': 'Ibimenyi', 'fr': 'Alertes'}[languageCode]!;

  String get navSummary =>
      const {
        'en': 'National Summary',
        'rw': 'Incamake y\'Igihugu',
        'fr': 'Résumé National',
      }[languageCode]!;

  String get navFacilities =>
      const {
        'en': 'Facilities',
        'rw': 'Ibigo',
        'fr': 'Installations',
      }[languageCode]!;

  String get navFeedback =>
      const {
        'en': 'Feedback',
        'rw': 'Ibitekerezo',
        'fr': 'Commentaires',
      }[languageCode]!;

  String get navCredits =>
      const {'en': 'Credits', 'rw': 'Abakozi', 'fr': 'Crédits'}[languageCode]!;

  String get navCropMonitoring =>
      const {
        'en': 'Crop Monitoring',
        'rw': 'Gukurikirana Imyaka',
        'fr': 'Surveillance des Cultures',
      }[languageCode]!;

  String get navWeather =>
      const {'en': 'Weather', 'rw': 'Ibihe', 'fr': 'Météo'}[languageCode]!;

  String get navReports =>
      const {'en': 'Reports', 'rw': 'Raporo', 'fr': 'Rapports'}[languageCode]!;

  String get navSettings =>
      const {
        'en': 'Settings',
        'rw': 'Igenamiterere',
        'fr': 'Paramètres',
      }[languageCode]!;

  // ── Dashboard header ─────────────────────────────────────────
  String get dashboardTitle =>
      const {
        'en': 'Rwanda Agricultural Dashboard',
        'rw': 'Ikibaho cy\'Ubuhinzi mu Rwanda',
        'fr': 'Tableau de Bord Agricole du Rwanda',
      }[languageCode]!;

  String get dashboardSubtitle =>
      const {
        'en': 'Real-time insights for healthier crops and higher yields',
        'rw': 'Amakuru yo kuri igihe ku myaka myiza n\'umusaruro mwinshi',
        'fr':
            'Analyses en temps réel pour des cultures saines et de meilleurs rendements',
      }[languageCode]!;

  // ── Weather card ──────────────────────────────────────────────
  String get weatherTitle =>
      const {'en': 'Weather', 'rw': 'Ibihe', 'fr': 'Météo'}[languageCode]!;

  String get weatherPartlyCloudy =>
      const {
        'en': 'Partly Cloudy',
        'rw': 'Ibicu bike',
        'fr': 'Partiellement Nuageux',
      }[languageCode]!;

  String get weatherHumidity =>
      const {
        'en': 'Humidity',
        'rw': 'Ubuhehere',
        'fr': 'Humidité',
      }[languageCode]!;

  String get weatherPrecip =>
      const {'en': 'Precip.', 'rw': 'Imvura', 'fr': 'Précip.'}[languageCode]!;

  String get weatherWind =>
      const {'en': 'Wind', 'rw': 'Umuyaga', 'fr': 'Vent'}[languageCode]!;

  String get weatherHigh =>
      const {'en': 'H', 'rw': 'H', 'fr': 'H'}[languageCode]!;

  String get weatherLow =>
      const {'en': 'L', 'rw': 'L', 'fr': 'L'}[languageCode]!;

  // ── Crop yield card ───────────────────────────────────────────
  String get cropYieldTitle =>
      const {
        'en': 'Crop Yield Overview',
        'rw': 'Incamake y\'Umusaruro',
        'fr': 'Aperçu du Rendement',
      }[languageCode]!;

  String get cropYieldTotal =>
      const {
        'en': 'Total Yield (Rwanda)',
        'rw': 'Umusaruro Wose (Rwanda)',
        'fr': 'Rendement Total (Rwanda)',
      }[languageCode]!;

  String get cropMaize =>
      const {'en': 'Maize', 'rw': 'Ibigori', 'fr': 'Maïs'}[languageCode]!;

  String get cropBeans =>
      const {
        'en': 'Beans',
        'rw': 'Ibishyimbo',
        'fr': 'Haricots',
      }[languageCode]!;

  String get cropCassava =>
      const {'en': 'Cassava', 'rw': 'Imyumbati', 'fr': 'Manioc'}[languageCode]!;

  String get cropPotato =>
      const {
        'en': 'Irish Potato',
        'rw': 'Ibirayi',
        'fr': 'Pomme de Terre',
      }[languageCode]!;

  // ── Risk indicators ───────────────────────────────────────────
  String get riskTitle =>
      const {
        'en': 'Risk Indicators',
        'rw': 'Ibimenyetso by\'Ingaruka',
        'fr': 'Indicateurs de Risque',
      }[languageCode]!;

  String get riskNationwide =>
      const {
        'en': 'Nation-wide assessment',
        'rw': 'Isuzuma ku gihugu cyose',
        'fr': 'Évaluation nationale',
      }[languageCode]!;

  String get riskPlantDisease =>
      const {
        'en': 'Plant Disease Risk',
        'rw': 'Ingaruka z\'Indwara z\'Imyaka',
        'fr': 'Risque de Maladie des Plantes',
      }[languageCode]!;

  String get riskDrought =>
      const {
        'en': 'Drought Risk',
        'rw': 'Ingaruka z\'Amapfa',
        'fr': 'Risque de Sécheresse',
      }[languageCode]!;

  String get riskFlood =>
      const {
        'en': 'Flood Risk',
        'rw': 'Ingaruka z\'Umwuzure',
        'fr': 'Risque d\'Inondation',
      }[languageCode]!;

  String get riskPest =>
      const {
        'en': 'Pest Infestation',
        'rw': 'Ingaruka z\'Ibyonnyi',
        'fr': 'Infestation de Ravageurs',
      }[languageCode]!;

  String get riskHigh =>
      const {'en': 'High', 'rw': 'Iteye Ubwoba', 'fr': 'Élevé'}[languageCode]!;

  String get riskModerate =>
      const {'en': 'Moderate', 'rw': 'Hagati', 'fr': 'Modéré'}[languageCode]!;

  String get riskLow =>
      const {'en': 'Low', 'rw': 'Nto', 'fr': 'Faible'}[languageCode]!;

  String get viewDetailedAnalytics =>
      const {
        'en': 'View Detailed Analytics →',
        'rw': 'Reba Isesengura Ryimbitse →',
        'fr': 'Voir les Analyses Détaillées →',
      }[languageCode]!;

  // ── Alerts bar ────────────────────────────────────────────────
  String get recentAlerts =>
      const {
        'en': 'Recent Alerts',
        'rw': 'Ibimenyi Biheruka',
        'fr': 'Alertes Récentes',
      }[languageCode]!;

  String get viewAll =>
      const {
        'en': 'View All',
        'rw': 'Reba Byose',
        'fr': 'Voir Tout',
      }[languageCode]!;

  String get viewDetails =>
      const {
        'en': 'View Details →',
        'rw': 'Reba Birambuye →',
        'fr': 'Voir les Détails →',
      }[languageCode]!;

  // ── Alert messages ────────────────────────────────────────────
  String get alertHighRisk =>
      const {
        'en': 'High risk of post-harvest loss. Emergency storage required.',
        'rw':
            'Ingaruka nini zo gukomereka nyuma y\'isarura. Ububiko bw\'ubutaramye burakenewe.',
        'fr':
            'Risque élevé de perte après récolte. Stockage d\'urgence requis.',
      }[languageCode]!;

  String get alertModerateRisk =>
      const {
        'en': 'Moderate risk. Plan drying within 48h.',
        'rw': 'Ingaruka hagati. Teganya gukama mu masaha 48.',
        'fr': 'Risque modéré. Planifier le séchage dans 48h.',
      }[languageCode]!;

  String get alertLowRisk =>
      const {
        'en': 'Healthy crop conditions. Safe to harvest.',
        'rw': 'Imyaka iri mu bihe byiza. Birashoboka gutsinda.',
        'fr': 'Bonnes conditions de culture. Sûr pour la récolte.',
      }[languageCode]!;

  // ── Post harvest alert banner ─────────────────────────────────
  String get postHarvestAlert =>
      const {
        'en': 'Post-Harvest Alert',
        'rw': 'Ikimenyetso nyuma y\'Isarura',
        'fr': 'Alerte Post-Récolte',
      }[languageCode]!;

  String postHarvestAlertBody(String districtName) =>
      {
        'en': '$districtName is at risk of quality loss due to high humidity.',
        'rw':
            '$districtName iri mu ngaruka zo gutakaza ubwiza kubera ubuhehere bwinshi.',
        'fr':
            '$districtName est à risque de perte de qualité en raison d\'une humidité élevée.',
      }[languageCode]!;

  // ── Profile ───────────────────────────────────────────────────
  String get profileName =>
      const {
        'en': 'Rwanda Farmer',
        'rw': 'Umuhinzi w\'u Rwanda',
        'fr': 'Agriculteur Rwandais',
      }[languageCode]!;

  String get profileRole =>
      const {
        'en': 'Manager',
        'rw': 'Umuyobozi',
        'fr': 'Gestionnaire',
      }[languageCode]!;

  // ── Map ───────────────────────────────────────────────────────
  String get mapLowRisk =>
      const {
        'en': 'Low Risk',
        'rw': 'Ingaruka Nto',
        'fr': 'Risque Faible',
      }[languageCode]!;

  String get mapModerateRisk =>
      const {
        'en': 'Moderate Risk',
        'rw': 'Ingaruka Hagati',
        'fr': 'Risque Modéré',
      }[languageCode]!;

  String get mapHighRisk =>
      const {
        'en': 'High Risk',
        'rw': 'Ingaruka Nini',
        'fr': 'Risque Élevé',
      }[languageCode]!;

  // ── Landing page ──────────────────────────────────────────────
  String get landingScrollHint =>
      const {
        'en': 'Scroll to explore',
        'rw': 'Kururuka urebe',
        'fr': 'Défiler pour explorer',
      }[languageCode]!;

  String get landingExploreCta =>
      const {
        'en': 'Explore Live Dashboard',
        'rw': 'Fungura Ikibaho cy\'Amakuru',
        'fr': 'Explorer le Tableau de Bord',
      }[languageCode]!;

  String get landingFooter =>
      const {
        'en':
            'Empowering Rwanda\'s agricultural planners with data-driven insights',
        'rw':
            'Gutera inkunga abategura ubuhinzi bw\'u Rwanda amakuru ashingiye ku makuru',
        'fr':
            'Soutenir les planificateurs agricoles du Rwanda avec des analyses basées sur les données',
      }[languageCode]!;

  // ── Collapse sidebar ──────────────────────────────────────────
  String get collapse =>
      const {'en': 'Collapse', 'rw': 'Funga', 'fr': 'Réduire'}[languageCode]!;

  // ── District detail screen ────────────────────────────────────
  String get riskScore =>
      const {
        'en': 'Risk Score',
        'rw': 'Amanota y\'Ingaruka',
        'fr': 'Score de Risque',
      }[languageCode]!;

  String get expectedHarvest =>
      const {
        'en': 'Expected Harvest Volume',
        'rw': 'Umusaruro Uteganijwe',
        'fr': 'Volume de Récolte Prévu',
      }[languageCode]!;

  String get nirsBaseline =>
      const {
        'en': 'NISR SAS Baseline Estimates',
        'rw': 'Ibipimo bya NISR SAS',
        'fr': 'Estimations de Base NISR SAS',
      }[languageCode]!;

  String get weatherOutlook =>
      const {
        'en': '14-Day Weather Outlook',
        'rw': 'Iteganyagihe ry\'iminsi 14',
        'fr': 'Prévisions Météo 14 Jours',
      }[languageCode]!;

  String get openMeteoData =>
      const {
        'en': 'Open-Meteo Forecast Data',
        'rw': 'Amakuru ya Open-Meteo',
        'fr': 'Données Prévisions Open-Meteo',
      }[languageCode]!;

  String get riskBreakdown =>
      const {
        'en': 'Risk Score Breakdown',
        'rw': 'Uburyo bwo Kubara Ingaruka',
        'fr': 'Décomposition du Score de Risque',
      }[languageCode]!;

  String get recommendedAction =>
      const {
        'en': 'RECOMMENDED ACTION',
        'rw': 'IGIKORWA GITEGANIJWE',
        'fr': 'ACTION RECOMMANDÉE',
      }[languageCode]!;

  String get findNearestStorage =>
      const {
        'en': 'Find nearest storage NOW',
        'rw': 'Shaka ububiko buri hafi UBU',
        'fr': 'Trouver le stockage le plus proche MAINTENANT',
      }[languageCode]!;

  String get viewDispatchPlan =>
      const {
        'en': 'View dispatch plan',
        'rw': 'Reba gahunda y\'kohereza',
        'fr': 'Voir le plan d\'expédition',
      }[languageCode]!;

  String get subscribeToSms =>
      const {
        'en': 'Subscribe to SMS risk alerts',
        'rw': 'Iyandikishe ku SMS y\'ingaruka',
        'fr': 'S\'abonner aux alertes SMS de risque',
      }[languageCode]!;

  String get subscribedSuccess =>
      const {
        'en': 'Subscribed! You will receive SMS alerts.',
        'rw': 'Wiyandikishije! Uzahabwa SMS z\'ingaruka.',
        'fr': 'Abonné! Vous recevrez des alertes SMS.',
      }[languageCode]!;

  String get totalPrecipitation =>
      const {
        'en': 'Total Precipitation',
        'rw': 'Imvura Yose',
        'fr': 'Précipitations Totales',
      }[languageCode]!;

  String get relativeHumidity =>
      const {
        'en': 'Relative Humidity',
        'rw': 'Ubuhehere Bwisumbuye',
        'fr': 'Humidité Relative',
      }[languageCode]!;

  String get over14Days =>
      const {
        'en': 'Over 14 days',
        'rw': 'Mu minsi 14',
        'fr': 'Sur 14 jours',
      }[languageCode]!;

  String get maximumRecorded =>
      const {
        'en': 'Maximum recorded',
        'rw': 'Byarashyizwe cyane',
        'fr': 'Maximum enregistré',
      }[languageCode]!;

  String get rainfallRiskIndex =>
      const {
        'en': 'Rainfall Risk Index',
        'rw': 'Indice y\'Ingaruka z\'Imvura',
        'fr': 'Indice de Risque Pluie',
      }[languageCode]!;

  String get humidityRiskIndex =>
      const {
        'en': 'Humidity Risk Index',
        'rw': 'Indice y\'Ingaruka z\'Ubuhehere',
        'fr': 'Indice de Risque Humidité',
      }[languageCode]!;

  String get historicalLoss =>
      const {
        'en': 'Historical loss:',
        'rw': 'Gutakaza kwa mbere:',
        'fr': 'Perte historique:',
      }[languageCode]!;

  String get firstReading =>
      const {
        'en': 'First reading',
        'rw': 'Isuzuma rya mbere',
        'fr': 'Première lecture',
      }[languageCode]!;

  // ── Summary screen ────────────────────────────────────────────
  String get nationalOverview =>
      const {
        'en': 'National Overview',
        'rw': 'Incamake y\'Igihugu',
        'fr': 'Aperçu National',
      }[languageCode]!;

  String get nationalDashboard =>
      const {
        'en': 'National Post-Harvest Risk Dashboard',
        'rw': 'Ikibaho cy\'Ingaruka nyuma y\'Isarura ku Gihugu',
        'fr': 'Tableau de Bord National des Risques Post-Récolte',
      }[languageCode]!;

  String get totalDistricts =>
      const {
        'en': 'Total Districts',
        'rw': 'Uduce Twose',
        'fr': 'Total Districts',
      }[languageCode]!;

  String get monitored =>
      const {
        'en': 'Monitored',
        'rw': 'Biri Gukurikiriwa',
        'fr': 'Surveillés',
      }[languageCode]!;

  String get avgRiskScore =>
      const {
        'en': 'Avg Risk Score',
        'rw': 'Amanota y\'Ingaruka Hagati',
        'fr': 'Score de Risque Moyen',
      }[languageCode]!;

  String get atRisk =>
      const {
        'en': 'At Risk',
        'rw': 'Afite Ingaruka',
        'fr': 'À Risque',
      }[languageCode]!;

  String get highAlert =>
      const {
        'en': 'High Alert',
        'rw': 'Impuruza Nini',
        'fr': 'Alerte Élevée',
      }[languageCode]!;

  String get riskDistribution =>
      const {
        'en': 'Risk Distribution',
        'rw': 'Ikwirakwizwa ry\'Ingaruka',
        'fr': 'Distribution des Risques',
      }[languageCode]!;

  String get realTimeClassification =>
      const {
        'en': '30 Districts — Real-time Classification',
        'rw': 'Uduce 30 — Isuzuma rya Kuri Igihe',
        'fr': '30 Districts — Classification en Temps Réel',
      }[languageCode]!;

  String get highRiskDistricts =>
      const {
        'en': 'HIGH RISK DISTRICTS',
        'rw': 'UDUCE DUTEYE UBWOBA',
        'fr': 'DISTRICTS À HAUT RISQUE',
      }[languageCode]!;

  String get provincialBreakdown =>
      const {
        'en': 'Provincial Breakdown',
        'rw': 'Amakuru y\'Intara',
        'fr': 'Répartition Provinciale',
      }[languageCode]!;

  String get policyRecommendations =>
      const {
        'en': 'POLICY RECOMMENDATIONS',
        'rw': 'INAMA Z\'INZEGO ZA LETA',
        'fr': 'RECOMMANDATIONS POLITIQUES',
      }[languageCode]!;

  String get standardOperations =>
      const {
        'en': 'Standard Operations',
        'rw': 'Ibikorwa Bisanzwe',
        'fr': 'Opérations Standard',
      }[languageCode]!;

  String get emergencyDeployment =>
      const {
        'en': 'Emergency Resource Deployment',
        'rw': 'Kohereza Ibikenewe by\'Ubutaramye',
        'fr': 'Déploiement d\'Urgence des Ressources',
      }[languageCode]!;

  String get storageCapacityCheck =>
      const {
        'en': 'Storage Capacity Check',
        'rw': 'Gusuzuma Ubushobozi bw\'Ububiko',
        'fr': 'Vérification de la Capacité de Stockage',
      }[languageCode]!;

  String get precautionaryDrying =>
      const {
        'en': 'Precautionary Drying Schedule',
        'rw': 'Gahunda y\'Gukama by\'Ikiteganywa',
        'fr': 'Programme de Séchage Préventif',
      }[languageCode]!;

  String get nst2Alignment =>
      const {
        'en': 'NST2 Alignment: Post-harvest loss reduction',
        'rw': 'NST2: Kugabanya Gutakaza nyuma y\'Isarura',
        'fr': 'Alignement NST2: Réduction des pertes post-récolte',
      }[languageCode]!;

  String get lastUpdated =>
      const {
        'en': 'Last updated:',
        'rw': 'Ivuguruwe bwa nyuma:',
        'fr': 'Dernière mise à jour:',
      }[languageCode]!;

  // ── Facilities screen ─────────────────────────────────────────
  String get facilitiesTitle =>
      const {
        'en': 'Facilities',
        'rw': 'Ibigo',
        'fr': 'Installations',
      }[languageCode]!;

  String get listView =>
      const {
        'en': 'List View',
        'rw': 'Urutonde',
        'fr': 'Vue Liste',
      }[languageCode]!;

  String get mapView =>
      const {
        'en': 'Map View',
        'rw': 'Ikarita',
        'fr': 'Vue Carte',
      }[languageCode]!;

  String get viewOnMap =>
      const {
        'en': 'View on Map',
        'rw': 'Reba ku Ikarita',
        'fr': 'Voir sur la Carte',
      }[languageCode]!;

  String get call =>
      const {'en': 'Call', 'rw': 'Hamagara', 'fr': 'Appeler'}[languageCode]!;

  String get email =>
      const {'en': 'Email', 'rw': 'Imeyili', 'fr': 'E-mail'}[languageCode]!;

  String get highUsage =>
      const {
        'en': 'High usage',
        'rw': 'Bikoreshwa cyane',
        'fr': 'Utilisation élevée',
      }[languageCode]!;

  String get facilityFull =>
      const {
        'en': 'Full',
        'rw': 'Byuzwe',
        'fr': 'Complet',
      }[languageCode]!;

  String get facilityPartial =>
      const {
        'en': 'Partial',
        'rw': 'Hafi',
        'fr': 'Partiel',
      }[languageCode]!;

  String get facilityAvailable =>
      const {
        'en': 'Available',
        'rw': 'Birahari',
        'fr': 'Disponible',
      }[languageCode]!;

  String get noFacilitiesFound =>
      const {
        'en': 'No facilities found',
        'rw': 'Nta bigo bibonetse',
        'fr': 'Aucune installation trouvée',
      }[languageCode]!;

  // ── Dispatch screen ───────────────────────────────────────────
  String get dispatchPlan =>
      const {
        'en': 'Dispatch Plan',
        'rw': 'Gahunda y\'Kohereza',
        'fr': 'Plan d\'Expédition',
      }[languageCode]!;

  String get reserve =>
      const {'en': 'Reserve', 'rw': 'Bika', 'fr': 'Réserver'}[languageCode]!;

  String get noFacilityFound =>
      const {
        'en': 'No facility with free capacity found nearby',
        'rw': 'Nta kigo gifite ahantu hasigaye habonetse hafi',
        'fr': 'Aucune installation avec capacité libre trouvée à proximité',
      }[languageCode]!;

  String get contactDistrictOffice =>
      const {
        'en': 'Contact the district agricultural office directly',
        'rw': 'Vugana na biro y\'ubuhinzi y\'akarere directly',
        'fr': 'Contactez directement le bureau agricole du district',
      }[languageCode]!;

  // ── Dashboard screen ──────────────────────────────────────────
  String get districtDetails =>
      const {
        'en': 'Dispatch Plan',
        'rw': 'Amakuru y\'Akarere',
        'fr': 'Détails du District',
      }[languageCode]!;

  // ── Landing page ──────────────────────────────────────────────
  String get openDashboard =>
      const {
        'en': 'Open Dashboard →',
        'rw': 'Fungura Ikibaho →',
        'fr': 'Ouvrir le Tableau →',
      }[languageCode]!;

  String get scrollToExplore =>
      const {
        'en': 'Scroll to explore',
        'rw': 'Yungurura urebe',
        'fr': 'Défiler pour explorer',
      }[languageCode]!;

  String get cropGrowthCycle =>
      const {
        'en': 'Crop Growth Cycle',
        'rw': 'Inzira y\'Imyaka',
        'fr': 'Cycle de Croissance',
      }[languageCode]!;

  String get scrollToGrow =>
      const {
        'en': 'Keep scrolling to watch the plant grow',
        'rw': 'Komeza uyungurure urebe imyaka ikura',
        'fr': 'Continuez à défiler pour voir la plante grandir',
      }[languageCode]!;

  // ── Map & home screen ─────────────────────────────────────────
  String get selectDistrict =>
      const {
        'en': 'Select a District',
        'rw': 'Hitamo Akarere',
        'fr': 'Sélectionner un District',
      }[languageCode]!;

  String get thirtyDistricts =>
      const {
        'en': '30 Districts',
        'rw': 'Tuduce 30',
        'fr': '30 Districts',
      }[languageCode]!;

  String get noData =>
      const {
        'en': 'No data available',
        'rw': 'Nta makuru ahari',
        'fr': 'Aucune donnée disponible',
      }[languageCode]!;

  String get loadingData =>
      const {
        'en': 'Loading district data…',
        'rw': 'Gutegereza amakuru…',
        'fr': 'Chargement des données…',
      }[languageCode]!;

  String get rainfall14d =>
      const {
        'en': 'Rainfall (14d)',
        'rw': 'Imvura (iminsi 14)',
        'fr': 'Pluie (14j)',
      }[languageCode]!;

  String get maxHumidity =>
      const {
        'en': 'Max Humidity',
        'rw': 'Ubuhehere Bwinshi',
        'fr': 'Humidité Max',
      }[languageCode]!;

  String get expectedHarvestVol =>
      const {
        'en': 'Expected Harvest Volume',
        'rw': 'Umusaruro Uteganijwe',
        'fr': 'Volume de Récolte Prévu',
      }[languageCode]!;

  String get landingTitle => const {
    'en': 'CropGuard AI',
    'rw': 'CropGuard AI',
    'fr': 'CropGuard AI',
  }[languageCode]!;

  String get landingSubtitle => const {
    'en': 'Better Insights. Higher Yields.',
    'rw': 'Amakuru Menshi. Umusaruro Mwinshi.',
    'fr': 'Meilleures Analyses. Rendements Plus Élevés.',
  }[languageCode]!;

  String get startUsing => const {
    'en': 'Open Dashboard →',
    'rw': 'Fungura Ikibaho →',
    'fr': 'Ouvrir le Tableau →',
  }[languageCode]!;

  String get startReading => const {
    'en': 'Learn More',
    'rw': 'Menya Birenzeho',
    'fr': 'En Savoir Plus',
  }[languageCode]!;

  String get howItWorksTitle => const {
    'en': 'How It Works',
    'rw': 'Ukora Ite',
    'fr': 'Comment Ça Fonctionne',
  }[languageCode]!;

  String get step1 => const {
    'en': 'Data Ingestion',
    'rw': 'Kwinjiza Amakuru',
    'fr': 'Ingestion des Données',
  }[languageCode]!;

  String get step1Desc => const {
    'en': 'We ingest NISR SAS data across all 30 Rwanda districts.',
    'rw': 'Twinjiza amakuru ya NISR SAS mu turere 30 tw\'u Rwanda.',
    'fr': 'Nous ingérons les données NISR SAS pour les 30 districts.',
  }[languageCode]!;

  String get step2 => const {
    'en': 'Predictive AI',
    'rw': 'AI y\'Iteganyabihe',
    'fr': 'IA Prédictive',
  }[languageCode]!;

  String get step2Desc => const {
    'en': 'AI merges weather forecasts with historical loss patterns.',
    'rw': 'AI ishyira hamwe ibihe n\'ingaruka z\'amateka.',
    'fr': 'L\'IA combine météo et patterns de pertes historiques.',
  }[languageCode]!;

  String get step3 => const {
    'en': 'Smart Storage',
    'rw': 'Ububiko Bwiza',
    'fr': 'Stockage Intelligent',
  }[languageCode]!;

  String get step3Desc => const {
    'en': 'Connect farmers to nearest storage facilities instantly.',
    'rw': 'Huza abahinzi n\'ibigo byo kubika bihuse.',
    'fr': 'Connecter les agriculteurs aux installations de stockage.',
  }[languageCode]!;

  String get featuresTitle => const {
    'en': 'Key Features',
    'rw': 'Ibiranga Sisitemu',
    'fr': 'Fonctionnalités Clés',
  }[languageCode]!;

  String get map => const {
    'en': 'Risk Map',
    'rw': 'Ikarita y\'Ingaruka',
    'fr': 'Carte des Risques',
  }[languageCode]!;

  String get mapDesc => const {
    'en': '30 districts color-coded by risk level in real time.',
    'rw': 'Turere 30 bifite amabara y\'ingaruka kuri igihe.',
    'fr': '30 districts colorés par niveau de risque en temps réel.',
  }[languageCode]!;

  String get sms => const {
    'en': 'SMS Alerts',
    'rw': 'Ubutumwa bwa SMS',
    'fr': 'Alertes SMS',
  }[languageCode]!;

  String get smsDesc => const {
    'en': 'Bilingual alerts via SMS/USSD — no internet needed.',
    'rw': 'Ubutumwa mu ndimi ebyiri bwa SMS/USSD — nta internet bisaba.',
    'fr': 'Alertes bilingues SMS/USSD — sans internet.',
  }[languageCode]!;

  String get service => const {
    'en': 'Storage Routing',
    'rw': 'Gushaka Ububiko',
    'fr': 'Acheminement Stockage',
  }[languageCode]!;

  String get facilitiesDesc => const {
    'en': 'Nearest drying and storage facilities for each district.',
    'rw': 'Ibigo byo kubika bihurira n\'akarere.',
    'fr': 'Installations de séchage et stockage les plus proches.',
  }[languageCode]!;

  String get ctaTitle => const {
    'en': 'Protect Rwanda\'s Harvest',
    'rw': 'Rinda Umusaruro w\'u Rwanda',
    'fr': 'Protégez la Récolte du Rwanda',
  }[languageCode]!;

  String get ctaSubtitle => const {
    'en': 'Join thousands of farmers using CropGuard AI to safeguard their crops.',
    'rw': 'Injira mu bahinzi ibihumbi bakoresha CropGuard AI kurinda imyaka yabo.',
    'fr': 'Rejoignez des milliers d\'agriculteurs utilisant CropGuard AI.',
  }[languageCode]!;

  String get updates => const {
    'en': 'Live Updates',
    'rw': 'Amakuru yo Kuri Igihe',
    'fr': 'Mises à Jour en Direct',
  }[languageCode]!;

  String get hours => const {
    'en': 'Updated every 6 hours',
    'rw': 'Yavuguruwe buri masaa 6',
    'fr': 'Mis à jour toutes les 6 heures',
  }[languageCode]!;

  String get districts => const {
    'en': '30 Districts',
    'rw': 'Uduce 30',
    'fr': '30 Districts',
  }[languageCode]!;

  String get facilities => const {
    'en': '21 Facilities',
    'rw': 'Ibigo 21',
    'fr': '21 Installations',
  }[languageCode]!;
  // ── Alert / subscription ──────────────────────────────────────────────────
  String get langKinyarwanda => const {
    'en': 'Kinyarwanda', 'rw': 'Ikinyarwanda', 'fr': 'Kinyarwanda',
  }[languageCode]!;

  String get langEnglish => const {
    'en': 'English', 'rw': 'Icyongereza', 'fr': 'Anglais',
  }[languageCode]!;

  String get cancel => const {
    'en': 'Cancel', 'rw': 'Hagarika', 'fr': 'Annuler',
  }[languageCode]!;

  String get subscribe => const {
    'en': 'Subscribe', 'rw': 'Iyandikishe', 'fr': 'S\'abonner',
  }[languageCode]!;

  String get riskCardCopied => const {
    'en': 'Risk card copied to clipboard!',
    'rw': 'Ikarita y\'ingaruka yakopishijwe!',
    'fr': 'Carte de risque copiée!',
  }[languageCode]!;

  String get couldNotLoadFacilities => const {
    'en': 'Could not load facilities. Please try again.',
    'rw': 'Ntibishobotse gufungura ibigo. Ongera ugerageze.',
    'fr': 'Impossible de charger les installations. Réessayez.',
  }[languageCode]!;

  String get selectGroundCondition => const {
    'en': 'Please select a ground condition.',
    'rw': 'Hitamo imiterere y\'ubutaka.',
    'fr': 'Veuillez sélectionner l\'état du sol.',
  }[languageCode]!;

  String get reportSubmitted => const {
    'en': 'Report submitted! Thank you.',
    'rw': 'Raporo yoherejwe! Urakoze.',
    'fr': 'Rapport soumis! Merci.',
  }[languageCode]!;

  String get submitReport => const {
    'en': 'Submit Report', 'rw': 'Ohereza Raporo', 'fr': 'Soumettre le Rapport',
  }[languageCode]!;

  String get showingAllFacilities => const {
    'en': 'Showing all facilities across Rwanda',
    'rw': 'Werekana ibigo byose mu Rwanda',
    'fr': 'Affichage de toutes les installations au Rwanda',
  }[languageCode]!;

  String get sendAnother => const {
    'en': 'Send Another', 'rw': 'Ohereza Ikindi', 'fr': 'Envoyer un Autre',
  }[languageCode]!;

  String get pdfExportFailed => const {
    'en': 'PDF export failed', 'rw': 'Gukura PDF byanze', 'fr': 'Échec export PDF',
  }[languageCode]!;

  String get submitReportError => const {
    'en': 'Failed to submit report', 'rw': 'Ntibishoboye kohereza raporo', 'fr': 'Échec envoi rapport',
  }[languageCode]!;

  // ── Feedback screen ───────────────────────────────────────────────────────
  String get feedbackTitle => const {
    'en': 'Feedback & Support', 'rw': 'Ibitekerezo & Ubufasha', 'fr': 'Commentaires & Support',
  }[languageCode]!;

  String get feedbackSubtitle => const {
    'en': 'Help us improve CropGuard AI', 'rw': 'Dufashe guteza imbere CropGuard AI', 'fr': 'Aidez-nous à améliorer CropGuard AI',
  }[languageCode]!;

  String get feedbackAbout => const {
    'en': 'What is this about?', 'rw': 'Ni iki iki kiganiro?', 'fr': 'De quoi s\'agit-il?',
  }[languageCode]!;

  String get feedbackTypeSuggestion => const {
    'en': 'Suggestion', 'rw': 'Inama', 'fr': 'Suggestion',
  }[languageCode]!;

  String get feedbackTypeBug => const {
    'en': 'Bug Report', 'rw': 'Raporo y\'ikibazo', 'fr': 'Rapport de Bug',
  }[languageCode]!;

  String get feedbackTypeSupport => const {
    'en': 'Support Request', 'rw': 'Gusaba Ubufasha', 'fr': 'Demande de Support',
  }[languageCode]!;

  String get feedbackTypeCompliment => const {
    'en': 'Compliment', 'rw': 'Gushimira', 'fr': 'Compliment',
  }[languageCode]!;

  String get feedbackTypeOther => const {
    'en': 'Other', 'rw': 'Ikindi', 'fr': 'Autre',
  }[languageCode]!;

  String get feedbackYourName => const {
    'en': 'Your Name', 'rw': 'Amazina yawe', 'fr': 'Votre Nom',
  }[languageCode]!;

  String get feedbackNameHint => const {
    'en': 'e.g. Jean de Dieu Uwimana', 'rw': 'urugero: Uwimana Jean', 'fr': 'ex. Jean de Dieu Uwimana',
  }[languageCode]!;

  String get feedbackNameRequired => const {
    'en': 'Name is required', 'rw': 'Amazina arakenewe', 'fr': 'Le nom est requis',
  }[languageCode]!;

  String get feedbackEmail => const {
    'en': 'Email (optional — for follow-up)', 'rw': 'Imeyili (si ngombwa)', 'fr': 'Email (optionnel)',
  }[languageCode]!;

  String get feedbackEmailInvalid => const {
    'en': 'Enter a valid email address', 'rw': 'Injiza imeyili nyayo', 'fr': 'Entrez un email valide',
  }[languageCode]!;

  String get feedbackYourMessage => const {
    'en': 'Your Message', 'rw': 'Ubutumwa bwawe', 'fr': 'Votre Message',
  }[languageCode]!;

  String get feedbackMessageRequired => const {
    'en': 'Message is required', 'rw': 'Ubutumwa burakenewe', 'fr': 'Le message est requis',
  }[languageCode]!;

  String get feedbackMessageTooShort => const {
    'en': 'Please write at least 10 characters', 'rw': 'Andika nibura inyuguti 10', 'fr': 'Écrivez au moins 10 caractères',
  }[languageCode]!;

  String get feedbackCouldNotSubmit => const {
    'en': 'Could not submit. Please check your connection and try again.',
    'rw': 'Ntishobotse kohereza. Reba iyikoranya rya internet hanyuma ugerageze.',
    'fr': 'Impossible d\'envoyer. Vérifiez votre connexion et réessayez.',
  }[languageCode]!;

  // ── Facilities screen ──────────────────────────────────────────────────────

  String get facilitiesAvailable => const {
    'en': 'available', 'rw': 'iboneka', 'fr': 'disponible',
  }[languageCode]!;

  String get facilitiesTotal => const {
    'en': 'total', 'rw': 'yose', 'fr': 'total',
  }[languageCode]!;

  String get facilitiesSearch => const {
    'en': 'Search facilities...', 'rw': 'Shakisha ibigo...', 'fr': 'Rechercher installations...',
  }[languageCode]!;

  String get facilitiesCallPhone => const {
    'en': 'Call', 'rw': 'Hamagara', 'fr': 'Appeler',
  }[languageCode]!;

  String get facilitiesCapacity => const {
    'en': 'Capacity', 'rw': 'Ubushobozi', 'fr': 'Capacité',
  }[languageCode]!;

  String get facilitiesAcrossRwanda => const {
    'en': 'facilities across Rwanda', 'rw': 'ibigo mu Rwanda', 'fr': 'installations au Rwanda',
  }[languageCode]!;

  // ── Crop Disease Scanner ───────────────────────────────────────────────────

  String get navScan => const {
    'en': 'Scan', 'rw': 'Gusuzuma', 'fr': 'Scanner',
  }[languageCode]!;

  String get scanTitle => const {
    'en': 'Leaf Disease Scanner',
    'rw': 'Gusuzuma Indwara z\'Ibimera',
    'fr': 'Scanner de Maladies des Plantes',
  }[languageCode]!;

  String get scanSubtitle => const {
    'en': 'AI-powered crop diagnosis',
    'rw': 'Isuzuma ry\'imyaka ryakozwe na AI',
    'fr': 'Diagnostic des cultures par IA',
  }[languageCode]!;

  String get scanInfo => const {
    'en': 'Take a clear photo of a sick leaf or upload from your gallery. The AI will identify the disease and show you how to treat it.',
    'rw': 'Fata ifoto nziza y\'ikibabi kirwaye cyangwa shyira uruhande rwa galeri yawe. AI izasuzuma indwara ikakwereka uburyo bwo kuvura.',
    'fr': 'Prenez une photo nette d\'une feuille malade ou téléchargez depuis votre galerie. L\'IA identifiera la maladie et vous montrera comment la traiter.',
  }[languageCode]!;

  // Permission dialog
  String get scanAllowCamera => const {
    'en': 'Allow Camera Access',
    'rw': 'Emera Gukoresha Kamera',
    'fr': 'Autoriser l\'Accès à la Caméra',
  }[languageCode]!;

  String get scanAllowGallery => const {
    'en': 'Allow Gallery Access',
    'rw': 'Emera Gukoresha Galeri',
    'fr': 'Autoriser l\'Accès à la Galerie',
  }[languageCode]!;

  String get scanCameraDesc => const {
    'en': 'CropGuard AI needs your camera to take a photo of the plant leaf for disease detection.\n\nYour photos are only used for analysis and are never stored on our servers.',
    'rw': 'CropGuard AI ikeneye kamera yawe gufata ifoto y\'ikibabi cy\'ikimera kugirango isuzume indwara.\n\nAmafoto yawe akoreshwa gusa isuzuma kandi ntazigera abikwa kuri seriveri zacu.',
    'fr': 'CropGuard AI a besoin de votre caméra pour prendre une photo de la feuille de plante pour détecter les maladies.\n\nVos photos ne sont utilisées que pour l\'analyse et ne sont jamais stockées sur nos serveurs.',
  }[languageCode]!;

  String get scanGalleryDesc => const {
    'en': 'CropGuard AI needs access to your gallery to upload a photo of the plant leaf for disease detection.\n\nYour photos are only used for analysis and are never stored on our servers.',
    'rw': 'CropGuard AI ikeneye kugera kuri galeri yawe gushyira ifoto y\'ikibabi cy\'ikimera kugirango isuzume indwara.\n\nAmafoto yawe akoreshwa gusa isuzuma kandi ntazigera abikwa kuri seriveri zacu.',
    'fr': 'CropGuard AI a besoin d\'accéder à votre galerie pour télécharger une photo de la feuille de plante pour détecter les maladies.\n\nVos photos ne sont utilisées que pour l\'analyse et ne sont jamais stockées sur nos serveurs.',
  }[languageCode]!;

  String get scanPrivacyNote => const {
    'en': 'Privacy protected · Used only for disease analysis',
    'rw': 'Ubuzima bw\'amakuru burinzwe · Bukoreshwa gusa isuzuma',
    'fr': 'Vie privée protégée · Utilisé uniquement pour l\'analyse',
  }[languageCode]!;

  String get scanAllowCameraBtn => const {
    'en': 'Allow Camera', 'rw': 'Emera Kamera', 'fr': 'Autoriser Caméra',
  }[languageCode]!;

  String get scanAllowGalleryBtn => const {
    'en': 'Allow Gallery', 'rw': 'Emera Galeri', 'fr': 'Autoriser Galerie',
  }[languageCode]!;

  String get scanSkip => const {
    'en': 'Skip for now', 'rw': 'Reka ubu', 'fr': 'Ignorer pour l\'instant',
  }[languageCode]!;

  // Image area
  String get scanNoImage => const {
    'en': 'No image selected',
    'rw': 'Nta foto yahiswemo',
    'fr': 'Aucune image sélectionnée',
  }[languageCode]!;

  String get scanNoImageSub => const {
    'en': 'Take a photo or upload from gallery',
    'rw': 'Fata ifoto cyangwa shyira uruhande rwa galeri',
    'fr': 'Prenez une photo ou téléchargez depuis la galerie',
  }[languageCode]!;

  String get scanTakePhoto => const {
    'en': 'Take Photo', 'rw': 'Fata Ifoto', 'fr': 'Prendre Photo',
  }[languageCode]!;

  String get scanUseCamera => const {
    'en': 'Use camera', 'rw': 'Koresha kamera', 'fr': 'Utiliser caméra',
  }[languageCode]!;

  String get scanUploadPhoto => const {
    'en': 'Upload Photo', 'rw': 'Shyira Ifoto', 'fr': 'Télécharger Photo',
  }[languageCode]!;

  String get scanFromGallery => const {
    'en': 'From gallery', 'rw': 'Mu galeri', 'fr': 'Depuis la galerie',
  }[languageCode]!;

  String get scanReadyToScan => const {
    'en': 'Ready to scan', 'rw': 'Witeguye gusuzuma', 'fr': 'Prêt à scanner',
  }[languageCode]!;

  String get scanAnalyze => const {
    'en': 'Analyze Disease →', 'rw': 'Suzuma Indwara →', 'fr': 'Analyser la Maladie →',
  }[languageCode]!;

  String get scanAnalyzing => const {
    'en': 'Analyzing...', 'rw': 'Gusuzuma...', 'fr': 'Analyse en cours...',
  }[languageCode]!;

  String get scanPlantImage => const {
    'en': 'Plant Image', 'rw': 'Ifoto y\'Ikimera', 'fr': 'Image de Plante',
  }[languageCode]!;

  // Analysis steps
  String get scanStep1 => const {
    'en': 'Uploading image...', 'rw': 'Kohereza ifoto...', 'fr': 'Envoi de l\'image...',
  }[languageCode]!;

  String get scanStep2 => const {
    'en': 'Detecting leaf structure...', 'rw': 'Gusuzuma imiterere y\'ikibabi...', 'fr': 'Détection de la structure...',
  }[languageCode]!;

  String get scanStep3 => const {
    'en': 'Analyzing color patterns...', 'rw': 'Gusesengura amabara...', 'fr': 'Analyse des couleurs...',
  }[languageCode]!;

  String get scanStep4 => const {
    'en': 'Comparing with disease database...', 'rw': 'Gusuzuma na bayi dati y\'indwara...', 'fr': 'Comparaison avec la base de données...',
  }[languageCode]!;

  String get scanStep5 => const {
    'en': 'Matching symptoms...', 'rw': 'Gusangira ibimenyetso...', 'fr': 'Correspondance des symptômes...',
  }[languageCode]!;

  String get scanStep6 => const {
    'en': 'Calculating confidence score...', 'rw': 'Kubara amanota y\'ikizere...', 'fr': 'Calcul du score de confiance...',
  }[languageCode]!;

  String get scanStep7 => const {
    'en': 'Preparing results...', 'rw': 'Gutegura ibisubizo...', 'fr': 'Préparation des résultats...',
  }[languageCode]!;

  // Tips section
  String get scanTipsTitle => const {
    'en': '📸 Tips for Best Results',
    'rw': '📸 Inama zo Kubona Ibisubizo Byiza',
    'fr': '📸 Conseils pour de Meilleurs Résultats',
  }[languageCode]!;

  String get scanTip1Title => const {
    'en': 'Good lighting', 'rw': 'Urumuri rwiza', 'fr': 'Bon éclairage',
  }[languageCode]!;

  String get scanTip1Desc => const {
    'en': 'Take photo in natural daylight — avoid shadows',
    'rw': 'Fata ifoto mu rumuri rw\'umunsi — irinde inkomanzi',
    'fr': 'Prenez la photo en lumière naturelle — évitez les ombres',
  }[languageCode]!;

  String get scanTip2Title => const {
    'en': 'Close-up shot', 'rw': 'Ifoto hafi', 'fr': 'Gros plan',
  }[languageCode]!;

  String get scanTip2Desc => const {
    'en': 'Focus on the diseased leaf, fill the frame',
    'rw': 'Ita ku kibabi kirwaye, yuzuze icyumba cya kamera',
    'fr': 'Concentrez-vous sur la feuille malade, remplissez le cadre',
  }[languageCode]!;

  String get scanTip3Title => const {
    'en': 'Multiple leaves', 'rw': 'Amababi menshi', 'fr': 'Plusieurs feuilles',
  }[languageCode]!;

  String get scanTip3Desc => const {
    'en': 'Include both healthy and sick leaves for comparison',
    'rw': 'Shyiramo amababi meza n\'mabi kugirango ugereranye',
    'fr': 'Incluez des feuilles saines et malades pour comparaison',
  }[languageCode]!;

  String get scanTip4Title => const {
    'en': 'Clear image', 'rw': 'Ifoto nziza', 'fr': 'Image nette',
  }[languageCode]!;

  String get scanTip4Desc => const {
    'en': 'Hold camera steady — blurry photos reduce accuracy',
    'rw': 'Shyikira kamera neza — amafoto adakunze atera amakosa',
    'fr': 'Tenez la caméra stable — les photos floues réduisent la précision',
  }[languageCode]!;

  String get scanTip5Title => const {
    'en': 'Single leaf', 'rw': 'Ikibabi kimwe', 'fr': 'Feuille unique',
  }[languageCode]!;

  String get scanTip5Desc => const {
    'en': 'If possible, place one leaf on a flat surface',
    'rw': 'Niba bishoboka, shyira ikibabi kimwe ku meza',
    'fr': 'Si possible, placez une feuille sur une surface plane',
  }[languageCode]!;

  // Supported crops section
  String get scanSupportedTitle => const {
    'en': '🌱 Supported Crops',
    'rw': '🌱 Imyaka Isuzumwa',
    'fr': '🌱 Cultures Supportées',
  }[languageCode]!;

  String get scanDatabaseDesc => const {
    'en': 'Disease database covering Rwanda\'s main crops',
    'rw': 'Bayi dati y\'indwara ihuye n\'imyaka ikurura mu Rwanda',
    'fr': 'Base de données couvrant les principales cultures du Rwanda',
  }[languageCode]!;

  String get scanDiseases => const {
    'en': 'diseases', 'rw': 'indwara', 'fr': 'maladies',
  }[languageCode]!;

  // Result screen
  String get scanResult => const {
    'en': 'Scan Result', 'rw': 'Ibisubizo by\'Isuzuma', 'fr': 'Résultat du Scan',
  }[languageCode]!;

  String get scanShare => const {
    'en': 'Share', 'rw': 'Sangira', 'fr': 'Partager',
  }[languageCode]!;

  String get scanShareSoon => const {
    'en': 'Sharing coming soon',
    'rw': 'Gutumagana bizaza vuba',
    'fr': 'Partage bientôt disponible',
  }[languageCode]!;

  String get scanCropLabel => const {
    'en': 'Crop:', 'rw': 'Igihingwa:', 'fr': 'Culture:',
  }[languageCode]!;

  String get scanConfidence => const {
    'en': 'AI Confidence', 'rw': 'Ikizere cya AI', 'fr': 'Confiance de l\'IA',
  }[languageCode]!;

  String get scanSymptoms => const {
    'en': '🔍 Symptoms Detected',
    'rw': '🔍 Ibimenyetso Byabonetse',
    'fr': '🔍 Symptômes Détectés',
  }[languageCode]!;

  String get scanCauses => const {
    'en': '⚠️ Causes', 'rw': '⚠️ Impamvu', 'fr': '⚠️ Causes',
  }[languageCode]!;

  String get scanTreatment => const {
    'en': '💊 Treatment Steps',
    'rw': '💊 Inzira zo Kuvura',
    'fr': '💊 Étapes de Traitement',
  }[languageCode]!;

  String get scanTreatmentTap => const {
    'en': 'Tap each step to mark as done',
    'rw': 'Kanda buri nzira kugirango ugaragaze ko yarangiye',
    'fr': 'Appuyez sur chaque étape pour la marquer comme terminée',
  }[languageCode]!;

  String get scanPrevention => const {
    'en': '🛡️ Prevention Tips',
    'rw': '🛡️ Inama zo Kwirinda',
    'fr': '🛡️ Conseils de Prévention',
  }[languageCode]!;

  String get scanAlternatives => const {
    'en': '🔄 Other Possible Diseases',
    'rw': '🔄 Izindi Ndwara Zishoboka',
    'fr': '🔄 Autres Maladies Possibles',
  }[languageCode]!;

  String get scanAlternativesSub => const {
    'en': 'Lower confidence alternatives from AI scan',
    'rw': 'Izindi ndwara z\'ikizere gike zavuye isuzuma ya AI',
    'fr': 'Alternatives à faible confiance du scan IA',
  }[languageCode]!;

  String get scanAlt => const {
    'en': 'Alt.', 'rw': 'Undi', 'fr': 'Alt.',
  }[languageCode]!;

  String get scanHealthyAdvice => const {
    'en': '✅ Plant Health Advice',
    'rw': '✅ Inama zo Gusungura Ikimera',
    'fr': '✅ Conseils de Santé des Plantes',
  }[languageCode]!;

  String get scanScanAgain => const {
    'en': 'Scan Another Plant',
    'rw': 'Suzuma Ikimera Ikindi',
    'fr': 'Scanner une Autre Plante',
  }[languageCode]!;

  String get scanHealthy => const {
    'en': 'Healthy Plant', 'rw': 'Ikimera Gikora Neza', 'fr': 'Plante Saine',
  }[languageCode]!;

  String get scanCameraError => const {
    'en': 'Could not open camera. Please check camera permissions in Settings.',
    'rw': 'Ntibishoboye gufungura kamera. Reba uburenganzira bwa kamera mu igenamiterere.',
    'fr': 'Impossible d\'ouvrir la caméra. Vérifiez les autorisations dans les Paramètres.',
  }[languageCode]!;

  String get scanGalleryError => const {
    'en': 'Could not open gallery. Please check storage permissions.',
    'rw': 'Ntibishoboye gufungura galeri. Reba uburenganzira bwo kubika.',
    'fr': 'Impossible d\'ouvrir la galerie. Vérifiez les autorisations de stockage.',
  }[languageCode]!;

}
