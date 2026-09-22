# 08 — IEEE Standards & Practical Networking

> Reference: Kurose & Ross Ch. 6 (link layer & LANs: Ethernet 802.3, Wi-Fi 802.11, addresses) + classic syllabus (IEEE 802 family, NIC/MAC) + book Ch. 4-5 concepts applied (routers, NAT) + `ping`/`ip`/`nslookup` manual. | TODO Chapter 7 | Priority: **MUST KNOW** — "how do I verify a network?" is asked in almost every junior admin/network role

---

## 7.1 IEEE Standards

### What is IEEE?

The **Institute of Electrical and Electronics Engineers** — the world's largest technical professional organization. It standardizes hardware, software, and data formats through **standardization bodies** (IEEE SA — Standards Association) and working groups (e.g., the **802 LAN/MAN Standards Committee**), issuing standards like **IEEE 802.3** (Ethernet) and **802.11** (Wi-Fi). It defines **Layer 1 + Layer 2** behavior — cabling, signaling, frame formats, MAC — so devices from different vendors interoperate.

> Interview answer: "IEEE is the standards body behind most of the physical and data-link layer — the 802 project. IEEE 802.3 defines classic wired Ethernet, 802.11 defines Wi-Fi, 802.1 handles bridging/VLANs/STP, 802.2 LLC. These ensure your NIC, switch, and router all speak the same frame and signaling language."

### Why networking standards are required

- **Interoperability** — devices from different vendors must plug together (Intel NIC ↔ Cisco switch ↔ Aruba AP ↔ Apple laptop).
- **Predictability & compatibility** — fixed frame formats, addresses, timing guarantee a device can decode another's signal.
- **Economies of scale** — a huge common market for NICs, cables, switches; competition lowers cost.
- **Innovation under constraints** — defined interfaces (PHY/MAC split) let vendors improve speed (100M → 1G → 10G → 100G) without redesigning everything.
- **Safety/quality (EMI, cabling)** — standardized connectors/categories guarantee performance.
- Standards are **recommendations** enforced through interoperability testing + certification (Wi-Fi Alliance, Ethernet Alliance).

> Consistent with Kurose's design philosophy: a layered protocol stack with **standardized interfaces between layers** is what allows independent evolution of each layer.

### IEEE 802 family

The **802 committee family** covers LAN/MAN link+physical standards (numbered). **802.2 LLC** sits on top; **MAC + PHY** below. Exam-favourite summary:

| Standard | Name | What it defines |
|---|---|---|
| 802.1 | Higher Layer LAN Protocols | Bridging, VLANs (802.1Q), Spanning Tree (802.1D/1w/1s), Link aggregation (802.1AX), LLDP |
| 802.2 | LLC (Logical Link Control) | The upper sublayer interface between network layer and MAC |
| 802.3 | **Ethernet** (CSMA/CD IEEE-port) | Wired LANs: baseband signaling, frame format, speeds |
| 802.4 | Token Bus (deprecated) | Broadcast bus with logical token ring — retired |
| 802.5 | Token Ring (IBM) | Physical ring topology, token-passing access — superseded by Ethernet |
| 802.6 | DQDB / MAN (deprecated) | Distributed Queue Dual Bus, Fiber MAN |
| 802.8 | FDDI (fiber) | Fiber Distributed Data Interface, dual counter-rotating rings |
| 802.11 | **Wi-Fi** WLAN | Wireless LAN: OFDM, MAC (CSMA/CA), security (802.11i/WPA) |
| 802.15 | WPAN / Bluetooth / LR-WPAN (ZigBee) | Personal-area wireless networks |
| 802.16 | WiMAX (deprecated) | Metropolitan broadband wireless (line-of-sight) |
| 802.18 | RR-TAG (Radio Regulatory) | Regulatory guidance for the above |

