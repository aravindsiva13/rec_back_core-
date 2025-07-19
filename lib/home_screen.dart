// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:html' as html;
// import 'dart:typed_data';
// import 'dart:convert';
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'providers.dart';
// import 'widgets.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _isDragOver = false;
//   Timer? _processingTimer;
//   List<String> _uploadedFiles = []; // Track multiple uploaded files

//   @override
//   void dispose() {
//     _processingTimer?.cancel();
//     super.dispose();
//   }

//   // Enhanced file upload handling for MULTIPLE files
//   Future<void> _handleMultipleFileUpload() async {
//     final provider = Provider.of<TransactionProvider>(context, listen: false);
//     final uploadProvider =
//         Provider.of<UploadStateProvider>(context, listen: false);

//     try {
//       // Create file input element with multiple file support
//       final html.FileUploadInputElement uploadInput =
//           html.FileUploadInputElement();
//       uploadInput.accept = '.zip,.xlsx,.xls';
//       uploadInput.multiple = true; // Enable multiple file selection
//       uploadInput.click();

//       uploadInput.onChange.listen((e) async {
//         final files = uploadInput.files;
//         if (files == null || files.isEmpty) return;

//         // Process all selected files
//         List<String> successfulUploads = [];
//         List<String> failedUploads = [];

//         for (int i = 0; i < files.length; i++) {
//           final file = files[i];

//           try {
//             // Validate file before uploading
//             final validationError = _validateFile(file.name, file.size);
//             if (validationError != null) {
//               failedUploads.add('${file.name}: $validationError');
//               continue;
//             }

//             uploadProvider
//                 .startUpload('${file.name} (${i + 1}/${files.length})');

//             // Read file as bytes
//             final reader = html.FileReader();
//             reader.readAsArrayBuffer(file);

//             await reader.onLoadEnd.first;

//             final bytes = reader.result as List<int>;
//             final uint8Bytes = Uint8List.fromList(bytes);

//             // Simulate upload progress for each file
//             for (int progress = 0; progress <= 100; progress += 25) {
//               await Future.delayed(const Duration(milliseconds: 30));
//               uploadProvider.updateProgress(progress / 100,
//                   status: 'Uploading ${file.name}... $progress%');
//             }

//             // Upload file to server
//             final response = await _uploadFileToServer(uint8Bytes, file.name);

//             if (response['success'] == true) {
//               successfulUploads.add(file.name);
//               _uploadedFiles.add(file.name);
//             } else {
//               failedUploads
//                   .add('${file.name}: ${response['error'] ?? 'Upload failed'}');
//             }
//           } catch (e) {
//             failedUploads.add('${file.name}: ${e.toString()}');
//           }
//         }

//         // Update UI based on results
//         if (successfulUploads.isNotEmpty) {
//           uploadProvider.completeUpload({
//             'totalFiles': files.length,
//             'successfulFiles': successfulUploads,
//             'failedFiles': failedUploads,
//           });

//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                         'Upload completed: ${successfulUploads.length}/${files.length} files'),
//                     if (successfulUploads.isNotEmpty)
//                       Text('✓ ${successfulUploads.join(', ')}',
//                           style: const TextStyle(fontSize: 12)),
//                     if (failedUploads.isNotEmpty)
//                       Text('✗ ${failedUploads.length} failed',
//                           style: const TextStyle(
//                               fontSize: 12, color: Colors.orange)),
//                   ],
//                 ),
//                 backgroundColor:
//                     failedUploads.isEmpty ? Colors.green : Colors.orange,
//                 duration: const Duration(seconds: 5),
//               ),
//             );
//           }
//         } else {
//           uploadProvider.failUpload('All uploads failed');
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text('All uploads failed:'),
//                     ...failedUploads.map((error) =>
//                         Text('• $error', style: const TextStyle(fontSize: 12))),
//                   ],
//                 ),
//                 backgroundColor: Colors.red,
//                 duration: const Duration(seconds: 8),
//               ),
//             );
//           }
//         }

//         // Refresh state
//         setState(() {});
//       });
//     } catch (e) {
//       uploadProvider.failUpload(e.toString());
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Upload error: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // File validation
//   String? _validateFile(String fileName, int fileSize) {
//     // Check file extension
//     final allowedExtensions = {'zip', 'xlsx', 'xls'};
//     final extension = fileName.split('.').last.toLowerCase();

//     if (!allowedExtensions.contains(extension)) {
//       return 'Invalid file type. Only .zip, .xlsx, and .xls files are allowed.';
//     }

