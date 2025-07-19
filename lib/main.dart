// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:reconciliation_app/data_screen.dart';
// import 'providers.dart';
// import 'home_screen.dart' hide SizedBox;
// import 'analytics_screen.dart';

// void main() {
//   runApp(const ReconciliationApp());
// }

// class ReconciliationApp extends StatelessWidget {
//   const ReconciliationApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => TransactionProvider()),
//         ChangeNotifierProvider(create: (_) => FilterProvider()),
//         ChangeNotifierProvider(create: (_) => ThemeProvider()),
//         ChangeNotifierProvider(create: (_) => AppStateProvider()),
//         ChangeNotifierProvider(create: (_) => UploadStateProvider()),
//       ],
//       child: Consumer<ThemeProvider>(
//         builder: (context, themeProvider, child) {
//           return MaterialApp(
//             title: 'Reconciliation Dashboard',
//             theme: themeProvider.themeData,
//             debugShowCheckedModeBanner: false,
//             home: const MainScreen(),
//           );
//         },
//       ),
//     );
//   }
// }

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AppStateProvider>(
//       builder: (context, appState, child) {
//         return Consumer<TransactionProvider>(
//           builder: (context, transactionProvider, child) {
//             return Scaffold(
//               appBar: AppBar(
//                 title: Row(
//                   children: [
//                     const Icon(Icons.account_balance, color: Colors.white),
//                     const SizedBox(width: 12),
//                     Text(
//                       appState.appTitle,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20,
//                       ),
//                     ),
//                   ],
//                 ),
//                 actions: [
//                   // Data summary in app bar
//                   if (transactionProvider.hasData)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 4),
//                       margin: const EdgeInsets.only(right: 8),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         '${transactionProvider.allTransactions.length} transactions',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),

//                   // Theme toggle button
//                   IconButton(
//                     onPressed: () =>
//                         context.read<ThemeProvider>().toggleTheme(),
//                     icon: Icon(
//                       context.watch<ThemeProvider>().isDarkMode
//                           ? Icons.light_mode
//                           : Icons.dark_mode,
//                       color: Colors.white,
//                     ),
//                     tooltip: 'Toggle theme',
//                   ),

//                   // Settings button
//                   IconButton(
//                     onPressed: () => _showSettingsDialog(context),
//                     icon: const Icon(Icons.settings, color: Colors.white),
//                     tooltip: 'Settings',
//                   ),
//                 ],
//                 bottom: TabBar(
//                   controller: _tabController,
//                   labelColor: Colors.white,
//                   unselectedLabelColor: Colors.white70,
//                   indicatorColor: Colors.white,
//                   tabs: const [
//                     Tab(
//                       icon: Icon(Icons.home),
//                       text: 'Dashboard',
//                     ),
//                     Tab(
//                       icon: Icon(Icons.table_view),
//                       text: 'Data',
//                     ),
//                     Tab(
//                       icon: Icon(Icons.analytics),
//                       text: 'Analytics',
//                     ),
//                   ],
//                 ),
//               ),
//               body: Stack(
//                 children: [
//                   TabBarView(
//                     controller: _tabController,
//                     children: const [
//                       HomeScreen(),
//                       DataScreen(),
//                       AnalyticsScreen(),
//                     ],
//                   ),

//                   // Error overlay
//                   if (transactionProvider.hasError)
//                     Positioned(
//                       top: 0,
//                       left: 0,
//                       right: 0,
//                       child: Container(
//                         color: Colors.red,
//                         padding: const EdgeInsets.all(8),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.error, color: Colors.white),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 transactionProvider.error ??
//                                     'An error occurred',
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                             ),
//                             IconButton(
//                               onPressed: () => transactionProvider.clearData(),
//                               icon:
//                                   const Icon(Icons.close, color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                   // Success message overlay
//                   if (transactionProvider.successMessage != null)
//                     Positioned(
//                       top: 0,
//                       left: 0,
//                       right: 0,
//                       child: Container(
//                         color: Colors.green,
//                         padding: const EdgeInsets.all(8),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.check_circle, color: Colors.white),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 transactionProvider.successMessage!,
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                             ),
//                             IconButton(
//                               onPressed: null, // Button is disabled
//                               icon:
//                                   const Icon(Icons.close, color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void _showSettingsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Settings'),
//         content: SizedBox(
//           width: 400,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Theme Settings
//               ListTile(
//                 leading: const Icon(Icons.palette),
//                 title: const Text('Dark Mode'),
//                 trailing: Consumer<ThemeProvider>(
//                   builder: (context, provider, child) {
//                     return Switch(
//                       value: provider.isDarkMode,
//                       onChanged: (value) => provider.toggleTheme(),
//                     );
//                   },
//                 ),
//               ),