**Notable recent branches:** 802.1AX Link Aggregation, 802.1Q VLAN tagging, 802.11ax (Wi-Fi 6), 802.11be (Wi-Fi 7), 802.1X port-based network access control (EAP).

### IEEE 802.3 (Ethernet)

IEEE 802.3 is the **family of wired-Ethernet standards**, evolved from the original 1973 Xerox/Intel/DEC Ethernet (10 Mbps, CSMA/CD). It standardizes:

- **Frame format** — shared by all Ethernet speeds (Preamble, SFD, Destination MAC, Source MAC, EtherType/Length, Payload 46–1500 B, FCS/CRC-32; Q-tag optional 4B for VLAN).
- **MAC rules** — earlier versions needed **CSMA/CD** on shared media; modern **full-duplex switched links need no collision detection** (point-to-point), so the access protocol "collapses".
- **Speeds/physical layers (name `DATA-RATE BASE MEDIUM-TYPE`):**

| Variant | Speed | Medium | Notes |
|---|---|---|---|
| 10BASE-T | 10 Mbps | Twisted pair (Cat 3+) | Original twisted-pair Ethernet |
| 100BASE-TX | 100 Mbps | Cat 5 UTP | "Fast Ethernet" |
| 1000BASE-T | 1 Gbps | Cat 5e/6 UTP | "Gigabit Ethernet" |
| 10GBASE-T | 10 Gbps | Cat 6a | Copper 10G; SFP+ for fiber |
| 1000BASE-LX/SX | 1 Gbps | Single/Multimode fiber | Longer links |
| **NBASE-T / 2.5G-5G-10G BASE-T** | 2.5G/5G/10G | Cat 5e/6/6a | Wi-Fi 6 uplink common |

Relevant properties: max frame 1518 B (1522 with VLAN Q-tag), minimum 64 B (no smaller or runt/truncated), robust CRC-32 FCS (error detection; no retransmission at this layer — TCP/upper layers handle it), MAC = globally unique 48-bit hardware address (24-bit OUI + 24-bit NIC ID), broadcast `FF:FF:FF:FF:FF:FF`, multicast bits set last LSB of first octet.

### IEEE 802.4 (Token Bus)

**802.4 Token Bus** — a **broadcast bus topology operating like a logical ring**: stations join/leave a ring overlay; a **token** circulates the logical ring, and only the token holder may transmit for a bounded time. Advantages: deterministic access, priority support. **Deprecated** because Ethernet's simplicity+price+speed beat the complexity of token maintenance, added latency, and physical bus installation issues.

### IEEE 802.5 (Token Ring)

**802.5 Token Ring** — IBM's **physical ring topology** (MAU/ring wiring): a 3-byte **token** circulates; a station with data captures the token, transmits, returns its frame marker so the sender strips the frame; a monitor handles ring errors. Speed: 4/16 Mbps. Benefits: no collision, deterministic delay, guaranteed access time (useful for real-time). Downsides: single ring failure zone without MAU bypass, slower than modern Ethernet, proprietary complexity → totally displaced by switched Ethernet.

> Phone-interview answer: "Token Ring guarantees access time because the token bounds wait; Ethernet was best-effort with random backoff. But cheap, fast, switched Ethernet won — today 802.11 wireless and 802.3 wired dominate."

### IEEE 802.11 (Wi-Fi)

**802.11 WLAN / Wi-Fi** — wireless LAN standard family, using **CSMA/CA** (carrier sense multiple access with collision avoidance) on **ISM bands** (2.4 GHz, 5 GHz, 6 GHz). 802.11 MAC fragments:

- **DCF (Distributed Coordination Function)** — CSMA/CA mandatory; no collision detection possible because a radio can't listen while transmitting (hidden/exposed terminal problems) → **wait DIFS + random backoff window, RTS/CTS handshake** to reserve, hop-by-hop **ACK** after each data frame.
- **PCF (Point Coordination Function)** — optional contention-free TDMA-style polling by the AP (used for QoS, e.g., voice).

