write-host ""
write-host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
write-host "           Danger:  Do not continue               "
write-host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
write-host ""
$today = Get-Date -format "yyMMddHHMMss"
$HCA = "phxvcenter.healthchoiceaz.local"
$HCAVDI = "phxvcsa01v.healthchoiceaz.local"
$targetVC = read-host "To select your targets: mock, All, FP7, VB1, RDC, VDR, HCA, HCAVDI?"
$search = read-host "enter search info - examples are md-*, *-jer*, or * for all"
$vCenters = "lm-fp7-sa01", "mm-vb1-sa01", "mm-vdr-sa01", "al-rdc-a01", "phxvcenter", "phxvsa01v"
$DCs = "DC-COR-AD01", "DC-COR-AD02", "DC-NET-AD01", "DC-NET-AD02", "DC-WDF-AD01", "DC-WDF-AD02", "DC-PAR-AD01", "DC-DOC-AD02"
$jer = "ld-jer-a84", "md-jer-a90"
$DNS = "al-adm-a01", "al-adm-a02"
$exclude = $DNS+$jer+$DCs+$vCenters

$doit = read-host "Are you sure you want to start up vm's using "search" as your search?  Enter yes to continue or test to just list them"

write-host '$doit is set to '$doit
write-host 'search is set to '$search
$VMS = ''
pause

function getthem {
    $vms = get-vm `
        | where-object {$_.Name -like $search `
            -and $exclude -notcontains $_.Name `
            -and $_.PowerState -eq "PoweredOff"} `
        | Select-Object Name, PowerState, VMHost
    foreach ($vm in $vms) {
        write-host $vm.Name "is targeted for startup"
        if ($doit -eq "yes") {
            get-vm $vm.Name | Start-VM -Confirm:$False -RunAsync
            $vm | Export-Csv -Append -Path $output -noTypeInformation
        } else {
            $vm | Export-Csv -Append -Path $output -NoTypeInformation
        }
    }
}

if ($doit -eq "yes" -or $doit -eq "test") {
    $file = "\\baz-filer01\repo\Scripts\vcsToDo$target.txt"
    $output = "\\baz-filer01\repo\changes\upVMs-$targetVC-$today.csv"
    $cred = if ($cred) {
        $cred
    } else {
        Get-Credential
    }

    if ($targetVC -like "mock") {
        connect-viserver mock -Credential $cred
        getthem
    }

    if ($targetVC -like "All" -or $targetVC -like "fp7") {
        connect-viserver fp7 -Credential $cred
        getthem
    }

    if ($targetVC -like "All" -or $targetVC -like "vb1") {
        connect-viserver vb1 -Credential $cred
        getthem
    }

    if ($targetVC -like "All" -or $targetVC -like "rdc") {
        connect-viserver vb1 -Credential $cred
        getthem
    }

    if ($targetVC -like "All" -or $targetVC -like "vdr") {
        connect-viserver vdr -Credential $cred
        getthem
    }

    if ($targetVC -like "All" -or $targetVC -like "HCA") {
        connect-viserver HCA -Credential $cred
        getthem
    }

    if ($targetVC -like "All" -or $targetVC -like "HCAVDI") {
        connect-viserver HCIVDI -Credential $cred
        getthem
    }

}

