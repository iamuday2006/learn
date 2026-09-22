# 05 — Network Layer (Routing, IP, Addressing, Subnetting)

> Reference: Kurose & Ross Ch. 4 (network layer & routing: control/data plane, OSPF/BGP, IP, IPv6) + classic syllabus (classful, subnetting numericals). | TODO Chapter 5 §5.1–5.5 | Priority: **MUST KNOW** — subnetting is a guaranteed numerical

---

## 5.1 Network Layer

### Purpose of Network Layer

Layer 3 — **source-to-destination (host-to-host) delivery of packets across multiple interconnected networks** (the path may cross many LANs, WANs, routers). Where the data link layer moves a frame *one hop*, the network layer moves a packet *the whole way* from end host (or ingress router) to the correct destination host anywhere on the internetwork.

Two orthogonal jobs (Kurose's data-plane / control-plane split):

- **Forwarding** — the *data plane*: each router's local action of moving an arriving packet from its input link to the correct output link using its **forward (match+action) table**.
- **Routing** — the *control plane*: the *network-wide* process of determining the end-to-end paths packets take, distributed via routing protocols; results installed into forwarding tables.

Plus: **logical (IP) addressing**, **congestion control** at this level (in some designs/QoS), fragmentation (IPv4), and error/control reporting (**ICMP**).

> Interview answer: "The network layer provides host-to-host delivery across networks. Routers forward packets hop by hop based on tables computed by routing protocols; each packet carries a logical IP address that stays the same end to end while link-layer headers change at every hop."

### Routing

The **global decision**: which path (sequence of routers/links) each packet should take from source to destination. Implemented by **routing protocols** populating routers' tables:

- Goal: correct (reach destination), loop-free, low-cost/low-delay, adapt to failures/congestion, scale to hundreds of thousands of prefixes, distribute load (ECMP).
- Families: static vs dynamic; intra-domain (OSPF, RIP) vs inter-domain (BGP); algorithms: distance-vector, link-state — §5.2.
- Routing decides **which output interface** (next hop) for each destination prefix — that's then used by forwarding.

### Forwarding

The **local, per-router action**: upon packet arrival at a link, router looks up the packet's destination IP in its **forwarding table** (often called routing table / FIB) and sends it out the matched output interface toward the next hop — at line rate in hardware (ASIC/TCAM for switches/routers).

- Match fields: destination prefix (longest prefix match); may also match on source, ports, ToS (ACL/firewall policy).
- Also decrements **TTL** (drops at 0, sends ICMP Time Exceeded), recomputes/validates header checksum (IPv4), fragments if needed & DF not set, re-encapsulates in new **link-layer frame** for the outgoing interface (new src/dst MAC, new FCS).

### Routing vs Forwarding (classic exam table)

| Basis | Routing | Forwarding |
|---|---|---|
| Scope | Global, network-wide | Local, single router |
| Plane | Control plane | Data plane |
| Question | "What is the best path src→dst?" | "For *this* arriving packet, which output port?" |
| Who/what | Routing protocols (OSPF/BGP/RIP), algorithms | Forwarding table lookup + switch fabric |
| Frequency | Periodic/event-driven (topology change) | Every packet, every nanosecond |
| Software | Routing software, convergence over seconds | Hardware lookup at line rate |
| Analogy | GPS planning the whole route across cities | At each junction, "take next exit toward Pune" |

### Router

The layer-3 device that implements forwarding + runs routing protocols:

- Interfaces each sit in **their own broadcast + collision domain**; joins different networks (LAN↔LAN, LAN↔WAN).
- Per packet: lookup (longest prefix) → TTL decrement → checksum/option processing → fragmentation if required → **new L2 encapsulation per hop** → queue/schedule out the chosen port (drops + signals congestion if queue full).
- Runs control protocols: **RIP/OSPF/BGP** (routes), **ICMP/ARP** (control/adjacent resolution), DHCP relay, NAT/firewall sometimes.
- Home "router" = router + switch + Wi-Fi AP + NAT + DHCP server + firewall in one box.

### Routing table

The router's lookup database — key fields:

| Field | Meaning |
|---|---|
| Destination prefix (e.g., 192.168.1.0/24) | Match this prefix in packet's dst IP |
| Next hop (e.g., 10.0.0.1) | Where to forward toward that prefix (or "directly connected") |
| Interface (e.g., eth0) | Output port |
| Metric (cost/hop count/delay) | Preference among equal prefixes (higher protocol preference first: static > OSPF > RIP typical) |
| AD / protocol source | Administrative distance — trust ranking of the source that learned the route |
| Age/uptime | Freshness of the entry |

Lookup rule: **longest prefix match** — if packet dst matches multiple rows, choose the *most specific* (longest) prefix; default route 0.0.0.0/0 is the last resort ("gateway of last resort").

---

## 5.2 Routing Algorithms

### Routing algorithm concept
The strategy that computes loop-free, preferably optimal paths from sources to destinations given topology (graph: nodes=routers, edges=links with costs) and dynamics (failures, load). Trade-offs across optimality, simplicity, message overhead (control traffic), speed of convergence, scalability.

### Static routing
- Routes **manually configured** by an administrator (no protocol chatter).
- **Pros:** simple, zero overhead, predictable, secure (no route injection), good for stub networks/small tops/defaults.
- **Cons:** no adaptivity — failures require manual fixes; doesn't scale; human error prone.
- Use: small stable networks, default/static defaults as backup, lab setups, policy routes with fixed next hops.

### Dynamic routing
- Routes learned automatically via **routing protocols** exchanging reachability (and metrics) with neighbours; tables recompute on topology/cost changes (**convergence**).
- **Pros:** adapts to failures/congestion, scales, load balances, self-heals.
- **Cons:** protocol overhead (CPU/bandwidth), convergence time, possible loops/transients, more complexity/attack surface (route hijacking — needs authentication).
- Use: essentially every real multi-router network (OSPF/EIGRP/BGP/RIP).

### Centralized routing
- A **single central controller/compute** has global topology view (all links, states, policies), runs the algorithm centrally, and **pushes forwarding entries** to routers.
- Examples: **SDN** (OpenFlow-style: controller programs switches), classic ARPANET initial link-state-ish centralized compute, some traffic-engineering systems.
- **Pros:** global optimum (TE, wavelength assignment), simplified router software, easy policy.
- **Cons:** controller is a **single point of failure/scalability bottleneck**; latency to react; needs secure, fast control-channel (controllers often replicated for HA).

### Distributed routing
- Each router **participates**: runs a protocol, exchanges messages **with neighbours only**, computes its own next hops from distributed info (or flooded LSDB).
- Examples: **RIP (distance vector), OSPF (link state), BGP (path vector)** — the Internet's actual model.
- **Pros:** no central SPOF, robust to single failures, scales naturally with decentralized load; matches the Internet's decentralized ownership.
- **Cons:** slower/less-global optimality than a central TE brain; protocol overhead everywhere; convergence and loop dangers (count-to-infinity, transient microloops) must be handled by design.

### Distance Vector (DV)

- Each router maintains a table of **best-known distance (cost/hops/delay) to every destination + next hop toward it** — its "vector" of distances.
- Periodically (or on change) router **sends its whole table to direct neighbours**; neighbour runs **Bellman-Ford update**: `D_x(y) = min_v { c(x,v) + D_v(y) }` — if a better path via neighbour v appears, replace next hop with v.
- "Routing by rumor / distributed Bellman-Ford": knowledge is *iteratively refined hop by hop*; routers don't know the full topology — only accumulated costs via neighbours.
- **Pros:** simple, lightweight messages (tables to neighbours only), no topology database.
- **Cons:** slow convergence (**count-to-infinity** problem on link failure — split horizon / poisoned reverse / hold-down mitigate); loop-prone during convergence; metric limited (hops/delay); scales poorly (whole-table chatter every 30 s — RIP).
- Example protocol: **RIP (Routing Information Protocol)** — metric = hop count, max 15 hops, split horizon & poison reverse, 30 s updates.

### Link State (LS)

- Each router **floods** its own link info (neighbours + costs) to **every router in the area/domain** → each builds an identical **complete topology map (link-state database)**.
- Then each router **independently runs Dijkstra's SPF** on the same graph to compute shortest-path tree to all destinations, installs best next hops.
- Events (link up/down) trigger immediate **flooding of LSAs**, not periodic full tables — fast, precise convergence.
- **Pros:** fast convergence (seconds), loop-free (SPF from same fresh LSDB), precise metrics (cost/bandwidth), scales better than DV within an area, each router sees full topology for TE decisions.
- **Cons:** memory (full graph), CPU (Dijkstra recompute), flooding overhead on every event (mitigated by areas — OSPF areas).
- Example protocol: **OSPF (Open Shortest Path First)** — Dijkstra SPF, areas/hierarchy, cost = reference_bw/interface_bw, authentication, ECMP.

### Routing algorithm comparison

| Basis | Distance Vector | Link State |
|---|---|---|
| Knowledge | Distances via neighbours ("routing by rumor") | Full topology map at every router |
| Algorithm | Bellman-Ford (distributed) | Dijkstra SPF (local, after flood) |
| Updates | Whole/partial table to neighbours periodically | Flood LSAs on change (event-driven) |
| Convergence | Slow (count-to-infinity) | Fast (seconds, SPF rerun) |
| Loop risk during convergence | Higher (needs split horizon etc.) | Low (single consistent LSDB) |
| Overhead | Small messages, constant chatter | Big LSA floods, but only on changes |
| Scalability | Poor (RIP ≤15 hops) | Better (OSPF areas, IS-IS levels) |
| Example | RIP, IGRP | OSPF, IS-IS, (EIGRP = hybrid/advanced DV) |

*(BGP sits above both as **path vector** — full AS-path list to prevent inter-domain loops + policy — the Internet's glue between autonomous systems.)*

---

## 5.3 IP — Internet Protocol

### Internet Protocol
The universal network-layer protocol of the Internet — a **best-effort, connectionless, packet-switched datagram service** delivered from host to host regardless of transport/app above. Every packet routed independently; recovery/reliability is the transport's job (TCP). IP = addresses + header + fragmentation + TTL + forwarding semantics — nothing more (no QoS guarantee, no security built in originally).

Version in use: **IPv4** (1981, RFC 791) transitioning to **IPv6** (1998, RFC 2460/8200).

### IPv4

- **32-bit** address written as four decimal octets: `192.168.10.7` (dotted decimal) = `11000000.10101000.00001010.00000111`.
- **Connectionless datagram:** each packet carries full source + destination address; no session setup; may be lost, reordered, duplicated, delayed — tolerated by design (simple core).
- **Fragmentation & reassembly:** if a packet exceeds the outgoing link's **MTU** (e.g., 1500 B Ethernet) and DF (Don't Fragment) not set, router **splits into fragments** (each with its own header: same ID, new fragment offset, MF flag); **only the destination host reassembles** (intermediate routers typically don't). DF=1 + packet > MTU → router drops & sends **ICMP "Fragmentation Needed (DF set)"** (Path MTU Discovery).
- **Header checksum:** covers **only the header** (payload checked by transport/link CRC); recomputed at each hop (because TTL/offset change).
- **TTL (Time To Live):** decremented at each router; at 0 the packet is discarded + **ICMP Time Exceeded** — bounds packet lifetime, is the core of `traceroute`.
- Options (record route, timestamp, security) mostly unused in practice.

### IPv4 packet/header (20-byte minimum + options)

```text
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|Version|  IHL  |    DSCP/ECN   |         Total Length          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         Identification        |Flags|     Fragment Offset     |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Time to Live |    Protocol   |       Header Checksum         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Source Address                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Destination Address                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Options (if IHL>5)             |  Padding  |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

Key fields:
- **Version** (4) + **IHL** (header length in 32-bit words; 5 = 20 B min).
- **Total Length** — whole packet bytes (header+payload).
- **Identification + Flags (DF/MF) + Fragment Offset** — fragmentation control (offset in 8-byte units).
- **TTL** — hop limit; **Protocol** — next header (6=TCP, 17=UDP, 1=ICMP, 89=OSPF…).
- **Header Checksum** — header integrity only.
- **Src/Dst IP** — end-to-end logical addresses (unchanged end to end, except NAT rewriting!).

### IPv6

- **128-bit** address → 2^128 addresses (~3.4×10³8) — solves IPv4 exhaustion, enables end-to-end addressing of every device/IoT.
- Written **hex, 8 groups of 4 digits, colon-separated**: `2001:0db8:85a3:0000:0000:8a2e:0370:7334` — compression rules: leading zeros per group dropped, one all-zero group → `::` (only once): `2001:db8:85a3::8a2e:370:7334`.
- **Simplified fixed 40-byte header** (no header checksum, no fragmentation by routers — source does path-MTU fragmentation only; no options in base header — extensions appended as "next header" chain).
- **Mandatory IPsec** support (in architecture; use optional in practice), always-on multicast instead of broadcast (no broadcasts → less noise), **stateless address autoconfiguration (SLAAC)** + DHCPv6, **flow-label** field for fast path/QoS, noARP→**NDP (Neighbor Discovery Protocol)** replaces ARP/ICMP-redirect/ICMP-router-discovery.
- Transition: dual-stack (run both), tunneling (6-in-4, 6to4, Teredo), translation (NAT64/DNS64).

### IPv6 packet/header (fixed 40 B)

```text
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|Version| Traffic Class |           Flow Label                  |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         Payload Length        |  Next Header  |   Hop Limit   |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+                         Source Address (128b)                 +
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+                      Destination Address (128b)               +
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

- **Traffic Class + Flow Label** — mark "flows" for fast per-flow scheduling (router hashes flow label instead of parsing 5-tuple).
- **Hop Limit** — the renamed TTL; **Next Header** — same chaining idea (TCP, extension hdr, etc.).
- **No:** IHL, flags/fragment fields (in base), header checksum — all moved/removed for faster per-hop processing.

### IPv4 vs IPv6 (core comparison)

| Basis | IPv4 | IPv6 |
|---|---|---|
| Address length | 32 bit (~4.3 B addrs) | 128 bit (~3.4×10³⁸) |
| Notation | Dotted decimal (192.168.1.1) | Hex colon groups (`2001:db8::1`) |
| Header size | 20–60 B variable | Fixed 40 B (+ extension headers) |
| Header checksum | Yes (recomputed per hop) | **None** (relies on link/transport) |
| Fragmentation | Routers + hosts | **Source only** (router sends PTB ICMPv6) |
| Broadcast | Yes | **No** (multicast + anycast) |
| Address config | Manual/DHCP | SLAAC + DHCPv6 |
| ARP / ICMP roles | ARP separate, ICMPv4 | **NDP** (ICMPv6-based), no ARP |
| Security/IPsec | Optional | Built into architecture |
| NAT needed (address scarcity) | Commonly yes | Not needed (address-rich) |
| QoS/flow support | TOS byte (limited) | Traffic Class + **Flow Label** |
| Header processing | More fields, slower per hop | Streamlined for hardware |
| Examples | Still dominant today | Deployed everywhere new (cloud/mobile default) |

Full exam table (with transition mechanisms): [10-final-exam-prep.md](10-final-exam-prep.md).

---

## 5.4 IP Addressing

### IP address concept
A **logical, hierarchical, software-assigned** identifier attached to a network interface, unique **within its routing scope** (globally public / per private network), used by routers to deliver packets to the right network then the right host. Two conceptual parts:

### Network ID (netid / prefix)
Identifies the **physical network/subnet** the host belongs to — the part routers use to forward to the correct network ("which street"). All hosts on the same subnet share the same network ID (given the same mask).

### Host ID (hostid / host part)
Identifies the **specific host/interface** within that network ("which house number") — unique only inside the subnet; local switches/ARP resolve it to a MAC on the final hop.

```text
          IP address  =  network ID  |  host ID
 example 192.168.1.105 with /24 mask:
          netid = 192.168.1.0        hostid = .105
          (routers route to 192.168.1.0/24, local ARP finds host .105)
```

### IPv4 address format
- 32 bits = 4 octets, each 0–255, dotted decimal for humans (`10.20.30.40`), binary for machines.
- Written with prefix length / mask: `172.16.5.4/16` ⇒ first 16 bits = network.

### Classful addressing (legacy A/B/C/D/E — still taught & tested)

Fixed class boundaries by the **leading bits of the first octet** (default masks follow):

| Class | First octet range | Leading bits | Default mask | Host bits | # networks | # hosts/network | Purpose |
|---|---|---|---|---|---|---|---|
| **A** | 1 – 126 | 0 | **255.0.0.0 (/8)** | 24 | 2⁷ = 126 | 2²⁴−2 ≈ 16.7 M | Very large orgs |
| **B** | 128 – 191 | 10 | **255.255.0.0 (/16)** | 16 | 2¹⁴ = 16384 | 2¹⁶−2 = 65534 | Medium orgs/universities |
| **C** | 192 – 223 | 110 | **255.255.255.0 (/24)** | 8 | 2²¹ ≈ 2.1 M | 2⁸−2 = 254 | Small networks |
| **D** | 224 – 239 | 1110 | — | — | — | — | **Multicast** groups (not host addresses) |
| **E** | 240 – 255 | 1111 | — | — | — | — | **Experimental/reserved** (future use) |

Notes:
- `127.x.x.x` (esp. **127.0.0.1**) is loopback **inside class A** but reserved for testing — not a usable network.
- Class **D/E excluded** from normal host addressing; "minus 2" for network (all-zeros) & broadcast (all-ones) addresses per subnet.
- Classful = **wasteful** (class B to a company with 300 hosts wastes 65k addresses) → drives **CIDR + subnetting** (§5.5).

### Class A / B / C / D / E (quick recall)

- **Class A:** `/8`, huge host space per net (16 M), few networks — `1.0.0.0 – 126.0.0.0`, mask 255.0.0.0. Example nets: `10.x.x.x` private.
- **Class B:** `/16`, 65k hosts per net, 16k nets — `128.1.0.0 – 191.255.0.0`, mask 255.255.0.0. Example: `172.16.x.x` private range.
- **Class C:** `/24`, 254 hosts per net, ~2.1M nets — `192.0.0.0 – 223.255.255.0`, mask 255.255.255.0. Example: `192.168.x.x` private range.
- **Class D:** `224.0.0.0 – 239.255.255.255` — **multicast** (one-to-many: 224.0.0.5 = OSPF routers, 239.x.x.x admin-scoped); no host ID structure like A/B/C; membership via IGMP.
- **Class E:** `240.0.0.0 – 255.255.255.255` — reserved/experimental (255.255.255.255 = limited broadcast inside class E); not assignable.

### Public IP
- **Globally routable** on the public Internet; administered by IANA → RIRs (APNIC, RIPE, ARIN…) → ISPs → customers.
- Unique across the world; directly reachable without translation (though most home traffic still passes NAT at the edge router).
- Must be requested/leased (costly) → another driver for private addressing + NAT.

### Private IP (RFC 1918)
- **Not routable on the public Internet** — free, reusable inside any org/home; edge router uses **NAT** to share public addresses.

| Class | Private ranges | CIDR block |
|---|---|---|
| A | 10.0.0.0 – 10.255.255.255 | **10.0.0.0/8** |
| B | 172.16.0.0 – 172.31.255.255 | **172.16.0.0/12** |
| C | 192.168.0.0 – 192.168.255.255 | **192.168.0.0/16** |

- Carriers/CGNAT also use `100.64.0.0/10` (RFC 6598) internally; `169.254.x.x` = link-local self-assigned (APIPA) when no DHCP.

### Loopback
- `127.0.0.0/8` — the whole 127/8 reserved; `127.0.0.1` = "this machine" on the **loopback interface** — never leaves the host stack.
- Uses: OS/network-stack self-test (`ping 127.0.0.1`), local services bound to localhost only (dev servers, databases), RPC/local IPC over TCP/IP.
- IPv6 equivalent: `::1` (128-bit loopback), one address only.

### Special addresses

| Address/prefix | Meaning |
|---|---|
| `0.0.0.0/32` (and `0.0.0.0` in general) | "This host on this network" / default-route / DHCP "unknown address" |
| `0.0.0.0/0` | Default route — "any destination, match only if nothing else" |
| `127.0.0.0/8` | Loopback (host itself) |
| `255.255.255.255/32` | **Limited broadcast** — to everyone on the local segment (never routed) |
| Network `.../network-bits` (host all 0) | **Network address** — names the subnet, not assignable to a host |
| Network `...` host all 1 (e.g., 192.168.1.**255** /24) | **Directed broadcast** — to all hosts on that subnet (router may forward, often filtered now) |
| `169.254.0.0/16` | APIPA / link-local — auto-config when DHCP fails; only same-link reachable |
| `100.64.0.0/10` | CGNAT shared address space (carrier NAT) |
| `224.0.0.0/4` | Multicast (class D) |
| `240.0.0.0/4` | Reserved/experimental (class E) |
| `198.18.0.0/15` | Benchmarking (network device tests) |
| `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24` | Documentation (TEST-NET-1/2/3) — sample addresses in RFCs/exams |
| IPv6 `::` | Unspecified address |
| IPv6 `::1` | Loopback |
| IPv6 `fe80::/10` | Link-local (every IPv6 iface has one) |
| IPv6 `ff00::/8` | Multicast; `ff02::1` all-nodes, `ff02::2` all-routers |
| IPv6 `fc00::/7` | Unique-local (private) addresses |
| IPv6 `2000::/3` | Global unicast |

---

## 5.5 Subnetting

### Why subnetting is required

- **Classful waste:** a class B block to a 300-host office burns 65k addresses; class C's 254 may be too small — fixed classes can't match real department sizes.
- **Subnetting** = an org **carves its own allocation into smaller logical subnets** (by borrowing host bits to extend the network prefix) — one class B becomes many class C-sized subnets for departments/floors/Wi-Fi/DMZ.
- **Benefits:** smaller **broadcast domains** (less broadcast traffic), **less congestion**, **easier administration & security** (ACLs/policies per subnet, e.g., isolate servers/VLANs), efficient address use, flexible growth (add subnets without renumbering everything), natural mapping to topology (one subnet per LAN/segment).

### Subnet mask
32-bit mask marking how many leading bits = **network (and subnet)** portion vs **host** portion: `1`s = network bits, `0`s = host bits.

- Written dotted decimal (`255.255.255.0`) or prefix length (`/24` = 24 network bits).
- **AND** the mask with any address in the subnet to get the **network/subnet address** (host bits forced to 0); AND with inverted mask to isolate host ID.
- Example: IP `192.168.5.33/27`, mask `255.255.255.224` → first 27 bits network, last 5 host bits → subnet block size 32.

```text
 192.168.5.33  = 11000000.10101000.00000101.00100001
 mask /27      = 11111111.11111111.11111111.11100000
 AND           = 11000000.10101000.00000101.00100000 → subnet 192.168.5.32/27
 host bits     = 00001 → host #1 in that subnet
```

### CIDR basics
**Classless Inter-Domain Routing (CIDR, RFC 1519)** — kills class boundaries: any prefix length `/n` is legal (`/22`, `/27`, `/13`…); routing uses **longest prefix match**; allocations done by RIRs in variable chunks (`/12`, `/15`…).

- Notation: `172.16.0.0/12` = 12 network bits.
- **Route aggregation / supernetting:** a router advertises one summary prefix covering many subnets (`203.0.112.0/20` covers 16 /24s) → shrinks global routing tables; kids: **subnetting = split** (borrow bits, more subnets), **supernetting = merge** (drop bits, one big prefix).
- Private+CIDR+VLSM together fixed IPv4's exhaustion short of the full IPv6 move.

### Network address
Address with **all host bits = 0** — names the subnet itself; **cannot be assigned to a host** (routing target for the prefix). Computed: `IP AND mask` (or write network prefix, pad zeros).

### Broadcast address
Address with **all host bits = 1** — a frame sent to it is delivered to **every host on that subnet** (L2 dst = FF:FF:FF:FF:FF:FF after ARP for that IP). Not assignable as a unicast host address (limited broadcast 255.255.255.255 covers "this segment, dest unknown").

### Host range (useful host addresses)
All addresses strictly between network and broadcast:

```text
 first usable = network + 1
 last usable  = broadcast − 1
 usable count = 2^(host bits) − 2   (minus network & broadcast)
```

### Number of subnets
Borrowing **s bits** from the host portion of the original classful/major network:

```text
 # subnets = 2^s          (modern/CIDR: no reserved subnet-zero issue — all usable)
 old classful formula: 2^s − 2  (historically excluded all-0/all-1 subnets; rarely used today)
```

Where `s` = new_prefix − original_network_prefix (e.g., class C /24 subnetted to /27 → s = 3 → 8 subnets).

### Number of hosts
Host bits `h = 32 − new_prefix_length`:

```text
 # hosts per subnet = 2^h − 2   (minus subnet address & broadcast)
```

Quick powers: h=8→254, h=6→62, h=5→30, h=4→14, h=3→6, h=2→2, h=1→0 (none usable! /31 point-to-point uses both addrs per RFC 3021; /32 = single host route).

### Basic subnetting problems (worked patterns)

**Pattern 1 — given IP/mask: find subnet, broadcast, range.**
IP `172.16.33.100/20`:
```text
 /20 → block size in 3rd octet = 256 − 240(=240? mask 3rd octet = 240 for /20) → blocks of 16
 mask 255.255.240.0
 3rd octet: 33 → 33/16 = 2 → subnet base = 2*16 = 32 → 172.16.32.0/20
 broadcast: next subnet −1 → 172.16.47.255
 range: 172.16.32.1 – 172.16.47.254   (hosts = 2^12 − 2 = 4094)
```

**Pattern 2 — given N hosts needed: choose mask.**
Need 500 hosts → 2^h −2 ≥ 500 → h = 9 (512−2=510) → prefix /23 (32−9) → mask 255.255.254.0.

**Pattern 3 — given number of subnets: borrow bits.**
Class B (default /16) needs ≥ 6 subnets → 2^s ≥ 6 → s = 3 → new prefix /19, mask 255.255.224.0 → 8 subnets × 8190 hosts each.

**Pattern 4 — VLSM (variable length):** assign different mask sizes per subnet from largest to smallest to fit all needs into one block without overlap (classic exam: build a corporate plan with /23 server LAN, /24 offices, /26 guest Wi-Fi, /30 WAN links — always place **largest subnets first**).

**Pattern 5 — CIDR/aggregation:** are these prefixes aggregatable? `200.10.4.0/24`, `200.10.5.0/24`… → common /23 → advertise `200.10.4.0/23` (check block alignment at boundary).

### Practice subnetting questions (drill set)

1. `192.168.10.50/28` → network? broadcast? usable range? (Ans: 192.168.10.48, .63, .49–.62, 14 hosts)
2. `10.1.2.30/30` → how many usable hosts? which subnet? (Ans: 2 hosts — .29 & .30 on 10.1.2.28/30; classic point-to-point)
3. Class C `/24` split into 4 equal subnets → mask? hosts each? (Ans: /26, 62 hosts, 192.168.1.0/26, .64/26, .128/26, .192/26)
4. Need 12 subnets of a class B — what prefix, how many hosts each? (Ans: /20, s=4, 16 subnets, 4094 hosts — or if they mean exactly ≥12 → 16 available)
5. Host has mask 255.255.255.240 — how many hosts? (Ans: /28 → 14)
6. Given blocks `x.x.0.0/24` × 4 — can they aggregate to /22? Only if aligned to /22 boundary.
7. `172.20.5.9/28` vs `/26` vs `/24` — compute all three subnet bases (mask AND) — watch 3rd/4th octet boundaries.
8. Convert dotted mask ↔ prefix ↔ binary mask instantly (drill: /19 = 11111111.11111111.11100000.00000000 = 255.255.224.0).

Full solved numerical set (exam-style, step-by-step): [10-final-exam-prep.md](10-final-exam-prep.md#subnetting--cidr).

---

## Chapter 5 Revision (§5.1–5.5)

### Routing questions
- Routing vs forwarding (global path vs local action, control vs data plane).
- Static vs dynamic; centralized (SDN controller) vs distributed.
- Distance vector = Bellman-Ford + neighbour tables + count-to-infinity (RIP) vs Link state = flood LSDB + Dijkstra (OSPF). Comparison table in §5.2.
- BGP = path vector between ASes (policy + loop-free AS path).

### IP addressing questions
- 32-bit IPv4 dotted decimal; parts network|host via mask.
- Classful A/B/C/D/E table (ranges, masks, hosts, purpose).
- Public vs RFC 1918 private; loopback 127.0.0.1 / ::1; special addresses table (§5.4).

### Subnetting problems
- mask AND → subnet base; broadcast = base + 2^h − 1; usable = 2^h − 2; subnets = 2^s.
- Choose mask from host/subnet requirements; VLSM largest-first; CIDR aggregation alignment.
- Step-by-step drills: [10](10-final-exam-prep.md#subnetting--cidr).

### IPv4 vs IPv6
- 32b vs 128b; variable vs fixed 40 B header; checksum present vs absent; router vs source fragmentation; broadcast vs multicast/SLAAC/NDP; IPsec optional vs architectural. Full table in §5.3 & [10](10-final-exam-prep.md).

### Important interview questions
1. What does the network layer do? Routing vs forwarding in 20 seconds.
2. How does a router choose between multiple matching prefixes? (longest prefix match)
3. Distance vector vs link state — protocol examples, convergence, loop behavior.
4. What happens to TTL and checksum as a packet crosses a router?
5. Why does fragmentation happen at the source in IPv6 but at routers in IPv4?
6. Explain class A/B/C and why classful addressing died (→CIDR/subnetting).
7. Why do we need private IPs if we have IPv6? (NAT, legacy, security-by-obscurity debate)
8. Walk through a /26 subnet calculation live (network, broadcast, hosts).

### Important exam questions
1. Define routing and forwarding; differentiate them.
2. Explain static vs dynamic routing; centralized vs distributed.
3. Compare distance vector and link state algorithms with examples (RIP vs OSPF).
4. Describe the IPv4 header fields and their purpose (≥6 fields with function).
5. Compare IPv4 and IPv6 headers/features in a table.
6. What is subnetting? Why is it needed? State subnet mask, network/broadcast addresses, host range formulas.
7. Solve: given `a.b.c.d/n` find subnet, mask, broadcast, #subnets from a classful base, #hosts.
8. Explain CIDR and route aggregation with an example.
9. List and explain important/special/reserved IP addresses.
10. Class D and E — purpose of each.

### Quick revision notes
- Network layer = host-to-host across networks; routing (global, control) computes tables; forwarding (local, data) matches+sends per packet; longest prefix match wins.
- DV/Bellman-Ford (RIP, rumor, count-to-infinity) vs LS/flood+Dijkstra (OSPF, fast, full map); BGP path-vector between ASes.
- IPv4: 32-bit, connectionless, header-only checksum, TTL, router fragmentation, options. IPv6: 128-bit, fixed 40 B, no checksum, source-only frag, NDP/SLAAC, flow label, multicast not broadcast.
- Classful: A /8 (1–126), B /16 (128–191), C /24 (192–223), D multicast (224–239), E reserved (240–255); masks 255.0.0.0 / 255.255.0.0 / 255.255.255.0.
- Private RFC1918: 10/8, 172.16/12, 192.168/16. Loopback 127/8. Broadcast all-1s host part; network all-0s.
- Subnet: borrow s bits → 2^s subnets; host h bits → 2^h − 2 hosts; AND mask for base, +2^h−1 broadcast, range base+1 … broadcast−1. CIDR = arbitrary /n + aggregation.
