<#
.SYNOPSIS
  The "Remove-IPv6Address" function takes an array of IPv4 and IPv6 addresses and returns only the IPv4 addresses in the output.

.EXAMPLE
  PS C:\> $IPs
  57.34.74.50
  57.34.74.67
  57.34.74.92
  fe80:0:0:0:27ba:6470:fcf9:b958
  fe80:0:0:0:3afa:c929:cfab:ff27
  fe80:0:0:0:2524:f294:1ef1:7893

  PS C:\> $IPs | IPv6AddressRemove
  57.34.74.50
  57.34.74.67
  57.34.74.92



  Here we have an array of both IPv4 and IPv6 addresses.  We then use the function by referencing its built-in alias of "IPv6AddressRemove" after the pipe, and as a result the output contains only IPv4 addresses.

.NOTES
  Name:  Remove-IPv6Address.ps1
  Author:  Travis Logue
  Version History:  1.1 | 2022-02-11 | Initial Version
  Dependencies:  
  Notes:
  - 

  .
#>
function Remove-IPv6Address {
  [CmdletBinding()]
  [Alias('IPv6AddressRemove')]
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

    $Result = $array | ? {$_ -notlike "*:*"}
    Write-Output $Result

  }
}