//               const Divider(),

//               // Export Options
//               const ListTile(
//                 leading: Icon(Icons.file_download),
//                 title: Text('Export Options'),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                           _showExportOptions(context);
//                         },
//                         icon: const Icon(Icons.table_chart),
//                         label: const Text('Export to Excel'),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                           _showExportOptions(context);
//                         },
//                         icon: const Icon(Icons.picture_as_pdf),
//                         label: const Text('Export to PDF'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showExportOptions(BuildContext context) {
//     final provider = context.read<TransactionProvider>();

//     if (!provider.hasData) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No data available to export'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Export Data'),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Choose export format:'),
//             SizedBox(height: 16),
//             // Export format options would go here
//             Text(
//                 'Export functionality will be implemented based on your requirements.'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               // Implement actual export functionality
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Export feature will be implemented'),
//                   backgroundColor: Colors.blue,
//                 ),
//               );
//             },
//             child: const Text('Export'),
//           ),
//         ],
//       ),
//     );
//   }
// }

//2- final

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:reconciliation_app/ReconProvider.dart';
// import 'package:reconciliation_app/data_screen.dart';
// import 'providers.dart';
// import 'home_screen.dart' hide SizedBox;
// import 'analytics_screen.dart';

// void main() {
//   runApp(const ReconciliationApp());
// }

// class ReconciliationApp extends StatelessWidget {
//   const ReconciliationApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => TransactionProvider()),
//         ChangeNotifierProvider(create: (_) => FilterProvider()),
//         ChangeNotifierProvider(create: (_) => ThemeProvider()),
//         ChangeNotifierProvider(create: (_) => AppStateProvider()),
//         ChangeNotifierProvider(create: (_) => UploadStateProvider()),
//         ChangeNotifierProvider(create: (_) => ReconProvider()),
//       ],
//       child: Consumer<ThemeProvider>(
//         builder: (context, themeProvider, child) {
//           return MaterialApp(
//             title: 'Reconciliation Dashboard',
//             theme: themeProvider.themeData,
//             debugShowCheckedModeBanner: false,
//             home: const MainScreen(),
//           );
//         },
//       ),
//     );
//   }
// }

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AppStateProvider>(
//       builder: (context, appState, child) {
//         return Consumer<TransactionProvider>(
//           builder: (context, transactionProvider, child) {
//             return Scaffold(
//               appBar: AppBar(
//                 title: Row(
//                   children: [
//                     const Icon(Icons.account_balance, color: Colors.white),
//                     const SizedBox(width: 12),
//                     Text(
//                       appState.appTitle,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20,
//                       ),
//                     ),
//                   ],
//                 ),
//                 actions: [
//                   // Data summary in app bar
//                   if (transactionProvider.hasData)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 4),
//                       margin: const EdgeInsets.only(right: 8),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         '${transactionProvider.allTransactions.length} transactions',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),

//                   // Theme toggle button
//                   IconButton(
//                     onPressed: () =>
//                         context.read<ThemeProvider>().toggleTheme(),
//                     icon: Icon(
//                       context.watch<ThemeProvider>().isDarkMode
//                           ? Icons.light_mode
//                           : Icons.dark_mode,
//                       color: Colors.white,
//                     ),
//                     tooltip: 'Toggle theme',
//                   ),

//                   // Settings button
//                   IconButton(
//                     onPressed: () => _showSettingsDialog(context),
//                     icon: const Icon(Icons.settings, color: Colors.white),
//                     tooltip: 'Settings',
//                   ),
//                 ],
//                 bottom: TabBar(
//                   controller: _tabController,
//                   labelColor: const Color.fromARGB(255, 19, 19, 19),
//                   unselectedLabelColor: const Color.fromARGB(179, 17, 17, 17),
//                   indicatorColor: const Color.fromARGB(255, 25, 25, 25),
//                   tabs: const [
//                     Tab(
//                       icon: Icon(Icons.home),
//                       text: 'Home',
//                     ),
//                     Tab(
//                       icon: Icon(Icons.table_view),
//                       text: 'Data',
//                     ),
//                     // Tab(
//                     //   icon: Icon(Icons.analytics),
//                     //   text: 'Analytics',
//                     // ),
//                   ],
//                 ),
//               ),
//               body: Stack(
//                 children: [
//                   TabBarView(
//                     controller: _tabController,
//                     children: [
//                       HomeScreen(),
//                       DataScreen(),
//                       AnalyticsScreen(),
//                     ],
//                   ),

//                   // Error overlay
//                   if (transactionProvider.hasError)
//                     Positioned(
//                       top: 0,
//                       left: 0,
//                       right: 0,
//                       child: Container(
//                         color: Colors.red,
//                         padding: const EdgeInsets.all(8),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.error, color: Colors.white),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 transactionProvider.error ??
//                                     'An error occurred',
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                             ),
//                             IconButton(
//                               onPressed: () => transactionProvider.clearData(),
//                               icon:
//                                   const Icon(Icons.close, color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void _showSettingsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Settings'),
//         content: SizedBox(
//           width: 400,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Theme Settings
//               ListTile(
//                 leading: const Icon(Icons.palette),
//                 title: const Text('Dark Mode'),
//                 trailing: Consumer<ThemeProvider>(
//                   builder: (context, provider, child) {
//                     return Switch(
//                       value: provider.isDarkMode,
//                       onChanged: (value) => provider.toggleTheme(),
//                     );
//                   },
//                 ),
//               ),

