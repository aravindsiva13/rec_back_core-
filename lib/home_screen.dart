// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'database_service.dart';
// import 'data_screen.dart';
// import 'dart:async';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _isLoading = false;
//   bool _isProcessing = false;
//   List<dynamic> _reconData = [];
//   String _statusMessage = '';
//   Timer? _statusTimer;
//   PlatformFile? _selectedFile;
//   double _processingProgress = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _loadReconData();
//   }

//   @override
//   void dispose() {
//     _statusTimer?.cancel();
//     super.dispose();
//   }

//   // Load reconciliation data from database
//   Future<void> _loadReconData() async {
//     setState(() {
//       _isLoading = true;
//       _statusMessage = 'Loading data...';
//     });

//     try {
//       final response = await DatabaseService.getReconSummary();
//       if (response['status'] == 'success') {
//         setState(() {
//           _reconData = response['data'] ?? [];
//           _statusMessage =
//               'Data loaded successfully (${_reconData.length} records)';
//         });
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

//   // Pick and upload file
//   Future<void> _pickAndUploadFile() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['zip', 'xlsx', 'xls', 'csv'],
//         allowMultiple: false,
//       );

//       if (result != null) {
//         _selectedFile = result.files.first;

//         setState(() {
//           _isLoading = true;
//           _statusMessage = 'Uploading ${_selectedFile!.name}...';
//         });

//         final response = await DatabaseService.uploadFile(_selectedFile!);

//         if (response['success'] == true) {
//           setState(() {
//             _statusMessage =
//                 'File uploaded successfully: ${response['filename']}';
//           });
//         } else {
//           setState(() {
//             _statusMessage = 'Upload failed: ${response['error']}';
//           });
//         }
//       }
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Upload error: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Start processing and monitor status
//   Future<void> _startProcessing() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _statusMessage = 'Starting processing...';
//       });

//       final response = await DatabaseService.startProcessing();

//       if (response['success'] == true) {
//         setState(() {
//           _isProcessing = true;
//           _statusMessage = 'Processing started successfully';
//           _processingProgress = 0.0;
//         });

//         // Start monitoring processing status
//         _startStatusMonitoring();
//       } else {
//         setState(() {
//           _statusMessage = 'Failed to start processing: ${response['error']}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Processing error: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Monitor processing status
//   void _startStatusMonitoring() {
//     _statusTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
//       try {
//         final statusResponse = await DatabaseService.getProcessingStatus();
//         final status = statusResponse['status'];

//         setState(() {
//           _isProcessing = status['is_processing'] ?? false;
//           _processingProgress = (status['progress'] ?? 0).toDouble();
//           _statusMessage = status['message'] ?? 'Processing...';
//         });

//         // Check if processing is complete
//         if (status['completed'] == true || status['is_processing'] == false) {
//           timer.cancel();
//           setState(() {
//             _isProcessing = false;
//           });

//           if (status['completed'] == true) {
//             _statusMessage = 'Processing completed successfully!';
//             // Automatically reload data after processing completes
//             await _loadReconData();
//           } else if (status['error'] != null) {
//             _statusMessage = 'Processing failed: ${status['error']}';
//           }
//         }
//       } catch (e) {
//         setState(() {
//           _statusMessage = 'Status check error: $e';
//         });
//       }
//     });
//   }

//   // Refresh data
//   Future<void> _refreshData() async {
//     await _loadReconData();
//   }

//   // Get latest transaction date
//   String _getLatestDate() {
//     if (_reconData.isEmpty) return 'N/A';
//     try {
//       String latest = _reconData.first['Txn_Date']?.toString() ?? '';
//       return latest.split('T')[0];
//     } catch (e) {
//       return 'N/A';
//     }
//   }

//   // Get number of unique transaction sources
//   int _getUniqueSources() {
//     if (_reconData.isEmpty) return 0;
//     Set<String> sources = _reconData
//         .map((item) => item['Txn_Source']?.toString() ?? '')
//         .where((source) => source.isNotEmpty)
//         .toSet();
//     return sources.length;
//   }

