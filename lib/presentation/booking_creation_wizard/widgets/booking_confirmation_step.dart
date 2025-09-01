import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BookingConfirmationStep extends StatefulWidget {
  final Map<String, dynamic>? selectedService;
  final Map<String, dynamic>? vehicleConfig;
  final Map<String, dynamic>? selectedSlot;
  final Function(Map<String, dynamic>) onBookingConfirmed;

  const BookingConfirmationStep({
    super.key,
    this.selectedService,
    this.vehicleConfig,
    this.selectedSlot,
    required this.onBookingConfirmed,
  });

  @override
  State<BookingConfirmationStep> createState() =>
      _BookingConfirmationStepState();
}

class _BookingConfirmationStepState extends State<BookingConfirmationStep> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String visitMode = "Wait";
  bool isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _calculateTotalPrice() {
    if (widget.selectedService == null || widget.vehicleConfig == null)
      return 0.0;

    double basePrice = (widget.selectedService!["price"] as double);
    final vehicleType = widget.vehicleConfig!["vehicleType"] as String;
    final wheelCount = widget.vehicleConfig!["wheelCount"] as int;

    // Vehicle type multiplier
    switch (vehicleType) {
      case "4x4":
        basePrice *= 1.4;
        break;
      case "SUV":
        basePrice *= 1.6;
        break;
    }

    // Wheel count multiplier
    basePrice = basePrice * wheelCount / 4;

    // Additional services
    if (widget.vehicleConfig!["punctureRepair"] as bool) basePrice += 15.0;
    if (widget.vehicleConfig!["balancing"] as bool) basePrice += 20.0;
    if (widget.vehicleConfig!["alignment"] as bool) basePrice += 35.0;

    return basePrice;
  }

  int _calculateTotalDuration() {
    if (widget.selectedService == null || widget.vehicleConfig == null)
      return 0;

    int baseDuration = (widget.selectedService!["baseDuration"] as int);
    final vehicleType = widget.vehicleConfig!["vehicleType"] as String;
    final wheelCount = widget.vehicleConfig!["wheelCount"] as int;

    // Vehicle type multiplier
    switch (vehicleType) {
      case "4x4":
        baseDuration = (baseDuration * 1.3).round();
        break;
      case "SUV":
        baseDuration = (baseDuration * 1.5).round();
        break;
    }

    // Wheel count multiplier
    baseDuration = (baseDuration * wheelCount / 4).round();

    // Additional services
    if (widget.vehicleConfig!["punctureRepair"] as bool) baseDuration += 15;
    if (widget.vehicleConfig!["balancing"] as bool) baseDuration += 20;
    if (widget.vehicleConfig!["alignment"] as bool) baseDuration += 30;

    return baseDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirmar Reserva',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Revisa los detalles y completa tu información de contacto',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingSummary(),
                  SizedBox(height: 3.h),
                  _buildVisitModeSelector(),
                  SizedBox(height: 3.h),
                  _buildCustomerForm(),
                  SizedBox(height: 3.h),
                  _buildConfirmButton(),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de la Reserva',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),

          // Service details
          _buildSummaryRow(
            'Servicio',
            widget.selectedService?["name"] ?? "No seleccionado",
            isTitle: true,
          ),
          _buildSummaryRow(
            'Vehículo',
            '${widget.vehicleConfig?["vehicleType"]} - ${widget.vehicleConfig?["wheelCount"]} ruedas',
          ),

          // Additional services
          if (widget.vehicleConfig?["punctureRepair"] == true)
            _buildSummaryRow('', '+ Reparación de pinchazos'),
          if (widget.vehicleConfig?["balancing"] == true)
            _buildSummaryRow('', '+ Balanceado de ruedas'),
          if (widget.vehicleConfig?["alignment"] == true)
            _buildSummaryRow('', '+ Alineación de dirección'),

          SizedBox(height: 1.h),
          Divider(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3)),
          SizedBox(height: 1.h),

          // Schedule details
          _buildSummaryRow(
            'Fecha y Hora',
            '${_formatDate(widget.selectedSlot?["date"])} - ${widget.selectedSlot?["startTime"]}',
            isTitle: true,
          ),
          _buildSummaryRow(
            'Duración Estimada',
            '${_calculateTotalDuration()} minutos',
          ),
          _buildSummaryRow(
            'Técnico Asignado',
            widget.selectedSlot?["technician"] ?? "Por asignar",
          ),

          SizedBox(height: 1.h),
          Divider(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3)),
          SizedBox(height: 1.h),

          // Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Precio Total',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              Text(
                '€${_calculateTotalPrice().toStringAsFixed(2)}',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTitle = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 30.w,
              child: Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isTitle ? FontWeight.w600 : FontWeight.w400,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ] else ...[
            SizedBox(width: 30.w),
          ],
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: isTitle ? FontWeight.w600 : FontWeight.w400,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitModeSelector() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modalidad de Visita',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),

          // Wait option
          _buildVisitModeOption(
            'Wait',
            'Esperar en el Taller',
            'Permanece en el taller durante el servicio',
            'schedule',
          ),

          SizedBox(height: 2.h),

          // Drop-off option
          _buildVisitModeOption(
            'Drop-off',
            'Dejar y Recoger',
            'Deja tu vehículo y recógelo cuando esté listo',
            'directions_car',
          ),
        ],
      ),
    );
  }

  Widget _buildVisitModeOption(
      String mode, String title, String description, String iconName) {
    final isSelected = visitMode == mode;

    return GestureDetector(
      onTap: () {
        setState(() {
          visitMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primaryContainer
              : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  size: 5.w,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerForm() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información de Contacto',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),

          // Name field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre Completo *',
              hintText: 'Introduce tu nombre completo',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es obligatorio';
              }
              if (value.trim().length < 2) {
                return 'El nombre debe tener al menos 2 caracteres';
              }
              return null;
            },
          ),

          SizedBox(height: 2.h),

          // Phone field
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono *',
              hintText: '+34 600 000 000',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El teléfono es obligatorio';
              }
              if (value.trim().length < 9) {
                return 'Introduce un número de teléfono válido';
              }
              return null;
            },
          ),

          SizedBox(height: 2.h),

          // Notes field
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notas Adicionales (Opcional)',
              hintText: 'Información adicional sobre tu vehículo o servicio...',
              prefixIcon: Icon(Icons.note_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isProcessing ? null : _confirmBooking,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Procesando...',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              )
            : Text(
                'Confirmar Reserva',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }

  void _confirmBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isProcessing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final bookingData = {
      "service": widget.selectedService,
      "vehicleConfig": widget.vehicleConfig,
      "slot": widget.selectedSlot,
      "visitMode": visitMode,
      "customer": {
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "notes": _notesController.text.trim(),
      },
      "totalPrice": _calculateTotalPrice(),
      "totalDuration": _calculateTotalDuration(),
      "bookingId": DateTime.now().millisecondsSinceEpoch.toString(),
      "status": "scheduled",
      "createdAt": DateTime.now().toIso8601String(),
    };

    setState(() {
      isProcessing = false;
    });

    widget.onBookingConfirmed(bookingData);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Fecha no seleccionada";

    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    final weekdays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];

    return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
  }
}
