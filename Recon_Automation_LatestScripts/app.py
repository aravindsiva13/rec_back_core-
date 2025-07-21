
# import os
# from pathlib import Path
# from flask import Flask, jsonify, request, send_file
# from flask_cors import CORS
# import mysql.connector
# import pandas as pd
# from datetime import datetime
# import logging
# import traceback
# from decimal import Decimal
# import os
# import subprocess
# import threading
# import time
# from werkzeug.utils import secure_filename
# import zipfile
# import shutil
# import json
# import sys
# import time
# from functools import wraps

# ITEMS_PER_PAGE = 999999 
# MAX_ITEMS_PER_PAGE = 999999

# # CRITICAL FIX 1: Ensure we get the absolute base directory
# BASE_DIR = Path(__file__).parent.resolve()
# print(f"🔧 BASE_DIR resolved to: {BASE_DIR}")

# # CRITICAL FIX 2: Build paths relative to the app.py location with validation
# UPLOAD_FOLDER = BASE_DIR / 'Input_Files'
# ALLOWED_EXTENSIONS = {'zip', 'xlsx', 'xls'}
# MAX_FILE_SIZE = 50 * 1024 * 1024

# # CRITICAL FIX 3: Updated batch file configuration with absolute paths
# BATCH_FILES = [
#     {
#         'path': str(BASE_DIR / 'run_all_scripts.bat'),
#         'name': 'Complete Reconciliation Process',
#         'description': 'Execute all 3 steps: Prepare Files → Process Data → Load Database',
#         'timeout': 7200,
#         'working_dir': str(BASE_DIR)  # Explicitly set working directory
#     }
# ]

# app = Flask(__name__)
# CORS(app)

# # Configure logging with more detail
# logging.basicConfig(
#     level=logging.INFO, 
#     format='%(asctime)s - %(levelname)s - %(funcName)s:%(lineno)d - %(message)s',
#     handlers=[
#         logging.StreamHandler(),
#         logging.FileHandler(BASE_DIR / 'flask_app.log')
#     ]
# )
# logger = logging.getLogger(__name__)

# # Database configuration - KEEP YOUR ORIGINAL
# DB_CONFIG = {
#     'host': 'localhost',
#     'user': 'root',
#     'password': 'Templerun@2',
#     'database': 'reconciliation'
# }

# # Global variable to track processing status
# processing_status = {
#     'is_processing': False,
#     'current_step': 0,
#     'total_steps': 1,
#     'step_name': '',
#     'progress': 0,
#     'message': '',
#     'error': None,
#     'completed': False,
#     'start_time': None,
#     'uploaded_files': [],
#     'detailed_log': [],
#     'execution_context': {
#         'working_directory': None,
#         'environment_vars': {},
#         'input_files_found': [],
#         'batch_file_exists': False
#     }
# }

# app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
# app.config['MAX_CONTENT_LENGTH'] = MAX_FILE_SIZE

# # Ensure upload directory exists
# os.makedirs(UPLOAD_FOLDER, exist_ok=True)
# os.makedirs(BASE_DIR / 'Output_Files', exist_ok=True)

# #original queries
# QUERIES = {
#     'SUMMARY': '''
#         (SELECT txn_source, Txn_type, sum(Txn_Amount) FROM reconciliation.payment_refund pr GROUP BY 1, 2) 
#         UNION 
#         (SELECT Txn_Source, Txn_type, sum(Txn_Amount) FROM reconciliation.paytm_phonepe pp GROUP BY 1, 2)
#     ''',
    
#     'RAWDATA': '''
#         (SELECT * FROM reconciliation.paytm_phonepe pp) 
#         UNION ALL 
#         (SELECT * FROM reconciliation.payment_refund pr)
#     ''',
    
#     'RECON_SUCCESS': '''
#         SELECT *, 
#                IF((ro1.PTPP_Payment + ro1.PTPP_Refund) = (ro1.Cloud_Payment + ro1.Cloud_Refund + ro1.Cloud_MRefund),
#                   "Perfect", "Investigate") AS Remarks 
#         FROM reconciliation.recon_outcome ro1 
#         WHERE (ro1.PTPP_Payment + ro1.PTPP_Refund) = (ro1.Cloud_Payment + ro1.Cloud_Refund + ro1.Cloud_MRefund)
#         ORDER BY ro1.Txn_RefNo
#     ''',
    
#     'RECON_INVESTIGATE': '''
#         SELECT *, 
#                IF((ro1.PTPP_Payment + ro1.PTPP_Refund) = (ro1.Cloud_Payment + ro1.Cloud_Refund + ro1.Cloud_MRefund),
#                   "Perfect", "Investigate") AS Remarks 
#         FROM reconciliation.recon_outcome ro1 
#         WHERE (ro1.PTPP_Payment + ro1.PTPP_Refund) != (ro1.Cloud_Payment + ro1.Cloud_Refund + ro1.Cloud_MRefund)
#         ORDER BY ro1.Txn_RefNo
#     ''',
    
#     'MANUAL_REFUND': '''
#         SELECT *, 
#                IF((ro1.PTPP_Payment + ro1.PTPP_Refund) = (ro1.Cloud_Payment + ro1.Cloud_Refund + ro1.Cloud_MRefund),
#                   "Perfect", "Investigate") AS Remarks 
#         FROM reconciliation.recon_outcome ro1 
#         WHERE (ro1.Txn_MID LIKE '%Auto refund%' 
#                OR ro1.Txn_MID LIKE '%manual%' 
#                OR ro1.Txn_MID LIKE '%Manual%'
#                OR ro1.Cloud_MRefund != 0)
#         ORDER BY ro1.Txn_RefNo
#     '''
# }


# def get_db_connection():
#     """Create and return a database connection - YOUR ORIGINAL"""
#     try:
#         conn = mysql.connector.connect(**DB_CONFIG)
#         return conn
#     except mysql.connector.Error as err:
#         logger.error(f"Database connection error: {err}")
#         return None

# def serialize_value(value):
#     """Convert various data types to JSON serializable format - YOUR ORIGINAL"""
#     if value is None:
#         return None
#     elif isinstance(value, datetime):
#         return value.isoformat()
#     elif isinstance(value, bytes):
#         return value.decode('utf-8', errors='ignore')
#     elif isinstance(value, Decimal):
#         return float(value)
#     else:
#         return value

# def execute_query_safe(query):
#     """Execute SQL query with comprehensive error handling - YOUR ORIGINAL"""
#     connection = None
#     try:
#         logger.info("Connecting to database...")
#         connection = mysql.connector.connect(**DB_CONFIG)
#         cursor = connection.cursor(dictionary=True)
        
#         logger.info("Executing query...")
#         cursor.execute(query)
#         results = cursor.fetchall()
        
#         logger.info(f"Query returned {len(results)} rows")
        
#         # Convert to JSON-serializable format
#         processed_results = []
#         for row in results:
#             processed_row = {}
#             for key, value in row.items():
#                 if isinstance(value, Decimal):
#                     processed_row[key] = float(value)
#                 elif value is None:
#                     processed_row[key] = ""
#                 else:
#                     processed_row[key] = str(value)
#             processed_results.append(processed_row)
        
#         return processed_results
        
#     except mysql.connector.Error as db_error:
#         logger.error(f"Database error: {db_error}")
#         return []
#     except Exception as e:
#         logger.error(f"General error in execute_query_safe: {e}")
#         return []
#     finally:
#         if connection and connection.is_connected():
#             cursor.close()
#             connection.close()

# def allowed_file(filename):
#     """Check if file extension is allowed - YOUR ORIGINAL"""
#     return '.' in filename and \
#            filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# def monitor_performance(f):
#     """Performance monitoring decorator - YOUR ORIGINAL"""
#     @wraps(f)
#     def decorated_function(*args, **kwargs):
#         start_time = time.time()
#         result = f(*args, **kwargs)
#         end_time = time.time()
        
#         duration = (end_time - start_time) * 1000
#         logger.info(f" {f.__name__} executed in {duration:.2f}ms")
        
#         if duration > 1000:
#             logger.warning(f" Slow query detected: {f.__name__} took {duration:.2f}ms")
        
#         return result
#     return decorated_function



# def run_batch_files():
#     """Execute the single run_all_scripts.bat file - SIMPLE WORKING VERSION"""
#     global processing_status
    
#     try:
#         processing_status.update({
#             'is_processing': True,
#             'current_step': 1,
#             'total_steps': 1,
#             'progress': 10,
#             'error': None,
#             'completed': False,
#             'start_time': datetime.now().isoformat(),
#             'step_name': 'Complete Reconciliation Process',
#             'message': 'Starting complete reconciliation workflow...'
#         })
        
#         working_dir = str(BASE_DIR)
#         batch_filename = "run_all_scripts.bat"
        
#         logger.info(f"Starting {batch_filename} in directory: {working_dir}")
        
#         # Set environment variable to indicate Flask execution
#         env = os.environ.copy()
#         env['FLASK_EXECUTION'] = '1'
        
#         # Update progress
#         processing_status['progress'] = 20
#         processing_status['message'] = 'Executing complete reconciliation process...'
        
#         # Execute the batch file - SIMPLE AND RELIABLE
#         result = subprocess.run(
#             batch_filename,
#             shell=True,
#             capture_output=True,
#             text=True,
#             cwd=working_dir,
#             env=env,
#             timeout=7200  # 2 hours total timeout
#         )
        
#         processing_status['progress'] = 90
        
#         # Check result
#         if result.returncode != 0:
#             error_msg = f"Reconciliation process failed with exit code {result.returncode}"
            
#             if result.stderr:
#                 error_msg += f"\nError details: {result.stderr[-1000:]}"  # Last 1000 chars
#             if result.stdout:
#                 error_msg += f"\nOutput: {result.stdout[-1000:]}"  # Last 1000 chars
            
#             processing_status.update({
#                 'error': error_msg,
#                 'is_processing': False,
#                 'progress': 0,
#                 'message': f'Failed with exit code {result.returncode}'
#             })
            
#             logger.error(f"run_all_scripts.bat failed: {error_msg}")
#             return
        
#         # SUCCESS!
#         processing_status.update({
#             'message': 'All steps completed! Database updated successfully.',
#             'progress': 100,
#             'completed': True,
#             'is_processing': False
#         })
        
#         logger.info("run_all_scripts.bat completed successfully!")
#         logger.info("Database should now contain reconciliation data")
        
#         # Log some of the output for debugging
#         if result.stdout:
#             logger.info(f"Process output (last 500 chars): {result.stdout[-500:]}")
        
#     except subprocess.TimeoutExpired:
#         error_msg = "Processing timed out after 2 hours"
#         processing_status.update({
#             'error': error_msg,
#             'is_processing': False,
#             'progress': 0,
#             'message': 'Process timed out'
#         })
#         logger.error(error_msg)
        
#     except Exception as e:
#         error_msg = f"Unexpected error: {str(e)}"
#         processing_status.update({
#             'error': error_msg,
#             'is_processing': False,
#             'progress': 0,
#             'message': 'Process failed'
#         })
#         logger.error(error_msg)
#         logger.error(traceback.format_exc())


# # NEW DEBUG ENDPOINTS to verify the fixes
# @app.route('/api/debug/environment', methods=['GET'])
# def debug_environment():
#     """Debug endpoint to check execution environment"""
#     try:
#         current_env = {
#             'BASE_DIR': str(BASE_DIR),
#             'UPLOAD_FOLDER': str(UPLOAD_FOLDER),
#             'working_directory': os.getcwd(),
#             'python_executable': sys.executable,
#             'batch_file_exists': os.path.exists(BATCH_FILES[0]['path']),
#             'batch_file_path': BATCH_FILES[0]['path'],
#             'input_files': [],
#             'environment_sample': {
#                 'PATH': os.environ.get('PATH', '').split(os.pathsep)[:5],
#                 'PYTHONPATH': os.environ.get('PYTHONPATH', 'Not set'),
#                 'USER': os.environ.get('USER', 'Not set'),
#                 'USERNAME': os.environ.get('USERNAME', 'Not set')
#             }
#         }
        