802.11 **generations** (friendly names by Wi-Fi Alliance):

| Generation | IEEE | Key | Band | Top rate (typical) |
|---|---|---|---|---|
| Wi-Fi 1 | 802.11 | — | 2.4 GHz | 2 Mbps (legacy) |
| Wi-Fi 4 | 802.11n | HT / MIMO | 2.4+5 GHz | 600 Mbps |
| Wi-Fi 5 | 802.11ac | VHT, MU-MIMO | 5 GHz | ~3.5 Gbps |
| Wi-Fi 6 | 802.11ax | OFDMA, up/down MU-MIMO | 2.4+5 GHz | ~9.6 Gbps |
| Wi-Fi 7 | 802.11be | 320 MHz, MLO, 4096-QAM | 2.4+5+6 GHz | ~46 Gbps |

**Modes:** Infrastructure (station ↔ AP ↔ distribution system → wired LAN), **Ad-hoc/IBSS** (peer-to-peer), **Mesh** (802.11s, multi-AP wireless backbone). **Security evolution:** WEP (broken, RC4) → WPA (TKIP) → **WPA2 (802.11i, AES-CCMP)** → **WPA3 (SAE, 192-bit mode, TPM forward secrecy)**; also **WPA2-Enterprise/802.1X** using EAP/RADIUS for orgs. Access via **SSID**; channels 1/6/11 in 2.4 GHz to avoid overlap (20 MHz spacing).

### Ethernet relationship

- **IEEE 802.3 ⇒ Ethernet.** "Ethernet" is the marketing/brand name; its formal standard is maintained in the 802.3 project. Frame format and CSMA/CD (legacy) are the defining features.
- Efficiency: Ethernet efficiency = payload/(overhead+frame) ≈ (min 46-1500B data + 18B header+tralier) — for 1500B data: 1500/1518 ≈ **98.8%**.
- Guaranteed interop => certified NIC + switch combinations, auto-neg for speed/duplex, MDI-X auto-crossover.

### Wi-Fi relationship

- **IEEE 802.11 ⇒ Wi-Fi.** "Wi-Fi" is the brand licensed by the **Wi-Fi Alliance** for certified 802.11 products (they test interop, add standards like WMM, direct, easy connect). Wi-Fi = marketing, 802.11 = engineering spec.
- Wi-Fi uses **12-14 channels** in 2.4 GHz (only 3 non-overlapping commonly: 1,6,11); 5/6 GHz bands have many non-overlapping channels and finer channel bonding.
- Unlike Ethernet (reliable 8B/10B or clean full-duplex copper), radio is lossy → more ACKs, retries, rate adaptation (MCS fallback), and transmit power on-air for security/coexistence.

> Standalone summary: 802.3 = wired copper/fiber LAN; 802.11 = wireless LAN; 802.4/802.5 = historical token-based deterministic LANs; 802.1 = bridging/VLAN/STP overhead.

---

## 7.2 Network Interface

### NIC

**Network Interface Card** — the hardware connecting a host to a network: handles **framing** (build/send/parse Ethernet/802.11 frames), **physical signaling** (encoding/transmit/receive on the medium), **MAC address**, and offloads (checksum, segmentation). Connects to the system **via PCIe/USB/SFP+** and to cable/Wi-Fi/optical media. Critical interface between the CPU/driver and the physical link.

Interface types: wired (RJ-45 Ethernet), wireless (Wi-Fi adapter, Bluetooth), virtual (loopback `lo`, bridge, TUN/TAP used by Docker/VPN), plus optical (SFP/SFP+/QSFP transceivers).

### MAC address

