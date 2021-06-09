#!/usr/bin/perl
# Generate L2/L3 VPN services for Inter-AS Demo

if (!@ARGV) {
    die "\nUsage: $0 ASN PE_ID,\nwhere:\n - ASN = AS number\n - PE_ID = 0 or 1\n\n";
}

$AS=$ARGV[0];
$PB=$ARGV[1]+1;
$LB="$AS.0.0.$PB";

$x = $AS/100;
$y = ($x%2)+1;
$peer_as = $y*100;

print "edit\nrollback\n";
print <<EOF;
set interfaces ge-0/0/9 unit 10 vlan-id 10
set interfaces ge-0/0/9 unit 10 family inet address 100.15.$PB.$x/24
set interfaces ge-0/0/9 unit 10 family inet6 address 2001:100:15:$PB:\:$x/64
set interfaces ge-0/0/9 unit 10 family inet6 address ::ffff:100.15.$PB.$x/126
set interfaces ge-0/0/9 unit 10 family mpls

set protocols mpls interface ge-0/0/9.10

set protocols bgp group inter-as peer-as $peer_as
set protocols bgp group inter-as family inet-vpn unicast
set protocols bgp group inter-as family inet6-vpn unicast
set protocols bgp group inter-as neighbor 100.15.$PB.$y
set protocols bgp group inter-as import rt-update

set policy-options policy-statement rt-update term VPN-110 from community RT-VPN-110-REMOTE
set policy-options policy-statement rt-update term VPN-110 then community add RT-VPN-110
set policy-options policy-statement rt-update term VPN-120 from community RT-VPN-120-REMOTE
set policy-options policy-statement rt-update term VPN-120 then community add RT-VPN-120
set policy-options policy-statement rt-update term VPN-130 from community RT-VPN-130-REMOTE
set policy-options policy-statement rt-update term VPN-130 then community add RT-VPN-130
set policy-options community RT-VPN-110 members target:$AS:110
set policy-options community RT-VPN-120 members target:$AS:120
set policy-options community RT-VPN-130 members target:$AS:130
set policy-options community RT-VPN-110-REMOTE members target:$peer_as:110
set policy-options community RT-VPN-120-REMOTE members target:$peer_as:120
set policy-options community RT-VPN-130-REMOTE members target:$peer_as:130

EOF
print "commit and-quit\nquit\n";
