class BookingModel {
  final String id;
  final String workshopId;
  final String customerId;
  final String serviceId;
  final String? resourceId;
  final String? technicianId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status;
  final String? notes;
  final Map<String, dynamic> vehicleInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.workshopId,
    required this.customerId,
    required this.serviceId,
    this.resourceId,
    this.technicianId,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    this.notes,
    this.vehicleInfo = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      workshopId: json['workshop_id'] as String,
      customerId: json['customer_id'] as String,
      serviceId: json['service_id'] as String,
      resourceId: json['resource_id'] as String?,
      technicianId: json['technician_id'] as String?,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      durationMinutes: json['duration_minutes'] as int,
      status: json['status'] as String? ?? 'scheduled',
      notes: json['notes'] as String?,
      vehicleInfo: json['vehicle_info'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workshop_id': workshopId,
      'customer_id': customerId,
      'service_id': serviceId,
      'resource_id': resourceId,
      'technician_id': technicianId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'status': status,
      'notes': notes,
      'vehicle_info': vehicleInfo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? workshopId,
    String? customerId,
    String? serviceId,
    String? resourceId,
    String? technicianId,
    DateTime? scheduledAt,
    int? durationMinutes,
    String? status,
    String? notes,
    Map<String, dynamic>? vehicleInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      workshopId: workshopId ?? this.workshopId,
      customerId: customerId ?? this.customerId,
      serviceId: serviceId ?? this.serviceId,
      resourceId: resourceId ?? this.resourceId,
      technicianId: technicianId ?? this.technicianId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
