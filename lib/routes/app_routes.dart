import 'package:flutter/material.dart';
import '../presentation/booking_creation_wizard/booking_creation_wizard.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/today_s_agenda/today_s_agenda.dart';
import '../presentation/calendar_view/calendar_view.dart';
import '../presentation/booking_details/booking_details.dart';
import '../presentation/workshop_configuration/workshop_configuration.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/service_catalog_management/service_catalog_management.dart';
import '../presentation/team_management/team_management.dart';
import '../presentation/kpi_dashboard/kpi_dashboard.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/splash-screen';
  static const String splashScreen = '/splash-screen';
  static const String bookingCreationWizard = '/booking-creation-wizard';
  static const String login = '/login-screen';
  static const String todaySAgenda = '/today-s-agenda';
  static const String calendarView = '/calendar-view';
  static const String bookingDetails = '/booking-details';
  static const String workshopConfiguration = '/workshop-configuration';
  static const String serviceCatalogManagement = '/service-catalog-management';
  static const String teamManagement = '/team-management';
  static const String kpiDashboard = '/kpi-dashboard';

  static Map<String, WidgetBuilder> routes = {
    splashScreen: (context) => const SplashScreen(),
    bookingCreationWizard: (context) => const BookingCreationWizard(),
    login: (context) => const LoginScreen(),
    todaySAgenda: (context) => const TodaySAgenda(),
    calendarView: (context) => const CalendarView(),
    bookingDetails: (context) => const BookingDetails(),
    workshopConfiguration: (context) => const WorkshopConfiguration(),
    serviceCatalogManagement: (context) => const ServiceCatalogManagement(),
    teamManagement: (context) => const TeamManagement(),
    kpiDashboard: (context) => const KpiDashboard(),
    // TODO: Add your other routes here
  };
}