//               const Divider(),

//               // Export Options
//               const ListTile(
//                 leading: Icon(Icons.file_download),
//                 title: Text('Export Options'),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                           _showExportOptions(context);
//                         },
//                         icon: const Icon(Icons.table_chart),
//                         label: const Text('Export to Excel'),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                           _showExportOptions(context);
//                         },
//                         icon: const Icon(Icons.picture_as_pdf),
//                         label: const Text('Export to PDF'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showExportOptions(BuildContext context) {
//     final provider = context.read<TransactionProvider>();

//     if (!provider.hasData) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No data available to export'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Export Data'),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Choose export format:'),
//             SizedBox(height: 16),
//             // Export format options would go here
//             Text(
//                 'Export functionality will be implemented based on your requirements.'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               // Implement actual export functionality
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Export feature will be implemented'),
//                   backgroundColor: Colors.blue,
//                 ),
//               );
//             },
//             child: const Text('Export'),
//           ),
//         ],
//       ),
//     );
//   }
// }

//3

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:reconciliation_app/ReconProvider.dart';
// import 'package:reconciliation_app/data_screen.dart';
// import 'providers.dart';
// import 'home_screen.dart' hide SizedBox;
// import 'analytics_screen.dart';

// // Custom Theme Data
// class AppTheme {
//   static const Color sage = Color(0xFF606C38); // Primary green
//   static const Color darkGreen = Color(0xFF283618); // Dark accent
//   static const Color cream = Color(0xFFFEFAE0); // Light background
//   static const Color golden = Color(0xFFDDA15E); // Secondary accent
//   static const Color bronze = Color(0xFFBC6C25); // Primary action

//   static ThemeData get lightTheme => ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: sage,
//           brightness: Brightness.light,
//           background: cream,
//           surface: Colors.white,
//           primary: sage,
//           secondary: golden,
//         ),
//         scaffoldBackgroundColor: cream,
//         appBarTheme: AppBarTheme(
//           backgroundColor: darkGreen,
//           elevation: 0,
//           foregroundColor: Colors.white,
//           titleTextStyle: const TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//           iconTheme: const IconThemeData(color: Colors.white),
//         ),
//         tabBarTheme: TabBarTheme(
//           labelColor: cream,
//           unselectedLabelColor: cream.withOpacity(0.7),
//           indicatorColor: golden,
//           indicatorSize: TabBarIndicatorSize.label,
//           labelStyle: const TextStyle(fontWeight: FontWeight.w600),
//           unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
//         ),
//         cardTheme: CardTheme(
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           color: Colors.white,
//           shadowColor: darkGreen.withOpacity(0.1),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             elevation: 0,
//             backgroundColor: bronze,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//           ),
//         ),
//         outlinedButtonTheme: OutlinedButtonThemeData(
//           style: OutlinedButton.styleFrom(
//             foregroundColor: sage,
//             side: const BorderSide(color: golden),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//           ),
//         ),
//         textButtonTheme: TextButtonThemeData(
//           style: TextButton.styleFrom(
//             foregroundColor: sage,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//         ),
//         switchTheme: SwitchThemeData(
//           thumbColor: MaterialStateProperty.resolveWith((states) {
//             if (states.contains(MaterialState.selected)) {
//               return bronze;
//             }
//             return golden;
//           }),
//           trackColor: MaterialStateProperty.resolveWith((states) {
//             if (states.contains(MaterialState.selected)) {
//               return bronze.withOpacity(0.3);
//             }
//             return golden.withOpacity(0.3);
//           }),
//         ),
//       );

