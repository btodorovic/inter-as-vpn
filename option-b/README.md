# Inter-AS VPN Option B

* VRFs don't need to be defined on the ASBRs.

* One single interconnection IFL used for signaling and traffic.

* Interconnecting interface MUST be MPLS-enabled:
  - [b]family mpls[/b] on the IFL, AND:
  - Interface referenced under [b]\[edit protocols mpls\][/b]

	set interfaces ge-0/0/9 unit 10 vlan-id 10
	set interfaces ge-0/0/9 unit 10 family inet address 100.15.1.1/24
	set interfaces ge-0/0/9 unit 10 family inet6 address 2001:100:15:1::1/64
	set interfaces ge-0/0/9 unit 10 family inet6 address ::ffff:100.15.1.1/126
	set interfaces ge-0/0/9 unit 10 family mpls

* BGP session - must be enabled on the interconnecting IFL, using:

	set protocols bgp group inter-as import rt-update
	set protocols bgp group inter-as family inet-vpn unicast
	set protocols bgp group inter-as family inet6-vpn unicast
	set protocols bgp group inter-as peer-as 200
	set protocols bgp group inter-as neighbor 100.15.1.2

* If IPv6 VPNs needs to be used, the IPv6-mapped IPv4 address MUST additionally be configured on the IFL - i.e.:

	set interfaces ge-0/0/9 unit 10 family inet6 address ::ffff:100.15.1.1/126

* We need a way to translate route targets from one network to the other, which can be done in several ways:
  - Adopt a common RT range and apply them to all VPNs, or:
  - Construct a BGP import policy adding locally defined RTs to all remote VPNs that need to be shared - e.g.:

	set policy-options policy-statement rt-update term VPN-110 from community RT-VPN-110-REMOTE
	set policy-options policy-statement rt-update term VPN-110 then community add RT-VPN-110
	set policy-options policy-statement rt-update term VPN-120 from community RT-VPN-120-REMOTE
	set policy-options policy-statement rt-update term VPN-120 then community add RT-VPN-120
	set policy-options policy-statement rt-update term VPN-130 from community RT-VPN-130-REMOTE
	set policy-options policy-statement rt-update term VPN-130 then community add RT-VPN-130

	# - NOTE - pay attention - on the other ASBR it's other way around
	set policy-options community RT-VPN-110 members target:100:110
	set policy-options community RT-VPN-120 members target:100:120
	set policy-options community RT-VPN-130 members target:100:130
	set policy-options community RT-VPN-110-REMOTE members target:200:110
	set policy-options community RT-VPN-120-REMOTE members target:200:120
	set policy-options community RT-VPN-130-REMOTE members target:200:130

