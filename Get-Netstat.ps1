<#
.SYNOPSIS
  The "Get-Netstat" function retrieves the TCP/UDP ports that are currently listening for inbound connections, the process/executable that started the listener, and (if run in an administrator shell) will display the UserName identity that started the listener.

.EXAMPLE
  PS C:\> $netstat = NetstatGet
  PS C:\> $netstat[0]


  LocalAddress  : ::
  RemoteAddress : ::
  Proto         : TCP
  LocalPort     : 135
  RemotePort    : 0
  State         : Listen
  PID           : 984
  UserName      : NT AUTHORITY\NETWORK SERVICE
  ProcessName   : svchost
  Path          : C:\WINDOWS\system32\svchost.exe



  Here we run the function by using its built-in alias of "NetstatGet" and putting the output into a variable.  We then display the first object and see valuable information such as the Process ID, the path of the executable that initiated the listener, and the identity of the 'UserName' that ran the executable.

.EXAMPLE
  PS C:\> Get-Netstat | Export-Csv -NoTypeInformation "C:\$(HOSTNAME.EXE)_$(Get-Date -Format yyyy-MM-dd).csv"


  Here we run the Get-Netstat function and output the information to a .csv file containing the hostname of the computer and the date.

.EXAMPLE
  PS C:\> $targets = get-adcomputer -filter * -Property DNSHostName
  PS C:\> $portlist = @()
  PS C:\> $i = 1
  PS C:\> $count = $targets.count
      
  PS C:\> foreach ($targethost in $targets) {
      write-host $i of $count -  $targethost.DNSHostName
      if (Test-Connection -ComputerName $targethost.DNSHostName -count 2 -Quiet) {
          $portlist += invoke-command -ComputerName $targethost ${function:Get-Netstat}
          ++$i
      }
  }
  PS C:\> $portlist | export-csv all-ports.csv



  Here we demonstrate a recommended means (from the isc.sans.edu post referenced in the Notes) of running "Get-Netstat" on computers throughout the domain in order to get a list of listening ports.  From there you can identify outliers from the norm with long tail analysis.

.NOTES
  Name:  Get-Netstat.ps1
  Author:  Rob VandenBrink (modified by: Travis Logue)
  Version History:  1.2 | 2022-01-02 | Added an alias and updated documentation
  Dependencies:  
  Notes:
  - Original Author: Rob VandenBrink
  - Modified by: Travis Logue
  - 2020-02-03 - I grabbed the original code from here:  https://isc.sans.edu/forums/diary/Netstat+Local+and+Remote+new+and+improved+now+with+more+PowerShell/25058/
  - The original code is very effective but I am adding an alias and changing the original name of the tool

  
  .
#>
function Get-Netstat {
  [CmdletBinding()]
  [Alias('NetstatGet')]
  param ()
  
  begin {
    $Processes = @{ }

    # first check if we're running elevated or not, so we don't error out on the Get-Process command
    # note that account info is only retrieved if we are elevated

    if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
      # Elevated - get account info per process
      Get-Process -IncludeUserName | ForEach-Object {
        $Processes[$_.Id] = $_
      }
    }
    else {
      # Not Elevated - don't collect per-process account info
      Get-Process | ForEach-Object {
        $Processes[$_.Id] = $_
      }
    }
  }
  
  process {
    # Query Listening TCP Ports and Connections
    $Ports = Get-NetTCPConnection |
    Select-Object LocalAddress,
    RemoteAddress,
    @{Name = "Proto"; Expression = { "TCP" } },
    LocalPort, RemotePort, State,
    @{Name = "PID"; Expression = { $_.OwningProcess } },
    @{Name = "UserName"; Expression = { $Processes[[int]$_.OwningProcess].UserName } },
    @{Name = "ProcessName"; Expression = { $Processes[[int]$_.OwningProcess].ProcessName } },
    @{Name = "Path"; Expression = { $Processes[[int]$_.OwningProcess].Path } } |
    Sort-Object -Property LocalPort, UserName

    # Query Listening UDP Ports (No Connections in UDP)
    $UDPPorts += Get-NetUDPEndpoint |
    Select-Object LocalAddress, RemoteAddress,
    @{Name = "Proto"; Expression = { "UDP" } },
    LocalPort, RemotePort, State,
    @{Name = "PID"; Expression = { $_.OwningProcess } },
    @{Name = "UserName"; Expression = { $Processes[[int]$_.OwningProcess].UserName } },
    @{Name = "ProcessName"; Expression = { $Processes[[int]$_.OwningProcess].ProcessName } },
    @{Name = "Path"; Expression = { $Processes[[int]$_.OwningProcess].Path } } |
    Sort-Object -Property LocalPort, UserName
  }
  
  end {
    foreach ($P in $UDPPorts) {
      if ( $P.LocalAddress -eq "0.0.0.0") { $P.State = "Listen" } 
    }
  
    $Ports += $UDPPorts
  
    $Ports
  }
}