//   // Build quick stat widget
//   Widget _buildQuickStat(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.blue,
//           ),
//         ),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Colors.grey,
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Reconciliation Dashboard'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _isLoading ? null : _refreshData,
//             tooltip: 'Refresh Data',
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Control Panel
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Control Panel',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 16),

//                     // File Upload Section
//                     Row(
//                       children: [
//                         ElevatedButton.icon(
//                           onPressed: _isLoading || _isProcessing
//                               ? null
//                               : _pickAndUploadFile,
//                           icon: const Icon(Icons.upload_file),
//                           label: const Text('Upload File'),
//                         ),
//                         const SizedBox(width: 16),
//                         if (_selectedFile != null)
//                           Expanded(
//                             child: Text(
//                               'Selected: ${_selectedFile!.name}',
//                               style: const TextStyle(fontSize: 12),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),

//                     // Processing Section
//                     Row(
//                       children: [
//                         ElevatedButton.icon(
//                           onPressed: _isLoading || _isProcessing
//                               ? null
//                               : _startProcessing,
//                           icon: const Icon(Icons.play_arrow),
//                           label: const Text('Start Processing'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         if (_isProcessing)
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                     'Progress: ${_processingProgress.toInt()}%'),
//                                 const SizedBox(height: 4),
//                                 LinearProgressIndicator(
//                                   value: _processingProgress / 100,
//                                   backgroundColor: Colors.grey[300],
//                                   valueColor:
//                                       const AlwaysStoppedAnimation<Color>(
//                                           Colors.blue),
//                                 ),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),

//                     // Status Message
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(8.0),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         'Status: $_statusMessage',
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Data Table Section
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Reconciliation Summary Data',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const DataScreen()),
//                     );
//                   },
//                   icon: const Icon(Icons.table_view),
//                   label: const Text('View Full Data'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),

//             Expanded(
//               child: Card(
//                 child: _isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : _reconData.isEmpty
//                         ? const Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.table_chart,
//                                     size: 64, color: Colors.grey),
//                                 SizedBox(height: 16),
//                                 Text(
//                                   'No data available',
//                                   style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   'Upload files and start processing to see reconciliation data.',
//                                   style: TextStyle(
//                                       fontSize: 14, color: Colors.grey),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : Column(
//                             children: [
//                               // Quick summary
//                               Container(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceAround,
//                                   children: [
//                                     _buildQuickStat('Total Records',
//                                         _reconData.length.toString()),
//                                     _buildQuickStat(
//                                         'Latest Date', _getLatestDate()),
//                                     _buildQuickStat('Sources',
//                                         _getUniqueSources().toString()),
//                                   ],
//                                 ),
//                               ),
//                               const Divider(),
//                               // Sample data preview
//                               Expanded(
//                                 child: SingleChildScrollView(
//                                   padding: const EdgeInsets.all(16),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       const Text(
//                                         'Recent Transactions (Sample):',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       ..._reconData
//                                           .take(5)
//                                           .map((item) => Container(
//                                                 margin: const EdgeInsets.only(
//                                                     bottom: 8),
//                                                 padding:
//                                                     const EdgeInsets.all(12),
//                                                 decoration: BoxDecoration(
//                                                   border: Border.all(
//                                                       color:
//                                                           Colors.grey.shade300),
//                                                   borderRadius:
//                                                       BorderRadius.circular(8),
//                                                 ),
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       'Txn: ${item['Txn_RefNo']} - ${item['Txn_Type']}',
//                                                       style: const TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.bold),
//                                                     ),
//                                                     Text(
//                                                         'Date: ${item['Txn_Date']?.toString().split('T')[0]}'),
//                                                     Text(
//                                                         'Cloud: ₹${item['Cloud_Payment']} | Paytm: ₹${item['Paytm_Payment']} | Card: ₹${item['Card_Payment']}'),
//                                                   ],
//                                                 ),
//                                               ))
//                                           .toList(),
//                                       const SizedBox(height: 16),
//                                       Center(
//                                         child: ElevatedButton.icon(
//                                           onPressed: () {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       const DataScreen()),
//                                             );
//                                           },
//                                           icon: const Icon(Icons.table_view),
//                                           label: const Text(
//                                               'View All Data in Table'),
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.blue,
//                                             foregroundColor: Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//2

// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'database_service.dart';
// import 'data_screen.dart';
// import 'dart:async';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _isLoading = false;
//   bool _isProcessing = false;
//   List<dynamic> _reconData = [];
//   String _statusMessage = '';
//   Timer? _statusTimer;
//   List<PlatformFile> _selectedFiles = [];
//   double _processingProgress = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _loadReconData();
//   }

//   @override
//   void dispose() {
//     _statusTimer?.cancel();
//     super.dispose();
//   }

//   // Load reconciliation data from database
//   Future<void> _loadReconData() async {
//     setState(() {
//       _isLoading = true;
//       _statusMessage = 'Loading data...';
//     });

//     try {
//       final response = await DatabaseService.getReconSummary();
//       if (response['status'] == 'success') {
//         setState(() {
//           _reconData = response['data'] ?? [];
//           _statusMessage =
//               'Data loaded successfully (${_reconData.length} records)';
//         });
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

//   // Pick and upload multiple files
//   Future<void> _pickAndUploadFiles() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['zip', 'xlsx', 'xls', 'csv'],
//         allowMultiple: true, // Enable multiple file selection
//       );

//       if (result != null && result.files.isNotEmpty) {
//         _selectedFiles = result.files;

//         setState(() {
//           _isLoading = true;
//           _statusMessage = 'Uploading ${_selectedFiles.length} file(s)...';
//         });

//         // Upload all files
//         final results =
//             await DatabaseService.uploadMultipleFiles(_selectedFiles);

//         // Count successful uploads
//         int successCount = results.where((r) => r['success'] == true).length;
//         int failCount = results.where((r) => r['success'] == false).length;

//         if (failCount == 0) {
//           setState(() {
//             _statusMessage = 'All $successCount files uploaded successfully!';
//           });
//         } else {
//           setState(() {
//             _statusMessage =
//                 '$successCount files uploaded, $failCount failed. Check details below.';
//           });
//         }

//         // Show detailed results
//         _showUploadResults(results);
//       }
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Upload error: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Show upload results dialog
//   void _showUploadResults(List<Map<String, dynamic>> results) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Upload Results'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: results.length,
//             itemBuilder: (context, index) {
//               final result = results[index];
//               return ListTile(
//                 leading: Icon(
//                   result['success'] ? Icons.check_circle : Icons.error,
//                   color: result['success'] ? Colors.green : Colors.red,
//                 ),
//                 title: Text(result['filename']),
//                 subtitle: Text(
//                   result['success']
//                       ? 'Uploaded successfully'
//                       : 'Failed: ${result['error']}',
//                 ),
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Start processing and monitor status
//   Future<void> _startProcessing() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _statusMessage = 'Starting processing...';
//       });

//       final response = await DatabaseService.startProcessing();

//       if (response['success'] == true) {
//         setState(() {
//           _isProcessing = true;
//           _statusMessage = 'Processing started successfully';
//           _processingProgress = 0.0;
//         });

//         // Start monitoring processing status
//         _startStatusMonitoring();
//       } else {
//         setState(() {
//           _statusMessage = 'Failed to start processing: ${response['error']}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Processing error: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Monitor processing status
//   void _startStatusMonitoring() {
//     _statusTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
//       try {
//         final statusResponse = await DatabaseService.getProcessingStatus();
//         final status = statusResponse['status'];

//         setState(() {
//           _isProcessing = status['is_processing'] ?? false;
//           _processingProgress = (status['progress'] ?? 0).toDouble();
//           _statusMessage = status['message'] ?? 'Processing...';
//         });

//         // Check if processing is complete
//         if (status['completed'] == true || status['is_processing'] == false) {
//           timer.cancel();
//           setState(() {
//             _isProcessing = false;
//           });

//           if (status['completed'] == true) {
//             _statusMessage = 'Processing completed successfully!';
//             // Automatically reload data after processing completes
//             await _loadReconData();
//           } else if (status['error'] != null) {
//             _statusMessage = 'Processing failed: ${status['error']}';
//           }
//         }
//       } catch (e) {
//         setState(() {
//           _statusMessage = 'Status check error: $e';
//         });
//       }
//     });
//   }