//   static ThemeData get darkTheme => ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: sage,
//           brightness: Brightness.dark,
//           background: darkGreen,
//           surface: const Color(0xFF1A1F0F),
//           primary: sage,
//           secondary: golden,
//         ),
//         scaffoldBackgroundColor: darkGreen,
//         appBarTheme: AppBarTheme(
//           backgroundColor: darkGreen,
//           elevation: 0,
//           foregroundColor: cream,
//           titleTextStyle: const TextStyle(
//             color: cream,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//           iconTheme: const IconThemeData(color: cream),
//         ),
//         tabBarTheme: TabBarTheme(
//           labelColor: cream,
//           unselectedLabelColor: cream.withOpacity(0.7),
//           indicatorColor: golden,
//           indicatorSize: TabBarIndicatorSize.label,
//           labelStyle: const TextStyle(fontWeight: FontWeight.w600),
//           unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
//         ),
//         cardTheme: CardTheme(
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           color: const Color(0xFF1A1F0F),
//           shadowColor: sage.withOpacity(0.1),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             elevation: 0,
//             backgroundColor: bronze,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//           ),
//         ),
//         outlinedButtonTheme: OutlinedButtonThemeData(
//           style: OutlinedButton.styleFrom(
//             foregroundColor: sage,
//             side: const BorderSide(color: golden),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//           ),
//         ),
//         textButtonTheme: TextButtonThemeData(
//           style: TextButton.styleFrom(
//             foregroundColor: sage,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//         ),
//         switchTheme: SwitchThemeData(
//           thumbColor: MaterialStateProperty.resolveWith((states) {
//             if (states.contains(MaterialState.selected)) {
//               return bronze;
//             }
//             return golden;
//           }),
//           trackColor: MaterialStateProperty.resolveWith((states) {
//             if (states.contains(MaterialState.selected)) {
//               return bronze.withOpacity(0.3);
//             }
//             return golden.withOpacity(0.3);
//           }),
//         ),
//       );
// }

// void main() {
//   runApp(const ReconciliationApp());
// }

// class ReconciliationApp extends StatelessWidget {
//   const ReconciliationApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => TransactionProvider()),
//         ChangeNotifierProvider(create: (_) => FilterProvider()),
//         ChangeNotifierProvider(create: (_) => ThemeProvider()),
//         ChangeNotifierProvider(create: (_) => AppStateProvider()),
//         ChangeNotifierProvider(create: (_) => UploadStateProvider()),
//         ChangeNotifierProvider(create: (_) => ReconProvider()),
//       ],
//       child: Consumer<ThemeProvider>(
//         builder: (context, themeProvider, child) {
//           return MaterialApp(
//             title: 'Reconciliation Dashboard',
//             theme: themeProvider.isDarkMode
//                 ? AppTheme.darkTheme
//                 : AppTheme.lightTheme,
//             debugShowCheckedModeBanner: false,
//             home: const MainScreen(),
//           );
//         },
//       ),
//     );
//   }
// }

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
//   late TabController _tabController;
//   late AnimationController _fadeController;
//   late AnimationController _slideController;

//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);

//     // Initialize animation controllers
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     // Initialize animations
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, -0.1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _slideController,
//       curve: Curves.easeOutCubic,
//     ));

