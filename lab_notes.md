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
  