**Medium Access Control address** — a **48-bit (6-byte) hardware address** burned into the NIC (or assigned randomly/OS-custom for privacy), written as `00:1A:2B:3C:4D:5E` (colons, hyphens, or dots). Structure = **24-bit OUI** (Organizationally Unique Identifier assigned by IEEE, identifies vendor: first octet LSB = 0 unicast, 1 multicast/broadcast) + **24-bit NIC-specific**. Scope: **Layer-2**, only used on the local LAN segment — frames contain source/destination MAC; switches use it to forward; routers inspect/rewrite at each hop.

Special addresses: broadcast `FF:FF:FF:FF:FF:FF` (flood to all), multicast (LSB of first octet = 1), locally-administered (2nd LSB of first octet = 1).

### MAC vs IP address

| | MAC address | IP address |
|---|---|---|
| Layer | **Layer 2** (data link) | **Layer 3** (network) |
| Format | 48-bit hex `00:1A:2B:3C:4D:5E` | IPv4 32-bit `192.168.1.5`, IPv6 128-bit |
| Assigned by | Vendor (burned-in) / OS | Network admin / DHCP |
| Scope | **Physical, local segment** | **Logical, internetwork** |
| Lifetime | Permanent (usually) | Temporary / renewable (lease) |
| Purpose | Deliver frame within the LAN | Deliver packet across networks (end-to-end) |
| Flat vs hierarchical | Flat (no geography info) | Hierarchical (network/host portion → routing) |
| Example | `00:1A:2B:3C:4D:5E` | `192.168.1.5/24` |

**Relationship:** ARP maps IP→MAC on the same segment; the switch learns MAC/source-port mapping; routing decides *which* next-hop MAC to seek. MAC alone cannot route beyond a subnet; IP alone cannot reach a device without knowing its MAC locally.

> Interview answer: "MAC addresses are burned-in hardware identifiers for same-LAN frame delivery; IP addresses are logical, hierarchical addresses routers use to move packets end to end. You need ARP to bind the two on each segment; the MAC changes at every router hop but IP stays the same."

### Network interface

The OS view: a **network interface** = the entity the network stack binds to (kernel struct): NIC + its driver exposes `eth0`, `wlan0`, `enp2s0`, `ens33` (Linux/systemd-net naming), `Ethernet`/`Wi-Fi` (Windows), `lo` loopback, `tun0` VPN. Commands: `ip link` (Linux list); `ipconfig /all` (Windows); `ifconfig` (legacy). Each interface owns its layer-2 (MAC), layer-3 (IP/mask/gateway), MTU, link speed/duplex, and allows multiple IPs.

### Ethernet interface

A wired network interface connected to a switch via **UTP (Cat 5e/6/6a) or fiber (SFP)**. Auto-negotiation picks best common **speed (10/100/1G/10G) + duplex**; uses full-duplex point-to-point (no collisions). You diagnose with `ip link`, `ethtool eth0` (speed/duplex/link-ok), `ip -br addr`.

### Wireless interface

Wi-Fi interface using 802.11 radio, binds to **AP's SSID**: scan/associate/authenticate (WPA2/WPA3 handshake), power management, roaming between APs within same ESSID; shows `wlan0` and you check with `iwconfig`/`nmcli`, `netsh wlan show interfaces` (Windows). Lower throughput/range than a wired NIC, higher latency, more link errors → CSMA/CA + retries.

> Table recap — NIC = hardware; interface = OS-visible binding; MAC = L2 identity; IP = L3 identity; both Ethernet and wireless NICs expose interfaces.

---

## 7.3 Practical Network Architecture

### Device → Switch → Router (home/office LAN)

Canonical LAN: **Client(s) → switch → router → ISP/Internet**:

```text
[PC1]──┐                         ┌──[DNS server]
[PC2]──┼──[Switch(L2 LAN)]──────[Router/NAT+Firewall]═══[ISP modem]═══Internet
[PC3]──┘                         │
[laptop]────────[AP(Wi-Fi)]──────┘  (same broadcast domain via VLAN/bridge)
```