//     // Check file size (50MB limit)
//     const maxSizeBytes = 50 * 1024 * 1024;
//     if (fileSize > maxSizeBytes) {
//       final sizeMB = fileSize / (1024 * 1024);
//       return 'File too large (${sizeMB.toStringAsFixed(1)}MB). Maximum size is 50MB.';
//     }

//     return null; // Valid file
//   }

//   Future<Map<String, dynamic>> _uploadFileToServer(
//       Uint8List bytes, String fileName) async {
//     try {
//       print('🚀 Uploading ${fileName} to backend...'); // DEBUG

//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('http://localhost:5000/api/upload'),
//       );

//       request.files.add(
//         http.MultipartFile.fromBytes(
//           'file',
//           bytes,
//           filename: fileName,
//         ),
//       );

//       print('📤 Sending request to backend...'); // DEBUG
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       print('📥 Backend response: ${response.statusCode}'); // DEBUG
//       print('📄 Response body: ${response.body}'); // DEBUG

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print('✅ Upload successful: ${data['filename']}'); // DEBUG
//         return {'success': true, 'data': data};
//       } else {
//         final errorData = json.decode(response.body);
//         print('❌ Upload failed: ${errorData['error']}'); // DEBUG
//         return {
//           'success': false,
//           'error': errorData['error'] ?? 'Upload failed'
//         };
//       }
//     } catch (e) {
//       print('💥 Upload exception: $e'); // DEBUG
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   // Load from database
//   Future<void> _loadFromDatabase() async {
//     final provider = Provider.of<TransactionProvider>(context, listen: false);
//     try {
//       await provider.loadTransactionsFromDatabase();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Data loaded successfully from database'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error loading data: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // Load from Excel (single file for compatibility)
//   Future<void> _loadFromExcel() async {
//     final provider = Provider.of<TransactionProvider>(context, listen: false);

//     try {
//       final html.FileUploadInputElement uploadInput =
//           html.FileUploadInputElement();
//       uploadInput.accept = '.xlsx,.xls';
//       uploadInput.click();

//       uploadInput.onChange.listen((e) async {
//         final files = uploadInput.files;
//         if (files!.isEmpty) return;

//         final file = files[0];
//         final reader = html.FileReader();
//         reader.readAsArrayBuffer(file);

//         reader.onLoadEnd.listen((e) async {
//           try {
//             final bytes = reader.result as List<int>;
//             final uint8Bytes = Uint8List.fromList(bytes);
//             // await provider.loadFromExcel(uint8Bytes, file.name);

//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Excel file loaded: ${file.name}'),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//             }
//           } catch (e) {
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Error loading Excel: $e'),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             }
//           }
//         });
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // Future<void> _startProcessing() async {
//   //   final provider = Provider.of<TransactionProvider>(context, listen: false);

//   //   try {
//   //     _showProcessingDialog();

//   //     await provider.startBatchProcessing();

//   //     _processingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
//   //       provider.checkProcessingStatus();

//   //       if (provider.batchProcessingStatus?['completed'] == true) {
//   //         timer.cancel();
//   //         Navigator.of(context).pop();

//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           const SnackBar(
//   //             content: Text('Processing completed successfully!'),
//   //             backgroundColor: Colors.green,
//   //           ),
//   //         );
//   //       } else if (provider.batchProcessingStatus?['error'] != null) {
//   //         timer.cancel();
//   //         Navigator.of(context).pop();

//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           SnackBar(
//   //             content: Text(
//   //                 'Processing failed: ${provider.batchProcessingStatus!['error']}'),
//   //             backgroundColor: Colors.red,
//   //           ),
//   //         );
//   //       }
//   //     });
//   //   } catch (e) {
//   //     Navigator.of(context).pop();
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text('Error: $e'),
//   //         backgroundColor: Colors.red,
//   //       ),
//   //     );
//   //   }
//   // }

//   Future<void> _startProcessing() async {
//     final provider = Provider.of<TransactionProvider>(context, listen: false);

//     try {
//       _showProcessingDialog();

//       await provider.startBatchProcessing();

//       _processingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
//         provider.checkProcessingStatus();

//         if (provider.batchProcessingStatus?['completed'] == true) {
//           timer.cancel();
//           Navigator.of(context).pop();

//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Processing completed successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         } else if (provider.batchProcessingStatus?['error'] != null) {
//           timer.cancel();
//           Navigator.of(context).pop();

