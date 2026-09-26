/// Domain model for a crowdsourced Abuja informal-transit route.
enum TransitMode { korope, keke, bus, lightRail }

extension TransitModeX on TransitMode {
  String get label {
    switch (this) {
      case TransitMode.korope:
        return 'Korope (Minibus)';
      case TransitMode.keke:
        return 'Keke (Tricycle)';
      case TransitMode.bus:
        return 'AUMT Bus';
      case TransitMode.lightRail:
        return 'Light Rail';
    }
  }

  String get shortLabel {
    switch (this) {
      case TransitMode.korope:
        return 'Korope';
      case TransitMode.keke:
        return 'Keke';
      case TransitMode.bus:
        return 'Bus';
      case TransitMode.lightRail:
        return 'Rail';
    }
  }
}

/// Verification state of a crowdsourced submission.
enum RouteStatus { verified, pending, flagged }

class TransitRoute {
  final String id;
  final String origin;
  final String destination;
  final TransitMode mode;
  final double fareMin;
  final double fareMax;
  final List<String> stops;
  final RouteStatus status;
  final String? notes;
  final String? submittedBy;
  final DateTime? submittedAt;

  const TransitRoute({
    required this.id,
    required this.origin,
    required this.destination,
    required this.mode,
    required this.fareMin,
    required this.fareMax,
    this.stops = const [],
    this.status = RouteStatus.pending,
    this.notes,
    this.submittedBy,
    this.submittedAt,
  });

  /// Human readable fare range, e.g. "₦150 - ₦250" or "₦200" when fixed.
  String get fareLabel {
    if (fareMin == fareMax) return '₦${fareMin.toStringAsFixed(0)}';
    return '₦${fareMin.toStringAsFixed(0)} - ₦${fareMax.toStringAsFixed(0)}';
  }

  String get routeLabel => '$origin → $destination';

  TransitRoute copyWith({
    String? id,
    String? origin,
    String? destination,
    TransitMode? mode,
    double? fareMin,
    double? fareMax,
    List<String>? stops,
    RouteStatus? status,
    String? notes,
    String? submittedBy,
    DateTime? submittedAt,
  }) {
    return TransitRoute(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      mode: mode ?? this.mode,
      fareMin: fareMin ?? this.fareMin,
      fareMax: fareMax ?? this.fareMax,
      stops: stops ?? this.stops,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'origin': origin,
        'destination': destination,
        'mode': mode.name,
        'fareMin': fareMin,
        'fareMax': fareMax,
        'stops': stops,
        'status': status.name,
        'notes': notes,
        'submittedBy': submittedBy,
        'submittedAt': submittedAt?.toIso8601String(),
      };

  factory TransitRoute.fromJson(Map<String, dynamic> json) => TransitRoute(
        id: json['id'] as String,
        origin: json['origin'] as String,
        destination: json['destination'] as String,
        mode: TransitMode.values.firstWhere(
          (m) => m.name == json['mode'],
          orElse: () => TransitMode.korope,
        ),
        fareMin: (json['fareMin'] as num).toDouble(),
        fareMax: (json['fareMax'] as num).toDouble(),
        stops: (json['stops'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        status: RouteStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => RouteStatus.pending,
        ),
        notes: json['notes'] as String?,
        submittedBy: json['submittedBy'] as String?,
        submittedAt: json['submittedAt'] != null ? DateTime.tryParse(json['submittedAt'] as String) : null,
      );
}
