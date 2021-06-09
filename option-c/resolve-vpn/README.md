# Inter-AS Option C - with 'resolv-vpn' option

Example how we configure Inter-AS Option C using inet.0 for BGP-LU NHs, with copy into inet.3.
Key elements of the configuration are:

<pre>
protocols {
    bgp
        group rr {
            family inet {
                labeled-unicast resolve-vpn;
            }
        }
    }
}
</pre>

This needs to be configured on all PE routers, ASBRs ("mm" in this example).

## RR Configuration

* We don't configure MPLS and LDP on the RR.
* Core-facing interfaces MUST have "family mpls" defined, though.
* The **resolve-vpn** knob is NOT NEEDED!
* We configure RR to use inet.0 to resolve L2/L3 VPN routes:

<pre>
routing-options
    rib inet6.3 {
        static {
            route ::0/0 discard;     ### required for 6PE and 6VPE NHs to get resolved
        }
    }
    resolution {
        rib bgp.l3vpn.0 {
            resolution-ribs inet.0;  ### uses inet.0 for NH resolution for L3VPNs
        }
        rib bgp.l2vpn.0 {
            resolution-ribs inet.0;  ### uses inet.0 for NH resolution for L2VPNs
        }
    }
}
</pre>

## Caveats

* All services work.
* Static route for RRs MUST be defined on the ASBRs and redistribute into IGP for MP-EBGP-MH to work.

