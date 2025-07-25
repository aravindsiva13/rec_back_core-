# # Set HOME_DIR and its sub directories containing your input files
# $HOME_DIR = "C:\Users\IT\Downloads\Recon_Automation_LatestScripts"
# $inputFolderPath = Join-Path $HOME_DIR "Input_Files"
# $outputFolderPath = Join-Path $HOME_DIR "Output_Files"

# $outputFile = Join-Path $outputFolderPath "iCloud_Payment.csv"
# $temp_pmt_file = Join-Path $inputFolderPath "temp_pmt_file.csv"

# #---------------- To remove blank spaces from Header record ----------------
# # Get all Payment files starting with "pmt" from inputFolderPath
# $paymentFiles = Get-ChildItem -Path $inputFolderPath -Filter pmt*.csv

# # Loop through each .zip file and extract it
# foreach ($paymentFile in $paymentFiles) 
# {
#     #Write-Host $paymentFile
#     $file2process = Join-Path $inputFolderPath $paymentFile
#     #Write-Host $file2process
#     $csv = Get-Content $file2process
#     $csv[0] = $csv[0] -replace ' ', ''  # Modify only the first line (header)
#     $csv | Set-Content $temp_pmt_file  # Save the changes
#     Remove-Item -Path $file2process
#     Rename-Item -Path $temp_pmt_file -NewName $file2process
# }
# #---------------- To remove blank spaces from Header record ----------------



# # Get all Payment files starting with "pmt" from inputFolderPath
# $paymentFiles = Get-ChildItem -Path $inputFolderPath -Filter pmt*.csv

# # Loop through each pmt*.csv file and write into output file
# foreach ($paymentFile in $paymentFiles) 
# {
#     Write-Host "Processing Payment file: $($paymentFile.Name)"
#     ### For each pmt*.csv create output file and load the output to the table immediately to avoid creating bulk CSV file which fails if created for one full month
#     # Delete Output File, if exist already
#     if ( Test-Path $outputFile) { Remove-Item -Path $outputFile }
#     # Create fresh Output File
#     if ( -not (Test-Path $outputFile) ) { Out-File -FilePath $outputfile -Encoding utf8 }

#     # Write Header - the first line into output CSV file
#     ###Write-Host "Txn_Source, Txn_Machine, Txn_MID, Txn_Type, Txn_Date, Txn_RefNo, Txn_Amount" 
#     Add-Content -Path $outputFile -NoNewline -Value "Txn_Source, Txn_Machine, Txn_MID, Txn_Type, Txn_Date, Txn_RefNo, Txn_Amount" 
#     Add-Content -Path $outputFile -Value ""

#     # Import the CSV file
#     $file2process = Join-Path $inputFolderPath $paymentFile
#     $data1 = Import-Csv -Path $file2process | Where-Object { $_.Status -like "*SUCCESS*" }
#     # $data1 = Import-Csv -Path $inputFile | Select-Object order_id | Sort-Object -Property order_id -Unique 

#     # Iterate through each row
#     foreach ($data1_row in $data1) 
#     {
#         $txn_source = "iCLOUD-PAYMENT"
#         $txn_machine = $data1_row.MachineId
#         $txn_mid = $data1_row.MID
#         $txn_type = $data1_row.PaymentMethod
#         $txn_date = $data1_row.TransactionDate.Substring(6,4), $data1_row.TransactionDate.Substring(3,2), $data1_row.TransactionDate.Substring(0,2)
#         $txn_refno = $data1_row.TransactionId
#         $txn_amount = $data1_row.PaidAmount

#         ###Write-Host $txn_source, ",", $txn_machine, ",", $txn_mid, ",", $txn_type, ",", $txn_date, ",", $txn_refno, ",", $txn_amount
#         Add-Content -Path $outputFile -NoNewline -Value $txn_source, ",", $txn_machine, ",", $txn_mid, ",", $txn_type, ",", $txn_date, ",", $txn_refno, ",", $txn_amount
#         Add-Content -Path $outputFile -Value ""
#     }
#     python load2table_iCloudPayment.py
#     # Rename Output File
#     $renamedOutputFile = Join-Path $outputFolderPath $paymentFile
#     Rename-Item -Path $outputFile -NewName $renamedOutputFile
#     Write-Host "File renamed successfully"
# }