//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                   'Processing failed: ${provider.batchProcessingStatus!['error']}'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       });
//     } catch (e) {
//       Navigator.of(context).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // Show processing dialog
//   void _showProcessingDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Consumer<TransactionProvider>(
//         builder: (context, provider, child) {
//           final status = provider.batchProcessingStatus ?? {};

//           return AlertDialog(
//             title: const Text('Processing Files'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Processing ${_uploadedFiles.length} uploaded files...'),
//                 const SizedBox(height: 16),
//                 if (status['step_name'] != null) ...[
//                   Text('Current Step: ${status['step_name']}'),
//                   const SizedBox(height: 8),
//                 ],
//                 if (status['message'] != null) ...[
//                   Text(status['message'], style: const TextStyle(fontSize: 12)),
//                   const SizedBox(height: 8),
//                 ],
//                 LinearProgressIndicator(
//                   value: (status['progress'] ?? 0) / 100.0,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                     '${status['current_step'] ?? 0}/${status['total_steps'] ?? 3} steps'),
//               ],
//             ),
//             actions: [
//               if (status['error'] != null)
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text('Close'),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<TransactionProvider>(
//       builder: (context, provider, child) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Reconciliation Dashboard'),
//             elevation: 0,
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.refresh),
//                 onPressed: () => provider.loadTransactionsFromDatabase(),
//                 tooltip: 'Refresh Data',
//               ),
//             ],
//           ),
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header Section
//                 _buildHeaderSection(context),
//                 const SizedBox(height: 32),

//                 // Data Source Selection
//                 _buildDataSourceSection(context, provider),
//                 const SizedBox(height: 32),

//                 // Multiple Files Upload Section
//                 if (_uploadedFiles.isNotEmpty) ...[
//                   _buildUploadedFilesSection(context, provider),
//                   const SizedBox(height: 32),
//                 ],

//                 // Data Status Section
//                 _buildDataStatusSection(context, provider),
//                 const SizedBox(height: 32),

//                 // Quick Actions
//                 if (provider.hasData) ...[
//                   _buildQuickActionsSection(context, provider),
//                 ],
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHeaderSection(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Welcome to Reconciliation System',
//           style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Load data from database or upload files for automated processing',
//           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                 color: Colors.grey[600],
//               ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDataSourceSection(
//       BuildContext context, TransactionProvider provider) {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Data Sources',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             const SizedBox(height: 16),

//             // Database Option
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Theme.of(context).dividerColor),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ListTile(
//                 contentPadding: const EdgeInsets.all(16),
//                 leading: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child:
//                       const Icon(Icons.storage, color: Colors.green, size: 24),
//                 ),
//                 title: const Text(
//                   'Load from Database',
//                   style: TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 subtitle:
//                     const Text('Get latest reconciliation data from MySQL'),
//                 trailing: provider.isLoading
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Icon(Icons.arrow_forward_ios, color: Colors.green),
//                 onTap: provider.isLoading ? null : _loadFromDatabase,
//               ),
//             ),

//             const SizedBox(height: 12),

//             // Excel File Option
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Theme.of(context).dividerColor),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ListTile(
//                 contentPadding: const EdgeInsets.all(16),
//                 leading: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.file_present,
//                       color: Colors.blue, size: 24),
//                 ),
//                 title: const Text(
//                   'Load from Excel File',
//                   style: TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 subtitle: const Text('Upload single Excel file for quick view'),
//                 trailing: const Icon(Icons.arrow_forward_ios),
//                 onTap: provider.isLoading ? null : _loadFromExcel,
//               ),
//             ),

//             const SizedBox(height: 12),

//             // Multiple Files Upload Option
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Theme.of(context).dividerColor),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ListTile(
//                 contentPadding: const EdgeInsets.all(16),
//                 leading: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.cloud_upload,
//                       color: Colors.orange, size: 24),
//                 ),
//                 title: const Text(
//                   'Upload Multiple Files & Process',
//                   style: TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 subtitle: const Text(
//                     'Upload multiple .zip/.xlsx files for batch processing'),
//                 trailing: const Icon(Icons.arrow_forward_ios),
//                 onTap: provider.isLoading ? null : _handleMultipleFileUpload,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildUploadedFilesSection(
//       BuildContext context, TransactionProvider provider) {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Uploaded Files (${_uploadedFiles.length})',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//                 TextButton.icon(
//                   onPressed: () {
//                     setState(() {
//                       _uploadedFiles.clear();
//                     });
//                   },
//                   icon: const Icon(Icons.clear),
//                   label: const Text('Clear All'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // List of uploaded files
//             ...(_uploadedFiles.map((fileName) => Container(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.check_circle,
//                           color: Colors.green, size: 20),
//                       const SizedBox(width: 8),
//                       Expanded(child: Text(fileName)),
//                       IconButton(
//                         icon: const Icon(Icons.close, size: 18),
//                         onPressed: () {
//                           setState(() {
//                             _uploadedFiles.remove(fileName);
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ))),