#         # Check input files
#         if os.path.exists(UPLOAD_FOLDER):
#             current_env['input_files'] = [
#                 {
#                     'name': f,
#                     'size': os.path.getsize(os.path.join(UPLOAD_FOLDER, f)),
#                     'modified': datetime.fromtimestamp(
#                         os.path.getmtime(os.path.join(UPLOAD_FOLDER, f))
#                     ).isoformat()
#                 }
#                 for f in os.listdir(UPLOAD_FOLDER)
#                 if os.path.isfile(os.path.join(UPLOAD_FOLDER, f))
#             ]
        
#         return jsonify({
#             'environment': current_env,
#             'processing_status': processing_status,
#             'timestamp': datetime.now().isoformat()
#         })
        
#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# @app.route('/api/debug/test-batch-context', methods=['POST'])
# def test_batch_context():
#     """Test batch file execution with the fixed context"""
#     try:
#         batch_file = BATCH_FILES[0]['path']
#         working_dir = BATCH_FILES[0]['working_dir']
        
#         if not os.path.exists(batch_file):
#             return jsonify({'error': f'Batch file not found: {batch_file}'}), 400
        
#         # Create a simple test command to check context
#         test_cmd = ['cmd.exe', '/c', f'cd && echo WORKING_DIR:%CD% && echo FLASK_TEST_VAR:%FLASK_TEST_VAR%']
        
#         env = os.environ.copy()
#         env['FLASK_TEST_VAR'] = 'TEST_FROM_FLASK'
        
#         result = subprocess.run(
#             test_cmd,
#             cwd=working_dir,
#             env=env,
#             capture_output=True,
#             text=True,
#             timeout=30
#         )
        
#         return jsonify({
#             'test_command': ' '.join(test_cmd),
#             'working_directory': working_dir,
#             'return_code': result.returncode,
#             'stdout': result.stdout,
#             'stderr': result.stderr,
#             'success': result.returncode == 0
#         })
        
#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# # Your original API routes - UNCHANGED (keeping all your working endpoints)
# @app.route('/api/health', methods=['GET', 'OPTIONS'])
# @monitor_performance
# def health_check_optimized():
#     """Enhanced health check with performance metrics - YOUR ORIGINAL"""
#     if request.method == 'OPTIONS':
#         response = jsonify({'status': 'ok'})
#         response.headers.add('Access-Control-Allow-Origin', '*')
#         response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
#         response.headers.add('Access-Control-Allow-Methods', 'GET, OPTIONS')
#         return response
    
#     try:
#         start_time = time.time()
        
#         connection = mysql.connector.connect(**DB_CONFIG)
#         if connection.is_connected():
#             cursor = connection.cursor()
#             cursor.execute("SELECT 1 as test")
#             cursor.fetchone()
#             cursor.execute("SHOW TABLES")
#             tables = cursor.fetchall()
#             cursor.close()
#             connection.close()
            
#             db_response_time = (time.time() - start_time) * 1000
            
#             return jsonify({
#                 'status': 'healthy',
#                 'database': 'connected',
#                 'tables_found': len(tables),
#                 'db_response_time_ms': round(db_response_time, 2),
#                 'timestamp': datetime.now().isoformat(),
#                 'api_version': '2.0_fixed',
#                 'batch_file_status': 'exists' if os.path.exists(BATCH_FILES[0]['path']) else 'missing'
#             })
#         else:
#             return jsonify({
#                 'status': 'unhealthy',
#                 'database': 'disconnected',
#                 'timestamp': datetime.now().isoformat()
#             }), 500
            
#     except Exception as e:
#         logger.error(f"Health check failed: {e}")
#         return jsonify({
#             'status': 'unhealthy',
#             'database': 'error',
#             'error': str(e),
#             'timestamp': datetime.now().isoformat()
#         }), 500

# @app.route('/api/upload', methods=['POST'])
# def upload_file():
#     """Enhanced file upload - ORIGINAL"""
#     try:
#         if 'file' not in request.files:
#             return jsonify({'error': 'No file part in the request'}), 400
        
#         file = request.files['file']
        
#         if file.filename == '':
#             return jsonify({'error': 'No file selected'}), 400
        
#         if file and allowed_file(file.filename):
#             filename = secure_filename(file.filename)
#             filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            
#             # Check if file already exists and create unique name if needed
#             if os.path.exists(filepath):
#                 name, ext = os.path.splitext(filename)
#                 counter = 1
#                 while os.path.exists(filepath):
#                     filename = f"{name}_{counter}{ext}"
#                     filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
#                     counter += 1
            
#             file.save(filepath)
            
#             if 'uploaded_files' not in processing_status:
#                 processing_status['uploaded_files'] = []
            
#             file_info = {
#                 'filename': filename,
#                 'original_filename': file.filename,
#                 'filepath': filepath,
#                 'size': os.path.getsize(filepath),
#                 'upload_time': datetime.now().isoformat(),
#                 'file_type': filename.split('.')[-1].lower()
#             }
#             processing_status['uploaded_files'].append(file_info)
            
#             logger.info(f"File uploaded successfully: {filename} ({file_info['size']} bytes)")
            
#             return jsonify({
#                 'success': True,
#                 'message': 'File uploaded successfully',
#                 'filename': filename,
#                 'original_filename': file.filename,
#                 'filepath': filepath,
#                 'size': file_info['size'],
#                 'file_type': file_info['file_type'],
#                 'timestamp': file_info['upload_time'],
#                 'total_uploaded_files': len(processing_status['uploaded_files'])
#             })
#         else:
#             return jsonify({
#                 'success': False,
#                 'error': f'File type not allowed. Only {", ".join(ALLOWED_EXTENSIONS)} files are permitted'
#             }), 400
            
#     except Exception as e:
#         logger.error(f"Error uploading file: {str(e)}")
#         return jsonify({'success': False, 'error': str(e)}), 500

# @app.route('/api/start-processing', methods=['POST'])
# def start_processing():
#     """FIXED: Enhanced processing start with proper validation"""
#     global processing_status
    
#     try:
#         if processing_status['is_processing']:
#             return jsonify({
#                 'success': False,
#                 'error': 'Processing already in progress',
#                 'status': processing_status
#             }), 400
        
#         # Validate batch file exists
#         batch_file = BATCH_FILES[0]['path']
#         if not os.path.exists(batch_file):
#             error_msg = f"Batch file not found: {batch_file}"
#             return jsonify({
#                 'success': False,
#                 'error': error_msg,
#                 'batch_file_path': batch_file
#             }), 400
        
#         # Check upload folder
#         if not os.path.exists(UPLOAD_FOLDER):
#             error_msg = f"Upload folder not found: {UPLOAD_FOLDER}"
#             return jsonify({'success': False, 'error': error_msg}), 400
        
#         uploaded_files = [f for f in os.listdir(UPLOAD_FOLDER) 
#                          if os.path.isfile(os.path.join(UPLOAD_FOLDER, f))]
        
#         # Reset processing status with execution context
#         processing_status = {
#             'is_processing': True,
#             'current_step': 0,
#             'total_steps': 1,
#             'step_name': 'Initializing',
#             'progress': 0,
#             'message': 'Starting FIXED batch processing...',
#             'error': None,
#             'completed': False,
#             'start_time': datetime.now().isoformat(),
#             'uploaded_files': processing_status.get('uploaded_files', []),
#             'detailed_log': [],
#             'execution_context': {
#                 'working_directory': None,
#                 'environment_vars': {},
#                 'input_files_found': uploaded_files,
#                 'batch_file_exists': True
#             }
#         }
        
#         # Start FIXED batch processing
#         thread = threading.Thread(target=run_batch_files)
#         thread.daemon = True
#         thread.start()
        
#         return jsonify({
#             'success': True,
#             'message': 'FIXED processing started successfully',
#             'status': processing_status,
#             'uploaded_files': uploaded_files,
#             'batch_file_verified': True,
#             'timestamp': datetime.now().isoformat()
#         })
        
#     except Exception as e:
#         error_msg = f"Error starting processing: {str(e)}"
#         logger.error(error_msg)
#         return jsonify({'success': False, 'error': error_msg}), 500

# @app.route('/api/processing-status', methods=['GET'])
# def get_processing_status():
#     """Get current processing status with execution context"""
#     return jsonify({
#         'status': processing_status,
#         'timestamp': datetime.now().isoformat(),
#         'version': 'fixed'
#     })

# # Keep all your original database endpoints unchanged
# @app.route('/api/reconciliation/data', methods=['GET', 'OPTIONS'])
# def get_reconciliation_data():
#     """YOUR ORIGINAL reconciliation data API - UNCHANGED"""
#     if request.method == 'OPTIONS':
#         response = jsonify({'status': 'ok'})
#         response.headers.add('Access-Control-Allow-Origin', '*')
#         response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
#         response.headers.add('Access-Control-Allow-Methods', 'GET, OPTIONS')
#         return response
    
#     try:
#         sheet = request.args.get('sheet', 'RECON_SUCCESS').upper()
#         search_term = request.args.get('search', '').strip()
#         page = int(request.args.get('page', 0))
#         limit = int(request.args.get('limit', 999999))
        
#         logger.info(f"API request for sheet: {sheet}, page: {page}, limit: {limit}")
        
#         if sheet == 'ALL':
#             return jsonify({
#                 'sheets': list(QUERIES.keys()),
#                 'status': 'success',
#                 'timestamp': datetime.now().isoformat()
#             })
        
#         if sheet not in QUERIES:
#             logger.error(f"Invalid sheet requested: {sheet}")
#             return jsonify({
#                 'error': f'Invalid sheet: {sheet}',
#                 'available_sheets': list(QUERIES.keys()),
#                 'status': 'error'
#             }), 400
        
#         query = QUERIES[sheet]
        
#         if search_term and sheet in ['RECON_SUCCESS', 'RECON_INVESTIGATE', 'MANUAL_REFUND']:
#             search_term = search_term.replace("'", "''")
#             search_condition = f"""
#             AND (
#                 Txn_RefNo LIKE '%{search_term}%' OR 
#                 Txn_MID LIKE '%{search_term}%' OR 
#                 Txn_Machine LIKE '%{search_term}%' OR
#                 Remarks LIKE '%{search_term}%'
#             )
#             """
#             if 'ORDER BY' in query:
#                 parts = query.split('ORDER BY', 1)
#                 query = parts[0] + search_condition + ' ORDER BY ' + parts[1]
#             else:
#                 query += search_condition
        
#         offset = page * limit
#         if 'ORDER BY' not in query.upper():
#             if 'recon_outcome' in query.lower():
#                 query += ' ORDER BY Txn_RefNo'
#             else:
#                 query += ' ORDER BY 1'
        
#         query += f' LIMIT {limit} OFFSET {offset}'
        
#         data = execute_query_safe(query)
        
#         if data is None:
#             logger.error(f"Query execution failed for sheet: {sheet}")
#             return jsonify([])
        
#         logger.info(f"Query successful for {sheet}: {len(data)} records")
        
#         total_count = None
#         if len(data) == limit:
#             try:
#                 if sheet in ['RECON_SUCCESS', 'RECON_INVESTIGATE', 'MANUAL_REFUND']:
#                     count_query = "SELECT COUNT(*) as total FROM reconciliation.recon_outcome"
                    
#                     if sheet == 'RECON_SUCCESS':
#                         count_query += " WHERE (PTPP_Payment + PTPP_Refund) = (Cloud_Payment + Cloud_Refund + Cloud_MRefund)"
#                     elif sheet == 'RECON_INVESTIGATE':
#                         count_query += " WHERE (PTPP_Payment + PTPP_Refund) != (Cloud_Payment + Cloud_Refund + Cloud_MRefund)"
#                     elif sheet == 'MANUAL_REFUND':
#                         count_query += " WHERE (Txn_MID LIKE '%Auto refund%' OR Txn_MID LIKE '%manual%' OR Txn_MID LIKE '%Manual%' OR Cloud_MRefund != 0)"
                    
