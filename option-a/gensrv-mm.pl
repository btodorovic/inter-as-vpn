#!/usr/bin/perl
# Generate L2/L3 VPN services for Inter-AS Demo

if (!@ARGV) {
    die "\nUsage: $0 ASN PE_ID,\nwhere:\n - ASN = AS number\n - PE_ID = 0 or 1\n\n";
}

$AS=$ARGV[0];
$PB=$ARGV[1]+1;
$LB="$AS.0.0.$PB";

print "edit\n";
for ($i=10; $i<40; $i+=10) {
    $vpn = sprintf ("VPN-1%d", $i);
    $ip3=($ARGV[1]+1)*100+$i;
    $vlan = 100+$i;
    $x = $AS/100;
    $y = ($x%2)+1;
    $peer_as = $y*100;

    print <<EOF;
set interfaces ge-0/0/9 unit $vlan vlan-id $vlan
set interfaces ge-0/0/9 unit $vlan family inet address 100.15.$ip3.$x/24
set interfaces ge-0/0/9 unit $vlan family inet6 address 2001:100:15:$ip3:\:$x/64

set routing-instances $vpn instance-type vrf
set routing-instances $vpn vrf-table-label
set routing-instances $vpn interface ge-0/0/9.$vlan
set routing-instances $vpn route-distinguisher $LB:$vlan
set routing-instances $vpn vrf-import $vpn-IMPORT
set routing-instances $vpn vrf-export $vpn-EXPORT
set routing-instances $vpn protocols bgp group ebgp-vpn peer-as $peer_as
set routing-instances $vpn protocols bgp group ebgp-vpn as-override
set routing-instances $vpn protocols bgp group ebgp-vpn neighbor 100.15.$ip3.$y
set routing-instances $vpn protocols bgp group ebgp-vpnv6 peer-as $peer_as
set routing-instances $vpn protocols bgp group ebgp-vpnv6 neighbor 2001:100:15:$ip3:\:$y
set routing-instances $vpn protocols bgp group ebgp-vpnv6 as-override

set policy-options policy-statement $vpn-EXPORT term export then community add RT-$vpn
set policy-options policy-statement $vpn-EXPORT term export then accept
set policy-options policy-statement $vpn-EXPORT then reject
set policy-options policy-statement $vpn-IMPORT term import from community RT-$vpn
set policy-options policy-statement $vpn-IMPORT term import then accept
set policy-options policy-statement $vpn-IMPORT then reject
set policy-options community RT-$vpn members target:$AS:$vlan

EOF
}
print "commit and-quit\nquit\n";