- **Switch (L2):** connects the LAN, forwards frames by MAC table, isolates collision domains, transparent to IP; handles local traffic only.
- **Router (L3):** default gateway — routes packets between LAN and WAN (or VLANs), runs **NAT** (lab→private ↔ public IP), **DHCP server**, basic **firewalling**; learns LAN interface IP + default route to ISP.
- **ISP:** provides connectivity + assigns public IP (static/dynamic), gives DNS + gateway; home/office uplink via modem (DOCSIS/FTTH/4G).

### Home network

Typical home: ISP fiber/DSL → **router/modem combo (gateway)** → switch or built-in ports + Wi-Fi AP → phones/PCs/smart devices. **DHCP** on the router hands out private `192.168.x.x`; **NAT** maps private→public; **DNS** goes to ISP resolver (or Cloudflare `1.1.1.1` / Google `8.8.8.8`). Add a **mesh/repeater** for coverage; IoT on an **IoT VLAN** or guest network for isolation.

### LAN architecture

- **Flat single subnet:** all hosts on `192.168.1.0/24`, one broadcast domain; easy to manage, no routing within LAN; scaling issues (broadcast storms, no segmentation).
- **VLAN-based:** 802.1Q tags divided by team/security zones (Users 10, Servers 20, Guest 30…) using a trunk to the switch/Router-on-a-Stick; each VLAN = own subnet + own DHCP scope + packet filters between VLANs. **Benefits:** smaller broadcast domains, security isolation, flexible logical design.
- **Wired backbone + wireless access:** APs bridge wireless 802.11 to the wired backbone; wireless users join the same or dedicated VLAN.

### Internet connection

End devices → default gateway → ISP edge → backbone (tier-1 providers interconnecting at **IXPs**) → destination. Connectivity services the ISP provides: **public IP**, **DNS**, route to Internet, services like static IP, port forwarding, QoS, sometimes CGNAT. You can see the path with `traceroute`/`tracert`; your actual IP is verified with `curl ifconfig.me`.

### ISP

**Internet Service Provider** — provides Internet access + transit. Tiers: **Tier 1** (transit everyone, no fee peering — backbone), **Tier 2** (regional, buys transit), **Tier 3** (residential/retail). Types: wired (DSL, cable, FTTH/FTTP), wireless (fixed WiMAX, 5G/LTE), satellite. Services: dedicated line, broadband, static IP/DNS, hosting, VPN. The ISP's **gateway/NAT** hides customer's private IPs behind of them (public IP at ISP edge).

### Router

Layer-3 device performing: **routing** (finding best next-hop path using routing tables/OSPF/BGP), **forwarding** (moving packet from ingress to egress interface), **NAT** (translate src/dst private↔public), plus **firewall/DHCP/DNS-relay**. Home/VPN/enterprise classes differ in performance, HA, and feature set. Router also owns the **default gateway address** your DHCP hands out.

> Diagnostic snippet: check default gateway `ip route | grep default` (Linux) or `ipconfig | findstr Gateway` (Windows); then `tracert 8.8.8.8` shows router → ISP → backbone hops.

### DNS

Optionally override ISP DNS: edit `/etc/resolv.conf` or router DHCP options; classless records (A/AAAA/CNAME/MX/NS/TXT/PTR/SOA/SRV) covered in `06`/`07`. Practical: `nslookup google.com`, `dig google.com`, `host`, `resolvectl status` (systemd). Failure diagnostics: cache/ttl, local `/etc/hosts`, DNS poisoning, split-horizon vs public.

### DHCP

Run at router; leases private IPs; scope → subnet/mask/gateway/DNS/lease-time. In offices: dedicated DHCP server or scope on router; use DHCP reservations for stable host IPs (printers, servers) instead of static config. See DORA + relay in `07` (§6.8). Practical: `ipconfig /release`, `/renew`, `lease` shown in `ipconfig /all`; `journalctl -u dhclient` or `nmcli`.