#                     if search_term:
#                         search_condition = f"""
#                         AND (
#                             Txn_RefNo LIKE '%{search_term}%' OR 
#                             Txn_MID LIKE '%{search_term}%' OR 
#                             Txn_Machine LIKE '%{search_term}%'
#                         )
#                         """
#                         count_query += search_condition
                
#                 elif sheet == 'SUMMARY':
#                     count_query = """
#                     SELECT COUNT(*) as total FROM (
#                         SELECT DISTINCT txn_source, Txn_type FROM reconciliation.payment_refund 
#                         UNION 
#                         SELECT DISTINCT Txn_Source, Txn_type FROM reconciliation.paytm_phonepe
#                     ) as summary_union
#                     """
                
#                 elif sheet == 'RAWDATA':
#                     count_query = """
#                     SELECT (
#                         (SELECT COUNT(*) FROM reconciliation.paytm_phonepe) + 
#                         (SELECT COUNT(*) FROM reconciliation.payment_refund)
#                     ) as total
#                     """
                
#                 count_result = execute_query_safe(count_query)
#                 if count_result and len(count_result) > 0:
#                     raw_total = count_result[0].get('total', len(data))
#                     if isinstance(raw_total, str):
#                         total_count = int(float(raw_total))
#                     elif isinstance(raw_total, (int, float, Decimal)):
#                         total_count = int(raw_total)
#                     else:
#                         total_count = len(data)
                        
#             except Exception as e:
#                 logger.error(f"Error getting total count: {e}")
#                 total_count = len(data)
        
#         response_data = {
#             'data': data,
#             'count': len(data),
#             'page': page,
#             'limit': limit,
#             'sheet': sheet,
#             'timestamp': datetime.now().isoformat(),
#             'status': 'success',
#             'search_applied': search_term if search_term else None,
#         }
        
#         if total_count is not None:
#             response_data['total_count'] = total_count
#             response_data['total_pages'] = (total_count + limit - 1) // limit
#             response_data['has_more'] = (page + 1) * limit < total_count
        
#         return jsonify(response_data)
        
#     except ValueError as ve:
#         logger.error(f"Parameter error in get_reconciliation_data: {str(ve)}")
#         return jsonify({
#             'error': f'Invalid parameter: {str(ve)}',
#             'status': 'error',
#             'timestamp': datetime.now().isoformat()
#         }), 400
        
#     except Exception as e:
#         logger.error(f"Error in get_reconciliation_data: {str(e)}")
#         logger.error(f"Full traceback: {traceback.format_exc()}")
#         return jsonify({
#             'error': str(e),
#             'status': 'error',
#             'timestamp': datetime.now().isoformat()
#         }), 500

# # Keep all your other original endpoints
# @app.route('/api/reconciliation/sheet/<sheet_name>', methods=['GET'])
# def get_sheet_data(sheet_name):
#     """Get data for a specific sheet - YOUR ORIGINAL"""
#     try:
#         sheet_upper = sheet_name.upper()
        
#         if sheet_upper not in QUERIES:
#             return jsonify({
#                 'error': f'Invalid sheet name. Available: {list(QUERIES.keys())}',
#                 'status': 'error'
#             }), 400
        
#         search_term = request.args.get('search', '').strip()
#         query = QUERIES[sheet_upper]
        
#         if search_term:
#             search_term = search_term.replace("'", "''")
#             if sheet_upper in ['RECON_SUCCESS', 'RECON_INVESTIGATE', 'MANUAL_REFUND']:
#                 search_condition = f"""
#                 AND (
#                     Txn_RefNo LIKE '%{search_term}%' OR 
#                     Txn_MID LIKE '%{search_term}%' OR 
#                     Txn_Machine LIKE '%{search_term}%'
#                 )
#                 """
#                 if 'ORDER BY' in query:
#                     parts = query.split('ORDER BY', 1)
#                     query = parts[0] + search_condition + ' ORDER BY ' + parts[1]
#                 else:
#                     query += search_condition
        
#         data = execute_query_safe(query)
        
#         if data is None:
#             return jsonify({
#                 'error': f'Failed to execute query for {sheet_name}',
#                 'status': 'error'
#             }), 500
        
#         return jsonify({
#             'data': data,
#             'count': len(data),
#             'sheet': sheet_upper,
#             'timestamp': datetime.now().isoformat(),
#             'status': 'success',
#             'search_applied': search_term if search_term else None,
#         })
        
#     except Exception as e:
#         logger.error(f"Error fetching sheet {sheet_name}: {str(e)}")
#         return jsonify({
#             'error': str(e),
#             'status': 'error',
#             'timestamp': datetime.now().isoformat()
#         }), 500

# @app.route('/api/reconciliation/stats', methods=['GET'])
# def get_reconciliation_stats():
#     """Get summary statistics for all sheets - YOUR ORIGINAL"""
#     try:
#         stats = {}
        
#         for sheet_name, query in QUERIES.items():
#             try:
#                 data = execute_query_safe(query)
#                 if data:
#                     stats[sheet_name] = {
#                         'total_records': len(data),
#                         'sheet_type': _get_sheet_description(sheet_name)
#                     }
                    
#                     if sheet_name in ['RECON_SUCCESS', 'RECON_INVESTIGATE', 'MANUAL_REFUND']:
#                         total_amount = sum(
#                             (float(row.get('PTPP_Payment', 0) or 0)) + (float(row.get('PTPP_Refund', 0) or 0))
#                             for row in data
#                         )
#                         stats[sheet_name]['total_amount'] = total_amount
#                 else:
#                     stats[sheet_name] = {
#                         'total_records': 0,
#                         'sheet_type': _get_sheet_description(sheet_name),
#                         'error': 'No data available'
#                     }
#             except Exception as e:
#                 stats[sheet_name] = {
#                     'total_records': 0,
#                     'sheet_type': _get_sheet_description(sheet_name),
#                     'error': str(e)
#                 }
        
#         return jsonify({
#             'stats': stats,
#             'timestamp': datetime.now().isoformat(),
#             'status': 'success'
#         })
        
#     except Exception as e:
#         logger.error(f"Error fetching reconciliation stats: {str(e)}")
#         return jsonify({
#             'error': str(e),
#             'status': 'error'
#         }), 500

# def _get_sheet_description(sheet_name):
#     """Get description for each sheet type"""
#     descriptions = {
#         'SUMMARY': 'Transaction summary by source and type',
#         'RAWDATA': 'All raw transaction data',
#         'RECON_SUCCESS': 'Perfect reconciliation matches',
#         'RECON_INVESTIGATE': 'Transactions requiring investigation',
#         'MANUAL_REFUND': 'Manual refund transactions'
#     }
#     return descriptions.get(sheet_name, 'Unknown sheet type')

# @app.route('/api/reconciliation/summary', methods=['GET'])
# def get_summary():
#     """Get summary statistics - YOUR ORIGINAL"""
#     try:
#         data = execute_query_safe(QUERIES['SUMMARY'])
        
#         if data is None:
#             return jsonify({'error': 'Failed to execute summary query'}), 500
        
#         return jsonify({
#             'data': data,
#             'count': len(data),
#             'timestamp': datetime.now().isoformat(),
#             'status': 'success'
#         })
        
#     except Exception as e:
#         logger.error(f"Error fetching summary: {str(e)}")
#         return jsonify({'error': str(e)}), 500

# @app.route('/api/reconciliation/refresh', methods=['POST'])
# def refresh_data():
#     """Refresh data - YOUR ORIGINAL"""
#     try:
#         conn = get_db_connection()
#         if not conn:
#             return jsonify({'error': 'Database connection failed'}), 500
        
#         cursor = conn.cursor()
#         cursor.execute("SELECT COUNT(*) FROM reconciliation.paytm_phonepe")
#         paytm_count = cursor.fetchone()[0]
        
#         cursor.execute("SELECT COUNT(*) FROM reconciliation.payment_refund")
#         payment_count = cursor.fetchone()[0]
        
#         cursor.close()
#         conn.close()
        
#         return jsonify({
#             'message': 'Data refresh completed',
#             'paytm_phonepe_records': paytm_count,
#             'payment_refund_records': payment_count,
#             'total_records': paytm_count + payment_count,
#             'status': 'success',
#             'timestamp': datetime.now().isoformat()
#         })
        
#     except Exception as e:
#         logger.error(f"Error refreshing data: {str(e)}")
#         return jsonify({'error': str(e)}), 500

# @app.route('/api/database/status', methods=['GET', 'OPTIONS'])
# def get_database_status():
#     """Get database table status - YOUR ORIGINAL"""
#     if request.method == 'OPTIONS':
#         response = jsonify({'status': 'ok'})
#         response.headers.add('Access-Control-Allow-Origin', '*')
#         response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
#         response.headers.add('Access-Control-Allow-Methods', 'GET, OPTIONS')
#         return response
    
#     try:
#         connection = mysql.connector.connect(**DB_CONFIG)
#         cursor = connection.cursor()
        
#         table_counts = {}
#         tables = ['payment_refund', 'paytm_phonepe', 'recon_outcome']
        
#         for table in tables:
#             try:
#                 cursor.execute(f"SELECT COUNT(*) FROM {table}")
#                 count = cursor.fetchone()[0]
#                 table_counts[table] = count
#             except Exception as e:
#                 table_counts[table] = f"Error: {str(e)}"
        
#         cursor.close()
#         connection.close()
        
#         return jsonify({
#             'status': 'success',
#             'table_counts': table_counts,
#             'timestamp': datetime.now().isoformat()
#         })
        
#     except Exception as e:
#         logger.error(f"Database status check failed: {e}")
#         return jsonify({
#             'status': 'error',
#             'error': str(e),
#             'timestamp': datetime.now().isoformat()
#         }), 500

# if __name__ == '__main__':
#     # Enhanced startup with validation
#     print("=" * 70)
#     print(" FIXED RECONCILIATION API SERVER")
#     print("=" * 70)
#     print(f" Startup Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
#     print(f"  Database: {DB_CONFIG['database']} on {DB_CONFIG['host']}")
#     print(f" Upload Folder: {UPLOAD_FOLDER}")
#     print(f" Base Directory: {BASE_DIR}")
#     print(f" Batch Files: {len(BATCH_FILES)}")
    
#     # Validate paths
#     print(f"\n PATH VALIDATION:")
#     print(f" BASE_DIR exists: {BASE_DIR.exists()}")
#     print(f" UPLOAD_FOLDER exists: {UPLOAD_FOLDER.exists()}")
    
#     for i, batch_file in enumerate(BATCH_FILES):
#         exists = os.path.exists(batch_file['path'])
#         print(f"{'' if exists else ''} Batch file {i+1}: {batch_file['path']}")
#         if not exists:
#             print(f"     Create this file or update the path in BATCH_FILES")
    
#     print("\n" + "="*50)
#     print(" DATABASE CONNECTION TEST")
#     print("="*50)
    
#     try:
#         conn = get_db_connection()
#         if conn and conn.is_connected():
#             print(" Database connection successful")
            
#             cursor = conn.cursor()
#             cursor.execute("SHOW TABLES")
#             tables = cursor.fetchall()
#             print(f" Found {len(tables)} tables in database")
            
#             # Test each required table
#             required_tables = ['payment_refund', 'paytm_phonepe', 'recon_outcome']
#             table_names = [table[0] for table in tables]
            
#             for table in required_tables:
#                 if table in table_names:
#                     cursor.execute(f"SELECT COUNT(*) FROM {table}")
#                     count = cursor.fetchone()[0]
#                     print(f" Table {table}: {count} records")
#                 else:
#                     print(f" Table {table}: NOT FOUND")
            
