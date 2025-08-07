import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import './providers/bus_schedule.dart';
import './providers/terminal_seats_provider.dart';
import './providers/bus_stops_provider.dart';
import './providers/receipt_provider.dart';
import './providers/auth_provider.dart';
import './providers/seat_selection_provider.dart';
import './providers/terminal_provider.dart';
import './providers/selected_seat_provider.dart';
import './providers/origin_provider.dart';
import './providers/road_provider.dart';
import './providers/user_provider.dart';
import './providers/cancellation_provider.dart';

import './admin/auth/admin_landingscreen.dart';
import './admin/auth/admin_login.dart';
import './admin/admin_screens/all_earnings_screen.dart';
import './admin/admin_widgets/all_earnings_daily.dart';
import './admin/admin_screens/admin_verificationlist.dart';
import './admin/admin_widgets/all_earnings_monthly.dart';
import './admin/admin_widgets/all_earnings_per_trip.dart';
import './admin/admin_screens/admin_location_screen.dart';

import './bus/auth/bus_registration.dart';
import './bus/auth/bus_login.dart';
import './bus/bus_providers/bus_provider.dart';
import './bus/bus_screens/driver_seat_ui_screen.dart';
import './bus/bus_screens/bus_home_screen.dart';
import './bus/bus_screens/bus_location_screen.dart';
import './bus/bus_screens/bus_earnings_screen.dart';
import './bus/bus_screens/bus_forms_screen.dart';
import './bus/bus_screens/map_picker_bus_screen.dart';
import './bus/bus_screens/bus_pay_screen.dart';
import './bus/bus_providers/bus_receipt_provider.dart';
import './bus/bus_providers/passenger_details_provider.dart';
import './bus/bus_screens/bus_receipt_screen.dart';
import './bus/bus_widgets/bus_earnings_daily.dart';
import './bus/bus_widgets/per_trip_earnings.dart';

import './screens/book_from_screen.dart';
import './screens/wallet_screens.dart';
import './screens/authentication/users/login_screen.dart';
import './screens/authentication/users/register_screen.dart';
import './screens/authentication/users/forgot_password.dart';
import './screens/home_screen.dart';
import './screens/splash_screen.dart';
import './screens/pay_now_screen.dart';
import './screens/receipt_screen.dart';
import './screens/bus_schedule_screen.dart';
import './screens/verification/verification_screen.dart';
import './screens/edit_profile_screen.dart';
import './screens/seat_ui_screen.dart';
import './screens/user_location_screen.dart';
import './screens/our_mission_screen.dart';
import './screens/about_us_screen.dart';
import './screens/map_picker_screen.dart';
import './screens/terminal_bus_list_screen.dart';
import './screens/map_picker_road_screen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCLWkVBbOOf3Al3t8eX-UXAuwGd_loJQfs',
      appId: '1:961625405654:android:e66fb5bb198ea57bd1f177',
      messagingSenderId: '961625405654',
      projectId: 'esp32-firebase-48836',
      databaseURL:
          'https://esp32-firebase-48836-default-rtdb.asia-southeast1.firebasedatabase.app',
      storageBucket: 'esp32-firebase-48836.appspot.com',
    ),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) => runApp(
      const Gabus(),
    ),
  );
}

class Gabus extends StatefulWidget {
  const Gabus({Key? key}) : super(key: key);

  @override
  State<Gabus> createState() => _GabusState();
}

