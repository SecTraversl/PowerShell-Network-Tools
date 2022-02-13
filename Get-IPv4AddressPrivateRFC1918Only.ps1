<#
.SYNOPSIS
  The "Get-IPv4AddressPrivateRFC1918Only" function takes an array of IP addresses and returns back only those IPv4 addresses that are fall within the Private RFC1918 address network ranges.

.EXAMPLE
  PS C:\> $test | select -f 20
  142.251.32.163
  fe80:0:0:0:8c9f:f627:d0e:ac76
  192.168.86.23
  192.168.86.20
  fe80:0:0:0:8c9f:f627:d0e:ac76
  192.168.86.43
  fe80:0:0:0:8c9f:f627:d0e:ac76
  192.168.86.1
  fe80:0:0:0:8c9f:f627:d0e:ac76
  192.168.86.48
  10.30.76.33
  192.168.86.48
  10.30.76.33
  192.168.86.48
  104.108.143.17
  192.168.86.1
  192.168.86.30
  192.168.86.43
  192.168.86.28
  104.108.143.17

  PS C:\> $test | select -f 20 | IPv4AddressPrivateRFC1918Only -ErrorAction SilentlyContinue
  192.168.86.23
  192.168.86.20
  192.168.86.43
  192.168.86.1
  192.168.86.48
  10.30.76.33
  192.168.86.48
  10.30.76.33
  192.168.86.48
  192.168.86.1
  192.168.86.30
  192.168.86.43
  192.168.86.28



  Here we have an array of IP Addresses contained within the variable '$test', including IPv4 Public and Private RFC1918 addresses as well as IPv6 addresses.  We then pipe those addresses into the function (by using its built-in alias of "IPv4AddressPrivateRFC1918Only") and in return we receive back only the addresses that are IPv4 Private RFC1918 addresses.

.NOTES
  Name:  Get-IPv4AddressPrivateRFC1918Only.ps1
  Author:  Travis Logue
  Version History:  1.1 | 2022-01-08 | Initial Version
  Dependencies:  
  Notes:
  - 

  .
#>
function Get-IPv4AddressPrivateRFC1918Only {
  [CmdletBinding()]
  [Alias('IPv4AddressPrivateRFC1918Only')]
  param (
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidatePattern("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")]
    [System.Object[]]
    $IPList
  )
  
  begin {
    # The begin block is run just once and allows us to define an array wherein we will place all of the objects from $IPList that we receive from the "|" Pipeline
    $array = @()
  }
  
  process {
    # The process block will run for each object in $IPList seen by the "|" Pipeline
    # - from the Pipeline we want to add each of the Objects to our $array before we apply our logic in the end{} block
    $array += $IPList
  }

  end {
    # The end block will apply our logic below for the entire $array of objects (originally from the $IPList array) received from the Pipeline

    foreach ($IP in $array) {
      $10Start = [version]"10.0.0.0"
      $10End = [version]"10.255.255.255"
    
      $172Start = [version]"172.16.0.0"
      $172End = [version]"172.31.255.255"
    
      $192Start = [version]"192.168.0.0"
      $192End = [version]"192.168.255.255"
    
      if ($10Start -le [version]$IP -and [version]$IP -le $10End) {
        Write-Output $IP
      }
      elseif ($172Start -le [version]$IP -and [version]$IP -le $172End) {
        Write-Output $IP
      }
      elseif ($192Start -le [version]$IP -and [version]$IP -le $192End) {
        Write-Output $IP
      }
    }

  }


}