#             cursor.close()
#             conn.close()
#         else:
#             print(" Database connection failed")
#             print("Please check:")
#             print("  1. MySQL server is running")
#             print("  2. Database 'reconciliation' exists") 
#             print("  3. Credentials in DB_CONFIG are correct")
#     except Exception as e:
#         print(f" Database connection error: {e}")
#         print("Please ensure MySQL is running and credentials are correct")
    
#     print("\n" + "="*50)
#     print(" API ENDPOINTS")
#     print("="*50)
#     print("  GET  /api/health")
#     print("  POST /api/upload")
#     print("  POST /api/start-processing")
#     print("  GET  /api/processing-status")
#     print("  GET  /api/reconciliation/data")
#     print("  GET  /api/reconciliation/sheet/<sheet_name>")
#     print("  GET  /api/reconciliation/stats")
#     print("  POST /api/reconciliation/refresh")
#     print("  GET  /api/debug/environment")
#     print("  POST /api/debug/test-batch-context")
#     print("="*70)
#     print(" FIXES APPLIED:")
#     print("   Working directory set correctly")
#     print("   Environment variables configured")
#     print("   Absolute paths used")
#     print("   Proper subprocess context")
#     print("   Enhanced logging and debugging")
#     print("="*70)
    
#     # Start the Flask application
#     app.run(debug=True, host='0.0.0.0', port=5000, threaded=True)

#2


# import os
# from pathlib import Path
# from flask import Flask, jsonify, request
# from flask_cors import CORS
# import mysql.connector
# import pandas as pd
# from datetime import datetime
# import logging
# import traceback
# from decimal import Decimal
# import subprocess
# import threading
# import time
# from werkzeug.utils import secure_filename
# from functools import wraps

# # Configuration
# BASE_DIR = Path(__file__).parent.resolve()
# UPLOAD_FOLDER = BASE_DIR / 'Input_Files'
# ALLOWED_EXTENSIONS = {'zip', 'xlsx', 'xls', 'csv'}
# MAX_FILE_SIZE = 50 * 1024 * 1024

# # Flask app setup
# app = Flask(__name__)
# CORS(app)

# # Logging configuration
# logging.basicConfig(
#     level=logging.INFO,
#     format='%(asctime)s - %(levelname)s - %(funcName)s:%(lineno)d - %(message)s',
#     handlers=[
#         logging.StreamHandler(),
#         logging.FileHandler(BASE_DIR / 'recon_api.log')
#     ]
# )
# logger = logging.getLogger(__name__)

# # Database configuration
# DB_CONFIG = {
#     'host': 'localhost',
#     'user': 'root',
#     'password': 'Templerun@2',
#     'database': 'reconciliation'
# }

# # Processing status tracker
# processing_status = {
#     'is_processing': False,
#     'current_step': 0,
#     'total_steps': 3,
#     'step_name': '',
#     'progress': 0,
#     'message': '',
#     'error': None,
#     'completed': False,
#     'start_time': None,
#     'uploaded_files': []
# }

# # File upload configuration
# app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
# app.config['MAX_CONTENT_LENGTH'] = MAX_FILE_SIZE

# # Ensure directories exist
# os.makedirs(UPLOAD_FOLDER, exist_ok=True)
# os.makedirs(BASE_DIR / 'Output_Files', exist_ok=True)

# # RECON_SUMMARY QUERIES - Based on your Generate_Recon_Summary.py
# RECON_SUMMARY_QUERIES = {
#     'RECON_SUCCESS': '''
#         SELECT * FROM reconciliation.recon_summary 
#         WHERE ((Cloud_Payment + Cloud_Refund) = 
#                (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
#                 VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
#                 Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment))
#         ORDER BY Txn_Date DESC, Txn_RefNo
#     ''',
    
#     'RECON_INVESTIGATE': '''
#         SELECT * FROM reconciliation.recon_summary 
#         WHERE ((Cloud_Payment + Cloud_Refund) <> 
#                (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
#                 VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
#                 Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment))
#         ORDER BY Txn_Date DESC, Txn_RefNo
#     ''',
    
#     # All records with calculated totals and status
#     'ALL_WITH_STATUS': '''
#         SELECT *,
#                (Cloud_Payment + Cloud_Refund) as Cloud_Total,
#                (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
#                 VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
#                 Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment) as Gateway_Total,
#                CASE 
#                    WHEN ((Cloud_Payment + Cloud_Refund) = 
#                          (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
#                           VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
#                           Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment))
#                    THEN 'Perfect'
#                    ELSE 'Investigate'
#                END as Reconciliation_Status,
#                ABS((Cloud_Payment + Cloud_Refund) - 
#                    (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
#                     VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
#                     Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment)) as Difference_Amount
#         FROM reconciliation.recon_summary
#         ORDER BY Txn_Date DESC, Txn_RefNo
#     ''',
    
#     # Summary statistics
#     'STATISTICS': '''
#         SELECT 
#             COUNT(*) as total_transactions,
#             SUM(Cloud_Payment + Cloud_Refund) as total_cloud_amount,
#             SUM(Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
#                 VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
#                 Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment) as total_gateway_amount,
#             SUM(CASE 
#                 WHEN ((Cloud_Payment + Cloud_Refund) = 
#                       (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
#                        VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
#                        Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment))
#                 THEN 1 ELSE 0 END) as perfect_matches,
#             SUM(CASE 
#                 WHEN ((Cloud_Payment + Cloud_Refund) <> 
#                       (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
#                        VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
#                        Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment))
#                 THEN 1 ELSE 0 END) as needs_investigation,
#             SUM(ABS((Cloud_Payment + Cloud_Refund) - 
#                     (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
#                      VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
#                      Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment))) as total_difference_amount,
#             MIN(Txn_Date) as earliest_transaction,
#             MAX(Txn_Date) as latest_transaction
#         FROM reconciliation.recon_summary
#     ''',
    
#     # Payment method breakdown
#     'PAYMENT_METHOD_BREAKDOWN': '''
#         SELECT 
#             'PayTM' as payment_method,
#             SUM(Paytm_Payment) as total_payments,
#             SUM(ABS(Paytm_Refund)) as total_refunds,
#             COUNT(CASE WHEN Paytm_Payment > 0 THEN 1 END) as payment_count,
#             COUNT(CASE WHEN Paytm_Refund < 0 THEN 1 END) as refund_count
#         FROM reconciliation.recon_summary
#         WHERE Paytm_Payment > 0 OR Paytm_Refund < 0
        
#         UNION ALL
        
#         SELECT 
#             'PhonePe' as payment_method,
#             SUM(Phonepe_Payment) as total_payments,
#             SUM(ABS(Phonepe_Refund)) as total_refunds,
#             COUNT(CASE WHEN Phonepe_Payment > 0 THEN 1 END) as payment_count,
#             COUNT(CASE WHEN Phonepe_Refund < 0 THEN 1 END) as refund_count
#         FROM reconciliation.recon_summary
#         WHERE Phonepe_Payment > 0 OR Phonepe_Refund < 0
        
#         UNION ALL
        
#         SELECT 
#             'VMS Money' as payment_method,
#             SUM(VMSMoney_Payment) as total_payments,
#             SUM(ABS(VMSMoney_Refund)) as total_refunds,
#             COUNT(CASE WHEN VMSMoney_Payment > 0 THEN 1 END) as payment_count,
#             COUNT(CASE WHEN VMSMoney_Refund < 0 THEN 1 END) as refund_count
#         FROM reconciliation.recon_summary
#         WHERE VMSMoney_Payment > 0 OR VMSMoney_Refund < 0
        
#         UNION ALL
        
#         SELECT 
#             'HDFC UPI' as payment_method,
#             SUM(HDFC_Payment) as total_payments,
#             SUM(ABS(HDFC_Refund)) as total_refunds,
#             COUNT(CASE WHEN HDFC_Payment > 0 THEN 1 END) as payment_count,
#             COUNT(CASE WHEN HDFC_Refund < 0 THEN 1 END) as refund_count
#         FROM reconciliation.recon_summary
#         WHERE HDFC_Payment > 0 OR HDFC_Refund < 0
        
#         UNION ALL
        
#         SELECT 
#             'Cards' as payment_method,
#             SUM(Card_Payment) as total_payments,
#             SUM(ABS(Card_Refund)) as total_refunds,
#             COUNT(CASE WHEN Card_Payment > 0 THEN 1 END) as payment_count,
#             COUNT(CASE WHEN Card_Refund < 0 THEN 1 END) as refund_count
#         FROM reconciliation.recon_summary
#         WHERE Card_Payment > 0 OR Card_Refund < 0
        
#         UNION ALL
        
#         SELECT 
#             'Sodexo' as payment_method,
#             SUM(Sodexo_Payment) as total_payments,
#             SUM(ABS(Sodexo_Refund)) as total_refunds,
#             COUNT(CASE WHEN Sodexo_Payment > 0 THEN 1 END) as payment_count,
#             COUNT(CASE WHEN Sodexo_Refund < 0 THEN 1 END) as refund_count
#         FROM reconciliation.recon_summary
#         WHERE Sodexo_Payment > 0 OR Sodexo_Refund < 0
        
#         UNION ALL
        
#         SELECT 
#             'Cash' as payment_method,
#             SUM(Cash_Payment) as total_payments,
#             0 as total_refunds,
#             COUNT(CASE WHEN Cash_Payment > 0 THEN 1 END) as payment_count,
#             0 as refund_count
#         FROM reconciliation.recon_summary
#         WHERE Cash_Payment > 0
        
#         ORDER BY total_payments DESC
#     '''
# }



# def get_db_connection():
#     """Create and return a database connection"""
#     try:
#         conn = mysql.connector.connect(**DB_CONFIG)
#         return conn
#     except mysql.connector.Error as err:
#         logger.error(f"Database connection error: {err}")
#         return None

# def serialize_value(value):
#     """Convert various data types to JSON serializable format"""
#     if value is None:
#         return None
#     elif isinstance(value, datetime):
#         return value.isoformat()
#     elif isinstance(value, bytes):
#         return value.decode('utf-8', errors='ignore')
#     elif isinstance(value, Decimal):
#         return float(value)
#     else:
#         return value

# def execute_query_safe(query):
#     """Execute SQL query with comprehensive error handling"""
#     connection = None
#     try:
#         logger.info("Connecting to database...")
#         connection = mysql.connector.connect(**DB_CONFIG)
#         cursor = connection.cursor(dictionary=True)
        
#         logger.info("Executing query...")
#         cursor.execute(query)
#         results = cursor.fetchall()
        
#         logger.info(f"Query returned {len(results)} rows")
        
#         # Convert to JSON-serializable format
#         processed_results = []
#         for row in results:
#             processed_row = {}
#             for key, value in row.items():
#                 if isinstance(value, Decimal):
#                     processed_row[key] = float(value)
#                 elif value is None:
#                     processed_row[key] = ""
#                 else:
#                     processed_row[key] = str(value)
#             processed_results.append(processed_row)
        
#         return processed_results
        
#     except mysql.connector.Error as db_error:
#         logger.error(f"Database error: {db_error}")
#         return []
#     except Exception as e:
#         logger.error(f"General error in execute_query_safe: {e}")
#         return []
#     finally:
#         if connection and connection.is_connected():
#             cursor.close()
#             connection.close()

# def allowed_file(filename):
#     """Check if file extension is allowed"""
#     return '.' in filename and \
#            filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# def run_reconciliation_process():
#     """Execute the complete reconciliation process"""
#     global processing_status
    
#     try:
#         processing_status.update({
#             'is_processing': True,
#             'current_step': 1,
#             'total_steps': 3,
#             'progress': 10,
#             'error': None,
#             'completed': False,
#             'start_time': datetime.now().isoformat(),
#             'step_name': 'Complete Reconciliation Process',
#             'message': 'Starting reconciliation workflow...'
#         })
        
#         working_dir = str(BASE_DIR)
#         batch_filename = "run_all_scripts.bat"
        
#         logger.info(f"Starting {batch_filename} in directory: {working_dir}")
        
