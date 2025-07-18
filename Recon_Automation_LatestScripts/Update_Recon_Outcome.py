import mysql.connector
from mysql.connector import Error

# Function to execute the SQL commands
def execute_sql_commands():
    try:
        # Connect to the MySQL database
        connection = mysql.connector.connect(
            host='localhost',  # Replace with your host
            database='reconciliation',  # Replace with your database name
            user='root',  # Replace with your username
            password='Templerun@2'  # Replace with your password
        )

        if connection.is_connected():
            cursor = connection.cursor()
            
            # Start by clearing the Recon_Outcome table
            delete_query = "DELETE FROM Recon_Outcome;"
            cursor.execute(delete_query)
            print("Deleted records from Recon_Outcome.")

            # Insert new records into Recon_Outcome
            insert_query = """
            INSERT INTO Recon_Outcome 
            (
            (SELECT DISTINCT Txn_RefNo, Txn_Machine, Txn_MID, 0, 0, 0, 0, 0 
            FROM Payment_Refund pr 
            WHERE (left(pr.Txn_Source,6) = 'iCLOUD') 
            AND ((left(pr.Txn_Type,3) = 'UPI') OR (pr.Txn_Type = ' (manual)')))
            UNION 
            (SELECT DISTINCT Txn_RefNo, Txn_Machine, Txn_MID, 0, 0, 0, 0, 0 
            FROM paytm_phonepe pp)
            );
            """
            cursor.execute(insert_query)
            print("Inserted new records into Recon_Outcome.")

            # Update the Recon_Outcome table
            update_queries = [
                """UPDATE Recon_Outcome RO 
                   SET PTPP_Payment = (SELECT COALESCE(SUM(pp.Txn_Amount), 0) 
                   FROM reconciliation.paytm_phonepe pp 
                   WHERE pp.Txn_Type = 'PAYMENT' AND pp.Txn_RefNo = ro.Txn_RefNo);""",
                """UPDATE Recon_Outcome RO 
                   SET PTPP_Refund = (SELECT COALESCE(SUM(pp.Txn_Amount), 0) 
                   FROM reconciliation.paytm_phonepe pp 
                   WHERE pp.Txn_Type = 'REFUND' AND pp.Txn_RefNo = ro.Txn_RefNo);""",
                """UPDATE Recon_Outcome RO 
                   SET Cloud_Payment = (SELECT COALESCE(SUM(pr.Txn_Amount), 0) 
                   FROM reconciliation.payment_refund pr 
                   WHERE pr.Txn_RefNo = ro.Txn_RefNo 
                   AND pr.Txn_Source = 'iCLOUD-PAYMENT' 
                   AND (pr.Txn_Type = 'UPI / Wallet (Paytm)' 
                   OR pr.Txn_Type = 'UPI / Wallet / Card (PhonePe)'));""",
                """UPDATE Recon_Outcome RO 
                   SET Cloud_Refund = (SELECT COALESCE(SUM(pr.Txn_Amount), 0) 
                   FROM reconciliation.payment_refund pr 
                   WHERE pr.Txn_Source = 'iCLOUD-REFUND' 
                   AND pr.Txn_Type != ' (manual)' 
                   AND pr.Txn_RefNo = ro.Txn_RefNo);""",
                """UPDATE Recon_Outcome RO 
                   SET Cloud_MRefund = (SELECT COALESCE(SUM(pr.Txn_Amount), 0) 
                   FROM reconciliation.payment_refund pr 
                   WHERE pr.Txn_RefNo = ro.Txn_RefNo 
                   AND pr.Txn_Source = 'iCLOUD-REFUND' 
                   AND pr.Txn_Type = ' (manual)');"""
            ]

            # Execute the update queries
            for query in update_queries:
                cursor.execute(query)
                print(f"Executed update query: {query[:50]}...")  # Print the first 50 characters of each query for confirmation

            # Commit the changes to the database
            connection.commit()
            print("All SQL commands executed successfully.")

    except Error as e:
        print(f"Error: {e}")
    finally:
        # Close the database connection
        if connection.is_connected():
            cursor.close()
            connection.close()
            print("MySQL connection is closed.")

# Call the function to execute the SQL commands
execute_sql_commands()