class _GabusState extends State<Gabus> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => OriginProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => BusProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => BusStopProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ReceiptProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => BusReceiptProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ScheduleProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PassengerDetailsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => OnRoadProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => OnTerminalProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CancellationProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SelectedSeatProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SeatSelectionProvider(),
        ),
        ChangeNotifierProxyProvider<BusStopProvider, TerminalSeatsProvider>(
          create: (ctx) => TerminalSeatsProvider(
            busStopProvider: Provider.of<BusStopProvider>(ctx, listen: false),
          ),
          update: (ctx, busStopProvider, _) => TerminalSeatsProvider(
            busStopProvider: busStopProvider,
          ),
        ),
      ],
      child: MaterialApp(
        navigatorObservers: [routeObserver],
        title: 'GaBus',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color.fromARGB(255, 255, 139, 0),
            secondary: const Color.fromARGB(255, 254, 255, 219),
            tertiary: const Color.fromARGB(255, 243, 170, 60),
          ),
          appBarTheme: const AppBarTheme(foregroundColor: Colors.black),
        ),
        home: const SplashScreen(),
        routes: {
          SplashScreen.routeName: (ctx) => const SplashScreen(),
          //Admin side routes
          AdminLandingScreen.routeName: (ctx) => const AdminLandingScreen(),
          AdminLocationScreen.routeName: (ctx) => AdminLocationScreen(),
          AdminLoginScreen.routeName: (ctx) => const AdminLoginScreen(),
          AllEarningsScreen.routeName: (ctx) => const AllEarningsScreen(),
          AllEarningsDaily.routeName: (ctx) => const AllEarningsDaily(),
          AllEarningsMonthly.routeName: (ctx) => const AllEarningsMonthly(),
          AllEarningsPerTrip.routeName: (ctx) => const AllEarningsPerTrip(),
          AdminVerificationScreen.routeName: (ctx) => AdminVerificationScreen(),
          // AdminVerificationDetailScreen.routeName: (ctx) =>
          //     AdminVerificationDetailScreen(),
          //Driver side routs
          BusRegistrationScreen.routeName: (ctx) =>
              const BusRegistrationScreen(),
          BusLoginScreen.routeName: (ctx) => const BusLoginScreen(),
          BusHomeScreen.routeName: (ctx) => const BusHomeScreen(),
          BusLocationScreen.routeName: (ctx) => BusLocationScreen(),
          DriverSeatUiScreen.routeName: (ctx) => const DriverSeatUiScreen(),
          BusEarningsScreen.routeName: (ctx) => const BusEarningsScreen(),
          BusEarningsDaily.routeName: (ctx) => const BusEarningsDaily(),
          BusFormScreen.routeName: (ctx) => const BusFormScreen(),
          BusPayScreen.routeName: (ctx) => const BusPayScreen(),
          MapPickerBusScreen.routeName: (ctx) => MapPickerBusScreen(),
          BusReceiptScreen.routeName: (ctx) => const BusReceiptScreen(),
          PerTripEarnings.routeName: (ctx) => const PerTripEarnings(),
          //User Side Routes
          RegisterScreen.routeName: (ctx) => RegisterScreen(),
          LoginScreen.routeName: (ctx) => const LoginScreen(),
          ForgotPasswordScreen.routeName: (ctx) => const ForgotPasswordScreen(),
          HomePageScreen.routeName: (ctx) => HomePageScreen(),
          OurMissionScreen.routeName: (ctx) => const OurMissionScreen(),
          AboutUsScreen.routeName: (ctx) => const AboutUsScreen(),
          PayNowScreen.routeName: (ctx) => const PayNowScreen(),
          ReceiptScreen.routeName: (ctx) => ReceiptScreen(),
          WalletScreen.routeName: (ctx) => const WalletScreen(),
          BusScheduleScreen.routeName: (ctx) => BusScheduleScreen(),
          EditProfileScreen.routename: (ctx) => const EditProfileScreen(),
          VerificationScreen.routename: (ctx) => const VerificationScreen(),
          SeatUiScreen.routename: (ctx) => const SeatUiScreen(),
          BookFromScreen.routeName: (ctx) => const BookFromScreen(),
          UserLocationScreen.routeName: (ctx) => UserLocationScreen(),
          TerminalBusListScreen.routeName: (ctx) => TerminalBusListScreen(),
          MapPickerScreen.routeName: (ctx) => MapPickerScreen(),
          MapPickerRoadScreen.routeName: (ctx) => MapPickerRoadScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
