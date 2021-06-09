# Inter-AS Option C - without inet.3

Example how we configure Inter-AS Option C using inet.0 resolution only.
Key elements of the configuration are: 

<pre>
routing-options {                    ### PE and ASBR routers only
    resolution {
        rib bgp.l3vpn.0 {
            resolution-ribs inet.0;  ### uses inet.0 for NH resolution for L3VPNs
        }
        rib bgp.l2vpn.0 {
            resolution-ribs inet.0;  ### uses inet.0 for NH resolution for L2VPNs
        }
        rib mpls.0 {
            resolution-ribs inet.0;  ### uses inet.0 for NH resolution for VPLS LSIs
        }
        rib l2circuit.0 {
            resolution-ribs inet.0;  ### uses inet.0 for NH resolution for L2CKTs
        }
    }
}
protocols {                          ### All routers (core included)
    mpls {
        traffic-engineering bgp-igp; ### Moves all LDP routes into inet.0
    }
}
</pre>

There is no **resolve-vpn** under **[edit protocols bgp group <*> family inet labeled-unicast]**.
	
## Caveats

* IPv4 L3VPNs work
* IPv6 L3VPNs don't work, "::FFFF:.*" NH resolution from inet6.0 doesn't work
* VPLS work
* L2CKTs don't work
* EVPN - not tested