#         # Set environment variable to indicate Flask execution
#         env = os.environ.copy()
#         env['FLASK_EXECUTION'] = '1'
        
#         # Update progress
#         processing_status['progress'] = 20
#         processing_status['message'] = 'Executing reconciliation process...'
        
#         # Execute the batch file
#         result = subprocess.run(
#             batch_filename,
#             shell=True,
#             capture_output=True,
#             text=True,
#             cwd=working_dir,
#             env=env,
#             timeout=7200  # 2 hours timeout
#         )
        
#         processing_status['progress'] = 90
        
#         # Check result
#         if result.returncode != 0:
#             error_msg = f"Reconciliation process failed with exit code {result.returncode}"
            
#             if result.stderr:
#                 error_msg += f"\nError details: {result.stderr[-1000:]}"
#             if result.stdout:
#                 error_msg += f"\nOutput: {result.stdout[-1000:]}"
            
#             processing_status.update({
#                 'error': error_msg,
#                 'is_processing': False,
#                 'progress': 0,
#                 'message': f'Failed with exit code {result.returncode}'
#             })
            
#             logger.error(f"run_all_scripts.bat failed: {error_msg}")
#             return
        
#         # SUCCESS!
#         processing_status.update({
#             'message': 'All steps completed! Recon_Summary data updated successfully.',
#             'progress': 100,
#             'completed': True,
#             'is_processing': False
#         })
        
#         logger.info("run_all_scripts.bat completed successfully!")
#         logger.info("Recon_Summary table should now contain updated data")
        
#     except subprocess.TimeoutExpired:
#         error_msg = "Processing timed out after 2 hours"
#         processing_status.update({
#             'error': error_msg,
#             'is_processing': False,
#             'progress': 0,
#             'message': 'Process timed out'
#         })
#         logger.error(error_msg)
        
#     except Exception as e:
#         error_msg = f"Unexpected error: {str(e)}"
#         processing_status.update({
#             'error': error_msg,
#             'is_processing': False,
#             'progress': 0,
#             'message': 'Process failed'
#         })
#         logger.error(error_msg)
#         logger.error(traceback.format_exc())

# # API ENDPOINTS

# @app.route('/api/health', methods=['GET', 'OPTIONS'])
# def health_check():
#     """Health check endpoint with Recon_Summary table validation"""
#     if request.method == 'OPTIONS':
#         response = jsonify({'status': 'ok'})
#         response.headers.add('Access-Control-Allow-Origin', '*')
#         response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
#         response.headers.add('Access-Control-Allow-Methods', 'GET, OPTIONS')
#         return response
    
#     try:
#         start_time = time.time()
        
#         connection = mysql.connector.connect(**DB_CONFIG)
#         if connection.is_connected():
#             cursor = connection.cursor()
#             cursor.execute("SELECT 1 as test")
#             cursor.fetchone()
            
#             # Check if recon_summary table exists and has data
#             cursor.execute("SELECT COUNT(*) FROM reconciliation.recon_summary")
#             recon_count = cursor.fetchone()[0]
            
#             # Check related tables
#             cursor.execute("SELECT COUNT(*) FROM reconciliation.payment_refund")
#             payment_count = cursor.fetchone()[0]
            
#             cursor.execute("SELECT COUNT(*) FROM reconciliation.paytm_phonepe")
#             paytm_phonepe_count = cursor.fetchone()[0]
            
#             cursor.close()
#             connection.close()
            
#             db_response_time = (time.time() - start_time) * 1000
            
#             return jsonify({
#                 'status': 'healthy',
#                 'database': 'connected',
#                 'table_counts': {
#                     'recon_summary': recon_count,
#                     'payment_refund': payment_count,
#                     'paytm_phonepe': paytm_phonepe_count
#                 },
#                 'db_response_time_ms': round(db_response_time, 2),
#                 'timestamp': datetime.now().isoformat(),
#                 'api_version': 'recon_summary_focused_v2',
#                 'batch_file_status': 'exists' if os.path.exists(BASE_DIR / 'run_all_scripts.bat') else 'missing'
#             })
#         else:
#             return jsonify({
#                 'status': 'unhealthy',
#                 'database': 'disconnected',
#                 'timestamp': datetime.now().isoformat()
#             }), 500
            
#     except Exception as e:
#         logger.error(f"Health check failed: {e}")
#         return jsonify({
#             'status': 'unhealthy',
#             'database': 'error',
#             'error': str(e),
#             'timestamp': datetime.now().isoformat()
#         }), 500

# @app.route('/api/upload', methods=['POST'])
# def upload_file():
#     """File upload endpoint"""
#     try:
#         if 'file' not in request.files:
#             return jsonify({'error': 'No file part in the request'}), 400
        
#         file = request.files['file']
        
#         if file.filename == '':
#             return jsonify({'error': 'No file selected'}), 400
        
#         if file and allowed_file(file.filename):
#             filename = secure_filename(file.filename)
#             filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            
#             # Create unique name if file already exists
#             if os.path.exists(filepath):
#                 name, ext = os.path.splitext(filename)
#                 counter = 1
#                 while os.path.exists(filepath):
#                     filename = f"{name}_{counter}{ext}"
#                     filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
#                     counter += 1
            
#             file.save(filepath)
            
#             file_info = {
#                 'filename': filename,
#                 'original_filename': file.filename,
#                 'filepath': filepath,
#                 'size': os.path.getsize(filepath),
#                 'upload_time': datetime.now().isoformat(),
#                 'file_type': filename.split('.')[-1].lower()
#             }
            
#             processing_status['uploaded_files'].append(file_info)
            
#             logger.info(f"File uploaded successfully: {filename} ({file_info['size']} bytes)")
            
#             return jsonify({
#                 'success': True,
#                 'message': 'File uploaded successfully',
#                 'filename': filename,
#                 'original_filename': file.filename,
#                 'filepath': filepath,
#                 'size': file_info['size'],
#                 'file_type': file_info['file_type'],
#                 'timestamp': file_info['upload_time'],
#                 'total_uploaded_files': len(processing_status['uploaded_files'])
#             })
#         else:
#             return jsonify({
#                 'success': False,
#                 'error': f'File type not allowed. Only {", ".join(ALLOWED_EXTENSIONS)} files are permitted'
#             }), 400
            
#     except Exception as e:
#         logger.error(f"Error uploading file: {str(e)}")
#         return jsonify({'success': False, 'error': str(e)}), 500

# @app.route('/api/start-processing', methods=['POST'])
# def start_processing():
#     """Start reconciliation processing"""
#     global processing_status
    
#     try:
#         if processing_status['is_processing']:
#             return jsonify({
#                 'success': False,
#                 'error': 'Processing already in progress',
#                 'status': processing_status
#             }), 400
        
#         # Validate batch file exists
#         batch_file = BASE_DIR / 'run_all_scripts.bat'
#         if not batch_file.exists():
#             error_msg = f"Batch file not found: {batch_file}"
#             return jsonify({
#                 'success': False,
#                 'error': error_msg,
#                 'batch_file_path': str(batch_file)
#             }), 400
        
#         # Check upload folder
#         if not UPLOAD_FOLDER.exists():
#             error_msg = f"Upload folder not found: {UPLOAD_FOLDER}"
#             return jsonify({'success': False, 'error': error_msg}), 400
        
#         uploaded_files = [f for f in os.listdir(UPLOAD_FOLDER) 
#                          if os.path.isfile(os.path.join(UPLOAD_FOLDER, f))]
        
#         # Reset processing status
#         processing_status = {
#             'is_processing': True,
#             'current_step': 0,
#             'total_steps': 3,
#             'step_name': 'Initializing',
#             'progress': 0,
#             'message': 'Starting reconciliation processing...',
#             'error': None,
#             'completed': False,
#             'start_time': datetime.now().isoformat(),
#             'uploaded_files': processing_status.get('uploaded_files', [])
#         }
        
#         # Start processing in background thread
#         thread = threading.Thread(target=run_reconciliation_process)
#         thread.daemon = True
#         thread.start()
        
#         return jsonify({
#             'success': True,
#             'message': 'Reconciliation processing started successfully',
#             'status': processing_status,
#             'uploaded_files': uploaded_files,
#             'batch_file_verified': True,
#             'timestamp': datetime.now().isoformat()
#         })
        
#     except Exception as e:
#         error_msg = f"Error starting processing: {str(e)}"
#         logger.error(error_msg)
#         return jsonify({'success': False, 'error': error_msg}), 500

# @app.route('/api/reconciliation/data', methods=['GET', 'OPTIONS'])
# def get_reconciliation_data():
#     """Get Recon_Summary data with filtering and pagination - Main endpoint for Flutter"""
#     if request.method == 'OPTIONS':
#         response = jsonify({'status': 'ok'})
#         response.headers.add('Access-Control-Allow-Origin', '*')
#         response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
#         response.headers.add('Access-Control-Allow-Methods', 'GET, OPTIONS')
#         return response
    
#     try:
#         # Get query parameters
#         filter_type = request.args.get('filter', 'all').lower()  # all, success, investigate, statistics, payment_breakdown
#         search_term = request.args.get('search', '').strip()
#         page = int(request.args.get('page', 0))
#         limit = int(request.args.get('limit', 100))
        
#         logger.info(f"API request - filter: {filter_type}, page: {page}, limit: {limit}")
        
#         # Determine which query to use based on filter
#         if filter_type == 'success':
#             base_query = RECON_SUMMARY_QUERIES['RECON_SUCCESS']
#         elif filter_type == 'investigate':
#             base_query = RECON_SUMMARY_QUERIES['RECON_INVESTIGATE']
#         elif filter_type == 'statistics':
#             # Return statistics
#             stats_data = execute_query_safe(RECON_SUMMARY_QUERIES['STATISTICS'])
#             return jsonify({
#                 'data': stats_data,
#                 'count': len(stats_data),
#                 'filter': filter_type,
#                 'timestamp': datetime.now().isoformat(),
#                 'status': 'success'
#             })
#         elif filter_type == 'payment_breakdown':
#             # Return payment method breakdown
#             breakdown_data = execute_query_safe(RECON_SUMMARY_QUERIES['PAYMENT_METHOD_BREAKDOWN'])
#             return jsonify({
#                 'data': breakdown_data,
#                 'count': len(breakdown_data),
#                 'filter': filter_type,
#                 'timestamp': datetime.now().isoformat(),
#                 'status': 'success'
#             })
#         else:
#             # Default: all records with status
#             base_query = RECON_SUMMARY_QUERIES['ALL_WITH_STATUS']
        
#         # Add search condition if provided
#         query = base_query
#         if search_term:
#             search_term = search_term.replace("'", "''")  # SQL injection protection
#             search_condition = f"""
#             AND (
#                 Txn_RefNo LIKE '%{search_term}%' OR 
#                 Txn_MID LIKE '%{search_term}%' OR 
#                 Txn_Machine LIKE '%{search_term}%' OR
#                 Txn_Source LIKE '%{search_term}%' OR
#                 Txn_Type LIKE '%{search_term}%'
#             )
#             """
#             # Insert search condition before ORDER BY
#             if 'ORDER BY' in query:
#                 parts = query.split('ORDER BY', 1)
#                 query = parts[0] + search_condition + ' ORDER BY ' + parts[1]
#             else:
#                 query += search_condition
        
#         # Add pagination
#         offset = page * limit
#         query += f' LIMIT {limit} OFFSET {offset}'
        
#         # Execute query
#         data = execute_query_safe(query)
        
#         if data is None:
#             logger.error(f"Query execution failed for filter: {filter_type}")
#             return jsonify({
#                 'data': [],
#                 'count': 0,
#                 'error': 'Query execution failed'
#             }), 500
        
#         logger.info(f"Query successful for {filter_type}: {len(data)} records")
        
#         # Get total count for pagination (if needed)
#         total_count = None
#         if len(data) == limit:
#             try:
#                 count_query = "SELECT COUNT(*) as total FROM reconciliation.recon_summary"
                
