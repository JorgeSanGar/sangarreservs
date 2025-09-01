import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/agenda_header_widget.dart';
import './widgets/booking_card_widget.dart';
import './widgets/empty_agenda_widget.dart';
import './widgets/resource_utilization_widget.dart';

class TodaySAgenda extends StatefulWidget {
  const TodaySAgenda({super.key});

  @override
  State<TodaySAgenda> createState() => _TodaySAgendaState();
}

class _TodaySAgendaState extends State<TodaySAgenda>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isRefreshing = false;
  String _userRole = 'manager'; // manager or worker
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Mock data for today's bookings
  final List<Map<String, dynamic>> _todayBookings = [
    {
      "id": 1,
      "customerName": "Carlos Rodríguez",
      "serviceType": "Cambio de neumáticos",
      "startTime": "09:00",
      "endTime": "10:30",
      "estimatedDuration": 90,
      "status": "scheduled",
      "vehicleInfo": "BMW X3 2020",
      "assignedTechnician": "Miguel Santos",
      "notes": "Cliente prefiere neumáticos Michelin",
    },
    {
      "id": 2,
      "customerName": "Ana García",
      "serviceType": "Reparación de pinchazos",
      "startTime": "11:00",
      "endTime": "11:45",
      "estimatedDuration": 45,
      "status": "in-progress",
      "vehicleInfo": "Seat León 2019",
      "assignedTechnician": "José Martín",
      "notes": "Pinchazo en rueda delantera derecha",
    },
    {
      "id": 3,
      "customerName": "Pedro Fernández",
      "serviceType": "Equilibrado",
      "startTime": "12:30",
      "endTime": "13:15",
      "estimatedDuration": 45,
      "status": "scheduled",
      "vehicleInfo": "Volkswagen Golf 2021",
      "assignedTechnician": "Miguel Santos",
      "notes": "Vibración en volante a alta velocidad",
    },
    {
      "id": 4,
      "customerName": "María López",
      "serviceType": "Alineación",
      "startTime": "15:00",
      "endTime": "16:00",
      "estimatedDuration": 60,
      "status": "delayed",
      "vehicleInfo": "Toyota Corolla 2018",
      "assignedTechnician": "José Martín",
      "notes": "Desgaste irregular en neumáticos",
    },
    {
      "id": 5,
      "customerName": "Javier Moreno",
      "serviceType": "Cambio de neumáticos",
      "startTime": "16:30",
      "endTime": "18:00",
      "estimatedDuration": 90,
      "status": "completed",
      "vehicleInfo": "Ford Focus 2020",
      "assignedTechnician": "Miguel Santos",
      "notes": "Cambio completo de 4 neumáticos",
    },
  ];

  // Mock resource utilization data (only for managers)
  final List<Map<String, dynamic>> _resourceData = [
    {
      "name": "Elevador 1",
      "utilization": 0.85,
      "type": "equipment",
    },
    {
      "name": "Elevador 2",
      "utilization": 0.65,
      "type": "equipment",
    },
    {
      "name": "Miguel Santos",
      "utilization": 0.92,
      "type": "technician",
    },
    {
      "name": "José Martín",
      "utilization": 0.78,
      "type": "technician",
    },
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
    _loadInitialData();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    HapticFeedback.lightImpact();

    // Simulate refresh API call
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agenda actualizada'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleNotificationTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abriendo notificaciones...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleBookingTap(Map<String, dynamic> booking) {
    Navigator.pushNamed(
      context,
      '/booking-details',
      arguments: booking,
    );
  }

  void _handleStartService(Map<String, dynamic> booking) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando servicio para ${booking['customerName']}'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {},
        ),
      ),
    );
  }

  void _handleContactCustomer(Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contactar Cliente',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            Text(
              booking['customerName'] as String,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Llamando al cliente...')),
                      );
                    },
                    icon: CustomIconWidget(
                      iconName: 'phone',
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text('Llamar'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enviando mensaje...')),
                      );
                    },
                    icon: CustomIconWidget(
                      iconName: 'message',
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    label: const Text('Mensaje'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _handleReschedule(Map<String, dynamic> booking) {
    Navigator.pushNamed(
      context,
      '/booking-creation-wizard',
      arguments: {'reschedule': true, 'booking': booking},
    );
  }

  void _handleCancel(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Text(
          '¿Estás seguro de que quieres cancelar la reserva de ${booking['customerName']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mantener'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Reserva de ${booking['customerName']} cancelada'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Cancelar Reserva'),
          ),
        ],
      ),
    );
  }

  void _handleCreateBooking() {
    Navigator.pushNamed(context, '/booking-creation-wizard');
  }

  List<Map<String, dynamic>> _getFilteredBookings() {
    if (_userRole == 'worker') {
      // Filter bookings for current worker (mock: Miguel Santos)
      return _todayBookings
          .where((booking) => booking['assignedTechnician'] == 'Miguel Santos')
          .toList();
    }
    return _todayBookings;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredBookings = _getFilteredBookings();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Sticky header
          AgendaHeaderWidget(
            onRefresh: _refreshData,
            onNotificationTap: _handleNotificationTap,
            notificationCount: 3,
          ),

          // Main content
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Cargando agenda...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshData,
                    color: colorScheme.primary,
                    child: filteredBookings.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: 70.h,
                              child: EmptyAgendaWidget(
                                onCreateBooking: _handleCreateBooking,
                              ),
                            ),
                          )
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              // Resource utilization (only for managers)
                              if (_userRole == 'manager')
                                ResourceUtilizationWidget(
                                  resourceData: _resourceData,
                                ),

                              // Bookings list
                              SizedBox(height: 1.h),
                              ...filteredBookings
                                  .map((booking) => BookingCardWidget(
                                        booking: booking,
                                        onTap: () => _handleBookingTap(booking),
                                        onStartService: () =>
                                            _handleStartService(booking),
                                        onContactCustomer: () =>
                                            _handleContactCustomer(booking),
                                        onReschedule: () =>
                                            _handleReschedule(booking),
                                        onCancel: () => _handleCancel(booking),
                                      )),

                              // Bottom padding for FAB
                              SizedBox(height: 10.h),
                            ],
                          ),
                  ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _handleCreateBooking,
          icon: CustomIconWidget(
            iconName: 'add',
            color: Colors.white,
            size: 24,
          ),
          label: const Text('Nueva Reserva'),
          tooltip: 'Crear nueva reserva',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Bottom Navigation
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/today-s-agenda',
        onTap: (route) {
          if (route != '/today-s-agenda') {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }
}