//     // Start animations
//     _fadeController.forward();
//     _slideController.forward();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _fadeController.dispose();
//     _slideController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AppStateProvider>(
//       builder: (context, appState, child) {
//         return Consumer<TransactionProvider>(
//           builder: (context, transactionProvider, child) {
//             return Scaffold(
//               appBar: AppBar(
//                 flexibleSpace: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         AppTheme.darkGreen,
//                         AppTheme.sage,
//                       ],
//                     ),
//                   ),
//                 ),
//                 title: SlideTransition(
//                   position: _slideAnimation,
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.15),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: const Icon(
//                             Icons.account_balance_rounded,
//                             color: Colors.white,
//                             size: 24,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Text(
//                             appState.appTitle,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w700,
//                               fontSize: 20,
//                               letterSpacing: -0.3,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 actions: [
//                   // Data summary badge
//                   if (transactionProvider.hasData)
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 8),
//                       margin: const EdgeInsets.only(right: 12),
//                       decoration: BoxDecoration(
//                         color: AppTheme.golden.withOpacity(0.9),
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppTheme.golden.withOpacity(0.3),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Text(
//                         '${transactionProvider.allTransactions.length} transactions',
//                         style: const TextStyle(
//                           color: AppTheme.darkGreen,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),

//                   // Theme toggle with animation
//                   AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     child: IconButton(
//                       onPressed: () =>
//                           context.read<ThemeProvider>().toggleTheme(),
//                       icon: AnimatedSwitcher(
//                         duration: const Duration(milliseconds: 300),
//                         child: Icon(
//                           context.watch<ThemeProvider>().isDarkMode
//                               ? Icons.light_mode_rounded
//                               : Icons.dark_mode_rounded,
//                           key: ValueKey(
//                               context.watch<ThemeProvider>().isDarkMode),
//                           color: Colors.white,
//                         ),
//                       ),
//                       tooltip: 'Toggle theme',
//                       style: IconButton.styleFrom(
//                         backgroundColor: Colors.white.withOpacity(0.1),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 8),

//                   // Settings button
//                   IconButton(
//                     onPressed: () => _showSettingsDialog(context),
//                     icon:
//                         const Icon(Icons.settings_rounded, color: Colors.white),
//                     tooltip: 'Settings',
//                     style: IconButton.styleFrom(
//                       backgroundColor: Colors.white.withOpacity(0.1),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 16),
//                 ],
//                 bottom: PreferredSize(
//                   preferredSize: const Size.fromHeight(50),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.1),
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         topRight: Radius.circular(20),
//                       ),
//                     ),
//                     child: TabBar(
//                       controller: _tabController,
//                       labelColor: Colors.white,
//                       unselectedLabelColor: Colors.white.withOpacity(0.6),
//                       indicatorColor: AppTheme.golden,
//                       indicatorWeight: 3,
//                       indicatorSize: TabBarIndicatorSize.label,
//                       labelStyle: const TextStyle(fontWeight: FontWeight.w600),
//                       unselectedLabelStyle:
//                           const TextStyle(fontWeight: FontWeight.w400),
//                       tabs: const [
//                         Tab(
//                           icon: Icon(Icons.home_rounded),
//                           text: 'Home',
//                         ),
//                         Tab(
//                           icon: Icon(Icons.table_view_rounded),
//                           text: 'Data',
//                         ),
//                         Tab(
//                           icon: Icon(Icons.analytics_rounded),
//                           text: 'Analytics',
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               body: Stack(
//                 children: [
//                   FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: TabBarView(
//                       controller: _tabController,
//                       children: [
//                         HomeScreen(),
//                         DataScreen(),
//                         AnalyticsScreen(),
//                       ],
//                     ),
//                   ),

//                   // Animated error overlay
//                   if (transactionProvider.hasError)
//                     Positioned(
//                       top: 0,
//                       left: 0,
//                       right: 0,
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 300),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [Colors.red.shade600, Colors.red.shade700],
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.red.withOpacity(0.3),
//                               blurRadius: 8,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         padding: const EdgeInsets.all(16),
//                         child: SafeArea(
//                           child: Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.2),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: const Icon(
//                                   Icons.error_rounded,
//                                   color: Colors.white,
//                                   size: 20,
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(
//                                   transactionProvider.error ??
//                                       'An error occurred',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                               IconButton(
//                                 onPressed: () =>
//                                     transactionProvider.clearData(),
//                                 icon: const Icon(
//                                   Icons.close_rounded,
//                                   color: Colors.white,
//                                 ),
//                                 style: IconButton.styleFrom(
//                                   backgroundColor:
//                                       Colors.white.withOpacity(0.2),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void _showSettingsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         child: AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: AppTheme.sage.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(
//                   Icons.settings_rounded,
//                   color: AppTheme.sage,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'Settings',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w700,
//                   color: AppTheme.darkGreen,
//                 ),
//               ),
//             ],
//           ),
//           content: SizedBox(
//             width: 400,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Theme Settings
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: AppTheme.sage.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: AppTheme.golden.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Icon(
//                           Icons.palette_rounded,
//                           color: AppTheme.bronze,
//                           size: 20,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Expanded(
//                         child: Text(
//                           'Dark Mode',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             color: AppTheme.darkGreen,
//                           ),
//                         ),
//                       ),
//                       Consumer<ThemeProvider>(
//                         builder: (context, provider, child) {
//                           return AnimatedContainer(
//                             duration: const Duration(milliseconds: 200),
//                             child: Switch(
//                               value: provider.isDarkMode,
//                               onChanged: (value) => provider.toggleTheme(),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // Export Options Section
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: AppTheme.golden.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: AppTheme.bronze.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Icon(
//                               Icons.file_download_rounded,
//                               color: AppTheme.bronze,
//                               size: 20,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           const Text(
//                             'Export Options',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               color: AppTheme.darkGreen,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: OutlinedButton.icon(
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                                 _showExportOptions(context);
//                               },
//                               icon: const Icon(Icons.table_chart_rounded,
//                                   size: 18),
//                               label: const Text('Excel'),
//                               style: OutlinedButton.styleFrom(
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 12),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: OutlinedButton.icon(
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                                 _showExportOptions(context);
//                               },
//                               icon: const Icon(Icons.picture_as_pdf_rounded,
//                                   size: 18),
//                               label: const Text('PDF'),
//                               style: OutlinedButton.styleFrom(
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 12),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Close'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showExportOptions(BuildContext context) {
//     final provider = context.read<TransactionProvider>();

//     if (!provider.hasData) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: const Icon(
//                   Icons.warning_rounded,
//                   color: Colors.white,
//                   size: 16,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Text('No data available to export'),
//             ],
//           ),
//           backgroundColor: AppTheme.bronze,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: AppTheme.bronze.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.file_download_rounded,
//                 color: AppTheme.bronze,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Text(
//               'Export Data',
//               style: TextStyle(
//                 fontWeight: FontWeight.w700,
//                 color: AppTheme.darkGreen,
//               ),
//             ),
//           ],
//         ),
//         content: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: const Color.fromARGB(255, 77, 73, 50).withOpacity(0.5),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: const Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Choose export format:',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: AppTheme.darkGreen,
//                 ),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Export functionality will be implemented based on your requirements.',
//                 style: TextStyle(
//                   color: AppTheme.sage,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton.icon(
//             onPressed: () {
//               Navigator.of(context).pop();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: const Icon(
//                           Icons.info_rounded,
//                           color: Colors.white,
//                           size: 16,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Text('Export feature will be implemented'),
//                     ],
//                   ),
//                   backgroundColor: AppTheme.sage,
//                   behavior: SnackBarBehavior.floating,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               );
//             },
//             icon: const Icon(Icons.download_rounded, size: 18),
//             label: const Text('Export'),
//           ),
//         ],
//       ),
//     );
//   }
// }

//4

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reconciliation_app/ReconProvider.dart';
import 'package:reconciliation_app/data_screen.dart';
import 'providers.dart';
import 'home_screen.dart' hide SizedBox;
import 'analytics_screen.dart';

// Custom Theme Data
class AppTheme {
  static const Color sage = Color(0xFF606C38); // Primary green
  static const Color darkGreen = Color(0xFF283618); // Dark accent
  static const Color cream = Color(0xFFFEFAE0); // Light background
  static const Color golden = Color(0xFFDDA15E); // Secondary accent
  static const Color bronze = Color(0xFFBC6C25); // Primary action

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: sage,
          brightness: Brightness.light,
          background: cream,
          surface: Colors.white,
          primary: sage,
          secondary: golden,
        ),
        scaffoldBackgroundColor: cream,
        appBarTheme: AppBarTheme(
          backgroundColor: darkGreen,
          elevation: 0,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: cream,
          unselectedLabelColor: cream.withOpacity(0.7),
          indicatorColor: golden,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          dividerColor: Colors.transparent, // Remove tab bar divider
          dividerHeight: 0, // Set divider height to 0
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          shadowColor: darkGreen.withOpacity(0.1),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: bronze,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: sage,
            side: const BorderSide(color: golden),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: sage,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return bronze;
            }
            return golden;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return bronze.withOpacity(0.3);
            }
            return golden.withOpacity(0.3);
          }),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: sage,
          brightness: Brightness.dark,
          background: darkGreen,
          surface: const Color(0xFF1A1F0F),
          primary: sage,
          secondary: golden,
        ),
        scaffoldBackgroundColor: darkGreen,
        appBarTheme: AppBarTheme(
          backgroundColor: darkGreen,
          elevation: 0,
          foregroundColor: cream,
          titleTextStyle: const TextStyle(
            color: cream,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: cream),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: cream,
          unselectedLabelColor: cream.withOpacity(0.7),
          indicatorColor: golden,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFF1A1F0F),
          shadowColor: sage.withOpacity(0.1),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: bronze,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: sage,
            side: const BorderSide(color: golden),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: sage,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return bronze;
            }
            return golden;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return bronze.withOpacity(0.3);
            }
            return golden.withOpacity(0.3);
          }),
        ),
      );
}

