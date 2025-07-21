// import 'package:flutter/material.dart';
// import 'database_service.dart';

// // Custom Theme Data (matching reference)
// class AppTheme {
//   static const Color sage = Color(0xFF606C38); // Primary green
//   static const Color darkGreen = Color(0xFF283618); // Dark accent
//   static const Color cream = Color(0xFFFEFAE0); // Light background
//   static const Color golden = Color(0xFFDDA15E); // Secondary accent
//   static const Color bronze = Color(0xFFBC6C25); // Primary action
//   static const Color accent = Color(0xFFDDA15E); // Accent color

//   static ThemeData get theme => ThemeData(
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
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           foregroundColor: darkGreen,
//           titleTextStyle: TextStyle(
//             color: darkGreen,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
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
//       );
// }

// class DataScreen extends StatefulWidget {
//   const DataScreen({super.key});

//   @override
//   State<DataScreen> createState() => _DataScreenState();
// }

// class _DataScreenState extends State<DataScreen> with TickerProviderStateMixin {
//   bool _isLoading = false;
//   List<dynamic> _reconData = [];
//   List<dynamic> _filteredData = [];
//   String _statusMessage = '';
//   String _searchQuery = '';
//   String _selectedFilter = 'All';
//   int _currentPage = 0;
//   final int _rowsPerPage = 20;

//   // Animation controllers
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   // Filter options
//   final List<String> _filterOptions = [
//     'All',
//     'Payment Only',
//     'Refund Only',
//     'Mismatched',
//     'Perfect Match'
//   ];

//   // Statistics
//   Map<String, dynamic> _statistics = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadReconData();

//     // Initialize animations
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
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
//     _fadeController.dispose();
//     _slideController.dispose();
//     super.dispose();
//   }

//   // Load reconciliation data from database
//   Future<void> _loadReconData() async {
//     setState(() {
//       _isLoading = true;
//       _statusMessage = 'Loading reconciliation data...';
//     });

//     try {
//       final response = await DatabaseService.getReconSummary();
//       if (response['status'] == 'success') {
//         setState(() {
//           _reconData = response['data'] ?? [];
//           _filteredData = List.from(_reconData);
//           _statusMessage =
//               'Data loaded successfully (${_reconData.length} records)';
//         });
//         _calculateStatistics();
//         _applyFilters();
//       } else {
//         setState(() {
//           _statusMessage = 'Failed to load data: ${response['error']}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Error loading data: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Calculate statistics from the data
//   void _calculateStatistics() {
//     if (_reconData.isEmpty) return;

//     int totalTransactions = _reconData.length;
//     double totalCloudAmount = 0;
//     double totalGatewayAmount = 0;
//     int perfectMatches = 0;
//     int mismatches = 0;

//     for (var record in _reconData) {
//       // Calculate cloud total
//       double cloudPayment = _parseDouble(record['Cloud_Payment']);
//       double cloudRefund = _parseDouble(record['Cloud_Refund']);
//       double cloudTotal = cloudPayment + cloudRefund;
//       totalCloudAmount += cloudTotal;

//       // Calculate gateway total
//       double gatewayTotal = _parseDouble(record['Paytm_Payment']) +
//           _parseDouble(record['Phonepe_Payment']) +
//           _parseDouble(record['VMSMoney_Payment']) +
//           _parseDouble(record['Card_Payment']) +
//           _parseDouble(record['Sodexo_Payment']) +
//           _parseDouble(record['HDFC_Payment']) +
//           _parseDouble(record['CASH_Payment']) -
//           _parseDouble(record['Paytm_Refund']) -
//           _parseDouble(record['Phonepe_Refund']) -
//           _parseDouble(record['VMSMoney_Refund']) -
//           _parseDouble(record['Card_Refund']) -
//           _parseDouble(record['Sodexo_Refund']) -
//           _parseDouble(record['HDFC_Refund']);

//       totalGatewayAmount += gatewayTotal;

//       // Check for perfect match
//       if ((cloudTotal - gatewayTotal).abs() < 0.01) {
//         perfectMatches++;
//       } else {
//         mismatches++;
//       }
//     }

//     setState(() {
//       _statistics = {
//         'totalTransactions': totalTransactions,
//         'totalCloudAmount': totalCloudAmount,
//         'totalGatewayAmount': totalGatewayAmount,
//         'perfectMatches': perfectMatches,
//         'mismatches': mismatches,
//         'matchPercentage': totalTransactions > 0
//             ? (perfectMatches / totalTransactions * 100)
//             : 0,
//         'amountDifference': totalCloudAmount - totalGatewayAmount,
//       };
//     });
//   }

//   // Parse double values safely
//   double _parseDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) {
//       return double.tryParse(value) ?? 0.0;
//     }
//     return 0.0;
//   }

//   // Apply search and filter
//   void _applyFilters() {
//     List<dynamic> filtered = List.from(_reconData);

//     // Apply search filter
//     if (_searchQuery.isNotEmpty) {
//       filtered = filtered.where((record) {
//         return record['Txn_RefNo']
//                     ?.toString()
//                     .toLowerCase()
//                     .contains(_searchQuery.toLowerCase()) ==
//                 true ||
//             record['Txn_Machine']
//                     ?.toString()
//                     .toLowerCase()
//                     .contains(_searchQuery.toLowerCase()) ==
//                 true ||
//             record['Txn_MID']
//                     ?.toString()
//                     .toLowerCase()
//                     .contains(_searchQuery.toLowerCase()) ==
//                 true;
//       }).toList();
//     }

//     // Apply category filter
//     switch (_selectedFilter) {
//       case 'Payment Only':
//         filtered = filtered.where((record) {
//           double totalPayments = _parseDouble(record['Cloud_Payment']) +
//               _parseDouble(record['Paytm_Payment']) +
//               _parseDouble(record['Phonepe_Payment']) +
//               _parseDouble(record['Card_Payment']) +
//               _parseDouble(record['CASH_Payment']);
//           return totalPayments > 0;
//         }).toList();
//         break;
//       case 'Refund Only':
//         filtered = filtered.where((record) {
//           double totalRefunds = _parseDouble(record['Cloud_Refund']) +
//               _parseDouble(record['Paytm_Refund']) +
//               _parseDouble(record['Phonepe_Refund']) +
//               _parseDouble(record['Card_Refund']);
//           return totalRefunds > 0;
//         }).toList();
//         break;
//       case 'Mismatched':
//         filtered = filtered.where((record) {
//           double cloudTotal = _parseDouble(record['Cloud_Payment']) +
//               _parseDouble(record['Cloud_Refund']);
//           double gatewayTotal = _parseDouble(record['Paytm_Payment']) +
//               _parseDouble(record['Phonepe_Payment']) +
//               _parseDouble(record['Card_Payment']) +
//               _parseDouble(record['CASH_Payment']) -
//               _parseDouble(record['Paytm_Refund']) -
//               _parseDouble(record['Phonepe_Refund']) -
//               _parseDouble(record['Card_Refund']);
//           return (cloudTotal - gatewayTotal).abs() >= 0.01;
//         }).toList();
//         break;
//       case 'Perfect Match':
//         filtered = filtered.where((record) {
//           double cloudTotal = _parseDouble(record['Cloud_Payment']) +
//               _parseDouble(record['Cloud_Refund']);
//           double gatewayTotal = _parseDouble(record['Paytm_Payment']) +
//               _parseDouble(record['Phonepe_Payment']) +
//               _parseDouble(record['Card_Payment']) +
//               _parseDouble(record['CASH_Payment']) -
//               _parseDouble(record['Paytm_Refund']) -
//               _parseDouble(record['Phonepe_Refund']) -
//               _parseDouble(record['Card_Refund']);
//           return (cloudTotal - gatewayTotal).abs() < 0.01;
//         }).toList();
//         break;
//     }

