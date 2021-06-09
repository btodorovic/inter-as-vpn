# Inter-AS Option C - with RIB-Groups

Example how we configure Inter-AS Option C using inet.3 for BGP-LU NHs, with copy into inet.0 using rib-groups.
This is the classical setup, recommended by Juniper. It works fine in 99% of use cases.
However, when using Internet GRT in a VRF, this has shown to cause BGP convergence issues.
Key elements of the configuration are (see full router configurations for more explanation):

**PE and ASBR Routers**:
<pre>
routing-options {
    interface-routes {
        rib-group inet RG-LOCAL-LOOPBACKS;
    }
    rib-groups {
        RG-LOCAL-LOOPBACKS {
            import-rib [ inet.0 inet.3 ];
            import-policy PL-MY-LOCAL-LOOPBACK;
        }
        RG-REMOTE-LOOPBACKS {
            import-rib [ inet.3 inet.0 inet6.3 ];  ### inet6.3 needed for 6PE/6VPE NHs to get resolved
            import-policy PL-REMOTE-LOOPBACKS;
        }
    }
}
protocols {
    bgp
        group rr {
            family inet {
                unicast;
                labeled-unicast {
                    rib-group RG-REMOTE-LOOPBACKS;
                    aigp;
                    rib {
                        inet.3;
                    }
                }
            }
            export [ lu-int nhs bgp ];
        }
    }
}
policy-options {
    policy-statement PL-MY-LOCAL-LOOPBACK {
        term LOCAL-LOOPBACKS {
            from {
                interface lo0.0;
                route-filter 0.0.0.0/0 prefix-length-range /32-/32;
            }
            to rib inet.3;
            then {
                metric 0;
                origin incomplete;
                next-hop self;
                accept;
            }
        }
        then reject;
    }
    policy-statement PL-REMOTE-LOOPBACKS {
        term REMOTE-LOOPBACKS {
            from {
                rib inet.0;
                route-filter <remote-lo0-range> prefix-length-range /32-/32;
            }
            then accept;
        }
        then reject;
    }
    policy-statement lu-int {
        term lu-int {
            from {
                protocol direct;
                rib inet.3;
                route-filter 100.0.0.0/24 prefix-length-range /32-/32;
            }
            then {
                metric 0;
                aigp-originate;
                next-hop self;
                accept;
            }
        }
        then next policy;
    }
}
</pre>

## RR Configuration

* We configure MPLS and LDP on the RR (although we can do it without - see ../resolve-vpn for inet.0-solution on RR only).

## Caveats

* All services work.

