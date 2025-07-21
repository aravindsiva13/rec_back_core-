# $HOME_DIR = "C:\Users\IT\Downloads\Recon_Automation_LatestScripts"
# ###Write-Host "HOME_DIR is set to: $HOME_DIR"

# # Set the directory containing your .zip files
# $inputFolderPath = Join-Path $HOME_DIR "Input_Files"
# $outputFolderPath = Join-Path $HOME_DIR "Output_Files"
# $outputFile = Join-Path $outputFolderPath "output_PhonePe.csv"

# # Get all PhonePe files starting with "Merchant_Settlement_Report" from inputFolderPath
# $phonepeFiles = Get-ChildItem -Path $inputFolderPath -Filter Merchant_Settlement_Report*.csv

# # Loop through each Merchant_Settlement_Report*.csv file and extract it
# foreach ($phonepeFile in $phonepeFiles) 
# {
#     Write-Host "Processing PhonePe file: $($phonepeFile.Name)"
#     # Delete Output File, if exist already
#     if ( Test-Path $outputFile) { Remove-Item -Path $outputFile }
#     # Create fresh Output File
#     if ( -not (Test-Path $outputFile) ) { Out-File -FilePath $outputfile -Encoding utf8 }

#     # Write Header - the first line into output CSV file 
#     ###Write-Host "Txn_Source, Txn_Machine, Txn_MID, Txn_Type, Txn_Date, Txn_RefNo, Txn_Amount" 
#     Add-Content -Path $outputFile -NoNewline -Value "Txn_Source, Txn_Machine, Txn_MID, Txn_Type, Txn_Date, Txn_RefNo, Txn_Amount" 
#     Add-Content -Path $outputFile -Value ""

#     # Import the CSV file
#     $file2process = Join-Path $inputFolderPath $phonepeFile
#     $data1 = Import-Csv -Path $file2process
#     #| Select-Object PaymentType, MerchantReferenceId, OriginalMerchantReferenceId, OriginalTransactionDate, Amount, TransactionDate,  TerminalName 
#     #| Sort-Object -Property MerchantReferenceId -Unique 

#     # Iterate through each row
#     foreach ($data1_row in $data1) 
#     {
#         #Write-Host -NoNewline "."

#         $txn_source = "PhonePe"
#         $txn_machine = $data1_row.TerminalName.Substring($data1_row.TerminalName.Length-10,10)
#         $txn_mid = $data1_row.StoreId.Substring(0,16)	
#         $txn_type = $data1_row.PaymentType
#         $txn_amount = $data1_row.Amount
#         if ($data1_row.PaymentType -eq "PAYMENT")
#         {
#             $txn_date = $data1_row.TransactionDate.Substring(6,4), $data1_row.TransactionDate.Substring(3,2), $data1_row.TransactionDate.Substring(0,2)
#             if ( $data1_row.MerchantReferenceId.IndexOf("AZ") -ge 0 ) { 
#                 $txn_refno = $data1_row.MerchantReferenceId.Substring(0,$data1_row.MerchantReferenceId.IndexOf("AZ")) 
#             } elseif ( $data1_row.MerchantReferenceId.IndexOf("-") -ge 0 ) { 
#                 $txn_refno = $data1_row.MerchantReferenceId.Substring(0,$data1_row.MerchantReferenceId.IndexOf("-")) 
#             } else {
#                 $txn_refno = $data1_row.MerchantReferenceId
#             }
#         }
#         elseif ($data1_row.PaymentType -eq "REFUND")
#         {
#             $txn_date = $data1_row.OriginalTransactionDate.Substring(6,4), $data1_row.OriginalTransactionDate.Substring(3,2), $data1_row.OriginalTransactionDate.Substring(0,2)
#             if ( $data1_row.OriginalMerchantReferenceId.IndexOf("AZ") -ge 0 ) { 
#                 $txn_refno = $data1_row.OriginalMerchantReferenceId.Substring(0,$data1_row.OriginalMerchantReferenceId.IndexOf("AZ")) 
#             } elseif ( $data1_row.OriginalMerchantReferenceId.IndexOf("-") -ge 0 ) { 
#                 $txn_refno = $data1_row.OriginalMerchantReferenceId.Substring(0,$data1_row.OriginalMerchantReferenceId.IndexOf("-")) 
#             } else { $txn_refno = $data1_row.OriginalMerchantReferenceId }
#         }

#         ###Write-Host $txn_source, ",", $txn_machine, ",", $txn_mid, ",", $txn_type, ",", $txn_date, ",", $txn_refno, ",", $txn_amount
#         Add-Content -Path $outputFile -NoNewline -Value $txn_source, ",", $txn_machine, ",", $txn_mid, ",", $txn_type, ",", $txn_date, ",", $txn_refno, ",", $txn_amount
#         Add-Content -Path $outputFile -Value ""
#     }
#     python load2table_PhonePe.py
#     # Rename Output File
#     $renamedOutputFile = Join-Path $outputFolderPath $phonepeFile
#     Rename-Item -Path $outputFile -NewName $renamedOutputFile
#     Write-Host "File renamed successfully"
# }