### NAT

**Network Address Translation** (NAT) map private→public at the edge. **Why:** IPv4 exhaustion, hide internal topology, cheap ISP single IP, plus a sort of rudimentary protection (unsolicited inbound blocked).

| Type | Behavior | Use |
|---|---|---|
| Static NAT (1:1) | one internal ↔ one public fixed mapping | public servers |
| Dynamic NAT (pool) | many internals ↔ public pool | dial/lease scenarios |
| **PAT (NAPT)** | many internals ↔ one public via port mapping (5-tuple table) | home/office internet |
| Port forwarding | explicit inbound rule (WAN:port → LAN:ip:port) | game servers, webcam |

Diagram:

```text
  PC 192.168.1.10:50056 ─▶ NAT table ─▶ WAN 203.0.113.5:50056 ─▶ Internet
   (src port 50056)        (src: 192.168.1.10→203.0.113.5)   (response comes back, reversed)
```

Drawbacks: breaks end-to-end, complicates P2P/VoIP (STUN/ICE/TURN/Hole punching), logs per flow, one NAT overload per public IP (65535 simultaneous). **IPv6 largely removes NAT need** (A /64 per LAN), though some orgs NAT64 for IPv6-only.

---

## 7.4 Practical Networking Commands

> These are the bread-and-butter "verify connectivity" command answers. Platform column: L = Linux/macOS, W = Windows.

### ping (L/W)

Send **ICMP echo request** to a target and measure **RTT + loss**; basic connectivity status.

```text
ping 8.8.8.8            # IPv4, continues
ping -c 4 8.8.8.8       # Linux: 4 packets
ping -t 8.8.8.8         # Windows: continues until Ctrl+C
ping -4: ping -6        # force IPv4/IPv6
ping hostname           # also checks DNS resolution
```
Result reading: replies + RTT via (dest must respond; some hosts/ICMP-blocked = timeouts, not death); loss% + median/lowest; **TTL** reveals initial OS TTL hints (Linux 64, Windows 128, router hops = decrement difference).

### ipconfig (W)

Windows wired/Wi-Fi interface/IP information.

```text
ipconfig                     # IPv4, mask, gateway per adapter
ipconfig /all                # + MAC, DHCP lease, DNS servers
ipconfig /release | /renew   # drop/ask DHCP new lease
ipconfig /flushdns           # clear local DNS cache
ipconfig /displaydns         # show cached DNS entries
```

### ip (L)

Modern Linux network command (replaces ifconfig/route/arp):

```text
ip addr               # IP + MAC per interface         (alias ip a)
ip link               # physical/protocol link state    (ip l)
ip route              # routing table                   (ip r; default route line)
ip neigh              # ARP/NDP table                   (ip n)
ip -br addr           # compact: up/down + IP
```
`ip link set eth0 up/down`, `ip addr add 192.168.1.5/24 dev eth0` (temporary), `ip route add default via 192.168.1.1`.

### ifconfig (L/macOS legacy)

Older interface config/status:

```text
ifconfig            # list interfaces (flags, MTU, IPv4, netmask, MAC)
ifconfig eth0 up    # called with sudo; mostly superseded by ip
```
Deprecated in modern Linux (no autoconf/IPAM), kept on macOS (`ifconfig en0`).

### tracert (W) / traceroute (L)

Show each router hop + RTT to destination; works via incrementing **TTL** causing ICMP Time-Exceeded from each intermediate router (Windows uses ICMP echo, Linux uses UDP probes by default).

```text
tracert 8.8.8.8          # Windows
traceroute 8.8.8.8       # Linux (traceroute -I for ICMP)
```
Reading: first line = your router/gateway, then ISP hops, * = hop didn't reply (filtered/slow), probe results per hop; useful to find where latency/loss begins (path issues, egress NAT).

### nslookup (L/W)

Query DNS interactively/simple:

