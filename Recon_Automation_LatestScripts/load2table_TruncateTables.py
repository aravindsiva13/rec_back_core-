import pandas as pd
import mysql.connector
from mysql.connector import Error

# Establish a MySQL connection
def create_connection():
    try:
        connection = mysql.connector.connect(
            host='localhost',  # e.g., localhost or an IP address
            user='root',  # e.g., root
            password='Templerun@2',  # your MySQL password
            database='reconciliation'  # the database you're using
        )
        if connection.is_connected():
            print("Connection to MySQL is successful!")
            return connection
    except Error as e:
        print(f"Error: {e}")
        return None

# Main function to load CSV and insert into MySQL
def main():
    # Create a MySQL connection
    connection = create_connection()
    
    if connection:
        delcursor = connection.cursor()
        # Delete Existing Data

        delcursor.execute("DELETE FROM payment_refund")
        connection.commit()
        print("payment_refund table truncated successfully")

        delcursor.execute("DELETE FROM paytm_phonepe")
        connection.commit()
        print("paytm_phonepe table truncated successfully")
  
        delcursor.execute("DELETE FROM Recon_Outcome")
        connection.commit()
        print("Recon_Outcome table truncated successfully")

        delcursor.execute("DELETE FROM Recon_Summary")
        connection.commit()
        print("Recon_Summary table truncated successfully")

        connection.close()  # Close the connection when done


if __name__ == "__main__":
    main()
