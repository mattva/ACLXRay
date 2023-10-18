#Requires -version 5.1
<#
.VERSION 2023.10.18

.AUTHOR Matteo Vadagnini

.COMPANYNAME Microsoft

.DESCRIPTION 
ACLXRay Custom Collector to retrieve extension attributes from user and group objects
Please configure destinationpath to point to the correct tools machine

-requires AD powershell module
-requires PS 5.1 (for Compress-archive)
#>
Set-Location 'C:\Program Files\ACLXRAY'
$hostname = [System.Net.Dns]::GetHostEntry($Env:ComputerName).HostName
$TimeStamp = Get-date -Format yyyyMMddHHmmss
$filename = "$($hostname)_extendedattributes.tsv"
$ServerInfofilename = "$($hostname)_ServerInfo.tsv"
$zipfilename = $hostname+"_extendedattributes_"+$TimeStamp+".zip"
$destinationFolder="\\contosofs1.contoso.com\TSVFiles\Client\"
$destinationPath="\\contosofs1.contoso.com\TSVFiles\Client\$zipfilename"
$logfile="$($hostname)_CustomCollector_ExtendedAttributes_$timestamp.log"

Function Write-Log {
<#
    .SYNOPSIS
        Write a log line with timestamp and verbosity level (INOF by default)
    .DESCRIPTION
        Write a log line with timestamp and verbosity level (INOF by default)
    .INPUTS
        Message: string with the message to append (mandatory)
        Level: verbosity Level (optional)
        Logfile: output log file (optional)
    .OUTPUTS
        None
    .EXAMPLE
        Write-Log INFO "Some message with $var" $logFile
    #>
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$False)]
    [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
    [String]
    $Level = "INFO",
    [Parameter(Mandatory=$True)]
    [string]
    $Message,
    [Parameter(Mandatory=$False)]
    [string]
    $logfile
    )
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    If($logfile) {
        Add-Content $logfile -Value $Line
    }
    switch ($Level) {
        "INFO" {Write-host $line}
        "WARN" {Write-Host -ForegroundColor Yellow $Line}
        "ERROR" {Write-Host -ForegroundColor Magenta $line}
        "FATAL" {write-host -ForegroundColor Red $line}
        "DEBUG" {write-host -ForegroundColor Cyan $line}
        }
}
Write-Log -Message "starting custom collector." -logfile $logFile -Level INFO

Write-Log -Message "Colecting ServerInfo" -logfile $logFile -Level INFO
$ts=get-date -Format "yyyy-MM-dd HH:mm:ss.fff"
Get-ADComputer -Filter {dnshostname -eq $hostname} | Select-Object @{name="ServerFqdn";Expression={$_.dnshostname}},@{name="Authority";Expression={(get-addomain).DNSRoot}}, `
@{name="NetbiosDomainName";Expression={$_.Name}},@{name="ServerSID";Expression={$_.SID}},@{name="Timestamp";Expression={$ts}},@{name="GUID";Expression={$_.ObjectGUID}}, `
@{name="sAMAccountName";Expression={$_.Name}},@{name="ForestRootDNS";Expression={(get-addomain).Forest}} `
| ConvertTo-Csv -NoTypeInformation -Delimiter "`t" | ForEach-Object { $_ -replace '"' } | Set-Content $ServerInfofilename -Encoding UTF8

Write-Log -Message "gathering user information" -logfile $logFile -Level INFO

Try {
    Get-ADUser -Filter * -Properties * | Select-Object DisplayName,SamAccountName,ObjectSID,@{Name="ID";Expression={$_.ObjectGUID}},extensionattribute1,extensionattribute2,extensionattribute3,`
    extensionattribute4,extensionattribute5,extensionattribute6,extensionattribute7,extensionattribute8,extensionattribute9,`
    extensionattribute10,extensionattribute11,extensionattribute12,extensionattribute13,extensionattribute14,extensionattribute15 -ErrorAction Stop `
    | ConvertTo-Csv -NoTypeInformation -Delimiter "`t"| ForEach-Object { $_ -replace '"' } | Set-Content $filename -Encoding UTF8
} catch {
            $ErrorMessage = $_.Exception.Message
            Write-Log -Message "$ErrorMessage" -logfile $logFile -Level ERROR
            continue
}

Write-Log -Message "gathering group information" -logfile $logFile -Level INFO

Try {
    Get-ADGroup -Filter * -Properties * | Select-Object DisplayName,SamAccountName,ObjectSID,@{Name="ID";Expression={$_.ObjectGUID}},extensionattribute1,extensionattribute2,extensionattribute3,`
    extensionattribute4,extensionattribute5,extensionattribute6,extensionattribute7,extensionattribute8,extensionattribute9,`
    extensionattribute10,extensionattribute11,extensionattribute12,extensionattribute13,extensionattribute14,extensionattribute15 -ErrorAction Stop `
    | ConvertTo-Csv -NoTypeInformation -Delimiter "`t"| Select-Object -Skip 1 | ForEach-Object { $_ -replace '"' } | Add-Content $filename -Encoding UTF8
} catch {
            $ErrorMessage = $_.Exception.Message
            Write-Log -Message "$ErrorMessage" -logfile $logFile -Level ERROR
            continue
}

Write-Log -Message "Moving $filename $serverInfoFileName to $destionationpath" -logfile $logFile -Level INFO

Try {
    Compress-Archive -Path $filename,$ServerInfofilename -DestinationPath $destinationpath -ErrorAction Stop
} catch {
            $ErrorMessage = $_.Exception.Message
            Write-Log -Message "$ErrorMessage" -logfile $logFile -Level ERROR
            continue
}

Write-Log -Message "Moving $logfile to $destinationFolder\Logs" -logfile $logFile -Level INFO

Try {
    Move-Item $logfile "$destinationFolder\Logs\" -ErrorAction Stop
} catch {
            $ErrorMessage = $_.Exception.Message
            Write-Log -Message "$ErrorMessage" -logfile $logFile -Level ERROR
            continue
}

#remove-item $filename