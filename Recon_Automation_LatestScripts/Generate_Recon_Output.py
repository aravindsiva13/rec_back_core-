import mysql.connector
import pandas as pd

# MySQL connection details
#host='localhost',  # e.g., localhost or an IP address
#user='root',  # e.g., root
#password='Templerun@2',  # your MySQL password
#database='reconciliation'  # the database you're using

# Queries to extract data
queries = {
    'SUMMARY': '(SELECT txn_source, Txn_type, sum(Txn_Amount) FROM reconciliation.payment_refund pr GROUP BY 1, 2) UNION (SELECT Txn_Source, Txn_type, sum(Txn_Amount) FROM reconciliation.paytm_phonepe pp GROUP BY 1, 2);',
    'RAWDATA': '(SELECT * FROM reconciliation.paytm_phonepe pp) UNION ALL (SELECT * FROM reconciliation.payment_refund pr);', 
    'RECON_SUCCESS': 'SELECT *, IF((ro1.PTPP_Payment + ro1.PTPP_Refund) = (ro1.Cloud_Payment + ro1.Cloud_Refund + ro1.Cloud_MRefund),"Perfect", "Investigate") AS Remarks FROM reconciliation.recon_outcome ro1 WHERE ((ro1.PTPP_Payment + ro1.PTPP_Refund) = (ro1.Cloud_Payment + ro1.Cloud_Refund + ro1.Cloud_MRefund)) AND ro1.Txn_RefNo NOT IN (SELECT ro2.txn_refno FROM reconciliation.recon_outcome ro2 WHERE ro2.txn_mid like \'%manual%\') ORDER BY 1;',
    'RECON_INVESTIGATE': 'SELECT *, IF((ro1.PTPP_Payment + ro1.PTPP_Refund) = (ro1.Cloud_Payment + ro1.Cloud_Refund + ro1.Cloud_MRefund),"Perfect", "Investigate") AS Remarks FROM reconciliation.recon_outcome ro1 WHERE ((ro1.PTPP_Payment + ro1.PTPP_Refund) != (ro1.Cloud_Payment + ro1.Cloud_Refund + ro1.Cloud_MRefund)) AND ro1.Txn_RefNo NOT IN (SELECT ro2.txn_refno FROM reconciliation.recon_outcome ro2 WHERE ro2.txn_mid like \'%manual%\') ORDER BY 1;',
    'MANUAL_REFUND': 'SELECT *, IF((ro1.PTPP_Payment + ro1.PTPP_Refund) = (ro1.Cloud_Payment + ro1.Cloud_Refund + ro1.Cloud_MRefund),"Perfect", "Investigate") AS Remarks FROM reconciliation.recon_outcome ro1 WHERE ro1.Txn_MID = \'Initiate manual refund to customer\' ORDER BY 1;'
}


# AND ro1.Txn_RefNo IN (SELECT ro2.txn_refno FROM reconciliation.recon_outcome ro2 WHERE ro2.txn_mid like \'%manual%\') - removed from MANUAL_REFUND Query
# Connect to MySQL
conn = mysql.connector.connect(
host='localhost',  # e.g., localhost or an IP address
user='root',  # e.g., root
password='Templerun@2',  # your MySQL password
database='reconciliation'  # the database you're using
)

# Create a Pandas ExcelWriter to write multiple sheets
output_file = 'recon_output.xlsx'
with pd.ExcelWriter(output_file, engine='openpyxl') as writer:
    for sheet_name, query in queries.items():
        # Execute the query
        df = pd.read_sql(query, conn)
        
        # Write the dataframe to an Excel sheet
        df.to_excel(writer, sheet_name=sheet_name, index=False)

# Close the MySQL connection
conn.close()

print(f"Data has been successfully written to {output_file}.")	