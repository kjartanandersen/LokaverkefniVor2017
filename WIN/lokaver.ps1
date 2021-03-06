
#$nn.Substring(3,$nn.Length - 3)


#Netkort
Rename-NetAdapter -Name "Ethernet" -NewName "LAN"
New-NetIPAddress -InterfaceAlias LAN -IPAddress 192.168.1.1 -PrefixLength 22
Set-DnsClientServerAddress -InterfaceAlias LAN -ServerAddresses 127.0.0.1

#AD
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName "kjartan.local" -InstallDns -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "pass.123" -Force)

#DHCP
Install-WindowsFeature -Name DHCP -IncludeManagementTools
Add-DhcpServerv4Scope -Name "192.168.1.0" -StartRange 192.168.1.3 -EndRange 192.168.3.254 -SubnetMask 255.255.252.0
Set-DhcpServerv4OptionValue -DnsServer 192.168.1.1 -Router 192.168.1.1
Add-DhcpServerInDC -DnsName WIN3B-06.kjartan.local

#Computer
Add-Computer -ComputerName "WIN3B-w81-06" -LocalCredential WIN3B-w81-06\Administrator -DomainName kjartan.local -Credential kjartan\Administrator -Restart -Force

#DNS Server
Add-DnsServerPrimaryZone -Name "kjartan.is" -ReplicationScope Domain
Add-DnsServerResourceRecordA -ZoneName "kjartan.is" -Name "www" -IPv4Address "10.10.0.1"
Add-DnsServerResourceRecordA -ZoneName "kjartan.is" -Name "." -IPv4Address "10.10.0.1"

#Web
Install-WindowsFeature web-server -IncludeManagementTools
New-Item "C:\inetpub\wwwroot\www.kjartan.is" -ItemType Directory
New-Item "C:\inetpub\wwwroot\www.kjartan.is\index.html" -ItemType File -Value "www.bbp.is"
New-Website -Name "www.kjartan.is" -HostHeader "www.kjartan.is" -PhysicalPath "C:\inetpub\wwwroot\www.kjartan.is\"
New-WebBinding -Name "www.kjartan.is" -HostHeader "kjartan.is" 


#Búa til OU
New-ADOrganizationalUnit -Name "Notendur" -ProtectedFromAccidentalDeletion $false
New-ADGroup -Name "Allir" -GroupScope Global -Path "ou=Notendur,dc=kjartan,dc=local"

#Import csv
$notendur = Import-Csv .\lokaverk_notendur_u.csv -Delimiter ";"

function SkodaIslenska {
    $ideft = ""
    foreach ($a in $idname.ToCharArray()) {
            $b = @{}
            $b.Add("á","a")
            $b.Add("é","e")
            $b.Add("í","i")
            $b.Add("ó","o")
            $b.Add("ú","u")
            $b.Add("ý","y")
            $b.Add("æ","a")
            $b.Add("ö","o")
            $b.Add("ð","d")
            $b.Add("þ","t")

            if ($b.ContainsKey($a.ToString())) {
                $ideft += $b[$a.ToString()]
            }
            else {
                $ideft += $a
            }
        }
        return $ideft

}