#                 if filter_type == 'success':
#                     count_query += " WHERE ((Cloud_Payment + Cloud_Refund) = (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment))"
#                 elif filter_type == 'investigate':
#                     count_query += " WHERE ((Cloud_Payment + Cloud_Refund) <> (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment))"
                
#                 if search_term:
#                     search_condition = f" AND (Txn_RefNo LIKE '%{search_term}%' OR Txn_MID LIKE '%{search_term}%' OR Txn_Machine LIKE '%{search_term}%' OR Txn_Source LIKE '%{search_term}%' OR Txn_Type LIKE '%{search_term}%')"
#                     count_query += search_condition
                
#                 count_result = execute_query_safe(count_query)
#                 if count_result and len(count_result) > 0:
#                     total_count = int(float(count_result[0].get('total', len(data))))
                        
#             except Exception as e:
#                 logger.error(f"Error getting total count: {e}")
#                 total_count = len(data)
        
#         response_data = {
#             'data': data,
#             'count': len(data),
#             'page': page,
#             'limit': limit,
#             'filter': filter_type,
#             'timestamp': datetime.now().isoformat(),
#             'status': 'success',
#             'search_applied': search_term if search_term else None,
#         }
        
#         if total_count is not None:
#             response_data['total_count'] = total_count
#             response_data['total_pages'] = (total_count + limit - 1) // limit
#             response_data['has_more'] = (page + 1) * limit < total_count
        
#         return jsonify(response_data)
        
#     except ValueError as ve:
#         logger.error(f"Parameter error in get_reconciliation_data: {str(ve)}")
#         return jsonify({
#             'error': f'Invalid parameter: {str(ve)}',
#             'status': 'error',
#             'timestamp': datetime.now().isoformat()
#         }), 400
        
#     except Exception as e:
#         logger.error(f"Error in get_reconciliation_data: {str(e)}")
#         logger.error(f"Full traceback: {traceback.format_exc()}")
#         return jsonify({
#             'error': str(e),
#             'status': 'error',
#             'timestamp': datetime.now().isoformat()
#         }), 500

# @app.route('/api/refresh', methods=['POST'])
# def refresh_data():
#     """Refresh Recon_Summary data and get updated statistics"""
#     try:
#         conn = get_db_connection()
#         if not conn:
#             return jsonify({'error': 'Database connection failed'}), 500
        
#         cursor = conn.cursor()
        
#         # Get counts from all relevant tables
#         cursor.execute("SELECT COUNT(*) FROM reconciliation.recon_summary")
#         recon_summary_count = cursor.fetchone()[0]
        
#         cursor.execute("SELECT COUNT(*) FROM reconciliation.paytm_phonepe")
#         paytm_count = cursor.fetchone()[0]
        
#         cursor.execute("SELECT COUNT(*) FROM reconciliation.payment_refund")
#         payment_count = cursor.fetchone()[0]
        
#         # Get comprehensive statistics
#         cursor.execute(RECON_SUMMARY_QUERIES['STATISTICS'])
#         stats = cursor.fetchone()
        
#         # Get payment method breakdown
#         cursor.execute(RECON_SUMMARY_QUERIES['PAYMENT_METHOD_BREAKDOWN'])
#         payment_methods = cursor.fetchall()
        
#         cursor.close()
#         conn.close()
        
#         return jsonify({
#             'message': 'Recon_Summary data refreshed successfully',
#             'table_counts': {
#                 'recon_summary': recon_summary_count,
#                 'paytm_phonepe': paytm_count,
#                 'payment_refund': payment_count
#             },
#             'statistics': {
#                 'total_transactions': stats[0] if stats else 0,
#                 'total_cloud_amount': float(stats[1]) if stats and stats[1] else 0,
#                 'total_gateway_amount': float(stats[2]) if stats and stats[2] else 0,
#                 'perfect_matches': stats[3] if stats else 0,
#                 'needs_investigation': stats[4] if stats else 0,
#                 'total_difference_amount': float(stats[5]) if stats and stats[5] else 0,
#                 'earliest_transaction': stats[6].isoformat() if stats and stats[6] else None,
#                 'latest_transaction': stats[7].isoformat() if stats and stats[7] else None
#             } if stats else {},
#             'payment_methods': [
#                 {
#                     'method': row[0],
#                     'total_payments': float(row[1]) if row[1] else 0,
#                     'total_refunds': float(row[2]) if row[2] else 0,
#                     'payment_count': row[3] if row[3] else 0,
#                     'refund_count': row[4] if row[4] else 0
#                 }
#                 for row in payment_methods
#             ],
#             'status': 'success',
#             'timestamp': datetime.now().isoformat()
#         })
        
#     except Exception as e:
#         logger.error(f"Error refreshing data: {str(e)}")
#         return jsonify({'error': str(e)}), 500

# @app.route('/api/processing-status', methods=['GET'])
# def get_processing_status():
#     """Get current processing status"""
#     return jsonify({
#         'status': processing_status,
#         'timestamp': datetime.now().isoformat(),
#         'version': 'recon_summary_focused_v2'
#     })

# # Additional endpoints for specific data types

# @app.route('/api/reconciliation/summary-stats', methods=['GET'])
# def get_summary_stats():
#     """Get summary statistics specifically for dashboard"""
#     try:
#         stats_data = execute_query_safe(RECON_SUMMARY_QUERIES['STATISTICS'])
        
#         if not stats_data or len(stats_data) == 0:
#             return jsonify({
#                 'error': 'No statistics available',
#                 'status': 'error'
#             }), 404
        
#         stats = stats_data[0]
        
#         # Calculate additional metrics
#         total_transactions = int(stats.get('total_transactions', 0))
#         perfect_matches = int(stats.get('perfect_matches', 0))
#         needs_investigation = int(stats.get('needs_investigation', 0))
        
#         success_rate = (perfect_matches / total_transactions * 100) if total_transactions > 0 else 0
#         investigation_rate = (needs_investigation / total_transactions * 100) if total_transactions > 0 else 0
        
#         return jsonify({
#             'total_transactions': total_transactions,
#             'perfect_matches': perfect_matches,
#             'needs_investigation': needs_investigation,
#             'success_rate': round(success_rate, 2),
#             'investigation_rate': round(investigation_rate, 2),
#             'total_cloud_amount': float(stats.get('total_cloud_amount', 0)),
#             'total_gateway_amount': float(stats.get('total_gateway_amount', 0)),
#             'total_difference_amount': float(stats.get('total_difference_amount', 0)),
#             'earliest_transaction': stats.get('earliest_transaction', ''),
#             'latest_transaction': stats.get('latest_transaction', ''),
#             'timestamp': datetime.now().isoformat(),
#             'status': 'success'
#         })
        
#     except Exception as e:
#         logger.error(f"Error getting summary stats: {str(e)}")
#         return jsonify({
#             'error': str(e),
#             'status': 'error'
#         }), 500

# @app.route('/api/reconciliation/payment-methods', methods=['GET'])
# def get_payment_methods():
#     """Get payment method breakdown for charts"""
#     try:
#         payment_data = execute_query_safe(RECON_SUMMARY_QUERIES['PAYMENT_METHOD_BREAKDOWN'])
        
#         if not payment_data:
#             return jsonify({
#                 'error': 'No payment method data available',
#                 'status': 'error'
#             }), 404
        
#         # Format data for frontend consumption
#         formatted_data = []
#         for row in payment_data:
#             formatted_data.append({
#                 'payment_method': row.get('payment_method', ''),
#                 'total_payments': float(row.get('total_payments', 0)),
#                 'total_refunds': float(row.get('total_refunds', 0)),
#                 'net_amount': float(row.get('total_payments', 0)) - float(row.get('total_refunds', 0)),
#                 'payment_count': int(row.get('payment_count', 0)),
#                 'refund_count': int(row.get('refund_count', 0)),
#                 'total_transactions': int(row.get('payment_count', 0)) + int(row.get('refund_count', 0))
#             })
        
#         return jsonify({
#             'data': formatted_data,
#             'count': len(formatted_data),
#             'timestamp': datetime.now().isoformat(),
#             'status': 'success'
#         })
        
#     except Exception as e:
#         logger.error(f"Error getting payment methods: {str(e)}")
#         return jsonify({
#             'error': str(e),
#             'status': 'error'
#         }), 500

# @app.route('/api/reconciliation/transaction/<transaction_id>', methods=['GET'])
# def get_transaction_details(transaction_id):
#     """Get detailed information for a specific transaction"""
#     try:
#         # Sanitize transaction_id
#         transaction_id = transaction_id.replace("'", "''")
        
#         query = f"""
#         SELECT *,
#                (Cloud_Payment + Cloud_Refund) as Cloud_Total,
#                (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
#                 VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
#                 Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment) as Gateway_Total,
#                CASE 
#                    WHEN ((Cloud_Payment + Cloud_Refund) = 
#                          (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
#                           VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
#                           Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment))
#                    THEN 'Perfect'
#                    ELSE 'Investigate'
#                END as Reconciliation_Status,
#                ABS((Cloud_Payment + Cloud_Refund) - 
#                    (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
#                     VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
#                     Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment)) as Difference_Amount
#         FROM reconciliation.recon_summary
#         WHERE Txn_RefNo = '{transaction_id}'
#         """
        
#         data = execute_query_safe(query)
        
#         if not data or len(data) == 0:
#             return jsonify({
#                 'error': f'Transaction {transaction_id} not found',
#                 'status': 'error'
#             }), 404
        
#         return jsonify({
#             'data': data[0],
#             'transaction_id': transaction_id,
#             'timestamp': datetime.now().isoformat(),
#             'status': 'success'
#         })
        
#     except Exception as e:
#         logger.error(f"Error getting transaction details: {str(e)}")
#         return jsonify({
#             'error': str(e),
#             'status': 'error'
#         }), 500

# # Error handlers
# @app.errorhandler(404)
# def not_found(error):
#     return jsonify({
#         'error': 'Endpoint not found',
#         'status': 'error',
#         'timestamp': datetime.now().isoformat()
#     }), 404

# @app.errorhandler(500)
# def internal_error(error):
#     return jsonify({
#         'error': 'Internal server error',
#         'status': 'error',
#         'timestamp': datetime.now().isoformat()
#     }), 500

# if __name__ == '__main__':
#     print("=" * 80)
#     print(" 🎯 RECON_SUMMARY FOCUSED API SERVER")
#     print("=" * 80)
#     print(f" Startup Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
#     print(f" Database: {DB_CONFIG['database']} on {DB_CONFIG['host']}")
#     print(f" Upload Folder: {UPLOAD_FOLDER}")
#     print(f" Base Directory: {BASE_DIR}")
    
#     # Validate paths
#     print(f"\n 📁 PATH VALIDATION:")
#     print(f" ✅ BASE_DIR exists: {BASE_DIR.exists()}")
#     print(f" ✅ UPLOAD_FOLDER exists: {UPLOAD_FOLDER.exists()}")
#     print(f" {'✅' if (BASE_DIR / 'run_all_scripts.bat').exists() else '❌'} run_all_scripts.bat exists: {(BASE_DIR / 'run_all_scripts.bat').exists()}")
    
#     print("\n" + "="*60)
#     print(" 🗄️  DATABASE CONNECTION TEST")
#     print("="*60)
    
#     try:
#         conn = get_db_connection()
#         if conn and conn.is_connected():
#             print(" ✅ Database connection successful")
            
#             cursor = conn.cursor()
            
#             # Test recon_summary table specifically
#             try:
#                 cursor.execute("SELECT COUNT(*) FROM recon_summary")
#                 count = cursor.fetchone()[0]
#                 print(f" ✅ recon_summary table: {count:,} records")
                
#                 if count > 0:
#                     # Get date range
#                     cursor.execute("SELECT MIN(Txn_Date), MAX(Txn_Date) FROM recon_summary")
#                     date_range = cursor.fetchone()
#                     if date_range[0] and date_range[1]:
#                         print(f"    📅 Date range: {date_range[0]} to {date_range[1]}")
                    
