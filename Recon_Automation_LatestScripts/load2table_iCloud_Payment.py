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
        df = pd.read_csv(csv_file_path)

        # Replace NaN and empty values with None for MySQL compatibility
        df = df.where(pd.notnull(df), None)
        df = df.replace(r'^\s*$', None, regex=True)

        cursor = connection.cursor()

        for _, row in df.iterrows():
            sql = f"INSERT INTO payment_refund ({', '.join(df.columns)}) VALUES ({', '.join(['%s'] * len(row))})"
            cursor.execute(sql, tuple(row))

        connection.commit()
        print(f"{cursor.rowcount} rows inserted successfully from {os.path.basename(csv_file_path)}.")

    except Error as e:
        print(f"Error: {e}")
        connection.rollback()

# Main function to load CSV and insert into MySQL
def main():
    # Folder path and filename pattern
    folder_path = r'C:\Users\IT\Downloads\Recon_Automation_LatestScripts\Output_Files'
    pattern = 'pmt*report*.csv'
    csv_files = glob.glob(os.path.join(folder_path, pattern))

    # Create a MySQL connection
    connection = create_connection()

    if connection:
        for csv_file in csv_files:
            insert_data_from_csv(csv_file, connection)

        connection.close()

if __name__ == "__main__":
    main()