```text
nslookup google.com         # A record via default resolver
nslookup google.com 8.8.8.8 # force a specific DNS server
nslookup -type=MX gmail.com # query record type   (set type=MX)
```
Answers include canonical name + addresses + TTL + authoritative server. Useful to verify resolution status + DNS leak.

### dig (L/macOS)

The power DNS tool (DNS + more control):

```text
dig google.com                          # A + authority + timings
dig @8.8.8.8 -t MX gmail.com             # MX via server
dig google.com +short                   # compact answer
dig -x 8.8.8.8                          # reverse PTR
dig +trace google.com                   # manual root→TLD→auth walk
```

### netstat (L/W)

Show **sockets/connections/listeners/statistics**:

```text
netstat -an            # all sockets + state (TCP/UDP)   LISTEN/ESTABLISHED
netstat -ano           # Windows + owning PID
netstat -antlp         # Linux listening + process (needs root)
netstat -s             # TCP/UDP/ICMP counters summary
netstat -rn            # routing table
```
Search by port / grep: `netstat -an | findstr :443` / `grep 443`.

### ss (L)

Modern socket statistics (netstat replacement):

```text
ss -tulnp        # tcp/udp listeners with process (needs root)
ss -an           # all connections
ss -s            # summary counts
```
Keys: `-t tcp, -u udp, -l listen, -n numeric, -p process`.

### curl (L/W)

HTTP/transfer client — test API / health / headers:

```text
curl https://example.com              # body
curl -I https://example.com           # headers only (HEAD)
curl -v / --trace-ascii -             # full handshake + headers
curl -X POST -d 'json' -H 'Content-Type: application/json' URL
```
Useful for HTTP status checks (200/404), TLS debug (`curl -k`), uploads/downloads, REST automation.

### Connection-oriented earned cheat (exam table)

| Command | Layer/protocol | Purpose | Windows | Linux/macOS |
|---|---|---|---|---|
| ping | L3/ICMP | connectivity + RTT + loss | `ping -t 8.8.8.8` | `ping -c 4 8.8.8.8` |
| ipconfig/ifconfig/ip | L3 config | interface IP/MAC/DHCP | `ipconfig /all` | `ip addr`, `ifconfig` |
| tracert/traceroute | L3/ICMP+UDP | show path + hop delays | `tracert 8.8.8.8` | `traceroute 8.8.8.8` |
| nslookup/dig/host | DNS (UDP 53) | resolve/verify DNS | `nslookup` | `dig`, `nslookup`, `host` |
| netstat/ss | L4 sockets | listeners/state/process | `netstat -ano` | `ss -tulnp` |
| curl | L7 HTTP(S) | fetch/trigger web services | `curl` | `curl` |

**Troubleshooting order (memorize for interview):** `ping` (host reachable?) → `tracert` (where path breaks) → DNS `nslookup/dig` (resolves?) → gateway/DHCP (have an IP? `ip`/`ipconfig`) → local service `netstat`/`ss` (port listening?) → app/L7 `curl` (service up?).

---

## Chapter 7 Revision

### IEEE standards table
802.1 bridging/VLAN/STP; **802.3 Ethernet** (frame + CSMA/CD + speeds, 1000BASE-T etc.); 802.4 Token Bus (logical ring, deprecated); 802.5 Token Ring (physical ring 4/16 Mbps, deterministic); **802.11 Wi-Fi (CSMA/CA, 2.4/5/6 GHz, Wi-Fi 6 = 802.11ax)**; 802.15 Bluetooth/ZigBee; 802.16 WiMAX. IEEE = standards body (802 committee); Wi-Fi Alliance certifies brand.

### Network architecture diagram
Client → switch (L2 MAC forwarding) → router/gateway (L3 + NAT + DHCP + FW) → ISP → Internet; DNS + DHCP servers in the LAN; Wi-Fi AP bridged to the wired backbone; VLAN segmentation for scale (full ASCII in §7.3).

