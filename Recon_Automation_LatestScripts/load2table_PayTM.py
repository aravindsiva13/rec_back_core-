# import pandas as pd
# import mysql.connector
# from mysql.connector import Error
# import glob
# import os

# # Establish a MySQL connection
# def create_connection():
#     try:
#         connection = mysql.connector.connect(
#             host='localhost',
#             user='root',
#             password='Templerun@2',
#             database='reconciliation'
#         )
#         if connection.is_connected():
#             print("Connection to MySQL is successful!")
#             return connection
#     except Error as e:
#         print(f"Error: {e}")
#         return None

# # Insert data into MySQL table
# def insert_data_from_csv(csv_file_path, connection):
#     try:
#         print(f"Processing file: {csv_file_path}")
#         df = pd.read_csv(csv_file_path)

#         # Replace NaN and empty values with None for MySQL compatibility
#         df = df.where(pd.notnull(df), None)
#         df = df.replace(r'^\s*$', None, regex=True)

#         cursor = connection.cursor()

#         for _, row in df.iterrows():
#             sql = f"INSERT INTO paytm_phonepe ({', '.join(df.columns)}) VALUES ({', '.join(['%s'] * len(row))})"
#             cursor.execute(sql, tuple(row))

#         connection.commit()
#         print(f"{cursor.rowcount} rows inserted successfully from {os.path.basename(csv_file_path)}.")

#     except Error as e:
#         print(f"Error: {e}")
#         connection.rollback()

# # Main function to load CSV and insert into MySQL
# def main():
#     # Folder path and filename pattern
#     folder_path = r'C:\Users\IT\Downloads\Recon_Automation_LatestScripts\Output_Files'
#     pattern = '*_bill_txn_report.csv'
#     csv_files = glob.glob(os.path.join(folder_path, pattern))

#     # Create a MySQL connection
#     connection = create_connection()

#     if connection:
#         for csv_file in csv_files:
#             insert_data_from_csv(csv_file, connection)

#         connection.close()

# if __name__ == "__main__":
#     main()


#2

import pandas as pd
import mysql.connector
from mysql.connector import Error
import glob
import os

# Establish a MySQL connection
def create_connection():
    try:
        connection = mysql.connector.connect(
            host='localhost',
            user='root',
            password='Templerun@2',
            database='reconciliation'
        )
        if connection.is_connected():
            print("Connection to MySQL is successful!")
            return connection
    except Error as e:
        print(f"Error: {e}")
        return None

# Insert data into MySQL table
def insert_data_from_csv(csv_file_path, connection):
    try:
        print(f"Processing file: {csv_file_path}")
        
        # Read CSV with error handling for malformed lines
        try:
            df = pd.read_csv(csv_file_path, 
                           on_bad_lines='skip',  # Skip malformed lines
                           engine='python',      # Use Python engine for better error handling
                           encoding='utf-8')
        except UnicodeDecodeError:
            # Try different encoding if UTF-8 fails
            df = pd.read_csv(csv_file_path, 
                           on_bad_lines='skip',
                           engine='python',
                           encoding='latin-1')

        # Validate that we have the expected columns
        expected_columns = ['Txn_Source', 'Txn_Machine', 'Txn_MID', 'Txn_Type', 'Txn_Date', 'Txn_RefNo', 'Txn_Amount']
        
        if len(df.columns) != len(expected_columns):
            print(f"Warning: Expected {len(expected_columns)} columns, but found {len(df.columns)} columns")
            print(f"Columns found: {list(df.columns)}")
            
            # If we have more columns than expected, take only the first 7
            if len(df.columns) > len(expected_columns):
                df = df.iloc[:, :len(expected_columns)]
                df.columns = expected_columns
                print("Truncated to first 7 columns and renamed them")
            else:
                print("Skipping file due to column mismatch")
                return

        # Replace NaN and empty values with None for MySQL compatibility
        df = df.where(pd.notnull(df), None)
        df = df.replace(r'^\s*$', None, regex=True)

        # Remove any completely empty rows
        df = df.dropna(how='all')

        if df.empty:
            print("No valid data rows found in file")
            return

        cursor = connection.cursor()

        # Insert rows one by one with error handling
        successful_inserts = 0
        for index, row in df.iterrows():
            try:
                sql = f"INSERT INTO paytm_phonepe ({', '.join(df.columns)}) VALUES ({', '.join(['%s'] * len(row))})"
                cursor.execute(sql, tuple(row))
                successful_inserts += 1
            except Error as e:
                print(f"Error inserting row {index}: {e}")
                print(f"Row data: {tuple(row)}")
                continue

        connection.commit()
        print(f"{successful_inserts} rows inserted successfully from {os.path.basename(csv_file_path)}.")

    except Exception as e:
        print(f"Error processing file {csv_file_path}: {e}")
        connection.rollback()

# Main function to load CSV and insert into MySQL
def main():
    # Folder path and filename pattern
    folder_path = r'C:\Users\IT\Downloads\Recon_Automation_LatestScripts\Output_Files'
    pattern = '*_bill_txn_report.csv'
    csv_files = glob.glob(os.path.join(folder_path, pattern))

    if not csv_files:
        print(f"No files found matching pattern: {pattern}")
        return

    # Create a MySQL connection
    connection = create_connection()

    if connection:
        for csv_file in csv_files:
            insert_data_from_csv(csv_file, connection)

        connection.close()
        print("Database connection closed.")

if __name__ == "__main__":
    main()