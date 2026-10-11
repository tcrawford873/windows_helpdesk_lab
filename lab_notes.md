# Lab notes

Commands and decisions, in the order I ran them.

## Q00 Setup (Oct 9, 2026)
- Laptop: Lenovo IdeaPad Flex 5, 16 GB RAM, Windows 11 Home, VirtualBox 7
- NAT Network "LabNet": 10.0.50.0/24, gateway 10.0.50.1, DHCP off
  (private range, avoids home 192.168.x.x and VirtualBox's 10.0.2.x)
- Ticket: Microsoft eval form looped in a normal window, worked in Incognito

## Q01 Domain Controller (Oct 10th 2026)
- VM DC01: Windows Server 2025 Standard Evaluation (Desktop Experience),
  4 GB RAM, 2 CPUs, 50 GB dynamic disk, adapter on LabNet
- Unattended install off, Guest Additions installed, shared clipboard on
- `Get-NetAdapter` showed the adapter is named "Ethernet" (ifIndex 6)
- Server Manager said "assigned by DHCP", but LabNet has no DHCP server,
  so it had likely given itself an APIPA (169.254.x.x) address

Static IP, temporary public DNS, rename:
```powershell
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.0.50.10 -PrefixLength 24 -DefaultGateway 10.0.50.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 1.1.1.1
Rename-Computer -NewName "DC01" -Restart
```
- Checked with `ipconfig /all`: host DC01, DHCP off, 10.0.50.10/24,
  gateway 10.0.50.1, DNS 1.1.1.1
  
### AD DS and DNS
```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName "corp.tclab.internal" -DomainNetbiosName "TCLAB" -InstallDns
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.0.50.10
Add-DnsServerForwarder -IPAddress 1.1.1.1
```
- The forwarder was already set. The promotion carried 1.1.1.1 over from the old DNS setting.

### Troubleshooting: dcdiag failures after first boot
- `dcdiag /q` failed DFSREvent and SystemLog
- SystemLog: event 5774, Netlogon couldn't register the `_ldap._tcp` SRV record at 7:15 PM (first boot)
- DFSREvent: a 6016 warning in the DFS Replication log at the same minute
```powershell
ipconfig /registerdns
Restart-Service Netlogon
Resolve-DnsName _ldap._tcp.corp.tclab.internal -Type SRV


Get-WinEvent -LogName "DFS Replication" -MaxEvents 5
```
- Result: SRV record resolves to dc01 (10.0.50.10), event 4602 shows SYSVOL initialized, and SYSVOL and NETLOGON are shared. Both errors came from the first boot, not a live problem.
- Screenshot: screenshots/01-dc-troubleshoot.png

## Q02 Client join (Oct 10, 2026)
- VM CLIENT01: Windows 11 Enterprise Evaluation, 4 GB RAM, 2 CPUs,
  64 GB dynamic disk, adapter on LabNet, local account labadmin
```powershell
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.0.50.21 -PrefixLength 24 -DefaultGateway 10.0.50.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 1.1.1.1
Set-TimeZone -Id "Pacific Standard Time"
slmgr /ato
```

### Troubleshooting
- Fresh install showed "Windows License is expired". `slmgr /dlv` said grace time expired (0xC004F009). The evaluation had never activated because the VM had no network yet. Gave it an address, ran `slmgr /ato`, now Licensed for 90 days.
- First `slmgr /ato` failed with 0x80072EE7 (name not resolved). `Test-NetConnection 1.1.1.1 -Port 53` succeeded, so routing was fine. Reran it a minute later and it worked. Likely ran before the new IP finished coming up.
- VM was very slow during the Guest Additions install. VirtualBox showed Execution Engine: native API, Nested Paging: Inactive. Hyper-V is active on the host (likely for Memory Integrity), so VirtualBox runs on top of it in a slower mode. Left it on for now.