foreach ($n in $notendur)
{
    $deild = $n.Deild
    $skoli = $n.Skóli

    #Búa til OU og Group
    if ((Get-ADOrganizationalUnit -Filter {name -like $skoli}).Name -ne $skoli )
    {
        New-ADOrganizationalUnit -Name $skoli -Path ("ou=Notendur,dc=kjartan,dc=local") -ProtectedFromAccidentalDeletion $false
        New-ADGroup -Name $skoli -Path $("ou=" + $skoli + ",ou=Notendur,dc=kjartan,dc=local") -GroupScope Global
        Add-ADGroupMember -Identity "Allir" -Members $skoli
    }
}

 foreach ($n in $notendur){
    $deild = $n.Deild
    $skoli = $n.Skóli
    $GroupName = $($deild + $skoli)

    #Búa til OU og Group
    if ((Get-ADOrganizationalUnit -SearchBase $("ou=" + $skoli + ",ou=Notendur,dc=kjartan,dc=local") -Filter {name -like $deild}).Name  -ne $deild) {
        New-ADOrganizationalUnit -Name $deild -Path $("ou=" + $skoli + ",ou=Notendur,dc=kjartan,dc=local") -ProtectedFromAccidentalDeletion $false
        New-ADGroup -Name $GroupName -Path $("ou=" + $deild + ",ou=" + $skoli + ",ou=Notendur,dc=kjartan,dc=local") -GroupScope Global
        Add-ADGroupMember -Identity $skoli -Members $GroupName
    }
 }

 foreach ($n in $notendur){
    
    $deild = $n.Deild
    $skoli = $n.Skóli
    $nafn = $n.Nafn
    $idname = ((($nafn).ToLower()).Split(" ")[0]).Substring(0,2) + ((($nafn).ToLower()).Split(" ")[-1]).Substring(0,1)
    $idnameeft = SkodaIslenska

    $users = Get-ADUser -Filter *
    $arr = @()
    foreach ($b in $users)
    {
        
        $num = $b.SamAccountName.Substring(3,$b.SamAccountName.Length - 3)

        if ($b.SamAccountName.Substring(0,3) -eq $idnameeft) {
            $num = [int]$num
            $arr += $num
            
        }
    }
    $maxnum = (($arr | Measure-Object -Maximum).Count) + 1
    $idnameeft = $idnameeft + $maxnum

    if ($deild -eq "")
    {
        New-ADUser -Verbose -Name $nafn -Surname $nafn.Split(" ")[-1] -GivenName $nafn.Split(" ")[0] -HomeDrive "H:" -HomeDirectory "\\WIN3B-06\Home$\%UserName%"  -Path ("ou=" + $skoli + ",ou=Notendur,dc=kjartan,dc=local") -DisplayName $nafn -SamAccountName $idnameeft -UserPrincipalName ($idnameeft + "@kjartan.local") -Department $deild -Company $skoli -Division $skoli -AccountPassword (ConvertTo-SecureString -AsPlainText "pass.123" -Force) -Enabled $true
    }
    else {
        New-ADUser -Verbose -Name $nafn -Surname $nafn.Split(" ")[-1] -GivenName $nafn.Split(" ")[0] -HomeDrive "H:" -HomeDirectory "\\WIN3B-06\Home$\%UserName%"  -Path ("ou=" + $deild + ",ou=" + $skoli + ",ou=Notendur,dc=kjartan,dc=local") -DisplayName $nafn -SamAccountName $idnameeft -UserPrincipalName ($idnameeft + "@kjartan.local") -Department $deild -Company $skoli -Division $skoli -AccountPassword (ConvertTo-SecureString -AsPlainText "pass.123" -Force) -Enabled $true
    }
    
}
    
new-item C:\WIN3B\sameign -ItemType Directory
New-SmbShare -Name "Home$" -Path C:\WIN3B\sameign -FullAccess kjartan\Allir, administrators

$rettindi = Get-Acl -Path C:\WIN3B\sameign
$nyrettindi = New-Object System.Security.AccessControl.FileSystemAccessRule("kjartan\Allir","Modify","Allow")
$rettindi.AddAccessRule($nyrettindi)
Set-Acl -Path C:\WIN3B\sameign $rettindi

#DSC

Configuration CheckDns {
    param(
        [string[]]$ComputerName = 'localhost'
    )
    

    Node $ComputerName{

        WindowsFeature DSCServiceFeature{
            Ensure = "Present"
            Name = "DSC-Service"
        }

        Service DnsService{
            Name = "DNS"
            State = "Running"
            StartupType = "Automatic"
        }

        
    }

}
CheckDns

Start-DscConfiguration -Path .\CheckDns -Wait -Force -Verbose
#test
foreach ($n in $notendur){
 }
 foreach ($a in $users) {
 }
 foreach ($b in $users){
 }