//     setState(() {
//       _filteredData = filtered;
//       _currentPage = 0; // Reset to first page when filtering
//     });
//   }

//   // Get current page data
//   List<dynamic> _getCurrentPageData() {
//     int startIndex = _currentPage * _rowsPerPage;
//     int endIndex = (startIndex + _rowsPerPage).clamp(0, _filteredData.length);
//     return _filteredData.sublist(startIndex, endIndex);
//   }

//   // Get total pages
//   int _getTotalPages() {
//     return (_filteredData.length / _rowsPerPage).ceil();
//   }

//   // Format currency
//   String _formatCurrency(dynamic value) {
//     double amount = _parseDouble(value);
//     return '₹${amount.toStringAsFixed(2)}';
//   }

//   // Get row color based on match status
//   Color? _getRowColor(Map<String, dynamic> record) {
//     double cloudTotal = _parseDouble(record['Cloud_Payment']) +
//         _parseDouble(record['Cloud_Refund']);
//     double gatewayTotal = _parseDouble(record['Paytm_Payment']) +
//         _parseDouble(record['Phonepe_Payment']) +
//         _parseDouble(record['Card_Payment']) +
//         _parseDouble(record['CASH_Payment']) -
//         _parseDouble(record['Paytm_Refund']) -
//         _parseDouble(record['Phonepe_Refund']) -
//         _parseDouble(record['Card_Refund']);

//     if ((cloudTotal - gatewayTotal).abs() < 0.01) {
//       return AppTheme.sage.withOpacity(0.1); // Perfect match
//     } else if ((cloudTotal - gatewayTotal).abs() > 10) {
//       return Colors.red.withOpacity(0.1); // Major mismatch
//     } else {
//       return AppTheme.golden.withOpacity(0.1); // Minor mismatch
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: AppTheme.theme,
//       child: Scaffold(
//         backgroundColor: AppTheme.cream,
//         appBar: AppBar(
//           title: const Text('Reconciliation Data'),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh_rounded),
//               onPressed: _isLoading ? null : _loadReconData,
//               tooltip: 'Refresh Data',
//             ),
//           ],
//         ),
//         body: FadeTransition(
//           opacity: _fadeAnimation,
//           child: SlideTransition(
//             position: _slideAnimation,
//             child: Column(
//               children: [
//                 // Statistics Panel
//                 if (_statistics.isNotEmpty) _buildStatisticsPanel(),

//                 // Search and Filter Panel
//                 _buildSearchFilterPanel(),

//                 // Data Table
//                 Expanded(
//                   child: _isLoading
//                       ? Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(20),
//                                 decoration: BoxDecoration(
//                                   color: AppTheme.sage.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: const CircularProgressIndicator(
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                       AppTheme.sage),
//                                 ),
//                               ),
//                               const SizedBox(height: 16),
//                               const Text(
//                                 'Loading reconciliation data...',
//                                 style: TextStyle(
//                                   color: AppTheme.sage,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       : _filteredData.isEmpty
//                           ? _buildEmptyState()
//                           : _buildDataTable(),
//                 ),

//                 // Status bar
//                 _buildStatusBar(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatisticsPanel() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.white,
//             AppTheme.cream.withOpacity(0.8),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.darkGreen.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [AppTheme.sage, AppTheme.darkGreen],
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(
//                     Icons.analytics_rounded,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 const Text(
//                   'Statistics Overview',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                     color: AppTheme.darkGreen,
//                     letterSpacing: -0.5,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             Wrap(
//               spacing: 16,
//               runSpacing: 16,
//               children: [
//                 _buildStatCard(
//                   'Total Transactions',
//                   _statistics['totalTransactions'].toString(),
//                   Icons.receipt_long_rounded,
//                   AppTheme.sage,
//                 ),
//                 _buildStatCard(
//                   'Cloud Amount',
//                   _formatCurrency(_statistics['totalCloudAmount']),
//                   Icons.cloud_rounded,
//                   AppTheme.golden,
//                 ),
//                 _buildStatCard(
//                   'Gateway Amount',
//                   _formatCurrency(_statistics['totalGatewayAmount']),
//                   Icons.payment_rounded,
//                   AppTheme.bronze,
//                 ),
//                 _buildStatCard(
//                   'Perfect Matches',
//                   '${_statistics['perfectMatches']}',
//                   Icons.check_circle_rounded,
//                   Colors.green,
//                 ),
//                 _buildStatCard(
//                   'Mismatches',
//                   '${_statistics['mismatches']}',
//                   Icons.error_rounded,
//                   Colors.red,
//                 ),
//                 _buildStatCard(
//                   'Match Rate',
//                   '${_statistics['matchPercentage'].toStringAsFixed(1)}%',
//                   Icons.trending_up_rounded,
//                   AppTheme.darkGreen,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard(
//       String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             color.withOpacity(0.1),
//             color.withOpacity(0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 12,
//               color: AppTheme.sage,
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchFilterPanel() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.white,
//             AppTheme.sage.withOpacity(0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppTheme.sage.withOpacity(0.2)),
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.sage.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Search field
//           Expanded(
//             flex: 2,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppTheme.sage.withOpacity(0.3)),
//               ),
//               child: TextField(
//                 decoration: const InputDecoration(
//                   hintText: 'Search by Txn RefNo, Machine, or MID...',
//                   hintStyle: TextStyle(color: AppTheme.sage),
//                   prefixIcon: Icon(Icons.search_rounded, color: AppTheme.sage),
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.all(16),
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     _searchQuery = value;
//                   });
//                   _applyFilters();
//                 },
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),