void main() {
  runApp(const ReconciliationApp());
}

class ReconciliationApp extends StatelessWidget {
  const ReconciliationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => UploadStateProvider()),
        ChangeNotifierProvider(create: (_) => ReconProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Reconciliation Dashboard',
            theme: themeProvider.isDarkMode
                ? AppTheme.darkTheme
                : AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Consumer<TransactionProvider>(
          builder: (context, transactionProvider, child) {
            return Scaffold(
              appBar: AppBar(
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.darkGreen,
                        AppTheme.sage,
                      ],
                    ),
                  ),
                ),
                title: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            appState.appTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  // Data summary badge
                  if (transactionProvider.hasData)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.golden.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.golden.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${transactionProvider.allTransactions.length} transactions',
                        style: const TextStyle(
                          color: AppTheme.darkGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  // Theme toggle with animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: IconButton(
                      onPressed: () =>
                          context.read<ThemeProvider>().toggleTheme(),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          context.watch<ThemeProvider>().isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          key: ValueKey(
                              context.watch<ThemeProvider>().isDarkMode),
                          color: Colors.white,
                        ),
                      ),
                      tooltip: 'Toggle theme',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Settings button
                  IconButton(
                    onPressed: () => _showSettingsDialog(context),
                    icon:
                        const Icon(Icons.settings_rounded, color: Colors.white),
                    tooltip: 'Settings',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withOpacity(0.6),
                      indicatorColor: AppTheme.golden,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      unselectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.w400),
                      dividerColor:
                          Colors.transparent, // Remove the divider line
                      dividerHeight: 0, // Ensure no height for divider
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.home_rounded),
                          text: 'Home',
                        ),
                        Tab(
                          icon: Icon(Icons.table_view_rounded),
                          text: 'Data',
                        ),
                        Tab(
                          icon: Icon(Icons.analytics_rounded),
                          text: 'Analytics',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: Stack(
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        HomeScreen(),
                        DataScreen(),
                        AnalyticsScreen(),
                      ],
                    ),
                  ),

                  // Animated error overlay
                  if (transactionProvider.hasError)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade600, Colors.red.shade700],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: SafeArea(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.error_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  transactionProvider.error ??
                                      'An error occurred',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    transactionProvider.clearData(),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.sage.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: AppTheme.sage,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkGreen,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Theme Settings
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.sage.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.golden.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.palette_rounded,
                          color: AppTheme.bronze,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkGreen,
                          ),
                        ),
                      ),
                      Consumer<ThemeProvider>(
                        builder: (context, provider, child) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: Switch(
                              value: provider.isDarkMode,
                              onChanged: (value) => provider.toggleTheme(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Export Options Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.golden.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.bronze.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.file_download_rounded,
                              color: AppTheme.bronze,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Export Options',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showExportOptions(context);
                              },
                              icon: const Icon(Icons.table_chart_rounded,
                                  size: 18),
                              label: const Text('Excel'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showExportOptions(context);
                              },
                              icon: const Icon(Icons.picture_as_pdf_rounded,
                                  size: 18),
                              label: const Text('PDF'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    final provider = context.read<TransactionProvider>();

    if (!provider.hasData) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text('No data available to export'),
            ],
          ),
          backgroundColor: AppTheme.bronze,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.bronze.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.file_download_rounded,
                color: AppTheme.bronze,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Export Data',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.darkGreen,
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cream.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose export format:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkGreen,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Export functionality will be implemented based on your requirements.',
                style: TextStyle(
                  color: AppTheme.sage,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.info_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Export feature will be implemented'),
                    ],
                  ),
                  backgroundColor: AppTheme.sage,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Export'),
          ),
        ],
      ),
    );
  }
}