### Network device diagram
Repeater (L1 regenerates), Hub (L1 flooding), Bridge (L2 filtering), Switch (L2 MAC table + VLANs), Router (L3 route+forward+NAT), Gateway (protocol translator, often router) — see `04` §4.8 and `05`.

### Practical command reference
`ping` ICMP; `ipconfig`/`ip`/`ifconfig` config; `tracert`/`traceroute` path; `nslookup`/`dig` DNS; `netstat`/`ss` sockets; `curl` HTTP. Troubleshoot order: ping → tracert → dig/nslookup → ip/ipconfig → netstat/ss → curl.

### Exam questions
1. What is IEEE and why are network standards required? List the IEEE 802 family with functions.
2. Describe IEEE 802.3 (Ethernet): frame format fields, minimum/maximum frame size, CSMA/CD role, naming (1000BASE-T meaning).
3. Compare 802.4 Token Bus vs 802.5 Token Ring with IEEE 802.11 CSMA/CA. Why did Ethernet win?
4. What is IEEE 802.11? Explain DCF (CSMA/CA) and why no CD; list Wi-Fi generations (802.11n/ac/ax/be) and security (WEP→WPA3).
5. What is a NIC? Explain the MAC address structure (OUI + NIC ID), special addresses, MAC vs IP table.
6. Draw and explain a small LAN: Device→Switch→Router→ISP → Internet, including where DNS/DHCP/NAT operate.
7. Explain NAT: why needed, static/dynamic/PAT, port forwarding; draw the mapping for PAT.
8. Match commands: ping/tracert/nslookup/ipconfig/netstat/curl — scenario-based (host unreachable, DNS fails, port closed, page times out).

### Interview questions
1. Home/office network: draw the path a request takes — devices to cable to switch to router to ISP to Internet.
2. What does each ping/tracaert/nslookup/netstat answer? When would you run each?
3. "My web page works but DNS-Checker says fail" — troubleshoot: DNS on/off, `/etc/resolv.conf`, `nslookup`, `dig`, cache/flush, router DNS forwarder.
4. Why two separate addresses — MAC and IP? Walk ARP (same subnet vs across subnet).
5. What's in a DHCP `ipconfig /all` output for a Python engineer? Lease + DNS + gateway + MAC.
6. Why NAT exists and why IPv6 kills NAT.
7. Switch vs Router vs Gateway vs Firewall in one sentence each.
8. If `ping` succeeds but `curl https://app` fails — where do you look next? (ports `ss`, HTTPS, proxy, firewall 443, app logs.)

### Quick revision notes
- IEEE 802: 802.3 Ethernet (wired), 802.4/802.5 token (legacy deterministic), 802.11 Wi-Fi (wireless CSMA/CA), 802.1 (bridging/VLAN/STP), 802.15 BT/ZigBee, 802.16 WiMAX.
- Ethernet = IEEE framed L2; min 64 B / max 1518 B; CRC-32; full-duplex switched = no CSMA/CD needed; naming `rate BASE medium`.
- 802.11 = CSMA/CA + ACK + RTS/CTS (no CD); Wi-Fi generations n/ac/ax/be; WPA2(802.11i)/WPA3; bands 2.4/5/6 GHz; SSID + channel.
- NIC = hardware; MAC = 48-bit L2 burned-in (OUI+NIC-ID); interface = OS binding; MAC vs IP: L2 local-permanent-flat vs L3 global-logical-hierarchical (ARP bridges both).
- Home/office: clients→switch→router (DHCP+NAT+FW+DNS-relay)→ISP→Internet; DHCP lease, NAT PAT saves IPs; VLANs split broadcast domains.
- Practical: ping/TTL, ipconfig/ip/ifconfig, tracert/traceroute, nslookup/dig, netstat/ss, curl — memorise the troubleshooting ladder for interviews.