//           // Filter dropdown
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppTheme.sage.withOpacity(0.3)),
//               ),
//               child: DropdownButtonFormField<String>(
//                 value: _selectedFilter,
//                 decoration: const InputDecoration(
//                   labelText: 'Filter',
//                   labelStyle: TextStyle(color: AppTheme.sage),
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.all(16),
//                 ),
//                 dropdownColor: Colors.white,
//                 items: _filterOptions.map((filter) {
//                   return DropdownMenuItem(
//                     value: filter,
//                     child: Text(
//                       filter,
//                       style: const TextStyle(color: AppTheme.darkGreen),
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedFilter = value!;
//                   });
//                   _applyFilters();
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.all(32),
//         padding: const EdgeInsets.all(32),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Colors.white,
//               AppTheme.cream.withOpacity(0.5),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: AppTheme.sage.withOpacity(0.2)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: AppTheme.sage.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Icon(
//                 Icons.search_off_rounded,
//                 size: 64,
//                 color: AppTheme.sage,
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'No data matches your criteria',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: AppTheme.darkGreen,
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               'Try adjusting your search or filter settings',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: AppTheme.sage,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDataTable() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.darkGreen.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Table header with record count and pagination
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppTheme.sage.withOpacity(0.1),
//                   AppTheme.sage.withOpacity(0.05),
//                 ],
//               ),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(20),
//                 topRight: Radius.circular(20),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Showing ${_getCurrentPageData().length} of ${_filteredData.length} records',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: AppTheme.darkGreen,
//                     fontSize: 16,
//                   ),
//                 ),
//                 if (_getTotalPages() > 1)
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: AppTheme.sage.withOpacity(0.3)),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           onPressed: _currentPage > 0
//                               ? () => setState(() => _currentPage--)
//                               : null,
//                           icon: const Icon(Icons.chevron_left_rounded),
//                           color: AppTheme.sage,
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           child: Text(
//                             '${_currentPage + 1} / ${_getTotalPages()}',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w500,
//                               color: AppTheme.darkGreen,
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: _currentPage < _getTotalPages() - 1
//                               ? () => setState(() => _currentPage++)
//                               : null,
//                           icon: const Icon(Icons.chevron_right_rounded),
//                           color: AppTheme.sage,
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           // Data table
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: SingleChildScrollView(
//                 child: Theme(
//                   data: Theme.of(context).copyWith(
//                     dataTableTheme: DataTableThemeData(
//                       headingRowColor: MaterialStateProperty.all(
//                         AppTheme.sage.withOpacity(0.1),
//                       ),
//                       headingTextStyle: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: AppTheme.darkGreen,
//                         fontSize: 14,
//                       ),
//                       dataTextStyle: const TextStyle(
//                         color: AppTheme.darkGreen,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ),
//                   child: DataTable(
//                     columnSpacing: 24,
//                     horizontalMargin: 20,
//                     columns: const [
//                       DataColumn(label: Text('Txn Source')),
//                       DataColumn(label: Text('Txn Type')),
//                       DataColumn(label: Text('Txn RefNo')),
//                       DataColumn(label: Text('Machine')),
//                       DataColumn(label: Text('MID')),
//                       DataColumn(label: Text('Date')),
//                       DataColumn(label: Text('Cloud Payment')),
//                       DataColumn(label: Text('Cloud Refund')),
//                       DataColumn(label: Text('Paytm Payment')),
//                       DataColumn(label: Text('Paytm Refund')),
//                       DataColumn(label: Text('PhonePe Payment')),
//                       DataColumn(label: Text('PhonePe Refund')),
//                       DataColumn(label: Text('Card Payment')),
//                       DataColumn(label: Text('Card Refund')),
//                       DataColumn(label: Text('Cash Payment')),
//                       DataColumn(label: Text('Status')),
//                     ],
//                     rows: _getCurrentPageData().map<DataRow>((item) {
//                       // Calculate match status
//                       double cloudTotal = _parseDouble(item['Cloud_Payment']) +
//                           _parseDouble(item['Cloud_Refund']);
//                       double gatewayTotal =
//                           _parseDouble(item['Paytm_Payment']) +
//                               _parseDouble(item['Phonepe_Payment']) +
//                               _parseDouble(item['Card_Payment']) +
//                               _parseDouble(item['CASH_Payment']) -
//                               _parseDouble(item['Paytm_Refund']) -
//                               _parseDouble(item['Phonepe_Refund']) -
//                               _parseDouble(item['Card_Refund']);

//                       String status;
//                       Color statusColor;
//                       if ((cloudTotal - gatewayTotal).abs() < 0.01) {
//                         status = 'Match';
//                         statusColor = AppTheme.sage;
//                       } else {
//                         status = 'Mismatch';
//                         statusColor = Colors.red;
//                       }

//                       return DataRow(
//                         color: MaterialStateProperty.all(_getRowColor(item)),
//                         cells: [
//                           DataCell(Text(item['Txn_Source']?.toString() ?? '')),
//                           DataCell(Text(item['Txn_Type']?.toString() ?? '')),
//                           DataCell(Text(item['Txn_RefNo']?.toString() ?? '')),
//                           DataCell(Text(item['Txn_Machine']?.toString() ?? '')),
//                           DataCell(Text(item['Txn_MID']?.toString() ?? '')),
//                           DataCell(Text(
//                               item['Txn_Date']?.toString().split('T')[0] ??
//                                   '')),
//                           DataCell(
//                               Text(_formatCurrency(item['Cloud_Payment']))),
//                           DataCell(Text(_formatCurrency(item['Cloud_Refund']))),
//                           DataCell(
//                               Text(_formatCurrency(item['Paytm_Payment']))),
//                           DataCell(Text(_formatCurrency(item['Paytm_Refund']))),
//                           DataCell(
//                               Text(_formatCurrency(item['Phonepe_Payment']))),
//                           DataCell(
//                               Text(_formatCurrency(item['Phonepe_Refund']))),
//                           DataCell(Text(_formatCurrency(item['Card_Payment']))),
//                           DataCell(Text(_formatCurrency(item['Card_Refund']))),
//                           DataCell(Text(_formatCurrency(item['CASH_Payment']))),
//                           DataCell(
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 6),
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     statusColor.withOpacity(0.2),
//                                     statusColor.withOpacity(0.1),
//                                   ],
//                                 ),
//                                 borderRadius: BorderRadius.circular(16),
//                                 border: Border.all(
//                                   color: statusColor.withOpacity(0.3),
//                                 ),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     status == 'Match'
//                                         ? Icons.check_circle_rounded
//                                         : Icons.error_rounded,
//                                     color: statusColor,
//                                     size: 14,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     status,
//                                     style: TextStyle(
//                                       color: statusColor,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBar() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.sage.withOpacity(0.1),
//             AppTheme.sage.withOpacity(0.05),
//           ],
//         ),
//         border: Border(
//           top: BorderSide(color: AppTheme.sage.withOpacity(0.2)),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppTheme.sage.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               _isLoading ? Icons.sync_rounded : Icons.info_rounded,
//               color: AppTheme.sage,
//               size: 16,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               _statusMessage,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: AppTheme.darkGreen,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           if (_isLoading)
//             const SizedBox(
//               width: 16,
//               height: 16,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(AppTheme.sage),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

//2

// import 'package:flutter/material.dart';
// import 'database_service.dart';

// class DataScreen extends StatefulWidget {
//   const DataScreen({super.key});

//   @override
//   State<DataScreen> createState() => _DataScreenState();
// }

// class _DataScreenState extends State<DataScreen> {
//   bool _isLoading = false;
//   List<dynamic> _reconData = [];
//   List<dynamic> _filteredData = [];
//   String _statusMessage = '';
//   String _searchQuery = '';
//   String _selectedFilter = 'All';
//   int _currentPage = 0;
//   final int _rowsPerPage = 20;

//   // Filter options
//   final List<String> _filterOptions = [
//     'All',
//     'Payment Only',
//     'Refund Only',
//     'Mismatched',
//     'Perfect Match'
//   ];

//   // Statistics
//   Map<String, dynamic> _statistics = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadReconData();
//   }

//   // Load reconciliation data from database
//   Future<void> _loadReconData() async {
//     setState(() {
//       _isLoading = true;
//       _statusMessage = 'Loading reconciliation data...';
//     });

//     try {
//       final response = await DatabaseService.getReconSummary();
//       if (response['status'] == 'success') {
//         setState(() {
//           _reconData = response['data'] ?? [];
//           _filteredData = List.from(_reconData);
//           _statusMessage =
//               'Data loaded successfully (${_reconData.length} records)';
//         });
//         _calculateStatistics();
//         _applyFilters();
//       } else {
//         setState(() {
//           _statusMessage = 'Failed to load data: ${response['error']}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Error loading data: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Calculate statistics from the data
//   void _calculateStatistics() {
//     if (_reconData.isEmpty) return;

//     int totalTransactions = _reconData.length;
//     double totalCloudAmount = 0;
//     double totalGatewayAmount = 0;
//     int perfectMatches = 0;
//     int mismatches = 0;

//     for (var record in _reconData) {
//       // Calculate cloud total
//       double cloudPayment = _parseDouble(record['Cloud_Payment']);
//       double cloudRefund = _parseDouble(record['Cloud_Refund']);
//       double cloudMRefund = _parseDouble(record['Cloud_MRefund']);
//       double cloudTotal = cloudPayment + cloudRefund + cloudMRefund;
//       totalCloudAmount += cloudTotal;

//       // Calculate gateway total
//       double gatewayTotal = _parseDouble(record['Paytm_Payment']) +
//           _parseDouble(record['Phonepe_Payment']) +
//           _parseDouble(record['VMSMoney_Payment']) +
//           _parseDouble(record['Card_Payment']) +
//           _parseDouble(record['Sodexo_Payment']) +
//           _parseDouble(record['HDFC_Payment']) +
//           _parseDouble(record['CASH_Payment']) -
//           _parseDouble(record['Paytm_Refund']) -
//           _parseDouble(record['Phonepe_Refund']) -
//           _parseDouble(record['VMSMoney_Refund']) -
//           _parseDouble(record['Card_Refund']) -
//           _parseDouble(record['Sodexo_Refund']) -
//           _parseDouble(record['HDFC_Refund']);

//       totalGatewayAmount += gatewayTotal;

//       // Check for perfect match
//       if ((cloudTotal - gatewayTotal).abs() < 0.01) {
//         perfectMatches++;
//       } else {
//         mismatches++;
//       }
//     }

//     setState(() {
//       _statistics = {
//         'totalTransactions': totalTransactions,
//         'totalCloudAmount': totalCloudAmount,
//         'totalGatewayAmount': totalGatewayAmount,
//         'perfectMatches': perfectMatches,
//         'mismatches': mismatches,
//         'matchPercentage': totalTransactions > 0
//             ? (perfectMatches / totalTransactions * 100)
//             : 0,
//         'amountDifference': totalCloudAmount - totalGatewayAmount,
//       };
//     });
//   }

//   // Parse double values safely
//   double _parseDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) {
//       return double.tryParse(value) ?? 0.0;
//     }
//     return 0.0;
//   }

//   // Apply search and filter
//   void _applyFilters() {
//     List<dynamic> filtered = List.from(_reconData);

//     // Apply search filter
//     if (_searchQuery.isNotEmpty) {
//       filtered = filtered.where((record) {
//         return record['Txn_RefNo']
//                     ?.toString()
//                     .toLowerCase()
//                     .contains(_searchQuery.toLowerCase()) ==
//                 true ||
//             record['Txn_Machine']
//                     ?.toString()
//                     .toLowerCase()
//                     .contains(_searchQuery.toLowerCase()) ==
//                 true ||
//             record['Txn_MID']
//                     ?.toString()
//                     .toLowerCase()
//                     .contains(_searchQuery.toLowerCase()) ==
//                 true;
//       }).toList();
//     }

//     // Apply category filter
//     switch (_selectedFilter) {
//       case 'Payment Only':
//         filtered = filtered.where((record) {
//           double totalPayments = _parseDouble(record['Cloud_Payment']) +
//               _parseDouble(record['Paytm_Payment']) +
//               _parseDouble(record['Phonepe_Payment']) +
//               _parseDouble(record['Card_Payment']) +
//               _parseDouble(record['CASH_Payment']);
//           return totalPayments > 0;
//         }).toList();
//         break;
//       case 'Refund Only':
//         filtered = filtered.where((record) {
//           double totalRefunds = _parseDouble(record['Cloud_Refund']) +
//               _parseDouble(record['Paytm_Refund']) +
//               _parseDouble(record['Phonepe_Refund']) +
//               _parseDouble(record['Card_Refund']);
//           return totalRefunds > 0;
//         }).toList();
//         break;
//       case 'Mismatched':
//         filtered = filtered.where((record) {
//           double cloudTotal = _parseDouble(record['Cloud_Payment']) +
//               _parseDouble(record['Cloud_Refund']) +
//               _parseDouble(record['Cloud_MRefund']);
//           double gatewayTotal = _parseDouble(record['Paytm_Payment']) +
//               _parseDouble(record['Phonepe_Payment']) +
//               _parseDouble(record['VMSMoney_Payment']) +
//               _parseDouble(record['Card_Payment']) +
//               _parseDouble(record['Sodexo_Payment']) +
//               _parseDouble(record['HDFC_Payment']) +
//               _parseDouble(record['CASH_Payment']) -
//               _parseDouble(record['Paytm_Refund']) -
//               _parseDouble(record['Phonepe_Refund']) -
//               _parseDouble(record['VMSMoney_Refund']) -
//               _parseDouble(record['Card_Refund']) -
//               _parseDouble(record['Sodexo_Refund']) -
//               _parseDouble(record['HDFC_Refund']);
//           return (cloudTotal - gatewayTotal).abs() >= 0.01;
//         }).toList();
//         break;
//       case 'Perfect Match':
//         filtered = filtered.where((record) {
//           double cloudTotal = _parseDouble(record['Cloud_Payment']) +
//               _parseDouble(record['Cloud_Refund']) +
//               _parseDouble(record['Cloud_MRefund']);
//           double gatewayTotal = _parseDouble(record['Paytm_Payment']) +
//               _parseDouble(record['Phonepe_Payment']) +
//               _parseDouble(record['VMSMoney_Payment']) +
//               _parseDouble(record['Card_Payment']) +
//               _parseDouble(record['Sodexo_Payment']) +
//               _parseDouble(record['HDFC_Payment']) +
//               _parseDouble(record['CASH_Payment']) -
//               _parseDouble(record['Paytm_Refund']) -
//               _parseDouble(record['Phonepe_Refund']) -
//               _parseDouble(record['VMSMoney_Refund']) -
//               _parseDouble(record['Card_Refund']) -
//               _parseDouble(record['Sodexo_Refund']) -
//               _parseDouble(record['HDFC_Refund']);
//           return (cloudTotal - gatewayTotal).abs() < 0.01;
//         }).toList();
//         break;
//     }

//     setState(() {
//       _filteredData = filtered;
//       _currentPage = 0; // Reset to first page when filtering
//     });
//   }

//   // Get current page data
//   List<dynamic> _getCurrentPageData() {
//     int startIndex = _currentPage * _rowsPerPage;
//     int endIndex = (startIndex + _rowsPerPage).clamp(0, _filteredData.length);
//     return _filteredData.sublist(startIndex, endIndex);
//   }

//   // Get total pages
//   int _getTotalPages() {
//     return (_filteredData.length / _rowsPerPage).ceil();
//   }

//   // Format currency
//   String _formatCurrency(dynamic value) {
//     double amount = _parseDouble(value);
//     return '₹${amount.toStringAsFixed(2)}';
//   }

//   // Get row color based on match status
//   Color? _getRowColor(Map<String, dynamic> record) {
//     double cloudTotal = _parseDouble(record['Cloud_Payment']) +
//         _parseDouble(record['Cloud_Refund']) +
//         _parseDouble(record['Cloud_MRefund']);
//     double gatewayTotal = _parseDouble(record['Paytm_Payment']) +
//         _parseDouble(record['Phonepe_Payment']) +
//         _parseDouble(record['VMSMoney_Payment']) +
//         _parseDouble(record['Card_Payment']) +
//         _parseDouble(record['Sodexo_Payment']) +
//         _parseDouble(record['HDFC_Payment']) +
//         _parseDouble(record['CASH_Payment']) -
//         _parseDouble(record['Paytm_Refund']) -
//         _parseDouble(record['Phonepe_Refund']) -
//         _parseDouble(record['VMSMoney_Refund']) -
//         _parseDouble(record['Card_Refund']) -
//         _parseDouble(record['Sodexo_Refund']) -
//         _parseDouble(record['HDFC_Refund']);

//     if ((cloudTotal - gatewayTotal).abs() < 0.01) {
//       return Colors.green.withOpacity(0.1); // Perfect match
//     } else if ((cloudTotal - gatewayTotal).abs() > 10) {
//       return Colors.red.withOpacity(0.1); // Major mismatch
//     } else {
//       return Colors.orange.withOpacity(0.1); // Minor mismatch
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Reconciliation Data'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _isLoading ? null : _loadReconData,
//             tooltip: 'Refresh Data',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Statistics Panel
//           if (_statistics.isNotEmpty)
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               color: Colors.blue.withOpacity(0.1),
//               child: Wrap(
//                 spacing: 20,
//                 runSpacing: 10,
//                 children: [
//                   _buildStatCard(
//                       'Total Transactions',
//                       _statistics['totalTransactions'].toString(),
//                       Icons.receipt),
//                   _buildStatCard(
//                       'Cloud Amount',
//                       _formatCurrency(_statistics['totalCloudAmount']),
//                       Icons.cloud),
//                   _buildStatCard(
//                       'Gateway Amount',
//                       _formatCurrency(_statistics['totalGatewayAmount']),
//                       Icons.payment),
//                   _buildStatCard('Perfect Matches',
//                       '${_statistics['perfectMatches']}', Icons.check_circle),
//                   _buildStatCard('Mismatches', '${_statistics['mismatches']}',
//                       Icons.error),
//                   _buildStatCard(
//                       'Match Rate',
//                       '${_statistics['matchPercentage'].toStringAsFixed(1)}%',
//                       Icons.analytics),
//                 ],
//               ),
//             ),

//           // Search and Filter Panel
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 // Search field
//                 Expanded(
//                   flex: 2,
//                   child: TextField(
//                     decoration: const InputDecoration(
//                       hintText: 'Search by Txn RefNo, Machine, or MID...',
//                       prefixIcon: Icon(Icons.search),
//                       border: OutlineInputBorder(),
//                       isDense: true,
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         _searchQuery = value;
//                       });
//                       _applyFilters();
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 16),

