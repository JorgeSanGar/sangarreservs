import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/booking_context_menu.dart';
import './widgets/calendar_filter_sheet.dart';
import './widgets/calendar_header_widget.dart';
import './widgets/resource_lane_widget.dart';
import './widgets/time_header_widget.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _horizontalScrollController;
  late ScrollController _verticalScrollController;

  DateTime _selectedDate = DateTime.now();
  bool _isWeekView = true;
  double _timeSlotWidth = 80.0;
  DateTime _startTime = DateTime.now().copyWith(hour: 8, minute: 0, second: 0);
  DateTime _endTime = DateTime.now().copyWith(hour: 18, minute: 0, second: 0);

  List<String> _selectedResourceIds = [];
  List<String> _selectedServiceTypes = [];

  // Mock data
  final List<Map<String, dynamic>> _resources = [
    {
      'id': 'elevator_1',
      'name': 'Elevador 1',
      'type': 'Elevador',
      'availability': {'isAvailable': true},
      'workingHours': {
        'start': 8,
        'end': 18,
        'breaks': [
          {'start': 12, 'end': 13},
          {'start': 15, 'end': 15.5},
        ],
      },
    },
    {
      'id': 'elevator_2',
      'name': 'Elevador 2',
      'type': 'Elevador',
      'availability': {'isAvailable': true},
      'workingHours': {
        'start': 8,
        'end': 18,
        'breaks': [
          {'start': 12, 'end': 13},
        ],
      },
    },
    {
      'id': 'bay_1',
      'name': 'Bahía 1',
      'type': 'Bahía',
      'availability': {'isAvailable': true},
      'workingHours': {
        'start': 8,
        'end': 18,
        'breaks': [],
      },
    },
    {
      'id': 'bay_2',
      'name': 'Bahía 2',
      'type': 'Bahía',
      'availability': {'isAvailable': false},
      'workingHours': {
        'start': 8,
        'end': 18,
        'breaks': [],
      },
    },
    {
      'id': 'tech_1',
      'name': 'Carlos Ruiz',
      'type': 'Técnico',
      'availability': {'isAvailable': true},
      'workingHours': {
        'start': 8,
        'end': 17,
        'breaks': [
          {'start': 12, 'end': 13},
          {'start': 15.5, 'end': 16},
        ],
      },
    },
    {
      'id': 'tech_2',
      'name': 'Ana García',
      'type': 'Técnico',
      'availability': {'isAvailable': true},
      'workingHours': {
        'start': 9,
        'end': 18,
        'breaks': [
          {'start': 13, 'end': 14},
        ],
      },
    },
  ];

  final List<Map<String, dynamic>> _bookings = [
    {
      'id': 'booking_1',
      'resourceId': 'elevator_1',
      'customerName': 'María López',
      'serviceType': 'Cambio de neumáticos',
      'status': 'programada',
      'startTime': '2025-09-01T09:00:00',
      'endTime': '2025-09-01T10:30:00',
      'vehicleType': 'Coche',
      'notes': 'Cliente prefiere neumáticos Michelin',
    },
    {
      'id': 'booking_2',
      'resourceId': 'elevator_1',
      'customerName': 'Juan Martín',
      'serviceType': 'Equilibrado',
      'status': 'en_progreso',
      'startTime': '2025-09-01T11:00:00',
      'endTime': '2025-09-01T12:00:00',
      'vehicleType': 'SUV',
      'notes': '',
    },
    {
      'id': 'booking_3',
      'resourceId': 'elevator_2',
      'customerName': 'Carmen Vega',
      'serviceType': 'Reparación de pinchazos',
      'status': 'completada',
      'startTime': '2025-09-01T08:30:00',
      'endTime': '2025-09-01T09:15:00',
      'vehicleType': 'Coche',
      'notes': 'Pinchazo en rueda trasera izquierda',
    },
    {
      'id': 'booking_4',
      'resourceId': 'bay_1',
      'customerName': 'Roberto Silva',
      'serviceType': 'Alineación',
      'status': 'programada',
      'startTime': '2025-09-01T14:00:00',
      'endTime': '2025-09-01T15:30:00',
      'vehicleType': '4x4',
      'notes': 'Vehículo con suspensión modificada',
    },
    {
      'id': 'booking_5',
      'resourceId': 'tech_1',
      'customerName': 'Elena Morales',
      'serviceType': 'Inspección',
      'status': 'programada',
      'startTime': '2025-09-01T10:00:00',
      'endTime': '2025-09-01T11:00:00',
      'vehicleType': 'Coche',
      'notes': 'Inspección pre-ITV',
    },
    {
      'id': 'booking_6',
      'resourceId': 'tech_2',
      'customerName': 'Diego Herrera',
      'serviceType': 'Rotación',
      'status': 'cancelada',
      'startTime': '2025-09-01T16:00:00',
      'endTime': '2025-09-01T16:45:00',
      'vehicleType': 'SUV',
      'notes': 'Cliente canceló por enfermedad',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _horizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();
    _selectedResourceIds = _resources.map((r) => r['id'] as String).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Calendario',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Agenda de hoy'),
            Tab(text: 'Calendario'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/booking-creation-wizard'),
            icon: CustomIconWidget(
              iconName: 'add',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Nueva reserva',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayAgendaTab(),
          _buildCalendarTab(),
        ],
      ),
    );
  }

  Widget _buildTodayAgendaTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'today',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Agenda de hoy',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Navega a la pestaña Calendario para ver la programación completa',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/today-s-agenda'),
            child: const Text('Ver agenda de hoy'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    return Column(
      children: [
        // Calendar Header
        CalendarHeaderWidget(
          selectedDate: _selectedDate,
          isWeekView: _isWeekView,
          onToggleView: _toggleView,
          onDatePicker: _showDatePicker,
          onFilter: _showFilterSheet,
        ),

        // Calendar Content
        Expanded(
          child: _isWeekView ? _buildWeekView() : _buildMonthView(),
        ),
      ],
    );
  }

  Widget _buildWeekView() {
    final filteredResources = _getFilteredResources();

    return Column(
      children: [
        // Time Header
        TimeHeaderWidget(
          startTime: _startTime,
          endTime: _endTime,
          timeSlotWidth: _timeSlotWidth,
          showCurrentTime: _isToday(),
        ),

        // Resource Lanes
        Expanded(
          child: SingleChildScrollView(
            controller: _verticalScrollController,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: _calculateTotalWidth(),
                child: Column(
                  children: filteredResources.map((resource) {
                    final resourceBookings =
                        _getResourceBookings(resource['id'] as String);

                    return ResourceLaneWidget(
                      resource: resource,
                      bookings: resourceBookings,
                      startTime: _startTime,
                      endTime: _endTime,
                      timeSlotWidth: _timeSlotWidth,
                      onBookingTap: _handleBookingTap,
                      onBookingLongPress: _handleBookingLongPress,
                      onEmptySlotLongPress: _handleEmptySlotLongPress,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'calendar_month',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Vista mensual',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'La vista mensual estará disponible próximamente',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isWeekView = true;
              });
            },
            child: const Text('Cambiar a vista semanal'),
          ),
        ],
      ),
    );
  }

  void _toggleView() {
    setState(() {
      _isWeekView = !_isWeekView;
    });
  }

  void _showDatePicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
        _updateTimeRange();
      });
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalendarFilterSheet(
        resources: _resources,
        selectedResourceIds: _selectedResourceIds,
        selectedServiceTypes: _selectedServiceTypes,
        onApplyFilters: _applyFilters,
      ),
    );
  }

  void _applyFilters(List<String> resourceIds, List<String> serviceTypes) {
    setState(() {
      _selectedResourceIds = resourceIds;
      _selectedServiceTypes = serviceTypes;
    });
  }

  void _handleBookingTap(Map<String, dynamic> booking) {
    Navigator.pushNamed(
      context,
      '/booking-details',
      arguments: booking,
    );
  }

  void _handleBookingLongPress(Map<String, dynamic> booking) {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: BookingContextMenu(
          booking: booking,
          onEdit: () => _editBooking(booking),
          onDuplicate: () => _duplicateBooking(booking),
          onReschedule: () => _rescheduleBooking(booking),
          onCancel: () => _cancelBooking(booking),
          onViewDetails: () => _handleBookingTap(booking),
        ),
      ),
    );
  }

  void _handleEmptySlotLongPress(DateTime time, String resourceId) {
    HapticFeedback.lightImpact();

    Navigator.pushNamed(
      context,
      '/booking-creation-wizard',
      arguments: {
        'selectedTime': time,
        'selectedResourceId': resourceId,
      },
    );
  }

  void _editBooking(Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editando reserva de ${booking['customerName']}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _duplicateBooking(Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Duplicando reserva de ${booking['customerName']}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }

  void _rescheduleBooking(Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reprogramando reserva de ${booking['customerName']}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  void _cancelBooking(Map<String, dynamic> booking) {
    setState(() {
      final index = _bookings.indexWhere((b) => b['id'] == booking['id']);
      if (index != -1) {
        _bookings[index]['status'] = 'cancelada';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reserva de ${booking['customerName']} cancelada'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredResources() {
    if (_selectedResourceIds.isEmpty) return _resources;

    return _resources.where((resource) {
      return _selectedResourceIds.contains(resource['id'] as String);
    }).toList();
  }

  List<Map<String, dynamic>> _getResourceBookings(String resourceId) {
    return _bookings.where((booking) {
      final matchesResource = booking['resourceId'] == resourceId;
      final matchesServiceType = _selectedServiceTypes.isEmpty ||
          _selectedServiceTypes.contains(booking['serviceType'] as String);

      return matchesResource && matchesServiceType;
    }).toList();
  }

  double _calculateTotalWidth() {
    final totalHours = _endTime.difference(_startTime).inHours;
    return 20.w + (totalHours * _timeSlotWidth);
  }

  bool _isToday() {
    final today = DateTime.now();
    return _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
  }

  void _updateTimeRange() {
    setState(() {
      _startTime = _selectedDate.copyWith(hour: 8, minute: 0, second: 0);
      _endTime = _selectedDate.copyWith(hour: 18, minute: 0, second: 0);
    });
  }
}
