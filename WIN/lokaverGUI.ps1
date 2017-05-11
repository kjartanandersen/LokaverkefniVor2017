[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")


$notendur = Import-Csv .\lokaverk_notendur_u.csv -Delimiter ";"

function SkraNyanNotanda {
    $notnafn = $skranotnafn.Text
    $namefyr = ($notnafn).ToLower()
    $idnameeft = SkodaIslenska
    $notvef = $skranotvefnafn.Text
    $notdeild = $skranotdrop.Text
    $notskoli = $skranotskolidrop.Text
    $idname = ((($notnafn).ToLower()).Split(" ")[0]).Substring(0,2) + ((($notnafn).ToLower()).Split(" ")[-1]).Substring(0,1)

    #Búa til User
    if ((Get-ADUser -Filter {name -like $notnafn}).Name -ne $notnafn ) {
        
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

        write-host $idnameeft
        if ($notskoli -eq "" -and $notdeild -eq "") {
            [System.Windows.MessageBox]::Show('Verður að Skrá Skóla og deild')
        }
        else {
            New-ADUser -Verbose -Name $notnafn -Surname $notnafn.Split(" ")[-1] -GivenName $notnafn.Split(" ")[0] -HomeDrive "H:" -HomeDirectory "\\WIN3B-06\Home$\%UserName%"  -Path ("ou=" + $notdeild + ",ou=" + $notskoli + ",ou=Notendur,dc=kjartan,dc=local") -DisplayName $notnafn -SamAccountName $idnameeft -UserPrincipalName ($idnameeft + "@kjartan.local") -Department $deild -Company $skoli -Division $skoli -AccountPassword (ConvertTo-SecureString -AsPlainText "pass.123" -Force) -Enabled $true
        }

        
    }

    #Ef checkbox er checked Setja upp vefsíðu og vefsvæði
    if ($skranotcheck.Checked) {
        if (((Get-DnsServerResourceRecord -ZoneName "kjartan.is" -Name $notvef).HostName) -ne $notvef) {
        Add-DnsServerResourceRecordA -ZoneName "kjartan.is" -Name $notvef -IPv4Address "192.168.1.1"
        }

        if ((Test-Path -Path ("C:\inetpub\wwwroot\www.kjartan.is\" + $notdeild + "\" + $notvef)) -eq $false) {
            New-Item ("C:\inetpub\wwwroot\www.kjartan.is\" + $notdeild + "\" + $notvef) -ItemType Directory
            if ((Test-Path -Path ("C:\inetpub\wwwroot\www.kjartan.is\" + $notdeild +"\" + $notvef + "\index.html")) -eq $false) {
                New-Item ("C:\inetpub\wwwroot\www.kjartan.is\" + $notdeild +"\" + $notvef + "\index.html") -ItemType File -Value ($notvef + ".bbp.is")
            }
        }

        if (((Get-Website -Name ($notvef + ".kjartan.is")).Name) -ne ($notvef + ".kjartan.is")) {
            New-Website -Name ($notvef + ".kjartan.is") -HostHeader ($notvef + ".kjartan.is") -PhysicalPath ("C:\inetpub\wwwroot\www.kjartan.is\" + $notdeild + "\" + $notvef + "\")
        }

    }
}




$deildarr = @()
$skoliarr = @()
foreach ($a in $notendur) {
    $deild = $a.Deild
    $skoli = $a.Skóli

    if ($deild -eq "") {

    }
    else
    {
        if ((Get-ADOrganizationalUnit -Filter {name -like $deild}).Name -eq $deild) {
            if ($deildarr -like $deild) {
            }
            else {
                $deildarr += $deild
            }
        }
    }
    if ($skoli -eq "") {

    }
    else
    {
        if ((Get-ADOrganizationalUnit -Filter {name -like $skoli}).Name -eq $skoli) {
            if ($skoliarr -like $skoli) {
            }
            else {
                $skoliarr += $skoli
            }
        }
    }
}


#Aðalglugginn 
$skranot = New-Object System.Windows.Forms.Form
$skranot.ClientSize = New-Object System.Drawing.Size(550,150)
$skranot.Text = "Skrá nýan notanda"

#Nafn innsláttarsvæði
$skranotnafn = New-Object System.Windows.Forms.TextBox
$skranotnafn.Location = New-Object System.Drawing.Point(80,20)
$skranotnafn.Size = New-Object System.Drawing.Size(210,30)
$skranot.Controls.Add($skranotnafn)

#Nafn Vefslóð
$skranotvefnafn = New-Object System.Windows.Forms.TextBox
$skranotvefnafn.Location = New-Object System.Drawing.Point(120,120)
$skranotvefnafn.Size = New-Object System.Drawing.Size(210,30)
$skranot.Controls.Add($skranotvefnafn)

#Nafn label
$skranotnafnlb = New-Object System.Windows.Forms.Label
$skranotnafnlb.Location = New-Object System.Drawing.Point(10,25)
$skranotnafnlb.Size = New-Object System.Drawing.Size(40,22)
$skranotnafnlb.Text = "Nafn"
$skranot.Controls.Add($skranotnafnlb)

#Nafn Vefslóð label
$skranotvefnafnlb = New-Object System.Windows.Forms.Label
$skranotvefnafnlb.Location = New-Object System.Drawing.Point(10,124)
$skranotvefnafnlb.Size = New-Object System.Drawing.Size(80,22)
$skranotvefnafnlb.Text = "Nafn Vefslóð"
$skranot.Controls.Add($skranotvefnafnlb)

#Dropbox
$skranotdrop = New-Object System.Windows.Forms.ComboBox
$skranotdrop.Location = New-Object System.Drawing.Point(10,50)
$skranotdrop.Size = New-Object System.Drawing.Size(180,30)
foreach ($deildir in $deildarr) {
    $skranotdrop.Items.Add($deildir)
}
$skranot.Controls.Add($skranotdrop)

#Dropbox skoli
$skranotskolidrop = New-Object System.Windows.Forms.ComboBox
$skranotskolidrop.Location = New-Object System.Drawing.Point(10,80)
$skranotskolidrop.Size = New-Object System.Drawing.Size(180,30)
foreach ($skolar in $skoliarr) {
    $skranotskolidrop.Items.Add($skolar)
}
$skranot.Controls.Add($skranotskolidrop)


#Dropbox label
$skranotdroplb = New-Object System.Windows.Forms.Label
$skranotdroplb.Location = New-Object System.Drawing.Point(200,57)
$skranotdroplb.Size = New-Object System.Drawing.Size(100,20)
$skranotdroplb.Text = "Veldu Deild"
$skranot.Controls.Add($skranotdroplb)

#Dropbox label skoli
$skranotdropskolilb = New-Object System.Windows.Forms.Label
$skranotdropskolilb.Location = New-Object System.Drawing.Point(200,87)
$skranotdropskolilb.Size = New-Object System.Drawing.Size(100,20)
$skranotdropskolilb.Text = "Veldu Deild"
$skranot.Controls.Add($skranotdropskolilb)


#Checkbox
$skranotcheck = New-Object System.Windows.Forms.CheckBox
$skranotcheck.Location = New-Object System.Drawing.Point(480,20)
$skranotcheck.Size = New-Object System.Drawing.Size(20,20)
$skranot.Controls.Add($skranotcheck)

#Checkbox label
$skranotchecklb = New-Object System.Windows.Forms.Label
$skranotchecklb.Location = New-Object System.Drawing.Point(420,24)
$skranotchecklb.Size = New-Object System.Drawing.Size(80,20)
$skranotchecklb.Text = "Vefsvæði?"
$skranot.Controls.Add($skranotchecklb)

#Button
$skranotbt = New-Object System.Windows.Forms.Button
$skranotbt.Location = New-Object System.Drawing.Point(300,50)
$skranotbt.Size = New-Object System.Drawing.Size(100,20)
$skranotbt.Text = "Keyra"
$skranotbt.add_Click({ SkraNyanNotanda })
$skranot.Controls.Add($skranotbt)

#Sýna Form
$skranot.ShowDialog()