//                 // Filter dropdown
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: _selectedFilter,
//                     decoration: const InputDecoration(
//                       labelText: 'Filter',
//                       border: OutlineInputBorder(),
//                       isDense: true,
//                     ),
//                     items: _filterOptions.map((filter) {
//                       return DropdownMenuItem(
//                         value: filter,
//                         child: Text(filter),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedFilter = value!;
//                       });
//                       _applyFilters();
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Data Table
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _filteredData.isEmpty
//                     ? const Center(
//                         child: Text(
//                           'No data matches your criteria.',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       )
//                     : Card(
//                         margin: const EdgeInsets.all(16),
//                         child: Column(
//                           children: [
//                             // Table header with record count
//                             Container(
//                               padding: const EdgeInsets.all(16),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'Showing ${_getCurrentPageData().length} of ${_filteredData.length} records',
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   if (_getTotalPages() > 1)
//                                     Row(
//                                       children: [
//                                         IconButton(
//                                           onPressed: _currentPage > 0
//                                               ? () =>
//                                                   setState(() => _currentPage--)
//                                               : null,
//                                           icon: const Icon(Icons.chevron_left),
//                                         ),
//                                         Text(
//                                             '${_currentPage + 1} / ${_getTotalPages()}'),
//                                         IconButton(
//                                           onPressed: _currentPage <
//                                                   _getTotalPages() - 1
//                                               ? () =>
//                                                   setState(() => _currentPage++)
//                                               : null,
//                                           icon: const Icon(Icons.chevron_right),
//                                         ),
//                                       ],
//                                     ),
//                                 ],
//                               ),
//                             ),

