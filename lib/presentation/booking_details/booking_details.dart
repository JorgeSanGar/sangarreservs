import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/booking_status_badge.dart';
import './widgets/booking_timeline_widget.dart';
import './widgets/customer_information_card.dart';
import './widgets/duration_tracking_widget.dart';
import './widgets/notes_section_widget.dart';
import './widgets/resource_assignment_card.dart';
import './widgets/service_information_card.dart';
import './widgets/visit_mode_indicator.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({super.key});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  // Mock data for booking details
  final Map<String, dynamic> _bookingData = {
    "id": "BK-2025-001",
    "status": "en_progreso",
    "serviceType": "Cambio de Neumáticos + Balanceado",
    "serviceCode": "CNB-001",
    "vehicleType": "Coche",
    "vehicleBrand": "Volkswagen",
    "vehicleModel": "Golf GTI",
    "wheelCount": 4,
    "estimatedDuration": "45 min",
    "price": "€120.00",
    "additionalServices": ["Alineación", "Revisión de Presión"],
    "visitMode": "esperar",
    "arrivalWindow": "14:30 - 15:00",
    "serviceStartTime": DateTime.now().subtract(const Duration(minutes: 15)),
    "isPaused": false,
    "pausedDuration": Duration.zero,
    "timeline": [
      {
        "title": "Cita Programada",
        "description": "Cita creada y confirmada con el cliente",
        "timestamp": "01/09/2025 - 09:30",
        "user": "María González",
        "completed": true,
        "current": false,
      },
      {
        "title": "Cliente Llegó",
        "description":
            "Cliente llegó al taller dentro de la ventana recomendada",
        "timestamp": "01/09/2025 - 14:35",
        "user": "Carlos Ruiz",
        "completed": true,
        "current": false,
      },
      {
        "title": "Servicio Iniciado",
        "description": "Técnico comenzó el servicio de cambio de neumáticos",
        "timestamp": "01/09/2025 - 14:45",
        "user": "Carlos Ruiz",
        "completed": true,
        "current": true,
      },
      {
        "title": "Servicio Completado",
        "description": "Servicio finalizado y vehículo listo para entrega",
        "timestamp": null,
        "user": null,
        "completed": false,
        "current": false,
      },
    ],
  };

  final Map<String, dynamic> _customerData = {
    "name": "Ana Martínez López",
    "phone": "+34 612 345 678",
    "email": "ana.martinez@email.com",
    "address": "Calle Mayor 123, 28001 Madrid",
    "notes":
        "Cliente preferente. Solicita llamada 10 minutos antes de finalizar el servicio.",
  };

  final Map<String, dynamic> _resourceData = {
    "bay": "Bahía 2",
    "bayStatus": "ocupado",
    "technician": "Carlos Ruiz Fernández",
    "technicianStatus": "ocupado",
    "equipment": "Elevador Hidráulico + Balanceadora",
    "equipmentStatus": "disponible",
    "startTime": "14:30",
    "endTime": "15:30",
  };

  final List<Map<String, dynamic>> _notesData = [
    {
      "id": 1,
      "content":
          "Cliente solicita revisión adicional de frenos. Programar para próxima visita.",
      "author": "Carlos Ruiz",
      "timestamp": "01/09/2025 - 14:50",
    },
    {
      "id": 2,
      "content":
          "Neumático delantero derecho tenía desgaste irregular. Recomendada alineación.",
      "author": "María González",
      "timestamp": "01/09/2025 - 14:35",
    },
  ];

  final String _currentUserRole = "manager"; // Can be "manager" or "worker"
  bool _isServicePaused = false;
  Duration _currentServiceDuration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Detalles de la Cita',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: colorScheme.onSurface,
            size: 20,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: colorScheme.onSurface,
              size: 24,
            ),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'share',
                      color: colorScheme.onSurface,
                      size: 16,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Compartir',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'print',
                      color: colorScheme.onSurface,
                      size: 16,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Imprimir',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'history',
                      color: colorScheme.onSurface,
                      size: 16,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Ver Historial',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Badge Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BookingStatusBadge(
                      status: _bookingData['status'] as String,
                      isLarge: true,
                    ),
                    const Spacer(),
                    Text(
                      _bookingData['id'] as String,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  'Programada para hoy, ${_bookingData['startTime']} - ${_bookingData['endTime']}',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Scrollable Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshBookingData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 1.h),
                    // Service Information
                    ServiceInformationCard(booking: _bookingData),
                    // Customer Information
                    CustomerInformationCard(customer: _customerData),
                    // Duration Tracking (only for in-progress bookings)
                    DurationTrackingWidget(
                      bookingStatus: _bookingData['status'] as String,
                      serviceStartTime:
                          _bookingData['serviceStartTime'] as DateTime?,
                      pausedDuration:
                          _bookingData['pausedDuration'] as Duration?,
                      isPaused: _isServicePaused,
                      onDurationUpdate: (duration) {
                        setState(() {
                          _currentServiceDuration = duration;
                        });
                      },
                    ),
                    // Timeline
                    BookingTimelineWidget(booking: _bookingData),
                    // Resource Assignment
                    ResourceAssignmentCard(
                      resources: _resourceData,
                      userRole: _currentUserRole,
                      onReassign: _handleResourceReassignment,
                    ),
                    // Visit Mode
                    VisitModeIndicator(
                      visitMode: _bookingData['visitMode'] as String,
                      arrivalWindow: _bookingData['arrivalWindow'] as String,
                    ),
                    // Notes Section
                    NotesSectionWidget(
                      notes: _notesData,
                      userRole: _currentUserRole,
                      onAddNote: _handleAddNote,
                    ),
                    SizedBox(height: 10.h), // Space for action buttons
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Action Buttons
      bottomNavigationBar: ActionButtonsWidget(
        bookingStatus: _bookingData['status'] as String,
        userRole: _currentUserRole,
        isServicePaused: _isServicePaused,
        onStartService: _handleStartService,
        onCompleteService: _handleCompleteService,
        onPauseService: _handlePauseService,
        onResumeService: _handleResumeService,
        onReschedule: _handleReschedule,
        onCancel: _handleCancelBooking,
        onDuplicate: _handleDuplicateBooking,
      ),
    );
  }

  Future<void> _refreshBookingData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        // Update booking data from server
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Datos actualizados',
            style: GoogleFonts.inter(fontSize: 14.sp),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareBookingDetails();
        break;
      case 'print':
        _printBookingDetails();
        break;
      case 'history':
        _viewBookingHistory();
        break;
    }
  }

  void _shareBookingDetails() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Compartiendo detalles de la cita...',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
      ),
    );
  }

  void _printBookingDetails() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Preparando impresión...',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
      ),
    );
  }

  void _viewBookingHistory() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Abriendo historial de la cita...',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
      ),
    );
  }

  void _handleStartService() {
    HapticFeedback.mediumImpact();
    setState(() {
      _bookingData['status'] = 'en_progreso';
      _bookingData['serviceStartTime'] = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Servicio iniciado',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _handleCompleteService() {
    HapticFeedback.mediumImpact();
    setState(() {
      _bookingData['status'] = 'completado';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Servicio completado exitosamente',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _handlePauseService() {
    HapticFeedback.lightImpact();
    setState(() {
      _isServicePaused = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Servicio pausado',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        backgroundColor: AppTheme.warningLight,
      ),
    );
  }

  void _handleResumeService() {
    HapticFeedback.lightImpact();
    setState(() {
      _isServicePaused = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Servicio reanudado',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _handleReschedule() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/booking-creation-wizard');
  }

  void _handleCancelBooking() {
    HapticFeedback.heavyImpact();
    setState(() {
      _bookingData['status'] = 'cancelado';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cita cancelada',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        backgroundColor: AppTheme.errorLight,
      ),
    );
  }

  void _handleDuplicateBooking() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/booking-creation-wizard');
  }

  void _handleResourceReassignment() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Abriendo reasignación de recursos...',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
      ),
    );
  }

  void _handleAddNote(String note) {
    HapticFeedback.lightImpact();
    setState(() {
      _notesData.insert(0, {
        "id": _notesData.length + 1,
        "content": note,
        "author": "Usuario Actual",
        "timestamp":
            "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} - ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Nota agregada exitosamente',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
      ),
    );
  }
}