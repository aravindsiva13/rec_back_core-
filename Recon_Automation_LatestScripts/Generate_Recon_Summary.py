import mysql.connector
import pandas as pd

# MySQL connection details
#host='localhost',  # e.g., localhost or an IP address
#user='root',  # e.g., root
#password='Templerun@2',  # your MySQL password
#database='reconciliation'  # the database you're using

# Queries to extract data
queries = {
    'RECON_SUCCESS':'SELECT * FROM reconciliation.recon_summary where ((Cloud_Payment+Cloud_Refund) = (Paytm_Payment-Paytm_Refund+Phonepe_Payment-Phonepe_Refund+VMSMoney_Payment+VMSMoney_Refund+HDFC_Payment+HDFC_Refund+Card_Payment+Card_Refund+Sodexo_Payment+Sodexo_Refund+Cash_Payment)) ;',
    'RECON_INVESTIGATE': 'SELECT * FROM reconciliation.recon_summary where ((Cloud_Payment+Cloud_Refund) <> (Paytm_Payment-Paytm_Refund+Phonepe_Payment-Phonepe_Refund+VMSMoney_Payment+VMSMoney_Refund+HDFC_Payment+HDFC_Refund+Card_Payment+Card_Refund+Sodexo_Payment+Sodexo_Refund+Cash_Payment)) ;'
}

# Connect to MySQL
conn = mysql.connector.connect(
host='localhost',  # e.g., localhost or an IP address
user='root',  # e.g., root
password='Templerun@2',  # your MySQL password
database='reconciliation'  # the database you're using
)

# Create a Pandas ExcelWriter to write multiple sheets
output_file = 'recon_summary.xlsx'
with pd.ExcelWriter(output_file, engine='openpyxl') as writer:
    for sheet_name, query in queries.items():
        # Execute the query
        df = pd.read_sql(query, conn)
        
        # Write the dataframe to an Excel sheet
        df.to_excel(writer, sheet_name=sheet_name, index=False)

# Close the MySQL connection
conn.close()

print(f"Data has been successfully written to {output_file}.")	