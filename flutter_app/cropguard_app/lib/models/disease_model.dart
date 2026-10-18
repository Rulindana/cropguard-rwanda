/// CropGuard AI — Plant Disease Database
/// Covers the most common crop diseases in Rwanda & East Africa
/// Served to the real AI scanner as its diagnosis vocabulary
/// (see lib/services/ai_service.dart).

import 'dart:typed_data';

class PlantDisease {
  final String id;
  final String name;
  final String scientificName;
  final String cropAffected;
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatmentSteps;
  final List<String> preventionTips;
  final String severity; // 'low' | 'moderate' | 'high' | 'critical'
  final String emoji;

  const PlantDisease({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.cropAffected,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.treatmentSteps,
    required this.preventionTips,
    required this.severity,
    required this.emoji,
  });
}

/// Scan result returned by the AI diagnosis engine
class ScanResult {
  final PlantDisease disease;
  final double confidence; // 0.0 – 1.0
  final String imagePath;
  final Uint8List? imageBytes; // in-memory photo (survives temp-cache cleanup)
  final DateTime scannedAt;
  final List<PlantDisease> alternatives; // next-best matches

  const ScanResult({
    required this.disease,
    required this.confidence,
    required this.imagePath,
    this.imageBytes,
    required this.scannedAt,
    required this.alternatives,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  DISEASE DATABASE  (25 diseases covering Rwanda's main crops)
// ─────────────────────────────────────────────────────────────────────────────

class DiseaseDatabase {
  static const List<PlantDisease> all = [
    // ── MAIZE (Ibigori) ──────────────────────────────────────────────────────
    PlantDisease(
      id: 'maize_gray_leaf_spot',
      name: 'Gray Leaf Spot',
      scientificName: 'Cercospora zeae-maydis',
      cropAffected: 'Maize',
      emoji: '🌽',
      severity: 'high',
      description:
          'A fungal disease that creates rectangular gray or tan lesions on maize leaves, reducing photosynthesis and yield.',
      symptoms: [
        'Rectangular gray or tan lesions on leaves',
        'Lesions run parallel to leaf veins',
        'Yellow halo around lesions',
        'Leaves turn brown and die from tip downward',
        'Stalks may become weak and break',
      ],
      causes: [
        'Fungus Cercospora zeae-maydis',
        'High humidity and warm temperatures (25–30°C)',
        'Dense plant canopy reducing air circulation',
        'Crop residue left in field from previous season',
      ],
      treatmentSteps: [
        'Step 1 — Remove and destroy infected leaves immediately to reduce spore spread.',
        'Step 2 — Apply foliar fungicide: Mancozeb 80% WP at 2.5 kg/ha or Propiconazole 250 EC at 0.5 L/ha.',
        'Step 3 — Spray every 10–14 days during active disease period.',
        'Step 4 — Improve field drainage to reduce humidity between plants.',
        'Step 5 — Avoid irrigating at night — water in the morning so leaves dry quickly.',
        'Step 6 — At season end, plow crop residue deep into the soil.',
      ],
      preventionTips: [
        'Plant resistant maize varieties (e.g., DK8031, H614D)',
        'Rotate crops — avoid planting maize in the same field 2 seasons in a row',
        'Maintain proper plant spacing (75 cm × 25 cm) for air flow',
        'Apply balanced fertilizer to keep plants strong',
      ],
    ),

    PlantDisease(
      id: 'maize_northern_blight',
      name: 'Northern Corn Leaf Blight',
      scientificName: 'Exserohilum turcicum',
      cropAffected: 'Maize',
      emoji: '🌽',
      severity: 'high',
      description:
          'Fungal disease producing long cigar-shaped lesions on maize leaves. Common in highland Rwanda during rainy seasons.',
      symptoms: [
        'Long (5–15 cm) cigar-shaped tan/gray lesions on leaves',
        'Lesions have wavy, irregular edges',
        'Dark sooty appearance inside lesions (spore masses)',
        'Entire leaf dies when many lesions merge',
        'Reduced cob size and yield',
      ],
      causes: [
        'Fungus Exserohilum turcicum',
        'Cool temperatures (18–27°C) with high moisture',
        'Dew or prolonged leaf wetness',
        'Infected seed or crop residue',
      ],
      treatmentSteps: [
        'Step 1 — Scout fields weekly from V6 stage onward.',
        'Step 2 — Apply Mancozeb + Cymoxanil fungicide at first sign of disease.',
        'Step 3 — Re-apply every 14 days or after heavy rain.',
        'Step 4 — Remove heavily infected leaves and bury or burn them.',
        'Step 5 — Avoid overhead irrigation during cool, wet periods.',
        'Step 6 — Ensure adequate potassium fertilization — deficient plants are more susceptible.',
      ],
      preventionTips: [
        'Use certified, treated seed from known resistant varieties',
        'Practice 2-year crop rotation with beans or potatoes',
        'Destroy crop residue after harvest',
        'Do not carry infected plant material between fields',
      ],
    ),

    PlantDisease(
      id: 'maize_fall_armyworm',
      name: 'Fall Armyworm',
      scientificName: 'Spodoptera frugiperda',
      cropAffected: 'Maize',
      emoji: '🌽',
      severity: 'critical',
      description:
          'Invasive pest that devastates maize — a single caterpillar can destroy a seedling overnight. Major threat to Rwanda since 2017.',
      symptoms: [
        'Ragged holes in leaves, especially the whorl (heart) of young plants',
        'Presence of caterpillars (green/brown with stripes, Y-shaped marking on head)',
        'Wet sawdust-like frass (droppings) inside leaf whorl',
        'Dead heart — central shoot dies while outer leaves appear green',
        'Damaged tassels and ears in older plants',
      ],
      causes: [
        'Moth pest Spodoptera frugiperda',
        'Female moth lays 100–200 eggs on leaf surface',
        'Caterpillar stage (larva) causes damage over 14–21 days',
        'Spreads rapidly — adult moths fly up to 100 km/night',
      ],
      treatmentSteps: [
        'Step 1 — Scout fields every 3–4 days from seedling stage.',
        'Step 2 — Apply sand + ash or sawdust into the plant whorl to kill young caterpillars.',
        'Step 3 — Spray Emamectin Benzoate 1.9% EC at 400 mL/ha directly into the whorl.',
        'Step 4 — Alternatively, use Spinosad 480 SC at 62.5–125 mL/ha for organic option.',
        'Step 5 — For severe infestation, apply Chlorpyrifos 480 EC at 1 L/ha.',
        'Step 6 — Spray in the evening when caterpillars are active and feeding.',
        'Step 7 — Repeat every 7–10 days as needed.',
      ],
      preventionTips: [
        'Plant early in the season to avoid peak moth populations',
        'Intercrop maize with beans or sweet potato to disrupt pest cycles',
        'Release natural predators — parasitic wasps (Cotesia sp.)',
        'Use pheromone traps to monitor adult moth populations',
        'Report sightings to your local RAB (Rwanda Agriculture Board) extension officer',
      ],
    ),

    // ── BEANS (Ibishyimbo) ───────────────────────────────────────────────────
    PlantDisease(
      id: 'bean_angular_leaf_spot',
      name: 'Angular Leaf Spot',
      scientificName: 'Pseudocercosporella griseola',
      cropAffected: 'Beans',
      emoji: '🫘',
      severity: 'moderate',
      description:
          'One of the most common and destructive bean diseases in Rwanda. Causes angular brown spots bounded by leaf veins.',
      symptoms: [
        'Angular brown/gray spots on leaves bounded by veins',
        'Spots have dark brown border with lighter center',
        'Spots on pods are dark, sunken, and oval-shaped',
        'Severely infected leaves turn yellow and fall off',
        'Reduced pod fill and seed quality',
      ],
      causes: [
        'Fungus Pseudocercosporella griseola',
        'Infected seeds (primary source)',
        'High humidity (>85%) and temperatures 16–28°C',
        'Splashing rain spreads spores',
        'Crop residue on soil surface',
      ],
      treatmentSteps: [
        'Step 1 — Use certified, disease-free seed before planting next season.',
        'Step 2 — At first sign of spots, spray Chlorothalonil 75% WP at 2 kg/ha.',
        'Step 3 — Alternatively apply Mancozeb 80% WP at 2 kg/ha every 10–14 days.',
        'Step 4 — Remove severely infected leaves and dispose of them away from field.',
        'Step 5 — Avoid working in the field when plants are wet to reduce spread.',
        'Step 6 — If disease is severe, apply Benomyl 50% WP at 1 kg/ha as additional protection.',
      ],
      preventionTips: [
        'Plant resistant varieties: RWR 2075, RWR 10, Lyamungu 85',
        'Rotate beans with maize, sorghum, or cassava',
        'Treat seeds with Thiram 80% WP (3 g/kg seed) before planting',
        'Plant at recommended spacing to improve air circulation',
      ],
    ),

    PlantDisease(
      id: 'bean_common_mosaic',
      name: 'Bean Common Mosaic',
      scientificName: 'Bean common mosaic virus (BCMV)',
      cropAffected: 'Beans',
      emoji: '🫘',
      severity: 'high',
      description:
          'Viral disease causing mosaic discoloration, stunting, and severe yield loss. Spreads through infected seed and aphids.',
      symptoms: [
        'Mosaic yellow-green mottling on leaves',
        'Leaf puckering, blistering, and distortion',
        'Stunted plant growth',
        'Downward curling of leaves',
        'Small, shriveled seeds in pods',
        'Black root and stem necrosis in some strains',
      ],
      causes: [
        'Bean common mosaic virus (BCMV)',
        'Transmitted by aphids (Aphis fabae)',
        'Infected seed — up to 90% of infection starts from seed',
        'Mechanical transmission through cutting tools',
      ],
      treatmentSteps: [
        'Step 1 — There is no chemical cure for viral diseases — act fast.',
        'Step 2 — Remove and destroy all infected plants immediately.',
        'Step 3 — Control aphid vectors by spraying Imidacloprid 200 SL at 200 mL/ha.',
        'Step 4 — Apply mineral oil spray to reduce aphid feeding and virus transmission.',
        'Step 5 — Disinfect all tools with 10% bleach solution between plants.',
        'Step 6 — Do NOT save seed from infected fields.',
      ],
      preventionTips: [
        'Only plant certified, virus-tested seed',
        'Plant resistant varieties: RWR 2245, CAL 96',
        'Control weeds — they harbor aphids and viruses',
        'Plant away from previously infected fields',
      ],
    ),

    PlantDisease(
      id: 'bean_rust',
      name: 'Bean Rust',
      scientificName: 'Uromyces appendiculatus',
      cropAffected: 'Beans',
      emoji: '🫘',
      severity: 'moderate',
      description:
          'Fungal rust producing orange-brown powder on the underside of leaves. Very common in Rwanda\'s highland areas.',
      symptoms: [
        'Small white spots on upper leaf surface initially',
        'Orange-brown powdery pustules on leaf underside',
        'Pustules also appear on pods and stems',
        'Severely infected leaves dry up and fall',
        'Premature defoliation reduces yield',
      ],
      causes: [
        'Fungus Uromyces appendiculatus',
        'Spread by wind-carried spores',
        'Favored by temperatures 17–27°C with high humidity',
        'Dew and rain splash',
      ],
      treatmentSteps: [
        'Step 1 — Apply Triadimefon 25% WP or Propiconazole 250 EC at first sign of rust.',
        'Step 2 — Spray every 10–14 days during disease season.',
        'Step 3 — Remove and burn infected leaves to reduce spore load.',
        'Step 4 — Avoid overhead irrigation — use drip if possible.',
        'Step 5 — Apply sulfur-based fungicide (Sulfur 80% WP at 3 kg/ha) as preventive measure.',
      ],
      preventionTips: [
        'Plant early — avoid the main rainy season peak for rust',
        'Use rust-resistant bean varieties',
        'Avoid dense planting — allow wind movement between plants',
        'Rotate with non-legume crops',
      ],
    ),

    // ── CASSAVA (Imyumbati) ──────────────────────────────────────────────────
    PlantDisease(
      id: 'cassava_mosaic',
      name: 'Cassava Mosaic Disease',
      scientificName: 'East African cassava mosaic virus (EACMV)',
      cropAffected: 'Cassava',
      emoji: '🌿',
      severity: 'critical',
      description:
          'The most destructive cassava disease in East Africa. Can cause 20–100% yield loss. Spread by whitefly and infected cuttings.',
      symptoms: [
        'Yellow and green mosaic pattern on leaves',
        'Twisted, distorted leaf shape',
        'Reduced leaf size',
        'Stunted overall plant growth',
        'Small, poorly-formed tubers at harvest',
        'Chlorotic (pale yellow) new growth',
      ],
      causes: [
        'East African cassava mosaic virus (EACMV-UG)',
        'Whitefly vector (Bemisia tabaci)',
        'Infected planting cuttings (stems)',
        'Once infected, plant cannot be cured',
      ],
      treatmentSteps: [
        'Step 1 — Remove infected plants immediately — do not leave them to spread virus.',
        'Step 2 — Destroy removed plants by burning — do not compost.',
        'Step 3 — Control whitefly with Imidacloprid 200 SL (1 mL/L water) foliar spray.',
        'Step 4 — Apply reflective mulch between rows to confuse and repel whiteflies.',
        'Step 5 — Replace replanting cuttings from healthy, certified sources only.',
        'Step 6 — Do not reuse cuttings from infected fields.',
      ],
      preventionTips: [
        'Always plant certified, virus-free cuttings from RAB distribution centers',
        'Use resistant varieties: NAROCAS 1, Kibandameno, Kiroba',
        'Scout fields monthly and rogue out infected plants early',
        'Plant in healthy soil away from known infected fields',
      ],
    ),

    PlantDisease(
      id: 'cassava_brown_streak',
      name: 'Cassava Brown Streak Disease',
      scientificName: 'Cassava brown streak virus (CBSV)',
      cropAffected: 'Cassava',
      emoji: '🌿',
      severity: 'critical',
      description:
          'A devastating disease causing brown streaks on stems and severe internal rot of tubers — making roots inedible.',
      symptoms: [
        'Yellow chlorotic patches on leaves (feather-like pattern)',
        'Brown streak marks on green stems',
        'Internal brown necrotic rot in tubers (seen when cut)',
        'Healthy-looking outside but rotten inside',
        'Corky, dry necrosis spreads through the tuber flesh',
      ],
      causes: [
        'Cassava brown streak virus (CBSV and UCBSV)',
        'Transmitted by whitefly Bemisia tabaci',
        'Infected cuttings are the main long-distance spread',
      ],
      treatmentSteps: [
        'Step 1 — Cut a sample tuber — if you see brown internal rot, the field is infected.',
        'Step 2 — Remove all infected plants and burn immediately.',
        'Step 3 — Do not eat or sell affected tubers — they are unsafe.',
        'Step 4 — Control whitefly: spray Thiamethoxam 25 WG at 200 g/ha.',
        'Step 5 — Clean all tools with soap and water after working in infected area.',
        'Step 6 — Replant only with certified clean cuttings from trusted source.',
      ],
      preventionTips: [
        'Use only certified, CBSD-tested planting material',
        'Plant resistant varieties where available (NARO 45, Narocas 1)',
        'Never move cuttings from areas with known CBSD outbreak',
        'Report CBSD outbreak to RAB extension immediately',
      ],
    ),

    // ── POTATO (Ibirayi) ─────────────────────────────────────────────────────
    PlantDisease(
      id: 'potato_late_blight',
      name: 'Late Blight',
      scientificName: 'Phytophthora infestans',
      cropAffected: 'Irish Potato',
      emoji: '🥔',
      severity: 'critical',
      description:
          'The most feared potato disease worldwide — caused the Irish Famine. In Rwanda it can destroy an entire crop within days in cool, wet conditions.',
      symptoms: [
        'Dark water-soaked spots on leaves (often starting at leaf tips/edges)',
        'White mold/spores visible on underside of leaves in humid conditions',
        'Brown rotting stems — plant collapses',
        'Tubers have brown, firm rot under skin when dug',
        'Foul smell from rotting tubers in storage',
        'Entire field can go from healthy to destroyed in 5–7 days',
      ],
      causes: [
        'Water mold Phytophthora infestans',
        'Cool (10–24°C) and wet/humid conditions — typical of Rwanda highlands',
        'Infected tubers used as seed',
        'Wind-spread spores travel many kilometers',
      ],
      treatmentSteps: [
        'Step 1 — ACT IMMEDIATELY — late blight spreads very fast.',
        'Step 2 — Spray Mancozeb 80% WP at 2.5 kg/ha as protective spray BEFORE disease arrives.',
        'Step 3 — For active infection, spray Metalaxyl + Mancozeb (Ridomil Gold) at 2.5 kg/ha.',
        'Step 4 — Spray every 7 days during rain season — more often if rain is heavy.',
        'Step 5 — Remove and bury (or burn) any infected haulm immediately.',
        'Step 6 — Do not harvest in wet weather — wait for dry conditions.',
        'Step 7 — Store tubers in cool, dry, well-ventilated stores only.',
      ],
      preventionTips: [
        'Use certified, disease-free seed potato from approved suppliers',
        'Plant resistant varieties: Kinigi, Victoria, Kirundo',
        'Begin preventive fungicide spray from 3 weeks after emergence',
        'Earth up plants to protect tubers from spore wash-down',
        'Monitor weather — spray before forecast rainy/cold periods',
      ],
    ),

    PlantDisease(
      id: 'potato_early_blight',
      name: 'Early Blight',
      scientificName: 'Alternaria solani',
      cropAffected: 'Irish Potato',
      emoji: '🥔',
      severity: 'moderate',
      description:
          'Fungal disease producing concentric ring lesions ("target spots") on older potato leaves. Less severe than late blight but causes consistent yield losses.',
      symptoms: [
        'Dark brown to black spots with concentric rings (target-board pattern)',
        'Yellow halo around each lesion',
        'Affects older/lower leaves first',
        'Lesions on stems (dark sunken areas)',
        'Premature defoliation weakens plant',
      ],
      causes: [
        'Fungus Alternaria solani',
        'Warm temperatures (24–29°C) alternating with wet periods',
        'Stressed or nutrient-deficient plants are more susceptible',
        'Infected crop debris in soil',
      ],
      treatmentSteps: [
        'Step 1 — Remove and discard infected lower leaves.',
        'Step 2 — Apply Chlorothalonil 75% WP at 2 kg/ha every 7–10 days.',
        'Step 3 — Supplement with adequate nitrogen and potassium fertilizer — healthy plants resist better.',
        'Step 4 — Avoid water stress — maintain consistent irrigation.',
        'Step 5 — Apply Azoxystrobin or Difenoconazole for stronger systemic control.',
      ],
      preventionTips: [
        'Use disease-free seed',
        'Apply balanced NPK fertilizer',
        'Avoid excessive nitrogen which promotes lush growth prone to disease',
        'Remove and plow in crop debris after harvest',
      ],
    ),

    // ── BANANA (Ingizi) ──────────────────────────────────────────────────────
    PlantDisease(
      id: 'banana_xanthomonas_wilt',
      name: 'Banana Xanthomonas Wilt',
      scientificName: 'Xanthomonas vasicola pv. musacearum',
      cropAffected: 'Banana',
      emoji: '🍌',
      severity: 'critical',
      description:
          'BXW has devastated banana plantations across East Africa including Rwanda. It is highly contagious — entire plantations can be lost.',
      symptoms: [
        'Wilting and yellowing of leaves starting from outer leaves',
        'Yellowing and rotting of male bud',
        'Premature and uneven ripening of fruits',
        'Yellow-orange bacterial ooze when stem or finger is cut',
        'Internal brown/dark discoloration of pseudostem when cut',
        'Eventually entire plant dies',
      ],
      causes: [
        'Bacteria Xanthomonas vasicola pv. musacearum (Xvm)',
        'Spread by contaminated tools (machetes, knives)',
        'Insects visiting infected male flowers spread it between plants',
        'Infected planting material (suckers)',
        'No chemical cure exists',
      ],
      treatmentSteps: [
        'Step 1 — STOP — do not use any tools on other plants before disinfecting.',
        'Step 2 — Cut and bury (or burn) ALL infected plants including corm — deep burial (>50 cm).',
        'Step 3 — Disinfect all cutting tools with 10% bleach or fire between plants.',
        'Step 4 — Remove male buds on healthy plants in infected area to stop insect spread.',
        'Step 5 — Leave infected area fallow for at least 6 months.',
        'Step 6 — Replant only with certified clean suckers or tissue-culture plantlets.',
        'Step 7 — Inform your neighbors — BXW spreads to adjacent fields.',
      ],
      preventionTips: [
        'Always disinfect tools before moving between banana plants',
        'Remove male buds early (before they open) on all plants',
        'Use clean planting material only',
        'Never bring banana material from areas with known BXW',
        'Report any suspected BXW to RAB immediately — it is notifiable',
      ],
    ),

    // ── TOMATO ───────────────────────────────────────────────────────────────
    PlantDisease(
      id: 'tomato_early_blight',
      name: 'Tomato Early Blight',
      scientificName: 'Alternaria solani',
      cropAffected: 'Tomato',
      emoji: '🍅',
      severity: 'moderate',
      description:
          'Common fungal disease on tomatoes causing dark concentric-ring lesions on older leaves and fruit.',
      symptoms: [
        'Dark brown spots with concentric rings on older/lower leaves',
        'Yellow areas surrounding the spots',
        'Dark sunken lesions at stem base (collar rot in seedlings)',
        'Fruit lesions: dark, leathery, sunken areas near stem',
        'Plant loses leaves from bottom upward',
      ],
      causes: [
        'Fungus Alternaria solani',
        'Survives in soil and infected debris',
        'Spread by water splash and wind',
        'Favored by warm (24–29°C) wet conditions',
      ],
      treatmentSteps: [
        'Step 1 — Remove and destroy all infected lower leaves.',
        'Step 2 — Spray Chlorothalonil 500 SC at 1.5–2 L/ha every 7 days.',
        'Step 3 — Apply copper-based fungicide (Copper hydroxide 77% WP at 2.5 kg/ha) alternating with Chlorothalonil.',
        'Step 4 — Stake plants and prune lower leaves to improve air flow.',
        'Step 5 — Avoid overhead watering — use drip irrigation or water at soil level.',
        'Step 6 — Maintain good nutrition — nitrogen and potassium help resist disease.',
      ],
      preventionTips: [
        'Use certified disease-free transplants',
        'Stake and prune for good air circulation',
        'Practice 3-year crop rotation',
        'Apply organic mulch to prevent soil splash',
      ],
    ),

    PlantDisease(
      id: 'tomato_bacterial_wilt',
      name: 'Bacterial Wilt',
      scientificName: 'Ralstonia solanacearum',
      cropAffected: 'Tomato',
      emoji: '🍅',
      severity: 'critical',
      description:
          'Devastating soil-borne bacteria causing sudden wilting and death of tomato plants. Very persistent in soil — up to 10 years.',
      symptoms: [
        'Sudden wilting of entire plant even when soil is moist',
        'Lower leaves wilt first then whole plant collapses',
        'Cut stem placed in water shows white to cream bacterial ooze streaming out',
        'Brown discoloration inside stem when cut',
        'Roots may appear dark and rotten',
      ],
      causes: [
        'Bacteria Ralstonia solanacearum',
        'Lives in soil for many years',
        'Enters plant through root wounds',
        'Spread by water, tools, infected transplants',
        'Warm temperatures (28–35°C) and waterlogged soils favor it',
      ],
      treatmentSteps: [
        'Step 1 — There is no effective chemical cure. Remove infected plants immediately.',
        'Step 2 — Pull entire plant with roots — bag and destroy (burn or deep bury).',
        'Step 3 — Do NOT compost or leave infected material on soil surface.',
        'Step 4 — Apply slaked lime (calcium hydroxide) around the removed plant hole.',
        'Step 5 — Disinfect all tools with 70% alcohol or bleach solution.',
        'Step 6 — Avoid planting solanaceous crops (tomato, pepper, potato) in that spot for 3–4 years.',
        'Step 7 — Improve drainage — waterlogging accelerates spread.',
      ],
      preventionTips: [
        'Use grafted tomato transplants on wilt-resistant rootstocks',
        'Plant resistant varieties where available',
        'Solarize soil between seasons (cover with clear plastic for 4–6 weeks)',
        'Avoid movement of soil from infected to clean areas',
        'Practice 4-year rotation with maize, sorghum, or cereals',
      ],
    ),

    // ── WHEAT/SORGHUM ────────────────────────────────────────────────────────
    PlantDisease(
      id: 'wheat_stem_rust',
      name: 'Wheat Stem Rust',
      scientificName: 'Puccinia graminis f. sp. tritici',
      cropAffected: 'Wheat / Sorghum',
      emoji: '🌾',
      severity: 'critical',
      description:
          'Highly destructive fungal rust affecting wheat. The Ug99 strain discovered in Uganda is particularly dangerous and has spread across East Africa.',
      symptoms: [
        'Orange-red elongated pustules on stems, leaf sheaths, and leaves',
        'Pustules rupture to release rusty-red spore powder',
        'Later turn black (telial stage) in the season',
        'Stems weaken and lodge (fall over)',
        'Severely affected grain shrivels — significant yield loss',
      ],
      causes: [
        'Fungus Puccinia graminis f. sp. tritici',
        'Wind-spread spores travel hundreds of kilometers',
        'Warm days (15–35°C) and cool nights with dew favor spread',
        'Susceptible wheat varieties',
      ],
      treatmentSteps: [
        'Step 1 — Apply Propiconazole 250 EC at 0.5 L/ha or Tebuconazole 250 EW at 1 L/ha.',
        'Step 2 — Spray at first sign of pustules — early intervention is critical.',
        'Step 3 — Re-apply every 14 days during high-risk period.',
        'Step 4 — Harvest early if infestation is severe to salvage grain.',
        'Step 5 — Report Ug99 suspected rust to RAB/extension officer immediately.',
      ],
      preventionTips: [
        'Plant Ug99-resistant wheat varieties: Kakamega, Robin',
        'Plant early to escape peak rust season',
        'Use certified, treated seed',
        'Monitor crops weekly during rainy season',
      ],
    ),

    // ── COFFEE (Ikawa) ───────────────────────────────────────────────────────
    PlantDisease(
      id: 'coffee_leaf_rust',
      name: 'Coffee Leaf Rust',
      scientificName: 'Hemileia vastatrix',
      cropAffected: 'Coffee (Arabica)',
      emoji: '☕',
      severity: 'high',
      description:
          'Major disease threatening Rwanda\'s premium Arabica coffee industry. Creates orange powdery spots on leaves leading to defoliation.',
      symptoms: [
        'Yellow-orange oily spots on upper leaf surface',
        'Orange powdery spore masses on underside of leaves',
        'Infected leaves turn brown and drop',
        'Severe defoliation weakens tree and reduces yield',
        'Small, underdeveloped coffee berries',
      ],
      causes: [
        'Fungus Hemileia vastatrix',
        'Spread by wind and rain splash',
        'Favored by warm (21–25°C) humid conditions with rainfall',
        'Dense shade reduces air movement, increasing humidity',
      ],
      treatmentSteps: [
        'Step 1 — Apply copper-based fungicide (Copper hydroxide 77% WP at 3 kg/ha) at start of rainy season.',
        'Step 2 — Spray every 21 days during rainy season for protection.',
        'Step 3 — For severe infection, apply Triadimefon 25% WP at 1 kg/ha for systemic control.',
        'Step 4 — Remove and burn heavily infected branches.',
        'Step 5 — Prune shade trees to increase air circulation.',
        'Step 6 — Do not over-fertilize with nitrogen — promotes lush, susceptible growth.',
      ],
      preventionTips: [
        'Plant resistant varieties: Batian, Ruiru 11',
        'Maintain proper shade management',
        'Begin preventive copper sprays at start of rainy season',
        'Prune coffee plants to open canopy',
      ],
    ),

    // ── HEALTHY PLANT ────────────────────────────────────────────────────────
    PlantDisease(
      id: 'healthy_plant',
      name: 'Healthy Plant',
      scientificName: 'No pathogen detected',
      cropAffected: 'All crops',
      emoji: '✅',
      severity: 'low',
      description:
          'Your plant appears healthy! No significant disease symptoms were detected in this image.',
      symptoms: [
        'Normal leaf color (green)',
        'No spots, lesions, or wilting',
        'Good plant structure and growth',
      ],
      causes: [],
      treatmentSteps: [
        'Step 1 — Continue regular monitoring — check plants weekly.',
        'Step 2 — Maintain proper watering and fertilization schedule.',
        'Step 3 — Keep field clean of weeds and crop debris.',
        'Step 4 — Apply preventive fungicide at the start of each rainy season.',
        'Step 5 — If symptoms appear, re-scan the plant immediately.',
      ],
      preventionTips: [
        'Scout fields regularly — catch disease early',
        'Use certified seeds and clean planting material',
        'Practice crop rotation each season',
        'Maintain balanced soil fertility',
      ],
    ),
  ];
}