#2


# Set HOME_DIR and its sub directories containing your input files
$HOME_DIR = "C:\Users\IT\Downloads\Recon_Automation_LatestScripts"
$inputFolderPath = Join-Path $HOME_DIR "Input_Files"
$outputFolderPath = Join-Path $HOME_DIR "Output_Files"

$outputFile = Join-Path $outputFolderPath "iCloud_Payment.csv"
$temp_pmt_file = Join-Path $inputFolderPath "temp_pmt_file.csv"

#---------------- To remove blank spaces from Header record ----------------
# Get all Payment files starting with "pmt" from inputFolderPath
$paymentFiles = Get-ChildItem -Path $inputFolderPath -Filter pmt*.csv

# Loop through each .zip file and extract it
foreach ($paymentFile in $paymentFiles) 
{
    #Write-Host $paymentFile
    $file2process = Join-Path $inputFolderPath $paymentFile
    #Write-Host $file2process
    $csv = Get-Content $file2process
    $csv[0] = $csv[0] -replace ' ', ''  # Modify only the first line (header)
    $csv | Set-Content $temp_pmt_file  # Save the changes
    Remove-Item -Path $file2process
    Rename-Item -Path $temp_pmt_file -NewName $file2process
}
#---------------- To remove blank spaces from Header record ----------------

# Get all Payment files starting with "pmt" from inputFolderPath
$paymentFiles = Get-ChildItem -Path $inputFolderPath -Filter pmt*.csv

# Loop through each pmt*.csv file and write into output file
foreach ($paymentFile in $paymentFiles) 
{
    Write-Host "Processing Payment file: $($paymentFile.Name)"
    
    ### For each pmt*.csv create output file and load the output to the table immediately to avoid creating bulk CSV file which fails if created for one full month
    # Delete Output File, if exist already
    if (Test-Path $outputFile) { 
        Remove-Item -Path $outputFile -Force
        Start-Sleep -Milliseconds 500  # Wait for file system to release handle
    }
    
    # Create fresh Output File using Out-File instead of separate creation
    $headerLine = "Txn_Source,Txn_Machine,Txn_MID,Txn_Type,Txn_Date,Txn_RefNo,Txn_Amount"
    $headerLine | Out-File -FilePath $outputFile -Encoding utf8

    # Import the CSV file
    $file2process = Join-Path $inputFolderPath $paymentFile
    $data1 = Import-Csv -Path $file2process | Where-Object { $_.Status -like "*SUCCESS*" }

    # Create an array to collect all output lines
    $outputLines = @()

    # Iterate through each row
    foreach ($data1_row in $data1) 
    {
        $txn_source = "iCLOUD-PAYMENT"
        $txn_machine = $data1_row.MachineId
        $txn_mid = $data1_row.MID
        $txn_type = $data1_row.PaymentMethod
        $txn_date = $data1_row.TransactionDate.Substring(6,4) + "-" + $data1_row.TransactionDate.Substring(3,2) + "-" + $data1_row.TransactionDate.Substring(0,2)
        $txn_refno = $data1_row.TransactionId
        $txn_amount = $data1_row.PaidAmount

        # Create the CSV line
        $csvLine = "$txn_source,$txn_machine,$txn_mid,$txn_type,$txn_date,$txn_refno,$txn_amount"
        $outputLines += $csvLine
    }

    # Write all lines at once to avoid stream conflicts
    if ($outputLines.Count -gt 0) {
        $outputLines | Add-Content -Path $outputFile -Encoding utf8
    }

    # Call Python script - Fix the filename reference
    python "load2table_iCloud_Payment.py"
    
    # Rename Output File
    $renamedOutputFile = Join-Path $outputFolderPath $paymentFile
    
    # Ensure the file is not locked before renaming
    Start-Sleep -Milliseconds 500
    
    if (Test-Path $renamedOutputFile) {
        Remove-Item -Path $renamedOutputFile -Force
    }
    
    Rename-Item -Path $outputFile -NewName $renamedOutputFile
    Write-Host "File renamed successfully"
}