//                             // Data table
//                             Expanded(
//                               child: SingleChildScrollView(
//                                 scrollDirection: Axis.horizontal,
//                                 child: SingleChildScrollView(
//                                   child: DataTable(
//                                     columnSpacing: 20,
//                                     columns: const [
//                                       DataColumn(
//                                           label: Text('Txn Source',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('Txn Type',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('Txn RefNo',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('Machine',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('MID',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('Date',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('Cloud Payment',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('Cloud Refund',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('Cloud MRefund',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('Paytm Payment',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('Paytm Refund',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('PhonePe Payment',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('PhonePe Refund',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('VMSMoney Payment',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('VMSMoney Refund',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('Card Payment',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('Card Refund',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('Sodexo Payment',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('Sodexo Refund',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('HDFC Payment',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('HDFC Refund',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('Cash Payment',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                       DataColumn(
//                                           label: Text('Status',
//                                               style: TextStyle(
//                                                   fontWeight:
//                                                       FontWeight.bold))),
//                                     ],
//                                     rows: _getCurrentPageData()
//                                         .map<DataRow>((item) {
//                                       // Calculate match status
//                                       double cloudTotal = _parseDouble(
//                                               item['Cloud_Payment']) +
//                                           _parseDouble(item['Cloud_Refund']) +
//                                           _parseDouble(item['Cloud_MRefund']);
//                                       double gatewayTotal = _parseDouble(
//                                               item['Paytm_Payment']) +
//                                           _parseDouble(
//                                               item['Phonepe_Payment']) +
//                                           _parseDouble(
//                                               item['VMSMoney_Payment']) +
//                                           _parseDouble(item['Card_Payment']) +
//                                           _parseDouble(item['Sodexo_Payment']) +
//                                           _parseDouble(item['HDFC_Payment']) +
//                                           _parseDouble(item['CASH_Payment']) -
//                                           _parseDouble(item['Paytm_Refund']) -
//                                           _parseDouble(item['Phonepe_Refund']) -
//                                           _parseDouble(
//                                               item['VMSMoney_Refund']) -
//                                           _parseDouble(item['Card_Refund']) -
//                                           _parseDouble(item['Sodexo_Refund']) -
//                                           _parseDouble(item['HDFC_Refund']);

//                                       String status;
//                                       Color statusColor;
//                                       if ((cloudTotal - gatewayTotal).abs() <
//                                           0.01) {
//                                         status = 'Match';
//                                         statusColor = Colors.green;
//                                       } else {
//                                         status = 'Mismatch';
//                                         statusColor = Colors.red;
//                                       }