#                     # Get reconciliation status summary
#                     cursor.execute("""
#                         SELECT 
#                             SUM(CASE WHEN ((Cloud_Payment + Cloud_Refund) = 
#                                           (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
#                                            VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
#                                            Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment))
#                                 THEN 1 ELSE 0 END) as perfect,
#                             SUM(CASE WHEN ((Cloud_Payment + Cloud_Refund) <> 
#                                           (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
#                                            VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
#                                            Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment))
#                                 THEN 1 ELSE 0 END) as investigate
#                         FROM recon_summary
#                     """)
#                     summary = cursor.fetchone()
#                     if summary:
#                         perfect, investigate = summary
#                         print(f"    ✅ Perfect matches: {perfect:,}")
#                         print(f"    🔍 Need investigation: {investigate:,}")
#                         if perfect + investigate > 0:
#                             success_rate = (perfect / (perfect + investigate)) * 100
#                             print(f"    📊 Success rate: {success_rate:.1f}%")
                
#             except Exception as e:
#                 print(f" ❌ recon_summary table: ERROR - {e}")
            
#             # Test other tables
#             tables = [
#                 ('payment_refund', 'Source data for cloud payments/refunds'),
#                 ('paytm_phonepe', 'Source data for gateway transactions')
#             ]
            
#             for table, description in tables:
#                 try:
#                     cursor.execute(f"SELECT COUNT(*) FROM {table}")
#                     count = cursor.fetchone()[0]
#                     print(f" ✅ {table}: {count:,} records ({description})")
#                 except Exception as e:
#                     print(f" ❌ {table}: ERROR - {e}")
            
#             cursor.close()
#             conn.close()
#         else:
#             print(" ❌ Database connection failed")
#             print("   Please check:")
#             print("     1. MySQL server is running")
#             print("     2. Database 'reconciliation' exists") 
#             print("     3. Credentials in DB_CONFIG are correct")
#     except Exception as e:
#         print(f" ❌ Database connection error: {e}")
#         print("   Please ensure MySQL is running and credentials are correct")
    
#     print("\n" + "="*60)
#     print(" 🔗 API ENDPOINTS")
#     print("="*60)
#     print("  📊 Main Data Endpoints:")
#     print("    GET  /api/health")
#     print("    GET  /api/reconciliation/data")
#     print("    GET  /api/reconciliation/summary-stats")
#     print("    GET  /api/reconciliation/payment-methods")
#     print("    GET  /api/reconciliation/transaction/<id>")
#     print("    POST /api/refresh")
#     print("")
#     print("  📁 File & Processing:")
#     print("    POST /api/upload")
#     print("    POST /api/start-processing")
#     print("    GET  /api/processing-status")
#     print("")
#     print("  🔍 Query Parameters for /api/reconciliation/data:")
#     print("    filter=all|success|investigate|statistics|payment_breakdown")
#     print("    search={search_term}")
#     print("    page={page_number}")
#     print("    limit={records_per_page}")
#     print("")
#     print("  📱 Sample Flutter API Calls:")
#     print("    • Dashboard stats: GET /api/reconciliation/summary-stats")
#     print("    • Perfect matches: GET /api/reconciliation/data?filter=success")
#     print("    • Issues to investigate: GET /api/reconciliation/data?filter=investigate")
#     print("    • Payment breakdown: GET /api/reconciliation/payment-methods")
#     print("    • Search transactions: GET /api/reconciliation/data?search=TXN123")
#     print("="*80)
#     print(" 🎯 FOCUSED ON RECON_SUMMARY DATA")
#     print(" 🔄 Ready to serve Flutter frontend")
#     print(" 📊 Comprehensive reconciliation analytics available")
#     print("="*80)
    
#     # Start the Flask application
#     app.run(debug=True, host='0.0.0.0', port=5000, threaded=True)


#3


from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
from decimal import Decimal
from datetime import datetime
import logging
import os
from pathlib import Path
import subprocess
import threading
import time
from werkzeug.utils import secure_filename
import traceback

# Flask app setup
app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter frontend

# Configuration
BASE_DIR = Path(__file__).parent.resolve()
UPLOAD_FOLDER = BASE_DIR / 'Input_Files'
ALLOWED_EXTENSIONS = {'zip', 'xlsx', 'xls', 'csv'}
MAX_FILE_SIZE = 50 * 1024 * 1024

# Logging configuration
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Templerun@2',
    'database': 'reconciliation'
}

# File upload configuration
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = MAX_FILE_SIZE

# Processing status tracker
processing_status = {
    'is_processing': False,
    'current_step': 0,
    'total_steps': 3,
    'step_name': '',
    'progress': 0,
    'message': '',
    'error': None,
    'completed': False,
    'start_time': None,
    'uploaded_files': []
}

# Ensure directories exist
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(BASE_DIR / 'Output_Files', exist_ok=True)

