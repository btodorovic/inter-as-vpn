# Inter-AS Option A

* Simplest concept - in each AS remote ASBR acts as a CE wrt the local ASBR

* All VRFs required to be shared beteen two AS'ems need to be defined on the ASBRs.

* Interconnecting interface is TAGGED (using IEEE 802.1Q VLAN tagging or flexible-vlan-tagging):
  - One IFL/VLAN per each VRF.
  - Limited by the amount of IFLs - currently up to 128,000 IFLs per each IFD

* Within each individual VRF we run a BGP session to exchange prefixes.

* Prefixes exchanged between ASBRs are automatically imported into the target VRFs on either side.