//                                       return DataRow(
//                                         color: MaterialStateProperty.all(
//                                             _getRowColor(item)),
//                                         cells: [
//                                           DataCell(Text(
//                                               item['Txn_Source']?.toString() ??
//                                                   '')),
//                                           DataCell(Text(
//                                               item['Txn_Type']?.toString() ??
//                                                   '')),
//                                           DataCell(Text(
//                                               item['Txn_RefNo']?.toString() ??
//                                                   '')),
//                                           DataCell(Text(
//                                               item['Txn_Machine']?.toString() ??
//                                                   '')),
//                                           DataCell(Text(
//                                               item['Txn_MID']?.toString() ??
//                                                   '')),
//                                           DataCell(Text(item['Txn_Date']
//                                                   ?.toString()
//                                                   .split('T')[0] ??
//                                               '')),
//                                           DataCell(Text(_formatCurrency(
//                                               item['Cloud_Payment']))),
//                                           DataCell(Text(_formatCurrency(
//                                               item['Cloud_Refund']))),
//                                           DataCell(Text(_formatCurrency(
//                                               item['Cloud_MRefund']))),
//                                           DataCell(Text(_formatCurrency(
//                                               item['Paytm_Payment']))),
//                                           DataCell(Text(_formatCurrency(
//                                               item['Paytm_Refund']))),
//                                           DataCell(Text(_formatCurrency(
//                                               item['Phonepe_Payment']))),
//                                           DataCell(Text(_formatCurrency(
//                                               item['Phonepe_Refund']))),
//                                           DataCell(Text(_formatCurrency(
//                                               item['VMSMoney_Payment']))),
//                                           DataCell(Text(_formatCurrency(
//                                               item['VMSMoney_Refund']))),
//                                           DataCell(Text(_formatCurrency(
//                                               item['Card_Payment']))),
//                                           DataCell(Text(_formatCurrency(
//                                               item['Card_Refund']))),
//                                           DataCell(Text(_formatCurrency(
//                                               item['Sodexo_Payment']))),
//                                           DataCell(Text(_formatCurrency(
//                                               item['Sodexo_Refund']))),
//                                           DataCell(Text(_formatCurrency(
//                                               item['HDFC_Payment']))),
//                                           DataCell(Text(_formatCurrency(
//                                               item['HDFC_Refund']))),
//                                           DataCell(Text(_formatCurrency(
//                                               item['CASH_Payment']))),
//                                           DataCell(
//                                             Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 8,
//                                                       vertical: 4),
//                                               decoration: BoxDecoration(
//                                                 color: statusColor
//                                                     .withOpacity(0.2),
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                               ),
//                                               child: Text(
//                                                 status,
//                                                 style: TextStyle(
//                                                   color: statusColor,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 12,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       );
//                                     }).toList(),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//           ),

//           // Status bar
//           Container(
//             padding: const EdgeInsets.all(8),
//             color: Colors.grey[200],
//             child: Text(
//               _statusMessage,
//               style: const TextStyle(fontSize: 12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String title, String value, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 3,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: Colors.blue, size: 24),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.grey,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }

//3

import 'package:flutter/material.dart';
import 'database_service.dart';
import 'filter_component.dart';

// Custom Theme Data (matching reference)
class AppTheme {
  static const Color sage = Color(0xFF606C38); // Primary green
  static const Color darkGreen = Color(0xFF283618); // Dark accent
  static const Color cream = Color(0xFFFEFAE0); // Light background
  static const Color golden = Color(0xFFDDA15E); // Secondary accent
  static const Color bronze = Color(0xFFBC6C25); // Primary action
  static const Color accent = Color(0xFFDDA15E); // Accent color

  static ThemeData get theme => ThemeData(
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: darkGreen,
          titleTextStyle: TextStyle(
            color: darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
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
      );
}

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  List<dynamic> _reconData = [];
  List<dynamic> _filteredData = [];
  String _statusMessage = '';
  String _searchQuery = '';
  String _selectedFilter = 'All';
  int _currentPage = 0;
  final int _rowsPerPage = 20;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  FilterResults? _currentFilterResults;
  bool _isFilterInitialized = false;

  // Filter options
  final List<String> _filterOptions = [
    'All',
    'Payment Only',
    'Refund Only',
    'Mismatched',
    'Perfect Match'
  ];

  // Statistics
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadReconData();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleFilterChanged(FilterResults results) {
    if (mounted) {
      setState(() {
        _filteredData = results.filteredData;
        _currentFilterResults = results;
        _currentPage = 0; // Reset pagination
        _isFilterInitialized = true;
      });
    }
  }