//             const SizedBox(height: 16),

//             // Processing Controls
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed:
//                         (provider.isBatchProcessing) ? null : _startProcessing,
//                     icon: provider.isBatchProcessing
//                         ? const SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Icon(Icons.play_arrow),
//                     label: Text(provider.isBatchProcessing
//                         ? 'Processing...'
//                         : 'Start Processing'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 OutlinedButton.icon(
//                   onPressed: _handleMultipleFileUpload,
//                   icon: const Icon(Icons.add),
//                   label: const Text('Add More Files'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDataStatusSection(
//       BuildContext context, TransactionProvider provider) {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Data Status',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildStatusCard(
//                     'Transactions',
//                     '${provider.allTransactions.length}',
//                     Icons.receipt,
//                     Colors.blue,
//                   ),
//                 ),
//                 const SizedBox(width: 16),

//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusCard(
//       String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color),
//           const SizedBox(height: 8),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActionsSection(
//       BuildContext context, TransactionProvider provider) {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Quick Actions',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () => Navigator.pushNamed(context, '/data'),
//                     icon: const Icon(Icons.table_view),
//                     label: const Text('View Data'),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () => Navigator.pushNamed(context, '/analytics'),
//                     icon: const Icon(Icons.analytics),
//                     label: const Text('Analytics'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//2

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'providers.dart';
import 'widgets.dart';

// Custom Theme Data
class AppTheme {
  static const Color sage = Color(0xFF606C38); // Primary green
  static const Color darkGreen = Color(0xFF283618); // Dark accent
  static const Color cream = Color(0xFFFEFAE0); // Light background
  static const Color golden = Color(0xFFDDA15E); // Secondary accent
  static const Color bronze = Color(0xFFBC6C25); // Primary action
  static const Color accent = Color(0xFFDDA15E); // Accent color (added)

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
  bool _isDragOver = false;
  Timer? _processingTimer;
  List<String> _uploadedFiles = [];

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
    _processingTimer?.cancel();
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

  // Enhanced file upload handling for MULTIPLE files
  Future<void> _handleMultipleFileUpload() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final uploadProvider =
        Provider.of<UploadStateProvider>(context, listen: false);

    try {
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement();
      uploadInput.accept = '.zip,.xlsx,.xls';
      uploadInput.multiple = true;
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files == null || files.isEmpty) return;

        List<String> successfulUploads = [];
        List<String> failedUploads = [];

        for (int i = 0; i < files.length; i++) {
          final file = files[i];

          try {
            final validationError = _validateFile(file.name, file.size);
            if (validationError != null) {
              failedUploads.add('${file.name}: $validationError');
              continue;
            }

            uploadProvider
                .startUpload('${file.name} (${i + 1}/${files.length})');

            final reader = html.FileReader();
            reader.readAsArrayBuffer(file);

            await reader.onLoadEnd.first;

            final bytes = reader.result as List<int>;
            final uint8Bytes = Uint8List.fromList(bytes);

            for (int progress = 0; progress <= 100; progress += 25) {
              await Future.delayed(const Duration(milliseconds: 30));
              uploadProvider.updateProgress(progress / 100,
                  status: 'Uploading ${file.name}... $progress%');
            }

            final response = await _uploadFileToServer(uint8Bytes, file.name);

            if (response['success'] == true) {
              successfulUploads.add(file.name);
              setState(() {
                _uploadedFiles.add(file.name);
              });
            } else {
              failedUploads
                  .add('${file.name}: ${response['error'] ?? 'Upload failed'}');
            }
          } catch (e) {
            failedUploads.add('${file.name}: ${e.toString()}');
          }
        }

