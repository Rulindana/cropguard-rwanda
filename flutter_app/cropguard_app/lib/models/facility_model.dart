class Facility {
  final String id;
  final String name;
  final String district;
  final String type;
  final double lat;
  final double lng;
  final double capacityTons;
  final double availableCapacityTons;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String operationalHours;

  Facility({
    required this.id,
    required this.name,
    required this.district,
    required this.type,
    required this.lat,
    required this.lng,
    required this.capacityTons,
    required this.availableCapacityTons,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    required this.operationalHours,
  });

  double get usedCapacity => capacityTons - availableCapacityTons;
  double get utilizationPct =>
      capacityTons > 0 ? (usedCapacity / capacityTons) * 100 : 0.0;

  factory Facility.fromFirestore(Map<String, dynamic> data, String id) {
    return Facility(
      id: id,
      name: data['name'] ?? '',
      district: data['district'] ?? '',
      type: data['type'] ?? 'drying_ground',
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      capacityTons: (data['capacity_tons'] as num).toDouble(),
      availableCapacityTons:
          (data['available_capacity_tons'] as num).toDouble(),
      contactName: data['contact_name'] ?? '',
      contactPhone: data['contact_phone'] ?? '',
      contactEmail: data['contact_email'] ?? '',
      operationalHours: data['operational_hours'] ?? '06:00-18:00',
    );
  }

  String get typeIcon {
    switch (type) {
      case 'drying_ground':
        return '☀️';
      case 'silo':
        return '🏛️';
      case 'cold_storage':
        return '❄️';
      case 'storage_center':
        return '📦';
      case 'mobile_dryer':
        return '🚛';
      default:
        return '🏭';
    }
  }

  String get typeLabel {
    switch (type) {
      case 'drying_ground':
        return 'Drying Ground';
      case 'silo':
        return 'Silo Storage';
      case 'cold_storage':
        return 'Cold Storage';
      case 'storage_center':
        return 'Storage Center';
      case 'mobile_dryer':
        return 'Mobile Dryer';
      default:
        return 'Facility';
    }
  }
}