//   // Refresh data
//   Future<void> _refreshData() async {
//     await _loadReconData();
//   }

//   // Get latest transaction date
//   String _getLatestDate() {
//     if (_reconData.isEmpty) return 'N/A';
//     try {
//       String latest = _reconData.first['Txn_Date']?.toString() ?? '';
//       return latest.split('T')[0];
//     } catch (e) {
//       return 'N/A';
//     }
//   }

//   // Get number of unique transaction sources
//   int _getUniqueSources() {
//     if (_reconData.isEmpty) return 0;
//     Set<String> sources = _reconData
//         .map((item) => item['Txn_Source']?.toString() ?? '')
//         .where((source) => source.isNotEmpty)
//         .toSet();
//     return sources.length;
//   }

//   // Build quick stat widget
//   Widget _buildQuickStat(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.blue,
//           ),
//         ),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Colors.grey,
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Reconciliation Dashboard'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _isLoading ? null : _refreshData,
//             tooltip: 'Refresh Data',
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Control Panel
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Control Panel',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 16),

//                     // File Upload Section
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             ElevatedButton.icon(
//                               onPressed: _isLoading || _isProcessing
//                                   ? null
//                                   : _pickAndUploadFiles,
//                               icon: const Icon(Icons.upload_file),
//                               label: const Text('Upload Files'),
//                             ),
//                             const SizedBox(width: 16),
//                             ElevatedButton.icon(
//                               onPressed: _selectedFiles.isEmpty
//                                   ? null
//                                   : () {
//                                       setState(() {
//                                         _selectedFiles.clear();
//                                       });
//                                     },
//                               icon: const Icon(Icons.clear),
//                               label: const Text('Clear'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.orange,
//                                 foregroundColor: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         if (_selectedFiles.isNotEmpty)
//                           Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.blue.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(4),
//                               border: Border.all(
//                                   color: Colors.blue.withOpacity(0.3)),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Selected Files (${_selectedFiles.length}):',
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 ..._selectedFiles
//                                     .map((file) => Padding(
//                                           padding:
//                                               const EdgeInsets.only(bottom: 2),
//                                           child: Row(
//                                             children: [
//                                               const Icon(
//                                                   Icons.insert_drive_file,
//                                                   size: 16,
//                                                   color: Colors.blue),
//                                               const SizedBox(width: 4),
//                                               Expanded(
//                                                 child: Text(
//                                                   file.name,
//                                                   style: const TextStyle(
//                                                       fontSize: 11),
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 '${(file.size / 1024 / 1024).toStringAsFixed(1)} MB',
//                                                 style: const TextStyle(
//                                                     fontSize: 10,
//                                                     color: Colors.grey),
//                                               ),
//                                             ],
//                                           ),
//                                         ))
//                                     .toList(),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),

//                     // Processing Section
//                     Row(
//                       children: [
//                         ElevatedButton.icon(
//                           onPressed: _isLoading || _isProcessing
//                               ? null
//                               : _startProcessing,
//                           icon: const Icon(Icons.play_arrow),
//                           label: const Text('Start Processing'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         if (_isProcessing)
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                     'Progress: ${_processingProgress.toInt()}%'),
//                                 const SizedBox(height: 4),
//                                 LinearProgressIndicator(
//                                   value: _processingProgress / 100,
//                                   backgroundColor: Colors.grey[300],
//                                   valueColor:
//                                       const AlwaysStoppedAnimation<Color>(
//                                           Colors.blue),
//                                 ),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),

//                     // Status Message
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(8.0),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         'Status: $_statusMessage',
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Data Table Section
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Reconciliation Summary Data',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const DataScreen()),
//                     );
//                   },
//                   icon: const Icon(Icons.table_view),
//                   label: const Text('View Full Data'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),