  // Load reconciliation data from database
  Future<void> _loadReconData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading reconciliation data...';
    });

    try {
      final response = await DatabaseService.getReconSummary();
      if (response['status'] == 'success') {
        setState(() {
          _reconData = response['data'] ?? [];
          _filteredData = List.from(_reconData);
          _statusMessage =
              'Data loaded successfully (${_reconData.length} records)';
        });
        _calculateStatistics();
        _applyFilters();
      } else {
        setState(() {
          _statusMessage = 'Failed to load data: ${response['error']}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Calculate statistics from the data
  void _calculateStatistics() {
    if (_reconData.isEmpty) return;

    int totalTransactions = _reconData.length;
    double totalCloudAmount = 0;
    double totalGatewayAmount = 0;
    int perfectMatches = 0;
    int mismatches = 0;

    for (var record in _reconData) {
      // Calculate cloud total (including MRefund)
      double cloudPayment = _parseDouble(record['Cloud_Payment']);
      double cloudRefund = _parseDouble(record['Cloud_Refund']);
      double cloudMRefund = _parseDouble(record['Cloud_MRefund']);
      double cloudTotal = cloudPayment + cloudRefund + cloudMRefund;
      totalCloudAmount += cloudTotal;

      // Calculate gateway total
      double gatewayTotal = _parseDouble(record['Paytm_Payment']) +
          _parseDouble(record['Phonepe_Payment']) +
          _parseDouble(record['VMSMoney_Payment']) +
          _parseDouble(record['Card_Payment']) +
          _parseDouble(record['Sodexo_Payment']) +
          _parseDouble(record['HDFC_Payment']) +
          _parseDouble(record['CASH_Payment']) -
          _parseDouble(record['Paytm_Refund']) -
          _parseDouble(record['Phonepe_Refund']) -
          _parseDouble(record['VMSMoney_Refund']) -
          _parseDouble(record['Card_Refund']) -
          _parseDouble(record['Sodexo_Refund']) -
          _parseDouble(record['HDFC_Refund']);

      totalGatewayAmount += gatewayTotal;

      // Check for perfect match
      if ((cloudTotal - gatewayTotal).abs() < 0.01) {
        perfectMatches++;
      } else {
        mismatches++;
      }
    }

    setState(() {
      _statistics = {
        'totalTransactions': totalTransactions,
        'totalCloudAmount': totalCloudAmount,
        'totalGatewayAmount': totalGatewayAmount,
        'perfectMatches': perfectMatches,
        'mismatches': mismatches,
        'matchPercentage': totalTransactions > 0
            ? (perfectMatches / totalTransactions * 100)
            : 0,
        'amountDifference': totalCloudAmount - totalGatewayAmount,
      };
    });
  }

  // Parse double values safely
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Apply search and filter
  void _applyFilters() {
    List<dynamic> filtered = List.from(_reconData);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((record) {
        return record['Txn_RefNo']
                    ?.toString()
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ==
                true ||
            record['Txn_Machine']
                    ?.toString()
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ==
                true ||
            record['Txn_MID']
                    ?.toString()
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ==
                true;
      }).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'Payment Only':
        filtered = filtered.where((record) {
          double totalPayments = _parseDouble(record['Cloud_Payment']) +
              _parseDouble(record['Paytm_Payment']) +
              _parseDouble(record['Phonepe_Payment']) +
              _parseDouble(record['VMSMoney_Payment']) +
              _parseDouble(record['Card_Payment']) +
              _parseDouble(record['Sodexo_Payment']) +
              _parseDouble(record['HDFC_Payment']) +
              _parseDouble(record['CASH_Payment']);
          return totalPayments > 0;
        }).toList();
        break;
      case 'Refund Only':
        filtered = filtered.where((record) {
          double totalRefunds = _parseDouble(record['Cloud_Refund']) +
              _parseDouble(record['Cloud_MRefund']) +
              _parseDouble(record['Paytm_Refund']) +
              _parseDouble(record['Phonepe_Refund']) +
              _parseDouble(record['VMSMoney_Refund']) +
              _parseDouble(record['Card_Refund']) +
              _parseDouble(record['Sodexo_Refund']) +
              _parseDouble(record['HDFC_Refund']);
          return totalRefunds > 0;
        }).toList();
        break;
      case 'Mismatched':
        filtered = filtered.where((record) {
          double cloudTotal = _parseDouble(record['Cloud_Payment']) +
              _parseDouble(record['Cloud_Refund']) +
              _parseDouble(record['Cloud_MRefund']);
          double gatewayTotal = _parseDouble(record['Paytm_Payment']) +
              _parseDouble(record['Phonepe_Payment']) +
              _parseDouble(record['VMSMoney_Payment']) +
              _parseDouble(record['Card_Payment']) +
              _parseDouble(record['Sodexo_Payment']) +
              _parseDouble(record['HDFC_Payment']) +
              _parseDouble(record['CASH_Payment']) -
              _parseDouble(record['Paytm_Refund']) -
              _parseDouble(record['Phonepe_Refund']) -
              _parseDouble(record['VMSMoney_Refund']) -
              _parseDouble(record['Card_Refund']) -
              _parseDouble(record['Sodexo_Refund']) -
              _parseDouble(record['HDFC_Refund']);
          return (cloudTotal - gatewayTotal).abs() >= 0.01;
        }).toList();
        break;
      case 'Perfect Match':
        filtered = filtered.where((record) {
          double cloudTotal = _parseDouble(record['Cloud_Payment']) +
              _parseDouble(record['Cloud_Refund']) +
              _parseDouble(record['Cloud_MRefund']);
          double gatewayTotal = _parseDouble(record['Paytm_Payment']) +
              _parseDouble(record['Phonepe_Payment']) +
              _parseDouble(record['VMSMoney_Payment']) +
              _parseDouble(record['Card_Payment']) +
              _parseDouble(record['Sodexo_Payment']) +
              _parseDouble(record['HDFC_Payment']) +
              _parseDouble(record['CASH_Payment']) -
              _parseDouble(record['Paytm_Refund']) -
              _parseDouble(record['Phonepe_Refund']) -
              _parseDouble(record['VMSMoney_Refund']) -
              _parseDouble(record['Card_Refund']) -
              _parseDouble(record['Sodexo_Refund']) -
              _parseDouble(record['HDFC_Refund']);
          return (cloudTotal - gatewayTotal).abs() < 0.01;
        }).toList();
        break;
    }

    setState(() {
      _filteredData = filtered;
      _currentPage = 0; // Reset to first page when filtering
    });
  }

  // Get current page data
  List<dynamic> _getCurrentPageData() {
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = (startIndex + _rowsPerPage).clamp(0, _filteredData.length);
    return _filteredData.sublist(startIndex, endIndex);
  }

  // Get total pages
  int _getTotalPages() {
    return (_filteredData.length / _rowsPerPage).ceil();
  }

  // Format currency
  String _formatCurrency(dynamic value) {
    double amount = _parseDouble(value);
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Get row color based on match status
  Color? _getRowColor(Map<String, dynamic> record) {
    double cloudTotal = _parseDouble(record['Cloud_Payment']) +
        _parseDouble(record['Cloud_Refund']) +
        _parseDouble(record['Cloud_MRefund']);
    double gatewayTotal = _parseDouble(record['Paytm_Payment']) +
        _parseDouble(record['Phonepe_Payment']) +
        _parseDouble(record['VMSMoney_Payment']) +
        _parseDouble(record['Card_Payment']) +
        _parseDouble(record['Sodexo_Payment']) +
        _parseDouble(record['HDFC_Payment']) +
        _parseDouble(record['CASH_Payment']) -
        _parseDouble(record['Paytm_Refund']) -
        _parseDouble(record['Phonepe_Refund']) -
        _parseDouble(record['VMSMoney_Refund']) -
        _parseDouble(record['Card_Refund']) -
        _parseDouble(record['Sodexo_Refund']) -
        _parseDouble(record['HDFC_Refund']);

    if ((cloudTotal - gatewayTotal).abs() < 0.01) {
      return AppTheme.sage.withOpacity(0.1); // Perfect match
    } else if ((cloudTotal - gatewayTotal).abs() > 10) {
      return Colors.red.withOpacity(0.1); // Major mismatch
    } else {
      return AppTheme.golden.withOpacity(0.1); // Minor mismatch
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.theme,
      child: Scaffold(
        backgroundColor: AppTheme.cream,
        appBar: AppBar(
          title: const Text('Reconciliation Data'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _isLoading ? null : _loadReconData,
              tooltip: 'Refresh Data',
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Statistics Panel (existing)
                if (_statistics.isNotEmpty) _buildStatisticsPanel(),

                // Advanced Filter Component (NEW)
                if (_reconData.isNotEmpty)
                  FilterComponent(
                    originalData: _reconData,
                    onFilterChanged: _handleFilterChanged,
                  ),

                // Filter Results Display (NEW)
                if (_currentFilterResults != null && _isFilterInitialized)
                  FilterResultsDisplay(results: _currentFilterResults!),

                // Data Table (existing)
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.sage.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.sage),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Loading reconciliation data...',
                                style: TextStyle(
                                  color: AppTheme.sage,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : (_filteredData.isEmpty && _isFilterInitialized)
                          ? _buildEmptyState()
                          : _reconData.isNotEmpty && !_isFilterInitialized
                              ? Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    child: const Text(
                                      'Initializing filters...',
                                      style: TextStyle(
                                        color: AppTheme.sage,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                              : _buildDataTable(),
                ),

                // Status bar (existing)
                _buildStatusBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.cream.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGreen.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.sage, AppTheme.darkGreen],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Statistics Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGreen,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard(
                  'Total Transactions',
                  _statistics['totalTransactions'].toString(),
                  Icons.receipt_long_rounded,
                  AppTheme.sage,
                ),
                _buildStatCard(
                  'Cloud Amount',
                  _formatCurrency(_statistics['totalCloudAmount']),
                  Icons.cloud_rounded,
                  AppTheme.golden,
                ),
                _buildStatCard(
                  'Gateway Amount',
                  _formatCurrency(_statistics['totalGatewayAmount']),
                  Icons.payment_rounded,
                  AppTheme.bronze,
                ),
                _buildStatCard(
                  'Perfect Matches',
                  '${_statistics['perfectMatches']}',
                  Icons.check_circle_rounded,
                  Colors.green,
                ),
                _buildStatCard(
                  'Mismatches',
                  '${_statistics['mismatches']}',
                  Icons.error_rounded,
                  Colors.red,
                ),
                _buildStatCard(
                  'Match Rate',
                  '${_statistics['matchPercentage'].toStringAsFixed(1)}%',
                  Icons.trending_up_rounded,
                  AppTheme.darkGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.sage,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            AppTheme.sage.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.sage.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.sage.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search field
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.sage.withOpacity(0.3)),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by Txn RefNo, Machine, or MID...',
                  hintStyle: TextStyle(color: AppTheme.sage),
                  prefixIcon: Icon(Icons.search_rounded, color: AppTheme.sage),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _applyFilters();
                },
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Filter dropdown
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.sage.withOpacity(0.3)),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedFilter,
                decoration: const InputDecoration(
                  labelText: 'Filter',
                  labelStyle: TextStyle(color: AppTheme.sage),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                dropdownColor: Colors.white,
                items: _filterOptions.map((filter) {
                  return DropdownMenuItem(
                    value: filter,
                    child: Text(
                      filter,
                      style: const TextStyle(color: AppTheme.darkGreen),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  _applyFilters();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppTheme.cream.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.sage.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.sage.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppTheme.sage,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No data matches your criteria',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGreen,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Try adjusting your search or filter settings',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.sage,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGreen.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table header with record count and pagination
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.sage.withOpacity(0.1),
                  AppTheme.sage.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${_getCurrentPageData().length} of ${_filteredData.length} records',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGreen,
                    fontSize: 16,
                  ),
                ),
                if (_getTotalPages() > 1)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.sage.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                          icon: const Icon(Icons.chevron_left_rounded),
                          color: AppTheme.sage,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${_currentPage + 1} / ${_getTotalPages()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.darkGreen,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _currentPage < _getTotalPages() - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                          icon: const Icon(Icons.chevron_right_rounded),
                          color: AppTheme.sage,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Data table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dataTableTheme: DataTableThemeData(
                      headingRowColor: MaterialStateProperty.all(
                        AppTheme.sage.withOpacity(0.1),
                      ),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGreen,
                        fontSize: 14,
                      ),
                      dataTextStyle: const TextStyle(
                        color: AppTheme.darkGreen,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  child: DataTable(
                    columnSpacing: 24,
                    horizontalMargin: 20,
                    columns: const [
                      DataColumn(label: Text('Txn Source')),
                      DataColumn(label: Text('Txn Type')),
                      DataColumn(label: Text('Txn RefNo')),
                      DataColumn(label: Text('Machine')),
                      DataColumn(label: Text('MID')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Cloud Payment')),
                      DataColumn(label: Text('Cloud Refund')),
                      DataColumn(label: Text('Cloud MRefund')),
                      DataColumn(label: Text('Paytm Payment')),
                      DataColumn(label: Text('Paytm Refund')),
                      DataColumn(label: Text('PhonePe Payment')),
                      DataColumn(label: Text('PhonePe Refund')),
                      DataColumn(label: Text('VMSMoney Payment')),
                      DataColumn(label: Text('VMSMoney Refund')),
                      DataColumn(label: Text('Card Payment')),
                      DataColumn(label: Text('Card Refund')),
                      DataColumn(label: Text('Sodexo Payment')),
                      DataColumn(label: Text('Sodexo Refund')),
                      DataColumn(label: Text('HDFC Payment')),
                      DataColumn(label: Text('HDFC Refund')),
                      DataColumn(label: Text('Cash Payment')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: _getCurrentPageData().map<DataRow>((item) {
                      // Calculate match status
                      double cloudTotal = _parseDouble(item['Cloud_Payment']) +
                          _parseDouble(item['Cloud_Refund']) +
                          _parseDouble(item['Cloud_MRefund']);
                      double gatewayTotal =
                          _parseDouble(item['Paytm_Payment']) +
                              _parseDouble(item['Phonepe_Payment']) +
                              _parseDouble(item['VMSMoney_Payment']) +
                              _parseDouble(item['Card_Payment']) +
                              _parseDouble(item['Sodexo_Payment']) +
                              _parseDouble(item['HDFC_Payment']) +
                              _parseDouble(item['CASH_Payment']) -
                              _parseDouble(item['Paytm_Refund']) -
                              _parseDouble(item['Phonepe_Refund']) -
                              _parseDouble(item['VMSMoney_Refund']) -
                              _parseDouble(item['Card_Refund']) -
                              _parseDouble(item['Sodexo_Refund']) -
                              _parseDouble(item['HDFC_Refund']);

                      String status;
                      Color statusColor;
                      if ((cloudTotal - gatewayTotal).abs() < 0.01) {
                        status = 'Match';
                        statusColor = AppTheme.sage;
                      } else {
                        status = 'Mismatch';
                        statusColor = Colors.red;
                      }

                      return DataRow(
                        color: MaterialStateProperty.all(_getRowColor(item)),
                        cells: [
                          DataCell(Text(item['Txn_Source']?.toString() ?? '')),
                          DataCell(Text(item['Txn_Type']?.toString() ?? '')),
                          DataCell(Text(item['Txn_RefNo']?.toString() ?? '')),
                          DataCell(Text(item['Txn_Machine']?.toString() ?? '')),
                          DataCell(Text(item['Txn_MID']?.toString() ?? '')),
                          DataCell(Text(
                              item['Txn_Date']?.toString().split('T')[0] ??
                                  '')),
                          DataCell(
                              Text(_formatCurrency(item['Cloud_Payment']))),
                          DataCell(Text(_formatCurrency(item['Cloud_Refund']))),
                          DataCell(
                              Text(_formatCurrency(item['Cloud_MRefund']))),
                          DataCell(
                              Text(_formatCurrency(item['Paytm_Payment']))),
                          DataCell(Text(_formatCurrency(item['Paytm_Refund']))),
                          DataCell(
                              Text(_formatCurrency(item['Phonepe_Payment']))),
                          DataCell(
                              Text(_formatCurrency(item['Phonepe_Refund']))),
                          DataCell(
                              Text(_formatCurrency(item['VMSMoney_Payment']))),
                          DataCell(
                              Text(_formatCurrency(item['VMSMoney_Refund']))),
                          DataCell(Text(_formatCurrency(item['Card_Payment']))),
                          DataCell(Text(_formatCurrency(item['Card_Refund']))),
                          DataCell(
                              Text(_formatCurrency(item['Sodexo_Payment']))),
                          DataCell(
                              Text(_formatCurrency(item['Sodexo_Refund']))),
                          DataCell(Text(_formatCurrency(item['HDFC_Payment']))),
                          DataCell(Text(_formatCurrency(item['HDFC_Refund']))),
                          DataCell(Text(_formatCurrency(item['CASH_Payment']))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    statusColor.withOpacity(0.2),
                                    statusColor.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    status == 'Match'
                                        ? Icons.check_circle_rounded
                                        : Icons.error_rounded,
                                    color: statusColor,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.sage.withOpacity(0.1),
            AppTheme.sage.withOpacity(0.05),
          ],
        ),
        border: Border(
          top: BorderSide(color: AppTheme.sage.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.sage.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isLoading ? Icons.sync_rounded : Icons.info_rounded,
              color: AppTheme.sage,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.darkGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.sage),
              ),
            ),
        ],
      ),
    );
  }
}
