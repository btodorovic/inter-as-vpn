#!/usr/bin/perl
# Generate L2/L3 VPN services for Inter-AS Demo

if (!@ARGV) {
    die "\nUsage: $0 ASN,\nwhere:\n - ASN = AS number\n\n";
}

$AS=$ARGV[0];

print "edit\nrollback\n";
for ($i=10; $i<40; $i+=10) {
    $a = 100+$i;
    $b = 200+$i;
    $vpn_a = sprintf ("VR-%d", $a);
    $vpn_b = sprintf ("VR-%d", $b);
    $vlan = 100+$i;
    $local_as = 100+$i;

    print <<EOF;
set interfaces lo0 unit $a family inet address $AS.$a.1.1/32
set interfaces lo0 unit $a family inet6 address 2$AS:$a:\:1/128
set interfaces lo0 unit $b family inet address $AS.$b.1.1/32
set interfaces lo0 unit $b family inet6 address 2$AS:$b:\:1/128
set interfaces ge-0/0/1 unit $vlan vlan-id $vlan
set interfaces ge-0/0/1 unit $vlan family inet address $AS.$AS.$a.2/24
set interfaces ge-0/0/1 unit $vlan family inet6 address 2001:$AS:$AS:$a:\:2/64
set interfaces ge-0/0/2 unit $vlan vlan-id $vlan
set interfaces ge-0/0/2 unit $vlan family inet address $AS.$AS.$b.2/24
set interfaces ge-0/0/2 unit $vlan family inet6 address 2001:$AS:$AS:$b:\:2/64

set routing-instances $vpn_a instance-type virtual-router
set routing-instances $vpn_a interface lo0.$a
set routing-instances $vpn_a interface ge-0/0/1.$vlan
set routing-instances $vpn_a routing-options autonomous-system $local_as independent-domain
set routing-instances $vpn_a routing-options static route $AS.$a.0.0/16 discard
set routing-instances $vpn_a routing-options rib $vpn_a.inet6.0 static route 2$AS:$a:\:/32 discard
set routing-instances $vpn_a protocols bgp group ebgp-vpn peer-as $AS
set routing-instances $vpn_a protocols bgp group ebgp-vpn export advertise
set routing-instances $vpn_a protocols bgp group ebgp-vpn neighbor $AS.$AS.$a.1

set routing-instances $vpn_a protocols bgp group ebgp-vpnv6 peer-as $AS
set routing-instances $vpn_a protocols bgp group ebgp-vpnv6 export advertise
set routing-instances $vpn_a protocols bgp group ebgp-vpnv6 neighbor 2001:$AS:$AS:$a:\:1

set routing-instances $vpn_b instance-type virtual-router
set routing-instances $vpn_b interface lo0.$b
set routing-instances $vpn_b interface ge-0/0/2.$vlan
set routing-instances $vpn_b routing-options autonomous-system $local_as independent-domain
set routing-instances $vpn_b routing-options static route $AS.$b.0.0/16 discard
set routing-instances $vpn_b routing-options rib $vpn_b.inet6.0 static route 2$AS:$b:\:/32 discard
set routing-instances $vpn_b protocols bgp group ebgp-vpn peer-as $AS
set routing-instances $vpn_b protocols bgp group ebgp-vpn export advertise
set routing-instances $vpn_b protocols bgp group ebgp-vpn neighbor $AS.$AS.$b.1

set routing-instances $vpn_b protocols bgp group ebgp-vpnv6 peer-as $AS
set routing-instances $vpn_b protocols bgp group ebgp-vpnv6 export advertise
set routing-instances $vpn_b protocols bgp group ebgp-vpnv6 neighbor 2001:$AS:$AS:$b:\:1

set policy-options policy-statement advertise from protocol static
set policy-options policy-statement advertise then accept

EOF
}
print "commit and-quit\nquit\n";