def get_db_connection():
    """Create and return a database connection"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except Error as err:
        logger.error(f"Database connection error: {err}")
        return None

def convert_to_json_serializable(data):
    """Convert database values to JSON-serializable format"""
    if data is None:
        return None
    elif isinstance(data, Decimal):
        return float(data)
    elif isinstance(data, datetime):
        return data.isoformat()
    else:
        return str(data)

def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def run_reconciliation_process():
    """Execute the complete reconciliation process"""
    global processing_status
    
    try:
        processing_status.update({
            'is_processing': True,
            'current_step': 1,
            'total_steps': 3,
            'progress': 10,
            'error': None,
            'completed': False,
            'start_time': datetime.now().isoformat(),
            'step_name': 'Complete Reconciliation Process',
            'message': 'Starting reconciliation workflow...'
        })
        
        working_dir = str(BASE_DIR)
        batch_filename = "run_all_scripts.bat"
        
        logger.info(f"Starting {batch_filename} in directory: {working_dir}")
        
        # Set environment variable to indicate Flask execution
        env = os.environ.copy()
        env['FLASK_EXECUTION'] = '1'
        
        # Update progress
        processing_status['progress'] = 20
        processing_status['message'] = 'Executing reconciliation process...'
        
        # Execute the batch file
        result = subprocess.run(
            batch_filename,
            shell=True,
            capture_output=True,
            text=True,
            cwd=working_dir,
            env=env,
            timeout=7200  # 2 hours timeout
        )
        
        processing_status['progress'] = 90
        
        # Check result
        if result.returncode != 0:
            error_msg = f"Reconciliation process failed with exit code {result.returncode}"
            
            if result.stderr:
                error_msg += f"\nError details: {result.stderr[-1000:]}"
            if result.stdout:
                error_msg += f"\nOutput: {result.stdout[-1000:]}"
            
            processing_status.update({
                'error': error_msg,
                'is_processing': False,
                'progress': 0,
                'message': f'Failed with exit code {result.returncode}'
            })
            
            logger.error(f"run_all_scripts.bat failed: {error_msg}")
            return
        
        # SUCCESS!
        processing_status.update({
            'message': 'All steps completed! Recon_Summary data updated successfully.',
            'progress': 100,
            'completed': True,
            'is_processing': False
        })
        
        logger.info("run_all_scripts.bat completed successfully!")
        logger.info("Recon_Summary table should now contain updated data")
        
    except subprocess.TimeoutExpired:
        error_msg = "Processing timed out after 2 hours"
        processing_status.update({
            'error': error_msg,
            'is_processing': False,
            'progress': 0,
            'message': 'Process timed out'
        })
        logger.error(error_msg)
        
    except Exception as e:
        error_msg = f"Unexpected error: {str(e)}"
        processing_status.update({
            'error': error_msg,
            'is_processing': False,
            'progress': 0,
            'message': 'Process failed'
        })
        logger.error(error_msg)
        logger.error(traceback.format_exc())

# =============================================================================
# API ENDPOINTS
# =============================================================================

@app.route('/recon-summary', methods=['GET'])
def get_recon_summary():
    """
    Fetch all data from Recon_summery table and return as JSON
    
    Returns:
        JSON array of all records from Recon_summery table
    """
    connection = None
    try:
        logger.info("Connecting to database...")
        
        # Connect to database
        connection = get_db_connection()
        if not connection:
            return jsonify({
                'error': 'Database connection failed',
                'status': 'error'
            }), 500
        
        # Create cursor
        cursor = connection.cursor(dictionary=True)
        
        # Execute query to fetch all data from Recon_summery table
        query = """
        SELECT 
            Txn_Source,
            Txn_Type,
            Txn_RefNo,
            Txn_Machine,
            Txn_MID,
            Txn_Date,
            Cloud_Payment,
            Cloud_Refund,
            Cloud_MRefund,
            Paytm_Payment,
            Paytm_Refund,
            Phonepe_Payment,
            Phonepe_Refund,
            VMSMoney_Payment,
            VMSMoney_Refund,
            Card_Payment,
            Card_Refund,
            Sodexo_Payment,
            Sodexo_Refund,
            HDFC_Payment,
            HDFC_Refund,
            CASH_Payment
        FROM Recon_Summary
        ORDER BY Txn_Date DESC, Txn_RefNo ASC
        """
        
        logger.info("Executing query to fetch Recon_summery data...")
        cursor.execute(query)
        
        # Fetch all results
        results = cursor.fetchall()
        logger.info(f"Successfully fetched {len(results)} records from Recon_summery table")
        
        # Convert to JSON-serializable format
        json_data = []
        for row in results:
            json_row = {}
            for key, value in row.items():
                json_row[key] = convert_to_json_serializable(value)
            json_data.append(json_row)
        
        # Close cursor
        cursor.close()
        
        # Return successful response
        return jsonify({
            'data': json_data,
            'count': len(json_data),
            'status': 'success',
            'message': f'Successfully retrieved {len(json_data)} records',
            'timestamp': datetime.now().isoformat()
        })
        
    except Error as db_error:
        logger.error(f"Database error: {db_error}")
        return jsonify({
            'error': f'Database error: {str(db_error)}',
            'status': 'error',
            'timestamp': datetime.now().isoformat()
        }), 500
        
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return jsonify({
            'error': f'Server error: {str(e)}',
            'status': 'error',
            'timestamp': datetime.now().isoformat()
        }), 500
        
    finally:
        # Always close connection
        if connection and connection.is_connected():
            connection.close()
            logger.info("Database connection closed")

@app.route('/upload', methods=['POST'])
def upload_file():
    """
    File upload endpoint for reconciliation input files
    
    Returns:
        JSON response with upload status and file information
    """
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No file part in the request'}), 400
        
        file = request.files['file']
        
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            
            # Create unique name if file already exists
            if os.path.exists(filepath):
                name, ext = os.path.splitext(filename)
                counter = 1
                while os.path.exists(filepath):
                    filename = f"{name}_{counter}{ext}"
                    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
                    counter += 1
            
            file.save(filepath)
            
            file_info = {
                'filename': filename,
                'original_filename': file.filename,
                'filepath': filepath,
                'size': os.path.getsize(filepath),
                'upload_time': datetime.now().isoformat(),
                'file_type': filename.split('.')[-1].lower()
            }
            
            processing_status['uploaded_files'].append(file_info)
            
            logger.info(f"File uploaded successfully: {filename} ({file_info['size']} bytes)")
            
            return jsonify({
                'success': True,
                'message': 'File uploaded successfully',
                'filename': filename,
                'original_filename': file.filename,
                'filepath': filepath,
                'size': file_info['size'],
                'file_type': file_info['file_type'],
                'timestamp': file_info['upload_time'],
                'total_uploaded_files': len(processing_status['uploaded_files'])
            })
        else:
            return jsonify({
                'success': False,
                'error': f'File type not allowed. Only {", ".join(ALLOWED_EXTENSIONS)} files are permitted'
            }), 400
            
    except Exception as e:
        logger.error(f"Error uploading file: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/start-processing', methods=['POST'])
def start_processing():
    """
    Start reconciliation processing
    
    Returns:
        JSON response with processing status
    """
    global processing_status
    
    try:
        if processing_status['is_processing']:
            return jsonify({
                'success': False,
                'error': 'Processing already in progress',
                'status': processing_status
            }), 400
        
        # Validate batch file exists
        batch_file = BASE_DIR / 'run_all_scripts.bat'
        if not batch_file.exists():
            error_msg = f"Batch file not found: {batch_file}"
            return jsonify({
                'success': False,
                'error': error_msg,
                'batch_file_path': str(batch_file)
            }), 400
        
        # Check upload folder
        if not UPLOAD_FOLDER.exists():
            error_msg = f"Upload folder not found: {UPLOAD_FOLDER}"
            return jsonify({'success': False, 'error': error_msg}), 400
        
        uploaded_files = [f for f in os.listdir(UPLOAD_FOLDER) 
                         if os.path.isfile(os.path.join(UPLOAD_FOLDER, f))]
        
        # Reset processing status
        processing_status = {
            'is_processing': True,
            'current_step': 0,
            'total_steps': 3,
            'step_name': 'Initializing',
            'progress': 0,
            'message': 'Starting reconciliation processing...',
            'error': None,
            'completed': False,
            'start_time': datetime.now().isoformat(),
            'uploaded_files': processing_status.get('uploaded_files', [])
        }
        
        # Start processing in background thread
        thread = threading.Thread(target=run_reconciliation_process)
        thread.daemon = True
        thread.start()
        
        return jsonify({
            'success': True,
            'message': 'Reconciliation processing started successfully',
            'status': processing_status,
            'uploaded_files': uploaded_files,
            'batch_file_verified': True,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        error_msg = f"Error starting processing: {str(e)}"
        logger.error(error_msg)
        return jsonify({'success': False, 'error': error_msg}), 500

@app.route('/processing-status', methods=['GET'])
def get_processing_status():
    """
    Get current processing status
    
    Returns:
        JSON response with current processing status
    """
    return jsonify({
        'status': processing_status,
        'timestamp': datetime.now().isoformat()
    })

@app.route('/refresh', methods=['POST'])
def refresh_data():
    """
    Refresh Recon_Summary data and get updated statistics
    
    Returns:
        JSON response with refreshed data statistics
    """
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({'error': 'Database connection failed'}), 500
        
        cursor = conn.cursor()
        
        # Get counts from all relevant tables
        cursor.execute("SELECT COUNT(*) FROM reconciliation.recon_summary")
        recon_summary_count = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM reconciliation.paytm_phonepe")
        paytm_count = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM reconciliation.payment_refund")
        payment_count = cursor.fetchone()[0]
        
        # Get basic statistics from recon_summary
        stats_query = """
        SELECT 
            COUNT(*) as total_transactions,
            SUM(Cloud_Payment + Cloud_Refund) as total_cloud_amount,
            SUM(Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
                VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
                Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment) as total_gateway_amount,
            SUM(CASE 
                WHEN ((Cloud_Payment + Cloud_Refund) = 
                      (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
                       VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
                       Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment))
                THEN 1 ELSE 0 END) as perfect_matches,
            SUM(CASE 
                WHEN ((Cloud_Payment + Cloud_Refund) <> 
                      (Paytm_Payment - Paytm_Refund + Phonepe_Payment - Phonepe_Refund + 
                       VMSMoney_Payment + VMSMoney_Refund + HDFC_Payment + HDFC_Refund + 
                       Card_Payment + Card_Refund + Sodexo_Payment + Sodexo_Refund + Cash_Payment))
                THEN 1 ELSE 0 END) as needs_investigation
        FROM reconciliation.recon_summary
        """
        
        cursor.execute(stats_query)
        stats = cursor.fetchone()
        
        cursor.close()
        conn.close()
        
        return jsonify({
            'message': 'Recon_Summary data refreshed successfully',
            'table_counts': {
                'recon_summary': recon_summary_count,
                'paytm_phonepe': paytm_count,
                'payment_refund': payment_count
            },
            'statistics': {
                'total_transactions': stats[0] if stats else 0,
                'total_cloud_amount': float(stats[1]) if stats and stats[1] else 0,
                'total_gateway_amount': float(stats[2]) if stats and stats[2] else 0,
                'perfect_matches': stats[3] if stats else 0,
                'needs_investigation': stats[4] if stats else 0,
                'success_rate': round((stats[3] / stats[0] * 100) if stats and stats[0] > 0 else 0, 2)
            } if stats else {},
            'status': 'success',
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Error refreshing data: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/uploaded-files', methods=['GET'])
def get_uploaded_files():
    """
    Get list of uploaded files
    
    Returns:
        JSON response with list of uploaded files
    """
    try:
        uploaded_files = []
        if UPLOAD_FOLDER.exists():
            for filename in os.listdir(UPLOAD_FOLDER):
                filepath = UPLOAD_FOLDER / filename
                if filepath.is_file():
                    file_info = {
                        'filename': filename,
                        'size': filepath.stat().st_size,
                        'upload_time': datetime.fromtimestamp(filepath.stat().st_mtime).isoformat(),
                        'file_type': filename.split('.')[-1].lower() if '.' in filename else 'unknown'
                    }
                    uploaded_files.append(file_info)
        
        return jsonify({
            'files': uploaded_files,
            'count': len(uploaded_files),
            'status': 'success',
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Error getting uploaded files: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/delete-file/<filename>', methods=['DELETE'])
def delete_file(filename):
    """
    Delete an uploaded file
    
    Returns:
        JSON response with deletion status
    """
    try:
        # Sanitize filename
        safe_filename = secure_filename(filename)
        filepath = UPLOAD_FOLDER / safe_filename
        
        if not filepath.exists():
            return jsonify({
                'success': False,
                'error': f'File {safe_filename} not found'
            }), 404
        
        # Delete the file
        filepath.unlink()
        
        # Remove from processing status if present
        processing_status['uploaded_files'] = [
            f for f in processing_status['uploaded_files'] 
            if f.get('filename') != safe_filename
        ]
        
        logger.info(f"File deleted successfully: {safe_filename}")
        
        return jsonify({
            'success': True,
            'message': f'File {safe_filename} deleted successfully',
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Error deleting file: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    """
    Health check endpoint to verify API and database connectivity
    
    Returns:
        JSON response with system status
    """
    try:
        # Test database connection
        connection = get_db_connection()
        if not connection:
            return jsonify({
                'status': 'unhealthy',
                'database': 'disconnected',
                'message': 'Cannot connect to database'
            }), 500
        
        # Test Recon_Summary table
        cursor = connection.cursor()
        cursor.execute("SELECT COUNT(*) FROM Recon_Summary")
        record_count = cursor.fetchone()[0]
        
        # Check if batch file exists
        batch_file_exists = (BASE_DIR / 'run_all_scripts.bat').exists()
        
        # Check upload folder
        upload_folder_exists = UPLOAD_FOLDER.exists()
        
        cursor.close()
        connection.close()
        
        return jsonify({
            'status': 'healthy',
            'database': 'connected',
            'recon_summary_records': record_count,
            'batch_file_exists': batch_file_exists,
            'upload_folder_exists': upload_folder_exists,
            'processing_status': processing_status['is_processing'],
            'message': 'API is working correctly',
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return jsonify({
            'status': 'unhealthy',
            'database': 'error',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

# Error handlers
@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({
        'error': 'Endpoint not found',
        'status': 'error',
        'available_endpoints': [
            '/recon-summary',
            '/upload', 
            '/start-processing',
            '/processing-status',
            '/refresh',
            '/uploaded-files',
            '/delete-file/<filename>',
            '/health'
        ],
        'timestamp': datetime.now().isoformat()
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    return jsonify({
        'error': 'Internal server error',
        'status': 'error',
        'timestamp': datetime.now().isoformat()
    }), 500

@app.errorhandler(413)
def file_too_large(error):
    """Handle file too large errors"""
    return jsonify({
        'error': f'File too large. Maximum size is {MAX_FILE_SIZE // (1024*1024)}MB',
        'status': 'error',
        'timestamp': datetime.now().isoformat()
    }), 413

if __name__ == '__main__':
    print("=" * 80)
    print(" 🎯 COMPREHENSIVE RECON_SUMMARY API")
    print("=" * 80)
    print(f" Start Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f" Database: {DB_CONFIG['database']} on {DB_CONFIG['host']}")
    print(f" Upload Folder: {UPLOAD_FOLDER}")
    print(f" Base Directory: {BASE_DIR}")
    print("")
    print(" 📡 Available Endpoints:")
    print("   GET  /recon-summary     - Fetch all Recon_summery data")
    print("   POST /upload            - Upload reconciliation files")
    print("   POST /start-processing  - Start reconciliation process")
    print("   GET  /processing-status - Get processing status")
    print("   POST /refresh           - Refresh data and get statistics")
    print("   GET  /uploaded-files    - Get list of uploaded files")
    print("   DELETE /delete-file/<filename> - Delete uploaded file")
    print("   GET  /health            - API health check")
    print("")
    print(" 🔍 Testing Database Connection...")
    
    try:
        # Test database connection on startup
        conn = get_db_connection()
        if conn and conn.is_connected():
            cursor = conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM Recon_Summary")
            count = cursor.fetchone()[0]
            cursor.close()
            conn.close()
            
            print(f" ✅ Database: Connected successfully")
            print(f" ✅ Recon_Summary table: {count:,} records found")
            
        else:
            print(" ❌ Database: Connection failed")
            print("    Please check MySQL server and credentials")
            
    except Exception as e:
        print(f" ❌ Database: Error - {e}")
        print("    Please verify database setup")
    
    # Check required files and folders
    print(f"\n 📁 File System Check:")
    print(f" ✅ Upload folder: {UPLOAD_FOLDER.exists()}")
    print(f" {'✅' if (BASE_DIR / 'run_all_scripts.bat').exists() else '❌'} Batch file: {(BASE_DIR / 'run_all_scripts.bat').exists()}")
    
    print("")
    print(" 📱 Flutter Integration:")
    print("   Base URL: http://localhost:5000")
    print("   Main Data: GET /recon-summary")
    print("   File Upload: POST /upload")
    print("   Start Process: POST /start-processing")
    print("   Check Status: GET /processing-status")
    print("   Refresh Data: POST /refresh")
    
    print("=" * 80)
    print(" 🚀 Starting Flask server...")
    print(" 🌐 Server will be available at: http://localhost:5000")
    print("=" * 80)
    
    # Start the Flask application
    app.run(debug=True, host='0.0.0.0', port=5000)
    print("=" * 60)
    print(" 🎯 SIMPLE RECON_SUMMARY API")
    print("=" * 60)
    print(f" Start Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f" Database: {DB_CONFIG['database']} on {DB_CONFIG['host']}")
    print("")
    print(" 📡 Available Endpoints:")
    print("   GET  /recon-summary   - Fetch all Recon_summery data")
    print("   GET  /health          - API health check")
    print("")
    print(" 🔍 Testing Database Connection...")
    
    try:
        # Test database connection on startup
        conn = get_db_connection()
        if conn and conn.is_connected():
            cursor = conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM Recon_Summary")
            count = cursor.fetchone()[0]
            cursor.close()
            conn.close()
            
            print(f" ✅ Database: Connected successfully")
            print(f" ✅ Recon_Summary table: {count:,} records found")
            print("")
            print(" 📱 Flutter Integration:")
            print("   Base URL: http://localhost:5000")
            print("   Endpoint: GET /recon-summary")
            print("   Response: JSON array of all records")
            
        else:
            print(" ❌ Database: Connection failed")
            print("    Please check MySQL server and credentials")
            
    except Exception as e:
        print(f" ❌ Database: Error - {e}")
        print("    Please verify database setup")
    
    print("=" * 60)
    print(" 🚀 Starting Flask server...")
    print(" 🌐 Server will be available at: http://localhost:5000")
    print("=" * 60)
    
    # Start the Flask application
    app.run(debug=True, host='0.0.0.0', port=5000)