//             Expanded(
//               child: Card(
//                 child: _isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : _reconData.isEmpty
//                         ? const Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.table_chart,
//                                     size: 64, color: Colors.grey),
//                                 SizedBox(height: 16),
//                                 Text(
//                                   'No data available',
//                                   style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   'Upload files and start processing to see reconciliation data.',
//                                   style: TextStyle(
//                                       fontSize: 14, color: Colors.grey),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : Column(
//                             children: [
//                               // Quick summary
//                               Container(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceAround,
//                                   children: [
//                                     _buildQuickStat('Total Records',
//                                         _reconData.length.toString()),
//                                     _buildQuickStat(
//                                         'Latest Date', _getLatestDate()),
//                                     _buildQuickStat('Sources',
//                                         _getUniqueSources().toString()),
//                                   ],
//                                 ),
//                               ),
//                               const Divider(),
//                               // Sample data preview
//                               Expanded(
//                                 child: SingleChildScrollView(
//                                   padding: const EdgeInsets.all(16),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       const Text(
//                                         'Recent Transactions (Sample):',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       ..._reconData
//                                           .take(5)
//                                           .map((item) => Container(
//                                                 margin: const EdgeInsets.only(
//                                                     bottom: 8),
//                                                 padding:
//                                                     const EdgeInsets.all(12),
//                                                 decoration: BoxDecoration(
//                                                   border: Border.all(
//                                                       color:
//                                                           Colors.grey.shade300),
//                                                   borderRadius:
//                                                       BorderRadius.circular(8),
//                                                 ),
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       'Txn: ${item['Txn_RefNo']} - ${item['Txn_Type']}',
//                                                       style: const TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.bold),
//                                                     ),
//                                                     Text(
//                                                         'Date: ${item['Txn_Date']?.toString().split('T')[0]}'),
//                                                     Text(
//                                                         'Cloud: ₹${item['Cloud_Payment']} | Paytm: ₹${item['Paytm_Payment']} | Card: ₹${item['Card_Payment']}'),
//                                                   ],
//                                                 ),
//                                               ))
//                                           .toList(),
//                                       const SizedBox(height: 16),
//                                       Center(
//                                         child: ElevatedButton.icon(
//                                           onPressed: () {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       const DataScreen()),
//                                             );
//                                           },
//                                           icon: const Icon(Icons.table_view),
//                                           label: const Text(
//                                               'View All Data in Table'),
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.blue,
//                                             foregroundColor: Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//3

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'database_service.dart';
import 'data_screen.dart';
import 'dart:async';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isProcessing = false;
  List<dynamic> _reconData = [];
  String _statusMessage = '';
  Timer? _statusTimer;
  List<PlatformFile> _selectedFiles = [];
  double _processingProgress = 0.0;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadReconData();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
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
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Start entrance animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // Animated button tap effect
  void _animateButtonTap(VoidCallback onTap) {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
      onTap();
    });
  }

  // Load reconciliation data from database
  Future<void> _loadReconData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading data...';
    });

    try {
      final response = await DatabaseService.getReconSummary();
      if (response['status'] == 'success') {
        setState(() {
          _reconData = response['data'] ?? [];
          _statusMessage =
              'Data loaded successfully (${_reconData.length} records)';
        });
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

  // Pick and upload multiple files
  Future<void> _pickAndUploadFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'xlsx', 'xls', 'csv'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        _selectedFiles = result.files;

        setState(() {
          _isLoading = true;
          _statusMessage = 'Uploading ${_selectedFiles.length} file(s)...';
        });

        final results =
            await DatabaseService.uploadMultipleFiles(_selectedFiles);

        int successCount = results.where((r) => r['success'] == true).length;
        int failCount = results.where((r) => r['success'] == false).length;

        if (failCount == 0) {
          setState(() {
            _statusMessage = 'All $successCount files uploaded successfully!';
          });
        } else {
          setState(() {
            _statusMessage =
                '$successCount files uploaded, $failCount failed. Check details below.';
          });
        }

        _showUploadResults(results);
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Upload error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show upload results dialog
  void _showUploadResults(List<Map<String, dynamic>> results) {
    showDialog(
      context: context,
      builder: (context) => FadeTransition(
        opacity: _fadeAnimation,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Upload Results',
              style: TextStyle(fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: result['success']
                        ? AppTheme.sage.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: result['success']
                          ? AppTheme.sage.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        result['success'] ? Icons.check_circle : Icons.error,
                        color: result['success'] ? AppTheme.sage : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result['filename'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              result['success']
                                  ? 'Uploaded successfully'
                                  : 'Failed: ${result['error']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: result['success']
                                    ? AppTheme.sage
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  // Start processing and monitor status
  Future<void> _startProcessing() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Starting processing...';
      });

      final response = await DatabaseService.startProcessing();

      if (response['success'] == true) {
        setState(() {
          _isProcessing = true;
          _statusMessage = 'Processing started successfully';
          _processingProgress = 0.0;
        });

        _startStatusMonitoring();
      } else {
        setState(() {
          _statusMessage = 'Failed to start processing: ${response['error']}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Processing error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Monitor processing status
  void _startStatusMonitoring() {
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final statusResponse = await DatabaseService.getProcessingStatus();
        final status = statusResponse['status'];

        setState(() {
          _isProcessing = status['is_processing'] ?? false;
          _processingProgress = (status['progress'] ?? 0).toDouble();
          _statusMessage = status['message'] ?? 'Processing...';
        });

        if (status['completed'] == true || status['is_processing'] == false) {
          timer.cancel();
          setState(() {
            _isProcessing = false;
          });

          if (status['completed'] == true) {
            _statusMessage = 'Processing completed successfully!';
            await _loadReconData();
          } else if (status['error'] != null) {
            _statusMessage = 'Processing failed: ${status['error']}';
          }
        }
      } catch (e) {
        setState(() {
          _statusMessage = 'Status check error: $e';
        });
      }
    });
  }

  // Refresh data
  Future<void> _refreshData() async {
    await _loadReconData();
  }

  // Get latest transaction date
  String _getLatestDate() {
    if (_reconData.isEmpty) return 'N/A';
    try {
      String latest = _reconData.first['Txn_Date']?.toString() ?? '';
      return latest.split('T')[0];
    } catch (e) {
      return 'N/A';
    }
  }

  // Get number of unique transaction sources
  int _getUniqueSources() {
    if (_reconData.isEmpty) return 0;
    Set<String> sources = _reconData
        .map((item) => item['Txn_Source']?.toString() ?? '')
        .where((source) => source.isNotEmpty)
        .toSet();
    return sources.length;
  }

  // Build quick stat widget
  Widget _buildQuickStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.sage.withOpacity(0.1),
            AppTheme.sage.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.sage.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.sage,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.theme,
      child: Scaffold(
        backgroundColor: AppTheme.cream,
        appBar: AppBar(
          title: const Text('Reconciliation Dashboard'),
          actions: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () => _animateButtonTap(_refreshData),
                    tooltip: 'Refresh Data',
                  ),
                );
              },
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(context),
                  const SizedBox(height: 40),
                  _buildDataSourceSection(context),
                  const SizedBox(height: 32),
                  if (_selectedFiles.isNotEmpty) ...[
                    _buildUploadedFilesSection(context),
                    const SizedBox(height: 32),
                  ],
                  _buildDataStatusSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Reconciliation System',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkGreen,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Load data from database or upload files for automated processing',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.sage,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourceSection(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color.fromARGB(255, 255, 241, 150).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkGreen.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppTheme.sage.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
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
                      Icons.source_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Data Sources',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkGreen,
                          letterSpacing: -0.5,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _buildDataSourceOption(
                icon: Icons.storage_rounded,
                title: 'Load from Database',
                subtitle: 'Get latest reconciliation data from MySQL',
                gradient: LinearGradient(
                  colors: [
                    AppTheme.sage.withOpacity(0.1),
                    AppTheme.sage.withOpacity(0.05)
                  ],
                ),
                iconColor: AppTheme.sage,
                borderColor: AppTheme.sage.withOpacity(0.3),
                isLoading: _isLoading,
                onTap: () => _animateButtonTap(_loadReconData),
              ),
              const SizedBox(width: 16),
              const SizedBox(height: 16),
              _buildDataSourceOption(
                icon: Icons.cloud_upload_rounded,
                title: 'Upload Multiple Files & Process',
                subtitle:
                    'Upload multiple .zip/.xlsx files for batch processing',
                gradient: LinearGradient(
                  colors: [
                    AppTheme.sage.withOpacity(0.1),
                    AppTheme.sage.withOpacity(0.05)
                  ],
                ),
                iconColor: AppTheme.sage,
                borderColor: AppTheme.sage.withOpacity(0.3),
                onTap: () => _animateButtonTap(_pickAndUploadFiles),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required Color iconColor,
    required Color borderColor,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: iconColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppTheme.darkGreen,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppTheme.sage,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: iconColor,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadedFilesSection(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.sage.withOpacity(0.08),
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.sage.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.sage.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.sage, AppTheme.darkGreen],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.upload_file_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Selected Files (${_selectedFiles.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.darkGreen,
                              letterSpacing: -0.5,
                            ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedFiles.clear();
                      });
                    },
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    label: const Text('Clear All'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.sage,
                      backgroundColor: AppTheme.sage.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = _selectedFiles[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          AppTheme.sage.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.sage.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.sage.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.sage.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.insert_drive_file_rounded,
                            color: AppTheme.sage,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.darkGreen,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${(file.size / 1024 / 1024).toStringAsFixed(1)} MB',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.sage,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedFiles.removeAt(index);
                            });
                          },
                          color: AppTheme.sage,
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.sage.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading || _isProcessing
                                ? null
                                : () => _animateButtonTap(_startProcessing),
                            icon: _isProcessing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.play_arrow_rounded),
                            label: Text(_isProcessing
                                ? 'Processing...'
                                : 'Start Processing'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.sage,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: AppTheme.sage.withOpacity(0.3),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => _animateButtonTap(_pickAndUploadFiles),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add More Files'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.sage,
                      side: BorderSide(color: AppTheme.sage.withOpacity(0.6)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataStatusSection(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppTheme.cream.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.sage.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkGreen.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppTheme.sage.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
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
                  Text(
                    'System Status',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkGreen,
                          letterSpacing: -0.5,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status Message Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.sage.withOpacity(0.1),
                      AppTheme.sage.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.sage.withOpacity(0.2),
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
                        _isLoading || _isProcessing
                            ? Icons.sync_rounded
                            : Icons.info_rounded,
                        color: AppTheme.sage,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.sage,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _statusMessage,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isLoading || _isProcessing)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppTheme.sage),
                        ),
                      ),
                  ],
                ),
              ),

              // Processing Progress Bar (when processing)
              if (_isProcessing) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.golden.withOpacity(0.1),
                        AppTheme.golden.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.golden.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Processing Progress',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkGreen,
                            ),
                          ),
                          Text(
                            '${_processingProgress.toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.bronze,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _processingProgress / 100,
                          backgroundColor: AppTheme.golden.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.bronze),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Data Summary Stats
              if (_reconData.isNotEmpty) ...[
                Text(
                  'Data Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGreen,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat(
                          'Total Records', _reconData.length.toString()),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildQuickStat('Latest Date', _getLatestDate()),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildQuickStat(
                          'Sources', _getUniqueSources().toString()),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sample Data Preview
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        AppTheme.cream.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.sage.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Transactions (Sample)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppTheme.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._reconData
                          .take(3)
                          .map((item) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.sage.withOpacity(0.05),
                                      Colors.white,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.sage.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                AppTheme.sage.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item['Txn_Type'] ?? 'N/A',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.sage,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Txn: ${item['Txn_RefNo'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: AppTheme.darkGreen,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Date: ${item['Txn_Date']?.toString().split('T')[0] ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.sage,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Cloud: ₹${item['Cloud_Payment'] ?? '0'} | Paytm: ₹${item['Paytm_Payment'] ?? '0'} | Card: ₹${item['Card_Payment'] ?? '0'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.darkGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      const SizedBox(height: 16),
                      Center(
                        child: AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: ElevatedButton.icon(
                                onPressed: () => _animateButtonTap(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const DataScreen()),
                                  );
                                }),
                                icon: const Icon(Icons.table_view_rounded),
                                label: const Text('View All Data'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.bronze,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Empty State
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        AppTheme.cream.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.sage.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.sage.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.table_chart_rounded,
                          size: 48,
                          color: AppTheme.sage,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No data available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload files and start processing to see reconciliation data.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.sage,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
