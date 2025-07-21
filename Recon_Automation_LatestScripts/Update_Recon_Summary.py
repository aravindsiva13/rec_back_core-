import mysql.connector
from mysql.connector import Error

# Function to execute the SQL commands
def execute_sql_commands():
    try:
        # Connect to the MySQL database
        connection = mysql.connector.connect(
            host='localhost',
            database='reconciliation',
            user='root',
            password='Templerun@2'
        )

        if connection.is_connected():
            cursor = connection.cursor()

            # Start by clearing the Recon_Summary table
            delete_query = "DELETE FROM Recon_Summary;"
            cursor.execute(delete_query)
            print("Deleted records from Recon_Summary.")

            # Insert new records for 'iCLOUD-PAYMENT'
            insert_payment_query = """INSERT INTO Recon_Summary 
            (
                Txn_Source, Txn_Type, Txn_RefNo, Txn_Machine, Txn_MID, Txn_Date, Cloud_Payment, Cloud_Refund, Cloud_MRefund, Paytm_Payment, Paytm_Refund, Phonepe_Payment, Phonepe_Refund, VMSMoney_Payment, VMSMoney_Refund, Card_Payment, Card_Refund, Sodexo_Payment, Sodexo_Refund, HDFC_Payment, HDFC_Refund, CASH_Payment
            )
            SELECT Txn_Source, Txn_Type, Txn_RefNo, Txn_Machine, Txn_MID, Txn_Date, SUM(Txn_Amount), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
              FROM Payment_Refund
             WHERE Txn_Source = 'iCLOUD-PAYMENT'
             GROUP BY Txn_Source, Txn_Type, Txn_RefNo, Txn_Machine, Txn_MID, Txn_Date;"""
            cursor.execute(insert_payment_query)
            print("Inserted 'iCLOUD-PAYMENT' records into Recon_Summary")

            # Update records for 'iCLOUD-REFUND-AUTO'
            update_refund_query = """
            UPDATE Recon_Summary
              JOIN Payment_Refund ON Recon_Summary.Txn_RefNo = Payment_Refund.Txn_RefNo
               SET Recon_Summary.Cloud_Refund = Payment_Refund.Txn_Amount
             WHERE Payment_Refund.Txn_Source = 'iCLOUD-REFUND'
               AND Payment_Refund.Txn_Type <> ' (manual)';"""
            cursor.execute(update_refund_query)
            print("Updated 'iCLOUD-REFUND-AUTO' records into Recon_Summary")

            # Update records for 'iCLOUD-REFUND-MANUAL' - Commenting it out as it is not the actual entries and just comments received from Machine App
            # update_mrefund_query = """
            # UPDATE Recon_Summary
            #   JOIN Payment_Refund ON Recon_Summary.Txn_RefNo = Payment_Refund.Txn_RefNo
            #    SET Recon_Summary.Cloud_MRefund = Payment_Refund.Txn_Amount
            #  WHERE Payment_Refund.Txn_Source = 'iCLOUD-REFUND'
            #    AND Payment_Refund.Txn_Type = ' (manual)';"""
            # cursor.execute(update_mrefund_query)
            # print("Updated 'iCLOUD-REFUND-MANUAL' records into Recon_Summary")

            # Update records for 'iCLOUD-PAYMENT-VMS-MONEY'
            update_vmspayment_query = """
            UPDATE Recon_Summary
              JOIN Payment_Refund ON Recon_Summary.Txn_RefNo = Payment_Refund.Txn_RefNo
               SET Recon_Summary.VMSMoney_Payment = Payment_Refund.Txn_Amount
             WHERE Payment_Refund.Txn_Source = 'iCLOUD-PAYMENT'
               AND Payment_Refund.Txn_Type = 'Credits (VMS Money)';"""
            cursor.execute(update_vmspayment_query)
            print("Updated 'iCLOUD-PAYMENT-VMS-MONEY' records into Recon_Summary")

            # Update records for 'iCLOUD-REFUND-VMS-MONEY'
            update_vmsrefund_query = """
            UPDATE Recon_Summary
              JOIN Payment_Refund ON Recon_Summary.Txn_RefNo = Payment_Refund.Txn_RefNo
               SET Recon_Summary.VMSMoney_Refund = Payment_Refund.Txn_Amount
             WHERE Payment_Refund.Txn_Source = 'iCLOUD-REFUND'
               AND Payment_Refund.Txn_Type = 'Credits (VMS Money) (auto)';"""
            cursor.execute(update_vmsrefund_query)
            print("Updated 'iCLOUD-REFUND-VMS-MONEY' records into Recon_Summary")

            # Update records for 'iCLOUD-PAYMENT-HDFC'
            update_hdfcpayment_query = """
            UPDATE Recon_Summary
              JOIN Payment_Refund ON Recon_Summary.Txn_RefNo = Payment_Refund.Txn_RefNo
               SET Recon_Summary.HDFC_Payment = Payment_Refund.Txn_Amount
             WHERE Payment_Refund.Txn_Source = 'iCLOUD-PAYMENT'
               AND Payment_Refund.Txn_Type = 'UPI (HDFC Bank)';"""
            cursor.execute(update_hdfcpayment_query)
            print("Updated 'iCLOUD-PAYMENT-HDFC' records into Recon_Summary")

            # Update records for 'iCLOUD-REFUND-HDFC'
            update_hdfcrefund_query = """
            UPDATE Recon_Summary
              JOIN Payment_Refund ON Recon_Summary.Txn_RefNo = Payment_Refund.Txn_RefNo
               SET Recon_Summary.HDFC_Refund = Payment_Refund.Txn_Amount
             WHERE Payment_Refund.Txn_Source = 'iCLOUD-REFUND'
               AND Payment_Refund.Txn_Type = 'UPI (HDFC Bank) (auto)';"""
            cursor.execute(update_hdfcrefund_query)
            print("Updated 'iCLOUD-REFUND-HDFC' records into Recon_Summary")

            # Update records for 'iCLOUD-PAYMENT-CARD'
            update_cardpayment_query = """
            UPDATE Recon_Summary
              JOIN Payment_Refund ON Recon_Summary.Txn_RefNo = Payment_Refund.Txn_RefNo
               SET Recon_Summary.Card_Payment = Payment_Refund.Txn_Amount
             WHERE Payment_Refund.Txn_Source = 'iCLOUD-PAYMENT'
               AND Payment_Refund.Txn_Type IN ('Credit Card (Razorpay)','Debit Card (Razorpay)');"""
            cursor.execute(update_cardpayment_query)
            print("Updated 'iCLOUD-PAYMENT-CARD' records into Recon_Summary")

            # Update records for 'iCLOUD-REFUND-HDFC'
            update_cardrefund_query = """
            UPDATE Recon_Summary
              JOIN Payment_Refund ON Recon_Summary.Txn_RefNo = Payment_Refund.Txn_RefNo
               SET Recon_Summary.Card_Refund = Payment_Refund.Txn_Amount
             WHERE Payment_Refund.Txn_Source = 'iCLOUD-REFUND'
               AND Payment_Refund.Txn_Type IN ('Credit Card (Razorpay) (auto)','Debit Card (Razorpay) (auto)');"""
            cursor.execute(update_cardrefund_query)
            print("Updated 'iCLOUD-REFUND-CARD' records into Recon_Summary")

            # Update records for 'iCLOUD-PAYMENT-SODEXO'
            update_sodexopayment_query = """
            UPDATE Recon_Summary
              JOIN Payment_Refund ON Recon_Summary.Txn_RefNo = Payment_Refund.Txn_RefNo
               SET Recon_Summary.Sodexo_Payment = Payment_Refund.Txn_Amount
             WHERE Payment_Refund.Txn_Source = 'iCLOUD-PAYMENT'
               AND Payment_Refund.Txn_Type = 'Pluxee (Sodexo)';"""
            cursor.execute(update_sodexopayment_query)
            print("Updated 'iCLOUD-PAYMENT-SODEXO' records into Recon_Summary")

            # Update records for 'iCLOUD-REFUND-SODEXO'
            update_sodexorefund_query = """
            UPDATE Recon_Summary
              JOIN Payment_Refund ON Recon_Summary.Txn_RefNo = Payment_Refund.Txn_RefNo
               SET Recon_Summary.Sodexo_Refund = Payment_Refund.Txn_Amount
             WHERE Payment_Refund.Txn_Source = 'iCLOUD-REFUND'
               AND Payment_Refund.Txn_Type = 'Pluxee (Sodexo) (auto)';"""
            cursor.execute(update_sodexorefund_query)
            print("Updated 'iCLOUD-REFUND-SODEXO' records into Recon_Summary")

            # Update records for 'iCLOUD-PAYMENT-CASH'
            update_cashpayment_query = """
            UPDATE Recon_Summary
              JOIN Payment_Refund ON Recon_Summary.Txn_RefNo = Payment_Refund.Txn_RefNo
               SET Recon_Summary.Cash_Payment = Payment_Refund.Txn_Amount
             WHERE Payment_Refund.Txn_Source = 'iCLOUD-PAYMENT'
               AND Payment_Refund.Txn_Type = 'Cash';"""
            cursor.execute(update_cashpayment_query)
            print("Updated 'iCLOUD-PAYMENT-SODEXO' records into Recon_Summary")

            # Update records for 'PAYTM-PAYMENT'
            update_paytmpayment_query = """
            UPDATE Recon_Summary
              JOIN PayTM_PhonePe ON Recon_Summary.Txn_RefNo = PayTM_PhonePe.Txn_RefNo
               SET Recon_Summary.PayTM_Payment = (SELECT SUM(PayTM_PhonePe.Txn_Amount) FROM PayTM_PhonePe WHERE Recon_Summary.Txn_RefNo = PayTM_PhonePe.Txn_RefNo GROUP BY Txn_RefNo)
             WHERE PayTM_PhonePe.Txn_Source = 'PayTM'
               AND PayTM_PhonePe.Txn_Type = 'PAYMENT';"""
            cursor.execute(update_paytmpayment_query)
            print("Updated 'PAYTM-PAYMENT' records into Recon_Summary")

            # Insert records for 'PAYTM-PAYMENT'
            insert_paytmpayment_query = """
            INSERT IGNORE INTO Recon_Summary (Txn_Source, Txn_Type, Txn_RefNo, Txn_Machine, Txn_MID,  Txn_Date, 
            Cloud_Payment, Cloud_Refund, Cloud_MRefund, 
            PayTM_Payment, PayTM_Refund, PhonePe_Payment, PhonePe_Refund, 
            VMSMoney_Payment, VMSMoney_Refund, Card_Payment, Card_Refund, 
            Sodexo_Payment, Sodexo_Refund, HDFC_Payment, HDFC_Refund, Cash_Payment)
            SELECT Txn_Source, Txn_Type, Txn_RefNo, Txn_Machine, Txn_MID,  Txn_Date, 
            0 AS Cloud_Payment, 0 AS Cloud_Refund, 0 AS Cloud_MRefund, 
            Txn_Amount AS PayTM_Payment, 0 AS PayTM_Refund, 0 AS PhonePe_Payment, 0 AS PhonePe_Refund, 
            0 AS VMSMoney_Payment, 0 AS VMSMoney_Refund, 0 AS Card_Payment, 0 AS Card_Refund, 
            0 AS Sodexo_Payment, 0 AS Sodexo_Refund, 0 As HDFC_Payment, 0 AS HDFC_Refund, 0 AS Cash_Payment
              FROM PayTM_PhonePe
             WHERE Txn_Source = 'PayTM'
               AND Txn_Type = 'PAYMENT'
               AND Txn_RefNo NOT IN (SELECT DISTINCT Txn_RefNo FROM RECON_SUMMARY);"""
            cursor.execute(insert_paytmpayment_query)
            print("Inserted 'PAYTM-PAYMENT' records into Recon_Summary")

            # Update records for 'PAYTM-REFUND'
            update_paytmrefund_query = """
            UPDATE Recon_Summary
              JOIN PayTM_PhonePe ON Recon_Summary.Txn_RefNo = PayTM_PhonePe.Txn_RefNo
               SET Recon_Summary.PayTM_Refund = (SELECT SUM(PayTM_PhonePe.Txn_Amount) FROM PayTM_PhonePe WHERE Recon_Summary.Txn_RefNo = PayTM_PhonePe.Txn_RefNo GROUP BY Txn_RefNo)
             WHERE PayTM_PhonePe.Txn_Source = 'PayTM'
               AND PayTM_PhonePe.Txn_Type = 'REFUND';"""
            cursor.execute(update_paytmrefund_query)
            print("Updated 'PAYTM-REFUND' records into Recon_Summary")

            # Insert records for 'PAYTM-REFUND'
            insert_paytmrefund_query = """
            INSERT IGNORE INTO Recon_Summary (Txn_Source, Txn_Type, Txn_RefNo, Txn_Machine, Txn_MID,  Txn_Date, 
            Cloud_Payment, Cloud_Refund, Cloud_MRefund, 
            PayTM_Payment, PayTM_Refund, PhonePe_Payment, PhonePe_Refund, 
            VMSMoney_Payment, VMSMoney_Refund, Card_Payment, Card_Refund, 
            Sodexo_Payment, Sodexo_Refund, HDFC_Payment, HDFC_Refund, Cash_Payment)
            SELECT Txn_Source, Txn_Type, Txn_RefNo, Txn_Machine, Txn_MID,  Txn_Date, 
            0 AS Cloud_Payment, 0 AS Cloud_Refund, 0 AS Cloud_MRefund, 
            0 AS PayTM_Payment, Txn_Amount AS PayTM_Refund, 0 AS PhonePe_Payment, 0 AS PhonePe_Refund, 
            0 AS VMSMoney_Payment, 0 AS VMSMoney_Refund, 0 AS Card_Payment, 0 AS Card_Refund, 
            0 AS Sodexo_Payment, 0 AS Sodexo_Refund, 0 As HDFC_Payment, 0 AS HDFC_Refund, 0 AS Cash_Payment
              FROM PayTM_PhonePe
             WHERE Txn_Source = 'PayTM'
               AND Txn_Type = 'REFUND'
               AND Txn_RefNo NOT IN (SELECT DISTINCT Txn_RefNo FROM RECON_SUMMARY);"""
            cursor.execute(insert_paytmrefund_query)
            print("Inserted 'PAYTM-REFUND' records into Recon_Summary")

            # Update records for 'PHONEPE-PAYMENT'
            update_phonepepayment_query = """
            UPDATE Recon_Summary
              JOIN PayTM_PhonePe ON Recon_Summary.Txn_RefNo = PayTM_PhonePe.Txn_RefNo
               SET Recon_Summary.PhonePe_Payment = (SELECT SUM(PayTM_PhonePe.Txn_Amount) FROM PayTM_PhonePe WHERE Recon_Summary.Txn_RefNo = PayTM_PhonePe.Txn_RefNo GROUP BY Txn_RefNo)
             WHERE PayTM_PhonePe.Txn_Source = 'PhonePe'
               AND PayTM_PhonePe.Txn_Type = 'PAYMENT';"""
            cursor.execute(update_phonepepayment_query)
            print("Updated 'PHONEPE-PAYMENT' records into Recon_Summary")

            # Insert records for 'PHONEPE-PAYMENT'
            insert_phonepepayment_query = """
            INSERT IGNORE INTO Recon_Summary (Txn_Source, Txn_Type, Txn_RefNo, Txn_Machine, Txn_MID,  Txn_Date, 
            Cloud_Payment, Cloud_Refund, Cloud_MRefund, 
            PayTM_Payment, PayTM_Refund, PhonePe_Payment, PhonePe_Refund, 
            VMSMoney_Payment, VMSMoney_Refund, Card_Payment, Card_Refund, 
            Sodexo_Payment, Sodexo_Refund, HDFC_Payment, HDFC_Refund, Cash_Payment)
            SELECT Txn_Source, Txn_Type, Txn_RefNo, Txn_Machine, Txn_MID,  Txn_Date, 
            0 AS Cloud_Payment, 0 AS Cloud_Refund, 0 AS Cloud_MRefund, 
            0 AS PayTM_Payment, 0 AS PayTM_Refund, Txn_Amount AS PhonePe_Payment, 0 AS PhonePe_Refund, 
            0 AS VMSMoney_Payment, 0 AS VMSMoney_Refund, 0 AS Card_Payment, 0 AS Card_Refund, 
            0 AS Sodexo_Payment, 0 AS Sodexo_Refund, 0 As HDFC_Payment, 0 AS HDFC_Refund, 0 AS Cash_Payment
              FROM PayTM_PhonePe
             WHERE Txn_Source = 'PhonePe'
               AND Txn_Type = 'PAYMENT'
               AND Txn_RefNo NOT IN (SELECT DISTINCT Txn_RefNo FROM RECON_SUMMARY);"""
            cursor.execute(insert_phonepepayment_query)
            print("Inserted 'PHONEPE-PAYMENT' records into Recon_Summary")

            # Update records for 'PHONEPE-REFUND'
            update_phoneperefund_query = """
            UPDATE Recon_Summary
              JOIN PayTM_PhonePe ON Recon_Summary.Txn_RefNo = PayTM_PhonePe.Txn_RefNo
               SET Recon_Summary.PhonePe_Refund = (SELECT SUM(PayTM_PhonePe.Txn_Amount) FROM PayTM_PhonePe WHERE Recon_Summary.Txn_RefNo = PayTM_PhonePe.Txn_RefNo GROUP BY Txn_RefNo)
             WHERE PayTM_PhonePe.Txn_Source = 'PhonePe'
               AND PayTM_PhonePe.Txn_Type = 'REFUND';"""
            cursor.execute(update_phoneperefund_query)
            print("Updated 'PHONEPE-REFUND' records into Recon_Summary")

            # Insert records for 'PHONEPE-REFUND'
            insert_phoneperefund_query = """
            INSERT IGNORE INTO Recon_Summary (Txn_Source, Txn_Type, Txn_RefNo, Txn_Machine, Txn_MID,  Txn_Date, 
            Cloud_Payment, Cloud_Refund, Cloud_MRefund, 
            PayTM_Payment, PayTM_Refund, PhonePe_Payment, PhonePe_Refund, 
            VMSMoney_Payment, VMSMoney_Refund, Card_Payment, Card_Refund, 
            Sodexo_Payment, Sodexo_Refund, HDFC_Payment, HDFC_Refund, Cash_Payment)
            SELECT Txn_Source, Txn_Type, Txn_RefNo, Txn_Machine, Txn_MID,  Txn_Date, 
            0 AS Cloud_Payment, 0 AS Cloud_Refund, 0 AS Cloud_MRefund, 
            0 AS PayTM_Payment, 0 AS PayTM_Refund, 0 AS PhonePe_Payment, Txn_Amount AS PhonePe_Refund, 
            0 AS VMSMoney_Payment, 0 AS VMSMoney_Refund, 0 AS Card_Payment, 0 AS Card_Refund, 
            0 AS Sodexo_Payment, 0 AS Sodexo_Refund, 0 As HDFC_Payment, 0 AS HDFC_Refund, 0 AS Cash_Payment
              FROM PayTM_PhonePe
             WHERE Txn_Source = 'PhonePe'
               AND Txn_Type = 'REFUND'
               AND Txn_RefNo NOT IN (SELECT DISTINCT Txn_RefNo FROM RECON_SUMMARY);"""
            cursor.execute(insert_phoneperefund_query)
            print("Inserted 'PHONEPE-REFUND' records into Recon_Summary")


            connection.commit()
            print("All SQL commands executed successfully.")

    except Error as e:
        print(f"Error: {e}")

    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()
            print("MySQL connection is closed.")

# Call the function to execute the SQL commands
execute_sql_commands()
