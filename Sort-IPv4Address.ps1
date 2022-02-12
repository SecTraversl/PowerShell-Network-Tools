<#
.SYNOPSIS
  The "Sort-IPAddress" function sorts IP Addresses in ascending (default) or descending (using the '-Descending' switch parameter) order.  Additionally, the second example in the 'Comment-Based-Help' shows how to do this with the "Sort-Object" cmdlet for objects with multiple properties (one of which contains an IP Address value).

.EXAMPLE
  PS C:\> $IPsRaw
  10.80.7.50
  192.168.153.1
  192.168.231.1
  PS C:\>
  PS C:\> $IPsRaw | Sort-IPAddress -Descending
  192.168.231.1
  192.168.153.1
  10.80.7.50
  PS C:\>
  PS C:\> $IPsRaw | Sort-IPAddress
  10.80.7.50
  192.168.153.1
  192.168.231.1



  Here we have an array of IP Address strings which we pipe into the "Sort-IPAddress" function for either '-Descending' or default 'Ascending' sort order.

.EXAMPLE
  PS C:\> $IPs

  IPAddress     InterfaceAlias                DefaultIPGateway InterfaceIndex
  ---------     --------------                ---------------- --------------
  10.80.7.50    Ethernet                      10.80.7.1                    19
  192.168.153.1 VMware Network Adapter VMnet8                              26
  192.168.231.1 VMware Network Adapter VMnet1                               4


  PS C:\> $IPs.ipaddress | Sort-IPAddress
  10.80.7.50
  192.168.153.1
  192.168.231.1

  PS C:\> $IPs.ipaddress | Sort-IPAddress -Descending
  192.168.231.1
  192.168.153.1
  10.80.7.50

  PS C:\> $IPs | Sort-Object {[version]$_.IPAddress}

  IPAddress     InterfaceAlias                DefaultIPGateway InterfaceIndex
  ---------     --------------                ---------------- --------------
  10.80.7.50    Ethernet                      10.80.7.1                    19
  192.168.153.1 VMware Network Adapter VMnet8                              26
  192.168.231.1 VMware Network Adapter VMnet1                               4


  PS C:\> $IPs | Sort-Object {[version]$_.IPAddress} -Descending

  IPAddress     InterfaceAlias                DefaultIPGateway InterfaceIndex
  ---------     --------------                ---------------- --------------
  192.168.231.1 VMware Network Adapter VMnet1                               4
  192.168.153.1 VMware Network Adapter VMnet8                              26
  10.80.7.50    Ethernet                      10.80.7.1                    19



  Here we have an array of objects each of which have an IP Address within a "IPAddress" property of the object.  We can dot-reference that "IPAddress" property and sort the IP addresses as we did in the first example.  Also, we can simply use the native Sort-Object cmdlet using the syntax ' {[version]$_.<Name-of-Property-with-IP-Address>} ' in order do our sorting based off of that property while keeping all other properties intact.

.NOTES
  Name:  Sort-IPAddress.ps1
  Author:  Travis Logue
  Version History:  1.1 | 2022-01-03 | Initial Version
  Dependencies:  
  Notes:
  - 2019-12-08 - This is where I learned I could cast the object/property to [version] to properly sort IP Addresses:  https://www.madwithpowershell.com/2016/03/sorting-ip-addresses-in-powershell-part.html

  - Very good article which helped me to understand the usefulness of the begin{}, process{}, and end{} blocks especially in context of using my function with the Pipeline.  The information here helped me to solve the problem of gathering all objects from the Pipeline before enacting a "Sort-Object" to the array:  https://www.sapien.com/blog/2019/05/13/advanced-powershell-functions-begin-to-process-to-end/

  - about_Pipelines:  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-5.1
  - about_Functions:  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions?view=powershell-5.1

  .
#>
function Sort-IPAddress {
  [CmdletBinding()]
  param (
    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidatePattern("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")]
    [System.Object[]]
    $IPList,
    [Parameter()]
    [switch]
    $Descending
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
    if ($Descending) {
      $array | Sort-Object {[version]$_} -Descending
    }
    else {
      $array | Sort-Object {[version]$_}
    }
  }
}