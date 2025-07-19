// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:data_table_2/data_table_2.dart';
// import 'package:intl/intl.dart';
// import 'ReconProvider.dart';

// class DataScreen extends StatefulWidget {
//   @override
//   _DataScreenState createState() => _DataScreenState();
// }

// class _DataScreenState extends State<DataScreen>
//     with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
//   late TabController _tabController;
//   late AnimationController _filterAnimationController;
//   late Animation<double> _filterAnimation;

//   // Search and filter controllers
//   final Map<String, TextEditingController> _searchControllers = {};
//   final Map<String, TextEditingController> _minAmountControllers = {};
//   final Map<String, TextEditingController> _maxAmountControllers = {};
//   final Map<String, TextEditingController> _remarksControllers = {};
//   final Map<String, String> _selectedTransactionModes = {};
//   final Map<String, String> _selectedQuickStatuses = {};
//   final Map<String, bool> _isFilterExpanded = {};

//   // Pagination
//   final Map<String, int> _currentPage = {};
//   final int _itemsPerPage = 50;

//   // Active filters tracking
//   final Map<String, List<String>> _activeFilters = {};

//   final List<SheetConfig> _sheets = [
//     SheetConfig('SUMMARY', 'Summary', Icons.dashboard_outlined,
//         'Transaction summary overview', Colors.blue),
//     SheetConfig('RECON_SUCCESS', 'Perfect Matches', Icons.check_circle_outline,
//         'Successfully reconciled transactions', Colors.green),
//     SheetConfig('RECON_INVESTIGATE', 'Investigate', Icons.warning_outlined,
//         'Transactions requiring investigation', Colors.orange),
//     SheetConfig('MANUAL_REFUND', 'Manual Refunds', Icons.edit_outlined,
//         'Manual refund transactions', Colors.purple),
//     SheetConfig('RAWDATA', 'Raw Data', Icons.table_rows_outlined,
//         'All raw transaction data', Colors.grey),
//   ];

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _sheets.length, vsync: this);
//     _filterAnimationController = AnimationController(
//       duration: Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _filterAnimation = CurvedAnimation(
//       parent: _filterAnimationController,
//       curve: Curves.easeInOut,
//     );

//     // Initialize controllers
//     for (var sheet in _sheets) {
//       _searchControllers[sheet.id] = TextEditingController();
//       _minAmountControllers[sheet.id] = TextEditingController();
//       _maxAmountControllers[sheet.id] = TextEditingController();
//       _remarksControllers[sheet.id] = TextEditingController();
//       _selectedTransactionModes[sheet.id] = 'All';
//       _selectedQuickStatuses[sheet.id] = 'All';
//       _isFilterExpanded[sheet.id] = false;
//       _currentPage[sheet.id] = 0;
//       _activeFilters[sheet.id] = [];
//     }

//     // Load initial data
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ReconProvider>(context, listen: false).loadAllSheets();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _filterAnimationController.dispose();
//     _searchControllers.values.forEach((controller) => controller.dispose());
//     _minAmountControllers.values.forEach((controller) => controller.dispose());
//     _maxAmountControllers.values.forEach((controller) => controller.dispose());
//     _remarksControllers.values.forEach((controller) => controller.dispose());
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         return Scaffold(
//           backgroundColor: Colors.grey[50],
//           appBar: _buildAppBar(provider),
//           body: Column(
//             children: [
//               if (provider.error != null) _buildErrorBanner(provider),
//               if (provider.isLoading) _buildLoadingIndicator(),
//               _buildTabBar(),
//               Expanded(child: _buildTabBarView(provider)),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   PreferredSizeWidget _buildAppBar(ReconProvider provider) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black87,
//       title: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.blue[100],
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(Icons.analytics_outlined, color: Colors.blue[700]),
//           ),
//           SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Reconciliation Dashboard',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//               Text('Real-time transaction analysis',
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//             ],
//           ),
//         ],
//       ),
//       // actions: [
//       //   _buildStatsChips(provider),
//       //   SizedBox(width: 16),
//       //   Container(
//       //     margin: EdgeInsets.symmetric(vertical: 8),
//       //     child: ElevatedButton.icon(
//       //       onPressed:
//       //           provider.isLoading ? null : () => provider.loadAllSheets(),
//       //       icon: Icon(Icons.refresh, size: 18),
//       //       label: Text('Refresh'),
//       //       style: ElevatedButton.styleFrom(
//       //         backgroundColor: Colors.blue[600],
//       //         foregroundColor: Colors.white,
//       //         elevation: 0,
//       //         shape: RoundedRectangleBorder(
//       //           borderRadius: BorderRadius.circular(8),
//       //         ),
//       //       ),
//       //     ),
//       //   ),
//       //   SizedBox(width: 16),
//       // ],
//     );
//   }

//   // Widget _buildStatsChips(ReconProvider provider) {
//   //   return Row(
//   //     children: [
//   //       _buildStatChip('Total Records', _getTotalRecords(provider).toString(),
//   //           Colors.blue),
//   //       SizedBox(width: 8),
//   //       _buildStatChip(
//   //           'Success Rate', '${_getSuccessRate(provider)}%', Colors.green),
//   //     ],
//   //   );
//   // }

//   Widget _buildStatChip(String label, String value, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(value,
//               style: TextStyle(
//                   fontSize: 14, fontWeight: FontWeight.bold, color: color)),
//           Text(label, style: TextStyle(fontSize: 10, color: color)),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorBanner(ReconProvider provider) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(16),
//       color: Colors.red[50],
//       child: Row(
//         children: [
//           Icon(Icons.error_outline, color: Colors.red[700]),
//           SizedBox(width: 12),
//           Expanded(
//             child:
//                 Text(provider.error!, style: TextStyle(color: Colors.red[700])),
//           ),
//           TextButton.icon(
//             onPressed: () => provider.clearError(),
//             icon: Icon(Icons.close, size: 18),
//             label: Text('Dismiss'),
//             style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingIndicator() {
//     return Container(
//       height: 4,
//       child: LinearProgressIndicator(
//         backgroundColor: Colors.grey[200],
//         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
//       ),
//     );
//   }

//   Widget _buildTabBar() {
//     return Container(
//       color: Colors.white,
//       child: TabBar(
//         controller: _tabController,
//         isScrollable: true,
//         labelColor: Colors.blue[700],
//         unselectedLabelColor: Colors.grey[600],
//         indicatorColor: Colors.blue[600],
//         indicatorWeight: 3,
//         labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//         unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
//         tabs: _sheets
//             .map((sheet) => Tab(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(sheet.icon, size: 20, color: sheet.color),
//                         SizedBox(width: 8),
//                         Text(sheet.name),
//                         SizedBox(width: 8),
//                         _buildRecordCountBadge(sheet),
//                       ],
//                     ),
//                   ),
//                 ))
//             .toList(),
//       ),
//     );
//   }

//   Widget _buildRecordCountBadge(SheetConfig sheet) {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final data = provider.getSheetData(sheet.id);
//         final count = data?.length ?? 0;

//         if (count == 0) return SizedBox.shrink();

//         return Container(
//           padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//           decoration: BoxDecoration(
//             color: sheet.color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             count.toString(),
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//               color: sheet.color,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTabBarView(ReconProvider provider) {
//     return TabBarView(
//       controller: _tabController,
//       children:
//           _sheets.map((sheet) => _buildSheetView(provider, sheet)).toList(),
//     );
//   }

//   Widget _buildSheetView(ReconProvider provider, SheetConfig sheet) {
//     final data = provider.getSheetData(sheet.id);

//     return Container(
//       margin: EdgeInsets.all(16),
//       child: Column(
//         children: [
//           _buildSheetHeader(sheet, data?.length ?? 0),
//           SizedBox(height: 16),
//           _buildFilterPanel(sheet),
//           SizedBox(height: 16),
//           _buildActiveFiltersChips(sheet),
//           SizedBox(height: 16),
//           Expanded(child: _buildDataContent(provider, sheet, data)),
//         ],
//       ),
//     );
//   }

//   Widget _buildSheetHeader(SheetConfig sheet, int recordCount) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: sheet.color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(sheet.icon, color: sheet.color, size: 24),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(sheet.name,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey[800],
//                       )),
//                   SizedBox(height: 4),
//                   Text(sheet.description,
//                       style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//                 ],
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: sheet.color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 '$recordCount Records',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: sheet.color,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterPanel(SheetConfig sheet) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Column(
//         children: [
//           // Filter header
//           InkWell(
//             onTap: () => _toggleFilterExpansion(sheet.id),
//             child: Container(
//               padding: EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Icon(Icons.filter_alt_outlined, color: Colors.grey[600]),
//                   SizedBox(width: 8),
//                   Text('Filters & Search',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[800],
//                       )),
//                   Spacer(),
//                   AnimatedRotation(
//                     turns: _isFilterExpanded[sheet.id]! ? 0.5 : 0,
//                     duration: Duration(milliseconds: 300),
//                     child: Icon(Icons.expand_more, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Expandable filter content
//           AnimatedContainer(
//             duration: Duration(milliseconds: 300),
//             height: _isFilterExpanded[sheet.id]! ? null : 0,
//             child: _isFilterExpanded[sheet.id]!
//                 ? _buildFilterContent(sheet)
//                 : SizedBox.shrink(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterContent(SheetConfig sheet) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Main search bar
//           Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.grey[50],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey[300]!),
//             ),
//             child: TextField(
//               controller: _searchControllers[sheet.id],
//               decoration: InputDecoration(
//                 hintText: 'Search in ${sheet.name.toLowerCase()}...',
//                 prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
//                 suffixIcon: _searchControllers[sheet.id]!.text.isNotEmpty
//                     ? IconButton(
//                         icon: Icon(Icons.clear, color: Colors.grey[600]),
//                         onPressed: () => _clearSearch(sheet.id),
//                       )
//                     : null,
//                 border: InputBorder.none,
//                 contentPadding:
//                     EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               ),
//               onChanged: (value) => _onSearchChanged(sheet.id, value),
//             ),
//           ),

//           SizedBox(height: 16),

//           // Filter section with proper layout
//           LayoutBuilder(
//             builder: (context, constraints) {
//               // Calculate responsive layout based on available width
//               final isWideScreen = constraints.maxWidth > 800;
//               final isTablet = constraints.maxWidth > 600;

//               if (isWideScreen) {
//                 return _buildWideScreenFilters(sheet);
//               } else if (isTablet) {
//                 return _buildTabletFilters(sheet);
//               } else {
//                 return _buildMobileFilters(sheet);
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWideScreenFilters(SheetConfig sheet) {
//     return Column(
//       children: [
//         // First row: Amount range and Transaction mode
//         Row(
//           children: [
//             Expanded(flex: 2, child: _buildAmountRangeFilter(sheet)),
//             SizedBox(width: 12),
//             Expanded(flex: 1, child: _buildTransactionModeFilter(sheet)),
//             SizedBox(width: 12),
//             Expanded(flex: 1, child: _buildQuickStatusFilter(sheet)),
//           ],
//         ),
//         SizedBox(height: 12),
//         // Second row: Remarks and Clear button
//         Row(
//           children: [
//             Expanded(flex: 2, child: _buildRemarksFilter(sheet)),
//             SizedBox(width: 12),
//             Expanded(flex: 1, child: _buildClearAllButton(sheet)),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildTabletFilters(SheetConfig sheet) {
//     return Column(
//       children: [
//         // First row: Amount range
//         _buildAmountRangeFilter(sheet),
//         SizedBox(height: 12),
//         // Second row: Transaction mode and Quick status
//         Row(
//           children: [
//             Expanded(child: _buildTransactionModeFilter(sheet)),
//             SizedBox(width: 12),
//             Expanded(child: _buildQuickStatusFilter(sheet)),
//           ],
//         ),
//         SizedBox(height: 12),
//         // Third row: Remarks and Clear button
//         Row(
//           children: [
//             Expanded(flex: 2, child: _buildRemarksFilter(sheet)),
//             SizedBox(width: 12),
//             Expanded(flex: 1, child: _buildClearAllButton(sheet)),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildMobileFilters(SheetConfig sheet) {
//     return Column(
//       children: [
//         _buildAmountRangeFilter(sheet),
//         SizedBox(height: 12),
//         _buildTransactionModeFilter(sheet),
//         SizedBox(height: 12),
//         _buildQuickStatusFilter(sheet),
//         SizedBox(height: 12),
//         _buildRemarksFilter(sheet),
//         SizedBox(height: 12),
//         _buildClearAllButton(sheet),
//       ],
//     );
//   }

//   Widget _buildAmountRangeFilter(SheetConfig sheet) {
//     return Container(
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               height: 48,
//               child: TextField(
//                 controller: _minAmountControllers[sheet.id],
//                 decoration: InputDecoration(
//                   labelText: 'Min Amount',
//                   prefixText: '₹',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   isDense: true,
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => _onFilterChanged(sheet.id),
//               ),
//             ),
//           ),
//           SizedBox(width: 8),
//           Expanded(
//             child: Container(
//               height: 48,
//               child: TextField(
//                 controller: _maxAmountControllers[sheet.id],
//                 decoration: InputDecoration(
//                   labelText: 'Max Amount',
//                   prefixText: '₹',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   isDense: true,
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => _onFilterChanged(sheet.id),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransactionModeFilter(SheetConfig sheet) {
//     final modes = ['All', 'Paytm', 'PhonePe', 'Cloud', 'PTPP', 'Manual'];

//     return Container(
//       height: 48,
//       child: DropdownButtonFormField<String>(
//         value: _selectedTransactionModes[sheet.id],
//         decoration: InputDecoration(
//           labelText: 'Transaction Mode',
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//           contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           isDense: true,
//         ),
//         items: modes
//             .map((mode) => DropdownMenuItem(
//                   value: mode,
//                   child: Text(mode, style: TextStyle(fontSize: 14)),
//                 ))
//             .toList(),
//         onChanged: (value) {
//           setState(() {
//             _selectedTransactionModes[sheet.id] = value!;
//           });
//           _onFilterChanged(sheet.id);
//         },
//         isExpanded: true,
//       ),
//     );
//   }

//   Widget _buildRemarksFilter(SheetConfig sheet) {
//     return Container(
//       height: 48,
//       child: TextField(
//         controller: _remarksControllers[sheet.id],
//         decoration: InputDecoration(
//           labelText: 'Contains in Remarks',
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//           contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           isDense: true,
//         ),
//         onChanged: (value) => _onFilterChanged(sheet.id),
//       ),
//     );
//   }

//   Widget _buildQuickStatusFilter(SheetConfig sheet) {
//     final statuses = ['All', 'Perfect', 'Investigate', 'Manual'];

//     return Container(
//       height: 48,
//       child: DropdownButtonFormField<String>(
//         value: _selectedQuickStatuses[sheet.id],
//         decoration: InputDecoration(
//           labelText: 'Quick Status',
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//           contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           isDense: true,
//         ),
//         items: statuses
//             .map((status) => DropdownMenuItem(
//                   value: status,
//                   child: Text(status, style: TextStyle(fontSize: 14)),
//                 ))
//             .toList(),
//         onChanged: (value) {
//           setState(() {
//             _selectedQuickStatuses[sheet.id] = value!;
//           });
//           _onFilterChanged(sheet.id);
//         },
//         isExpanded: true,
//       ),
//     );
//   }

//   Widget _buildClearAllButton(SheetConfig sheet) {
//     return Container(
//       height: 48,
//       width: double.infinity,
//       child: ElevatedButton.icon(
//         onPressed: () => _clearAllFilters(sheet.id),
//         icon: Icon(Icons.clear_all, size: 18),
//         label: Text('Clear All'),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.grey[100],
//           foregroundColor: Colors.grey[700],
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActiveFiltersChips(SheetConfig sheet) {
//     final activeFilters = _activeFilters[sheet.id] ?? [];

//     if (activeFilters.isEmpty) return SizedBox.shrink();

//     return Container(
//       alignment: Alignment.centerLeft,
//       child: Wrap(
//         spacing: 8,
//         runSpacing: 8,
//         children: [
//           Text('Active Filters: ',
//               style: TextStyle(
//                   fontWeight: FontWeight.w600, color: Colors.grey[600])),
//           ...activeFilters.map((filter) => Chip(
//                 label: Text(filter, style: TextStyle(fontSize: 12)),
//                 backgroundColor: Colors.blue[50],
//                 deleteIcon: Icon(Icons.close, size: 16),
//                 onDeleted: () => _removeFilter(sheet.id, filter),
//                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               )),
//         ],
//       ),
//     );
//   }

//   Widget _buildDataContent(ReconProvider provider, SheetConfig sheet,
//       List<Map<String, dynamic>>? data) {
//     if (provider.isLoading) {
//       return _buildLoadingState(sheet);
//     }

//     if (data == null || data.isEmpty) {
//       return _buildEmptyState(sheet, provider);
//     }

//     final filteredData = _applyFilters(data, sheet.id);
//     final paginatedData = _getPaginatedData(filteredData, sheet.id);

//     if (filteredData.isEmpty) {
//       return _buildNoResultsState(sheet);
//     }

//     return Column(
//       children: [
//         if (filteredData.length > _itemsPerPage)
//           _buildPaginationInfo(sheet, filteredData.length),
//         Expanded(child: _buildDataTable(sheet, paginatedData)),
//         if (filteredData.length > _itemsPerPage)
//           _buildPaginationControls(sheet, filteredData.length),
//       ],
//     );
//   }

//   Widget _buildLoadingState(SheetConfig sheet) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(color: sheet.color),
//           SizedBox(height: 16),
//           Text('Loading ${sheet.name.toLowerCase()}...',
//               style: TextStyle(color: Colors.grey[600])),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(SheetConfig sheet, ReconProvider provider) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(50),
//             ),
//             child:
//                 Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
//           ),
//           SizedBox(height: 16),
//           Text('No data available',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//           SizedBox(height: 8),
//           Text('No records found for ${sheet.name}',
//               style: TextStyle(color: Colors.grey[600])),
//           SizedBox(height: 16),
//           ElevatedButton.icon(
//             onPressed: () => provider.loadSheet(sheet.id),
//             icon: Icon(Icons.refresh),
//             label: Text('Reload Data'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: sheet.color,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoResultsState(SheetConfig sheet) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.orange[50],
//               borderRadius: BorderRadius.circular(50),
//             ),
//             child: Icon(Icons.search_off, size: 48, color: Colors.orange[400]),
//           ),
//           SizedBox(height: 16),
//           Text('No results found',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//           SizedBox(height: 8),
//           Text('Try adjusting your filters or search criteria',
//               style: TextStyle(color: Colors.grey[600])),
//           SizedBox(height: 16),
//           TextButton.icon(
//             onPressed: () => _clearAllFilters(sheet.id),
//             icon: Icon(Icons.clear_all),
//             label: Text('Clear All Filters'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDataTable(SheetConfig sheet, List<Map<String, dynamic>> data) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: _buildDataTableForSheet(sheet, data),
//       ),
//     );
//   }

//   Widget _buildDataTableForSheet(
//       SheetConfig sheet, List<Map<String, dynamic>> data) {
//     switch (sheet.id) {
//       case 'SUMMARY':
//         return _buildSummaryTable(data);
//       case 'RAWDATA':
//         return _buildRawDataTable(data);
//       case 'RECON_SUCCESS':
//       case 'RECON_INVESTIGATE':
//       case 'MANUAL_REFUND':
//         return _buildReconTable(data, sheet);
//       default:
//         return _buildGenericTable(data);
//     }
//   }

//   Widget _buildSummaryTable(List<Map<String, dynamic>> data) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 12,
//       horizontalMargin: 12,
//       minWidth: 600,
//       headingRowHeight: 56,
//       dataRowHeight: 48,
//       headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
//       columns: [
//         DataColumn2(
//           label: Text('Source', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//       ],
//       rows: data
//           .map((row) => DataRow2(
//                 cells: [
//                   DataCell(
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(row['txn_source']?.toString() ?? ''),
//                     ),
//                   ),
//                   DataCell(Text(row['Txn_type']?.toString() ?? '')),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['sum(Txn_Amount)']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style: TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ],
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildRawDataTable(List<Map<String, dynamic>> data) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 8,
//       horizontalMargin: 8,
//       minWidth: 800,
//       headingRowHeight: 56,
//       dataRowHeight: 48,
//       headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
//       columns: [
//         DataColumn2(
//           label: Text('Ref No', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//         ),
//         DataColumn2(
//           label: Text('Source', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Machine', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//       ],
//       rows: data
//           .map((row) => DataRow2(
//                 cells: [
//                   DataCell(
//                     SelectableText(
//                       row['Txn_RefNo']?.toString() ?? '',
//                       style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
//                     ),
//                   ),
//                   DataCell(
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: _getSourceColor(row['Txn_Source']?.toString()),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         row['Txn_Source']?.toString() ?? '',
//                         style: TextStyle(fontSize: 11, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   DataCell(Text(row['Txn_Type']?.toString() ?? '',
//                       style: TextStyle(fontSize: 12))),
//                   DataCell(Text(row['Txn_Machine']?.toString() ?? '',
//                       style: TextStyle(fontSize: 12))),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(row['Txn_Amount']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ],
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildReconTable(List<Map<String, dynamic>> data, SheetConfig sheet) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 8,
//       horizontalMargin: 8,
//       minWidth: 1000,
//       headingRowHeight: 56,
//       dataRowHeight: 48,
//       headingRowColor: MaterialStateProperty.all(sheet.color.withOpacity(0.1)),
//       columns: [
//         DataColumn2(
//           label: Text('Ref No', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//         ),
//         DataColumn2(
//           label: Text('Machine', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label:
//               Text('PTPP Pay', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label:
//               Text('PTPP Ref', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label:
//               Text('Cloud Pay', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label:
//               Text('Cloud Ref', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//         ),
//       ],
//       rows: data
//           .map((row) => DataRow2(
//                 cells: [
//                   DataCell(
//                     SelectableText(
//                       row['Txn_RefNo']?.toString() ?? '',
//                       style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
//                     ),
//                   ),
//                   DataCell(Text(row['Txn_Machine']?.toString() ?? '',
//                       style: TextStyle(fontSize: 12))),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['PTPP_Payment']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['PTPP_Refund']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['Cloud_Payment']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['Cloud_Refund']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color:
//                             _getRemarksColor(row['Remarks']?.toString() ?? ''),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         row['Remarks']?.toString() ?? '',
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildGenericTable(List<Map<String, dynamic>> data) {
//     if (data.isEmpty) return Center(child: Text('No data available'));

//     final columns = data.first.keys.take(6).toList();

//     return DataTable2(
//       columnSpacing: 12,
//       horizontalMargin: 12,
//       minWidth: columns.length * 120.0,
//       headingRowHeight: 56,
//       dataRowHeight: 48,
//       headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
//       columns: columns
//           .map((column) => DataColumn2(
//                 label:
//                     Text(column, style: TextStyle(fontWeight: FontWeight.bold)),
//                 size: ColumnSize.M,
//               ))
//           .toList(),
//       rows: data
//           .map((row) => DataRow2(
//                 cells: columns
//                     .map((column) => DataCell(
//                           Text(
//                             _formatCellValue(row[column]),
//                             style: TextStyle(fontSize: 12),
//                           ),
//                         ))
//                     .toList(),
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildPaginationInfo(SheetConfig sheet, int totalItems) {
//     final currentPage = _currentPage[sheet.id] ?? 0;
//     final startIndex = currentPage * _itemsPerPage + 1;
//     final endIndex = ((currentPage + 1) * _itemsPerPage).clamp(0, totalItems);

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Showing $startIndex-$endIndex of $totalItems records',
//             style: TextStyle(color: Colors.grey[600], fontSize: 14),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: sheet.color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Text(
//               'Page ${currentPage + 1} of ${(totalItems / _itemsPerPage).ceil()}',
//               style: TextStyle(
//                 color: sheet.color,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaginationControls(SheetConfig sheet, int totalItems) {
//     final totalPages = (totalItems / _itemsPerPage).ceil();
//     final currentPage = _currentPage[sheet.id] ?? 0;

//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ElevatedButton.icon(
//             onPressed: currentPage > 0 ? () => _changePage(sheet.id, 0) : null,
//             icon: Icon(Icons.first_page, size: 18),
//             label: Text('First'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.grey[100],
//               foregroundColor: Colors.grey[700],
//               elevation: 0,
//             ),
//           ),
//           SizedBox(width: 8),
//           ElevatedButton.icon(
//             onPressed: currentPage > 0
//                 ? () => _changePage(sheet.id, currentPage - 1)
//                 : null,
//             icon: Icon(Icons.chevron_left, size: 18),
//             label: Text('Previous'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.grey[100],
//               foregroundColor: Colors.grey[700],
//               elevation: 0,
//             ),
//           ),
//           SizedBox(width: 16),
//           Text(
//             '${currentPage + 1} / $totalPages',
//             style: TextStyle(fontWeight: FontWeight.w600),
//           ),
//           SizedBox(width: 16),
//           ElevatedButton.icon(
//             onPressed: currentPage < totalPages - 1
//                 ? () => _changePage(sheet.id, currentPage + 1)
//                 : null,
//             icon: Icon(Icons.chevron_right, size: 18),
//             label: Text('Next'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: sheet.color,
//               foregroundColor: Colors.white,
//               elevation: 0,
//             ),
//           ),
//           SizedBox(width: 8),
//           ElevatedButton.icon(
//             onPressed: currentPage < totalPages - 1
//                 ? () => _changePage(sheet.id, totalPages - 1)
//                 : null,
//             icon: Icon(Icons.last_page, size: 18),
//             label: Text('Last'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: sheet.color,
//               foregroundColor: Colors.white,
//               elevation: 0,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper Methods
//   Color _getRemarksColor(String remarks) {
//     switch (remarks.toLowerCase()) {
//       case 'perfect':
//         return Colors.green[600]!;
//       case 'investigate':
//         return Colors.orange[600]!;
//       case 'manual':
//         return Colors.purple[600]!;
//       default:
//         return Colors.blue[600]!;
//     }
//   }

//   Color _getSourceColor(String? source) {
//     switch (source?.toLowerCase()) {
//       case 'paytm':
//         return Colors.blue[600]!;
//       case 'phonepe':
//         return Colors.purple[600]!;
//       case 'cloud':
//         return Colors.green[600]!;
//       case 'ptpp':
//         return Colors.orange[600]!;
//       default:
//         return Colors.grey[600]!;
//     }
//   }

//   String _formatCellValue(dynamic value) {
//     if (value == null) return '';
//     if (value is num && value > 1000) {
//       return NumberFormat('#,##0.00').format(value);
//     }
//     return value.toString();
//   }

//   int _getTotalRecords(ReconProvider provider) {
//     int total = 0;
//     for (String sheetId in [
//       'SUMMARY',
//       'RAWDATA',
//       'RECON_SUCCESS',
//       'RECON_INVESTIGATE',
//       'MANUAL_REFUND'
//     ]) {
//       final data = provider.getSheetData(sheetId);
//       if (data != null) total += data.length;
//     }
//     return total;
//   }

//   int _getSuccessRate(ReconProvider provider) {
//     final successData = provider.getSheetData('RECON_SUCCESS');
//     final investigateData = provider.getSheetData('RECON_INVESTIGATE');
//     final totalRecon =
//         (successData?.length ?? 0) + (investigateData?.length ?? 0);

//     if (totalRecon == 0) return 0;
//     return ((successData?.length ?? 0) * 100 / totalRecon).round();
//   }

//   List<Map<String, dynamic>> _applyFilters(
//       List<Map<String, dynamic>> data, String sheetId) {
//     final searchQuery = _searchControllers[sheetId]?.text.toLowerCase() ?? '';
//     final minAmount =
//         double.tryParse(_minAmountControllers[sheetId]?.text ?? '');
//     final maxAmount =
//         double.tryParse(_maxAmountControllers[sheetId]?.text ?? '');
//     final remarksFilter =
//         _remarksControllers[sheetId]?.text.toLowerCase() ?? '';
//     final modeFilter = _selectedTransactionModes[sheetId] ?? 'All';
//     final statusFilter = _selectedQuickStatuses[sheetId] ?? 'All';

//     return data.where((row) {
//       // Search filter
//       if (searchQuery.isNotEmpty) {
//         bool matchesSearch = row.values.any((value) =>
//             value?.toString().toLowerCase().contains(searchQuery) ?? false);
//         if (!matchesSearch) return false;
//       }

//       // Amount range filter
//       if (minAmount != null || maxAmount != null) {
//         final amount = _getAmountFromRow(row);
//         if (amount != null) {
//           if (minAmount != null && amount < minAmount) return false;
//           if (maxAmount != null && amount > maxAmount) return false;
//         }
//       }

//       // Remarks filter
//       if (remarksFilter.isNotEmpty) {
//         final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//         if (!remarks.contains(remarksFilter)) return false;
//       }

//       // Transaction mode filter
//       if (modeFilter != 'All') {
//         final source = row['Txn_Source']?.toString() ?? '';
//         if (!source.toLowerCase().contains(modeFilter.toLowerCase()))
//           return false;
//       }

//       // Quick status filter
//       if (statusFilter != 'All') {
//         final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//         if (!remarks.contains(statusFilter.toLowerCase())) return false;
//       }

//       return true;
//     }).toList();
//   }

//   double? _getAmountFromRow(Map<String, dynamic> row) {
//     // Try different amount field names
//     final amountFields = [
//       'Txn_Amount',
//       'PTPP_Payment',
//       'Cloud_Payment',
//       'sum(Txn_Amount)'
//     ];

//     for (String field in amountFields) {
//       if (row.containsKey(field)) {
//         return double.tryParse(row[field]?.toString() ?? '0');
//       }
//     }
//     return null;
//   }

//   List<Map<String, dynamic>> _getPaginatedData(
//       List<Map<String, dynamic>> data, String sheetId) {
//     final startIndex = (_currentPage[sheetId] ?? 0) * _itemsPerPage;
//     final endIndex = (startIndex + _itemsPerPage).clamp(0, data.length);
//     return data.sublist(startIndex, endIndex);
//   }

//   void _toggleFilterExpansion(String sheetId) {
//     setState(() {
//       _isFilterExpanded[sheetId] = !_isFilterExpanded[sheetId]!;
//     });

//     if (_isFilterExpanded[sheetId]!) {
//       _filterAnimationController.forward();
//     } else {
//       _filterAnimationController.reverse();
//     }
//   }

//   void _onSearchChanged(String sheetId, String value) {
//     setState(() {
//       _currentPage[sheetId] = 0;
//     });
//     _updateActiveFilters(sheetId);
//   }

//   void _onFilterChanged(String sheetId) {
//     setState(() {
//       _currentPage[sheetId] = 0;
//     });
//     _updateActiveFilters(sheetId);
//   }

//   void _updateActiveFilters(String sheetId) {
//     List<String> filters = [];

//     final searchQuery = _searchControllers[sheetId]?.text ?? '';
//     if (searchQuery.isNotEmpty) {
//       filters.add('Search: "$searchQuery"');
//     }

//     final minAmount = _minAmountControllers[sheetId]?.text ?? '';
//     final maxAmount = _maxAmountControllers[sheetId]?.text ?? '';
//     if (minAmount.isNotEmpty || maxAmount.isNotEmpty) {
//       filters.add('Amount: ₹$minAmount - ₹$maxAmount');
//     }

//     final remarks = _remarksControllers[sheetId]?.text ?? '';
//     if (remarks.isNotEmpty) {
//       filters.add('Remarks: "$remarks"');
//     }

//     final mode = _selectedTransactionModes[sheetId] ?? 'All';
//     if (mode != 'All') {
//       filters.add('Mode: $mode');
//     }

//     final status = _selectedQuickStatuses[sheetId] ?? 'All';
//     if (status != 'All') {
//       filters.add('Status: $status');
//     }

//     setState(() {
//       _activeFilters[sheetId] = filters;
//     });
//   }

//   void _removeFilter(String sheetId, String filter) {
//     if (filter.startsWith('Search:')) {
//       _searchControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Amount:')) {
//       _minAmountControllers[sheetId]?.clear();
//       _maxAmountControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Remarks:')) {
//       _remarksControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Mode:')) {
//       _selectedTransactionModes[sheetId] = 'All';
//     } else if (filter.startsWith('Status:')) {
//       _selectedQuickStatuses[sheetId] = 'All';
//     }

//     _onFilterChanged(sheetId);
//   }

//   void _clearSearch(String sheetId) {
//     setState(() {
//       _searchControllers[sheetId]?.clear();
//       _currentPage[sheetId] = 0;
//     });
//     _updateActiveFilters(sheetId);
//   }

//   void _clearAllFilters(String sheetId) {
//     setState(() {
//       _searchControllers[sheetId]?.clear();
//       _minAmountControllers[sheetId]?.clear();
//       _maxAmountControllers[sheetId]?.clear();
//       _remarksControllers[sheetId]?.clear();
//       _selectedTransactionModes[sheetId] = 'All';
//       _selectedQuickStatuses[sheetId] = 'All';
//       _currentPage[sheetId] = 0;
//       _activeFilters[sheetId] = [];
//     });
//   }

//   void _changePage(String sheetId, int newPage) {
//     setState(() {
//       _currentPage[sheetId] = newPage;
//     });
//   }
// }

// class SheetConfig {
//   final String id;
//   final String name;
//   final IconData icon;
//   final String description;
//   final Color color;

//   SheetConfig(this.id, this.name, this.icon, this.description, this.color);
// }

//2

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:data_table_2/data_table_2.dart';
// import 'package:intl/intl.dart';
// import 'ReconProvider.dart';

// class DataScreen extends StatefulWidget {
//   @override
//   _DataScreenState createState() => _DataScreenState();
// }

// class _DataScreenState extends State<DataScreen>
//     with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
//   late TabController _tabController;
//   late AnimationController _filterAnimationController;
//   late Animation<double> _filterAnimation;

//   // Search and filter controllers
//   final Map<String, TextEditingController> _searchControllers = {};
//   final Map<String, TextEditingController> _minAmountControllers = {};
//   final Map<String, TextEditingController> _maxAmountControllers = {};
//   final Map<String, TextEditingController> _remarksControllers = {};
//   final Map<String, String> _selectedTransactionModes = {};
//   final Map<String, String> _selectedQuickStatuses = {};
//   final Map<String, bool> _isFilterExpanded = {};

//   // Pagination
//   final Map<String, int> _currentPage = {};
//   final int _itemsPerPage = 100; // Increased for better performance

//   // Active filters tracking
//   final Map<String, List<String>> _activeFilters = {};

//   // Floating filter panel
//   bool _showFloatingFilter = false;
//   String _currentFilterSheet = '';

//   final List<SheetConfig> _sheets = [
//     SheetConfig('SUMMARY', 'Summary', Icons.dashboard_outlined,
//         'Summary overview', Colors.blue),
//     SheetConfig('RECON_SUCCESS', 'Perfect', Icons.check_circle_outline,
//         'Successfully reconciled', Colors.green),
//     SheetConfig('RECON_INVESTIGATE', 'Investigate', Icons.warning_outlined,
//         'Require investigation', Colors.orange),
//     SheetConfig('MANUAL_REFUND', 'Manual', Icons.edit_outlined,
//         'Manual refunds', Colors.purple),
//     SheetConfig('RAWDATA', 'Raw Data', Icons.table_rows_outlined,
//         'All raw data', Colors.grey),
//   ];

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize TabController FIRST with correct length
//     _tabController = TabController(length: _sheets.length, vsync: this);

//     _filterAnimationController = AnimationController(
//       duration: Duration(milliseconds: 250),
//       vsync: this,
//     );
//     _filterAnimation = CurvedAnimation(
//       parent: _filterAnimationController,
//       curve: Curves.easeInOut,
//     );

//     // Initialize controllers for each sheet
//     for (var sheet in _sheets) {
//       _searchControllers[sheet.id] = TextEditingController();
//       _minAmountControllers[sheet.id] = TextEditingController();
//       _maxAmountControllers[sheet.id] = TextEditingController();
//       _remarksControllers[sheet.id] = TextEditingController();
//       _selectedTransactionModes[sheet.id] = 'All';
//       _selectedQuickStatuses[sheet.id] = 'All';
//       _isFilterExpanded[sheet.id] = false;
//       _currentPage[sheet.id] = 0;
//       _activeFilters[sheet.id] = [];
//     }

//     // Load initial data
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ReconProvider>(context, listen: false).loadAllSheets();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _filterAnimationController.dispose();
//     _searchControllers.values.forEach((controller) => controller.dispose());
//     _minAmountControllers.values.forEach((controller) => controller.dispose());
//     _maxAmountControllers.values.forEach((controller) => controller.dispose());
//     _remarksControllers.values.forEach((controller) => controller.dispose());
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         return Scaffold(
//           backgroundColor: Colors.grey[50],
//           appBar: _buildCompactAppBar(provider),
//           body: Stack(
//             children: [
//               Column(
//                 children: [
//                   if (provider.error != null) _buildErrorBanner(provider),
//                   if (provider.isLoading) _buildLoadingIndicator(),
//                   _buildEnhancedTabBar(),
//                   Expanded(child: _buildTabBarView(provider)),
//                 ],
//               ),
//               // Floating Filter Panel
//               if (_showFloatingFilter) _buildFloatingFilterPanel(),
//             ],
//           ),
//           floatingActionButton: _buildFilterFAB(),
//           floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
//         );
//       },
//     );
//   }

//   PreferredSizeWidget _buildCompactAppBar(ReconProvider provider) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black87,
//       toolbarHeight: 60,
//       title: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: Colors.blue[100],
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Icon(Icons.analytics_outlined,
//                 color: Colors.blue[700], size: 20),
//           ),
//           SizedBox(width: 8),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Reconciliation Dashboard',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//               Text('Real-time analysis',
//                   style: TextStyle(fontSize: 11, color: Colors.grey[600])),
//             ],
//           ),
//         ],
//       ),
//       actions: [
//         _buildCompactStatsRow(provider),
//         SizedBox(width: 8),
//         IconButton(
//           onPressed: provider.isLoading ? null : () => provider.loadAllSheets(),
//           icon: Icon(Icons.refresh, size: 20),
//           tooltip: 'Refresh Data',
//         ),
//         SizedBox(width: 8),
//       ],
//     );
//   }

//   Widget _buildCompactStatsRow(ReconProvider provider) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _buildCompactStatChip(
//             'Records', _getTotalRecords(provider).toString(), Colors.blue),
//         SizedBox(width: 6),
//         _buildCompactStatChip(
//             'Success', '${_getSuccessRate(provider)}%', Colors.green),
//       ],
//     );
//   }

//   Widget _buildCompactStatChip(String label, String value, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3), width: 0.5),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(value,
//               style: TextStyle(
//                   fontSize: 12, fontWeight: FontWeight.bold, color: color)),
//           Text(label, style: TextStyle(fontSize: 9, color: color)),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorBanner(ReconProvider provider) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       color: Colors.red[50],
//       child: Row(
//         children: [
//           Icon(Icons.error_outline, color: Colors.red[700], size: 16),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(provider.error!,
//                 style: TextStyle(color: Colors.red[700], fontSize: 12)),
//           ),
//           IconButton(
//             onPressed: () => provider.clearError(),
//             icon: Icon(Icons.close, size: 16, color: Colors.red[700]),
//             padding: EdgeInsets.zero,
//             constraints: BoxConstraints(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingIndicator() {
//     return Container(
//       height: 2,
//       child: LinearProgressIndicator(
//         backgroundColor: Colors.grey[200],
//         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
//       ),
//     );
//   }

//   Widget _buildEnhancedTabBar() {
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.symmetric(horizontal: 8),
//       child: TabBar(
//         controller: _tabController,
//         isScrollable: true,
//         labelColor: Colors.blue[700] ?? Colors.blue,
//         unselectedLabelColor: Colors.grey[600] ?? Colors.grey,
//         indicatorColor: Colors.blue[600] ?? Colors.blue,
//         indicatorWeight: 2,
//         labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//         unselectedLabelStyle:
//             TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
//         onTap: (index) {
//           if (index < _sheets.length) {
//             _currentFilterSheet = _sheets[index].id;
//           }
//         },
//         tabs: _sheets
//             .map((sheet) => Tab(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(sheet.icon, size: 16, color: sheet.color),
//                         SizedBox(width: 6),
//                         Text(sheet.name),
//                         SizedBox(width: 6),
//                         _buildRecordCountBadge(sheet),
//                       ],
//                     ),
//                   ),
//                 ))
//             .toList(),
//       ),
//     );
//   }

//   Widget _buildRecordCountBadge(SheetConfig sheet) {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final data = provider.getSheetData(sheet.id);
//         final count = data?.length ?? 0;

//         if (count == 0) return SizedBox.shrink();

//         return Container(
//           padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//           decoration: BoxDecoration(
//             color: (sheet.color ?? Colors.grey).withOpacity(0.15),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             count > 999
//                 ? '${(count / 1000).toStringAsFixed(1)}k'
//                 : count.toString(),
//             style: TextStyle(
//               fontSize: 9,
//               fontWeight: FontWeight.bold,
//               color: sheet.color ?? Colors.grey,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTabBarView(ReconProvider provider) {
//     if (_tabController.length != _sheets.length) {
//       // Safety check: rebuild TabController if lengths don't match
//       _tabController.dispose();
//       _tabController = TabController(length: _sheets.length, vsync: this);
//     }

//     return TabBarView(
//       controller: _tabController,
//       children: _sheets
//           .map((sheet) => _buildOptimizedSheetView(provider, sheet))
//           .toList(),
//     );
//   }

//   Widget _buildOptimizedSheetView(ReconProvider provider, SheetConfig sheet) {
//     final data = provider.getSheetData(sheet.id);

//     return Padding(
//       padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
//       child: Column(
//         children: [
//           // Compact header with quick info
//           _buildCompactSheetHeader(sheet, data),
//           SizedBox(height: 6),
//           // Active filters row (only if filters are active)
//           if (_activeFilters[sheet.id]?.isNotEmpty == true)
//             _buildActiveFiltersRow(sheet),
//           if (_activeFilters[sheet.id]?.isNotEmpty == true) SizedBox(height: 6),
//           // Main data table - maximized height
//           Expanded(child: _buildOptimizedDataContent(provider, sheet, data)),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactSheetHeader(
//       SheetConfig sheet, List<Map<String, dynamic>>? data) {
//     final recordCount = data?.length ?? 0;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Row(
//         children: [
//           Icon(sheet.icon, color: sheet.color, size: 18),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(sheet.description,
//                 style: TextStyle(fontSize: 13, color: Colors.grey[700])),
//           ),
//           // Compact record count chip
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//             decoration: BoxDecoration(
//               color: sheet.color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               recordCount > 999
//                   ? '${(recordCount / 1000).toStringAsFixed(1)}k records'
//                   : '$recordCount records',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: sheet.color,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActiveFiltersRow(SheetConfig sheet) {
//     final activeFilters = _activeFilters[sheet.id] ?? [];

//     return Container(
//       height: 32,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: activeFilters.length + 1, // +1 for clear all button
//         separatorBuilder: (context, index) => SizedBox(width: 6),
//         itemBuilder: (context, index) {
//           if (index == activeFilters.length) {
//             // Clear all button
//             return GestureDetector(
//               onTap: () => _clearAllFilters(sheet.id),
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.red[50],
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.red[200]!),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.clear_all, size: 12, color: Colors.red[600]),
//                     SizedBox(width: 4),
//                     Text('Clear All',
//                         style: TextStyle(fontSize: 10, color: Colors.red[600])),
//                   ],
//                 ),
//               ),
//             );
//           }

//           final filter = activeFilters[index];
//           return Container(
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.blue[200]!),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(filter,
//                     style: TextStyle(fontSize: 10, color: Colors.blue[700])),
//                 SizedBox(width: 4),
//                 GestureDetector(
//                   onTap: () => _removeFilter(sheet.id, filter),
//                   child: Icon(Icons.close, size: 12, color: Colors.blue[600]),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildOptimizedDataContent(ReconProvider provider, SheetConfig sheet,
//       List<Map<String, dynamic>>? data) {
//     if (provider.isLoading) {
//       return _buildLoadingState(sheet);
//     }

//     if (data == null || data.isEmpty) {
//       return _buildEmptyState(sheet, provider);
//     }

//     final filteredData = _applyFilters(data, sheet.id);
//     final paginatedData = _getPaginatedData(filteredData, sheet.id);

//     if (filteredData.isEmpty) {
//       return _buildNoResultsState(sheet);
//     }

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         children: [
//           // Pagination info (compact)
//           if (filteredData.length > _itemsPerPage)
//             _buildCompactPaginationInfo(sheet, filteredData.length),
//           // Data table - takes remaining space
//           Expanded(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: _buildDataTableForSheet(sheet, paginatedData),
//             ),
//           ),
//           // Pagination controls (compact)
//           if (filteredData.length > _itemsPerPage)
//             _buildCompactPaginationControls(sheet, filteredData.length),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactPaginationInfo(SheetConfig sheet, int totalItems) {
//     final currentPage = _currentPage[sheet.id] ?? 0;
//     final startIndex = currentPage * _itemsPerPage + 1;
//     final endIndex = ((currentPage + 1) * _itemsPerPage).clamp(0, totalItems);

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Showing $startIndex-$endIndex of $totalItems',
//             style: TextStyle(color: Colors.grey[600], fontSize: 11),
//           ),
//           Text(
//             'Page ${currentPage + 1} of ${(totalItems / _itemsPerPage).ceil()}',
//             style: TextStyle(
//               color: sheet.color,
//               fontWeight: FontWeight.w600,
//               fontSize: 11,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactPaginationControls(SheetConfig sheet, int totalItems) {
//     final totalPages = (totalItems / _itemsPerPage).ceil();
//     final currentPage = _currentPage[sheet.id] ?? 0;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         border: Border(top: BorderSide(color: Colors.grey[200]!)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _buildPaginationButton(
//             icon: Icons.first_page,
//             enabled: currentPage > 0,
//             onPressed: () => _changePage(sheet.id, 0),
//           ),
//           _buildPaginationButton(
//             icon: Icons.chevron_left,
//             enabled: currentPage > 0,
//             onPressed: () => _changePage(sheet.id, currentPage - 1),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             child: Text(
//               '${currentPage + 1}/$totalPages',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
//             ),
//           ),
//           _buildPaginationButton(
//             icon: Icons.chevron_right,
//             enabled: currentPage < totalPages - 1,
//             onPressed: () => _changePage(sheet.id, currentPage + 1),
//           ),
//           _buildPaginationButton(
//             icon: Icons.last_page,
//             enabled: currentPage < totalPages - 1,
//             onPressed: () => _changePage(sheet.id, totalPages - 1),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaginationButton({
//     required IconData icon,
//     required bool enabled,
//     required VoidCallback onPressed,
//   }) {
//     return SizedBox(
//       width: 32,
//       height: 32,
//       child: IconButton(
//         onPressed: enabled ? onPressed : null,
//         icon: Icon(icon, size: 16),
//         padding: EdgeInsets.zero,
//         style: IconButton.styleFrom(
//           backgroundColor: enabled ? Colors.white : Colors.transparent,
//           disabledBackgroundColor: Colors.transparent,
//         ),
//       ),
//     );
//   }

//   // Floating Filter Panel
//   Widget _buildFilterFAB() {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final currentSheetIndex = _tabController.index;
//         final currentSheet = _sheets[currentSheetIndex];
//         final hasActiveFilters =
//             _activeFilters[currentSheet.id]?.isNotEmpty == true;

//         return FloatingActionButton.small(
//           onPressed: () {
//             setState(() {
//               _currentFilterSheet = currentSheet.id;
//               _showFloatingFilter = !_showFloatingFilter;
//             });
//           },
//           backgroundColor:
//               hasActiveFilters ? currentSheet.color : Colors.grey[700],
//           child: Stack(
//             children: [
//               Icon(Icons.filter_alt, size: 20, color: Colors.white),
//               if (hasActiveFilters)
//                 Positioned(
//                   right: 0,
//                   top: 0,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFloatingFilterPanel() {
//     final sheet = _sheets.firstWhere((s) => s.id == _currentFilterSheet);

//     return Positioned(
//       top: 16,
//       right: 16,
//       child: Material(
//         elevation: 8,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           width: 320,
//           constraints: BoxConstraints(maxHeight: 400),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header
//               Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: sheet.color.withOpacity(0.1),
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.filter_alt, color: sheet.color, size: 20),
//                     SizedBox(width: 8),
//                     Text('Filter ${sheet.name}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: sheet.color,
//                         )),
//                     Spacer(),
//                     IconButton(
//                       onPressed: () =>
//                           setState(() => _showFloatingFilter = false),
//                       icon: Icon(Icons.close, size: 20),
//                       padding: EdgeInsets.zero,
//                       constraints: BoxConstraints(),
//                     ),
//                   ],
//                 ),
//               ),
//               // Filter content
//               Flexible(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(16),
//                   child: _buildFloatingFilterContent(sheet),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingFilterContent(SheetConfig sheet) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Search
//         TextField(
//           controller: _searchControllers[sheet.id],
//           decoration: InputDecoration(
//             hintText: 'Search...',
//             prefixIcon: Icon(Icons.search, size: 20),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             isDense: true,
//           ),
//           onChanged: (value) => _onSearchChanged(sheet.id, value),
//         ),
//         SizedBox(height: 12),

//         // Amount range
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _minAmountControllers[sheet.id],
//                 decoration: InputDecoration(
//                   labelText: 'Min ₹',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                   isDense: true,
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => _onFilterChanged(sheet.id),
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: TextField(
//                 controller: _maxAmountControllers[sheet.id],
//                 decoration: InputDecoration(
//                   labelText: 'Max ₹',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                   isDense: true,
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => _onFilterChanged(sheet.id),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 12),

//         // Transaction mode
//         DropdownButtonFormField<String>(
//           value: _selectedTransactionModes[sheet.id],
//           decoration: InputDecoration(
//             labelText: 'Transaction Mode',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//             isDense: true,
//           ),
//           items: ['All', 'Paytm', 'PhonePe', 'Cloud', 'PTPP', 'Manual']
//               .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
//               .toList(),
//           onChanged: (value) {
//             setState(() => _selectedTransactionModes[sheet.id] = value!);
//             _onFilterChanged(sheet.id);
//           },
//         ),
//         SizedBox(height: 12),

//         // Remarks
//         TextField(
//           controller: _remarksControllers[sheet.id],
//           decoration: InputDecoration(
//             labelText: 'Remarks contains',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//             isDense: true,
//           ),
//           onChanged: (value) => _onFilterChanged(sheet.id),
//         ),
//         SizedBox(height: 16),

//         // Action buttons
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => _clearAllFilters(sheet.id),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey[100],
//                   foregroundColor: Colors.grey[700],
//                   elevation: 0,
//                 ),
//                 child: Text('Clear All'),
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => setState(() => _showFloatingFilter = false),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: sheet.color,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: Text('Apply'),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // Data Table Building Methods (keeping your existing implementation but optimized)
//   Widget _buildDataTableForSheet(
//       SheetConfig sheet, List<Map<String, dynamic>> data) {
//     switch (sheet.id) {
//       case 'SUMMARY':
//         return _buildSummaryTable(data);
//       case 'RAWDATA':
//         return _buildRawDataTable(data);
//       case 'RECON_SUCCESS':
//       case 'RECON_INVESTIGATE':
//       case 'MANUAL_REFUND':
//         return _buildReconTable(data, sheet);
//       default:
//         return _buildGenericTable(data);
//     }
//   }

//   Widget _buildSummaryTable(List<Map<String, dynamic>> data) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 12,
//       horizontalMargin: 12,
//       minWidth: 600,
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
//       columns: [
//         DataColumn2(
//           label: Text('Source',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Type',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Amount',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//       ],
//       rows: data
//           .map((row) => DataRow2(
//                 cells: [
//                   DataCell(
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(row['txn_source']?.toString() ?? '',
//                           style: TextStyle(fontSize: 11)),
//                     ),
//                   ),
//                   DataCell(Text(row['Txn_type']?.toString() ?? '',
//                       style: TextStyle(fontSize: 11))),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['sum(Txn_Amount)']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
//                     ),
//                   ),
//                 ],
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildRawDataTable(List<Map<String, dynamic>> data) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 8,
//       horizontalMargin: 8,
//       minWidth: 800,
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
//       columns: [
//         DataColumn2(
//           label: Text('Ref No',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.M,
//         ),
//         DataColumn2(
//           label: Text('Source',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Type',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Machine',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Amount',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//       ],
//       rows: data
//           .map((row) => DataRow2(
//                 cells: [
//                   DataCell(
//                     SelectableText(
//                       row['Txn_RefNo']?.toString() ?? '',
//                       style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
//                     ),
//                   ),
//                   DataCell(
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//                       decoration: BoxDecoration(
//                         color: _getSourceColor(row['Txn_Source']?.toString()),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         row['Txn_Source']?.toString() ?? '',
//                         style: TextStyle(fontSize: 9, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   DataCell(Text(row['Txn_Type']?.toString() ?? '',
//                       style: TextStyle(fontSize: 10))),
//                   DataCell(Text(row['Txn_Machine']?.toString() ?? '',
//                       style: TextStyle(fontSize: 10))),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(row['Txn_Amount']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ],
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildReconTable(List<Map<String, dynamic>> data, SheetConfig sheet) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 8,
//       horizontalMargin: 8,
//       minWidth: 1000,
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(sheet.color.withOpacity(0.1)),
//       columns: [
//         DataColumn2(
//           label: Text('Ref No',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.M,
//         ),
//         DataColumn2(
//           label: Text('Machine',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('PTPP Pay',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('PTPP Ref',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('Cloud Pay',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('Cloud Ref',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('Remarks',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.M,
//         ),
//       ],
//       rows: data
//           .map((row) => DataRow2(
//                 cells: [
//                   DataCell(
//                     SelectableText(
//                       row['Txn_RefNo']?.toString() ?? '',
//                       style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
//                     ),
//                   ),
//                   DataCell(Text(row['Txn_Machine']?.toString() ?? '',
//                       style: TextStyle(fontSize: 10))),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['PTPP_Payment']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['PTPP_Refund']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['Cloud_Payment']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['Cloud_Refund']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color:
//                             _getRemarksColor(row['Remarks']?.toString() ?? ''),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         row['Remarks']?.toString() ?? '',
//                         style: TextStyle(
//                           fontSize: 9,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildGenericTable(List<Map<String, dynamic>> data) {
//     if (data.isEmpty) return Center(child: Text('No data available'));

//     final columns = data.first.keys.take(6).toList();

//     return DataTable2(
//       columnSpacing: 12,
//       horizontalMargin: 12,
//       minWidth: columns.length * 120.0,
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
//       columns: columns
//           .map((column) => DataColumn2(
//                 label: Text(column,
//                     style:
//                         TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//                 size: ColumnSize.M,
//               ))
//           .toList(),
//       rows: data
//           .map((row) => DataRow2(
//                 cells: columns
//                     .map((column) => DataCell(
//                           Text(
//                             _formatCellValue(row[column]),
//                             style: TextStyle(fontSize: 10),
//                           ),
//                         ))
//                     .toList(),
//               ))
//           .toList(),
//     );
//   }

//   // Loading and Error States
//   Widget _buildLoadingState(SheetConfig sheet) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(color: sheet.color, strokeWidth: 2),
//           SizedBox(height: 12),
//           Text('Loading ${sheet.name.toLowerCase()}...',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(SheetConfig sheet, ReconProvider provider) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(40),
//             ),
//             child:
//                 Icon(Icons.inbox_outlined, size: 40, color: Colors.grey[400]),
//           ),
//           SizedBox(height: 12),
//           Text('No data available',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           SizedBox(height: 6),
//           Text('No records found for ${sheet.name}',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//           SizedBox(height: 12),
//           ElevatedButton.icon(
//             onPressed: () => provider.loadSheet(sheet.id),
//             icon: Icon(Icons.refresh, size: 16),
//             label: Text('Reload Data'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: sheet.color,
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoResultsState(SheetConfig sheet) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.orange[50],
//               borderRadius: BorderRadius.circular(40),
//             ),
//             child: Icon(Icons.search_off, size: 40, color: Colors.orange[400]),
//           ),
//           SizedBox(height: 12),
//           Text('No results found',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           SizedBox(height: 6),
//           Text('Try adjusting your filters or search criteria',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//           SizedBox(height: 12),
//           TextButton.icon(
//             onPressed: () => _clearAllFilters(sheet.id),
//             icon: Icon(Icons.clear_all, size: 16),
//             label: Text('Clear All Filters'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper Methods
//   Color _getRemarksColor(String remarks) {
//     switch (remarks.toLowerCase()) {
//       case 'perfect':
//         return Colors.green[600]!;
//       case 'investigate':
//         return Colors.orange[600]!;
//       case 'manual':
//         return Colors.purple[600]!;
//       default:
//         return Colors.blue[600]!;
//     }
//   }

//   Color _getSourceColor(String? source) {
//     switch (source?.toLowerCase()) {
//       case 'paytm':
//         return Colors.blue[600]!;
//       case 'phonepe':
//         return Colors.purple[600]!;
//       case 'cloud':
//         return Colors.green[600]!;
//       case 'ptpp':
//         return Colors.orange[600]!;
//       default:
//         return Colors.grey[600]!;
//     }
//   }

//   String _formatCellValue(dynamic value) {
//     if (value == null) return '';
//     if (value is num && value > 1000) {
//       return NumberFormat('#,##0.00').format(value);
//     }
//     return value.toString();
//   }

//   int _getTotalRecords(ReconProvider provider) {
//     int total = 0;
//     for (String sheetId in [
//       'SUMMARY',
//       'RAWDATA',
//       'RECON_SUCCESS',
//       'RECON_INVESTIGATE',
//       'MANUAL_REFUND'
//     ]) {
//       final data = provider.getSheetData(sheetId);
//       if (data != null) total += data.length;
//     }
//     return total;
//   }

//   int _getSuccessRate(ReconProvider provider) {
//     final successData = provider.getSheetData('RECON_SUCCESS');
//     final investigateData = provider.getSheetData('RECON_INVESTIGATE');
//     final totalRecon =
//         (successData?.length ?? 0) + (investigateData?.length ?? 0);

//     if (totalRecon == 0) return 0;
//     return ((successData?.length ?? 0) * 100 / totalRecon).round();
//   }

//   List<Map<String, dynamic>> _applyFilters(
//       List<Map<String, dynamic>> data, String sheetId) {
//     final searchQuery = _searchControllers[sheetId]?.text.toLowerCase() ?? '';
//     final minAmount =
//         double.tryParse(_minAmountControllers[sheetId]?.text ?? '');
//     final maxAmount =
//         double.tryParse(_maxAmountControllers[sheetId]?.text ?? '');
//     final remarksFilter =
//         _remarksControllers[sheetId]?.text.toLowerCase() ?? '';
//     final modeFilter = _selectedTransactionModes[sheetId] ?? 'All';
//     final statusFilter = _selectedQuickStatuses[sheetId] ?? 'All';

//     return data.where((row) {
//       // Search filter
//       if (searchQuery.isNotEmpty) {
//         bool matchesSearch = row.values.any((value) =>
//             value?.toString().toLowerCase().contains(searchQuery) ?? false);
//         if (!matchesSearch) return false;
//       }

//       // Amount range filter
//       if (minAmount != null || maxAmount != null) {
//         final amount = _getAmountFromRow(row);
//         if (amount != null) {
//           if (minAmount != null && amount < minAmount) return false;
//           if (maxAmount != null && amount > maxAmount) return false;
//         }
//       }

//       // Remarks filter
//       if (remarksFilter.isNotEmpty) {
//         final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//         if (!remarks.contains(remarksFilter)) return false;
//       }

//       // Transaction mode filter
//       if (modeFilter != 'All') {
//         final source = row['Txn_Source']?.toString() ?? '';
//         if (!source.toLowerCase().contains(modeFilter.toLowerCase()))
//           return false;
//       }

//       // Quick status filter
//       if (statusFilter != 'All') {
//         final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//         if (!remarks.contains(statusFilter.toLowerCase())) return false;
//       }

//       return true;
//     }).toList();
//   }

//   double? _getAmountFromRow(Map<String, dynamic> row) {
//     final amountFields = [
//       'Txn_Amount',
//       'PTPP_Payment',
//       'Cloud_Payment',
//       'sum(Txn_Amount)'
//     ];

//     for (String field in amountFields) {
//       if (row.containsKey(field)) {
//         return double.tryParse(row[field]?.toString() ?? '0');
//       }
//     }
//     return null;
//   }

//   List<Map<String, dynamic>> _getPaginatedData(
//       List<Map<String, dynamic>> data, String sheetId) {
//     final startIndex = (_currentPage[sheetId] ?? 0) * _itemsPerPage;
//     final endIndex = (startIndex + _itemsPerPage).clamp(0, data.length);
//     return data.sublist(startIndex, endIndex);
//   }

//   void _onSearchChanged(String sheetId, String value) {
//     setState(() {
//       _currentPage[sheetId] = 0;
//     });
//     _updateActiveFilters(sheetId);
//   }

//   void _onFilterChanged(String sheetId) {
//     setState(() {
//       _currentPage[sheetId] = 0;
//     });
//     _updateActiveFilters(sheetId);
//   }

//   void _updateActiveFilters(String sheetId) {
//     List<String> filters = [];

//     final searchQuery = _searchControllers[sheetId]?.text ?? '';
//     if (searchQuery.isNotEmpty) {
//       filters.add('Search: "$searchQuery"');
//     }

//     final minAmount = _minAmountControllers[sheetId]?.text ?? '';
//     final maxAmount = _maxAmountControllers[sheetId]?.text ?? '';
//     if (minAmount.isNotEmpty || maxAmount.isNotEmpty) {
//       filters.add('Amount: ₹$minAmount - ₹$maxAmount');
//     }

//     final remarks = _remarksControllers[sheetId]?.text ?? '';
//     if (remarks.isNotEmpty) {
//       filters.add('Remarks: "$remarks"');
//     }

//     final mode = _selectedTransactionModes[sheetId] ?? 'All';
//     if (mode != 'All') {
//       filters.add('Mode: $mode');
//     }

//     final status = _selectedQuickStatuses[sheetId] ?? 'All';
//     if (status != 'All') {
//       filters.add('Status: $status');
//     }

//     setState(() {
//       _activeFilters[sheetId] = filters;
//     });
//   }

//   void _removeFilter(String sheetId, String filter) {
//     if (filter.startsWith('Search:')) {
//       _searchControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Amount:')) {
//       _minAmountControllers[sheetId]?.clear();
//       _maxAmountControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Remarks:')) {
//       _remarksControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Mode:')) {
//       _selectedTransactionModes[sheetId] = 'All';
//     } else if (filter.startsWith('Status:')) {
//       _selectedQuickStatuses[sheetId] = 'All';
//     }

//     _onFilterChanged(sheetId);
//   }

//   void _clearAllFilters(String sheetId) {
//     setState(() {
//       _searchControllers[sheetId]?.clear();
//       _minAmountControllers[sheetId]?.clear();
//       _maxAmountControllers[sheetId]?.clear();
//       _remarksControllers[sheetId]?.clear();
//       _selectedTransactionModes[sheetId] = 'All';
//       _selectedQuickStatuses[sheetId] = 'All';
//       _currentPage[sheetId] = 0;
//       _activeFilters[sheetId] = [];
//     });
//   }

//   void _changePage(String sheetId, int newPage) {
//     setState(() {
//       _currentPage[sheetId] = newPage;
//     });
//   }
// }

// class SheetConfig {
//   final String id;
//   final String name;
//   final IconData icon;
//   final String description;
//   final Color color;

//   SheetConfig(this.id, this.name, this.icon, this.description, this.color);
// }

// // Add these extension methods at the bottom of the file for null safety
// extension SafeColor on Color? {
//   Color get safe => this ?? Colors.grey;
// }

// extension SafeColorWithOpacity on Color {
//   Color safeWithOpacity(double opacity) {
//     try {
//       return this.withOpacity(opacity);
//     } catch (e) {

//3 -added the filter correctly

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:data_table_2/data_table_2.dart';
// import 'package:intl/intl.dart';
// import 'ReconProvider.dart';

// class DataScreen extends StatefulWidget {
//   @override
//   _DataScreenState createState() => _DataScreenState();
// }

// class _DataScreenState extends State<DataScreen>
//     with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
//   late TabController _tabController;
//   late AnimationController _filterAnimationController;
//   late Animation<double> _filterAnimation;

//   // Search and filter controllers
//   final Map<String, TextEditingController> _searchControllers = {};
//   final Map<String, TextEditingController> _minAmountControllers = {};
//   final Map<String, TextEditingController> _maxAmountControllers = {};
//   final Map<String, TextEditingController> _remarksControllers = {};
//   final Map<String, String> _selectedTransactionModes = {};
//   final Map<String, String> _selectedQuickStatuses = {};
//   final Map<String, bool> _isFilterExpanded = {};

//   final Map<String, List<String>> _selectedTransactionModesList = {};
//   final Map<String, List<String>> _selectedQuickStatusesList = {};

// // Available options for multi-select
//   final List<String> _transactionModes = [
//     'Paytm',
//     'PhonePe',
//     'Cloud',
//     'PTPP',
//     'Manual'
//   ];
//   final List<String> _quickStatuses = ['Perfect', 'Investigate', 'Manual'];

//   // Pagination
//   final Map<String, int> _currentPage = {};
//   final int _itemsPerPage = 100; // Increased for better performance

//   // Active filters tracking
//   final Map<String, List<String>> _activeFilters = {};

//   // Floating filter panel
//   bool _showFloatingFilter = false;
//   String _currentFilterSheet = '';

//   final List<SheetConfig> _sheets = [
//     SheetConfig('SUMMARY', 'Summary', Icons.dashboard_outlined,
//         'Summary overview', Colors.blue),
//     SheetConfig('RECON_SUCCESS', 'Perfect', Icons.check_circle_outline,
//         'Successfully reconciled', Colors.green),
//     SheetConfig('RECON_INVESTIGATE', 'Investigate', Icons.warning_outlined,
//         'Require investigation', Colors.orange),
//     SheetConfig('MANUAL_REFUND', 'Manual', Icons.edit_outlined,
//         'Manual refunds', Colors.purple),
//     SheetConfig('RAWDATA', 'Raw Data', Icons.table_rows_outlined,
//         'All raw data', Colors.grey),
//   ];

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize TabController FIRST with correct length
//     _tabController = TabController(length: _sheets.length, vsync: this);

//     _filterAnimationController = AnimationController(
//       duration: Duration(milliseconds: 250),
//       vsync: this,
//     );
//     _filterAnimation = CurvedAnimation(
//       parent: _filterAnimationController,
//       curve: Curves.easeInOut,
//     );

//     // Initialize controllers for each sheet
//     for (var sheet in _sheets) {
//       _searchControllers[sheet.id] = TextEditingController();
//       _minAmountControllers[sheet.id] = TextEditingController();
//       _maxAmountControllers[sheet.id] = TextEditingController();
//       _remarksControllers[sheet.id] = TextEditingController();
//       _selectedTransactionModes[sheet.id] = 'All';
//       _selectedQuickStatuses[sheet.id] = 'All';
//       _isFilterExpanded[sheet.id] = false;
//       _currentPage[sheet.id] = 0;
//       _activeFilters[sheet.id] = [];
//       _selectedTransactionModesList[sheet.id] = [];
//       _selectedQuickStatusesList[sheet.id] = [];
//     }

//     // Load initial data
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ReconProvider>(context, listen: false).loadAllSheets();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _filterAnimationController.dispose();
//     _searchControllers.values.forEach((controller) => controller.dispose());
//     _minAmountControllers.values.forEach((controller) => controller.dispose());
//     _maxAmountControllers.values.forEach((controller) => controller.dispose());
//     _remarksControllers.values.forEach((controller) => controller.dispose());
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         return Scaffold(
//           backgroundColor: Colors.grey[50],
//           appBar: _buildCompactAppBar(provider),
//           body: Stack(
//             children: [
//               Column(
//                 children: [
//                   if (provider.error != null) _buildErrorBanner(provider),
//                   if (provider.isLoading) _buildLoadingIndicator(),
//                   _buildEnhancedTabBar(),
//                   Expanded(child: _buildTabBarView(provider)),
//                 ],
//               ),
//               // Floating Filter Panel
//               if (_showFloatingFilter) _buildFloatingFilterPanel(),
//             ],
//           ),
//           floatingActionButton: _buildFilterFAB(),
//           floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
//         );
//       },
//     );
//   }

//   PreferredSizeWidget _buildCompactAppBar(ReconProvider provider) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black87,
//       toolbarHeight: 60,
//       title: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: Colors.blue[100],
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Icon(Icons.analytics_outlined,
//                 color: Colors.blue[700], size: 20),
//           ),
//           SizedBox(width: 8),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Reconciliation Dashboard',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//               Text('Real-time analysis',
//                   style: TextStyle(fontSize: 11, color: Colors.grey[600])),
//             ],
//           ),
//         ],
//       ),
//       actions: [
//         _buildCompactStatsRow(provider),
//         SizedBox(width: 8),
//         IconButton(
//           onPressed: provider.isLoading ? null : () => provider.loadAllSheets(),
//           icon: Icon(Icons.refresh, size: 20),
//           tooltip: 'Refresh Data',
//         ),
//         SizedBox(width: 8),
//       ],
//     );
//   }

//   Widget _buildCompactStatsRow(ReconProvider provider) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _buildCompactStatChip(
//             'Records', _getTotalRecords(provider).toString(), Colors.blue),
//         SizedBox(width: 6),
//         _buildCompactStatChip(
//             'Success', '${_getSuccessRate(provider)}%', Colors.green),
//       ],
//     );
//   }

//   Widget _buildCompactStatChip(String label, String value, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3), width: 0.5),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(value,
//               style: TextStyle(
//                   fontSize: 12, fontWeight: FontWeight.bold, color: color)),
//           Text(label, style: TextStyle(fontSize: 9, color: color)),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorBanner(ReconProvider provider) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       color: Colors.red[50],
//       child: Row(
//         children: [
//           Icon(Icons.error_outline, color: Colors.red[700], size: 16),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(provider.error!,
//                 style: TextStyle(color: Colors.red[700], fontSize: 12)),
//           ),
//           IconButton(
//             onPressed: () => provider.clearError(),
//             icon: Icon(Icons.close, size: 16, color: Colors.red[700]),
//             padding: EdgeInsets.zero,
//             constraints: BoxConstraints(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingIndicator() {
//     return Container(
//       height: 2,
//       child: LinearProgressIndicator(
//         backgroundColor: Colors.grey[200],
//         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
//       ),
//     );
//   }

//   Widget _buildEnhancedTabBar() {
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.symmetric(horizontal: 8),
//       child: TabBar(
//         controller: _tabController,
//         isScrollable: true,
//         labelColor: Colors.blue[700] ?? Colors.blue,
//         unselectedLabelColor: Colors.grey[600] ?? Colors.grey,
//         indicatorColor: Colors.blue[600] ?? Colors.blue,
//         indicatorWeight: 2,
//         labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//         unselectedLabelStyle:
//             TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
//         onTap: (index) {
//           if (index < _sheets.length) {
//             _currentFilterSheet = _sheets[index].id;
//           }
//         },
//         tabs: _sheets
//             .map((sheet) => Tab(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(sheet.icon, size: 16, color: sheet.color),
//                         SizedBox(width: 6),
//                         Text(sheet.name),
//                         SizedBox(width: 6),
//                         _buildRecordCountBadge(sheet),
//                       ],
//                     ),
//                   ),
//                 ))
//             .toList(),
//       ),
//     );
//   }

//   Widget _buildRecordCountBadge(SheetConfig sheet) {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final data = provider.getSheetData(sheet.id);
//         final count = data?.length ?? 0;

//         if (count == 0) return SizedBox.shrink();

//         return Container(
//           padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//           decoration: BoxDecoration(
//             color: (sheet.color ?? Colors.grey).withOpacity(0.15),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             count > 999
//                 ? '${(count / 1000).toStringAsFixed(1)}k'
//                 : count.toString(),
//             style: TextStyle(
//               fontSize: 9,
//               fontWeight: FontWeight.bold,
//               color: sheet.color ?? Colors.grey,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTabBarView(ReconProvider provider) {
//     if (_tabController.length != _sheets.length) {
//       // Safety check: rebuild TabController if lengths don't match
//       _tabController.dispose();
//       _tabController = TabController(length: _sheets.length, vsync: this);
//     }

//     return TabBarView(
//       controller: _tabController,
//       children: _sheets
//           .map((sheet) => _buildOptimizedSheetView(provider, sheet))
//           .toList(),
//     );
//   }

//   Widget _buildOptimizedSheetView(ReconProvider provider, SheetConfig sheet) {
//     final data = provider.getSheetData(sheet.id);

//     return Padding(
//       padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
//       child: Column(
//         children: [
//           // Compact header with quick info
//           _buildCompactSheetHeader(sheet, data),
//           SizedBox(height: 6),
//           // Active filters row (only if filters are active)
//           if (_activeFilters[sheet.id]?.isNotEmpty == true)
//             _buildActiveFiltersRow(sheet),
//           if (_activeFilters[sheet.id]?.isNotEmpty == true) SizedBox(height: 6),
//           // Main data table - maximized height
//           Expanded(child: _buildOptimizedDataContent(provider, sheet, data)),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactSheetHeader(
//       SheetConfig sheet, List<Map<String, dynamic>>? data) {
//     final recordCount = data?.length ?? 0;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Row(
//         children: [
//           Icon(sheet.icon, color: sheet.color, size: 18),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(sheet.description,
//                 style: TextStyle(fontSize: 13, color: Colors.grey[700])),
//           ),
//           // Compact record count chip
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//             decoration: BoxDecoration(
//               color: sheet.color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               recordCount > 999
//                   ? '${(recordCount / 1000).toStringAsFixed(1)}k records'
//                   : '$recordCount records',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: sheet.color,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActiveFiltersRow(SheetConfig sheet) {
//     final activeFilters = _activeFilters[sheet.id] ?? [];

//     return Container(
//       height: 32,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: activeFilters.length + 1, // +1 for clear all button
//         separatorBuilder: (context, index) => SizedBox(width: 6),
//         itemBuilder: (context, index) {
//           if (index == activeFilters.length) {
//             // Clear all button
//             return GestureDetector(
//               onTap: () => _clearAllFilters(sheet.id),
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.red[50],
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.red[200]!),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.clear_all, size: 12, color: Colors.red[600]),
//                     SizedBox(width: 4),
//                     Text('Clear All',
//                         style: TextStyle(fontSize: 10, color: Colors.red[600])),
//                   ],
//                 ),
//               ),
//             );
//           }

//           final filter = activeFilters[index];
//           return Container(
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.blue[200]!),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(filter,
//                     style: TextStyle(fontSize: 10, color: Colors.blue[700])),
//                 SizedBox(width: 4),
//                 GestureDetector(
//                   onTap: () => _removeFilter(sheet.id, filter),
//                   child: Icon(Icons.close, size: 12, color: Colors.blue[600]),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildOptimizedDataContent(ReconProvider provider, SheetConfig sheet,
//       List<Map<String, dynamic>>? data) {
//     if (provider.isLoading) {
//       return _buildLoadingState(sheet);
//     }

//     if (data == null || data.isEmpty) {
//       return _buildEmptyState(sheet, provider);
//     }

//     final filteredData = _applyFilters(data, sheet.id);
//     final paginatedData = _getPaginatedData(filteredData, sheet.id);

//     if (filteredData.isEmpty) {
//       return _buildNoResultsState(sheet);
//     }

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         children: [
//           // Pagination info (compact)
//           if (filteredData.length > _itemsPerPage)
//             _buildCompactPaginationInfo(sheet, filteredData.length),
//           // Data table - takes remaining space
//           Expanded(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: _buildDataTableForSheet(sheet, paginatedData),
//             ),
//           ),
//           // Pagination controls (compact)
//           if (filteredData.length > _itemsPerPage)
//             _buildCompactPaginationControls(sheet, filteredData.length),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactPaginationInfo(SheetConfig sheet, int totalItems) {
//     final currentPage = _currentPage[sheet.id] ?? 0;
//     final startIndex = currentPage * _itemsPerPage + 1;
//     final endIndex = ((currentPage + 1) * _itemsPerPage).clamp(0, totalItems);

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Showing $startIndex-$endIndex of $totalItems',
//             style: TextStyle(color: Colors.grey[600], fontSize: 11),
//           ),
//           Text(
//             'Page ${currentPage + 1} of ${(totalItems / _itemsPerPage).ceil()}',
//             style: TextStyle(
//               color: sheet.color,
//               fontWeight: FontWeight.w600,
//               fontSize: 11,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactPaginationControls(SheetConfig sheet, int totalItems) {
//     final totalPages = (totalItems / _itemsPerPage).ceil();
//     final currentPage = _currentPage[sheet.id] ?? 0;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         border: Border(top: BorderSide(color: Colors.grey[200]!)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _buildPaginationButton(
//             icon: Icons.first_page,
//             enabled: currentPage > 0,
//             onPressed: () => _changePage(sheet.id, 0),
//           ),
//           _buildPaginationButton(
//             icon: Icons.chevron_left,
//             enabled: currentPage > 0,
//             onPressed: () => _changePage(sheet.id, currentPage - 1),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             child: Text(
//               '${currentPage + 1}/$totalPages',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
//             ),
//           ),
//           _buildPaginationButton(
//             icon: Icons.chevron_right,
//             enabled: currentPage < totalPages - 1,
//             onPressed: () => _changePage(sheet.id, currentPage + 1),
//           ),
//           _buildPaginationButton(
//             icon: Icons.last_page,
//             enabled: currentPage < totalPages - 1,
//             onPressed: () => _changePage(sheet.id, totalPages - 1),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaginationButton({
//     required IconData icon,
//     required bool enabled,
//     required VoidCallback onPressed,
//   }) {
//     return SizedBox(
//       width: 32,
//       height: 32,
//       child: IconButton(
//         onPressed: enabled ? onPressed : null,
//         icon: Icon(icon, size: 16),
//         padding: EdgeInsets.zero,
//         style: IconButton.styleFrom(
//           backgroundColor: enabled ? Colors.white : Colors.transparent,
//           disabledBackgroundColor: Colors.transparent,
//         ),
//       ),
//     );
//   }

//   // Floating Filter Panel
//   Widget _buildFilterFAB() {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final currentSheetIndex = _tabController.index;
//         final currentSheet = _sheets[currentSheetIndex];
//         final hasActiveFilters =
//             _activeFilters[currentSheet.id]?.isNotEmpty == true;

//         return FloatingActionButton.small(
//           onPressed: () {
//             setState(() {
//               _currentFilterSheet = currentSheet.id;
//               _showFloatingFilter = !_showFloatingFilter;
//             });
//           },
//           backgroundColor:
//               hasActiveFilters ? currentSheet.color : Colors.grey[700],
//           child: Stack(
//             children: [
//               Icon(Icons.filter_alt, size: 20, color: Colors.white),
//               if (hasActiveFilters)
//                 Positioned(
//                   right: 0,
//                   top: 0,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFloatingFilterPanel() {
//     final sheet = _sheets.firstWhere((s) => s.id == _currentFilterSheet);

//     return Positioned(
//       top: 16,
//       right: 16,
//       child: Material(
//         elevation: 8,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           width: 320,
//           constraints: BoxConstraints(maxHeight: 400),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header
//               Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: sheet.color.withOpacity(0.1),
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.filter_alt, color: sheet.color, size: 20),
//                     SizedBox(width: 8),
//                     Text('Filter ${sheet.name}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: sheet.color,
//                         )),
//                     Spacer(),
//                     IconButton(
//                       onPressed: () =>
//                           setState(() => _showFloatingFilter = false),
//                       icon: Icon(Icons.close, size: 20),
//                       padding: EdgeInsets.zero,
//                       constraints: BoxConstraints(),
//                     ),
//                   ],
//                 ),
//               ),
//               // Filter content
//               Flexible(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(16),
//                   child: _buildFloatingFilterContent(sheet),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingFilterContent(SheetConfig sheet) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Search
//         TextField(
//           controller: _searchControllers[sheet.id],
//           decoration: InputDecoration(
//             hintText: 'Search...',
//             prefixIcon: Icon(Icons.search, size: 20),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             isDense: true,
//           ),
//           onChanged: (value) => _onSearchChanged(sheet.id, value),
//         ),
//         SizedBox(height: 12),

//         // Amount range
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _minAmountControllers[sheet.id],
//                 decoration: InputDecoration(
//                   labelText: 'Min ₹',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                   isDense: true,
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => _onFilterChanged(sheet.id),
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: TextField(
//                 controller: _maxAmountControllers[sheet.id],
//                 decoration: InputDecoration(
//                   labelText: 'Max ₹',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                   isDense: true,
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => _onFilterChanged(sheet.id),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 12),

//         // Multi-Select Transaction Mode
//         _buildMultiSelectField(
//           label: 'Transaction Modes',
//           selectedItems: _selectedTransactionModesList[sheet.id] ?? [],
//           availableItems: _transactionModes,
//           onChanged: (selectedItems) {
//             setState(() {
//               _selectedTransactionModesList[sheet.id] = selectedItems;
//             });
//             _onFilterChanged(sheet.id);
//           },
//         ),
//         SizedBox(height: 12),

//         // Multi-Select Quick Status
//         _buildMultiSelectField(
//           label: 'Quick Status',
//           selectedItems: _selectedQuickStatusesList[sheet.id] ?? [],
//           availableItems: _quickStatuses,
//           onChanged: (selectedItems) {
//             setState(() {
//               _selectedQuickStatusesList[sheet.id] = selectedItems;
//             });
//             _onFilterChanged(sheet.id);
//           },
//         ),
//         SizedBox(height: 12),

//         // Remarks
//         TextField(
//           controller: _remarksControllers[sheet.id],
//           decoration: InputDecoration(
//             labelText: 'Remarks contains',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//             isDense: true,
//           ),
//           onChanged: (value) => _onFilterChanged(sheet.id),
//         ),
//         SizedBox(height: 16),

//         // Filtered Summary
//         _buildFilteredSummary(sheet),
//         SizedBox(height: 16),

//         // Action buttons
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => _clearAllFilters(sheet.id),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey[100],
//                   foregroundColor: Colors.grey[700],
//                   elevation: 0,
//                 ),
//                 child: Text('Clear All'),
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => setState(() => _showFloatingFilter = false),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: sheet.color,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: Text('Apply'),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

// // 4. Add this new method for multi-select fields
//   Widget _buildMultiSelectField({
//     required String label,
//     required List<String> selectedItems,
//     required List<String> availableItems,
//     required Function(List<String>) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//         SizedBox(height: 4),
//         Container(
//           width: double.infinity,
//           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey[400]!),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Wrap(
//             spacing: 4,
//             runSpacing: 4,
//             children: [
//               ...selectedItems.map((item) => Chip(
//                     label: Text(item, style: TextStyle(fontSize: 10)),
//                     backgroundColor: Colors.blue[100],
//                     deleteIcon: Icon(Icons.close, size: 14),
//                     onDeleted: () {
//                       final newList = List<String>.from(selectedItems);
//                       newList.remove(item);
//                       onChanged(newList);
//                     },
//                     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     padding: EdgeInsets.symmetric(horizontal: 4),
//                   )),
//               PopupMenuButton<String>(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.add, size: 14),
//                       SizedBox(width: 4),
//                       Text('Add', style: TextStyle(fontSize: 10)),
//                     ],
//                   ),
//                 ),
//                 itemBuilder: (context) => availableItems
//                     .where((item) => !selectedItems.contains(item))
//                     .map((item) => PopupMenuItem(
//                           value: item,
//                           child: Text(item, style: TextStyle(fontSize: 12)),
//                         ))
//                     .toList(),
//                 onSelected: (item) {
//                   final newList = List<String>.from(selectedItems);
//                   newList.add(item);
//                   onChanged(newList);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

// // 5. Add this new method for filtered summary
//   Widget _buildFilteredSummary(SheetConfig sheet) {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final data = provider.getSheetData(sheet.id);
//         if (data == null || data.isEmpty) {
//           return SizedBox.shrink();
//         }

//         final filteredData = _applyFilters(data, sheet.id);
//         final totalAmount = _calculateTotalAmount(filteredData);

//         return Container(
//           padding: EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: sheet.color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: sheet.color.withOpacity(0.3)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Filtered Results',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: sheet.color,
//                   fontSize: 12,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Records',
//                         style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                       ),
//                       Text(
//                         '${filteredData.length}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: sheet.color,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         'Total Amount',
//                         style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                       ),
//                       Text(
//                         NumberFormat.currency(symbol: '₹', decimalDigits: 0)
//                             .format(totalAmount),
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: sheet.color,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

// // 6. Add this helper method to calculate total amount
//   double _calculateTotalAmount(List<Map<String, dynamic>> data) {
//     double total = 0.0;

//     for (var row in data) {
//       // Try different amount fields based on the sheet type
//       final amountFields = [
//         'Txn_Amount',
//         'PTPP_Payment',
//         'Cloud_Payment',
//         'sum(Txn_Amount)',
//         'PTPP_Refund',
//         'Cloud_Refund'
//       ];

//       for (String field in amountFields) {
//         if (row.containsKey(field) && row[field] != null) {
//           final amount = double.tryParse(row[field].toString()) ?? 0.0;
//           total += amount;
//           break; // Only count the first valid amount field found
//         }
//       }
//     }

//     return total;
//   }

//   // Data Table Building Methods (keeping your existing implementation but optimized)
//   Widget _buildDataTableForSheet(
//       SheetConfig sheet, List<Map<String, dynamic>> data) {
//     switch (sheet.id) {
//       case 'SUMMARY':
//         return _buildSummaryTable(data);
//       case 'RAWDATA':
//         return _buildRawDataTable(data);
//       case 'RECON_SUCCESS':
//       case 'RECON_INVESTIGATE':
//       case 'MANUAL_REFUND':
//         return _buildReconTable(data, sheet);
//       default:
//         return _buildGenericTable(data);
//     }
//   }

//   Widget _buildSummaryTable(List<Map<String, dynamic>> data) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 12,
//       horizontalMargin: 12,
//       minWidth: 600,
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
//       columns: [
//         DataColumn2(
//           label: Text('Source',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Type',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Amount',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//       ],
//       rows: data
//           .map((row) => DataRow2(
//                 cells: [
//                   DataCell(
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(row['txn_source']?.toString() ?? '',
//                           style: TextStyle(fontSize: 11)),
//                     ),
//                   ),
//                   DataCell(Text(row['Txn_type']?.toString() ?? '',
//                       style: TextStyle(fontSize: 11))),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['sum(Txn_Amount)']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
//                     ),
//                   ),
//                 ],
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildRawDataTable(List<Map<String, dynamic>> data) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 8,
//       horizontalMargin: 8,
//       minWidth: 800,
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
//       columns: [
//         DataColumn2(
//           label: Text('Ref No',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.M,
//         ),
//         DataColumn2(
//           label: Text('Source',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Type',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Machine',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Amount',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//       ],
//       rows: data
//           .map((row) => DataRow2(
//                 cells: [
//                   DataCell(
//                     SelectableText(
//                       row['Txn_RefNo']?.toString() ?? '',
//                       style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
//                     ),
//                   ),
//                   DataCell(
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//                       decoration: BoxDecoration(
//                         color: _getSourceColor(row['Txn_Source']?.toString()),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         row['Txn_Source']?.toString() ?? '',
//                         style: TextStyle(fontSize: 9, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   DataCell(Text(row['Txn_Type']?.toString() ?? '',
//                       style: TextStyle(fontSize: 10))),
//                   DataCell(Text(row['Txn_Machine']?.toString() ?? '',
//                       style: TextStyle(fontSize: 10))),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(row['Txn_Amount']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ],
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildReconTable(List<Map<String, dynamic>> data, SheetConfig sheet) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 8,
//       horizontalMargin: 8,
//       minWidth: 1000,
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(sheet.color.withOpacity(0.1)),
//       columns: [
//         DataColumn2(
//           label: Text('Ref No',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.M,
//         ),
//         DataColumn2(
//           label: Text('Machine',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('PTPP Pay',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('PTPP Ref',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('Cloud Pay',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('Cloud Ref',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('Remarks',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.M,
//         ),
//       ],
//       rows: data
//           .map((row) => DataRow2(
//                 cells: [
//                   DataCell(
//                     SelectableText(
//                       row['Txn_RefNo']?.toString() ?? '',
//                       style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
//                     ),
//                   ),
//                   DataCell(Text(row['Txn_Machine']?.toString() ?? '',
//                       style: TextStyle(fontSize: 10))),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['PTPP_Payment']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['PTPP_Refund']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['Cloud_Payment']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['Cloud_Refund']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color:
//                             _getRemarksColor(row['Remarks']?.toString() ?? ''),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         row['Remarks']?.toString() ?? '',
//                         style: TextStyle(
//                           fontSize: 9,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildGenericTable(List<Map<String, dynamic>> data) {
//     if (data.isEmpty) return Center(child: Text('No data available'));

//     final columns = data.first.keys.take(6).toList();

//     return DataTable2(
//       columnSpacing: 12,
//       horizontalMargin: 12,
//       minWidth: columns.length * 120.0,
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
//       columns: columns
//           .map((column) => DataColumn2(
//                 label: Text(column,
//                     style:
//                         TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//                 size: ColumnSize.M,
//               ))
//           .toList(),
//       rows: data
//           .map((row) => DataRow2(
//                 cells: columns
//                     .map((column) => DataCell(
//                           Text(
//                             _formatCellValue(row[column]),
//                             style: TextStyle(fontSize: 10),
//                           ),
//                         ))
//                     .toList(),
//               ))
//           .toList(),
//     );
//   }

//   // Loading and Error States
//   Widget _buildLoadingState(SheetConfig sheet) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(color: sheet.color, strokeWidth: 2),
//           SizedBox(height: 12),
//           Text('Loading ${sheet.name.toLowerCase()}...',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(SheetConfig sheet, ReconProvider provider) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(40),
//             ),
//             child:
//                 Icon(Icons.inbox_outlined, size: 40, color: Colors.grey[400]),
//           ),
//           SizedBox(height: 12),
//           Text('No data available',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           SizedBox(height: 6),
//           Text('No records found for ${sheet.name}',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//           SizedBox(height: 12),
//           ElevatedButton.icon(
//             onPressed: () => provider.loadSheet(sheet.id),
//             icon: Icon(Icons.refresh, size: 16),
//             label: Text('Reload Data'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: sheet.color,
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoResultsState(SheetConfig sheet) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.orange[50],
//               borderRadius: BorderRadius.circular(40),
//             ),
//             child: Icon(Icons.search_off, size: 40, color: Colors.orange[400]),
//           ),
//           SizedBox(height: 12),
//           Text('No results found',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           SizedBox(height: 6),
//           Text('Try adjusting your filters or search criteria',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//           SizedBox(height: 12),
//           TextButton.icon(
//             onPressed: () => _clearAllFilters(sheet.id),
//             icon: Icon(Icons.clear_all, size: 16),
//             label: Text('Clear All Filters'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper Methods
//   Color _getRemarksColor(String remarks) {
//     switch (remarks.toLowerCase()) {
//       case 'perfect':
//         return Colors.green[600]!;
//       case 'investigate':
//         return Colors.orange[600]!;
//       case 'manual':
//         return Colors.purple[600]!;
//       default:
//         return Colors.blue[600]!;
//     }
//   }

//   Color _getSourceColor(String? source) {
//     switch (source?.toLowerCase()) {
//       case 'paytm':
//         return Colors.blue[600]!;
//       case 'phonepe':
//         return Colors.purple[600]!;
//       case 'cloud':
//         return Colors.green[600]!;
//       case 'ptpp':
//         return Colors.orange[600]!;
//       default:
//         return Colors.grey[600]!;
//     }
//   }

//   String _formatCellValue(dynamic value) {
//     if (value == null) return '';
//     if (value is num && value > 1000) {
//       return NumberFormat('#,##0.00').format(value);
//     }
//     return value.toString();
//   }

//   int _getTotalRecords(ReconProvider provider) {
//     int total = 0;
//     for (String sheetId in [
//       'SUMMARY',
//       'RAWDATA',
//       'RECON_SUCCESS',
//       'RECON_INVESTIGATE',
//       'MANUAL_REFUND'
//     ]) {
//       final data = provider.getSheetData(sheetId);
//       if (data != null) total += data.length;
//     }
//     return total;
//   }

//   int _getSuccessRate(ReconProvider provider) {
//     final successData = provider.getSheetData('RECON_SUCCESS');
//     final investigateData = provider.getSheetData('RECON_INVESTIGATE');
//     final totalRecon =
//         (successData?.length ?? 0) + (investigateData?.length ?? 0);

//     if (totalRecon == 0) return 0;
//     return ((successData?.length ?? 0) * 100 / totalRecon).round();
//   }

//   // List<Map<String, dynamic>> _applyFilters(
//   //     List<Map<String, dynamic>> data, String sheetId) {
//   //   final searchQuery = _searchControllers[sheetId]?.text.toLowerCase() ?? '';
//   //   final minAmount =
//   //       double.tryParse(_minAmountControllers[sheetId]?.text ?? '');
//   //   final maxAmount =
//   //       double.tryParse(_maxAmountControllers[sheetId]?.text ?? '');
//   //   final remarksFilter =
//   //       _remarksControllers[sheetId]?.text.toLowerCase() ?? '';
//   //   final modeFilter = _selectedTransactionModes[sheetId] ?? 'All';
//   //   final statusFilter = _selectedQuickStatuses[sheetId] ?? 'All';

//   //   return data.where((row) {
//   //     // Search filter
//   //     if (searchQuery.isNotEmpty) {
//   //       bool matchesSearch = row.values.any((value) =>
//   //           value?.toString().toLowerCase().contains(searchQuery) ?? false);
//   //       if (!matchesSearch) return false;
//   //     }

//   //     // Amount range filter
//   //     if (minAmount != null || maxAmount != null) {
//   //       final amount = _getAmountFromRow(row);
//   //       if (amount != null) {
//   //         if (minAmount != null && amount < minAmount) return false;
//   //         if (maxAmount != null && amount > maxAmount) return false;
//   //       }
//   //     }

//   //     // Remarks filter
//   //     if (remarksFilter.isNotEmpty) {
//   //       final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//   //       if (!remarks.contains(remarksFilter)) return false;
//   //     }

//   //     // Transaction mode filter
//   //     if (modeFilter != 'All') {
//   //       final source = row['Txn_Source']?.toString() ?? '';
//   //       if (!source.toLowerCase().contains(modeFilter.toLowerCase()))
//   //         return false;
//   //     }

//   //     // Quick status filter
//   //     if (statusFilter != 'All') {
//   //       final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//   //       if (!remarks.contains(statusFilter.toLowerCase())) return false;
//   //     }

//   //     return true;
//   //   }).toList();
//   // }

//   List<Map<String, dynamic>> _applyFilters(
//       List<Map<String, dynamic>> data, String sheetId) {
//     final searchQuery = _searchControllers[sheetId]?.text.toLowerCase() ?? '';
//     final minAmount =
//         double.tryParse(_minAmountControllers[sheetId]?.text ?? '');
//     final maxAmount =
//         double.tryParse(_maxAmountControllers[sheetId]?.text ?? '');
//     final remarksFilter =
//         _remarksControllers[sheetId]?.text.toLowerCase() ?? '';

//     // Updated to use multi-select lists
//     final selectedModes = _selectedTransactionModesList[sheetId] ?? [];
//     final selectedStatuses = _selectedQuickStatusesList[sheetId] ?? [];

//     return data.where((row) {
//       // Search filter
//       if (searchQuery.isNotEmpty) {
//         bool matchesSearch = row.values.any((value) =>
//             value?.toString().toLowerCase().contains(searchQuery) ?? false);
//         if (!matchesSearch) return false;
//       }

//       // Amount range filter
//       if (minAmount != null || maxAmount != null) {
//         final amount = _getAmountFromRow(row);
//         if (amount != null) {
//           if (minAmount != null && amount < minAmount) return false;
//           if (maxAmount != null && amount > maxAmount) return false;
//         }
//       }

//       // Remarks filter
//       if (remarksFilter.isNotEmpty) {
//         final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//         if (!remarks.contains(remarksFilter)) return false;
//       }

//       // Multi-select transaction mode filter
//       if (selectedModes.isNotEmpty) {
//         final source = row['Txn_Source']?.toString() ?? '';
//         bool matchesMode = selectedModes
//             .any((mode) => source.toLowerCase().contains(mode.toLowerCase()));
//         if (!matchesMode) return false;
//       }

//       // Multi-select status filter
//       if (selectedStatuses.isNotEmpty) {
//         final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//         bool matchesStatus = selectedStatuses
//             .any((status) => remarks.contains(status.toLowerCase()));
//         if (!matchesStatus) return false;
//       }

//       return true;
//     }).toList();
//   }

//   double? _getAmountFromRow(Map<String, dynamic> row) {
//     final amountFields = [
//       'Txn_Amount',
//       'PTPP_Payment',
//       'Cloud_Payment',
//       'sum(Txn_Amount)'
//     ];

//     for (String field in amountFields) {
//       if (row.containsKey(field)) {
//         return double.tryParse(row[field]?.toString() ?? '0');
//       }
//     }
//     return null;
//   }

//   List<Map<String, dynamic>> _getPaginatedData(
//       List<Map<String, dynamic>> data, String sheetId) {
//     final startIndex = (_currentPage[sheetId] ?? 0) * _itemsPerPage;
//     final endIndex = (startIndex + _itemsPerPage).clamp(0, data.length);
//     return data.sublist(startIndex, endIndex);
//   }

//   void _onSearchChanged(String sheetId, String value) {
//     setState(() {
//       _currentPage[sheetId] = 0;
//     });
//     _updateActiveFilters(sheetId);
//   }

//   void _onFilterChanged(String sheetId) {
//     setState(() {
//       _currentPage[sheetId] = 0;
//     });
//     _updateActiveFilters(sheetId);
//   }

//   // void _updateActiveFilters(String sheetId) {
//   //   List<String> filters = [];

//   //   final searchQuery = _searchControllers[sheetId]?.text ?? '';
//   //   if (searchQuery.isNotEmpty) {
//   //     filters.add('Search: "$searchQuery"');
//   //   }

//   //   final minAmount = _minAmountControllers[sheetId]?.text ?? '';
//   //   final maxAmount = _maxAmountControllers[sheetId]?.text ?? '';
//   //   if (minAmount.isNotEmpty || maxAmount.isNotEmpty) {
//   //     filters.add('Amount: ₹$minAmount - ₹$maxAmount');
//   //   }

//   //   final remarks = _remarksControllers[sheetId]?.text ?? '';
//   //   if (remarks.isNotEmpty) {
//   //     filters.add('Remarks: "$remarks"');
//   //   }

//   //   final mode = _selectedTransactionModes[sheetId] ?? 'All';
//   //   if (mode != 'All') {
//   //     filters.add('Mode: $mode');
//   //   }

//   //   final status = _selectedQuickStatuses[sheetId] ?? 'All';
//   //   if (status != 'All') {
//   //     filters.add('Status: $status');
//   //   }

//   //   setState(() {
//   //     _activeFilters[sheetId] = filters;
//   //   });
//   // }

//   void _updateActiveFilters(String sheetId) {
//     List<String> filters = [];

//     final searchQuery = _searchControllers[sheetId]?.text ?? '';
//     if (searchQuery.isNotEmpty) {
//       filters.add('Search: "$searchQuery"');
//     }

//     final minAmount = _minAmountControllers[sheetId]?.text ?? '';
//     final maxAmount = _maxAmountControllers[sheetId]?.text ?? '';
//     if (minAmount.isNotEmpty || maxAmount.isNotEmpty) {
//       filters.add('Amount: ₹$minAmount - ₹$maxAmount');
//     }

//     final remarks = _remarksControllers[sheetId]?.text ?? '';
//     if (remarks.isNotEmpty) {
//       filters.add('Remarks: "$remarks"');
//     }

//     // Updated for multi-select
//     final selectedModes = _selectedTransactionModesList[sheetId] ?? [];
//     if (selectedModes.isNotEmpty) {
//       filters.add('Modes: ${selectedModes.join(", ")}');
//     }

//     final selectedStatuses = _selectedQuickStatusesList[sheetId] ?? [];
//     if (selectedStatuses.isNotEmpty) {
//       filters.add('Status: ${selectedStatuses.join(", ")}');
//     }

//     setState(() {
//       _activeFilters[sheetId] = filters;
//     });
//   }

//   void _removeFilter(String sheetId, String filter) {
//     if (filter.startsWith('Search:')) {
//       _searchControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Amount:')) {
//       _minAmountControllers[sheetId]?.clear();
//       _maxAmountControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Remarks:')) {
//       _remarksControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Modes:')) {
//       _selectedTransactionModesList[sheetId] = [];
//     } else if (filter.startsWith('Status:')) {
//       _selectedQuickStatusesList[sheetId] = [];
//     }

//     _onFilterChanged(sheetId);
//   }

//   void _clearAllFilters(String sheetId) {
//     setState(() {
//       _searchControllers[sheetId]?.clear();
//       _minAmountControllers[sheetId]?.clear();
//       _maxAmountControllers[sheetId]?.clear();
//       _remarksControllers[sheetId]?.clear();
//       _selectedTransactionModes[sheetId] = 'All'; // Keep existing single select
//       _selectedQuickStatuses[sheetId] = 'All'; // Keep existing single select

//       // Clear new multi-select lists
//       _selectedTransactionModesList[sheetId] = [];
//       _selectedQuickStatusesList[sheetId] = [];

//       _currentPage[sheetId] = 0;
//       _activeFilters[sheetId] = [];
//     });
//   }

//   void _changePage(String sheetId, int newPage) {
//     setState(() {
//       _currentPage[sheetId] = newPage;
//     });
//   }
// }

// class SheetConfig {
//   final String id;
//   final String name;
//   final IconData icon;
//   final String description;
//   final Color color;

//   SheetConfig(this.id, this.name, this.icon, this.description, this.color);
// }

// // Add these extension methods at the bottom of the file for null safety
// extension SafeColor on Color? {
//   Color get safe => this ?? Colors.grey;
// }

// extension SafeColorWithOpacity on Color {
//   Color safeWithOpacity(double opacity) {
//     try {
//       return this.withOpacity(opacity);
//     } catch (e) {
//       return Colors.grey.withOpacity(opacity);
//     }
//   }
// }

//4 -final correct one

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:data_table_2/data_table_2.dart';
// import 'package:intl/intl.dart';
// import 'ReconProvider.dart';

// class DataScreen extends StatefulWidget {
//   @override
//   _DataScreenState createState() => _DataScreenState();
// }

// class _DataScreenState extends State<DataScreen>
//     with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
//   late TabController _tabController;
//   late AnimationController _filterAnimationController;
//   late Animation<double> _filterAnimation;

//   // Search and filter controllers
//   final Map<String, TextEditingController> _searchControllers = {};
//   final Map<String, TextEditingController> _minAmountControllers = {};
//   final Map<String, TextEditingController> _maxAmountControllers = {};
//   final Map<String, TextEditingController> _remarksControllers = {};
//   final Map<String, String> _selectedTransactionModes = {};
//   final Map<String, String> _selectedQuickStatuses = {};
//   final Map<String, bool> _isFilterExpanded = {};

//   final Map<String, List<String>> _selectedTransactionModesList = {};
//   final Map<String, List<String>> _selectedQuickStatusesList = {};

// // Available options for multi-select
//   final List<String> _transactionModes = [
//     'Paytm',
//     'PhonePe',
//     'Cloud',
//     'PTPP',
//     'Manual'
//   ];
//   final List<String> _quickStatuses = ['Perfect', 'Investigate', 'Manual'];

//   // Pagination
//   final Map<String, int> _currentPage = {};
//   final int _itemsPerPage = 100; // Increased for better performance

//   // Active filters tracking
//   final Map<String, List<String>> _activeFilters = {};

//   // Floating filter panel
//   bool _showFloatingFilter = false;
//   String _currentFilterSheet = '';

//   final List<SheetConfig> _sheets = [
//     SheetConfig('SUMMARY', 'Summary', Icons.dashboard_outlined,
//         'Summary overview', Colors.blue),
//     SheetConfig('RECON_SUCCESS', 'Perfect', Icons.check_circle_outline,
//         'Successfully reconciled', Colors.green),
//     SheetConfig('RECON_INVESTIGATE', 'Investigate', Icons.warning_outlined,
//         'Require investigation', Colors.orange),
//     SheetConfig('MANUAL_REFUND', 'Manual', Icons.edit_outlined,
//         'Manual refunds', Colors.purple),
//     SheetConfig('RAWDATA', 'Raw Data', Icons.table_rows_outlined,
//         'All raw data', Colors.grey),
//   ];

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize TabController FIRST with correct length
//     _tabController = TabController(length: _sheets.length, vsync: this);

//     _filterAnimationController = AnimationController(
//       duration: Duration(milliseconds: 250),
//       vsync: this,
//     );
//     _filterAnimation = CurvedAnimation(
//       parent: _filterAnimationController,
//       curve: Curves.easeInOut,
//     );

//     // Initialize controllers for each sheet
//     for (var sheet in _sheets) {
//       _searchControllers[sheet.id] = TextEditingController();
//       _minAmountControllers[sheet.id] = TextEditingController();
//       _maxAmountControllers[sheet.id] = TextEditingController();
//       _remarksControllers[sheet.id] = TextEditingController();
//       _selectedTransactionModes[sheet.id] = 'All';
//       _selectedQuickStatuses[sheet.id] = 'All';
//       _isFilterExpanded[sheet.id] = false;
//       _currentPage[sheet.id] = 0;
//       _activeFilters[sheet.id] = [];
//       _selectedTransactionModesList[sheet.id] = [];
//       _selectedQuickStatusesList[sheet.id] = [];
//     }

//     // Load initial data
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ReconProvider>(context, listen: false).loadAllSheets();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _filterAnimationController.dispose();
//     _searchControllers.values.forEach((controller) => controller.dispose());
//     _minAmountControllers.values.forEach((controller) => controller.dispose());
//     _maxAmountControllers.values.forEach((controller) => controller.dispose());
//     _remarksControllers.values.forEach((controller) => controller.dispose());
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         return Scaffold(
//           backgroundColor: Colors.grey[50],
//           appBar: _buildCompactAppBar(provider),
//           body: Stack(
//             children: [
//               Column(
//                 children: [
//                   if (provider.error != null) _buildErrorBanner(provider),
//                   if (provider.isLoading) _buildLoadingIndicator(),
//                   _buildEnhancedTabBar(),
//                   Expanded(child: _buildTabBarView(provider)),
//                 ],
//               ),
//               // Floating Filter Panel
//               if (_showFloatingFilter) _buildFloatingFilterPanel(),
//             ],
//           ),
//           floatingActionButton: _buildFilterFAB(),
//           floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
//         );
//       },
//     );
//   }

//   PreferredSizeWidget _buildCompactAppBar(ReconProvider provider) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black87,
//       toolbarHeight: 60,
//       title: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: Colors.blue[100],
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Icon(Icons.analytics_outlined,
//                 color: Colors.blue[700], size: 20),
//           ),
//           SizedBox(width: 8),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Reconciliation Dashboard',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//               Text('Real-time analysis',
//                   style: TextStyle(fontSize: 11, color: Colors.grey[600])),
//             ],
//           ),
//         ],
//       ),
//       actions: [
//         _buildCompactStatsRow(provider),
//         SizedBox(width: 8),
//         IconButton(
//           onPressed: provider.isLoading ? null : () => provider.loadAllSheets(),
//           icon: Icon(Icons.refresh, size: 20),
//           tooltip: 'Refresh Data',
//         ),
//         SizedBox(width: 8),
//       ],
//     );
//   }

//   Widget _buildCompactStatsRow(ReconProvider provider) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _buildCompactStatChip(
//             'Records', _getTotalRecords(provider).toString(), Colors.blue),
//         SizedBox(width: 6),
//         _buildCompactStatChip(
//             'Success', '${_getSuccessRate(provider)}%', Colors.green),
//       ],
//     );
//   }

//   Widget _buildCompactStatChip(String label, String value, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3), width: 0.5),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(value,
//               style: TextStyle(
//                   fontSize: 12, fontWeight: FontWeight.bold, color: color)),
//           Text(label, style: TextStyle(fontSize: 9, color: color)),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorBanner(ReconProvider provider) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       color: Colors.red[50],
//       child: Row(
//         children: [
//           Icon(Icons.error_outline, color: Colors.red[700], size: 16),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(provider.error!,
//                 style: TextStyle(color: Colors.red[700], fontSize: 12)),
//           ),
//           IconButton(
//             onPressed: () => provider.clearError(),
//             icon: Icon(Icons.close, size: 16, color: Colors.red[700]),
//             padding: EdgeInsets.zero,
//             constraints: BoxConstraints(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingIndicator() {
//     return Container(
//       height: 2,
//       child: LinearProgressIndicator(
//         backgroundColor: Colors.grey[200],
//         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
//       ),
//     );
//   }

//   Widget _buildEnhancedTabBar() {
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.symmetric(horizontal: 8),
//       child: TabBar(
//         controller: _tabController,
//         isScrollable: true,
//         labelColor: Colors.blue[700] ?? Colors.blue,
//         unselectedLabelColor: Colors.grey[600] ?? Colors.grey,
//         indicatorColor: Colors.blue[600] ?? Colors.blue,
//         indicatorWeight: 2,
//         labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//         unselectedLabelStyle:
//             TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
//         onTap: (index) {
//           if (index < _sheets.length) {
//             _currentFilterSheet = _sheets[index].id;
//           }
//         },
//         tabs: _sheets
//             .map((sheet) => Tab(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(sheet.icon, size: 16, color: sheet.color),
//                         SizedBox(width: 6),
//                         Text(sheet.name),
//                         SizedBox(width: 6),
//                         _buildRecordCountBadge(sheet),
//                       ],
//                     ),
//                   ),
//                 ))
//             .toList(),
//       ),
//     );
//   }

//   Widget _buildRecordCountBadge(SheetConfig sheet) {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final data = provider.getSheetData(sheet.id);
//         final count = data?.length ?? 0;

//         if (count == 0) return SizedBox.shrink();

//         return Container(
//           padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//           decoration: BoxDecoration(
//             color: (sheet.color ?? Colors.grey).withOpacity(0.15),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             count > 999
//                 ? '${(count / 1000).toStringAsFixed(1)}k'
//                 : count.toString(),
//             style: TextStyle(
//               fontSize: 9,
//               fontWeight: FontWeight.bold,
//               color: sheet.color ?? Colors.grey,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTabBarView(ReconProvider provider) {
//     if (_tabController.length != _sheets.length) {
//       // Safety check: rebuild TabController if lengths don't match
//       _tabController.dispose();
//       _tabController = TabController(length: _sheets.length, vsync: this);
//     }

//     return TabBarView(
//       controller: _tabController,
//       children: _sheets
//           .map((sheet) => _buildOptimizedSheetView(provider, sheet))
//           .toList(),
//     );
//   }

//   Widget _buildOptimizedSheetView(ReconProvider provider, SheetConfig sheet) {
//     final data = provider.getSheetData(sheet.id);

//     return Padding(
//       padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
//       child: Column(
//         children: [
//           // Compact header with quick info
//           _buildCompactSheetHeader(sheet, data),
//           SizedBox(height: 6),
//           // Active filters row (only if filters are active)
//           if (_activeFilters[sheet.id]?.isNotEmpty == true)
//             _buildActiveFiltersRow(sheet),
//           if (_activeFilters[sheet.id]?.isNotEmpty == true) SizedBox(height: 6),
//           // Main data table - maximized height
//           Expanded(child: _buildOptimizedDataContent(provider, sheet, data)),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactSheetHeader(
//       SheetConfig sheet, List<Map<String, dynamic>>? data) {
//     final recordCount = data?.length ?? 0;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Row(
//         children: [
//           Icon(sheet.icon, color: sheet.color, size: 18),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(sheet.description,
//                 style: TextStyle(fontSize: 13, color: Colors.grey[700])),
//           ),
//           // Compact record count chip
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//             decoration: BoxDecoration(
//               color: sheet.color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               recordCount > 999
//                   ? '${(recordCount / 1000).toStringAsFixed(1)}k records'
//                   : '$recordCount records',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: sheet.color,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActiveFiltersRow(SheetConfig sheet) {
//     final activeFilters = _activeFilters[sheet.id] ?? [];

//     return Container(
//       height: 32,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: activeFilters.length + 1, // +1 for clear all button
//         separatorBuilder: (context, index) => SizedBox(width: 6),
//         itemBuilder: (context, index) {
//           if (index == activeFilters.length) {
//             // Clear all button
//             return GestureDetector(
//               onTap: () => _clearAllFilters(sheet.id),
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.red[50],
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.red[200]!),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.clear_all, size: 12, color: Colors.red[600]),
//                     SizedBox(width: 4),
//                     Text('Clear All',
//                         style: TextStyle(fontSize: 10, color: Colors.red[600])),
//                   ],
//                 ),
//               ),
//             );
//           }

//           final filter = activeFilters[index];
//           return Container(
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.blue[200]!),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(filter,
//                     style: TextStyle(fontSize: 10, color: Colors.blue[700])),
//                 SizedBox(width: 4),
//                 GestureDetector(
//                   onTap: () => _removeFilter(sheet.id, filter),
//                   child: Icon(Icons.close, size: 12, color: Colors.blue[600]),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildOptimizedDataContent(ReconProvider provider, SheetConfig sheet,
//       List<Map<String, dynamic>>? data) {
//     if (provider.isLoading) {
//       return _buildLoadingState(sheet);
//     }

//     if (data == null || data.isEmpty) {
//       return _buildEmptyState(sheet, provider);
//     }

//     final filteredData = _applyFilters(data, sheet.id);
//     final paginatedData = _getPaginatedData(filteredData, sheet.id);

//     if (filteredData.isEmpty) {
//       return _buildNoResultsState(sheet);
//     }

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         children: [
//           // Pagination info (compact)
//           if (filteredData.length > _itemsPerPage)
//             _buildCompactPaginationInfo(sheet, filteredData.length),
//           // Data table - takes remaining space
//           Expanded(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: _buildDataTableForSheet(sheet, paginatedData),
//             ),
//           ),
//           // Pagination controls (compact)
//           if (filteredData.length > _itemsPerPage)
//             _buildCompactPaginationControls(sheet, filteredData.length),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactPaginationInfo(SheetConfig sheet, int totalItems) {
//     final currentPage = _currentPage[sheet.id] ?? 0;
//     final startIndex = currentPage * _itemsPerPage + 1;
//     final endIndex = ((currentPage + 1) * _itemsPerPage).clamp(0, totalItems);

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Showing $startIndex-$endIndex of $totalItems',
//             style: TextStyle(color: Colors.grey[600], fontSize: 11),
//           ),
//           Text(
//             'Page ${currentPage + 1} of ${(totalItems / _itemsPerPage).ceil()}',
//             style: TextStyle(
//               color: sheet.color,
//               fontWeight: FontWeight.w600,
//               fontSize: 11,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactPaginationControls(SheetConfig sheet, int totalItems) {
//     final totalPages = (totalItems / _itemsPerPage).ceil();
//     final currentPage = _currentPage[sheet.id] ?? 0;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         border: Border(top: BorderSide(color: Colors.grey[200]!)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _buildPaginationButton(
//             icon: Icons.first_page,
//             enabled: currentPage > 0,
//             onPressed: () => _changePage(sheet.id, 0),
//           ),
//           _buildPaginationButton(
//             icon: Icons.chevron_left,
//             enabled: currentPage > 0,
//             onPressed: () => _changePage(sheet.id, currentPage - 1),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             child: Text(
//               '${currentPage + 1}/$totalPages',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
//             ),
//           ),
//           _buildPaginationButton(
//             icon: Icons.chevron_right,
//             enabled: currentPage < totalPages - 1,
//             onPressed: () => _changePage(sheet.id, currentPage + 1),
//           ),
//           _buildPaginationButton(
//             icon: Icons.last_page,
//             enabled: currentPage < totalPages - 1,
//             onPressed: () => _changePage(sheet.id, totalPages - 1),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaginationButton({
//     required IconData icon,
//     required bool enabled,
//     required VoidCallback onPressed,
//   }) {
//     return SizedBox(
//       width: 32,
//       height: 32,
//       child: IconButton(
//         onPressed: enabled ? onPressed : null,
//         icon: Icon(icon, size: 16),
//         padding: EdgeInsets.zero,
//         style: IconButton.styleFrom(
//           backgroundColor: enabled ? Colors.white : Colors.transparent,
//           disabledBackgroundColor: Colors.transparent,
//         ),
//       ),
//     );
//   }

//   // Floating Filter Panel
//   Widget _buildFilterFAB() {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final currentSheetIndex = _tabController.index;
//         final currentSheet = _sheets[currentSheetIndex];
//         final hasActiveFilters =
//             _activeFilters[currentSheet.id]?.isNotEmpty == true;

//         return FloatingActionButton.small(
//           onPressed: () {
//             setState(() {
//               _currentFilterSheet = currentSheet.id;
//               _showFloatingFilter = !_showFloatingFilter;
//             });
//           },
//           backgroundColor:
//               hasActiveFilters ? currentSheet.color : Colors.grey[700],
//           child: Stack(
//             children: [
//               Icon(Icons.filter_alt, size: 20, color: Colors.white),
//               if (hasActiveFilters)
//                 Positioned(
//                   right: 0,
//                   top: 0,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFloatingFilterPanel() {
//     final sheet = _sheets.firstWhere((s) => s.id == _currentFilterSheet);

//     return Positioned(
//       top: 16,
//       right: 16,
//       child: Material(
//         elevation: 8,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           width: 320,
//           constraints: BoxConstraints(maxHeight: 400),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header
//               Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: sheet.color.withOpacity(0.1),
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.filter_alt, color: sheet.color, size: 20),
//                     SizedBox(width: 8),
//                     Text('Filter ${sheet.name}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: sheet.color,
//                         )),
//                     Spacer(),
//                     IconButton(
//                       onPressed: () =>
//                           setState(() => _showFloatingFilter = false),
//                       icon: Icon(Icons.close, size: 20),
//                       padding: EdgeInsets.zero,
//                       constraints: BoxConstraints(),
//                     ),
//                   ],
//                 ),
//               ),
//               // Filter content
//               Flexible(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(16),
//                   child: _buildFloatingFilterContent(sheet),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingFilterContent(SheetConfig sheet) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Search
//         TextField(
//           controller: _searchControllers[sheet.id],
//           decoration: InputDecoration(
//             hintText: 'Search...',
//             prefixIcon: Icon(Icons.search, size: 20),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             isDense: true,
//           ),
//           onChanged: (value) => _onSearchChanged(sheet.id, value),
//         ),
//         SizedBox(height: 12),

//         // Amount range
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _minAmountControllers[sheet.id],
//                 decoration: InputDecoration(
//                   labelText: 'Min ₹',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                   isDense: true,
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => _onFilterChanged(sheet.id),
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: TextField(
//                 controller: _maxAmountControllers[sheet.id],
//                 decoration: InputDecoration(
//                   labelText: 'Max ₹',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                   isDense: true,
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => _onFilterChanged(sheet.id),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 12),

//         // Multi-Select Transaction Mode
//         _buildMultiSelectField(
//           label: 'Transaction Modes',
//           selectedItems: _selectedTransactionModesList[sheet.id] ?? [],
//           availableItems: _transactionModes,
//           onChanged: (selectedItems) {
//             setState(() {
//               _selectedTransactionModesList[sheet.id] = selectedItems;
//             });
//             _onFilterChanged(sheet.id);
//           },
//         ),
//         SizedBox(height: 12),

//         // Multi-Select Quick Status
//         _buildMultiSelectField(
//           label: 'Quick Status',
//           selectedItems: _selectedQuickStatusesList[sheet.id] ?? [],
//           availableItems: _quickStatuses,
//           onChanged: (selectedItems) {
//             setState(() {
//               _selectedQuickStatusesList[sheet.id] = selectedItems;
//             });
//             _onFilterChanged(sheet.id);
//           },
//         ),
//         SizedBox(height: 12),

//         // Remarks
//         TextField(
//           controller: _remarksControllers[sheet.id],
//           decoration: InputDecoration(
//             labelText: 'Remarks contains',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//             isDense: true,
//           ),
//           onChanged: (value) => _onFilterChanged(sheet.id),
//         ),
//         SizedBox(height: 16),

//         // Filtered Summary
//         _buildFilteredSummary(sheet),
//         SizedBox(height: 16),

//         // Action buttons
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => _clearAllFilters(sheet.id),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey[100],
//                   foregroundColor: Colors.grey[700],
//                   elevation: 0,
//                 ),
//                 child: Text('Clear All'),
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => setState(() => _showFloatingFilter = false),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: sheet.color,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: Text('Apply'),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

// // 4. Add this new method for multi-select fields
//   Widget _buildMultiSelectField({
//     required String label,
//     required List<String> selectedItems,
//     required List<String> availableItems,
//     required Function(List<String>) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//         SizedBox(height: 4),
//         Container(
//           width: double.infinity,
//           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey[400]!),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Wrap(
//             spacing: 4,
//             runSpacing: 4,
//             children: [
//               ...selectedItems.map((item) => Chip(
//                     label: Text(item, style: TextStyle(fontSize: 10)),
//                     backgroundColor: Colors.blue[100],
//                     deleteIcon: Icon(Icons.close, size: 14),
//                     onDeleted: () {
//                       final newList = List<String>.from(selectedItems);
//                       newList.remove(item);
//                       onChanged(newList);
//                     },
//                     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     padding: EdgeInsets.symmetric(horizontal: 4),
//                   )),
//               PopupMenuButton<String>(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.add, size: 14),
//                       SizedBox(width: 4),
//                       Text('Add', style: TextStyle(fontSize: 10)),
//                     ],
//                   ),
//                 ),
//                 itemBuilder: (context) => availableItems
//                     .where((item) => !selectedItems.contains(item))
//                     .map((item) => PopupMenuItem(
//                           value: item,
//                           child: Text(item, style: TextStyle(fontSize: 12)),
//                         ))
//                     .toList(),
//                 onSelected: (item) {
//                   final newList = List<String>.from(selectedItems);
//                   newList.add(item);
//                   onChanged(newList);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

// // 5. Add this new method for filtered summary
//   Widget _buildFilteredSummary(SheetConfig sheet) {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final data = provider.getSheetData(sheet.id);
//         if (data == null || data.isEmpty) {
//           return SizedBox.shrink();
//         }

//         final filteredData = _applyFilters(data, sheet.id);
//         final totalAmount = _calculateTotalAmount(filteredData);

//         return Container(
//           padding: EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: sheet.color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: sheet.color.withOpacity(0.3)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Filtered Results',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: sheet.color,
//                   fontSize: 12,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Records',
//                         style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                       ),
//                       Text(
//                         '${filteredData.length}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: sheet.color,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         'Total Amount',
//                         style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                       ),
//                       Text(
//                         NumberFormat.currency(symbol: '₹', decimalDigits: 0)
//                             .format(totalAmount),
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: sheet.color,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

// // 6. Add this helper method to calculate total amount
//   double _calculateTotalAmount(List<Map<String, dynamic>> data) {
//     double total = 0.0;

//     for (var row in data) {
//       // Try different amount fields based on the sheet type
//       final amountFields = [
//         'Txn_Amount',
//         'PTPP_Payment',
//         'Cloud_Payment',
//         'sum(Txn_Amount)',
//         'PTPP_Refund',
//         'Cloud_Refund',
//         'Cloud_MRefund' // MISSING FIELD ADDED
//       ];

//       for (String field in amountFields) {
//         if (row.containsKey(field) && row[field] != null) {
//           final amount = double.tryParse(row[field].toString()) ?? 0.0;
//           total += amount;
//           break; // Only count the first valid amount field found
//         }
//       }
//     }

//     return total;
//   }

//   // Data Table Building Methods (keeping your existing implementation but optimized)
//   Widget _buildDataTableForSheet(
//       SheetConfig sheet, List<Map<String, dynamic>> data) {
//     switch (sheet.id) {
//       case 'SUMMARY':
//         return _buildSummaryTable(data);
//       case 'RAWDATA':
//         return _buildRawDataTable(data);
//       case 'RECON_SUCCESS':
//       case 'RECON_INVESTIGATE':
//       case 'MANUAL_REFUND':
//         return _buildReconTable(data, sheet);
//       default:
//         return _buildGenericTable(data);
//     }
//   }

//   Widget _buildSummaryTable(List<Map<String, dynamic>> data) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 12,
//       horizontalMargin: 12,
//       minWidth: 600,
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
//       columns: [
//         DataColumn2(
//           label: Text('Source',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Type',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Amount',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//       ],
//       rows: data
//           .map((row) => DataRow2(
//                 cells: [
//                   DataCell(
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(row['txn_source']?.toString() ?? '',
//                           style: TextStyle(fontSize: 11)),
//                     ),
//                   ),
//                   DataCell(Text(row['Txn_type']?.toString() ?? '',
//                       style: TextStyle(fontSize: 11))),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['sum(Txn_Amount)']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
//                     ),
//                   ),
//                 ],
//               ))
//           .toList(),
//     );
//   }

//   String _getShortMID(String mid) {
//     if (mid.isEmpty) return '-';

//     // VENDOLITEINDIA03 → VENDOL03
//     if (mid.startsWith('VENDOLITEINDIA')) {
//       return 'VENDOL${mid.substring(14)}';
//     }

//     // Auto refund initiated from the machine → Auto Refund
//     if (mid.toLowerCase().contains('auto')) {
//       return 'Auto Refund';
//     }

//     // If still too long, cut it
//     if (mid.length > 12) {
//       return '${mid.substring(0, 10)}..';
//     }

//     return mid;
//   }

// // 1. Updated _buildReconTable method with missing fields
//   Widget _buildReconTable(List<Map<String, dynamic>> data, SheetConfig sheet) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 6,
//       horizontalMargin: 8,
//       minWidth: 1200, // Increased width for additional columns
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(sheet.color.withOpacity(0.1)),
//       columns: [
//         DataColumn2(
//           label: Text('Ref No',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Machine',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('MID',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize
//               .L, // Changed from ColumnSize.M to ColumnSize.L for more space
//         ),
//         DataColumn2(
//           label: Text('PTPP Pay',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('PTPP Ref',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('Cloud Pay',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('Cloud Ref',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('Cloud Manual', // MISSING FIELD ADDED
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('Remarks',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.M,
//         ),
//       ],
//       rows: data
//           .map((row) => DataRow2(
//                 cells: [
//                   DataCell(
//                     SelectableText(
//                       row['Txn_RefNo']?.toString() ?? '',
//                       style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
//                     ),
//                   ),
//                   DataCell(Text(row['Txn_Machine']?.toString() ?? '',
//                       style: TextStyle(fontSize: 10))),
//                   DataCell(
//                     Container(
//                       width: double.infinity, // Take full available width
//                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: _getMIDColor(row['Txn_MID']?.toString()),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Text(
//                         row['Txn_MID']?.toString() ??
//                             '-', // Show full MID without truncation
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         overflow: TextOverflow
//                             .visible, // Allow text to wrap or expand
//                         softWrap: true, // Enable text wrapping
//                       ),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['PTPP_Payment']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['PTPP_Refund']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['Cloud_Payment']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['Cloud_Refund']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                   DataCell(
//                     // MISSING FIELD ADDED
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['Cloud_MRefund']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                         color: (double.tryParse(
//                                         row['Cloud_MRefund']?.toString() ??
//                                             '0') ??
//                                     0) !=
//                                 0
//                             ? Colors.red[700]
//                             : null,
//                       ),
//                     ),
//                   ),
//                   DataCell(
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color:
//                             _getRemarksColor(row['Remarks']?.toString() ?? ''),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         row['Remarks']?.toString() ?? '',
//                         style: TextStyle(
//                           fontSize: 9,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ))
//           .toList(),
//     );
//   }

// // 2. Updated _buildRawDataTable method with missing fields
//   Widget _buildRawDataTable(List<Map<String, dynamic>> data) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
//     final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

//     return DataTable2(
//       columnSpacing: 8,
//       horizontalMargin: 8,
//       minWidth: 1200, // Increased width for additional columns
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
//       columns: [
//         DataColumn2(
//           label: Text('Ref No',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Source',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Type',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Machine',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('MID',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.L, // Changed from ColumnSize.M to ColumnSize.L
//         ),
//         DataColumn2(
//           label: Text('Date', // MISSING FIELD ADDED
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.M,
//         ),
//         DataColumn2(
//           label: Text('Amount',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.S,
//           numeric: true,
//         ),
//       ],
//       rows: data
//           .map((row) => DataRow2(
//                 cells: [
//                   DataCell(
//                     SelectableText(
//                       row['Txn_RefNo']?.toString() ?? '',
//                       style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
//                     ),
//                   ),
//                   DataCell(
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//                       decoration: BoxDecoration(
//                         color: _getSourceColor(row['Txn_Source']?.toString()),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         row['Txn_Source']?.toString() ?? '',
//                         style: TextStyle(fontSize: 9, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   DataCell(Text(row['Txn_Type']?.toString() ?? '',
//                       style: TextStyle(fontSize: 10))),
//                   DataCell(Text(row['Txn_Machine']?.toString() ?? '',
//                       style: TextStyle(fontSize: 10))),
//                   DataCell(
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         _getShortMID(row['Txn_MID']?.toString() ?? ''),
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.grey[800],
//                           fontWeight: FontWeight.w500,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                       ),
//                     ),
//                   ),
//                   DataCell(
//                     // MISSING FIELD ADDED
//                     Text(
//                       _formatDate(row['Txn_Date']?.toString() ?? ''),
//                       style: TextStyle(fontSize: 10),
//                     ),
//                   ),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(row['Txn_Amount']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ],
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildGenericTable(List<Map<String, dynamic>> data) {
//     if (data.isEmpty) return Center(child: Text('No data available'));

//     final columns = data.first.keys.take(6).toList();

//     return DataTable2(
//       columnSpacing: 12,
//       horizontalMargin: 12,
//       minWidth: columns.length * 120.0,
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
//       columns: columns
//           .map((column) => DataColumn2(
//                 label: Text(column,
//                     style:
//                         TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//                 size: ColumnSize.M,
//               ))
//           .toList(),
//       rows: data
//           .map((row) => DataRow2(
//                 cells: columns
//                     .map((column) => DataCell(
//                           Text(
//                             _formatCellValue(row[column]),
//                             style: TextStyle(fontSize: 10),
//                           ),
//                         ))
//                     .toList(),
//               ))
//           .toList(),
//     );
//   }

//   // Loading and Error States
//   Widget _buildLoadingState(SheetConfig sheet) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(color: sheet.color, strokeWidth: 2),
//           SizedBox(height: 12),
//           Text('Loading ${sheet.name.toLowerCase()}...',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//         ],
//       ),
//     );
//   }

// // Helper method to get MID color coding
//   Color _getMIDColor(String? mid) {
//     if (mid == null || mid.isEmpty) return Colors.grey[400]!;

//     final midLower = mid.toLowerCase();
//     if (midLower.contains('vendol')) {
//       return Colors.indigo[600]!;
//     } else if (midLower.contains('india')) {
//       return Colors.teal[600]!;
//     } else if (midLower.contains('auto') || midLower.contains('manual')) {
//       return Colors.orange[600]!;
//     }
//     return Colors.blue[600]!;
//   }

// // Helper method to format date display
//   String _formatDate(String dateStr) {
//     if (dateStr.isEmpty) return '-';

//     try {
//       // Handle different date formats that might come from Excel
//       DateTime? date;

//       // Try parsing common Excel date formats
//       if (dateStr.contains('-')) {
//         date = DateTime.tryParse(dateStr);
//       } else if (dateStr.length == 8) {
//         // Handle YYYYMMDD format
//         final year = int.tryParse(dateStr.substring(0, 4));
//         final month = int.tryParse(dateStr.substring(4, 6));
//         final day = int.tryParse(dateStr.substring(6, 8));
//         if (year != null && month != null && day != null) {
//           date = DateTime(year, month, day);
//         }
//       }

//       if (date != null) {
//         return DateFormat('MMM dd, yy').format(date);
//       }

//       // If parsing fails, return truncated string
//       return dateStr.length > 12 ? '${dateStr.substring(0, 12)}...' : dateStr;
//     } catch (e) {
//       return dateStr.length > 12 ? '${dateStr.substring(0, 12)}...' : dateStr;
//     }
//   }

//   Widget _buildEmptyState(SheetConfig sheet, ReconProvider provider) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(40),
//             ),
//             child:
//                 Icon(Icons.inbox_outlined, size: 40, color: Colors.grey[400]),
//           ),
//           SizedBox(height: 12),
//           Text('No data available',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           SizedBox(height: 6),
//           Text('No records found for ${sheet.name}',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//           SizedBox(height: 12),
//           ElevatedButton.icon(
//             onPressed: () => provider.loadSheet(sheet.id),
//             icon: Icon(Icons.refresh, size: 16),
//             label: Text('Reload Data'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: sheet.color,
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoResultsState(SheetConfig sheet) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.orange[50],
//               borderRadius: BorderRadius.circular(40),
//             ),
//             child: Icon(Icons.search_off, size: 40, color: Colors.orange[400]),
//           ),
//           SizedBox(height: 12),
//           Text('No results found',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           SizedBox(height: 6),
//           Text('Try adjusting your filters or search criteria',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//           SizedBox(height: 12),
//           TextButton.icon(
//             onPressed: () => _clearAllFilters(sheet.id),
//             icon: Icon(Icons.clear_all, size: 16),
//             label: Text('Clear All Filters'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper Methods
//   Color _getRemarksColor(String remarks) {
//     switch (remarks.toLowerCase()) {
//       case 'perfect':
//         return Colors.green[600]!;
//       case 'investigate':
//         return Colors.orange[600]!;
//       case 'manual':
//         return Colors.purple[600]!;
//       default:
//         return Colors.blue[600]!;
//     }
//   }

//   Color _getSourceColor(String? source) {
//     switch (source?.toLowerCase()) {
//       case 'paytm':
//         return Colors.blue[600]!;
//       case 'phonepe':
//         return Colors.purple[600]!;
//       case 'cloud':
//         return Colors.green[600]!;
//       case 'ptpp':
//         return Colors.orange[600]!;
//       default:
//         return Colors.grey[600]!;
//     }
//   }

//   String _formatCellValue(dynamic value) {
//     if (value == null) return '';
//     if (value is num && value > 1000) {
//       return NumberFormat('#,##0.00').format(value);
//     }
//     return value.toString();
//   }

//   int _getTotalRecords(ReconProvider provider) {
//     int total = 0;
//     for (String sheetId in [
//       'SUMMARY',
//       'RAWDATA',
//       'RECON_SUCCESS',
//       'RECON_INVESTIGATE',
//       'MANUAL_REFUND'
//     ]) {
//       final data = provider.getSheetData(sheetId);
//       if (data != null) total += data.length;
//     }
//     return total;
//   }

//   int _getSuccessRate(ReconProvider provider) {
//     final successData = provider.getSheetData('RECON_SUCCESS');
//     final investigateData = provider.getSheetData('RECON_INVESTIGATE');
//     final totalRecon =
//         (successData?.length ?? 0) + (investigateData?.length ?? 0);

//     if (totalRecon == 0) return 0;
//     return ((successData?.length ?? 0) * 100 / totalRecon).round();
//   }

//   // List<Map<String, dynamic>> _applyFilters(
//   //     List<Map<String, dynamic>> data, String sheetId) {
//   //   final searchQuery = _searchControllers[sheetId]?.text.toLowerCase() ?? '';
//   //   final minAmount =
//   //       double.tryParse(_minAmountControllers[sheetId]?.text ?? '');
//   //   final maxAmount =
//   //       double.tryParse(_maxAmountControllers[sheetId]?.text ?? '');
//   //   final remarksFilter =
//   //       _remarksControllers[sheetId]?.text.toLowerCase() ?? '';
//   //   final modeFilter = _selectedTransactionModes[sheetId] ?? 'All';
//   //   final statusFilter = _selectedQuickStatuses[sheetId] ?? 'All';

//   //   return data.where((row) {
//   //     // Search filter
//   //     if (searchQuery.isNotEmpty) {
//   //       bool matchesSearch = row.values.any((value) =>
//   //           value?.toString().toLowerCase().contains(searchQuery) ?? false);
//   //       if (!matchesSearch) return false;
//   //     }

//   //     // Amount range filter
//   //     if (minAmount != null || maxAmount != null) {
//   //       final amount = _getAmountFromRow(row);
//   //       if (amount != null) {
//   //         if (minAmount != null && amount < minAmount) return false;
//   //         if (maxAmount != null && amount > maxAmount) return false;
//   //       }
//   //     }

//   //     // Remarks filter
//   //     if (remarksFilter.isNotEmpty) {
//   //       final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//   //       if (!remarks.contains(remarksFilter)) return false;
//   //     }

//   //     // Transaction mode filter
//   //     if (modeFilter != 'All') {
//   //       final source = row['Txn_Source']?.toString() ?? '';
//   //       if (!source.toLowerCase().contains(modeFilter.toLowerCase()))
//   //         return false;
//   //     }

//   //     // Quick status filter
//   //     if (statusFilter != 'All') {
//   //       final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//   //       if (!remarks.contains(statusFilter.toLowerCase())) return false;
//   //     }

//   //     return true;
//   //   }).toList();
//   // }

//   List<Map<String, dynamic>> _applyFilters(
//       List<Map<String, dynamic>> data, String sheetId) {
//     final searchQuery = _searchControllers[sheetId]?.text.toLowerCase() ?? '';
//     final minAmount =
//         double.tryParse(_minAmountControllers[sheetId]?.text ?? '');
//     final maxAmount =
//         double.tryParse(_maxAmountControllers[sheetId]?.text ?? '');
//     final remarksFilter =
//         _remarksControllers[sheetId]?.text.toLowerCase() ?? '';

//     // Updated to use multi-select lists
//     final selectedModes = _selectedTransactionModesList[sheetId] ?? [];
//     final selectedStatuses = _selectedQuickStatusesList[sheetId] ?? [];

//     return data.where((row) {
//       // Search filter
//       if (searchQuery.isNotEmpty) {
//         bool matchesSearch = row.values.any((value) =>
//             value?.toString().toLowerCase().contains(searchQuery) ?? false);
//         if (!matchesSearch) return false;
//       }

//       // Amount range filter
//       if (minAmount != null || maxAmount != null) {
//         final amount = _getAmountFromRow(row);
//         if (amount != null) {
//           if (minAmount != null && amount < minAmount) return false;
//           if (maxAmount != null && amount > maxAmount) return false;
//         }
//       }

//       // Remarks filter
//       if (remarksFilter.isNotEmpty) {
//         final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//         if (!remarks.contains(remarksFilter)) return false;
//       }

//       // Multi-select transaction mode filter
//       if (selectedModes.isNotEmpty) {
//         final source = row['Txn_Source']?.toString() ?? '';
//         bool matchesMode = selectedModes
//             .any((mode) => source.toLowerCase().contains(mode.toLowerCase()));
//         if (!matchesMode) return false;
//       }

//       // Multi-select status filter
//       if (selectedStatuses.isNotEmpty) {
//         final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//         bool matchesStatus = selectedStatuses
//             .any((status) => remarks.contains(status.toLowerCase()));
//         if (!matchesStatus) return false;
//       }

//       return true;
//     }).toList();
//   }

//   double? _getAmountFromRow(Map<String, dynamic> row) {
//     final amountFields = [
//       'Txn_Amount',
//       'PTPP_Payment',
//       'Cloud_Payment',
//       'sum(Txn_Amount)'
//     ];

//     for (String field in amountFields) {
//       if (row.containsKey(field)) {
//         return double.tryParse(row[field]?.toString() ?? '0');
//       }
//     }
//     return null;
//   }

//   List<Map<String, dynamic>> _getPaginatedData(
//       List<Map<String, dynamic>> data, String sheetId) {
//     final startIndex = (_currentPage[sheetId] ?? 0) * _itemsPerPage;
//     final endIndex = (startIndex + _itemsPerPage).clamp(0, data.length);
//     return data.sublist(startIndex, endIndex);
//   }

//   void _onSearchChanged(String sheetId, String value) {
//     setState(() {
//       _currentPage[sheetId] = 0;
//     });
//     _updateActiveFilters(sheetId);
//   }

//   void _onFilterChanged(String sheetId) {
//     setState(() {
//       _currentPage[sheetId] = 0;
//     });
//     _updateActiveFilters(sheetId);
//   }

//   // void _updateActiveFilters(String sheetId) {
//   //   List<String> filters = [];

//   //   final searchQuery = _searchControllers[sheetId]?.text ?? '';
//   //   if (searchQuery.isNotEmpty) {
//   //     filters.add('Search: "$searchQuery"');
//   //   }

//   //   final minAmount = _minAmountControllers[sheetId]?.text ?? '';
//   //   final maxAmount = _maxAmountControllers[sheetId]?.text ?? '';
//   //   if (minAmount.isNotEmpty || maxAmount.isNotEmpty) {
//   //     filters.add('Amount: ₹$minAmount - ₹$maxAmount');
//   //   }

//   //   final remarks = _remarksControllers[sheetId]?.text ?? '';
//   //   if (remarks.isNotEmpty) {
//   //     filters.add('Remarks: "$remarks"');
//   //   }

//   //   final mode = _selectedTransactionModes[sheetId] ?? 'All';
//   //   if (mode != 'All') {
//   //     filters.add('Mode: $mode');
//   //   }

//   //   final status = _selectedQuickStatuses[sheetId] ?? 'All';
//   //   if (status != 'All') {
//   //     filters.add('Status: $status');
//   //   }

//   //   setState(() {
//   //     _activeFilters[sheetId] = filters;
//   //   });
//   // }

//   void _updateActiveFilters(String sheetId) {
//     List<String> filters = [];

//     final searchQuery = _searchControllers[sheetId]?.text ?? '';
//     if (searchQuery.isNotEmpty) {
//       filters.add('Search: "$searchQuery"');
//     }

//     final minAmount = _minAmountControllers[sheetId]?.text ?? '';
//     final maxAmount = _maxAmountControllers[sheetId]?.text ?? '';
//     if (minAmount.isNotEmpty || maxAmount.isNotEmpty) {
//       filters.add('Amount: ₹$minAmount - ₹$maxAmount');
//     }

//     final remarks = _remarksControllers[sheetId]?.text ?? '';
//     if (remarks.isNotEmpty) {
//       filters.add('Remarks: "$remarks"');
//     }

//     // Updated for multi-select
//     final selectedModes = _selectedTransactionModesList[sheetId] ?? [];
//     if (selectedModes.isNotEmpty) {
//       filters.add('Modes: ${selectedModes.join(", ")}');
//     }

//     final selectedStatuses = _selectedQuickStatusesList[sheetId] ?? [];
//     if (selectedStatuses.isNotEmpty) {
//       filters.add('Status: ${selectedStatuses.join(", ")}');
//     }

//     setState(() {
//       _activeFilters[sheetId] = filters;
//     });
//   }

//   void _removeFilter(String sheetId, String filter) {
//     if (filter.startsWith('Search:')) {
//       _searchControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Amount:')) {
//       _minAmountControllers[sheetId]?.clear();
//       _maxAmountControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Remarks:')) {
//       _remarksControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Modes:')) {
//       _selectedTransactionModesList[sheetId] = [];
//     } else if (filter.startsWith('Status:')) {
//       _selectedQuickStatusesList[sheetId] = [];
//     }

//     _onFilterChanged(sheetId);
//   }

//   void _clearAllFilters(String sheetId) {
//     setState(() {
//       _searchControllers[sheetId]?.clear();
//       _minAmountControllers[sheetId]?.clear();
//       _maxAmountControllers[sheetId]?.clear();
//       _remarksControllers[sheetId]?.clear();
//       _selectedTransactionModes[sheetId] = 'All'; // Keep existing single select
//       _selectedQuickStatuses[sheetId] = 'All'; // Keep existing single select

//       // Clear new multi-select lists
//       _selectedTransactionModesList[sheetId] = [];
//       _selectedQuickStatusesList[sheetId] = [];

//       _currentPage[sheetId] = 0;
//       _activeFilters[sheetId] = [];
//     });
//   }

//   void _changePage(String sheetId, int newPage) {
//     setState(() {
//       _currentPage[sheetId] = newPage;
//     });
//   }
// }

// class SheetConfig {
//   final String id;
//   final String name;
//   final IconData icon;
//   final String description;
//   final Color color;

//   SheetConfig(this.id, this.name, this.icon, this.description, this.color);
// }

// // Add these extension methods at the bottom of the file for null safety
// extension SafeColor on Color? {
//   Color get safe => this ?? Colors.grey;
// }

// extension SafeColorWithOpacity on Color {
//   Color safeWithOpacity(double opacity) {
//     try {
//       return this.withOpacity(opacity);
//     } catch (e) {
//       return Colors.grey.withOpacity(opacity);
//     }
//   }
// }

//5 changing the filter

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:data_table_2/data_table_2.dart';
// import 'package:intl/intl.dart';
// import 'ReconProvider.dart';
// import 'package:flutter/services.dart';

// class DataScreen extends StatefulWidget {
//   @override
//   _DataScreenState createState() => _DataScreenState();
// }

// class _DataScreenState extends State<DataScreen>
//     with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
//   late TabController _tabController;
//   late AnimationController _filterAnimationController;
//   late Animation<double> _filterAnimation;

//   // Search and filter controllers
//   final Map<String, TextEditingController> _searchControllers = {};
//   final Map<String, TextEditingController> _minAmountControllers = {};
//   final Map<String, TextEditingController> _maxAmountControllers = {};
//   final Map<String, TextEditingController> _remarksControllers = {};
//   final Map<String, String> _selectedTransactionModes = {};
//   final Map<String, String> _selectedQuickStatuses = {};
//   final Map<String, bool> _isFilterExpanded = {};

//   Map<String, String> _selectedTransactionSources = {};

//   final Map<String, List<String>> _selectedTransactionModesList = {};
//   final Map<String, List<String>> _selectedQuickStatusesList = {};

//   final Map<String, double> _totalAmounts = {}; // Store total amounts per sheet
//   final Map<String, double> _filteredAmounts =
//       {}; // Store filtered amounts per sheet
//   final Map<String, int> _filteredCounts = {};

// // Available options for multi-select
//   final List<String> _transactionModes = [
//     'Paytm',
//     'PhonePe',
//     'Cloud',
//     'PTPP',
//     'Manual'
//   ];
//   final List<String> _quickStatuses = ['Perfect', 'Investigate', 'Manual'];

//   // Pagination
//   final Map<String, int> _currentPage = {};
//   final int _itemsPerPage = 100; // Increased for better performance

//   // Active filters tracking
//   final Map<String, List<String>> _activeFilters = {};
//   final Map<String, bool> _isFinancialBreakdownExpanded = {};
//   // Floating filter panel
//   bool _showFloatingFilter = false;
//   String _currentFilterSheet = '';

//   final List<SheetConfig> _sheets = [
//     SheetConfig('SUMMARY', 'Summary', Icons.dashboard_outlined,
//         'Summary overview', Colors.blue),
//     SheetConfig('RECON_SUCCESS', 'Perfect', Icons.check_circle_outline,
//         'Successfully reconciled', Colors.green),
//     SheetConfig('RECON_INVESTIGATE', 'Investigate', Icons.warning_outlined,
//         'Require investigation', Colors.orange),
//     SheetConfig('MANUAL_REFUND', 'Manual', Icons.edit_outlined,
//         'Manual refunds', Colors.purple),
//     SheetConfig('RAWDATA', 'Raw Data', Icons.table_rows_outlined,
//         'All raw data', Colors.grey),
//   ];

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize TabController FIRST with correct length
//     _tabController = TabController(length: _sheets.length, vsync: this);

//     _filterAnimationController = AnimationController(
//       duration: Duration(milliseconds: 250),
//       vsync: this,
//     );
//     _filterAnimation = CurvedAnimation(
//       parent: _filterAnimationController,
//       curve: Curves.easeInOut,
//     );

//     // Initialize controllers for each sheet
//     for (var sheet in _sheets) {
//       _searchControllers[sheet.id] = TextEditingController();
//       _minAmountControllers[sheet.id] = TextEditingController();
//       _maxAmountControllers[sheet.id] = TextEditingController();
//       _remarksControllers[sheet.id] = TextEditingController();
//       _selectedTransactionModes[sheet.id] = 'All';
//       _selectedQuickStatuses[sheet.id] = 'All';
//       _isFilterExpanded[sheet.id] = false;
//       _currentPage[sheet.id] = 0;
//       _activeFilters[sheet.id] = [];
//       _selectedTransactionModesList[sheet.id] = [];
//       _selectedQuickStatusesList[sheet.id] = [];

//       _totalAmounts[sheet.id] = 0.0;
//       _filteredAmounts[sheet.id] = 0.0;
//       _filteredCounts[sheet.id] = 0;

//       _isFinancialBreakdownExpanded[sheet.id] = false;
//     }

//     // Load initial data
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ReconProvider>(context, listen: false).loadAllSheets();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _filterAnimationController.dispose();
//     _searchControllers.values.forEach((controller) => controller.dispose());
//     _minAmountControllers.values.forEach((controller) => controller.dispose());
//     _maxAmountControllers.values.forEach((controller) => controller.dispose());
//     _remarksControllers.values.forEach((controller) => controller.dispose());
//     super.dispose();
//   }

//   void _handleRowAction(
//       BuildContext context, Map<String, dynamic> row, String action) {
//     switch (action) {
//       case 'copy':
//         Clipboard.setData(
//             ClipboardData(text: row['Txn_RefNo']?.toString() ?? ''));
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Reference number copied to clipboard')),
//         );
//         break;
//       case 'details':
//         _showTransactionDetails(context, row);
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         return Scaffold(
//           backgroundColor: Colors.grey[50],
//           appBar: _buildCompactAppBar(provider),
//           body: Stack(
//             children: [
//               Column(
//                 children: [
//                   if (provider.error != null) _buildErrorBanner(provider),
//                   if (provider.isLoading) _buildLoadingIndicator(),
//                   _buildEnhancedTabBar(),
//                   Expanded(child: _buildTabBarView(provider)),
//                 ],
//               ),
//               // Floating Filter Panel
//               if (_showFloatingFilter) _buildFloatingFilterPanel(),
//             ],
//           ),
//           floatingActionButton: _buildFilterFAB(),
//           floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
//         );
//       },
//     );
//   }

//   PreferredSizeWidget _buildCompactAppBar(ReconProvider provider) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black87,
//       toolbarHeight: 60,
//       title: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: Colors.blue[100],
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Icon(Icons.analytics_outlined,
//                 color: Colors.blue[700], size: 20),
//           ),
//           SizedBox(width: 8),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Reconciliation Dashboard',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//               Text('Real-time analysis',
//                   style: TextStyle(fontSize: 11, color: Colors.grey[600])),
//             ],
//           ),
//         ],
//       ),
//       actions: [
//         _buildCompactStatsRow(provider),
//         SizedBox(width: 8),
//         IconButton(
//           onPressed: provider.isLoading ? null : () => provider.loadAllSheets(),
//           icon: Icon(Icons.refresh, size: 20),
//           tooltip: 'Refresh Data',
//         ),
//         SizedBox(width: 8),
//       ],
//     );
//   }

//   Widget _buildCompactStatsRow(ReconProvider provider) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _buildCompactStatChip(
//             'Records', _getTotalRecords(provider).toString(), Colors.blue),
//         SizedBox(width: 6),
//         _buildCompactStatChip(
//             'Success', '${_getSuccessRate(provider)}%', Colors.green),
//       ],
//     );
//   }

//   Widget _buildCompactStatChip(String label, String value, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3), width: 0.5),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(value,
//               style: TextStyle(
//                   fontSize: 12, fontWeight: FontWeight.bold, color: color)),
//           Text(label, style: TextStyle(fontSize: 9, color: color)),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorBanner(ReconProvider provider) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       color: Colors.red[50],
//       child: Row(
//         children: [
//           Icon(Icons.error_outline, color: Colors.red[700], size: 16),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(provider.error!,
//                 style: TextStyle(color: Colors.red[700], fontSize: 12)),
//           ),
//           IconButton(
//             onPressed: () => provider.clearError(),
//             icon: Icon(Icons.close, size: 16, color: Colors.red[700]),
//             padding: EdgeInsets.zero,
//             constraints: BoxConstraints(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingIndicator() {
//     return Container(
//       height: 2,
//       child: LinearProgressIndicator(
//         backgroundColor: Colors.grey[200],
//         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
//       ),
//     );
//   }

//   Widget _buildEnhancedTabBar() {
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.symmetric(horizontal: 8),
//       child: TabBar(
//         controller: _tabController,
//         isScrollable: true,
//         labelColor: Colors.blue[700] ?? Colors.blue,
//         unselectedLabelColor: Colors.grey[600] ?? Colors.grey,
//         indicatorColor: Colors.blue[600] ?? Colors.blue,
//         indicatorWeight: 2,
//         labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//         unselectedLabelStyle:
//             TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
//         onTap: (index) {
//           if (index < _sheets.length) {
//             _currentFilterSheet = _sheets[index].id;
//           }
//         },
//         tabs: _sheets
//             .map((sheet) => Tab(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(sheet.icon, size: 16, color: sheet.color),
//                         SizedBox(width: 6),
//                         Text(sheet.name),
//                         SizedBox(width: 6),
//                         _buildRecordCountBadge(sheet),
//                       ],
//                     ),
//                   ),
//                 ))
//             .toList(),
//       ),
//     );
//   }

//   Widget _buildRecordCountBadge(SheetConfig sheet) {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final data = provider.getSheetData(sheet.id);
//         final count = data?.length ?? 0;

//         if (count == 0) return SizedBox.shrink();

//         return Container(
//           padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//           decoration: BoxDecoration(
//             color: (sheet.color ?? Colors.grey).withOpacity(0.15),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             count > 999
//                 ? '${(count / 1000).toStringAsFixed(1)}k'
//                 : count.toString(),
//             style: TextStyle(
//               fontSize: 9,
//               fontWeight: FontWeight.bold,
//               color: sheet.color ?? Colors.grey,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTabBarView(ReconProvider provider) {
//     if (_tabController.length != _sheets.length) {
//       // Safety check: rebuild TabController if lengths don't match
//       _tabController.dispose();
//       _tabController = TabController(length: _sheets.length, vsync: this);
//     }

//     return TabBarView(
//       controller: _tabController,
//       children: _sheets
//           .map((sheet) => _buildOptimizedSheetView(provider, sheet))
//           .toList(),
//     );
//   }

//   Widget _buildOptimizedSheetView(ReconProvider provider, SheetConfig sheet) {
//     final data = provider.getSheetData(sheet.id);

//     return Padding(
//       padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
//       child: Column(
//         children: [
//           // Compact header with quick info
//           _buildCompactSheetHeader(sheet, data),
//           SizedBox(height: 6),

//           // ✅ ADD THIS LINE - Financial Breakdown Header
//           _buildFinancialBreakdownHeader(sheet, data),

//           // Total Amount Display (your existing code)
//           if (data != null && data.isNotEmpty) _buildTotalAmountDisplay(sheet),
//           if (data != null && data.isNotEmpty) SizedBox(height: 6),

//           // Active filters row (only if filters are active)
//           if (_activeFilters[sheet.id]?.isNotEmpty == true)
//             _buildActiveFiltersRow(sheet),
//           if (_activeFilters[sheet.id]?.isNotEmpty == true) SizedBox(height: 6),

//           // Main data table - maximized height
//           Expanded(child: _buildOptimizedDataContent(provider, sheet, data)),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactSheetHeader(
//       SheetConfig sheet, List<Map<String, dynamic>>? data) {
//     final recordCount = data?.length ?? 0;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Row(
//         children: [
//           Icon(sheet.icon, color: sheet.color, size: 18),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(sheet.description,
//                 style: TextStyle(fontSize: 13, color: Colors.grey[700])),
//           ),
//           // Compact record count chip
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//             decoration: BoxDecoration(
//               color: sheet.color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               recordCount > 999
//                   ? '${(recordCount / 1000).toStringAsFixed(1)}k records'
//                   : '$recordCount records',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: sheet.color,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActiveFiltersRow(SheetConfig sheet) {
//     final activeFilters = _activeFilters[sheet.id] ?? [];

//     return Container(
//       height: 32,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: activeFilters.length + 1, // +1 for clear all button
//         separatorBuilder: (context, index) => SizedBox(width: 6),
//         itemBuilder: (context, index) {
//           if (index == activeFilters.length) {
//             // Clear all button
//             return GestureDetector(
//               onTap: () => _clearAllFilters(sheet.id),
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.red[50],
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.red[200]!),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.clear_all, size: 12, color: Colors.red[600]),
//                     SizedBox(width: 4),
//                     Text('Clear All',
//                         style: TextStyle(fontSize: 10, color: Colors.red[600])),
//                   ],
//                 ),
//               ),
//             );
//           }

//           final filter = activeFilters[index];
//           return Container(
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.blue[200]!),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(filter,
//                     style: TextStyle(fontSize: 10, color: Colors.blue[700])),
//                 SizedBox(width: 4),
//                 GestureDetector(
//                   onTap: () => _removeFilter(sheet.id, filter),
//                   child: Icon(Icons.close, size: 12, color: Colors.blue[600]),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildOptimizedDataContent(ReconProvider provider, SheetConfig sheet,
//       List<Map<String, dynamic>>? data) {
//     if (provider.isLoading) {
//       return _buildLoadingState(sheet);
//     }

//     if (data == null || data.isEmpty) {
//       return _buildEmptyState(sheet, provider);
//     }

//     final filteredData = _applyFilters(data, sheet.id);
//     final paginatedData = _getPaginatedData(filteredData, sheet.id);

//     if (filteredData.isEmpty) {
//       return _buildNoResultsState(sheet);
//     }

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         children: [
//           // Pagination info (compact)
//           if (filteredData.length > _itemsPerPage)
//             _buildCompactPaginationInfo(sheet, filteredData.length),
//           // Data table - takes remaining space
//           Expanded(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: _buildDataTableForSheet(sheet, paginatedData),
//             ),
//           ),
//           // Pagination controls (compact)
//           if (filteredData.length > _itemsPerPage)
//             _buildCompactPaginationControls(sheet, filteredData.length),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactPaginationInfo(SheetConfig sheet, int totalItems) {
//     final currentPage = _currentPage[sheet.id] ?? 0;
//     final startIndex = currentPage * _itemsPerPage + 1;
//     final endIndex = ((currentPage + 1) * _itemsPerPage).clamp(0, totalItems);

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Showing $startIndex-$endIndex of $totalItems',
//             style: TextStyle(color: Colors.grey[600], fontSize: 11),
//           ),
//           Text(
//             'Page ${currentPage + 1} of ${(totalItems / _itemsPerPage).ceil()}',
//             style: TextStyle(
//               color: sheet.color,
//               fontWeight: FontWeight.w600,
//               fontSize: 11,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactPaginationControls(SheetConfig sheet, int totalItems) {
//     final totalPages = (totalItems / _itemsPerPage).ceil();
//     final currentPage = _currentPage[sheet.id] ?? 0;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         border: Border(top: BorderSide(color: Colors.grey[200]!)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _buildPaginationButton(
//             icon: Icons.first_page,
//             enabled: currentPage > 0,
//             onPressed: () => _changePage(sheet.id, 0),
//           ),
//           _buildPaginationButton(
//             icon: Icons.chevron_left,
//             enabled: currentPage > 0,
//             onPressed: () => _changePage(sheet.id, currentPage - 1),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             child: Text(
//               '${currentPage + 1}/$totalPages',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
//             ),
//           ),
//           _buildPaginationButton(
//             icon: Icons.chevron_right,
//             enabled: currentPage < totalPages - 1,
//             onPressed: () => _changePage(sheet.id, currentPage + 1),
//           ),
//           _buildPaginationButton(
//             icon: Icons.last_page,
//             enabled: currentPage < totalPages - 1,
//             onPressed: () => _changePage(sheet.id, totalPages - 1),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaginationButton({
//     required IconData icon,
//     required bool enabled,
//     required VoidCallback onPressed,
//   }) {
//     return SizedBox(
//       width: 32,
//       height: 32,
//       child: IconButton(
//         onPressed: enabled ? onPressed : null,
//         icon: Icon(icon, size: 16),
//         padding: EdgeInsets.zero,
//         style: IconButton.styleFrom(
//           backgroundColor: enabled ? Colors.white : Colors.transparent,
//           disabledBackgroundColor: Colors.transparent,
//         ),
//       ),
//     );
//   }

//   // Floating Filter Panel
//   Widget _buildFilterFAB() {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final currentSheetIndex = _tabController.index;
//         final currentSheet = _sheets[currentSheetIndex];
//         final hasActiveFilters =
//             _activeFilters[currentSheet.id]?.isNotEmpty == true;

//         return FloatingActionButton.small(
//           onPressed: () {
//             setState(() {
//               _currentFilterSheet = currentSheet.id;
//               _showFloatingFilter = !_showFloatingFilter;
//             });
//           },
//           backgroundColor:
//               hasActiveFilters ? currentSheet.color : Colors.grey[700],
//           child: Stack(
//             children: [
//               Icon(Icons.filter_alt, size: 20, color: Colors.white),
//               if (hasActiveFilters)
//                 Positioned(
//                   right: 0,
//                   top: 0,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFloatingFilterPanel() {
//     final sheet = _sheets.firstWhere((s) => s.id == _currentFilterSheet);

//     return Positioned(
//       top: 16,
//       right: 16,
//       child: Material(
//         elevation: 8,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           width: 320,
//           constraints: BoxConstraints(maxHeight: 400),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header
//               Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: sheet.color.withOpacity(0.1),
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.filter_alt, color: sheet.color, size: 20),
//                     SizedBox(width: 8),
//                     Text('Filter ${sheet.name}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: sheet.color,
//                         )),
//                     Spacer(),
//                     IconButton(
//                       onPressed: () =>
//                           setState(() => _showFloatingFilter = false),
//                       icon: Icon(Icons.close, size: 20),
//                       padding: EdgeInsets.zero,
//                       constraints: BoxConstraints(),
//                     ),
//                   ],
//                 ),
//               ),
//               // Filter content
//               Flexible(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(16),
//                   child: _buildFloatingFilterContent(sheet),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingFilterContent(SheetConfig sheet) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Search
//         TextField(
//           controller: _searchControllers[sheet.id],
//           decoration: InputDecoration(
//             hintText: 'Search...',
//             prefixIcon: Icon(Icons.search, size: 20),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             isDense: true,
//           ),
//           onChanged: (value) => _onSearchChanged(sheet.id, value),
//         ),
//         SizedBox(height: 12),

//         // Amount range
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _minAmountControllers[sheet.id],
//                 decoration: InputDecoration(
//                   labelText: 'Min ₹',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                   isDense: true,
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => _onFilterChanged(sheet.id),
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: TextField(
//                 controller: _maxAmountControllers[sheet.id],
//                 decoration: InputDecoration(
//                   labelText: 'Max ₹',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                   isDense: true,
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => _onFilterChanged(sheet.id),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 12),

//         // Multi-Select Transaction Mode
//         _buildMultiSelectField(
//           label: 'Transaction Modes',
//           selectedItems: _selectedTransactionModesList[sheet.id] ?? [],
//           availableItems: _transactionModes,
//           onChanged: (selectedItems) {
//             setState(() {
//               _selectedTransactionModesList[sheet.id] = selectedItems;
//             });
//             _onFilterChanged(sheet.id);
//           },
//         ),
//         SizedBox(height: 12),

//         // Multi-Select Quick Status
//         _buildMultiSelectField(
//           label: 'Quick Status',
//           selectedItems: _selectedQuickStatusesList[sheet.id] ?? [],
//           availableItems: _quickStatuses,
//           onChanged: (selectedItems) {
//             setState(() {
//               _selectedQuickStatusesList[sheet.id] = selectedItems;
//             });
//             _onFilterChanged(sheet.id);
//           },
//         ),
//         SizedBox(height: 12),

//         // Remarks
//         TextField(
//           controller: _remarksControllers[sheet.id],
//           decoration: InputDecoration(
//             labelText: 'Remarks contains',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//             isDense: true,
//           ),
//           onChanged: (value) => _onFilterChanged(sheet.id),
//         ),
//         SizedBox(height: 16),

//         // Filtered Summary
//         _buildFilteredSummary(sheet),
//         SizedBox(height: 16),

//         // Action buttons
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => _clearAllFilters(sheet.id),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey[100],
//                   foregroundColor: Colors.grey[700],
//                   elevation: 0,
//                 ),
//                 child: Text('Clear All'),
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => setState(() => _showFloatingFilter = false),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: sheet.color,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: Text('Apply'),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

// // 4. Add this new method for multi-select fields
//   Widget _buildMultiSelectField({
//     required String label,
//     required List<String> selectedItems,
//     required List<String> availableItems,
//     required Function(List<String>) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//         SizedBox(height: 4),
//         Container(
//           width: double.infinity,
//           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey[400]!),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Wrap(
//             spacing: 4,
//             runSpacing: 4,
//             children: [
//               ...selectedItems.map((item) => Chip(
//                     label: Text(item, style: TextStyle(fontSize: 10)),
//                     backgroundColor: Colors.blue[100],
//                     deleteIcon: Icon(Icons.close, size: 14),
//                     onDeleted: () {
//                       final newList = List<String>.from(selectedItems);
//                       newList.remove(item);
//                       onChanged(newList);
//                     },
//                     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     padding: EdgeInsets.symmetric(horizontal: 4),
//                   )),
//               PopupMenuButton<String>(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.add, size: 14),
//                       SizedBox(width: 4),
//                       Text('Add', style: TextStyle(fontSize: 10)),
//                     ],
//                   ),
//                 ),
//                 itemBuilder: (context) => availableItems
//                     .where((item) => !selectedItems.contains(item))
//                     .map((item) => PopupMenuItem(
//                           value: item,
//                           child: Text(item, style: TextStyle(fontSize: 12)),
//                         ))
//                     .toList(),
//                 onSelected: (item) {
//                   final newList = List<String>.from(selectedItems);
//                   newList.add(item);
//                   onChanged(newList);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

// // 5. Add this new method for filtered summary
//   Widget _buildFilteredSummary(SheetConfig sheet) {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final data = provider.getSheetData(sheet.id);
//         if (data == null || data.isEmpty) {
//           return SizedBox.shrink();
//         }

//         // ✅ CHECK IF ANY FILTERS ARE ACTIVE
//         final hasActiveFilters = _hasAnyActiveFilters(sheet.id);

//         // 🚫 DON'T SHOW if no filters are applied
//         if (!hasActiveFilters) {
//           return SizedBox.shrink(); // Hide the entire filtered summary
//         }

//         // ✅ SHOW ONLY when filters are active
//         final filteredData = _applyFilters(data, sheet.id);
//         final totalAmount = _calculateTotalAmount(filteredData);

//         return Container(
//           padding: EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: sheet.color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: sheet.color.withOpacity(0.3)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Filtered Results',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: sheet.color,
//                   fontSize: 12,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Records',
//                         style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                       ),
//                       Text(
//                         '${filteredData.length}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: sheet.color,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         'Total Amount',
//                         style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                       ),
//                       Text(
//                         NumberFormat.currency(symbol: '₹', decimalDigits: 0)
//                             .format(totalAmount),
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: sheet.color,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

// // 🔧 ADD THIS NEW HELPER METHOD
// // Add this method to your DataScreen class:

//   bool _hasAnyActiveFilters(String sheetId) {
//     // Check search filter
//     final searchQuery = _searchControllers[sheetId]?.text ?? '';
//     if (searchQuery.isNotEmpty) return true;

//     // Check amount filters
//     final minAmount = _minAmountControllers[sheetId]?.text ?? '';
//     final maxAmount = _maxAmountControllers[sheetId]?.text ?? '';
//     if (minAmount.isNotEmpty || maxAmount.isNotEmpty) return true;

//     // Check remarks filter
//     final remarks = _remarksControllers[sheetId]?.text ?? '';
//     if (remarks.isNotEmpty) return true;

//     // Check transaction modes
//     final selectedModes = _selectedTransactionModesList[sheetId] ?? [];
//     if (selectedModes.isNotEmpty) return true;

//     // Check quick status
//     final selectedStatuses = _selectedQuickStatusesList[sheetId] ?? [];
//     if (selectedStatuses.isNotEmpty) return true;

//     return false; // No filters active
//   }

// // 6. Add this helper method to calculate total amount
//   double _calculateTotalAmount(List<Map<String, dynamic>> data) {
//     double total = 0.0;

//     for (var row in data) {
//       // Try different amount fields based on the sheet type
//       final amountFields = [
//         'Txn_Amount',
//         'PTPP_Payment',
//         'Cloud_Payment',
//         'sum(Txn_Amount)',
//         'PTPP_Refund',
//         'Cloud_Refund',
//         'Cloud_MRefund' // MISSING FIELD ADDED
//       ];

//       for (String field in amountFields) {
//         if (row.containsKey(field) && row[field] != null) {
//           final amount = double.tryParse(row[field].toString()) ?? 0.0;
//           total += amount;
//           break; // Only count the first valid amount field found
//         }
//       }
//     }

//     return total;
//   }

//   // Data Table Building Methods (keeping your existing implementation but optimized)
//   Widget _buildDataTableForSheet(
//       SheetConfig sheet, List<Map<String, dynamic>> data) {
//     switch (sheet.id) {
//       case 'SUMMARY':
//         return _buildSummaryTable(data);
//       case 'RAWDATA':
//         return _buildRawDataTable(data);
//       case 'RECON_SUCCESS':
//       case 'RECON_INVESTIGATE':
//       case 'MANUAL_REFUND':
//         return _buildReconTable(data, sheet);
//       default:
//         return _buildGenericTable(data);
//     }
//   }

//   Widget _buildSummaryTable(List<Map<String, dynamic>> data) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 12,
//       horizontalMargin: 12,
//       minWidth: 600,
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
//       columns: [
//         DataColumn2(
//           label: Text('Source',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Type',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Amount',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//       ],
//       rows: data
//           .map((row) => DataRow2(
//                 cells: [
//                   DataCell(
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(row['txn_source']?.toString() ?? '',
//                           style: TextStyle(fontSize: 11)),
//                     ),
//                   ),
//                   DataCell(Text(row['Txn_type']?.toString() ?? '',
//                       style: TextStyle(fontSize: 11))),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['sum(Txn_Amount)']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
//                     ),
//                   ),
//                 ],
//               ))
//           .toList(),
//     );
//   }

//   String _getShortMID(String mid) {
//     if (mid.isEmpty) return '-';

//     // VENDOLITEINDIA03 → VENDOL03
//     if (mid.startsWith('VENDOLITEINDIA')) {
//       return 'VENDOL${mid.substring(14)}';
//     }

//     // Auto refund initiated from the machine → Auto Refund
//     if (mid.toLowerCase().contains('auto')) {
//       return 'Auto Refund';
//     }

//     // If still too long, cut it
//     if (mid.length > 12) {
//       return '${mid.substring(0, 10)}..';
//     }

//     return mid;
//   }

// // 1. Updated _buildReconTable method with missing fields
// //   Widget _buildReconTable(List<Map<String, dynamic>> data, SheetConfig sheet) {
// //     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

// //     return DataTable2(
// //       columnSpacing: 6,
// //       horizontalMargin: 8,
// //       minWidth: 1200, // Increased width for additional columns
// //       headingRowHeight: 40,
// //       dataRowHeight: 36,
// //       headingRowColor: MaterialStateProperty.all(sheet.color.withOpacity(0.1)),
// //       columns: [
// //         DataColumn2(
// //           label: Text('Ref No',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.L,
// //         ),
// //         DataColumn2(
// //           label: Text('Machine',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //         ),
// //         DataColumn2(
// //           label: Text('MID',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize
// //               .L, // Changed from ColumnSize.M to ColumnSize.L for more space
// //         ),
// //         DataColumn2(
// //           label: Text('PTPP Pay',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //           numeric: true,
// //         ),
// //         DataColumn2(
// //           label: Text('PTPP Ref',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //           numeric: true,
// //         ),
// //         DataColumn2(
// //           label: Text('Cloud Pay',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //           numeric: true,
// //         ),
// //         DataColumn2(
// //           label: Text('Cloud Ref',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //           numeric: true,
// //         ),
// //         DataColumn2(
// //           label: Text('Cloud Manual', // MISSING FIELD ADDED
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //           numeric: true,
// //         ),
// //         DataColumn2(
// //           label: Text('Remarks',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.M,
// //         ),
// //       ],
// //       rows: data
// //           .map((row) => DataRow2(
// //                 cells: [
// //                   DataCell(
// //                     SelectableText(
// //                       row['Txn_RefNo']?.toString() ?? '',
// //                       style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
// //                     ),
// //                   ),
// //                   DataCell(Text(row['Txn_Machine']?.toString() ?? '',
// //                       style: TextStyle(fontSize: 10))),
// //                   DataCell(
// //                     Container(
// //                       width: double.infinity, // Take full available width
// //                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
// //                       decoration: BoxDecoration(
// //                         color: _getMIDColor(row['Txn_MID']?.toString()),
// //                         borderRadius: BorderRadius.circular(6),
// //                       ),
// //                       child: Text(
// //                         row['Txn_MID']?.toString() ??
// //                             '-', // Show full MID without truncation
// //                         style: TextStyle(
// //                           fontSize: 10,
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                         overflow: TextOverflow
// //                             .visible, // Allow text to wrap or expand
// //                         softWrap: true, // Enable text wrapping
// //                       ),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     Text(
// //                       currencyFormat.format(
// //                         double.tryParse(
// //                                 row['PTPP_Payment']?.toString() ?? '0') ??
// //                             0,
// //                       ),
// //                       style:
// //                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     Text(
// //                       currencyFormat.format(
// //                         double.tryParse(
// //                                 row['PTPP_Refund']?.toString() ?? '0') ??
// //                             0,
// //                       ),
// //                       style:
// //                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     Text(
// //                       currencyFormat.format(
// //                         double.tryParse(
// //                                 row['Cloud_Payment']?.toString() ?? '0') ??
// //                             0,
// //                       ),
// //                       style:
// //                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     Text(
// //                       currencyFormat.format(
// //                         double.tryParse(
// //                                 row['Cloud_Refund']?.toString() ?? '0') ??
// //                             0,
// //                       ),
// //                       style:
// //                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     // MISSING FIELD ADDED
// //                     Text(
// //                       currencyFormat.format(
// //                         double.tryParse(
// //                                 row['Cloud_MRefund']?.toString() ?? '0') ??
// //                             0,
// //                       ),
// //                       style: TextStyle(
// //                         fontSize: 10,
// //                         fontWeight: FontWeight.w600,
// //                         color: (double.tryParse(
// //                                         row['Cloud_MRefund']?.toString() ??
// //                                             '0') ??
// //                                     0) !=
// //                                 0
// //                             ? Colors.red[700]
// //                             : null,
// //                       ),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     Container(
// //                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //                       decoration: BoxDecoration(
// //                         color:
// //                             _getRemarksColor(row['Remarks']?.toString() ?? ''),
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: Text(
// //                         row['Remarks']?.toString() ?? '',
// //                         style: TextStyle(
// //                           fontSize: 9,
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ))
// //           .toList(),
// //     );
// //   }

// // // 2. Updated _buildRawDataTable method with missing fields
// //   Widget _buildRawDataTable(List<Map<String, dynamic>> data) {
// //     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
// //     final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

// //     return DataTable2(
// //       columnSpacing: 8,
// //       horizontalMargin: 8,
// //       minWidth: 1200, // Increased width for additional columns
// //       headingRowHeight: 40,
// //       dataRowHeight: 36,
// //       headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
// //       columns: [
// //         DataColumn2(
// //           label: Text('Ref No',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.L,
// //         ),
// //         DataColumn2(
// //           label: Text('Source',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //         ),
// //         DataColumn2(
// //           label: Text('Type',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //         ),
// //         DataColumn2(
// //           label: Text('Machine',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //         ),
// //         DataColumn2(
// //           label: Text('MID',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.L, // Changed from ColumnSize.M to ColumnSize.L
// //         ),
// //         DataColumn2(
// //           label: Text('Date', // MISSING FIELD ADDED
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.M,
// //         ),
// //         DataColumn2(
// //           label: Text('Amount',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //           numeric: true,
// //         ),
// //       ],
// //       rows: data
// //           .map((row) => DataRow2(
// //                 cells: [
// //                   DataCell(
// //                     SelectableText(
// //                       row['Txn_RefNo']?.toString() ?? '',
// //                       style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     Container(
// //                       padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
// //                       decoration: BoxDecoration(
// //                         color: _getSourceColor(row['Txn_Source']?.toString()),
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: Text(
// //                         row['Txn_Source']?.toString() ?? '',
// //                         style: TextStyle(fontSize: 9, color: Colors.white),
// //                       ),
// //                     ),
// //                   ),
// //                   DataCell(Text(row['Txn_Type']?.toString() ?? '',
// //                       style: TextStyle(fontSize: 10))),
// //                   DataCell(Text(row['Txn_Machine']?.toString() ?? '',
// //                       style: TextStyle(fontSize: 10))),
// //                   DataCell(
// //                     Container(
// //                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //                       decoration: BoxDecoration(
// //                         color: Colors.grey[100],
// //                         borderRadius: BorderRadius.circular(4),
// //                       ),
// //                       child: Text(
// //                         _getShortMID(row['Txn_MID']?.toString() ?? ''),
// //                         style: TextStyle(
// //                           fontSize: 10,
// //                           color: Colors.grey[800],
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                         overflow: TextOverflow.ellipsis,
// //                         maxLines: 1,
// //                       ),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     // MISSING FIELD ADDED
// //                     Text(
// //                       _formatDate(row['Txn_Date']?.toString() ?? ''),
// //                       style: TextStyle(fontSize: 10),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     Text(
// //                       currencyFormat.format(
// //                         double.tryParse(row['Txn_Amount']?.toString() ?? '0') ??
// //                             0,
// //                       ),
// //                       style:
// //                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
// //                     ),
// //                   ),
// //                 ],
// //               ))
// //           .toList(),
// //     );
// //   }

// //2newly updated that included the txn source

//   Widget _buildRawDataTable(List<Map<String, dynamic>> data) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 8,
//       horizontalMargin: 12,
//       minWidth: 900, // Increased width to accommodate Txn_Source column
//       headingRowHeight: 56,
//       dataRowHeight: 48,
//       headingRowColor: MaterialStateProperty.all(Colors.green[50]),
//       columns: [
//         // NEW: Add Txn_Source column first
//         DataColumn2(
//           label: Text('Source', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Machine', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('MID', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//         ),
//         DataColumn2(
//           label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//         ),
//         DataColumn2(
//           label: Text('Ref No', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//       ],
//       rows: data.map((row) {
//         return DataRow2(
//           cells: [
//             // NEW: Display Txn_Source with color coding
//             DataCell(
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: _getSourceColor(row['Txn_Source']?.toString() ?? ''),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   row['Txn_Source']?.toString() ?? '',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//             DataCell(Text(row['Txn_Machine']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(row['Txn_MID']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(row['Txn_Type']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(row['Txn_Date']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(row['Txn_RefNo']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(
//                 currencyFormat.format(
//                     double.tryParse(row['Txn_Amount']?.toString() ?? '0') ?? 0),
//                 style: TextStyle(fontSize: 12))),
//             DataCell(
//               PopupMenuButton<String>(
//                 icon: Icon(Icons.more_vert),
//                 onSelected: (value) => _handleRowAction(context, row, value),
//                 itemBuilder: (context) => [
//                   PopupMenuItem(
//                     value: 'copy',
//                     child: Row(
//                       children: [
//                         Icon(Icons.copy, size: 16),
//                         SizedBox(width: 8),
//                         Text('Copy Ref No'),
//                       ],
//                     ),
//                   ),
//                   PopupMenuItem(
//                     value: 'details',
//                     child: Row(
//                       children: [
//                         Icon(Icons.info, size: 16),
//                         SizedBox(width: 8),
//                         Text('View Details'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       }).toList(),
//     );
//   }

// // 2. UPDATE: _buildReconTable method in lib/data_screen.dart
//   Widget _buildReconTable(List<Map<String, dynamic>> data, SheetConfig sheet) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 8,
//       horizontalMargin: 12,
//       minWidth: 1200, // Increased width to accommodate Txn_Source column
//       headingRowHeight: 56,
//       dataRowHeight: 48,
//       headingRowColor: MaterialStateProperty.all(Colors.purple[50]),
//       columns: [
//         DataColumn2(
//           label: Text('Ref No', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.L,
//         ),
//         // NEW: Add Txn_Source column
//         DataColumn2(
//           label: Text('Source', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Machine', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('MID', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//         ),
//         DataColumn2(
//           label:
//               Text('PTPP Pay', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//         DataColumn2(
//           label:
//               Text('PTPP Ref', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//         DataColumn2(
//           label:
//               Text('Cloud Pay', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//         DataColumn2(
//           label:
//               Text('Cloud Ref', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//         ),
//         DataColumn2(
//           label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//       ],
//       rows: data.map((row) {
//         return DataRow2(
//           cells: [
//             DataCell(Text(row['Txn_RefNo']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             // NEW: Display Txn_Source with color coding
//             DataCell(
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: _getSourceColor(row['Txn_Source']?.toString() ?? ''),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   row['Txn_Source']?.toString() ?? '',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//             DataCell(Text(row['Txn_Machine']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(row['Txn_MID']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(
//                 currencyFormat.format(
//                     double.tryParse(row['PTPP_Payment']?.toString() ?? '0') ??
//                         0),
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(
//                 currencyFormat.format(
//                     double.tryParse(row['PTPP_Refund']?.toString() ?? '0') ??
//                         0),
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(
//                 currencyFormat.format(
//                     double.tryParse(row['Cloud_Payment']?.toString() ?? '0') ??
//                         0),
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(
//                 currencyFormat.format(
//                     double.tryParse(row['Cloud_Refund']?.toString() ?? '0') ??
//                         0),
//                 style: TextStyle(fontSize: 12))),
//             DataCell(
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: _getRemarksColor(row['Remarks']?.toString() ?? ''),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   row['Remarks']?.toString() ?? '',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//             DataCell(
//               PopupMenuButton<String>(
//                 icon: Icon(Icons.more_vert),
//                 onSelected: (value) => _handleRowAction(context, row, value),
//                 itemBuilder: (context) => [
//                   PopupMenuItem(
//                     value: 'copy',
//                     child: Row(
//                       children: [
//                         Icon(Icons.copy, size: 16),
//                         SizedBox(width: 8),
//                         Text('Copy Ref No'),
//                       ],
//                     ),
//                   ),
//                   PopupMenuItem(
//                     value: 'details',
//                     child: Row(
//                       children: [
//                         Icon(Icons.info, size: 16),
//                         SizedBox(width: 8),
//                         Text('View Details'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       }).toList(),
//     );
//   }

// // 3. NEW: Add color coding method for transaction sources
//   Color _getSourceColor(String source) {
//     switch (source.toLowerCase()) {
//       case 'paytm':
//         return Colors.blue;
//       case 'phonepe':
//         return Colors.purple;
//       case 'cloud':
//         return Colors.green;
//       case 'manual':
//         return Colors.orange;
//       case 'unknown':
//         return Colors.grey;
//       default:
//         return Colors.blueGrey;
//     }
//   }

//   void _showTransactionDetails(BuildContext context, Map<String, dynamic> row) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             Text('Transaction Details'),
//             Spacer(),
//             // NEW: Show transaction source prominently in dialog title
//             if (row['Txn_Source'] != null)
//               Chip(
//                 label: Text(
//                   row['Txn_Source'].toString(),
//                   style: TextStyle(color: Colors.white, fontSize: 12),
//                 ),
//                 backgroundColor: _getSourceColor(row['Txn_Source'].toString()),
//               ),
//           ],
//         ),
//         content: Container(
//           width: double.maxFinite,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // NEW: Highlight transaction source first
//                 if (row['Txn_Source'] != null) ...[
//                   _buildDetailRow('Transaction Source', row['Txn_Source'],
//                       highlight: true),
//                   Divider(),
//                 ],
//                 _buildDetailRow('Reference Number', row['Txn_RefNo']),
//                 _buildDetailRow('Machine', row['Txn_Machine']),
//                 _buildDetailRow('MID', row['Txn_MID']),
//                 if (row['Txn_Type'] != null)
//                   _buildDetailRow('Type', row['Txn_Type']),
//                 if (row['Txn_Date'] != null)
//                   _buildDetailRow('Date', row['Txn_Date']),
//                 if (row['Txn_Amount'] != null)
//                   _buildDetailRow('Amount', row['Txn_Amount']),
//                 if (row['PTPP_Payment'] != null)
//                   _buildDetailRow('PTPP Payment', row['PTPP_Payment']),
//                 if (row['PTPP_Refund'] != null)
//                   _buildDetailRow('PTPP Refund', row['PTPP_Refund']),
//                 if (row['Cloud_Payment'] != null)
//                   _buildDetailRow('Cloud Payment', row['Cloud_Payment']),
//                 if (row['Cloud_Refund'] != null)
//                   _buildDetailRow('Cloud Refund', row['Cloud_Refund']),
//                 if (row['Cloud_MRefund'] != null)
//                   _buildDetailRow('Cloud Manual Refund', row['Cloud_MRefund']),
//                 if (row['Remarks'] != null)
//                   _buildDetailRow('Remarks', row['Remarks']),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('Close'),
//           ),
//           // NEW: Add button to copy transaction source
//           if (row['Txn_Source'] != null)
//             TextButton(
//               onPressed: () {
//                 Clipboard.setData(
//                     ClipboardData(text: row['Txn_Source'].toString()));
//                 Navigator.of(context).pop();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                       content: Text('Transaction source copied to clipboard')),
//                 );
//               },
//               child: Text('Copy Source'),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransactionSourceFilter(SheetConfig sheet) {
//     final sources = ['All', 'PayTM', 'PhonePe', 'Cloud', 'Manual', 'Unknown'];

//     return DropdownButtonFormField<String>(
//       value: _selectedTransactionSources[sheet.id] ?? 'All',
//       decoration: InputDecoration(
//         labelText: 'Transaction Source',
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         isDense: true,
//       ),
//       items: sources
//           .map((source) => DropdownMenuItem(
//                 value: source,
//                 child: Text(source),
//               ))
//           .toList(),
//       onChanged: (value) {
//         setState(() {
//           _selectedTransactionSources[sheet.id] = value!;
//         });
//         _onFilterChanged(sheet.id);
//       },
//     );
//   }

// // 5. NEW: Helper method for building detail rows with highlighting
//   Widget _buildDetailRow(String label, dynamic value,
//       {bool highlight = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 140,
//             child: Text(
//               '$label:',
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: highlight ? Colors.blue : null,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Container(
//               padding: highlight
//                   ? EdgeInsets.symmetric(horizontal: 8, vertical: 2)
//                   : null,
//               decoration: highlight
//                   ? BoxDecoration(
//                       color: Colors.blue.shade50,
//                       borderRadius: BorderRadius.circular(4),
//                     )
//                   : null,
//               child: Text(
//                 value?.toString() ?? 'N/A',
//                 style: TextStyle(
//                   fontWeight: highlight ? FontWeight.w600 : null,
//                   color: highlight ? Colors.blue.shade700 : null,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGenericTable(List<Map<String, dynamic>> data) {
//     if (data.isEmpty) return Center(child: Text('No data available'));

//     final columns = data.first.keys.take(6).toList();

//     return DataTable2(
//       columnSpacing: 12,
//       horizontalMargin: 12,
//       minWidth: columns.length * 120.0,
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
//       columns: columns
//           .map((column) => DataColumn2(
//                 label: Text(column,
//                     style:
//                         TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//                 size: ColumnSize.M,
//               ))
//           .toList(),
//       rows: data
//           .map((row) => DataRow2(
//                 cells: columns
//                     .map((column) => DataCell(
//                           Text(
//                             _formatCellValue(row[column]),
//                             style: TextStyle(fontSize: 10),
//                           ),
//                         ))
//                     .toList(),
//               ))
//           .toList(),
//     );
//   }

//   // Loading and Error States
//   Widget _buildLoadingState(SheetConfig sheet) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(color: sheet.color, strokeWidth: 2),
//           SizedBox(height: 12),
//           Text('Loading ${sheet.name.toLowerCase()}...',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//         ],
//       ),
//     );
//   }

// // Helper method to get MID color coding
//   Color _getMIDColor(String? mid) {
//     if (mid == null || mid.isEmpty) return Colors.grey[400]!;

//     final midLower = mid.toLowerCase();
//     if (midLower.contains('vendol')) {
//       return Colors.indigo[600]!;
//     } else if (midLower.contains('india')) {
//       return Colors.teal[600]!;
//     } else if (midLower.contains('auto') || midLower.contains('manual')) {
//       return Colors.orange[600]!;
//     }
//     return Colors.blue[600]!;
//   }

// // Helper method to format date display
//   String _formatDate(String dateStr) {
//     if (dateStr.isEmpty) return '-';

//     try {
//       // Handle different date formats that might come from Excel
//       DateTime? date;

//       // Try parsing common Excel date formats
//       if (dateStr.contains('-')) {
//         date = DateTime.tryParse(dateStr);
//       } else if (dateStr.length == 8) {
//         // Handle YYYYMMDD format
//         final year = int.tryParse(dateStr.substring(0, 4));
//         final month = int.tryParse(dateStr.substring(4, 6));
//         final day = int.tryParse(dateStr.substring(6, 8));
//         if (year != null && month != null && day != null) {
//           date = DateTime(year, month, day);
//         }
//       }

//       if (date != null) {
//         return DateFormat('MMM dd, yy').format(date);
//       }

//       // If parsing fails, return truncated string
//       return dateStr.length > 12 ? '${dateStr.substring(0, 12)}...' : dateStr;
//     } catch (e) {
//       return dateStr.length > 12 ? '${dateStr.substring(0, 12)}...' : dateStr;
//     }
//   }

//   Widget _buildEmptyState(SheetConfig sheet, ReconProvider provider) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(40),
//             ),
//             child:
//                 Icon(Icons.inbox_outlined, size: 40, color: Colors.grey[400]),
//           ),
//           SizedBox(height: 12),
//           Text('No data available',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           SizedBox(height: 6),
//           Text('No records found for ${sheet.name}',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//           SizedBox(height: 12),
//           ElevatedButton.icon(
//             onPressed: () => provider.loadSheet(sheet.id),
//             icon: Icon(Icons.refresh, size: 16),
//             label: Text('Reload Data'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: sheet.color,
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoResultsState(SheetConfig sheet) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.orange[50],
//               borderRadius: BorderRadius.circular(40),
//             ),
//             child: Icon(Icons.search_off, size: 40, color: Colors.orange[400]),
//           ),
//           SizedBox(height: 12),
//           Text('No results found',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           SizedBox(height: 6),
//           Text('Try adjusting your filters or search criteria',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//           SizedBox(height: 12),
//           TextButton.icon(
//             onPressed: () => _clearAllFilters(sheet.id),
//             icon: Icon(Icons.clear_all, size: 16),
//             label: Text('Clear All Filters'),
//           ),
//         ],
//       ),
//     );
//   }

//   Map<String, double> _calculateFinancialBreakdown(
//       List<Map<String, dynamic>> data) {
//     double ptppPayment = 0.0;
//     double ptppRefund = 0.0;
//     double cloudPayment = 0.0;
//     double cloudRefund = 0.0;
//     double cloudManualRefund = 0.0;

//     for (var row in data) {
//       ptppPayment +=
//           double.tryParse(row['PTPP_Payment']?.toString() ?? '0') ?? 0.0;
//       ptppRefund +=
//           double.tryParse(row['PTPP_Refund']?.toString() ?? '0') ?? 0.0;
//       cloudPayment +=
//           double.tryParse(row['Cloud_Payment']?.toString() ?? '0') ?? 0.0;
//       cloudRefund +=
//           double.tryParse(row['Cloud_Refund']?.toString() ?? '0') ?? 0.0;
//       cloudManualRefund +=
//           double.tryParse(row['Cloud_MRefund']?.toString() ?? '0') ?? 0.0;
//     }

//     return {
//       'ptpp_payment': ptppPayment,
//       'ptpp_refund': ptppRefund,
//       'total_ptpp': ptppPayment + ptppRefund,
//       'cloud_payment': cloudPayment,
//       'cloud_refund': cloudRefund,
//       'cloud_manual_refund': cloudManualRefund,
//       'total_cloud': cloudPayment + cloudRefund + cloudManualRefund,
//     };
//   }

// // 4. Add this new widget method
//   Widget _buildFinancialBreakdownHeader(
//       SheetConfig sheet, List<Map<String, dynamic>>? data) {
//     // Only show for reconciliation sheets
//     if (!['RECON_SUCCESS', 'RECON_INVESTIGATE', 'MANUAL_REFUND']
//         .contains(sheet.id)) {
//       return SizedBox.shrink();
//     }

//     if (data == null || data.isEmpty) {
//       return SizedBox.shrink();
//     }

//     final breakdown = _calculateFinancialBreakdown(data);
//     final isExpanded = _isFinancialBreakdownExpanded[sheet.id] ?? false;

//     return Container(
//       margin: EdgeInsets.only(bottom: 6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         children: [
//           // Compact Header - Always Visible
//           InkWell(
//             onTap: () {
//               setState(() {
//                 _isFinancialBreakdownExpanded[sheet.id] = !isExpanded;
//               });
//             },
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.account_balance_wallet_outlined,
//                     size: 16,
//                     color: sheet.color,
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     'Financial Summary',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   // Quick totals in compact view
//                   if (!isExpanded) ...[
//                     _buildQuickTotal(
//                         'PTPP', breakdown['total_ptpp']!, Colors.blue),
//                     SizedBox(width: 6),
//                     _buildQuickTotal(
//                         'Cloud', breakdown['total_cloud']!, Colors.green),
//                   ],
//                   Spacer(),
//                   Icon(
//                     isExpanded ? Icons.expand_less : Icons.expand_more,
//                     size: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Expandable Details
//           if (isExpanded)
//             Container(
//               padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//                 borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
//               ),
//               child: Row(
//                 children: [
//                   // PTPP Breakdown
//                   Expanded(
//                     child: _buildBreakdownSection(
//                       'PTPP',
//                       Colors.blue,
//                       [
//                         {
//                           'label': 'Payment',
//                           'value': breakdown['ptpp_payment']!
//                         },
//                         {'label': 'Refund', 'value': breakdown['ptpp_refund']!},
//                       ],
//                       breakdown['total_ptpp']!,
//                     ),
//                   ),

//                   Container(
//                     width: 1,
//                     height: 60,
//                     color: Colors.grey[300],
//                     margin: EdgeInsets.symmetric(horizontal: 12),
//                   ),

//                   // Cloud Breakdown
//                   Expanded(
//                     child: _buildBreakdownSection(
//                       'Cloud',
//                       Colors.green,
//                       [
//                         {
//                           'label': 'Payment',
//                           'value': breakdown['cloud_payment']!
//                         },
//                         {
//                           'label': 'Refund',
//                           'value': breakdown['cloud_refund']!
//                         },
//                         {
//                           'label': 'Manual',
//                           'value': breakdown['cloud_manual_refund']!
//                         },
//                       ],
//                       breakdown['total_cloud']!,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

// // 5. Add helper widgets
//   Widget _buildQuickTotal(String label, double amount, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Text(
//         '$label: ${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(amount)}',
//         style: TextStyle(
//           fontSize: 9,
//           fontWeight: FontWeight.w600,
//           color: color,
//         ),
//       ),
//     );
//   }

//   Widget _buildBreakdownSection(String title, Color color,
//       List<Map<String, dynamic>> items, double total) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Section Title
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         SizedBox(height: 4),

//         // Individual Items
//         ...items.map((item) => Padding(
//               padding: EdgeInsets.only(bottom: 2),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     item['label'],
//                     style: TextStyle(fontSize: 9, color: Colors.grey[600]),
//                   ),
//                   Text(
//                     NumberFormat.currency(symbol: '₹', decimalDigits: 0)
//                         .format(item['value']),
//                     style: TextStyle(
//                       fontSize: 9,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey[800],
//                     ),
//                   ),
//                 ],
//               ),
//             )),

//         // Divider
//         Container(
//           height: 1,
//           color: color.withOpacity(0.3),
//           margin: EdgeInsets.symmetric(vertical: 3),
//         ),

//         // Total
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Total',
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             Text(
//               NumberFormat.currency(symbol: '₹', decimalDigits: 0)
//                   .format(total),
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // Helper Methods
//   Color _getRemarksColor(String remarks) {
//     switch (remarks.toLowerCase()) {
//       case 'perfect':
//         return Colors.green[600]!;
//       case 'investigate':
//         return Colors.orange[600]!;
//       case 'manual':
//         return Colors.purple[600]!;
//       default:
//         return Colors.blue[600]!;
//     }
//   }

//   // Color _getSourceColor(String? source) {
//   //   switch (source?.toLowerCase()) {
//   //     case 'paytm':
//   //       return Colors.blue[600]!;
//   //     case 'phonepe':
//   //       return Colors.purple[600]!;
//   //     case 'cloud':
//   //       return Colors.green[600]!;
//   //     case 'ptpp':
//   //       return Colors.orange[600]!;
//   //     default:
//   //       return Colors.grey[600]!;
//   //   }
//   // }

//   String _formatCellValue(dynamic value) {
//     if (value == null) return '';
//     if (value is num && value > 1000) {
//       return NumberFormat('#,##0.00').format(value);
//     }
//     return value.toString();
//   }

//   int _getTotalRecords(ReconProvider provider) {
//     int total = 0;
//     for (String sheetId in [
//       'SUMMARY',
//       'RAWDATA',
//       'RECON_SUCCESS',
//       'RECON_INVESTIGATE',
//       'MANUAL_REFUND'
//     ]) {
//       final data = provider.getSheetData(sheetId);
//       if (data != null) total += data.length;
//     }
//     return total;
//   }

//   int _getSuccessRate(ReconProvider provider) {
//     final successData = provider.getSheetData('RECON_SUCCESS');
//     final investigateData = provider.getSheetData('RECON_INVESTIGATE');
//     final totalRecon =
//         (successData?.length ?? 0) + (investigateData?.length ?? 0);

//     if (totalRecon == 0) return 0;
//     return ((successData?.length ?? 0) * 100 / totalRecon).round();
//   }

//   // List<Map<String, dynamic>> _applyFilters(
//   //     List<Map<String, dynamic>> data, String sheetId) {
//   //   final searchQuery = _searchControllers[sheetId]?.text.toLowerCase() ?? '';
//   //   final minAmount =
//   //       double.tryParse(_minAmountControllers[sheetId]?.text ?? '');
//   //   final maxAmount =
//   //       double.tryParse(_maxAmountControllers[sheetId]?.text ?? '');
//   //   final remarksFilter =
//   //       _remarksControllers[sheetId]?.text.toLowerCase() ?? '';
//   //   final modeFilter = _selectedTransactionModes[sheetId] ?? 'All';
//   //   final statusFilter = _selectedQuickStatuses[sheetId] ?? 'All';

//   //   return data.where((row) {
//   //     // Search filter
//   //     if (searchQuery.isNotEmpty) {
//   //       bool matchesSearch = row.values.any((value) =>
//   //           value?.toString().toLowerCase().contains(searchQuery) ?? false);
//   //       if (!matchesSearch) return false;
//   //     }

//   //     // Amount range filter
//   //     if (minAmount != null || maxAmount != null) {
//   //       final amount = _getAmountFromRow(row);
//   //       if (amount != null) {
//   //         if (minAmount != null && amount < minAmount) return false;
//   //         if (maxAmount != null && amount > maxAmount) return false;
//   //       }
//   //     }

//   //     // Remarks filter
//   //     if (remarksFilter.isNotEmpty) {
//   //       final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//   //       if (!remarks.contains(remarksFilter)) return false;
//   //     }

//   //     // Transaction mode filter
//   //     if (modeFilter != 'All') {
//   //       final source = row['Txn_Source']?.toString() ?? '';
//   //       if (!source.toLowerCase().contains(modeFilter.toLowerCase()))
//   //         return false;
//   //     }

//   //     // Quick status filter
//   //     if (statusFilter != 'All') {
//   //       final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//   //       if (!remarks.contains(statusFilter.toLowerCase())) return false;
//   //     }

//   //     return true;
//   //   }).toList();
//   // }

//   List<Map<String, dynamic>> _applyFilters(
//       List<Map<String, dynamic>> data, String sheetId) {
//     final searchQuery = _searchControllers[sheetId]?.text.toLowerCase() ?? '';
//     final minAmount =
//         double.tryParse(_minAmountControllers[sheetId]?.text ?? '');
//     final maxAmount =
//         double.tryParse(_maxAmountControllers[sheetId]?.text ?? '');
//     final remarksFilter =
//         _remarksControllers[sheetId]?.text.toLowerCase() ?? '';

//     // Updated to use multi-select lists
//     final selectedModes = _selectedTransactionModesList[sheetId] ?? [];
//     final selectedStatuses = _selectedQuickStatusesList[sheetId] ?? [];

//     // Calculate total amount for all records (before filtering)
//     _totalAmounts[sheetId] = _calculateTotalAmountForSheet(data, sheetId);

//     final filteredData = data.where((row) {
//       // Search filter
//       if (searchQuery.isNotEmpty) {
//         bool matchesSearch = row.values.any((value) =>
//             value?.toString().toLowerCase().contains(searchQuery) ?? false);
//         if (!matchesSearch) return false;
//       }

//       // Amount range filter
//       if (minAmount != null || maxAmount != null) {
//         final amount = _getAmountFromRow(row);
//         if (amount != null) {
//           if (minAmount != null && amount < minAmount) return false;
//           if (maxAmount != null && amount > maxAmount) return false;
//         }
//       }

//       // Remarks filter
//       if (remarksFilter.isNotEmpty) {
//         final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//         if (!remarks.contains(remarksFilter)) return false;
//       }

//       // Multi-select transaction mode filter
//       if (selectedModes.isNotEmpty) {
//         final source = row['Txn_Source']?.toString() ?? '';
//         bool matchesMode = selectedModes
//             .any((mode) => source.toLowerCase().contains(mode.toLowerCase()));
//         if (!matchesMode) return false;
//       }

//       // Multi-select status filter
//       if (selectedStatuses.isNotEmpty) {
//         final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//         bool matchesStatus = selectedStatuses
//             .any((status) => remarks.contains(status.toLowerCase()));
//         if (!matchesStatus) return false;
//       }

//       return true;
//     }).toList();

//     // Calculate filtered totals
//     _filteredAmounts[sheetId] =
//         _calculateTotalAmountForSheet(filteredData, sheetId);
//     _filteredCounts[sheetId] = filteredData.length;

//     return filteredData;
//   }

//   double _calculateTotalAmountForSheet(
//       List<Map<String, dynamic>> data, String sheetId) {
//     double total = 0.0;

//     for (var row in data) {
//       switch (sheetId) {
//         case 'SUMMARY':
//           // For summary, use sum(Txn_Amount)
//           final amount =
//               double.tryParse(row['sum(Txn_Amount)']?.toString() ?? '0') ?? 0.0;
//           total += amount;
//           break;

//         case 'RAWDATA':
//           // For raw data, use Txn_Amount
//           final amount =
//               double.tryParse(row['Txn_Amount']?.toString() ?? '0') ?? 0.0;
//           total += amount;
//           break;

//         case 'RECON_SUCCESS':
//         case 'RECON_INVESTIGATE':
//         case 'MANUAL_REFUND':
//           // For reconciliation tabs, sum positive amounts only
//           final ptppPay =
//               double.tryParse(row['PTPP_Payment']?.toString() ?? '0') ?? 0.0;
//           final cloudPay =
//               double.tryParse(row['Cloud_Payment']?.toString() ?? '0') ?? 0.0;
//           final cloudMRef =
//               double.tryParse(row['Cloud_MRefund']?.toString() ?? '0') ?? 0.0;

//           if (sheetId == 'MANUAL_REFUND') {
//             total += cloudMRef; // Focus on manual refunds
//           } else {
//             total +=
//                 (ptppPay + cloudPay); // Focus on payments for other recon tabs
//           }
//           break;

//         default:
//           // Fallback to generic amount detection
//           final amount = _getAmountFromRow(row) ?? 0.0;
//           total += amount;
//       }
//     }

//     return total;
//   }

//   Widget _buildTotalAmountDisplay(SheetConfig sheet) {
//     final totalAmount = _totalAmounts[sheet.id] ?? 0.0;
//     final filteredAmount = _filteredAmounts[sheet.id] ?? 0.0;
//     final filteredCount = _filteredCounts[sheet.id] ?? 0;
//     final hasFilters = _activeFilters[sheet.id]?.isNotEmpty == true;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: sheet.color.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: sheet.color.withOpacity(0.2)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Total Records Display
//           Row(
//             children: [
//               Icon(Icons.receipt_long, size: 14, color: sheet.color),
//               SizedBox(width: 4),
//               Text(
//                 hasFilters
//                     ? 'Filtered: $filteredCount records'
//                     : 'Total: ${(_totalAmounts[sheet.id] != null ? _filteredCounts[sheet.id] ?? 0 : 0)} records',
//                 style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey[700],
//                 ),
//               ),
//             ],
//           ),
//           // Amount Display
//           Row(
//             children: [
//               Icon(Icons.currency_rupee, size: 14, color: sheet.color),
//               SizedBox(width: 4),
//               Text(
//                 hasFilters
//                     ? NumberFormat.currency(symbol: '₹', decimalDigits: 0)
//                         .format(filteredAmount)
//                     : NumberFormat.currency(symbol: '₹', decimalDigits: 0)
//                         .format(totalAmount),
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: sheet.color,
//                 ),
//               ),
//               if (hasFilters) ...[
//                 SizedBox(width: 4),
//                 Text(
//                   'of ${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(totalAmount)}',
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   double? _getAmountFromRow(Map<String, dynamic> row) {
//     final amountFields = [
//       'Txn_Amount',
//       'PTPP_Payment',
//       'Cloud_Payment',
//       'sum(Txn_Amount)'
//     ];

//     for (String field in amountFields) {
//       if (row.containsKey(field)) {
//         return double.tryParse(row[field]?.toString() ?? '0');
//       }
//     }
//     return null;
//   }

//   List<Map<String, dynamic>> _getPaginatedData(
//       List<Map<String, dynamic>> data, String sheetId) {
//     final startIndex = (_currentPage[sheetId] ?? 0) * _itemsPerPage;
//     final endIndex = (startIndex + _itemsPerPage).clamp(0, data.length);
//     return data.sublist(startIndex, endIndex);
//   }

//   void _onSearchChanged(String sheetId, String value) {
//     setState(() {
//       _currentPage[sheetId] = 0;
//     });
//     _updateActiveFilters(sheetId);
//   }

//   void _onFilterChanged(String sheetId) {
//     setState(() {
//       _currentPage[sheetId] = 0;
//     });
//     _updateActiveFilters(sheetId);
//   }

//   // void _updateActiveFilters(String sheetId) {
//   //   List<String> filters = [];

//   //   final searchQuery = _searchControllers[sheetId]?.text ?? '';
//   //   if (searchQuery.isNotEmpty) {
//   //     filters.add('Search: "$searchQuery"');
//   //   }

//   //   final minAmount = _minAmountControllers[sheetId]?.text ?? '';
//   //   final maxAmount = _maxAmountControllers[sheetId]?.text ?? '';
//   //   if (minAmount.isNotEmpty || maxAmount.isNotEmpty) {
//   //     filters.add('Amount: ₹$minAmount - ₹$maxAmount');
//   //   }

//   //   final remarks = _remarksControllers[sheetId]?.text ?? '';
//   //   if (remarks.isNotEmpty) {
//   //     filters.add('Remarks: "$remarks"');
//   //   }

//   //   final mode = _selectedTransactionModes[sheetId] ?? 'All';
//   //   if (mode != 'All') {
//   //     filters.add('Mode: $mode');
//   //   }

//   //   final status = _selectedQuickStatuses[sheetId] ?? 'All';
//   //   if (status != 'All') {
//   //     filters.add('Status: $status');
//   //   }

//   //   setState(() {
//   //     _activeFilters[sheetId] = filters;
//   //   });
//   // }

//   void _updateActiveFilters(String sheetId) {
//     List<String> filters = [];

//     final searchQuery = _searchControllers[sheetId]?.text ?? '';
//     if (searchQuery.isNotEmpty) {
//       filters.add('Search: "$searchQuery"');
//     }

//     final minAmount = _minAmountControllers[sheetId]?.text ?? '';
//     final maxAmount = _maxAmountControllers[sheetId]?.text ?? '';
//     if (minAmount.isNotEmpty || maxAmount.isNotEmpty) {
//       filters.add('Amount: ₹$minAmount - ₹$maxAmount');
//     }

//     final remarks = _remarksControllers[sheetId]?.text ?? '';
//     if (remarks.isNotEmpty) {
//       filters.add('Remarks: "$remarks"');
//     }

//     // Updated for multi-select
//     final selectedModes = _selectedTransactionModesList[sheetId] ?? [];
//     if (selectedModes.isNotEmpty) {
//       filters.add('Modes: ${selectedModes.join(", ")}');
//     }

//     final selectedStatuses = _selectedQuickStatusesList[sheetId] ?? [];
//     if (selectedStatuses.isNotEmpty) {
//       filters.add('Status: ${selectedStatuses.join(", ")}');
//     }

//     setState(() {
//       _activeFilters[sheetId] = filters;
//     });
//   }

//   void _removeFilter(String sheetId, String filter) {
//     if (filter.startsWith('Search:')) {
//       _searchControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Amount:')) {
//       _minAmountControllers[sheetId]?.clear();
//       _maxAmountControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Remarks:')) {
//       _remarksControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Modes:')) {
//       _selectedTransactionModesList[sheetId] = [];
//     } else if (filter.startsWith('Status:')) {
//       _selectedQuickStatusesList[sheetId] = [];
//     }

//     _onFilterChanged(sheetId);
//   }

//   void _clearAllFilters(String sheetId) {
//     setState(() {
//       _searchControllers[sheetId]?.clear();
//       _minAmountControllers[sheetId]?.clear();
//       _maxAmountControllers[sheetId]?.clear();
//       _remarksControllers[sheetId]?.clear();
//       _selectedTransactionModes[sheetId] = 'All'; // Keep existing single select
//       _selectedQuickStatuses[sheetId] = 'All'; // Keep existing single select

//       // Clear new multi-select lists
//       _selectedTransactionModesList[sheetId] = [];
//       _selectedQuickStatusesList[sheetId] = [];

//       _currentPage[sheetId] = 0;
//       _activeFilters[sheetId] = [];
//     });
//   }

//   void _changePage(String sheetId, int newPage) {
//     setState(() {
//       _currentPage[sheetId] = newPage;
//     });
//   }
// }

// class SheetConfig {
//   final String id;
//   final String name;
//   final IconData icon;
//   final String description;
//   final Color color;

//   SheetConfig(this.id, this.name, this.icon, this.description, this.color);
// }

// // Add these extension methods at the bottom of the file for null safety
// extension SafeColor on Color? {
//   Color get safe => this ?? Colors.grey;
// }

// extension SafeColorWithOpacity on Color {
//   Color safeWithOpacity(double opacity) {
//     try {
//       return this.withOpacity(opacity);
//     } catch (e) {
//       return Colors.grey.withOpacity(opacity);
//     }
//   }
// }

//6

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:data_table_2/data_table_2.dart';
// import 'package:intl/intl.dart';
// import 'ReconProvider.dart';
// import 'package:flutter/services.dart';

// class DataScreen extends StatefulWidget {
//   @override
//   _DataScreenState createState() => _DataScreenState();
// }

// class _DataScreenState extends State<DataScreen>
//     with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
//   late TabController _tabController;
//   late AnimationController _filterAnimationController;
//   late Animation<double> _filterAnimation;

//   // Search and filter controllers
//   final Map<String, TextEditingController> _searchControllers = {};
//   final Map<String, TextEditingController> _minAmountControllers = {};
//   final Map<String, TextEditingController> _maxAmountControllers = {};
//   final Map<String, TextEditingController> _remarksControllers = {};
//   final Map<String, String> _selectedTransactionModes = {};
//   final Map<String, String> _selectedQuickStatuses = {};
//   final Map<String, bool> _isFilterExpanded = {};

//   Map<String, String> _selectedTransactionSources = {};

//   final Map<String, List<String>> _selectedTransactionModesList = {};
//   final Map<String, List<String>> _selectedQuickStatusesList = {};

//   final Map<String, double> _totalAmounts = {}; // Store total amounts per sheet
//   final Map<String, double> _filteredAmounts =
//       {}; // Store filtered amounts per sheet
//   final Map<String, int> _filteredCounts = {};

// // Available options for multi-select
//   final List<String> _transactionModes = [
//     'Paytm',
//     'PhonePe',
//     'Cloud',
//     'PTPP',
//     'Manual'
//   ];
//   final List<String> _quickStatuses = ['Perfect', 'Investigate', 'Manual'];

//   // Pagination
//   final Map<String, int> _currentPage = {};
//   final int _itemsPerPage = 100; // Increased for better performance

//   // Active filters tracking
//   final Map<String, List<String>> _activeFilters = {};
//   final Map<String, bool> _isFinancialBreakdownExpanded = {};
//   // Floating filter panel
//   bool _showFloatingFilter = false;
//   String _currentFilterSheet = '';

//   final List<SheetConfig> _sheets = [
//     SheetConfig('SUMMARY', 'Summary', Icons.dashboard_outlined,
//         'Summary overview', Colors.blue),
//     SheetConfig('RECON_SUCCESS', 'Perfect', Icons.check_circle_outline,
//         'Successfully reconciled', Colors.green),
//     SheetConfig('RECON_INVESTIGATE', 'Investigate', Icons.warning_outlined,
//         'Require investigation', Colors.orange),
//     SheetConfig('MANUAL_REFUND', 'Manual', Icons.edit_outlined,
//         'Manual refunds', Colors.purple),
//     SheetConfig('RAWDATA', 'Raw Data', Icons.table_rows_outlined,
//         'All raw data', Colors.grey),
//   ];

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize TabController FIRST with correct length
//     _tabController = TabController(length: _sheets.length, vsync: this);

//     _filterAnimationController = AnimationController(
//       duration: Duration(milliseconds: 250),
//       vsync: this,
//     );
//     _filterAnimation = CurvedAnimation(
//       parent: _filterAnimationController,
//       curve: Curves.easeInOut,
//     );

//     // Initialize controllers for each sheet
//     for (var sheet in _sheets) {
//       _searchControllers[sheet.id] = TextEditingController();
//       _minAmountControllers[sheet.id] = TextEditingController();
//       _maxAmountControllers[sheet.id] = TextEditingController();
//       _remarksControllers[sheet.id] = TextEditingController();
//       _selectedTransactionModes[sheet.id] = 'All';
//       _selectedQuickStatuses[sheet.id] = 'All';
//       _isFilterExpanded[sheet.id] = false;
//       _currentPage[sheet.id] = 0;
//       _activeFilters[sheet.id] = [];
//       _selectedTransactionModesList[sheet.id] = [];
//       _selectedQuickStatusesList[sheet.id] = [];

//       _totalAmounts[sheet.id] = 0.0;
//       _filteredAmounts[sheet.id] = 0.0;
//       _filteredCounts[sheet.id] = 0;

//       _isFinancialBreakdownExpanded[sheet.id] = false;
//     }

//     // Load initial data
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ReconProvider>(context, listen: false).loadAllSheets();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _filterAnimationController.dispose();
//     _searchControllers.values.forEach((controller) => controller.dispose());
//     _minAmountControllers.values.forEach((controller) => controller.dispose());
//     _maxAmountControllers.values.forEach((controller) => controller.dispose());
//     _remarksControllers.values.forEach((controller) => controller.dispose());
//     super.dispose();
//   }

//   void _handleRowAction(
//       BuildContext context, Map<String, dynamic> row, String action) {
//     switch (action) {
//       case 'copy':
//         Clipboard.setData(
//             ClipboardData(text: row['Txn_RefNo']?.toString() ?? ''));
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Reference number copied to clipboard')),
//         );
//         break;
//       case 'details':
//         _showTransactionDetails(context, row);
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         return Scaffold(
//           backgroundColor: Colors.grey[50],
//           appBar: _buildCompactAppBar(provider),
//           body: Stack(
//             children: [
//               Column(
//                 children: [
//                   if (provider.error != null) _buildErrorBanner(provider),
//                   if (provider.isLoading) _buildLoadingIndicator(),
//                   _buildEnhancedTabBar(),
//                   Expanded(child: _buildTabBarView(provider)),
//                 ],
//               ),
//               // Floating Filter Panel
//               if (_showFloatingFilter) _buildFloatingFilterPanel(),
//             ],
//           ),
//           floatingActionButton: _buildFilterFAB(),
//           floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
//         );
//       },
//     );
//   }

//   PreferredSizeWidget _buildCompactAppBar(ReconProvider provider) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black87,
//       toolbarHeight: 60,
//       title: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: Colors.blue[100],
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Icon(Icons.analytics_outlined,
//                 color: Colors.blue[700], size: 20),
//           ),
//           SizedBox(width: 8),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Reconciliation Dashboard',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//               Text('Real-time analysis',
//                   style: TextStyle(fontSize: 11, color: Colors.grey[600])),
//             ],
//           ),
//         ],
//       ),
//       actions: [
//         _buildCompactStatsRow(provider),
//         SizedBox(width: 8),
//         IconButton(
//           onPressed: provider.isLoading ? null : () => provider.loadAllSheets(),
//           icon: Icon(Icons.refresh, size: 20),
//           tooltip: 'Refresh Data',
//         ),
//         SizedBox(width: 8),
//       ],
//     );
//   }

//   Widget _buildCompactStatsRow(ReconProvider provider) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _buildCompactStatChip(
//             'Records', _getTotalRecords(provider).toString(), Colors.blue),
//         SizedBox(width: 6),
//         _buildCompactStatChip(
//             'Success', '${_getSuccessRate(provider)}%', Colors.green),
//       ],
//     );
//   }

//   Widget _buildCompactStatChip(String label, String value, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3), width: 0.5),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(value,
//               style: TextStyle(
//                   fontSize: 12, fontWeight: FontWeight.bold, color: color)),
//           Text(label, style: TextStyle(fontSize: 9, color: color)),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorBanner(ReconProvider provider) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       color: Colors.red[50],
//       child: Row(
//         children: [
//           Icon(Icons.error_outline, color: Colors.red[700], size: 16),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(provider.error!,
//                 style: TextStyle(color: Colors.red[700], fontSize: 12)),
//           ),
//           IconButton(
//             onPressed: () => provider.clearError(),
//             icon: Icon(Icons.close, size: 16, color: Colors.red[700]),
//             padding: EdgeInsets.zero,
//             constraints: BoxConstraints(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingIndicator() {
//     return Container(
//       height: 2,
//       child: LinearProgressIndicator(
//         backgroundColor: Colors.grey[200],
//         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
//       ),
//     );
//   }

//   Widget _buildEnhancedTabBar() {
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.symmetric(horizontal: 8),
//       child: TabBar(
//         controller: _tabController,
//         isScrollable: true,
//         labelColor: Colors.blue[700] ?? Colors.blue,
//         unselectedLabelColor: Colors.grey[600] ?? Colors.grey,
//         indicatorColor: Colors.blue[600] ?? Colors.blue,
//         indicatorWeight: 2,
//         labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//         unselectedLabelStyle:
//             TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
//         onTap: (index) {
//           if (index < _sheets.length) {
//             _currentFilterSheet = _sheets[index].id;
//           }
//         },
//         tabs: _sheets
//             .map((sheet) => Tab(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(sheet.icon, size: 16, color: sheet.color),
//                         SizedBox(width: 6),
//                         Text(sheet.name),
//                         SizedBox(width: 6),
//                         _buildRecordCountBadge(sheet),
//                       ],
//                     ),
//                   ),
//                 ))
//             .toList(),
//       ),
//     );
//   }

//   Widget _buildRecordCountBadge(SheetConfig sheet) {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final data = provider.getSheetData(sheet.id);
//         final count = data?.length ?? 0;

//         if (count == 0) return SizedBox.shrink();

//         return Container(
//           padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//           decoration: BoxDecoration(
//             color: (sheet.color ?? Colors.grey).withOpacity(0.15),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             count > 999
//                 ? '${(count / 1000).toStringAsFixed(1)}k'
//                 : count.toString(),
//             style: TextStyle(
//               fontSize: 9,
//               fontWeight: FontWeight.bold,
//               color: sheet.color ?? Colors.grey,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTabBarView(ReconProvider provider) {
//     if (_tabController.length != _sheets.length) {
//       // Safety check: rebuild TabController if lengths don't match
//       _tabController.dispose();
//       _tabController = TabController(length: _sheets.length, vsync: this);
//     }

//     return TabBarView(
//       controller: _tabController,
//       children: _sheets
//           .map((sheet) => _buildOptimizedSheetView(provider, sheet))
//           .toList(),
//     );
//   }

//   Widget _buildOptimizedSheetView(ReconProvider provider, SheetConfig sheet) {
//     final data = provider.getSheetData(sheet.id);

//     return Padding(
//       padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
//       child: Column(
//         children: [
//           // Compact header with quick info
//           _buildCompactSheetHeader(sheet, data),
//           SizedBox(height: 6),

//           // ✅ ADD THIS LINE - Financial Breakdown Header
//           _buildFinancialBreakdownHeader(sheet, data),

//           // Total Amount Display (your existing code)
//           if (data != null && data.isNotEmpty) _buildTotalAmountDisplay(sheet),
//           if (data != null && data.isNotEmpty) SizedBox(height: 6),

//           // Active filters row (only if filters are active)
//           if (_activeFilters[sheet.id]?.isNotEmpty == true)
//             _buildActiveFiltersRow(sheet),
//           if (_activeFilters[sheet.id]?.isNotEmpty == true) SizedBox(height: 6),

//           // Main data table - maximized height
//           Expanded(child: _buildOptimizedDataContent(provider, sheet, data)),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactSheetHeader(
//       SheetConfig sheet, List<Map<String, dynamic>>? data) {
//     final recordCount = data?.length ?? 0;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Row(
//         children: [
//           Icon(sheet.icon, color: sheet.color, size: 18),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(sheet.description,
//                 style: TextStyle(fontSize: 13, color: Colors.grey[700])),
//           ),
//           // Compact record count chip
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//             decoration: BoxDecoration(
//               color: sheet.color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               recordCount > 999
//                   ? '${(recordCount / 1000).toStringAsFixed(1)}k records'
//                   : '$recordCount records',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: sheet.color,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActiveFiltersRow(SheetConfig sheet) {
//     final activeFilters = _activeFilters[sheet.id] ?? [];

//     return Container(
//       height: 32,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: activeFilters.length + 1, // +1 for clear all button
//         separatorBuilder: (context, index) => SizedBox(width: 6),
//         itemBuilder: (context, index) {
//           if (index == activeFilters.length) {
//             // Clear all button
//             return GestureDetector(
//               onTap: () => _clearAllFilters(sheet.id),
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.red[50],
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.red[200]!),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.clear_all, size: 12, color: Colors.red[600]),
//                     SizedBox(width: 4),
//                     Text('Clear All',
//                         style: TextStyle(fontSize: 10, color: Colors.red[600])),
//                   ],
//                 ),
//               ),
//             );
//           }

//           final filter = activeFilters[index];
//           return Container(
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.blue[200]!),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(filter,
//                     style: TextStyle(fontSize: 10, color: Colors.blue[700])),
//                 SizedBox(width: 4),
//                 GestureDetector(
//                   onTap: () => _removeFilter(sheet.id, filter),
//                   child: Icon(Icons.close, size: 12, color: Colors.blue[600]),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildOptimizedDataContent(ReconProvider provider, SheetConfig sheet,
//       List<Map<String, dynamic>>? data) {
//     if (provider.isLoading) {
//       return _buildLoadingState(sheet);
//     }

//     if (data == null || data.isEmpty) {
//       return _buildEmptyState(sheet, provider);
//     }

//     final filteredData = _applyFilters(data, sheet.id);
//     final paginatedData = _getPaginatedData(filteredData, sheet.id);

//     if (filteredData.isEmpty) {
//       return _buildNoResultsState(sheet);
//     }

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         children: [
//           // Pagination info (compact)
//           if (filteredData.length > _itemsPerPage)
//             _buildCompactPaginationInfo(sheet, filteredData.length),
//           // Data table - takes remaining space
//           Expanded(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: _buildDataTableForSheet(sheet, paginatedData),
//             ),
//           ),
//           // Pagination controls (compact)
//           if (filteredData.length > _itemsPerPage)
//             _buildCompactPaginationControls(sheet, filteredData.length),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactPaginationInfo(SheetConfig sheet, int totalItems) {
//     final currentPage = _currentPage[sheet.id] ?? 0;
//     final startIndex = currentPage * _itemsPerPage + 1;
//     final endIndex = ((currentPage + 1) * _itemsPerPage).clamp(0, totalItems);

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Showing $startIndex-$endIndex of $totalItems',
//             style: TextStyle(color: Colors.grey[600], fontSize: 11),
//           ),
//           Text(
//             'Page ${currentPage + 1} of ${(totalItems / _itemsPerPage).ceil()}',
//             style: TextStyle(
//               color: sheet.color,
//               fontWeight: FontWeight.w600,
//               fontSize: 11,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactPaginationControls(SheetConfig sheet, int totalItems) {
//     final totalPages = (totalItems / _itemsPerPage).ceil();
//     final currentPage = _currentPage[sheet.id] ?? 0;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         border: Border(top: BorderSide(color: Colors.grey[200]!)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _buildPaginationButton(
//             icon: Icons.first_page,
//             enabled: currentPage > 0,
//             onPressed: () => _changePage(sheet.id, 0),
//           ),
//           _buildPaginationButton(
//             icon: Icons.chevron_left,
//             enabled: currentPage > 0,
//             onPressed: () => _changePage(sheet.id, currentPage - 1),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             child: Text(
//               '${currentPage + 1}/$totalPages',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
//             ),
//           ),
//           _buildPaginationButton(
//             icon: Icons.chevron_right,
//             enabled: currentPage < totalPages - 1,
//             onPressed: () => _changePage(sheet.id, currentPage + 1),
//           ),
//           _buildPaginationButton(
//             icon: Icons.last_page,
//             enabled: currentPage < totalPages - 1,
//             onPressed: () => _changePage(sheet.id, totalPages - 1),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaginationButton({
//     required IconData icon,
//     required bool enabled,
//     required VoidCallback onPressed,
//   }) {
//     return SizedBox(
//       width: 32,
//       height: 32,
//       child: IconButton(
//         onPressed: enabled ? onPressed : null,
//         icon: Icon(icon, size: 16),
//         padding: EdgeInsets.zero,
//         style: IconButton.styleFrom(
//           backgroundColor: enabled ? Colors.white : Colors.transparent,
//           disabledBackgroundColor: Colors.transparent,
//         ),
//       ),
//     );
//   }

//   // Floating Filter Panel
//   Widget _buildFilterFAB() {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final currentSheetIndex = _tabController.index;
//         final currentSheet = _sheets[currentSheetIndex];
//         final hasActiveFilters =
//             _activeFilters[currentSheet.id]?.isNotEmpty == true;

//         return FloatingActionButton.small(
//           onPressed: () {
//             setState(() {
//               _currentFilterSheet = currentSheet.id;
//               _showFloatingFilter = !_showFloatingFilter;
//             });
//           },
//           backgroundColor:
//               hasActiveFilters ? currentSheet.color : Colors.grey[700],
//           child: Stack(
//             children: [
//               Icon(Icons.filter_alt, size: 20, color: Colors.white),
//               if (hasActiveFilters)
//                 Positioned(
//                   right: 0,
//                   top: 0,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFloatingFilterPanel() {
//     final sheet = _sheets.firstWhere((s) => s.id == _currentFilterSheet);

//     return Positioned(
//       top: 16,
//       right: 16,
//       child: Material(
//         elevation: 8,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           width: 320,
//           constraints: BoxConstraints(maxHeight: 400),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header
//               Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: sheet.color.withOpacity(0.1),
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.filter_alt, color: sheet.color, size: 20),
//                     SizedBox(width: 8),
//                     Text('Filter ${sheet.name}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: sheet.color,
//                         )),
//                     Spacer(),
//                     IconButton(
//                       onPressed: () =>
//                           setState(() => _showFloatingFilter = false),
//                       icon: Icon(Icons.close, size: 20),
//                       padding: EdgeInsets.zero,
//                       constraints: BoxConstraints(),
//                     ),
//                   ],
//                 ),
//               ),
//               // Filter content
//               Flexible(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(16),
//                   child: _buildFloatingFilterContent(sheet),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingFilterContent(SheetConfig sheet) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Search
//         TextField(
//           controller: _searchControllers[sheet.id],
//           decoration: InputDecoration(
//             hintText: 'Search...',
//             prefixIcon: Icon(Icons.search, size: 20),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             isDense: true,
//           ),
//           onChanged: (value) => _onSearchChanged(sheet.id, value),
//         ),
//         SizedBox(height: 12),

//         // Amount range
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _minAmountControllers[sheet.id],
//                 decoration: InputDecoration(
//                   labelText: 'Min ₹',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                   isDense: true,
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => _onFilterChanged(sheet.id),
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: TextField(
//                 controller: _maxAmountControllers[sheet.id],
//                 decoration: InputDecoration(
//                   labelText: 'Max ₹',
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                   isDense: true,
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => _onFilterChanged(sheet.id),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 12),

//         // Multi-Select Transaction Mode
//         _buildMultiSelectField(
//           label: 'Transaction Modes',
//           selectedItems: _selectedTransactionModesList[sheet.id] ?? [],
//           availableItems: _transactionModes,
//           onChanged: (selectedItems) {
//             setState(() {
//               _selectedTransactionModesList[sheet.id] = selectedItems;
//             });
//             _onFilterChanged(sheet.id);
//           },
//         ),
//         SizedBox(height: 12),

//         // Multi-Select Quick Status
//         _buildMultiSelectField(
//           label: 'Quick Status',
//           selectedItems: _selectedQuickStatusesList[sheet.id] ?? [],
//           availableItems: _quickStatuses,
//           onChanged: (selectedItems) {
//             setState(() {
//               _selectedQuickStatusesList[sheet.id] = selectedItems;
//             });
//             _onFilterChanged(sheet.id);
//           },
//         ),
//         SizedBox(height: 12),

//         // Remarks
//         TextField(
//           controller: _remarksControllers[sheet.id],
//           decoration: InputDecoration(
//             labelText: 'Remarks contains',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//             isDense: true,
//           ),
//           onChanged: (value) => _onFilterChanged(sheet.id),
//         ),
//         SizedBox(height: 16),

//         // Filtered Summary
//         _buildFilteredSummary(sheet),
//         SizedBox(height: 16),

//         // Action buttons
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => _clearAllFilters(sheet.id),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey[100],
//                   foregroundColor: Colors.grey[700],
//                   elevation: 0,
//                 ),
//                 child: Text('Clear All'),
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => setState(() => _showFloatingFilter = false),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: sheet.color,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: Text('Apply'),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

// // 4. Add this new method for multi-select fields
//   Widget _buildMultiSelectField({
//     required String label,
//     required List<String> selectedItems,
//     required List<String> availableItems,
//     required Function(List<String>) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//         SizedBox(height: 4),
//         Container(
//           width: double.infinity,
//           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey[400]!),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Wrap(
//             spacing: 4,
//             runSpacing: 4,
//             children: [
//               ...selectedItems.map((item) => Chip(
//                     label: Text(item, style: TextStyle(fontSize: 10)),
//                     backgroundColor: Colors.blue[100],
//                     deleteIcon: Icon(Icons.close, size: 14),
//                     onDeleted: () {
//                       final newList = List<String>.from(selectedItems);
//                       newList.remove(item);
//                       onChanged(newList);
//                     },
//                     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     padding: EdgeInsets.symmetric(horizontal: 4),
//                   )),
//               PopupMenuButton<String>(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.add, size: 14),
//                       SizedBox(width: 4),
//                       Text('Add', style: TextStyle(fontSize: 10)),
//                     ],
//                   ),
//                 ),
//                 itemBuilder: (context) => availableItems
//                     .where((item) => !selectedItems.contains(item))
//                     .map((item) => PopupMenuItem(
//                           value: item,
//                           child: Text(item, style: TextStyle(fontSize: 12)),
//                         ))
//                     .toList(),
//                 onSelected: (item) {
//                   final newList = List<String>.from(selectedItems);
//                   newList.add(item);
//                   onChanged(newList);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

// // 5. Add this new method for filtered summary
//   Widget _buildFilteredSummary(SheetConfig sheet) {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final data = provider.getSheetData(sheet.id);
//         if (data == null || data.isEmpty) {
//           return SizedBox.shrink();
//         }

//         // ✅ CHECK IF ANY FILTERS ARE ACTIVE
//         final hasActiveFilters = _hasAnyActiveFilters(sheet.id);

//         // 🚫 DON'T SHOW if no filters are applied
//         if (!hasActiveFilters) {
//           return SizedBox.shrink(); // Hide the entire filtered summary
//         }

//         // ✅ SHOW ONLY when filters are active
//         final filteredData = _applyFilters(data, sheet.id);
//         final totalAmount = _calculateTotalAmount(filteredData);

//         return Container(
//           padding: EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: sheet.color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: sheet.color.withOpacity(0.3)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Filtered Results',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: sheet.color,
//                   fontSize: 12,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Records',
//                         style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                       ),
//                       Text(
//                         '${filteredData.length}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: sheet.color,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         'Total Amount',
//                         style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                       ),
//                       Text(
//                         NumberFormat.currency(symbol: '₹', decimalDigits: 0)
//                             .format(totalAmount),
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: sheet.color,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

// // 🔧 ADD THIS NEW HELPER METHOD
// // Add this method to your DataScreen class:

//   bool _hasAnyActiveFilters(String sheetId) {
//     // Check search filter
//     final searchQuery = _searchControllers[sheetId]?.text ?? '';
//     if (searchQuery.isNotEmpty) return true;

//     // Check amount filters
//     final minAmount = _minAmountControllers[sheetId]?.text ?? '';
//     final maxAmount = _maxAmountControllers[sheetId]?.text ?? '';
//     if (minAmount.isNotEmpty || maxAmount.isNotEmpty) return true;

//     // Check remarks filter
//     final remarks = _remarksControllers[sheetId]?.text ?? '';
//     if (remarks.isNotEmpty) return true;

//     // Check transaction modes
//     final selectedModes = _selectedTransactionModesList[sheetId] ?? [];
//     if (selectedModes.isNotEmpty) return true;

//     // Check quick status
//     final selectedStatuses = _selectedQuickStatusesList[sheetId] ?? [];
//     if (selectedStatuses.isNotEmpty) return true;

//     return false; // No filters active
//   }

// // 6. Add this helper method to calculate total amount
//   double _calculateTotalAmount(List<Map<String, dynamic>> data) {
//     double total = 0.0;

//     for (var row in data) {
//       // Try different amount fields based on the sheet type
//       final amountFields = [
//         'Txn_Amount',
//         'PTPP_Payment',
//         'Cloud_Payment',
//         'sum(Txn_Amount)',
//         'PTPP_Refund',
//         'Cloud_Refund',
//         'Cloud_MRefund' // MISSING FIELD ADDED
//       ];

//       for (String field in amountFields) {
//         if (row.containsKey(field) && row[field] != null) {
//           final amount = double.tryParse(row[field].toString()) ?? 0.0;
//           total += amount;
//           break; // Only count the first valid amount field found
//         }
//       }
//     }

//     return total;
//   }

//   // Data Table Building Methods (keeping your existing implementation but optimized)
//   Widget _buildDataTableForSheet(
//       SheetConfig sheet, List<Map<String, dynamic>> data) {
//     switch (sheet.id) {
//       case 'SUMMARY':
//         return _buildSummaryTable(data);
//       case 'RAWDATA':
//         return _buildRawDataTable(data);
//       case 'RECON_SUCCESS':
//       case 'RECON_INVESTIGATE':
//       case 'MANUAL_REFUND':
//         return _buildReconTable(data, sheet);
//       default:
//         return _buildGenericTable(data);
//     }
//   }

//   Widget _buildSummaryTable(List<Map<String, dynamic>> data) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 12,
//       horizontalMargin: 12,
//       minWidth: 600,
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
//       columns: [
//         DataColumn2(
//           label: Text('Source',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Type',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Amount',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//       ],
//       rows: data
//           .map((row) => DataRow2(
//                 cells: [
//                   DataCell(
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(row['txn_source']?.toString() ?? '',
//                           style: TextStyle(fontSize: 11)),
//                     ),
//                   ),
//                   DataCell(Text(row['Txn_type']?.toString() ?? '',
//                       style: TextStyle(fontSize: 11))),
//                   DataCell(
//                     Text(
//                       currencyFormat.format(
//                         double.tryParse(
//                                 row['sum(Txn_Amount)']?.toString() ?? '0') ??
//                             0,
//                       ),
//                       style:
//                           TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
//                     ),
//                   ),
//                 ],
//               ))
//           .toList(),
//     );
//   }

//   String _getShortMID(String mid) {
//     if (mid.isEmpty) return '-';

//     // VENDOLITEINDIA03 → VENDOL03
//     if (mid.startsWith('VENDOLITEINDIA')) {
//       return 'VENDOL${mid.substring(14)}';
//     }

//     // Auto refund initiated from the machine → Auto Refund
//     if (mid.toLowerCase().contains('auto')) {
//       return 'Auto Refund';
//     }

//     // If still too long, cut it
//     if (mid.length > 12) {
//       return '${mid.substring(0, 10)}..';
//     }

//     return mid;
//   }

// // 1. Updated _buildReconTable method with missing fields
// //   Widget _buildReconTable(List<Map<String, dynamic>> data, SheetConfig sheet) {
// //     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

// //     return DataTable2(
// //       columnSpacing: 6,
// //       horizontalMargin: 8,
// //       minWidth: 1200, // Increased width for additional columns
// //       headingRowHeight: 40,
// //       dataRowHeight: 36,
// //       headingRowColor: MaterialStateProperty.all(sheet.color.withOpacity(0.1)),
// //       columns: [
// //         DataColumn2(
// //           label: Text('Ref No',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.L,
// //         ),
// //         DataColumn2(
// //           label: Text('Machine',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //         ),
// //         DataColumn2(
// //           label: Text('MID',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize
// //               .L, // Changed from ColumnSize.M to ColumnSize.L for more space
// //         ),
// //         DataColumn2(
// //           label: Text('PTPP Pay',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //           numeric: true,
// //         ),
// //         DataColumn2(
// //           label: Text('PTPP Ref',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //           numeric: true,
// //         ),
// //         DataColumn2(
// //           label: Text('Cloud Pay',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //           numeric: true,
// //         ),
// //         DataColumn2(
// //           label: Text('Cloud Ref',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //           numeric: true,
// //         ),
// //         DataColumn2(
// //           label: Text('Cloud Manual', // MISSING FIELD ADDED
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //           numeric: true,
// //         ),
// //         DataColumn2(
// //           label: Text('Remarks',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.M,
// //         ),
// //       ],
// //       rows: data
// //           .map((row) => DataRow2(
// //                 cells: [
// //                   DataCell(
// //                     SelectableText(
// //                       row['Txn_RefNo']?.toString() ?? '',
// //                       style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
// //                     ),
// //                   ),
// //                   DataCell(Text(row['Txn_Machine']?.toString() ?? '',
// //                       style: TextStyle(fontSize: 10))),
// //                   DataCell(
// //                     Container(
// //                       width: double.infinity, // Take full available width
// //                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
// //                       decoration: BoxDecoration(
// //                         color: _getMIDColor(row['Txn_MID']?.toString()),
// //                         borderRadius: BorderRadius.circular(6),
// //                       ),
// //                       child: Text(
// //                         row['Txn_MID']?.toString() ??
// //                             '-', // Show full MID without truncation
// //                         style: TextStyle(
// //                           fontSize: 10,
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                         overflow: TextOverflow
// //                             .visible, // Allow text to wrap or expand
// //                         softWrap: true, // Enable text wrapping
// //                       ),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     Text(
// //                       currencyFormat.format(
// //                         double.tryParse(
// //                                 row['PTPP_Payment']?.toString() ?? '0') ??
// //                             0,
// //                       ),
// //                       style:
// //                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     Text(
// //                       currencyFormat.format(
// //                         double.tryParse(
// //                                 row['PTPP_Refund']?.toString() ?? '0') ??
// //                             0,
// //                       ),
// //                       style:
// //                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     Text(
// //                       currencyFormat.format(
// //                         double.tryParse(
// //                                 row['Cloud_Payment']?.toString() ?? '0') ??
// //                             0,
// //                       ),
// //                       style:
// //                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     Text(
// //                       currencyFormat.format(
// //                         double.tryParse(
// //                                 row['Cloud_Refund']?.toString() ?? '0') ??
// //                             0,
// //                       ),
// //                       style:
// //                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     // MISSING FIELD ADDED
// //                     Text(
// //                       currencyFormat.format(
// //                         double.tryParse(
// //                                 row['Cloud_MRefund']?.toString() ?? '0') ??
// //                             0,
// //                       ),
// //                       style: TextStyle(
// //                         fontSize: 10,
// //                         fontWeight: FontWeight.w600,
// //                         color: (double.tryParse(
// //                                         row['Cloud_MRefund']?.toString() ??
// //                                             '0') ??
// //                                     0) !=
// //                                 0
// //                             ? Colors.red[700]
// //                             : null,
// //                       ),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     Container(
// //                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //                       decoration: BoxDecoration(
// //                         color:
// //                             _getRemarksColor(row['Remarks']?.toString() ?? ''),
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: Text(
// //                         row['Remarks']?.toString() ?? '',
// //                         style: TextStyle(
// //                           fontSize: 9,
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ))
// //           .toList(),
// //     );
// //   }

// // // 2. Updated _buildRawDataTable method with missing fields
// //   Widget _buildRawDataTable(List<Map<String, dynamic>> data) {
// //     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
// //     final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

// //     return DataTable2(
// //       columnSpacing: 8,
// //       horizontalMargin: 8,
// //       minWidth: 1200, // Increased width for additional columns
// //       headingRowHeight: 40,
// //       dataRowHeight: 36,
// //       headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
// //       columns: [
// //         DataColumn2(
// //           label: Text('Ref No',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.L,
// //         ),
// //         DataColumn2(
// //           label: Text('Source',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //         ),
// //         DataColumn2(
// //           label: Text('Type',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //         ),
// //         DataColumn2(
// //           label: Text('Machine',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //         ),
// //         DataColumn2(
// //           label: Text('MID',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.L, // Changed from ColumnSize.M to ColumnSize.L
// //         ),
// //         DataColumn2(
// //           label: Text('Date', // MISSING FIELD ADDED
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.M,
// //         ),
// //         DataColumn2(
// //           label: Text('Amount',
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //           size: ColumnSize.S,
// //           numeric: true,
// //         ),
// //       ],
// //       rows: data
// //           .map((row) => DataRow2(
// //                 cells: [
// //                   DataCell(
// //                     SelectableText(
// //                       row['Txn_RefNo']?.toString() ?? '',
// //                       style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     Container(
// //                       padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
// //                       decoration: BoxDecoration(
// //                         color: _getSourceColor(row['Txn_Source']?.toString()),
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: Text(
// //                         row['Txn_Source']?.toString() ?? '',
// //                         style: TextStyle(fontSize: 9, color: Colors.white),
// //                       ),
// //                     ),
// //                   ),
// //                   DataCell(Text(row['Txn_Type']?.toString() ?? '',
// //                       style: TextStyle(fontSize: 10))),
// //                   DataCell(Text(row['Txn_Machine']?.toString() ?? '',
// //                       style: TextStyle(fontSize: 10))),
// //                   DataCell(
// //                     Container(
// //                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //                       decoration: BoxDecoration(
// //                         color: Colors.grey[100],
// //                         borderRadius: BorderRadius.circular(4),
// //                       ),
// //                       child: Text(
// //                         _getShortMID(row['Txn_MID']?.toString() ?? ''),
// //                         style: TextStyle(
// //                           fontSize: 10,
// //                           color: Colors.grey[800],
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                         overflow: TextOverflow.ellipsis,
// //                         maxLines: 1,
// //                       ),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     // MISSING FIELD ADDED
// //                     Text(
// //                       _formatDate(row['Txn_Date']?.toString() ?? ''),
// //                       style: TextStyle(fontSize: 10),
// //                     ),
// //                   ),
// //                   DataCell(
// //                     Text(
// //                       currencyFormat.format(
// //                         double.tryParse(row['Txn_Amount']?.toString() ?? '0') ??
// //                             0,
// //                       ),
// //                       style:
// //                           TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
// //                     ),
// //                   ),
// //                 ],
// //               ))
// //           .toList(),
// //     );
// //   }

// //2newly updated that included the txn source

//   Widget _buildRawDataTable(List<Map<String, dynamic>> data) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 8,
//       horizontalMargin: 12,
//       minWidth: 900, // Increased width to accommodate Txn_Source column
//       headingRowHeight: 56,
//       dataRowHeight: 48,
//       headingRowColor: MaterialStateProperty.all(Colors.green[50]),
//       columns: [
//         // NEW: Add Txn_Source column first
//         DataColumn2(
//           label: Text('Source', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Machine', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('MID', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//         ),
//         DataColumn2(
//           label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//         ),
//         DataColumn2(
//           label: Text('Ref No', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.L,
//         ),
//         DataColumn2(
//           label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//       ],
//       rows: data.map((row) {
//         return DataRow2(
//           cells: [
//             // NEW: Display Txn_Source with color coding
//             DataCell(
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: _getSourceColor(row['Txn_Source']?.toString() ?? ''),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   row['Txn_Source']?.toString() ?? '',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//             DataCell(Text(row['Txn_Machine']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(row['Txn_MID']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(row['Txn_Type']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(row['Txn_Date']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(row['Txn_RefNo']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(
//                 currencyFormat.format(
//                     double.tryParse(row['Txn_Amount']?.toString() ?? '0') ?? 0),
//                 style: TextStyle(fontSize: 12))),
//             DataCell(
//               PopupMenuButton<String>(
//                 icon: Icon(Icons.more_vert),
//                 onSelected: (value) => _handleRowAction(context, row, value),
//                 itemBuilder: (context) => [
//                   PopupMenuItem(
//                     value: 'copy',
//                     child: Row(
//                       children: [
//                         Icon(Icons.copy, size: 16),
//                         SizedBox(width: 8),
//                         Text('Copy Ref No'),
//                       ],
//                     ),
//                   ),
//                   PopupMenuItem(
//                     value: 'details',
//                     child: Row(
//                       children: [
//                         Icon(Icons.info, size: 16),
//                         SizedBox(width: 8),
//                         Text('View Details'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       }).toList(),
//     );
//   }

// // 2. UPDATE: _buildReconTable method in lib/data_screen.dart
//   Widget _buildReconTable(List<Map<String, dynamic>> data, SheetConfig sheet) {
//     final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

//     return DataTable2(
//       columnSpacing: 8,
//       horizontalMargin: 12,
//       minWidth: 1200, // Increased width to accommodate Txn_Source column
//       headingRowHeight: 56,
//       dataRowHeight: 48,
//       headingRowColor: MaterialStateProperty.all(Colors.purple[50]),
//       columns: [
//         DataColumn2(
//           label: Text('Ref No', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.L,
//         ),
//         // NEW: Add Txn_Source column
//         DataColumn2(
//           label: Text('Source', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('Machine', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//         DataColumn2(
//           label: Text('MID', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//         ),
//         DataColumn2(
//           label:
//               Text('PTPP Pay', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//         DataColumn2(
//           label:
//               Text('PTPP Ref', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//         DataColumn2(
//           label:
//               Text('Cloud Pay', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//         DataColumn2(
//           label:
//               Text('Cloud Ref', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//           numeric: true,
//         ),
//         DataColumn2(
//           label: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.M,
//         ),
//         DataColumn2(
//           label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
//           size: ColumnSize.S,
//         ),
//       ],
//       rows: data.map((row) {
//         return DataRow2(
//           cells: [
//             DataCell(Text(row['Txn_RefNo']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             // NEW: Display Txn_Source with color coding
//             DataCell(
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: _getSourceColor(row['Txn_Source']?.toString() ?? ''),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   row['Txn_Source']?.toString() ?? '',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//             DataCell(Text(row['Txn_Machine']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(row['Txn_MID']?.toString() ?? '',
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(
//                 currencyFormat.format(
//                     double.tryParse(row['PTPP_Payment']?.toString() ?? '0') ??
//                         0),
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(
//                 currencyFormat.format(
//                     double.tryParse(row['PTPP_Refund']?.toString() ?? '0') ??
//                         0),
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(
//                 currencyFormat.format(
//                     double.tryParse(row['Cloud_Payment']?.toString() ?? '0') ??
//                         0),
//                 style: TextStyle(fontSize: 12))),
//             DataCell(Text(
//                 currencyFormat.format(
//                     double.tryParse(row['Cloud_Refund']?.toString() ?? '0') ??
//                         0),
//                 style: TextStyle(fontSize: 12))),
//             DataCell(
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: _getRemarksColor(row['Remarks']?.toString() ?? ''),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   row['Remarks']?.toString() ?? '',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//             DataCell(
//               PopupMenuButton<String>(
//                 icon: Icon(Icons.more_vert),
//                 onSelected: (value) => _handleRowAction(context, row, value),
//                 itemBuilder: (context) => [
//                   PopupMenuItem(
//                     value: 'copy',
//                     child: Row(
//                       children: [
//                         Icon(Icons.copy, size: 16),
//                         SizedBox(width: 8),
//                         Text('Copy Ref No'),
//                       ],
//                     ),
//                   ),
//                   PopupMenuItem(
//                     value: 'details',
//                     child: Row(
//                       children: [
//                         Icon(Icons.info, size: 16),
//                         SizedBox(width: 8),
//                         Text('View Details'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       }).toList(),
//     );
//   }

// // 3. NEW: Add color coding method for transaction sources
//   Color _getSourceColor(String source) {
//     switch (source.toLowerCase()) {
//       case 'paytm':
//         return Colors.blue;
//       case 'phonepe':
//         return Colors.purple;
//       case 'cloud':
//         return Colors.green;
//       case 'manual':
//         return Colors.orange;
//       case 'unknown':
//         return Colors.grey;
//       default:
//         return Colors.blueGrey;
//     }
//   }

//   void _showTransactionDetails(BuildContext context, Map<String, dynamic> row) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             Text('Transaction Details'),
//             Spacer(),
//             // NEW: Show transaction source prominently in dialog title
//             if (row['Txn_Source'] != null)
//               Chip(
//                 label: Text(
//                   row['Txn_Source'].toString(),
//                   style: TextStyle(color: Colors.white, fontSize: 12),
//                 ),
//                 backgroundColor: _getSourceColor(row['Txn_Source'].toString()),
//               ),
//           ],
//         ),
//         content: Container(
//           width: double.maxFinite,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // NEW: Highlight transaction source first
//                 if (row['Txn_Source'] != null) ...[
//                   _buildDetailRow('Transaction Source', row['Txn_Source'],
//                       highlight: true),
//                   Divider(),
//                 ],
//                 _buildDetailRow('Reference Number', row['Txn_RefNo']),
//                 _buildDetailRow('Machine', row['Txn_Machine']),
//                 _buildDetailRow('MID', row['Txn_MID']),
//                 if (row['Txn_Type'] != null)
//                   _buildDetailRow('Type', row['Txn_Type']),
//                 if (row['Txn_Date'] != null)
//                   _buildDetailRow('Date', row['Txn_Date']),
//                 if (row['Txn_Amount'] != null)
//                   _buildDetailRow('Amount', row['Txn_Amount']),
//                 if (row['PTPP_Payment'] != null)
//                   _buildDetailRow('PTPP Payment', row['PTPP_Payment']),
//                 if (row['PTPP_Refund'] != null)
//                   _buildDetailRow('PTPP Refund', row['PTPP_Refund']),
//                 if (row['Cloud_Payment'] != null)
//                   _buildDetailRow('Cloud Payment', row['Cloud_Payment']),
//                 if (row['Cloud_Refund'] != null)
//                   _buildDetailRow('Cloud Refund', row['Cloud_Refund']),
//                 if (row['Cloud_MRefund'] != null)
//                   _buildDetailRow('Cloud Manual Refund', row['Cloud_MRefund']),
//                 if (row['Remarks'] != null)
//                   _buildDetailRow('Remarks', row['Remarks']),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('Close'),
//           ),
//           // NEW: Add button to copy transaction source
//           if (row['Txn_Source'] != null)
//             TextButton(
//               onPressed: () {
//                 Clipboard.setData(
//                     ClipboardData(text: row['Txn_Source'].toString()));
//                 Navigator.of(context).pop();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                       content: Text('Transaction source copied to clipboard')),
//                 );
//               },
//               child: Text('Copy Source'),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransactionSourceFilter(SheetConfig sheet) {
//     final sources = ['All', 'PayTM', 'PhonePe', 'Cloud', 'Manual', 'Unknown'];

//     return DropdownButtonFormField<String>(
//       value: _selectedTransactionSources[sheet.id] ?? 'All',
//       decoration: InputDecoration(
//         labelText: 'Transaction Source',
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         isDense: true,
//       ),
//       items: sources
//           .map((source) => DropdownMenuItem(
//                 value: source,
//                 child: Text(source),
//               ))
//           .toList(),
//       onChanged: (value) {
//         setState(() {
//           _selectedTransactionSources[sheet.id] = value!;
//         });
//         _onFilterChanged(sheet.id);
//       },
//     );
//   }

// // 5. NEW: Helper method for building detail rows with highlighting
//   Widget _buildDetailRow(String label, dynamic value,
//       {bool highlight = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 140,
//             child: Text(
//               '$label:',
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: highlight ? Colors.blue : null,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Container(
//               padding: highlight
//                   ? EdgeInsets.symmetric(horizontal: 8, vertical: 2)
//                   : null,
//               decoration: highlight
//                   ? BoxDecoration(
//                       color: Colors.blue.shade50,
//                       borderRadius: BorderRadius.circular(4),
//                     )
//                   : null,
//               child: Text(
//                 value?.toString() ?? 'N/A',
//                 style: TextStyle(
//                   fontWeight: highlight ? FontWeight.w600 : null,
//                   color: highlight ? Colors.blue.shade700 : null,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGenericTable(List<Map<String, dynamic>> data) {
//     if (data.isEmpty) return Center(child: Text('No data available'));

//     final columns = data.first.keys.take(6).toList();

//     return DataTable2(
//       columnSpacing: 12,
//       horizontalMargin: 12,
//       minWidth: columns.length * 120.0,
//       headingRowHeight: 40,
//       dataRowHeight: 36,
//       headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
//       columns: columns
//           .map((column) => DataColumn2(
//                 label: Text(column,
//                     style:
//                         TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//                 size: ColumnSize.M,
//               ))
//           .toList(),
//       rows: data
//           .map((row) => DataRow2(
//                 cells: columns
//                     .map((column) => DataCell(
//                           Text(
//                             _formatCellValue(row[column]),
//                             style: TextStyle(fontSize: 10),
//                           ),
//                         ))
//                     .toList(),
//               ))
//           .toList(),
//     );
//   }

//   // Loading and Error States
//   Widget _buildLoadingState(SheetConfig sheet) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(color: sheet.color, strokeWidth: 2),
//           SizedBox(height: 12),
//           Text('Loading ${sheet.name.toLowerCase()}...',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//         ],
//       ),
//     );
//   }

// // Helper method to get MID color coding
//   Color _getMIDColor(String? mid) {
//     if (mid == null || mid.isEmpty) return Colors.grey[400]!;

//     final midLower = mid.toLowerCase();
//     if (midLower.contains('vendol')) {
//       return Colors.indigo[600]!;
//     } else if (midLower.contains('india')) {
//       return Colors.teal[600]!;
//     } else if (midLower.contains('auto') || midLower.contains('manual')) {
//       return Colors.orange[600]!;
//     }
//     return Colors.blue[600]!;
//   }

// // Helper method to format date display
//   String _formatDate(String dateStr) {
//     if (dateStr.isEmpty) return '-';

//     try {
//       // Handle different date formats that might come from Excel
//       DateTime? date;

//       // Try parsing common Excel date formats
//       if (dateStr.contains('-')) {
//         date = DateTime.tryParse(dateStr);
//       } else if (dateStr.length == 8) {
//         // Handle YYYYMMDD format
//         final year = int.tryParse(dateStr.substring(0, 4));
//         final month = int.tryParse(dateStr.substring(4, 6));
//         final day = int.tryParse(dateStr.substring(6, 8));
//         if (year != null && month != null && day != null) {
//           date = DateTime(year, month, day);
//         }
//       }

//       if (date != null) {
//         return DateFormat('MMM dd, yy').format(date);
//       }

//       // If parsing fails, return truncated string
//       return dateStr.length > 12 ? '${dateStr.substring(0, 12)}...' : dateStr;
//     } catch (e) {
//       return dateStr.length > 12 ? '${dateStr.substring(0, 12)}...' : dateStr;
//     }
//   }

//   Widget _buildEmptyState(SheetConfig sheet, ReconProvider provider) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(40),
//             ),
//             child:
//                 Icon(Icons.inbox_outlined, size: 40, color: Colors.grey[400]),
//           ),
//           SizedBox(height: 12),
//           Text('No data available',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           SizedBox(height: 6),
//           Text('No records found for ${sheet.name}',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//           SizedBox(height: 12),
//           ElevatedButton.icon(
//             onPressed: () => provider.loadSheet(sheet.id),
//             icon: Icon(Icons.refresh, size: 16),
//             label: Text('Reload Data'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: sheet.color,
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoResultsState(SheetConfig sheet) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.orange[50],
//               borderRadius: BorderRadius.circular(40),
//             ),
//             child: Icon(Icons.search_off, size: 40, color: Colors.orange[400]),
//           ),
//           SizedBox(height: 12),
//           Text('No results found',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           SizedBox(height: 6),
//           Text('Try adjusting your filters or search criteria',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//           SizedBox(height: 12),
//           TextButton.icon(
//             onPressed: () => _clearAllFilters(sheet.id),
//             icon: Icon(Icons.clear_all, size: 16),
//             label: Text('Clear All Filters'),
//           ),
//         ],
//       ),
//     );
//   }

//   Map<String, double> _calculateFinancialBreakdown(
//       List<Map<String, dynamic>> data) {
//     double ptppPayment = 0.0;
//     double ptppRefund = 0.0;
//     double cloudPayment = 0.0;
//     double cloudRefund = 0.0;
//     double cloudManualRefund = 0.0;

//     for (var row in data) {
//       ptppPayment +=
//           double.tryParse(row['PTPP_Payment']?.toString() ?? '0') ?? 0.0;
//       ptppRefund +=
//           double.tryParse(row['PTPP_Refund']?.toString() ?? '0') ?? 0.0;
//       cloudPayment +=
//           double.tryParse(row['Cloud_Payment']?.toString() ?? '0') ?? 0.0;
//       cloudRefund +=
//           double.tryParse(row['Cloud_Refund']?.toString() ?? '0') ?? 0.0;
//       cloudManualRefund +=
//           double.tryParse(row['Cloud_MRefund']?.toString() ?? '0') ?? 0.0;
//     }

//     return {
//       'ptpp_payment': ptppPayment,
//       'ptpp_refund': ptppRefund,
//       'total_ptpp': ptppPayment + ptppRefund,
//       'cloud_payment': cloudPayment,
//       'cloud_refund': cloudRefund,
//       'cloud_manual_refund': cloudManualRefund,
//       'total_cloud': cloudPayment + cloudRefund + cloudManualRefund,
//     };
//   }

// // 4. Add this new widget method
//   Widget _buildFinancialBreakdownHeader(
//       SheetConfig sheet, List<Map<String, dynamic>>? data) {
//     // Only show for reconciliation sheets
//     if (!['RECON_SUCCESS', 'RECON_INVESTIGATE', 'MANUAL_REFUND']
//         .contains(sheet.id)) {
//       return SizedBox.shrink();
//     }

//     if (data == null || data.isEmpty) {
//       return SizedBox.shrink();
//     }

//     final breakdown = _calculateFinancialBreakdown(data);
//     final isExpanded = _isFinancialBreakdownExpanded[sheet.id] ?? false;

//     return Container(
//       margin: EdgeInsets.only(bottom: 6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         children: [
//           // Compact Header - Always Visible
//           InkWell(
//             onTap: () {
//               setState(() {
//                 _isFinancialBreakdownExpanded[sheet.id] = !isExpanded;
//               });
//             },
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.account_balance_wallet_outlined,
//                     size: 16,
//                     color: sheet.color,
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     'Financial Summary',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   // Quick totals in compact view
//                   if (!isExpanded) ...[
//                     _buildQuickTotal(
//                         'PTPP', breakdown['total_ptpp']!, Colors.blue),
//                     SizedBox(width: 6),
//                     _buildQuickTotal(
//                         'Cloud', breakdown['total_cloud']!, Colors.green),
//                   ],
//                   Spacer(),
//                   Icon(
//                     isExpanded ? Icons.expand_less : Icons.expand_more,
//                     size: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Expandable Details
//           if (isExpanded)
//             Container(
//               padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//                 borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
//               ),
//               child: Row(
//                 children: [
//                   // PTPP Breakdown
//                   Expanded(
//                     child: _buildBreakdownSection(
//                       'PTPP',
//                       Colors.blue,
//                       [
//                         {
//                           'label': 'Payment',
//                           'value': breakdown['ptpp_payment']!
//                         },
//                         {'label': 'Refund', 'value': breakdown['ptpp_refund']!},
//                       ],
//                       breakdown['total_ptpp']!,
//                     ),
//                   ),

//                   Container(
//                     width: 1,
//                     height: 60,
//                     color: Colors.grey[300],
//                     margin: EdgeInsets.symmetric(horizontal: 12),
//                   ),

//                   // Cloud Breakdown
//                   Expanded(
//                     child: _buildBreakdownSection(
//                       'Cloud',
//                       Colors.green,
//                       [
//                         {
//                           'label': 'Payment',
//                           'value': breakdown['cloud_payment']!
//                         },
//                         {
//                           'label': 'Refund',
//                           'value': breakdown['cloud_refund']!
//                         },
//                         {
//                           'label': 'Manual',
//                           'value': breakdown['cloud_manual_refund']!
//                         },
//                       ],
//                       breakdown['total_cloud']!,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

// // 5. Add helper widgets
//   Widget _buildQuickTotal(String label, double amount, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Text(
//         '$label: ${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(amount)}',
//         style: TextStyle(
//           fontSize: 9,
//           fontWeight: FontWeight.w600,
//           color: color,
//         ),
//       ),
//     );
//   }

//   Widget _buildBreakdownSection(String title, Color color,
//       List<Map<String, dynamic>> items, double total) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Section Title
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         SizedBox(height: 4),

//         // Individual Items
//         ...items.map((item) => Padding(
//               padding: EdgeInsets.only(bottom: 2),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     item['label'],
//                     style: TextStyle(fontSize: 9, color: Colors.grey[600]),
//                   ),
//                   Text(
//                     NumberFormat.currency(symbol: '₹', decimalDigits: 0)
//                         .format(item['value']),
//                     style: TextStyle(
//                       fontSize: 9,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey[800],
//                     ),
//                   ),
//                 ],
//               ),
//             )),

//         // Divider
//         Container(
//           height: 1,
//           color: color.withOpacity(0.3),
//           margin: EdgeInsets.symmetric(vertical: 3),
//         ),

//         // Total
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Total',
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             Text(
//               NumberFormat.currency(symbol: '₹', decimalDigits: 0)
//                   .format(total),
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // Helper Methods
//   Color _getRemarksColor(String remarks) {
//     switch (remarks.toLowerCase()) {
//       case 'perfect':
//         return Colors.green[600]!;
//       case 'investigate':
//         return Colors.orange[600]!;
//       case 'manual':
//         return Colors.purple[600]!;
//       default:
//         return Colors.blue[600]!;
//     }
//   }

//   // Color _getSourceColor(String? source) {
//   //   switch (source?.toLowerCase()) {
//   //     case 'paytm':
//   //       return Colors.blue[600]!;
//   //     case 'phonepe':
//   //       return Colors.purple[600]!;
//   //     case 'cloud':
//   //       return Colors.green[600]!;
//   //     case 'ptpp':
//   //       return Colors.orange[600]!;
//   //     default:
//   //       return Colors.grey[600]!;
//   //   }
//   // }

//   String _formatCellValue(dynamic value) {
//     if (value == null) return '';
//     if (value is num && value > 1000) {
//       return NumberFormat('#,##0.00').format(value);
//     }
//     return value.toString();
//   }

//   int _getTotalRecords(ReconProvider provider) {
//     int total = 0;
//     for (String sheetId in [
//       'SUMMARY',
//       'RAWDATA',
//       'RECON_SUCCESS',
//       'RECON_INVESTIGATE',
//       'MANUAL_REFUND'
//     ]) {
//       final data = provider.getSheetData(sheetId);
//       if (data != null) total += data.length;
//     }
//     return total;
//   }

//   int _getSuccessRate(ReconProvider provider) {
//     final successData = provider.getSheetData('RECON_SUCCESS');
//     final investigateData = provider.getSheetData('RECON_INVESTIGATE');
//     final totalRecon =
//         (successData?.length ?? 0) + (investigateData?.length ?? 0);

//     if (totalRecon == 0) return 0;
//     return ((successData?.length ?? 0) * 100 / totalRecon).round();
//   }

//   // List<Map<String, dynamic>> _applyFilters(
//   //     List<Map<String, dynamic>> data, String sheetId) {
//   //   final searchQuery = _searchControllers[sheetId]?.text.toLowerCase() ?? '';
//   //   final minAmount =
//   //       double.tryParse(_minAmountControllers[sheetId]?.text ?? '');
//   //   final maxAmount =
//   //       double.tryParse(_maxAmountControllers[sheetId]?.text ?? '');
//   //   final remarksFilter =
//   //       _remarksControllers[sheetId]?.text.toLowerCase() ?? '';
//   //   final modeFilter = _selectedTransactionModes[sheetId] ?? 'All';
//   //   final statusFilter = _selectedQuickStatuses[sheetId] ?? 'All';

//   //   return data.where((row) {
//   //     // Search filter
//   //     if (searchQuery.isNotEmpty) {
//   //       bool matchesSearch = row.values.any((value) =>
//   //           value?.toString().toLowerCase().contains(searchQuery) ?? false);
//   //       if (!matchesSearch) return false;
//   //     }

//   //     // Amount range filter
//   //     if (minAmount != null || maxAmount != null) {
//   //       final amount = _getAmountFromRow(row);
//   //       if (amount != null) {
//   //         if (minAmount != null && amount < minAmount) return false;
//   //         if (maxAmount != null && amount > maxAmount) return false;
//   //       }
//   //     }

//   //     // Remarks filter
//   //     if (remarksFilter.isNotEmpty) {
//   //       final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//   //       if (!remarks.contains(remarksFilter)) return false;
//   //     }

//   //     // Transaction mode filter
//   //     if (modeFilter != 'All') {
//   //       final source = row['Txn_Source']?.toString() ?? '';
//   //       if (!source.toLowerCase().contains(modeFilter.toLowerCase()))
//   //         return false;
//   //     }

//   //     // Quick status filter
//   //     if (statusFilter != 'All') {
//   //       final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//   //       if (!remarks.contains(statusFilter.toLowerCase())) return false;
//   //     }

//   //     return true;
//   //   }).toList();
//   // }

//   List<Map<String, dynamic>> _applyFilters(
//       List<Map<String, dynamic>> data, String sheetId) {
//     final searchQuery = _searchControllers[sheetId]?.text.toLowerCase() ?? '';
//     final minAmount =
//         double.tryParse(_minAmountControllers[sheetId]?.text ?? '');
//     final maxAmount =
//         double.tryParse(_maxAmountControllers[sheetId]?.text ?? '');
//     final remarksFilter =
//         _remarksControllers[sheetId]?.text.toLowerCase() ?? '';

//     // Updated to use multi-select lists
//     final selectedModes = _selectedTransactionModesList[sheetId] ?? [];
//     final selectedStatuses = _selectedQuickStatusesList[sheetId] ?? [];

//     // Calculate total amount for all records (before filtering)
//     _totalAmounts[sheetId] = _calculateTotalAmountForSheet(data, sheetId);

//     final filteredData = data.where((row) {
//       // Search filter
//       if (searchQuery.isNotEmpty) {
//         bool matchesSearch = row.values.any((value) =>
//             value?.toString().toLowerCase().contains(searchQuery) ?? false);
//         if (!matchesSearch) return false;
//       }

//       // Amount range filter
//       if (minAmount != null || maxAmount != null) {
//         final amount = _getAmountFromRow(row);
//         if (amount != null) {
//           if (minAmount != null && amount < minAmount) return false;
//           if (maxAmount != null && amount > maxAmount) return false;
//         }
//       }

//       // Remarks filter
//       if (remarksFilter.isNotEmpty) {
//         final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//         if (!remarks.contains(remarksFilter)) return false;
//       }

//       // Multi-select transaction mode filter
//       if (selectedModes.isNotEmpty) {
//         final source = row['Txn_Source']?.toString() ?? '';
//         bool matchesMode = selectedModes
//             .any((mode) => source.toLowerCase().contains(mode.toLowerCase()));
//         if (!matchesMode) return false;
//       }

//       // Multi-select status filter
//       if (selectedStatuses.isNotEmpty) {
//         final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
//         bool matchesStatus = selectedStatuses
//             .any((status) => remarks.contains(status.toLowerCase()));
//         if (!matchesStatus) return false;
//       }

//       return true;
//     }).toList();

//     // Calculate filtered totals
//     _filteredAmounts[sheetId] =
//         _calculateTotalAmountForSheet(filteredData, sheetId);
//     _filteredCounts[sheetId] = filteredData.length;

//     return filteredData;
//   }

//   double _calculateTotalAmountForSheet(
//       List<Map<String, dynamic>> data, String sheetId) {
//     double total = 0.0;

//     for (var row in data) {
//       switch (sheetId) {
//         case 'SUMMARY':
//           // For summary, use sum(Txn_Amount)
//           final amount =
//               double.tryParse(row['sum(Txn_Amount)']?.toString() ?? '0') ?? 0.0;
//           total += amount;
//           break;

//         case 'RAWDATA':
//           // For raw data, use Txn_Amount
//           final amount =
//               double.tryParse(row['Txn_Amount']?.toString() ?? '0') ?? 0.0;
//           total += amount;
//           break;

//         case 'RECON_SUCCESS':
//         case 'RECON_INVESTIGATE':
//         case 'MANUAL_REFUND':
//           // For reconciliation tabs, sum positive amounts only
//           final ptppPay =
//               double.tryParse(row['PTPP_Payment']?.toString() ?? '0') ?? 0.0;
//           final cloudPay =
//               double.tryParse(row['Cloud_Payment']?.toString() ?? '0') ?? 0.0;
//           final cloudMRef =
//               double.tryParse(row['Cloud_MRefund']?.toString() ?? '0') ?? 0.0;

//           if (sheetId == 'MANUAL_REFUND') {
//             total += cloudMRef; // Focus on manual refunds
//           } else {
//             total +=
//                 (ptppPay + cloudPay); // Focus on payments for other recon tabs
//           }
//           break;

//         default:
//           // Fallback to generic amount detection
//           final amount = _getAmountFromRow(row) ?? 0.0;
//           total += amount;
//       }
//     }

//     return total;
//   }

//   Widget _buildTotalAmountDisplay(SheetConfig sheet) {
//     final totalAmount = _totalAmounts[sheet.id] ?? 0.0;
//     final filteredAmount = _filteredAmounts[sheet.id] ?? 0.0;
//     final filteredCount = _filteredCounts[sheet.id] ?? 0;
//     final hasFilters = _activeFilters[sheet.id]?.isNotEmpty == true;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: sheet.color.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: sheet.color.withOpacity(0.2)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Total Records Display
//           Row(
//             children: [
//               Icon(Icons.receipt_long, size: 14, color: sheet.color),
//               SizedBox(width: 4),
//               Text(
//                 hasFilters
//                     ? 'Filtered: $filteredCount records'
//                     : 'Total: ${(_totalAmounts[sheet.id] != null ? _filteredCounts[sheet.id] ?? 0 : 0)} records',
//                 style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey[700],
//                 ),
//               ),
//             ],
//           ),
//           // Amount Display
//           Row(
//             children: [
//               Icon(Icons.currency_rupee, size: 14, color: sheet.color),
//               SizedBox(width: 4),
//               Text(
//                 hasFilters
//                     ? NumberFormat.currency(symbol: '₹', decimalDigits: 0)
//                         .format(filteredAmount)
//                     : NumberFormat.currency(symbol: '₹', decimalDigits: 0)
//                         .format(totalAmount),
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: sheet.color,
//                 ),
//               ),
//               if (hasFilters) ...[
//                 SizedBox(width: 4),
//                 Text(
//                   'of ${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(totalAmount)}',
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   double? _getAmountFromRow(Map<String, dynamic> row) {
//     final amountFields = [
//       'Txn_Amount',
//       'PTPP_Payment',
//       'Cloud_Payment',
//       'sum(Txn_Amount)'
//     ];

//     for (String field in amountFields) {
//       if (row.containsKey(field)) {
//         return double.tryParse(row[field]?.toString() ?? '0');
//       }
//     }
//     return null;
//   }

//   List<Map<String, dynamic>> _getPaginatedData(
//       List<Map<String, dynamic>> data, String sheetId) {
//     final startIndex = (_currentPage[sheetId] ?? 0) * _itemsPerPage;
//     final endIndex = (startIndex + _itemsPerPage).clamp(0, data.length);
//     return data.sublist(startIndex, endIndex);
//   }

//   void _onSearchChanged(String sheetId, String value) {
//     setState(() {
//       _currentPage[sheetId] = 0;
//     });
//     _updateActiveFilters(sheetId);
//   }

//   void _onFilterChanged(String sheetId) {
//     setState(() {
//       _currentPage[sheetId] = 0;
//     });
//     _updateActiveFilters(sheetId);
//   }

//   // void _updateActiveFilters(String sheetId) {
//   //   List<String> filters = [];

//   //   final searchQuery = _searchControllers[sheetId]?.text ?? '';
//   //   if (searchQuery.isNotEmpty) {
//   //     filters.add('Search: "$searchQuery"');
//   //   }

//   //   final minAmount = _minAmountControllers[sheetId]?.text ?? '';
//   //   final maxAmount = _maxAmountControllers[sheetId]?.text ?? '';
//   //   if (minAmount.isNotEmpty || maxAmount.isNotEmpty) {
//   //     filters.add('Amount: ₹$minAmount - ₹$maxAmount');
//   //   }

//   //   final remarks = _remarksControllers[sheetId]?.text ?? '';
//   //   if (remarks.isNotEmpty) {
//   //     filters.add('Remarks: "$remarks"');
//   //   }

//   //   final mode = _selectedTransactionModes[sheetId] ?? 'All';
//   //   if (mode != 'All') {
//   //     filters.add('Mode: $mode');
//   //   }

//   //   final status = _selectedQuickStatuses[sheetId] ?? 'All';
//   //   if (status != 'All') {
//   //     filters.add('Status: $status');
//   //   }

//   //   setState(() {
//   //     _activeFilters[sheetId] = filters;
//   //   });
//   // }

//   void _updateActiveFilters(String sheetId) {
//     List<String> filters = [];

//     final searchQuery = _searchControllers[sheetId]?.text ?? '';
//     if (searchQuery.isNotEmpty) {
//       filters.add('Search: "$searchQuery"');
//     }

//     final minAmount = _minAmountControllers[sheetId]?.text ?? '';
//     final maxAmount = _maxAmountControllers[sheetId]?.text ?? '';
//     if (minAmount.isNotEmpty || maxAmount.isNotEmpty) {
//       filters.add('Amount: ₹$minAmount - ₹$maxAmount');
//     }

//     final remarks = _remarksControllers[sheetId]?.text ?? '';
//     if (remarks.isNotEmpty) {
//       filters.add('Remarks: "$remarks"');
//     }

//     // Updated for multi-select
//     final selectedModes = _selectedTransactionModesList[sheetId] ?? [];
//     if (selectedModes.isNotEmpty) {
//       filters.add('Modes: ${selectedModes.join(", ")}');
//     }

//     final selectedStatuses = _selectedQuickStatusesList[sheetId] ?? [];
//     if (selectedStatuses.isNotEmpty) {
//       filters.add('Status: ${selectedStatuses.join(", ")}');
//     }

//     setState(() {
//       _activeFilters[sheetId] = filters;
//     });
//   }

//   void _removeFilter(String sheetId, String filter) {
//     if (filter.startsWith('Search:')) {
//       _searchControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Amount:')) {
//       _minAmountControllers[sheetId]?.clear();
//       _maxAmountControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Remarks:')) {
//       _remarksControllers[sheetId]?.clear();
//     } else if (filter.startsWith('Modes:')) {
//       _selectedTransactionModesList[sheetId] = [];
//     } else if (filter.startsWith('Status:')) {
//       _selectedQuickStatusesList[sheetId] = [];
//     }

//     _onFilterChanged(sheetId);
//   }

//   void _clearAllFilters(String sheetId) {
//     setState(() {
//       _searchControllers[sheetId]?.clear();
//       _minAmountControllers[sheetId]?.clear();
//       _maxAmountControllers[sheetId]?.clear();
//       _remarksControllers[sheetId]?.clear();
//       _selectedTransactionModes[sheetId] = 'All'; // Keep existing single select
//       _selectedQuickStatuses[sheetId] = 'All'; // Keep existing single select

//       // Clear new multi-select lists
//       _selectedTransactionModesList[sheetId] = [];
//       _selectedQuickStatusesList[sheetId] = [];

//       _currentPage[sheetId] = 0;
//       _activeFilters[sheetId] = [];
//     });
//   }

//   void _changePage(String sheetId, int newPage) {
//     setState(() {
//       _currentPage[sheetId] = newPage;
//     });
//   }
// }

// class SheetConfig {
//   final String id;
//   final String name;
//   final IconData icon;
//   final String description;
//   final Color color;

//   SheetConfig(this.id, this.name, this.icon, this.description, this.color);
// }

// // Add these extension methods at the bottom of the file for null safety
// extension SafeColor on Color? {
//   Color get safe => this ?? Colors.grey;
// }

// extension SafeColorWithOpacity on Color {
//   Color safeWithOpacity(double opacity) {
//     try {
//       return this.withOpacity(opacity);
//     } catch (e) {
//       return Colors.grey.withOpacity(opacity);
//     }
//   }
// }

//7

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'ReconProvider.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;

  // Search and filter controllers
  final Map<String, TextEditingController> _searchControllers = {};
  final Map<String, TextEditingController> _minAmountControllers = {};
  final Map<String, TextEditingController> _maxAmountControllers = {};
  final Map<String, TextEditingController> _remarksControllers = {};
  final Map<String, String> _selectedTransactionModes = {};
  final Map<String, String> _selectedQuickStatuses = {};
  final Map<String, bool> _isFilterExpanded = {};

  final Map<String, List<String>> _selectedTransactionModesList = {};
  final Map<String, List<String>> _selectedQuickStatusesList = {};

  final Map<String, double> _totalAmounts = {}; // Store total amounts per sheet
  final Map<String, double> _filteredAmounts =
      {}; // Store filtered amounts per sheet
  final Map<String, int> _filteredCounts = {};

// Available options for multi-select
  final List<String> _transactionModes = [
    'Paytm',
    'PhonePe',
    'Cloud',
    'PTPP',
    'Manual'
  ];
  final List<String> _quickStatuses = ['Perfect', 'Investigate', 'Manual'];

  // Pagination
  final Map<String, int> _currentPage = {};
  final int _itemsPerPage = 100; // Increased for better performance

  // Active filters tracking
  final Map<String, List<String>> _activeFilters = {};
  final Map<String, bool> _isFinancialBreakdownExpanded = {};
  // Floating filter panel
  bool _showFloatingFilter = false;
  String _currentFilterSheet = '';

  final List<SheetConfig> _sheets = [
    SheetConfig('SUMMARY', 'Summary', Icons.dashboard_outlined,
        'Summary overview', Colors.blue),
    SheetConfig('RECON_SUCCESS', 'Perfect', Icons.check_circle_outline,
        'Successfully reconciled', Colors.green),
    SheetConfig('RECON_INVESTIGATE', 'Investigate', Icons.warning_outlined,
        'Require investigation', Colors.orange),
    SheetConfig('MANUAL_REFUND', 'Manual', Icons.edit_outlined,
        'Manual refunds', Colors.purple),
    SheetConfig('RAWDATA', 'Raw Data', Icons.table_rows_outlined,
        'All raw data', Colors.grey),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Initialize TabController FIRST with correct length
    _tabController = TabController(length: _sheets.length, vsync: this);

    _filterAnimationController = AnimationController(
      duration: Duration(milliseconds: 250),
      vsync: this,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );

    // Initialize controllers for each sheet
    for (var sheet in _sheets) {
      _searchControllers[sheet.id] = TextEditingController();
      _minAmountControllers[sheet.id] = TextEditingController();
      _maxAmountControllers[sheet.id] = TextEditingController();
      _remarksControllers[sheet.id] = TextEditingController();
      _selectedTransactionModes[sheet.id] = 'All';
      _selectedQuickStatuses[sheet.id] = 'All';
      _isFilterExpanded[sheet.id] = false;
      _currentPage[sheet.id] = 0;
      _activeFilters[sheet.id] = [];
      _selectedTransactionModesList[sheet.id] = [];
      _selectedQuickStatusesList[sheet.id] = [];

      _totalAmounts[sheet.id] = 0.0;
      _filteredAmounts[sheet.id] = 0.0;
      _filteredCounts[sheet.id] = 0;

      _isFinancialBreakdownExpanded[sheet.id] = false;
    }

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReconProvider>(context, listen: false).loadAllSheets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _filterAnimationController.dispose();
    _searchControllers.values.forEach((controller) => controller.dispose());
    _minAmountControllers.values.forEach((controller) => controller.dispose());
    _maxAmountControllers.values.forEach((controller) => controller.dispose());
    _remarksControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ReconProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildCompactAppBar(provider),
          body: Stack(
            children: [
              Column(
                children: [
                  if (provider.error != null) _buildErrorBanner(provider),
                  if (provider.isLoading) _buildLoadingIndicator(),
                  _buildEnhancedTabBar(),
                  Expanded(child: _buildTabBarView(provider)),
                ],
              ),
              // Floating Filter Panel
              if (_showFloatingFilter) _buildFloatingFilterPanel(),
            ],
          ),
          floatingActionButton: _buildFilterFAB(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        );
      },
    );
  }

  PreferredSizeWidget _buildCompactAppBar(ReconProvider provider) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      toolbarHeight: 60,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.analytics_outlined,
                color: Colors.blue[700], size: 20),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Reconciliation Dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Text('Real-time analysis',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
      actions: [
        _buildCompactStatsRow(provider),
        SizedBox(width: 8),
        IconButton(
          onPressed: provider.isLoading ? null : () => provider.loadAllSheets(),
          icon: Icon(Icons.refresh, size: 20),
          tooltip: 'Refresh Data',
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCompactStatsRow(ReconProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCompactStatChip(
            'Records', _getTotalRecords(provider).toString(), Colors.blue),
        SizedBox(width: 6),
        _buildCompactStatChip(
            'Success', '${_getSuccessRate(provider)}%', Colors.green),
      ],
    );
  }

  Widget _buildCompactStatChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 9, color: color)),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(ReconProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red[50],
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(provider.error!,
                style: TextStyle(color: Colors.red[700], fontSize: 12)),
          ),
          IconButton(
            onPressed: () => provider.clearError(),
            icon: Icon(Icons.close, size: 16, color: Colors.red[700]),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 2,
      child: LinearProgressIndicator(
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
      ),
    );
  }

//   Widget _buildEnhancedTabBar() {
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.symmetric(horizontal: 8),
//       child: TabBar(
//         controller: _tabController,
//         isScrollable: true,
//         labelColor: Colors.blue[700] ?? Colors.blue,
//         unselectedLabelColor: Colors.grey[600] ?? Colors.grey,
//         indicatorColor: Colors.blue[600] ?? Colors.blue,
//         indicatorWeight: 2,
//         labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//         unselectedLabelStyle:
//             TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
//         onTap: (index) {
//           if (index < _sheets.length) {
//             _currentFilterSheet = _sheets[index].id;
//           }
//         },
//         tabs: _sheets
//             .map((sheet) => Tab(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(sheet.icon, size: 16, color: sheet.color),
//                         SizedBox(width: 6),
//                         Text(sheet.name),
//                         SizedBox(width: 6),
//                         _buildRecordCountBadge(sheet),
//                       ],
//                     ),
//                   ),
//                 ))
//             .toList(),
//       ),
//     );
//   }

  Widget _buildEnhancedTabBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.blue[700] ?? Colors.blue,
        unselectedLabelColor: Colors.grey[600] ?? Colors.grey,
        indicatorColor: Colors.blue[600] ?? Colors.blue,
        indicatorWeight: 2,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle:
            TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        onTap: (index) {
          if (index < _sheets.length) {
            final newSheetId = _sheets[index].id;

            // 🔧 FIX: Reset filter panel when tab changes
            if (_currentFilterSheet != newSheetId) {
              setState(() {
                _currentFilterSheet = newSheetId;
                // Reset floating filter panel to hide it
                _showFloatingFilter = false;
              });
            }
          }
        },
        tabs: _sheets
            .map((sheet) => Tab(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(sheet.icon, size: 16, color: sheet.color),
                        SizedBox(width: 6),
                        Text(sheet.name),
                        SizedBox(width: 6),
                        _buildRecordCountBadge(sheet),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildRecordCountBadge(SheetConfig sheet) {
    return Consumer<ReconProvider>(
      builder: (context, provider, child) {
        final data = provider.getSheetData(sheet.id);
        final count = data?.length ?? 0;

        if (count == 0) return SizedBox.shrink();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: (sheet.color ?? Colors.grey).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count > 999
                ? '${(count / 1000).toStringAsFixed(1)}k'
                : count.toString(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: sheet.color ?? Colors.grey,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBarView(ReconProvider provider) {
    if (_tabController.length != _sheets.length) {
      // Safety check: rebuild TabController if lengths don't match
      _tabController.dispose();
      _tabController = TabController(length: _sheets.length, vsync: this);
    }

    return TabBarView(
      controller: _tabController,
      children: _sheets
          .map((sheet) => _buildOptimizedSheetView(provider, sheet))
          .toList(),
    );
  }

  Widget _buildOptimizedSheetView(ReconProvider provider, SheetConfig sheet) {
    final data = provider.getSheetData(sheet.id);

    return Padding(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        children: [
          // Compact header with quick info
          _buildCompactSheetHeader(sheet, data),
          SizedBox(height: 6),

          // ✅ ADD THIS LINE - Financial Breakdown Header
          _buildFinancialBreakdownHeader(sheet, data),

          // Total Amount Display (your existing code)
          if (data != null && data.isNotEmpty) _buildTotalAmountDisplay(sheet),
          if (data != null && data.isNotEmpty) SizedBox(height: 6),

          // Active filters row (only if filters are active)
          if (_activeFilters[sheet.id]?.isNotEmpty == true)
            _buildActiveFiltersRow(sheet),
          if (_activeFilters[sheet.id]?.isNotEmpty == true) SizedBox(height: 6),

          // Main data table - maximized height
          Expanded(child: _buildOptimizedDataContent(provider, sheet, data)),
        ],
      ),
    );
  }

  Widget _buildCompactSheetHeader(
      SheetConfig sheet, List<Map<String, dynamic>>? data) {
    final recordCount = data?.length ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(sheet.icon, color: sheet.color, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(sheet.description,
                style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          ),
          // Compact record count chip
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: sheet.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              recordCount > 999
                  ? '${(recordCount / 1000).toStringAsFixed(1)}k records'
                  : '$recordCount records',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: sheet.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersRow(SheetConfig sheet) {
    final activeFilters = _activeFilters[sheet.id] ?? [];

    return Container(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: activeFilters.length + 1, // +1 for clear all button
        separatorBuilder: (context, index) => SizedBox(width: 6),
        itemBuilder: (context, index) {
          if (index == activeFilters.length) {
            // Clear all button
            return GestureDetector(
              onTap: () => _clearAllFilters(sheet.id),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.clear_all, size: 12, color: Colors.red[600]),
                    SizedBox(width: 4),
                    Text('Clear All',
                        style: TextStyle(fontSize: 10, color: Colors.red[600])),
                  ],
                ),
              ),
            );
          }

          final filter = activeFilters[index];
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(filter,
                    style: TextStyle(fontSize: 10, color: Colors.blue[700])),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _removeFilter(sheet.id, filter),
                  child: Icon(Icons.close, size: 12, color: Colors.blue[600]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptimizedDataContent(ReconProvider provider, SheetConfig sheet,
      List<Map<String, dynamic>>? data) {
    if (provider.isLoading) {
      return _buildLoadingState(sheet);
    }

    if (data == null || data.isEmpty) {
      return _buildEmptyState(sheet, provider);
    }

    final filteredData = _applyFilters(data, sheet.id);
    final paginatedData = _getPaginatedData(filteredData, sheet.id);

    if (filteredData.isEmpty) {
      return _buildNoResultsState(sheet);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Pagination info (compact)
          if (filteredData.length > _itemsPerPage)
            _buildCompactPaginationInfo(sheet, filteredData.length),
          // Data table - takes remaining space
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildDataTableForSheet(sheet, paginatedData),
            ),
          ),
          // Pagination controls (compact)
          if (filteredData.length > _itemsPerPage)
            _buildCompactPaginationControls(sheet, filteredData.length),
        ],
      ),
    );
  }

  Widget _buildCompactPaginationInfo(SheetConfig sheet, int totalItems) {
    final currentPage = _currentPage[sheet.id] ?? 0;
    final startIndex = currentPage * _itemsPerPage + 1;
    final endIndex = ((currentPage + 1) * _itemsPerPage).clamp(0, totalItems);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $startIndex-$endIndex of $totalItems',
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
          Text(
            'Page ${currentPage + 1} of ${(totalItems / _itemsPerPage).ceil()}',
            style: TextStyle(
              color: sheet.color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPaginationControls(SheetConfig sheet, int totalItems) {
    final totalPages = (totalItems / _itemsPerPage).ceil();
    final currentPage = _currentPage[sheet.id] ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPaginationButton(
            icon: Icons.first_page,
            enabled: currentPage > 0,
            onPressed: () => _changePage(sheet.id, 0),
          ),
          _buildPaginationButton(
            icon: Icons.chevron_left,
            enabled: currentPage > 0,
            onPressed: () => _changePage(sheet.id, currentPage - 1),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              '${currentPage + 1}/$totalPages',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          _buildPaginationButton(
            icon: Icons.chevron_right,
            enabled: currentPage < totalPages - 1,
            onPressed: () => _changePage(sheet.id, currentPage + 1),
          ),
          _buildPaginationButton(
            icon: Icons.last_page,
            enabled: currentPage < totalPages - 1,
            onPressed: () => _changePage(sheet.id, totalPages - 1),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 16),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: enabled ? Colors.white : Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  // Floating Filter Panel
//   Widget _buildFilterFAB() {
//     return Consumer<ReconProvider>(
//       builder: (context, provider, child) {
//         final currentSheetIndex = _tabController.index;
//         final currentSheet = _sheets[currentSheetIndex];
//         final hasActiveFilters =
//             _activeFilters[currentSheet.id]?.isNotEmpty == true;

//         return FloatingActionButton.small(
//           onPressed: () {
//             setState(() {
//               _currentFilterSheet = currentSheet.id;
//               _showFloatingFilter = !_showFloatingFilter;
//             });
//           },
//           backgroundColor:
//               hasActiveFilters ? currentSheet.color : Colors.grey[700],
//           child: Stack(
//             children: [
//               Icon(Icons.filter_alt, size: 20, color: Colors.white),
//               if (hasActiveFilters)
//                 Positioned(
//                   right: 0,
//                   top: 0,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

  Widget _buildFilterFAB() {
    return Consumer<ReconProvider>(
      builder: (context, provider, child) {
        final currentSheetIndex = _tabController.index;
        final currentSheet = _sheets[currentSheetIndex];
        final hasActiveFilters =
            _activeFilters[currentSheet.id]?.isNotEmpty == true;

        return FloatingActionButton.small(
          onPressed: () {
            setState(() {
              // 🔧 FIX: Always update current filter sheet before showing panel
              _currentFilterSheet = currentSheet.id;
              _showFloatingFilter = !_showFloatingFilter;
            });
          },
          backgroundColor:
              hasActiveFilters ? currentSheet.color : Colors.grey[700],
          child: Stack(
            children: [
              Icon(Icons.filter_alt, size: 20, color: Colors.white),
              if (hasActiveFilters)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

//   Widget _buildFloatingFilterPanel() {
//     final sheet = _sheets.firstWhere((s) => s.id == _currentFilterSheet);

//     return Positioned(
//       top: 16,
//       right: 16,
//       child: Material(
//         elevation: 8,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           width: 320,
//           constraints: BoxConstraints(maxHeight: 400),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header
//               Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: sheet.color.withOpacity(0.1),
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.filter_alt, color: sheet.color, size: 20),
//                     SizedBox(width: 8),
//                     Text('Filter ${sheet.name}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: sheet.color,
//                         )),
//                     Spacer(),
//                     IconButton(
//                       onPressed: () =>
//                           setState(() => _showFloatingFilter = false),
//                       icon: Icon(Icons.close, size: 20),
//                       padding: EdgeInsets.zero,
//                       constraints: BoxConstraints(),
//                     ),
//                   ],
//                 ),
//               ),
//               // Filter content
//               Flexible(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(16),
//                   child: _buildFloatingFilterContent(sheet),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

  Widget _buildFloatingFilterPanel() {
    final sheet = _sheets.firstWhere((s) => s.id == _currentFilterSheet);

    // 🔧 FIX: Get available fields for current sheet
    final availableFields = _getAvailableFieldsForSheet(sheet.id);

    return Positioned(
      top: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 320,
          constraints: BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with sheet info
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: sheet.color.withOpacity(0.1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_alt, color: sheet.color, size: 20),
                    SizedBox(width: 8),
                    Text('Filter ${sheet.name}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: sheet.color,
                        )),
                    Spacer(),
                    // 🔧 FIX: Add reset button in header
                    if (_hasAnyActiveFilters(sheet.id))
                      IconButton(
                        onPressed: () => _clearAllFilters(sheet.id),
                        icon: Icon(Icons.clear_all,
                            size: 16, color: Colors.orange),
                        tooltip: 'Clear all filters',
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: () =>
                          setState(() => _showFloatingFilter = false),
                      icon: Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Filter content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: _buildDynamicFilterContent(sheet, availableFields),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicFilterContent(
      SheetConfig sheet, Map<String, bool> availableFields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search (always available)
        TextField(
          controller: _searchControllers[sheet.id],
          decoration: InputDecoration(
            hintText: 'Search ${sheet.name.toLowerCase()}...',
            prefixIcon: Icon(Icons.search, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
          onChanged: (value) => _onSearchChanged(sheet.id, value),
        ),
        SizedBox(height: 12),

        // Amount range (if available)
        if (availableFields['amount'] == true) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minAmountControllers[sheet.id],
                  decoration: InputDecoration(
                    labelText: 'Min ₹',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _onFilterChanged(sheet.id),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _maxAmountControllers[sheet.id],
                  decoration: InputDecoration(
                    labelText: 'Max ₹',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _onFilterChanged(sheet.id),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
        ],

        // Transaction Mode (if available)
        if (availableFields['transactionMode'] == true) ...[
          _buildMultiSelectField(
            label: 'Transaction Modes',
            selectedItems: _selectedTransactionModesList[sheet.id] ?? [],
            availableItems: _getTransactionModesForSheet(sheet.id),
            onChanged: (selectedItems) {
              setState(() {
                _selectedTransactionModesList[sheet.id] = selectedItems;
              });
              _onFilterChanged(sheet.id);
            },
          ),
          SizedBox(height: 12),
        ],

        // Quick Status (if available)
        if (availableFields['quickStatus'] == true) ...[
          _buildMultiSelectField(
            label: 'Quick Status',
            selectedItems: _selectedQuickStatusesList[sheet.id] ?? [],
            availableItems: _getQuickStatusesForSheet(sheet.id),
            onChanged: (selectedItems) {
              setState(() {
                _selectedQuickStatusesList[sheet.id] = selectedItems;
              });
              _onFilterChanged(sheet.id);
            },
          ),
          SizedBox(height: 12),
        ],

        // Remarks (if available)
        if (availableFields['remarks'] == true) ...[
          TextField(
            controller: _remarksControllers[sheet.id],
            decoration: InputDecoration(
              labelText: 'Remarks contains',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              isDense: true,
            ),
            onChanged: (value) => _onFilterChanged(sheet.id),
          ),
          SizedBox(height: 16),
        ],

        // Filtered Summary (only when filters are active)
        _buildFilteredSummary(sheet),

        // Show active filter count
        if (_hasAnyActiveFilters(sheet.id)) ...[
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: sheet.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${_activeFilters[sheet.id]?.length ?? 0} active filters',
              style: TextStyle(
                fontSize: 10,
                color: sheet.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],

        SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _hasAnyActiveFilters(sheet.id)
                    ? () => _clearAllFilters(sheet.id)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                  elevation: 0,
                ),
                child: Text('Clear All'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _showFloatingFilter = false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sheet.color,
                  foregroundColor: Colors.white,
                ),
                child: Text('Apply'),
              ),
            ),
          ],
        ),
      ],
    );
  }

// 5. NEW: Get available fields for each sheet type
  Map<String, bool> _getAvailableFieldsForSheet(String sheetId) {
    switch (sheetId) {
      case 'SUMMARY':
        return {
          'amount': true,
          'transactionMode': true,
          'quickStatus': false, // Summary doesn't have status
          'remarks': false,
        };

      case 'RAWDATA':
        return {
          'amount': true,
          'transactionMode': true,
          'quickStatus': false, // Raw data doesn't have status
          'remarks': false,
        };

      case 'RECON_SUCCESS':
        return {
          'amount': true,
          'transactionMode': true,
          'quickStatus': false, // Already filtered to Perfect
          'remarks': true,
        };

      case 'RECON_INVESTIGATE':
        return {
          'amount': true,
          'transactionMode': true,
          'quickStatus': false, // Already filtered to Investigate
          'remarks': true,
        };

      case 'MANUAL_REFUND':
        return {
          'amount': true,
          'transactionMode': true,
          'quickStatus': true, // Enable Quick Status for Manual Refund
          'remarks': true,
        };

      default:
        return {
          'amount': true,
          'transactionMode': true,
          'quickStatus': true,
          'remarks': true,
        };
    }
  }

// 6. NEW: Get transaction modes for specific sheet
  List<String> _getTransactionModesForSheet(String sheetId) {
    // You can customize this based on what's actually available in each sheet
    switch (sheetId) {
      case 'SUMMARY':
        return ['Paytm', 'PhonePe', 'Cloud', 'PTPP'];
      case 'RAWDATA':
        return ['Paytm', 'PhonePe', 'Cloud', 'PTPP', 'Manual'];
      default:
        return _transactionModes; // Use the full list
    }
  }

// 7. NEW: Get quick statuses for specific sheet
  List<String> _getQuickStatusesForSheet(String sheetId) {
    switch (sheetId) {
      case 'RECON_SUCCESS':
        return ['Perfect']; // Only Perfect makes sense here
      case 'RECON_INVESTIGATE':
        return ['Investigate']; // Only Investigate makes sense here
      case 'MANUAL_REFUND':
        return [
          'Perfect',
          'Investigate',
          'Manual'
        ]; // All statuses available for Manual Refund
      default:
        return _quickStatuses; // Use the full list
    }
  }

  Widget _buildFloatingFilterContent(SheetConfig sheet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search
        TextField(
          controller: _searchControllers[sheet.id],
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: Icon(Icons.search, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
          onChanged: (value) => _onSearchChanged(sheet.id, value),
        ),
        SizedBox(height: 12),

        // Amount range
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minAmountControllers[sheet.id],
                decoration: InputDecoration(
                  labelText: 'Min ₹',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _onFilterChanged(sheet.id),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _maxAmountControllers[sheet.id],
                decoration: InputDecoration(
                  labelText: 'Max ₹',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _onFilterChanged(sheet.id),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Multi-Select Transaction Mode
        _buildMultiSelectField(
          label: 'Transaction Modes',
          selectedItems: _selectedTransactionModesList[sheet.id] ?? [],
          availableItems: _transactionModes,
          onChanged: (selectedItems) {
            setState(() {
              _selectedTransactionModesList[sheet.id] = selectedItems;
            });
            _onFilterChanged(sheet.id);
          },
        ),
        SizedBox(height: 12),

        // Multi-Select Quick Status
        _buildMultiSelectField(
          label: 'Quick Status',
          selectedItems: _selectedQuickStatusesList[sheet.id] ?? [],
          availableItems: _quickStatuses,
          onChanged: (selectedItems) {
            setState(() {
              _selectedQuickStatusesList[sheet.id] = selectedItems;
            });
            _onFilterChanged(sheet.id);
          },
        ),
        SizedBox(height: 12),

        // Remarks
        TextField(
          controller: _remarksControllers[sheet.id],
          decoration: InputDecoration(
            labelText: 'Remarks contains',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            isDense: true,
          ),
          onChanged: (value) => _onFilterChanged(sheet.id),
        ),
        SizedBox(height: 16),

        // Filtered Summary
        _buildFilteredSummary(sheet),
        SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _clearAllFilters(sheet.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                  elevation: 0,
                ),
                child: Text('Clear All'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _showFloatingFilter = false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sheet.color,
                  foregroundColor: Colors.white,
                ),
                child: Text('Apply'),
              ),
            ),
          ],
        ),
      ],
    );
  }

// 4. Add this new method for multi-select fields
  Widget _buildMultiSelectField({
    required String label,
    required List<String> selectedItems,
    required List<String> availableItems,
    required Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              ...selectedItems.map((item) => Chip(
                    label: Text(item, style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.blue[100],
                    deleteIcon: Icon(Icons.close, size: 14),
                    onDeleted: () {
                      final newList = List<String>.from(selectedItems);
                      newList.remove(item);
                      onChanged(newList);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.symmetric(horizontal: 4),
                  )),
              PopupMenuButton<String>(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14),
                      SizedBox(width: 4),
                      Text('Add', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                itemBuilder: (context) => availableItems
                    .where((item) => !selectedItems.contains(item))
                    .map((item) => PopupMenuItem(
                          value: item,
                          child: Text(item, style: TextStyle(fontSize: 12)),
                        ))
                    .toList(),
                onSelected: (item) {
                  final newList = List<String>.from(selectedItems);
                  newList.add(item);
                  onChanged(newList);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

// 5. Add this new method for filtered summary
  Widget _buildFilteredSummary(SheetConfig sheet) {
    return Consumer<ReconProvider>(
      builder: (context, provider, child) {
        final data = provider.getSheetData(sheet.id);
        if (data == null || data.isEmpty) {
          return SizedBox.shrink();
        }

        // ✅ CHECK IF ANY FILTERS ARE ACTIVE
        final hasActiveFilters = _hasAnyActiveFilters(sheet.id);

        // 🚫 DON'T SHOW if no filters are applied
        if (!hasActiveFilters) {
          return SizedBox.shrink(); // Hide the entire filtered summary
        }

        // ✅ SHOW ONLY when filters are active
        final filteredData = _applyFilters(data, sheet.id);
        final totalAmount = _calculateTotalAmount(filteredData);

        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: sheet.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: sheet.color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtered Results',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: sheet.color,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Records',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      Text(
                        '${filteredData.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: sheet.color,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      Text(
                        NumberFormat.currency(symbol: '₹', decimalDigits: 0)
                            .format(totalAmount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: sheet.color,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

// 🔧 ADD THIS NEW HELPER METHOD
// Add this method to your DataScreen class:

  bool _hasAnyActiveFilters(String sheetId) {
    // Check search filter
    final searchQuery = _searchControllers[sheetId]?.text ?? '';
    if (searchQuery.isNotEmpty) return true;

    // Check amount filters
    final minAmount = _minAmountControllers[sheetId]?.text ?? '';
    final maxAmount = _maxAmountControllers[sheetId]?.text ?? '';
    if (minAmount.isNotEmpty || maxAmount.isNotEmpty) return true;

    // Check remarks filter
    final remarks = _remarksControllers[sheetId]?.text ?? '';
    if (remarks.isNotEmpty) return true;

    // Check transaction modes
    final selectedModes = _selectedTransactionModesList[sheetId] ?? [];
    if (selectedModes.isNotEmpty) return true;

    // Check quick status
    final selectedStatuses = _selectedQuickStatusesList[sheetId] ?? [];
    if (selectedStatuses.isNotEmpty) return true;

    return false; // No filters active
  }

// 6. Add this helper method to calculate total amount
  double _calculateTotalAmount(List<Map<String, dynamic>> data) {
    double total = 0.0;

    for (var row in data) {
      // Try different amount fields based on the sheet type
      final amountFields = [
        'Txn_Amount',
        'PTPP_Payment',
        'Cloud_Payment',
        'sum(Txn_Amount)',
        'PTPP_Refund',
        'Cloud_Refund',
        'Cloud_MRefund' // MISSING FIELD ADDED
      ];

      for (String field in amountFields) {
        if (row.containsKey(field) && row[field] != null) {
          final amount = double.tryParse(row[field].toString()) ?? 0.0;
          total += amount;
          break; // Only count the first valid amount field found
        }
      }
    }

    return total;
  }

  // Data Table Building Methods (keeping your existing implementation but optimized)
  Widget _buildDataTableForSheet(
      SheetConfig sheet, List<Map<String, dynamic>> data) {
    switch (sheet.id) {
      case 'SUMMARY':
        return _buildSummaryTable(data);
      case 'RAWDATA':
        return _buildRawDataTable(data);
      case 'RECON_SUCCESS':
      case 'RECON_INVESTIGATE':
      case 'MANUAL_REFUND':
        return _buildReconTable(data, sheet);
      default:
        return _buildGenericTable(data);
    }
  }

  Widget _buildSummaryTable(List<Map<String, dynamic>> data) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 600,
      headingRowHeight: 40,
      dataRowHeight: 36,
      headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
      columns: [
        DataColumn2(
          label: Text('Source',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Type',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Amount',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.M,
          numeric: true,
        ),
      ],
      rows: data
          .map((row) => DataRow2(
                cells: [
                  DataCell(
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(row['txn_source']?.toString() ?? '',
                          style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  DataCell(Text(row['Txn_type']?.toString() ?? '',
                      style: TextStyle(fontSize: 11))),
                  DataCell(
                    Text(
                      currencyFormat.format(
                        double.tryParse(
                                row['sum(Txn_Amount)']?.toString() ?? '0') ??
                            0,
                      ),
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }

  String _getShortMID(String mid) {
    if (mid.isEmpty) return '-';

    // VENDOLITEINDIA03 → VENDOL03
    if (mid.startsWith('VENDOLITEINDIA')) {
      return 'VENDOL${mid.substring(14)}';
    }

    // Auto refund initiated from the machine → Auto Refund
    if (mid.toLowerCase().contains('auto')) {
      return 'Auto Refund';
    }

    // If still too long, cut it
    if (mid.length > 12) {
      return '${mid.substring(0, 10)}..';
    }

    return mid;
  }

// 1. Updated _buildReconTable method with missing fields
  Widget _buildReconTable(List<Map<String, dynamic>> data, SheetConfig sheet) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return DataTable2(
      columnSpacing: 6,
      horizontalMargin: 8,
      minWidth: 1200, // Increased width for additional columns
      headingRowHeight: 40,
      dataRowHeight: 36,
      headingRowColor: MaterialStateProperty.all(sheet.color.withOpacity(0.1)),
      columns: [
        DataColumn2(
          label: Text('Ref No',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Machine',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('MID',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize
              .L, // Changed from ColumnSize.M to ColumnSize.L for more space
        ),
        DataColumn2(
          label: Text('PTPP Pay',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text('PTPP Ref',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text('Cloud Pay',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text('Cloud Ref',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text('Cloud Manual', // MISSING FIELD ADDED
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text('Remarks',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.M,
        ),
      ],
      rows: data
          .map((row) => DataRow2(
                cells: [
                  DataCell(
                    SelectableText(
                      row['Txn_RefNo']?.toString() ?? '',
                      style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ),
                  DataCell(Text(row['Txn_Machine']?.toString() ?? '',
                      style: TextStyle(fontSize: 10))),
                  DataCell(
                    Container(
                      width: double.infinity, // Take full available width
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getMIDColor(row['Txn_MID']?.toString()),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        row['Txn_MID']?.toString() ??
                            '-', // Show full MID without truncation
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow
                            .visible, // Allow text to wrap or expand
                        softWrap: true, // Enable text wrapping
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      currencyFormat.format(
                        double.tryParse(
                                row['PTPP_Payment']?.toString() ?? '0') ??
                            0,
                      ),
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(
                    Text(
                      currencyFormat.format(
                        double.tryParse(
                                row['PTPP_Refund']?.toString() ?? '0') ??
                            0,
                      ),
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(
                    Text(
                      currencyFormat.format(
                        double.tryParse(
                                row['Cloud_Payment']?.toString() ?? '0') ??
                            0,
                      ),
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(
                    Text(
                      currencyFormat.format(
                        double.tryParse(
                                row['Cloud_Refund']?.toString() ?? '0') ??
                            0,
                      ),
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(
                    // MISSING FIELD ADDED
                    Text(
                      currencyFormat.format(
                        double.tryParse(
                                row['Cloud_MRefund']?.toString() ?? '0') ??
                            0,
                      ),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: (double.tryParse(
                                        row['Cloud_MRefund']?.toString() ??
                                            '0') ??
                                    0) !=
                                0
                            ? Colors.red[700]
                            : null,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            _getRemarksColor(row['Remarks']?.toString() ?? ''),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        row['Remarks']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }

// 2. Updated _buildRawDataTable method with missing fields
  Widget _buildRawDataTable(List<Map<String, dynamic>> data) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return DataTable2(
      columnSpacing: 8,
      horizontalMargin: 8,
      minWidth: 1200, // Increased width for additional columns
      headingRowHeight: 40,
      dataRowHeight: 36,
      headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
      columns: [
        DataColumn2(
          label: Text('Ref No',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Source',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Type',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Machine',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('MID',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.L, // Changed from ColumnSize.M to ColumnSize.L
        ),
        DataColumn2(
          label: Text('Date', // MISSING FIELD ADDED
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Amount',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          size: ColumnSize.S,
          numeric: true,
        ),
      ],
      rows: data
          .map((row) => DataRow2(
                cells: [
                  DataCell(
                    SelectableText(
                      row['Txn_RefNo']?.toString() ?? '',
                      style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: _getSourceColor(row['Txn_Source']?.toString()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        row['Txn_Source']?.toString() ?? '',
                        style: TextStyle(fontSize: 9, color: Colors.white),
                      ),
                    ),
                  ),
                  DataCell(Text(row['Txn_Type']?.toString() ?? '',
                      style: TextStyle(fontSize: 10))),
                  DataCell(Text(row['Txn_Machine']?.toString() ?? '',
                      style: TextStyle(fontSize: 10))),
                  DataCell(
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getShortMID(row['Txn_MID']?.toString() ?? ''),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  DataCell(
                    // MISSING FIELD ADDED
                    Text(
                      _formatDate(row['Txn_Date']?.toString() ?? ''),
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  DataCell(
                    Text(
                      currencyFormat.format(
                        double.tryParse(row['Txn_Amount']?.toString() ?? '0') ??
                            0,
                      ),
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }

  Widget _buildGenericTable(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return Center(child: Text('No data available'));

    final columns = data.first.keys.take(6).toList();

    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: columns.length * 120.0,
      headingRowHeight: 40,
      dataRowHeight: 36,
      headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
      columns: columns
          .map((column) => DataColumn2(
                label: Text(column,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                size: ColumnSize.M,
              ))
          .toList(),
      rows: data
          .map((row) => DataRow2(
                cells: columns
                    .map((column) => DataCell(
                          Text(
                            _formatCellValue(row[column]),
                            style: TextStyle(fontSize: 10),
                          ),
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }

  // Loading and Error States
  Widget _buildLoadingState(SheetConfig sheet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: sheet.color, strokeWidth: 2),
          SizedBox(height: 12),
          Text('Loading ${sheet.name.toLowerCase()}...',
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

// Helper method to get MID color coding
  Color _getMIDColor(String? mid) {
    if (mid == null || mid.isEmpty) return Colors.grey[400]!;

    final midLower = mid.toLowerCase();
    if (midLower.contains('vendol')) {
      return Colors.indigo[600]!;
    } else if (midLower.contains('india')) {
      return Colors.teal[600]!;
    } else if (midLower.contains('auto') || midLower.contains('manual')) {
      return Colors.orange[600]!;
    }
    return Colors.blue[600]!;
  }

// Helper method to format date display
  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '-';

    try {
      // Handle different date formats that might come from Excel
      DateTime? date;

      // Try parsing common Excel date formats
      if (dateStr.contains('-')) {
        date = DateTime.tryParse(dateStr);
      } else if (dateStr.length == 8) {
        // Handle YYYYMMDD format
        final year = int.tryParse(dateStr.substring(0, 4));
        final month = int.tryParse(dateStr.substring(4, 6));
        final day = int.tryParse(dateStr.substring(6, 8));
        if (year != null && month != null && day != null) {
          date = DateTime(year, month, day);
        }
      }

      if (date != null) {
        return DateFormat('MMM dd, yy').format(date);
      }

      // If parsing fails, return truncated string
      return dateStr.length > 12 ? '${dateStr.substring(0, 12)}...' : dateStr;
    } catch (e) {
      return dateStr.length > 12 ? '${dateStr.substring(0, 12)}...' : dateStr;
    }
  }

  Widget _buildEmptyState(SheetConfig sheet, ReconProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(40),
            ),
            child:
                Icon(Icons.inbox_outlined, size: 40, color: Colors.grey[400]),
          ),
          SizedBox(height: 12),
          Text('No data available',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Text('No records found for ${sheet.name}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => provider.loadSheet(sheet.id),
            icon: Icon(Icons.refresh, size: 16),
            label: Text('Reload Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: sheet.color,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(SheetConfig sheet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(Icons.search_off, size: 40, color: Colors.orange[400]),
          ),
          SizedBox(height: 12),
          Text('No results found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Text('Try adjusting your filters or search criteria',
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _clearAllFilters(sheet.id),
            icon: Icon(Icons.clear_all, size: 16),
            label: Text('Clear All Filters'),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateFinancialBreakdown(
      List<Map<String, dynamic>> data) {
    double ptppPayment = 0.0;
    double ptppRefund = 0.0;
    double cloudPayment = 0.0;
    double cloudRefund = 0.0;
    double cloudManualRefund = 0.0;

    for (var row in data) {
      ptppPayment +=
          double.tryParse(row['PTPP_Payment']?.toString() ?? '0') ?? 0.0;
      ptppRefund +=
          double.tryParse(row['PTPP_Refund']?.toString() ?? '0') ?? 0.0;
      cloudPayment +=
          double.tryParse(row['Cloud_Payment']?.toString() ?? '0') ?? 0.0;
      cloudRefund +=
          double.tryParse(row['Cloud_Refund']?.toString() ?? '0') ?? 0.0;
      cloudManualRefund +=
          double.tryParse(row['Cloud_MRefund']?.toString() ?? '0') ?? 0.0;
    }

    return {
      'ptpp_payment': ptppPayment,
      'ptpp_refund': ptppRefund,
      'total_ptpp': ptppPayment + ptppRefund,
      'cloud_payment': cloudPayment,
      'cloud_refund': cloudRefund,
      'cloud_manual_refund': cloudManualRefund,
      'total_cloud': cloudPayment + cloudRefund + cloudManualRefund,
    };
  }

// 4. Add this new widget method
  Widget _buildFinancialBreakdownHeader(
      SheetConfig sheet, List<Map<String, dynamic>>? data) {
    // Only show for reconciliation sheets
    if (!['RECON_SUCCESS', 'RECON_INVESTIGATE', 'MANUAL_REFUND']
        .contains(sheet.id)) {
      return SizedBox.shrink();
    }

    if (data == null || data.isEmpty) {
      return SizedBox.shrink();
    }

    final breakdown = _calculateFinancialBreakdown(data);
    final isExpanded = _isFinancialBreakdownExpanded[sheet.id] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Compact Header - Always Visible
          InkWell(
            onTap: () {
              setState(() {
                _isFinancialBreakdownExpanded[sheet.id] = !isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: sheet.color,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Financial Summary',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: 8),
                  // Quick totals in compact view
                  if (!isExpanded) ...[
                    _buildQuickTotal(
                        'PTPP', breakdown['total_ptpp']!, Colors.blue),
                    SizedBox(width: 6),
                    _buildQuickTotal(
                        'Cloud', breakdown['total_cloud']!, Colors.green),
                  ],
                  Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),

          // Expandable Details
          if (isExpanded)
            Container(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  // PTPP Breakdown
                  Expanded(
                    child: _buildBreakdownSection(
                      'PTPP',
                      Colors.blue,
                      [
                        {
                          'label': 'Payment',
                          'value': breakdown['ptpp_payment']!
                        },
                        {'label': 'Refund', 'value': breakdown['ptpp_refund']!},
                      ],
                      breakdown['total_ptpp']!,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.grey[300],
                    margin: EdgeInsets.symmetric(horizontal: 12),
                  ),

                  // Cloud Breakdown
                  Expanded(
                    child: _buildBreakdownSection(
                      'Cloud',
                      Colors.green,
                      [
                        {
                          'label': 'Payment',
                          'value': breakdown['cloud_payment']!
                        },
                        {
                          'label': 'Refund',
                          'value': breakdown['cloud_refund']!
                        },
                        {
                          'label': 'Manual',
                          'value': breakdown['cloud_manual_refund']!
                        },
                      ],
                      breakdown['total_cloud']!,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

// 5. Add helper widgets
  Widget _buildQuickTotal(String label, double amount, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: ${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(amount)}',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildBreakdownSection(String title, Color color,
      List<Map<String, dynamic>> items, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),

        // Individual Items
        ...items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['label'],
                    style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '₹', decimalDigits: 0)
                        .format(item['value']),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            )),

        // Divider
        Container(
          height: 1,
          color: color.withOpacity(0.3),
          margin: EdgeInsets.symmetric(vertical: 3),
        ),

        // Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              NumberFormat.currency(symbol: '₹', decimalDigits: 0)
                  .format(total),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper Methods
  Color _getRemarksColor(String remarks) {
    switch (remarks.toLowerCase()) {
      case 'perfect':
        return Colors.green[600]!;
      case 'investigate':
        return Colors.orange[600]!;
      case 'manual':
        return Colors.purple[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  Color _getSourceColor(String? source) {
    switch (source?.toLowerCase()) {
      case 'paytm':
        return Colors.blue[600]!;
      case 'phonepe':
        return Colors.purple[600]!;
      case 'cloud':
        return Colors.green[600]!;
      case 'ptpp':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _formatCellValue(dynamic value) {
    if (value == null) return '';
    if (value is num && value > 1000) {
      return NumberFormat('#,##0.00').format(value);
    }
    return value.toString();
  }

  int _getTotalRecords(ReconProvider provider) {
    int total = 0;
    for (String sheetId in [
      'SUMMARY',
      'RAWDATA',
      'RECON_SUCCESS',
      'RECON_INVESTIGATE',
      'MANUAL_REFUND'
    ]) {
      final data = provider.getSheetData(sheetId);
      if (data != null) total += data.length;
    }
    return total;
  }

  int _getSuccessRate(ReconProvider provider) {
    final successData = provider.getSheetData('RECON_SUCCESS');
    final investigateData = provider.getSheetData('RECON_INVESTIGATE');
    final totalRecon =
        (successData?.length ?? 0) + (investigateData?.length ?? 0);

    if (totalRecon == 0) return 0;
    return ((successData?.length ?? 0) * 100 / totalRecon).round();
  }

  // List<Map<String, dynamic>> _applyFilters(
  //     List<Map<String, dynamic>> data, String sheetId) {
  //   final searchQuery = _searchControllers[sheetId]?.text.toLowerCase() ?? '';
  //   final minAmount =
  //       double.tryParse(_minAmountControllers[sheetId]?.text ?? '');
  //   final maxAmount =
  //       double.tryParse(_maxAmountControllers[sheetId]?.text ?? '');
  //   final remarksFilter =
  //       _remarksControllers[sheetId]?.text.toLowerCase() ?? '';
  //   final modeFilter = _selectedTransactionModes[sheetId] ?? 'All';
  //   final statusFilter = _selectedQuickStatuses[sheetId] ?? 'All';

  //   return data.where((row) {
  //     // Search filter
  //     if (searchQuery.isNotEmpty) {
  //       bool matchesSearch = row.values.any((value) =>
  //           value?.toString().toLowerCase().contains(searchQuery) ?? false);
  //       if (!matchesSearch) return false;
  //     }

  //     // Amount range filter
  //     if (minAmount != null || maxAmount != null) {
  //       final amount = _getAmountFromRow(row);
  //       if (amount != null) {
  //         if (minAmount != null && amount < minAmount) return false;
  //         if (maxAmount != null && amount > maxAmount) return false;
  //       }
  //     }

  //     // Remarks filter
  //     if (remarksFilter.isNotEmpty) {
  //       final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
  //       if (!remarks.contains(remarksFilter)) return false;
  //     }

  //     // Transaction mode filter
  //     if (modeFilter != 'All') {
  //       final source = row['Txn_Source']?.toString() ?? '';
  //       if (!source.toLowerCase().contains(modeFilter.toLowerCase()))
  //         return false;
  //     }

  //     // Quick status filter
  //     if (statusFilter != 'All') {
  //       final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
  //       if (!remarks.contains(statusFilter.toLowerCase())) return false;
  //     }

  //     return true;
  //   }).toList();
  // }

  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> data, String sheetId) {
    final searchQuery = _searchControllers[sheetId]?.text.toLowerCase() ?? '';
    final minAmount =
        double.tryParse(_minAmountControllers[sheetId]?.text ?? '');
    final maxAmount =
        double.tryParse(_maxAmountControllers[sheetId]?.text ?? '');
    final remarksFilter =
        _remarksControllers[sheetId]?.text.toLowerCase() ?? '';

    // Updated to use multi-select lists
    final selectedModes = _selectedTransactionModesList[sheetId] ?? [];
    final selectedStatuses = _selectedQuickStatusesList[sheetId] ?? [];

    // Calculate total amount for all records (before filtering)
    _totalAmounts[sheetId] = _calculateTotalAmountForSheet(data, sheetId);

    final filteredData = data.where((row) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        bool matchesSearch = row.values.any((value) =>
            value?.toString().toLowerCase().contains(searchQuery) ?? false);
        if (!matchesSearch) return false;
      }

      // Amount range filter
      if (minAmount != null || maxAmount != null) {
        final amount = _getAmountFromRow(row);
        if (amount != null) {
          if (minAmount != null && amount < minAmount) return false;
          if (maxAmount != null && amount > maxAmount) return false;
        }
      }

      // Remarks filter
      if (remarksFilter.isNotEmpty) {
        final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
        if (!remarks.contains(remarksFilter)) return false;
      }

      // Multi-select transaction mode filter
      if (selectedModes.isNotEmpty) {
        final source = row['Txn_Source']?.toString() ?? '';
        bool matchesMode = selectedModes
            .any((mode) => source.toLowerCase().contains(mode.toLowerCase()));
        if (!matchesMode) return false;
      }

      // Multi-select status filter
      if (selectedStatuses.isNotEmpty) {
        final remarks = row['Remarks']?.toString().toLowerCase() ?? '';
        bool matchesStatus = selectedStatuses
            .any((status) => remarks.contains(status.toLowerCase()));
        if (!matchesStatus) return false;
      }

      return true;
    }).toList();

    // Calculate filtered totals
    _filteredAmounts[sheetId] =
        _calculateTotalAmountForSheet(filteredData, sheetId);
    _filteredCounts[sheetId] = filteredData.length;

    return filteredData;
  }

  double _calculateTotalAmountForSheet(
      List<Map<String, dynamic>> data, String sheetId) {
    double total = 0.0;

    for (var row in data) {
      switch (sheetId) {
        case 'SUMMARY':
          // For summary, use sum(Txn_Amount)
          final amount =
              double.tryParse(row['sum(Txn_Amount)']?.toString() ?? '0') ?? 0.0;
          total += amount;
          break;

        case 'RAWDATA':
          // For raw data, use Txn_Amount
          final amount =
              double.tryParse(row['Txn_Amount']?.toString() ?? '0') ?? 0.0;
          total += amount;
          break;

        case 'RECON_SUCCESS':
        case 'RECON_INVESTIGATE':
        case 'MANUAL_REFUND':
          // For reconciliation tabs, sum positive amounts only
          final ptppPay =
              double.tryParse(row['PTPP_Payment']?.toString() ?? '0') ?? 0.0;
          final cloudPay =
              double.tryParse(row['Cloud_Payment']?.toString() ?? '0') ?? 0.0;
          final cloudMRef =
              double.tryParse(row['Cloud_MRefund']?.toString() ?? '0') ?? 0.0;

          if (sheetId == 'MANUAL_REFUND') {
            total += cloudMRef; // Focus on manual refunds
          } else {
            total +=
                (ptppPay + cloudPay); // Focus on payments for other recon tabs
          }
          break;

        default:
          // Fallback to generic amount detection
          final amount = _getAmountFromRow(row) ?? 0.0;
          total += amount;
      }
    }

    return total;
  }

  Widget _buildTotalAmountDisplay(SheetConfig sheet) {
    final totalAmount = _totalAmounts[sheet.id] ?? 0.0;
    final filteredAmount = _filteredAmounts[sheet.id] ?? 0.0;
    final filteredCount = _filteredCounts[sheet.id] ?? 0;
    final hasFilters = _activeFilters[sheet.id]?.isNotEmpty == true;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: sheet.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: sheet.color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total Records Display
          Row(
            children: [
              Icon(Icons.receipt_long, size: 14, color: sheet.color),
              SizedBox(width: 4),
              Text(
                hasFilters
                    ? 'Filtered: $filteredCount records'
                    : 'Total: ${(_totalAmounts[sheet.id] != null ? _filteredCounts[sheet.id] ?? 0 : 0)} records',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          // Amount Display
          Row(
            children: [
              Icon(Icons.currency_rupee, size: 14, color: sheet.color),
              SizedBox(width: 4),
              Text(
                hasFilters
                    ? NumberFormat.currency(symbol: '₹', decimalDigits: 0)
                        .format(filteredAmount)
                    : NumberFormat.currency(symbol: '₹', decimalDigits: 0)
                        .format(totalAmount),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: sheet.color,
                ),
              ),
              if (hasFilters) ...[
                SizedBox(width: 4),
                Text(
                  'of ${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(totalAmount)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  double? _getAmountFromRow(Map<String, dynamic> row) {
    final amountFields = [
      'Txn_Amount',
      'PTPP_Payment',
      'Cloud_Payment',
      'sum(Txn_Amount)'
    ];

    for (String field in amountFields) {
      if (row.containsKey(field)) {
        return double.tryParse(row[field]?.toString() ?? '0');
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _getPaginatedData(
      List<Map<String, dynamic>> data, String sheetId) {
    if (data.isEmpty) return [];

    final startIndex = (_currentPage[sheetId] ?? 0) * _itemsPerPage;

    // 🔧 SIMPLE FIX: If start is beyond data, reset to page 0
    if (startIndex >= data.length) {
      _currentPage[sheetId] = 0;
      return data.take(_itemsPerPage).toList();
    }

    final endIndex = (startIndex + _itemsPerPage).clamp(0, data.length);
    return data.sublist(startIndex, endIndex);
  }

  void _onSearchChanged(String sheetId, String value) {
    setState(() {
      _currentPage[sheetId] = 0;
    });
    _updateActiveFilters(sheetId);
  }

  void _onFilterChanged(String sheetId) {
    setState(() {
      _currentPage[sheetId] = 0;
    });
    _updateActiveFilters(sheetId);
  }

  // void _updateActiveFilters(String sheetId) {
  //   List<String> filters = [];

  //   final searchQuery = _searchControllers[sheetId]?.text ?? '';
  //   if (searchQuery.isNotEmpty) {
  //     filters.add('Search: "$searchQuery"');
  //   }

  //   final minAmount = _minAmountControllers[sheetId]?.text ?? '';
  //   final maxAmount = _maxAmountControllers[sheetId]?.text ?? '';
  //   if (minAmount.isNotEmpty || maxAmount.isNotEmpty) {
  //     filters.add('Amount: ₹$minAmount - ₹$maxAmount');
  //   }

  //   final remarks = _remarksControllers[sheetId]?.text ?? '';
  //   if (remarks.isNotEmpty) {
  //     filters.add('Remarks: "$remarks"');
  //   }

  //   final mode = _selectedTransactionModes[sheetId] ?? 'All';
  //   if (mode != 'All') {
  //     filters.add('Mode: $mode');
  //   }

  //   final status = _selectedQuickStatuses[sheetId] ?? 'All';
  //   if (status != 'All') {
  //     filters.add('Status: $status');
  //   }

  //   setState(() {
  //     _activeFilters[sheetId] = filters;
  //   });
  // }

  void _updateActiveFilters(String sheetId) {
    List<String> filters = [];

    final searchQuery = _searchControllers[sheetId]?.text ?? '';
    if (searchQuery.isNotEmpty) {
      filters.add('Search: "$searchQuery"');
    }

    final minAmount = _minAmountControllers[sheetId]?.text ?? '';
    final maxAmount = _maxAmountControllers[sheetId]?.text ?? '';
    if (minAmount.isNotEmpty || maxAmount.isNotEmpty) {
      filters.add('Amount: ₹$minAmount - ₹$maxAmount');
    }

    final remarks = _remarksControllers[sheetId]?.text ?? '';
    if (remarks.isNotEmpty) {
      filters.add('Remarks: "$remarks"');
    }

    // Updated for multi-select
    final selectedModes = _selectedTransactionModesList[sheetId] ?? [];
    if (selectedModes.isNotEmpty) {
      filters.add('Modes: ${selectedModes.join(", ")}');
    }

    final selectedStatuses = _selectedQuickStatusesList[sheetId] ?? [];
    if (selectedStatuses.isNotEmpty) {
      filters.add('Status: ${selectedStatuses.join(", ")}');
    }

    setState(() {
      _activeFilters[sheetId] = filters;
    });
  }

  void _removeFilter(String sheetId, String filter) {
    if (filter.startsWith('Search:')) {
      _searchControllers[sheetId]?.clear();
    } else if (filter.startsWith('Amount:')) {
      _minAmountControllers[sheetId]?.clear();
      _maxAmountControllers[sheetId]?.clear();
    } else if (filter.startsWith('Remarks:')) {
      _remarksControllers[sheetId]?.clear();
    } else if (filter.startsWith('Modes:')) {
      _selectedTransactionModesList[sheetId] = [];
    } else if (filter.startsWith('Status:')) {
      _selectedQuickStatusesList[sheetId] = [];
    }

    _onFilterChanged(sheetId);
  }

//   void _clearAllFilters(String sheetId) {
//     setState(() {
//       _searchControllers[sheetId]?.clear();
//       _minAmountControllers[sheetId]?.clear();
//       _maxAmountControllers[sheetId]?.clear();
//       _remarksControllers[sheetId]?.clear();
//       _selectedTransactionModes[sheetId] = 'All'; // Keep existing single select
//       _selectedQuickStatuses[sheetId] = 'All'; // Keep existing single select

//       // Clear new multi-select lists
//       _selectedTransactionModesList[sheetId] = [];
//       _selectedQuickStatusesList[sheetId] = [];

//       _currentPage[sheetId] = 0;
//       _activeFilters[sheetId] = [];
//     });
//   }

  void _clearAllFilters(String sheetId) {
    setState(() {
      // Clear all filter controllers
      _searchControllers[sheetId]?.clear();
      _minAmountControllers[sheetId]?.clear();
      _maxAmountControllers[sheetId]?.clear();
      _remarksControllers[sheetId]?.clear();

      // Reset single select dropdowns
      _selectedTransactionModes[sheetId] = 'All';
      _selectedQuickStatuses[sheetId] = 'All';

      // Clear multi-select lists
      _selectedTransactionModesList[sheetId] = [];
      _selectedQuickStatusesList[sheetId] = [];

      // Reset pagination
      _currentPage[sheetId] = 0;

      // Clear active filters
      _activeFilters[sheetId] = [];

      // Reset totals
      _filteredAmounts[sheetId] = _totalAmounts[sheetId] ?? 0.0;
      _filteredCounts[sheetId] = 0;
    });
  }

  void _changePage(String sheetId, int newPage) {
    setState(() {
      _currentPage[sheetId] = newPage;
    });
  }
}

class SheetConfig {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final Color color;

  SheetConfig(this.id, this.name, this.icon, this.description, this.color);
}

// Add these extension methods at the bottom of the file for null safety
extension SafeColor on Color? {
  Color get safe => this ?? Colors.grey;
}

extension SafeColorWithOpacity on Color {
  Color safeWithOpacity(double opacity) {
    try {
      return this.withOpacity(opacity);
    } catch (e) {
      return Colors.grey.withOpacity(opacity);
    }
  }
}
