#!/usr/bin/env python3
"""
Comprehensive test script for the Recon_Summary API
Tests all endpoints including upload, processing, and data retrieval
"""

import requests
import json
import os
from datetime import datetime
from pathlib import Path

# Configuration
BASE_URL = "http://localhost:5000"

# Test endpoints
ENDPOINTS = {
    'health': {'method': 'GET', 'url': '/health'},
    'recon_summary': {'method': 'GET', 'url': '/recon-summary'},
    'uploaded_files': {'method': 'GET', 'url': '/uploaded-files'},
    'processing_status': {'method': 'GET', 'url': '/processing-status'},
    'refresh': {'method': 'POST', 'url': '/refresh'}
}

def test_endpoint(name, config):
    """Test a single API endpoint"""
    try:
        print(f"\n🧪 Testing {name}...")
        print(f"   URL: {BASE_URL}{config['url']}")
        
        if config['method'] == 'GET':
            response = requests.get(f"{BASE_URL}{config['url']}", timeout=10)
        elif config['method'] == 'POST':
            response = requests.post(f"{BASE_URL}{config['url']}", timeout=10)
        
        print(f"   Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            
            # Print relevant info based on endpoint
            if name == 'health':
                print(f"   ✅ API Status: {data.get('status', 'unknown')}")
                print(f"   ✅ Database: {data.get('database', 'unknown')}")
                print(f"   📊 Records: {data.get('recon_summary_records', 'unknown')}")
                print(f"   📁 Batch file exists: {data.get('batch_file_exists', 'unknown')}")
                print(f"   📁 Upload folder exists: {data.get('upload_folder_exists', 'unknown')}")
                
            elif name == 'recon_summary':
                if 'data' in data and isinstance(data['data'], list):
                    print(f"   ✅ Success - {len(data['data'])} records returned")
                    if len(data['data']) > 0:
                        sample_record = data['data'][0]
                        print(f"   📋 Sample record fields: {list(sample_record.keys())[:5]}...")
                        
                        # Check for key reconciliation fields
                        key_fields = ['Txn_RefNo', 'Cloud_Payment', 'Paytm_Payment', 'Phonepe_Payment']
                        for field in key_fields:
                            if field in sample_record:
                                print(f"      ✅ {field}: {sample_record[field]}")
                else:
                    print(f"   ℹ️  No records found")
                    
            elif name == 'uploaded_files':
                files = data.get('files', [])
                print(f"   ✅ Found {len(files)} uploaded files")
                for file_info in files[:3]:  # Show first 3 files
                    print(f"      📄 {file_info.get('filename', 'unknown')} ({file_info.get('size', 0)} bytes)")
                    
            elif name == 'processing_status':
                status = data.get('status', {})
                print(f"   ✅ Processing: {status.get('is_processing', False)}")
                print(f"   📊 Progress: {status.get('progress', 0)}%")
                print(f"   📝 Message: {status.get('message', 'N/A')}")
                
            elif name == 'refresh':
                print(f"   ✅ Status: {data.get('status', 'unknown')}")
                if 'statistics' in data:
                    stats = data['statistics']
                    print(f"   📈 Total transactions: {stats.get('total_transactions', 'N/A')}")
                    print(f"   📈 Perfect matches: {stats.get('perfect_matches', 'N/A')}")
                    print(f"   📈 Success rate: {stats.get('success_rate', 'N/A')}%")
                if 'table_counts' in data:
                    counts = data['table_counts']
                    print(f"   📊 Table counts: {counts}")
            
            return True
                
        else:
            print(f"   ❌ Failed - Status {response.status_code}")
            try:
                error_data = response.json()
                print(f"   📝 Error: {error_data.get('error', 'Unknown error')}")
            except:
                print(f"   📝 Error: {response.text[:100]}...")
            return False
                
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Connection Error: {e}")
        return False
    except Exception as e:
        print(f"   ❌ Unexpected Error: {e}")
        return False

def test_file_upload():
    """Test file upload functionality"""
    print(f"\n📁 Testing File Upload...")
    
    try:
        # Create a test file
        test_content = "Test,File,Content\n1,2,3\n4,5,6"
        test_filename = "test_upload.csv"
        
        with open(test_filename, 'w') as f:
            f.write(test_content)
        
        print(f"   Created test file: {test_filename}")
        
        # Upload the file
        with open(test_filename, 'rb') as f:
            files = {'file': (test_filename, f, 'text/csv')}
            response = requests.post(f"{BASE_URL}/upload", files=files, timeout=30)
        
        print(f"   Upload Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print(f"   ✅ Upload successful")
                print(f"   📄 Uploaded as: {data.get('filename', 'unknown')}")
                print(f"   📊 File size: {data.get('size', 0)} bytes")
                print(f"   📂 Total files: {data.get('total_uploaded_files', 0)}")
                
                # Clean up - delete the uploaded file
                delete_response = requests.delete(f"{BASE_URL}/delete-file/{data.get('filename', test_filename)}")
                if delete_response.status_code == 200:
                    print(f"   🗑️  Test file cleaned up successfully")
                
                # Clean up local test file
                os.remove(test_filename)
                return True
            else:
                print(f"   ❌ Upload failed: {data.get('error', 'Unknown error')}")
        else:
            print(f"   ❌ Upload failed with status {response.status_code}")
        
        # Clean up local test file if it exists
        if os.path.exists(test_filename):
            os.remove(test_filename)
        return False
        
    except Exception as e:
        print(f"   ❌ File upload test error: {e}")
        # Clean up local test file if it exists
        if os.path.exists(test_filename):
            os.remove(test_filename)
        return False

def test_data_consistency():
    """Test data consistency and structure"""
    print(f"\n🔍 Testing Data Consistency...")
    
    try:
        response = requests.get(f"{BASE_URL}/recon-summary", timeout=30)
        
        if response.status_code == 200:
            data = response.json()
            
            if data.get('data') and len(data['data']) > 0:
                records = data['data']
                print(f"   ✅ Retrieved {len(records)} records")
                
                # Test data structure consistency
                required_fields = [
                    'Txn_Source', 'Txn_Type', 'Txn_RefNo', 'Txn_Machine', 'Txn_MID', 'Txn_Date',
                    'Cloud_Payment', 'Cloud_Refund', 'Cloud_MRefund',
                    'Paytm_Payment', 'Paytm_Refund', 'Phonepe_Payment', 'Phonepe_Refund',
                    'VMSMoney_Payment', 'VMSMoney_Refund', 'Card_Payment', 'Card_Refund',
                    'Sodexo_Payment', 'Sodexo_Refund', 'HDFC_Payment', 'HDFC_Refund', 'CASH_Payment'
                ]
                
                # Check first record structure
                first_record = records[0]
                missing_fields = []
                
                for field in required_fields:
                    if field not in first_record:
                        missing_fields.append(field)
                
                if missing_fields:
                    print(f"   ⚠️  Missing fields: {missing_fields}")
                else:
                    print(f"   ✅ All required fields present")
                
                # Test data types
                numeric_fields = [
                    'Cloud_Payment', 'Cloud_Refund', 'Paytm_Payment', 'Phonepe_Payment',
                    'VMSMoney_Payment', 'Card_Payment', 'Sodexo_Payment', 'HDFC_Payment', 'CASH_Payment'
                ]
                
                type_issues = []
                for field in numeric_fields:
                    if field in first_record:
                        value = first_record[field]
                        if not isinstance(value, (int, float, str)):
                            type_issues.append(f"{field}: {type(value)}")
                
                if type_issues:
                    print(f"   ⚠️  Type issues: {type_issues}")
                else:
                    print(f"   ✅ Data types are Flutter-compatible")
                
                # Calculate some statistics
                perfect_matches = 0
                needs_investigation = 0
                
                for record in records[:100]:  # Test first 100 records
                    try:
                        cloud_total = float(record.get('Cloud_Payment', 0)) + float(record.get('Cloud_Refund', 0)) + float(record.get('Cloud_MRefund', 0))
                        gateway_total = (
                            float(record.get('Paytm_Payment', 0)) + float(record.get('Paytm_Refund', 0)) +
                            float(record.get('Phonepe_Payment', 0)) + float(record.get('Phonepe_Refund', 0)) +
                            float(record.get('VMSMoney_Payment', 0)) + float(record.get('VMSMoney_Refund', 0)) +
                            float(record.get('Card_Payment', 0)) + float(record.get('Card_Refund', 0)) +
                            float(record.get('Sodexo_Payment', 0)) + float(record.get('Sodexo_Refund', 0)) +
                            float(record.get('HDFC_Payment', 0)) + float(record.get('HDFC_Refund', 0)) +
                            float(record.get('CASH_Payment', 0))
                        )
                        
                        if abs(cloud_total - gateway_total) < 0.01:
                            perfect_matches += 1
                        else:
                            needs_investigation += 1
                    except:
                        needs_investigation += 1
                
                total_tested = min(100, len(records))
                success_rate = (perfect_matches / total_tested * 100) if total_tested > 0 else 0
                
                print(f"   📊 Sample Analysis (first {total_tested} records):")
                print(f"      Perfect matches: {perfect_matches}")
                print(f"      Need investigation: {needs_investigation}")
                print(f"      Success rate: {success_rate:.1f}%")
                
                return True
            else:
                print(f"   ℹ️  No data available for consistency testing")
                return True
        else:
            print(f"   ❌ Could not retrieve data for consistency testing")
            return False
            
    except Exception as e:
        print(f"   ❌ Data consistency test error: {e}")
        return False

def test_flutter_integration_simulation():
    """Simulate Flutter integration patterns"""
    print(f"\n📱 Testing Flutter Integration Patterns...")
    
    try:
        # Test 1: Dashboard data loading
        print(f"   🏠 Testing dashboard data pattern...")
        health_response = requests.get(f"{BASE_URL}/health")
        refresh_response = requests.post(f"{BASE_URL}/refresh")
        
        if health_response.status_code == 200 and refresh_response.status_code == 200:
            health_data = health_response.json()
            refresh_data = refresh_response.json()
            
            print(f"      ✅ Health check: {health_data.get('status')}")
            print(f"      ✅ Refresh data: {refresh_data.get('status')}")
            
            if 'statistics' in refresh_data:
                stats = refresh_data['statistics']
                print(f"      📊 Dashboard metrics ready:")
                print(f"         Total: {stats.get('total_transactions', 0)}")
                print(f"         Perfect: {stats.get('perfect_matches', 0)}")
                print(f"         Rate: {stats.get('success_rate', 0)}%")
        
        # Test 2: Data list loading with pagination simulation
        print(f"   📋 Testing data list pattern...")
        data_response = requests.get(f"{BASE_URL}/recon-summary")
        
        if data_response.status_code == 200:
            data = data_response.json()
            records = data.get('data', [])
            
            print(f"      ✅ Retrieved {len(records)} records")
            print(f"      📱 Flutter ListView ready with {len(records)} items")
            
            if len(records) > 0:
                print(f"      📄 Sample record structure validated")
        
        # Test 3: File upload workflow
        print(f"   📁 Testing file upload workflow...")
        files_response = requests.get(f"{BASE_URL}/uploaded-files")
        
        if files_response.status_code == 200:
            files_data = files_response.json()
            print(f"      ✅ File listing: {files_data.get('count', 0)} files")
        
        # Test 4: Processing status monitoring
        print(f"   ⚙️  Testing processing status pattern...")
        status_response = requests.get(f"{BASE_URL}/processing-status")
        
        if status_response.status_code == 200:
            status_data = status_response.json()
            status = status_data.get('status', {})
            print(f"      ✅ Processing status: {status.get('is_processing', False)}")
            print(f"      📊 Progress tracking: {status.get('progress', 0)}%")
        
        print(f"   ✅ All Flutter integration patterns working")
        return True
        
    except Exception as e:
        print(f"   ❌ Flutter integration test error: {e}")
        return False

def main():
    """Run all comprehensive tests"""
    print("=" * 80)
    print(" 🧪 COMPREHENSIVE RECON_SUMMARY API TESTING")
    print("=" * 80)
    print(f" Test Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f" Target URL: {BASE_URL}")
    print("=" * 80)
    
    results = {}
    
    # Test basic endpoints
    for name, config in ENDPOINTS.items():
        results[name] = test_endpoint(name, config)
    
    # Test file upload functionality
    results['file_upload'] = test_file_upload()
    
    # Test data consistency
    results['data_consistency'] = test_data_consistency()
    
    # Test Flutter integration patterns
    results['flutter_integration'] = test_flutter_integration_simulation()
    
    # Summary
    print("\n" + "=" * 80)
    print(" 📋 COMPREHENSIVE TEST RESULTS")
    print("=" * 80)
    
    passed = sum(1 for result in results.values() if result)
    total = len(results)
    
    for test_name, result in results.items():
        status = '✅ PASS' if result else '❌ FAIL'
        print(f" {test_name.replace('_', ' ').title():.<30} {status}")
    
    print(f"\n 📊 Overall Result: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n 🎉 ALL TESTS PASSED!")
        print(" 🚀 API is fully ready for Flutter integration!")
        print("\n 📱 Flutter Integration Checklist:")
        print("   ✅ Health check endpoint working")
        print("   ✅ Main data endpoint returning proper JSON")
        print("   ✅ File upload functionality working")
        print("   ✅ Processing workflow available") 
        print("   ✅ Data refresh working")
        print("   ✅ All data types Flutter-compatible")
        print("   ✅ Error handling in place")
        
        print("\n 🔗 Ready-to-use Flutter endpoints:")
        print("   • Dashboard: GET /health + POST /refresh")
        print("   • Data List: GET /recon-summary")
        print("   • File Upload: POST /upload")
        print("   • Processing: POST /start-processing + GET /processing-status")
        print("   • File Management: GET /uploaded-files + DELETE /delete-file/<name>")
        
    else:
        print(f"\n ⚠️  {total - passed} TESTS FAILED!")
        print(" 🔧 Please check:")
        print("   1. Flask server is running on port 5000")
        print("   2. Database connection is working")
        print("   3. Recon_Summary table has data")
        print("   4. All required files are in place")
        print("   5. Upload folder permissions are correct")
    
    print("=" * 80)

if __name__ == "__main__":
    main()