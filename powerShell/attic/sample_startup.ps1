#Start up VMs in a predefined dependency order if vCenter is unavailable
#Only attempts to start VMs that are in a powered off state
 
#List of ESXi Hosts
#All hosts in list must have the same root credentials
# "ip of host1", "ip of host2","ip of host3",...
$ESXiHosts = "xxx.xxx.xxx.xxx","xxx.xxx.xxx.xxx"
 
#List of VM Inventory Names to Start First
#Virtualized domain controllers, DHCP Servers, or DNS Servers that other services depend on
# "VMInventoryName","VMInventoryName",...
$StartFirst = "vDC01","vDC02"
 
#List of VM Inventory Names to Start Second
#Virtualized database servers that support the vCenter databases
# "VMInventoryName","VMInventoryName",...
$StartSecond = "vDB01","vDB02"
 
#List of VM Inventory Names to Start Third
#Virtualized vCenter Server since other dependencies have been started
# "VMInventoryName","VMInventoryName",...
$StartThird = "vCenter-VM"
 
#Amount of time to wait (in seconds) between each start list of VMs
$WaitTime = "60"
 
#Prompt for ESXi root Credentials
$ESXiCreds = Get-Credential root
 
#Connect to each host defined in $ESXiHosts
Connect-viserver -Server $ESXiHosts -Credential $ESXiCreds
 
#If no host connections exit
if ($DefaultVIServer -eq $null) {
    Write "No host connected. Exiting"
    Exit
}
 
Function Start-ListofVMs($vms) {
 foreach ($vm in $vms) {
  Write "`n  ----Starting `"$vm`"..."
  Get-VM -Name $vm | Where-Object {$_.PowerState -eq "PoweredOff"} | Start-VM |  Format-Table -autosize Name, Powerstate, VMHost | Out-String
 }
 Write "`n Waiting for $WaitTime Seconds for started VMs to stabilize..."
 Start-Sleep -s $WaitTime
}
 
Write "`n Starting VMs in Start First List: $StartFirst"
Start-ListofVMs $StartFirst
 
Write "`n Starting VMs in Start Second List: $StartSecond"
Start-ListofVMs $StartSecond
 
Write "`n Starting VMs in Start Third List: $StartThird"
Start-ListofVMs $StartThird
 
Write "`n Done - Disconnecting from $ESXiHosts"
Disconnect-VIServer -Server * -Force -Confirm:$false
Exit

