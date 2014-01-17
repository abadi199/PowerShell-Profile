<#
.SYNOPSIS
    Return the IP address from a Hostname
.DESCRIPTION
    Return the IP address from a Hostname. Use the ipv6 or ipv4 only switches to return either. Beware using localhost will only return loopback addresses.
.PARAMETER ComputerName
    One or more hostnames to resolve.  Defaults to the current machine's hostname.
.PARAMETER IPV6only
    To only retrieve IPv6 addresses
.PARAMETER IPV4only
    To only retrieve IPv4 addresses

.EXAMPLE

Get-IPAddress -IPV6only -ComputerName server123

ComputerName      IPAddress
------------      ---------
Server123         fe80::3d0f:51a2:56b:c015%83
Server123         fe80::5efe:10.71.80.160%63
Server123         2001:4898:0:fff:0:5efe:10.71.80.160

.EXAMPLE

Get-IPAddress -IPV6only

ComputerName      IPAddress                         
------------      ---------                         
workstat123       fe80::3d0f:51a2:56b:c015%83       
workstat123       fe80::5efe:10.71.80.160%63        
workstat123       2001:4898:0:fff:0:5efe:10.71.80.160

.EXAMPLE

Get-IPAddress -IPV4only

ComputerName      IPAddress  
------------      ---------  
workstat123       10.71.80.160
.EXAMPLE
Get-IPAddress

ComputerName      IPAddress                         
------------      ---------                         
workstat123       fe80::3d0f:51a2:56b:c015%83       
workstat123       fe80::5efe:10.71.80.160%63        
workstat123       2001:4898:0:fff:0:5efe:10.71.80.160
workstat123       10.71.80.160             

.EXAMPLE

Get-IPAddress -ComputerName workstat123,W7client

ComputerName      IPAddress                           
------------      ---------                           
workstat123       fe80::3d0f:51a2:56b:c015%83         
workstat123       fe80::5efe:10.71.80.160%63          
workstat123       2001:4898:0:fff:0:5efe:10.71.80.160 
workstat123       10.71.80.160                        
W7client          2001:4898:0:fff:200:5efe:157.59.2.232
W7client          2001:4898:1c:3:1914:146:cca8:c4e9   
W7client          W7client                            
W7client          157.59.2.232

.LINK
http://gallery.technet.microsoft.com/scriptcenter/44e9fef7-a04b-40b3-bb05-97659e56e27e
#>
function global:Get-IPAddress {          
#Requires -Version 2.0

[CmdletBinding()]            
 Param             
   (                       
    [Parameter(Position=1,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [String[]]$ComputerName = $env:COMPUTERNAME,
    [Switch]$IPV6only,
    [Switch]$IPV4only
   )#End Param

Begin            
{            
 Write-Verbose "`n Checking IP Address . . .`n"
 $i = 0            
}#Begin          
Process            
{
    $ComputerName | ForEach-Object {
        $HostName = $_

        Try {
            $AddressList = @(([net.dns]::GetHostEntry($HostName)).AddressList)
        }
        Catch {
            "Cannot determine the IP Address on $HostName"
        }

        If ($AddressList.Count -ne 0)
        {
            $AddressList | ForEach-Object {
            if ($IPV6only)
                {
                    if ($_.AddressFamily -eq "InterNetworkV6")
                        {
                            New-Object psobject -Property @{
                                IPAddress    = $_.IPAddressToString
                                ComputerName = $HostName
                                } | Select ComputerName,IPAddress   
                        }
                }
            if ($IPV4only)
                {
                    if ($_.AddressFamily -eq "InterNetwork")
                        {
                              New-Object psobject -Property @{
                                IPAddress    = $_.IPAddressToString
                                ComputerName = $HostName
                               } | Select ComputerName,IPAddress   
                        }
                }
            if (!($IPV6only -or $IPV4only))
                {
                      New-Object psobject -Property @{
                        IPAddress    = $_.IPAddressToString
                        ComputerName = $HostName
                       } | Select ComputerName,IPAddress
                }
        }#IF
        }#Foreach-Object(IPAddress)
    }#Foreach-Object(ComputerName)

}#Process
}#Get-IPAddress