        if (successfulUploads.isNotEmpty) {
          uploadProvider.completeUpload({
            'totalFiles': files.length,
            'successfulFiles': successfulUploads,
            'failedFiles': failedUploads,
          });

          if (mounted) {
            _showAnimatedSnackBar(
              'Upload completed: ${successfulUploads.length}/${files.length} files',
              failedUploads.isEmpty ? Colors.green : Colors.orange,
              successfulUploads: successfulUploads,
              failedUploads: failedUploads,
            );
          }
        } else {
          uploadProvider.failUpload('All uploads failed');
          if (mounted) {
            _showAnimatedSnackBar(
              'All uploads failed',
              Colors.red,
              failedUploads: failedUploads,
            );
          }
        }
      });
    } catch (e) {
      uploadProvider.failUpload(e.toString());
      if (mounted) {
        _showAnimatedSnackBar('Upload error: ${e.toString()}', Colors.red);
      }
    }
  }

  void _showAnimatedSnackBar(
    String message,
    Color color, {
    List<String>? successfulUploads,
    List<String>? failedUploads,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              if (successfulUploads != null && successfulUploads.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('✓ ${successfulUploads.join(', ')}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.black.withOpacity(0.9))),
                ),
              if (failedUploads != null && failedUploads.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('✗ ${failedUploads.length} failed',
                      style: TextStyle(
                          fontSize: 12, color: Colors.black.withOpacity(0.9))),
                ),
            ],
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String? _validateFile(String fileName, int fileSize) {
    final allowedExtensions = {'zip', 'xlsx', 'xls'};
    final extension = fileName.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(extension)) {
      return 'Invalid file type. Only .zip, .xlsx, and .xls files are allowed.';
    }

    const maxSizeBytes = 50 * 1024 * 1024;
    if (fileSize > maxSizeBytes) {
      final sizeMB = fileSize / (1024 * 1024);
      return 'File too large (${sizeMB.toStringAsFixed(1)}MB). Maximum size is 50MB.';
    }

    return null;
  }

  Future<Map<String, dynamic>> _uploadFileToServer(
      Uint8List bytes, String fileName) async {
    try {
      print('🚀 Uploading ${fileName} to backend...');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/api/upload'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

      print('📤 Sending request to backend...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Backend response: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Upload successful: ${data['filename']}');
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        print('❌ Upload failed: ${errorData['error']}');
        return {
          'success': false,
          'error': errorData['error'] ?? 'Upload failed'
        };
      }
    } catch (e) {
      print('💥 Upload exception: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> _loadFromDatabase() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    try {
      await provider.loadTransactionsFromDatabase();
      if (mounted) {
        _showAnimatedSnackBar(
            'Data loaded successfully from database', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showAnimatedSnackBar('Error loading data: $e', Colors.red);
      }
    }
  }

  Future<void> _loadFromExcel() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    try {
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement();
      uploadInput.accept = '.xlsx,.xls';
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files!.isEmpty) return;

        final file = files[0];
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);

        reader.onLoadEnd.listen((e) async {
          try {
            final bytes = reader.result as List<int>;
            final uint8Bytes = Uint8List.fromList(bytes);

            if (mounted) {
              _showAnimatedSnackBar(
                  'Excel file loaded: ${file.name}', Colors.green);
            }
          } catch (e) {
            if (mounted) {
              _showAnimatedSnackBar('Error loading Excel: $e', Colors.red);
            }
          }
        });
      });
    } catch (e) {
      if (mounted) {
        _showAnimatedSnackBar('Error: $e', Colors.red);
      }
    }
  }

  Future<void> _startProcessing() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    try {
      _showProcessingDialog();

      await provider.startBatchProcessing();

      _processingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        provider.checkProcessingStatus();

        if (provider.batchProcessingStatus?['completed'] == true) {
          timer.cancel();
          Navigator.of(context).pop();
          _showAnimatedSnackBar(
              'Processing completed successfully!', Colors.green);
        } else if (provider.batchProcessingStatus?['error'] != null) {
          timer.cancel();
          Navigator.of(context).pop();
          _showAnimatedSnackBar(
              'Processing failed: ${provider.batchProcessingStatus!['error']}',
              Colors.red);
        }
      });
    } catch (e) {
      Navigator.of(context).pop();
      _showAnimatedSnackBar('Error: $e', Colors.red);
    }
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            final status = provider.batchProcessingStatus ?? {};

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Processing Files',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Processing ${_uploadedFiles.length} uploaded files...',
                      style: const TextStyle(color: AppTheme.sage)),
                  const SizedBox(height: 20),
                  if (status['step_name'] != null) ...[
                    Text('Current Step: ${status['step_name']}',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                  ],
                  if (status['message'] != null) ...[
                    Text(status['message'],
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.sage)),
                    const SizedBox(height: 12),
                  ],
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (status['progress'] ?? 0) / 100.0,
                      backgroundColor: AppTheme.golden.withOpacity(0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppTheme.sage),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                      '${status['current_step'] ?? 0}/${status['total_steps'] ?? 3} steps',
                      style:
                          const TextStyle(fontSize: 12, color: AppTheme.sage)),
                ],
              ),
              actions: [
                if (status['error'] != null)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Scaffold(
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
                      onPressed: () => _animateButtonTap(
                          () => provider.loadTransactionsFromDatabase()),
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
                    _buildDataSourceSection(context, provider),
                    const SizedBox(height: 32),
                    if (_uploadedFiles.isNotEmpty) ...[
                      _buildUploadedFilesSection(context, provider),
                      const SizedBox(height: 32),
                    ],
                    // _buildDataStatusSection(context, provider),
                    // const SizedBox(height: 32),
                    // if (provider.hasData) ...[
                    //   _buildQuickActionsSection(context, provider),
                    // ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

  // Widget _buildDataSourceSection(
  //     BuildContext context, TransactionProvider provider) {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 300),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: const Color.fromARGB(255, 198, 223, 116),
  //         borderRadius: BorderRadius.circular(20),
  //         boxShadow: [
  //           BoxShadow(
  //             color: const Color.fromARGB(255, 54, 52, 50).withOpacity(0.18),
  //             blurRadius: 20,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(32),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Data Sources',
  //               style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //                     fontWeight: FontWeight.w700,
  //                     color: AppTheme.darkGreen,
  //                   ),
  //             ),
  //             const SizedBox(height: 24),
  //             _buildDataSourceOption(
  //               icon: Icons.storage_rounded,
  //               title: 'Load from Database',
  //               subtitle: 'Get latest reconciliation data from MySQL',
  //               color: const Color.fromARGB(255, 21, 21, 20),
  //               isLoading: provider.isLoading,
  //               onTap: () => _animateButtonTap(_loadFromDatabase),
  //             ),
  //             const SizedBox(height: 16),
  //             _buildDataSourceOption(
  //               icon: Icons.description_rounded,
  //               title: 'Load from Excel File',
  //               subtitle: 'Upload single Excel file for quick view',
  //               color: const Color.fromARGB(255, 37, 37, 36),
  //               onTap: () => _animateButtonTap(_loadFromExcel),
  //             ),
  //             const SizedBox(height: 16),
  //             _buildDataSourceOption(
  //               icon: Icons.cloud_upload_rounded,
  //               title: 'Upload Multiple Files & Process',
  //               subtitle:
  //                   'Upload multiple .zip/.xlsx files for batch processing',
  //               color: const Color.fromARGB(255, 29, 27, 25),
  //               onTap: () => _animateButtonTap(_handleMultipleFileUpload),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildDataSourceOption({
  //   required IconData icon,
  //   required String title,
  //   required String subtitle,
  //   required Color color,
  //   required VoidCallback onTap,
  //   bool isLoading = false,
  // }) {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 200),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         onTap: isLoading ? null : onTap,
  //         borderRadius: BorderRadius.circular(16),
  //         child: Container(
  //           padding: const EdgeInsets.all(20),
  //           decoration: BoxDecoration(
  //             border: Border.all(color: AppTheme.golden.withOpacity(0.3)),
  //             borderRadius: BorderRadius.circular(16),
  //           ),
  //           child: Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(16),
  //                 decoration: BoxDecoration(
  //                   color: color.withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Icon(icon, color: color, size: 24),
  //               ),
  //               const SizedBox(width: 20),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       title,
  //                       style: const TextStyle(
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 16,
  //                         color: AppTheme.darkGreen,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       subtitle,
  //                       style: const TextStyle(
  //                         color: AppTheme.sage,
  //                         fontSize: 14,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               if (isLoading)
  //                 const SizedBox(
  //                   width: 20,
  //                   height: 20,
  //                   child: CircularProgressIndicator(
  //                     strokeWidth: 2,
  //                     valueColor: AlwaysStoppedAnimation<Color>(AppTheme.sage),
  //                   ),
  //                 )
  //               else
  //                 Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildUploadedFilesSection(
  //     BuildContext context, TransactionProvider provider) {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 400),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: const Color.fromARGB(255, 216, 246, 156),
  //         borderRadius: BorderRadius.circular(20),
  //         boxShadow: [
  //           BoxShadow(
  //             color: AppTheme.accent.withOpacity(0.08),
  //             blurRadius: 20,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(32),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   'Uploaded Files (${_uploadedFiles.length})',
  //                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //                         fontWeight: FontWeight.w700,
  //                         color: AppTheme.darkGreen,
  //                       ),
  //                 ),
  //                 TextButton.icon(
  //                   onPressed: () {
  //                     setState(() {
  //                       _uploadedFiles.clear();
  //                     });
  //                   },
  //                   icon: const Icon(Icons.clear_rounded, size: 18),
  //                   label: const Text('Clear All'),
  //                   style: TextButton.styleFrom(
  //                     foregroundColor: AppTheme.sage,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 20),
  //             AnimatedList(
  //               shrinkWrap: true,
  //               physics: const NeverScrollableScrollPhysics(),
  //               initialItemCount: _uploadedFiles.length,
  //               itemBuilder: (context, index, animation) {
  //                 if (index >= _uploadedFiles.length) return Container();
  //                 return SlideTransition(
  //                   position: animation.drive(
  //                     Tween(begin: const Offset(1, 0), end: Offset.zero)
  //                         .chain(CurveTween(curve: Curves.easeOut)),
  //                   ),
  //                   child: Container(
  //                     margin: const EdgeInsets.only(bottom: 12),
  //                     padding: const EdgeInsets.all(16),
  //                     decoration: BoxDecoration(
  //                       color: AppTheme.sage.withOpacity(0.08),
  //                       borderRadius: BorderRadius.circular(12),
  //                       border: Border.all(
  //                         color: AppTheme.sage.withOpacity(0.3),
  //                       ),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         const Icon(Icons.check_circle_rounded,
  //                             color: AppTheme.sage, size: 20),
  //                         const SizedBox(width: 12),
  //                         Expanded(
  //                           child: Text(
  //                             _uploadedFiles[index],
  //                             style: const TextStyle(
  //                               fontWeight: FontWeight.w500,
  //                               color: AppTheme.darkGreen,
  //                             ),
  //                           ),
  //                         ),
  //                         IconButton(
  //                           icon: const Icon(Icons.close_rounded, size: 18),
  //                           onPressed: () {
  //                             setState(() {
  //                               _uploadedFiles.removeAt(index);
  //                             });
  //                           },
  //                           color: AppTheme.sage,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //             const SizedBox(height: 24),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: AnimatedBuilder(
  //                     animation: _scaleAnimation,
  //                     builder: (context, child) {
  //                       return Transform.scale(
  //                         scale: _scaleAnimation.value,
  //                         child: ElevatedButton.icon(
  //                           onPressed: provider.isBatchProcessing
  //                               ? null
  //                               : () => _animateButtonTap(_startProcessing),
  //                           icon: provider.isBatchProcessing
  //                               ? const SizedBox(
  //                                   width: 16,
  //                                   height: 16,
  //                                   child: CircularProgressIndicator(
  //                                     strokeWidth: 2,
  //                                     valueColor: AlwaysStoppedAnimation<Color>(
  //                                         Colors.white),
  //                                   ),
  //                                 )
  //                               : const Icon(Icons.play_arrow_rounded),
  //                           label: Text(provider.isBatchProcessing
  //                               ? 'Processing...'
  //                               : 'Start Processing'),
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: AppTheme.sage,
  //                             foregroundColor: Colors.white,
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //                 const SizedBox(width: 16),
  //                 OutlinedButton.icon(
  //                   onPressed: () =>
  //                       _animateButtonTap(_handleMultipleFileUpload),
  //                   icon: const Icon(Icons.add_rounded),
  //                   label: const Text('Add More Files'),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildDataStatusSection(
  //     BuildContext context, TransactionProvider provider) {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 300),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(20),
  //         boxShadow: [
  //           BoxShadow(
  //             color: AppTheme.accent.withOpacity(0.08),
  //             blurRadius: 20,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(32),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Data Status',
  //               style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //                     fontWeight: FontWeight.w700,
  //                     color: AppTheme.darkGreen,
  //                   ),
  //             ),
  //             const SizedBox(height: 24),
  //             _buildStatusCard(
  //               'Transactions',
  //               '${provider.allTransactions.length}',
  //               Icons.receipt_long_rounded,
  //               AppTheme.golden,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

//2

  Widget _buildDataSourceSection(
      BuildContext context, TransactionProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          // Gradient background for more depth
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
                      gradient: LinearGradient(
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
                isLoading: provider.isLoading,
                onTap: () => _animateButtonTap(_loadFromDatabase),
              ),
              const SizedBox(height: 16),
              _buildDataSourceOption(
                icon: Icons.description_rounded,
                title: 'Load from Excel File',
                subtitle: 'Upload single Excel file for quick view',
                gradient: LinearGradient(
                  colors: [
                    AppTheme.sage.withOpacity(0.1),
                    AppTheme.sage.withOpacity(0.05)
                  ],
                ),
                iconColor: AppTheme.sage,
                borderColor: AppTheme.sage.withOpacity(0.3),
                onTap: () => _animateButtonTap(_loadFromExcel),
              ),
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
                onTap: () => _animateButtonTap(_handleMultipleFileUpload),
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

  Widget _buildUploadedFilesSection(
      BuildContext context, TransactionProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      child: Container(
        decoration: BoxDecoration(
          // Success-themed gradient
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
                          gradient: LinearGradient(
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
                        'Uploaded Files (${_uploadedFiles.length})',
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
                        _uploadedFiles.clear();
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
              AnimatedList(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                initialItemCount: _uploadedFiles.length,
                itemBuilder: (context, index, animation) {
                  if (index >= _uploadedFiles.length) return Container();
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(1, 0), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.easeOut)),
                    ),
                    child: Container(
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
                              Icons.check_circle_rounded,
                              color: AppTheme.sage,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _uploadedFiles[index],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppTheme.darkGreen,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              setState(() {
                                _uploadedFiles.removeAt(index);
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
                            onPressed: provider.isBatchProcessing
                                ? null
                                : () => _animateButtonTap(_startProcessing),
                            icon: provider.isBatchProcessing
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
                            label: Text(provider.isBatchProcessing
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
                    onPressed: () =>
                        _animateButtonTap(_handleMultipleFileUpload),
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

  // Widget _buildDataStatusSection(
  //     BuildContext context, TransactionProvider provider) {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 300),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         // Clean white with subtle sage accent (same as database option)
  //         gradient: LinearGradient(
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //           colors: [
  //             Colors.white,
  //             AppTheme.cream.withOpacity(0.8),
  //           ],
  //         ),
  //         borderRadius: BorderRadius.circular(24),
  //         border: Border.all(
  //           color: AppTheme.sage.withOpacity(0.2),
  //           width: 1,
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: AppTheme.darkGreen.withOpacity(0.12),
  //             blurRadius: 24,
  //             offset: const Offset(0, 8),
  //           ),
  //           BoxShadow(
  //             color: AppTheme.sage.withOpacity(0.08),
  //             blurRadius: 16,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(32),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   padding: const EdgeInsets.all(12),
  //                   decoration: BoxDecoration(
  //                     gradient: LinearGradient(
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
  //                 Text(
  //                   'Data Status',
  //                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //                         fontWeight: FontWeight.w700,
  //                         color: AppTheme.darkGreen,
  //                         letterSpacing: -0.5,
  //                       ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 28),
  //             _buildStatusCard(
  //               'Transactions',
  //               '${provider.allTransactions.length}',
  //               Icons.receipt_long_rounded,
  //               AppTheme.sage,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildStatusCard(
  //     String title, String value, IconData icon, Color color) {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 400),
  //     padding: const EdgeInsets.all(24),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [
  //           color.withOpacity(0.1),
  //           color.withOpacity(0.05),
  //         ],
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(
  //         color: color.withOpacity(0.2),
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             color: color.withOpacity(0.15),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: Icon(icon, color: color, size: 24),
  //         ),
  //         const SizedBox(height: 16),
  //         Text(
  //           title,
  //           style: const TextStyle(
  //             fontSize: 14,
  //             fontWeight: FontWeight.w500,
  //             color: AppTheme.sage,
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           value,
  //           style: const TextStyle(
  //             fontSize: 32,
  //             fontWeight: FontWeight.w700,
  //             color: AppTheme.darkGreen,
  //             letterSpacing: -1,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildQuickActionsSection(
      BuildContext context, TransactionProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkGreen,
                    ),
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
                            onPressed: () => _animateButtonTap(
                                () => Navigator.pushNamed(context, '/data')),
                            icon: const Icon(Icons.table_view_rounded),
                            label: const Text('View Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.bronze,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: OutlinedButton.icon(
                            onPressed: () => _animateButtonTap(() =>
                                Navigator.pushNamed(context, '/analytics')),
                            icon: const Icon(Icons.analytics_rounded),
                            label: const Text('Analytics'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              side: const BorderSide(color: AppTheme.golden),
                              foregroundColor: AppTheme.sage,
                            ),
                          ),
                        );
                      },
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
}