#2


$HOME_DIR = "C:\Users\IT\Downloads\Recon_Automation_LatestScripts"
###Write-Host "HOME_DIR is set to: $HOME_DIR"

# Set the directory containing your .zip files
$inputFolderPath = Join-Path $HOME_DIR "Input_Files"
$outputFolderPath = Join-Path $HOME_DIR "Output_Files"
$outputFile = Join-Path $outputFolderPath "output_PhonePe.csv"

# Get all PhonePe files starting with "Merchant_Settlement_Report" from inputFolderPath
$phonepeFiles = Get-ChildItem -Path $inputFolderPath -Filter Merchant_Settlement_Report*.csv

# Loop through each Merchant_Settlement_Report*.csv file and extract it
foreach ($phonepeFile in $phonepeFiles) 
{
    Write-Host "Processing PhonePe file: $($phonepeFile.Name)"
    
    # Delete Output File, if exist already
    if (Test-Path $outputFile) { 
        Remove-Item -Path $outputFile -Force
        Start-Sleep -Milliseconds 500  # Wait for file system to release handle
    }
    
    # Create fresh Output File using Out-File instead of separate creation
    $headerLine = "Txn_Source,Txn_Machine,Txn_MID,Txn_Type,Txn_Date,Txn_RefNo,Txn_Amount"
    $headerLine | Out-File -FilePath $outputFile -Encoding utf8

    # Import the CSV file
    $file2process = Join-Path $inputFolderPath $phonepeFile
    $data1 = Import-Csv -Path $file2process

    # Create an array to collect all output lines
    $outputLines = @()

    # Iterate through each row
    foreach ($data1_row in $data1) 
    {
        $txn_source = "PhonePe"
        $txn_machine = $data1_row.TerminalName.Substring($data1_row.TerminalName.Length-10,10)
        $txn_mid = $data1_row.StoreId.Substring(0,16)	
        $txn_type = $data1_row.PaymentType
        $txn_amount = $data1_row.Amount
        
        if ($data1_row.PaymentType -eq "PAYMENT")
        {
            $txn_date = $data1_row.TransactionDate.Substring(6,4) + "-" + $data1_row.TransactionDate.Substring(3,2) + "-" + $data1_row.TransactionDate.Substring(0,2)
            if ( $data1_row.MerchantReferenceId.IndexOf("AZ") -ge 0 ) { 
                $txn_refno = $data1_row.MerchantReferenceId.Substring(0,$data1_row.MerchantReferenceId.IndexOf("AZ")) 
            } elseif ( $data1_row.MerchantReferenceId.IndexOf("-") -ge 0 ) { 
                $txn_refno = $data1_row.MerchantReferenceId.Substring(0,$data1_row.MerchantReferenceId.IndexOf("-")) 
            } else {
                $txn_refno = $data1_row.MerchantReferenceId
            }
        }
        elseif ($data1_row.PaymentType -eq "REFUND")
        {
            $txn_date = $data1_row.OriginalTransactionDate.Substring(6,4) + "-" + $data1_row.OriginalTransactionDate.Substring(3,2) + "-" + $data1_row.OriginalTransactionDate.Substring(0,2)
            if ( $data1_row.OriginalMerchantReferenceId.IndexOf("AZ") -ge 0 ) { 
                $txn_refno = $data1_row.OriginalMerchantReferenceId.Substring(0,$data1_row.OriginalMerchantReferenceId.IndexOf("AZ")) 
            } elseif ( $data1_row.OriginalMerchantReferenceId.IndexOf("-") -ge 0 ) { 
                $txn_refno = $data1_row.OriginalMerchantReferenceId.Substring(0,$data1_row.OriginalMerchantReferenceId.IndexOf("-")) 
            } else { 
                $txn_refno = $data1_row.OriginalMerchantReferenceId 
            }
        }

        # Create the CSV line - escape any commas in the data
        $csvLine = "$txn_source,$txn_machine,$txn_mid,$txn_type,$txn_date,$txn_refno,$txn_amount"
        $outputLines += $csvLine
    }

    # Write all lines at once to avoid stream conflicts
    if ($outputLines.Count -gt 0) {
        $outputLines | Add-Content -Path $outputFile -Encoding utf8
    }

    # Call Python script
    python "load2table_PhonePe.py"
    
    # Rename Output File
    $renamedOutputFile = Join-Path $outputFolderPath $phonepeFile
    
    # Ensure the file is not locked before renaming
    Start-Sleep -Milliseconds 500
    
    if (Test-Path $renamedOutputFile) {
        Remove-Item -Path $renamedOutputFile -Force
    }
    
    Rename-Item -Path $outputFile -NewName $renamedOutputFile
    Write-Host "File renamed successfully"
}