# 09 — Interview Questions & Scenario Walkthroughs

> Reference: TODO Chapter 8 (interview + final revision: fundamentals, transmission, switching, data link, multiple access, devices, network layer, transport, application, scenarios). | Priority: **MUST KNOW** — 8.10 scenarios are the classic "tell me what happens when…" questions; answers reuse every earlier chapter

---

## 8.1 Networking Fundamentals

### What is a computer network?

A computer network is **two or more autonomous devices (nodes) interconnected by communication links** (wired/wireless) so they can **exchange data and share resources**, governed by agreed **protocols**. Goals: resource/resource sharing, high reliability & availability, scalability, communication (email/chat/stream), distributed processing.

### LAN vs MAN vs WAN

| Feature | LAN | MAN | WAN |
|---|---|---|---|
| Scope | Room/building/campus | City/metro | Country/global |
| Ownership | Single org | Org or shared | Multiple ISPs/consortia |
| Speed | 100 Mbps–100 Gbps | 100 Mbps–10+ Gbps | 1–100 Mbps+ |
| Latency | Low (µs–ms) | Medium | Higher |
| Example | Office Ethernet/Wi-Fi | City fiber ring, cable TV headend | Internet |

### Internet vs Web

**Internet** = the global network (physical + logical infrastructure: routers, fiber, IP). **Web (WWW)** = one application layer using HTTP/HTTPS on top of the Internet. Internet also hosts email, DNS, VoIP, FTP, gaming. The Web is a subset — "Internet is the road network, theWeb is a service (shops) traveling on it."

### Protocol vs service

**Protocol** = the rules/format of the conversation (syntax, semantics, timing) — e.g., TCP, HTTP, DNS. **Service** = the functionality delivered to a layer/application using the protocol (reliable byte stream from TCP; name resolution from DNS). A protocol *implements* a service. Also in e-commerce: a service (web API) *uses* protocols (SOAP/gRPC/HTTP).

### OSI model

7 layers (bottom→top): **Physical, Data Link, Network, Transport, Session, Presentation, Application.** Job per layer: Physical – bits on the medium; Data Link – frames + MAC + error check between neighbors; Network – packets + routing/IP addressing end-to-end; Transport – segmentation/reassembly, TCP/UDP, ports, reliable delivery; Session – dialog management/checkpointing; Presentation – encoding/encryption/compression; Application – network services to apps (HTTP, DNS, SMTP). Reference model for understanding/debugging/protocol design; real Internet = TCP/IP.

### TCP/IP model

4/5 layers: **Application** (HTTP, DNS, SMTP, FTP — merging session+presentation), **Transport** (= OSI 4), **Internet/Network** (IP, ICMP, routing), **Link/Network Access** (Ethernet, Wi-Fi, PPP — physical+data link merged). It was the *implementation* of the Internet (RFC 1122) vs OSI being the standard-first blueprint. Encapsulate: application data → TCP segment → IP packet → frame.

### OSI vs TCP/IP

| Aspect | OSI | TCP/IP |
|---|---|---|
| Layers | 7 | 4 (or 5 with substructure) |
| Origin | Standard-first (ISO, 1984) | Implemented-first (DARPA, 1970s) |
| Session/Presentation | Separate layers | Folded into Application |
| Delivery model | Connection-oriented emphasis | Connectionless IP + TCP/UDP choice |
| Compatibility | Reference/teaching | Actual Internet stack |
| Protocol update path | Slow, formal | Incremental, pragmatic |

### Encapsulation

Adding **protocol headers (and trailers)** as data moves down the stack. Client data: `App data → TCP header+data (segment) → IP header (packet) → Ethernet header+CRC (frame)`. Each layer treats what it receives as opaque **payload** — "payload + header". Diagram bottom→top shows polynomial wrapping. Purpose: each layer adds the info its peer on the far side needs (ports, IPs, MACs).

### Decapsulation

The reverse — removing headers at the **receiver** as data rises the stack (frame → packet → segment → app data), each layer validating its field (CRC, IP checksum, port demux) before handing up.

> Interview answer: "Encapsulation = wrapping envelopes inside envelopes downward; decapsulation = unwrapping upward. The two sides are symmetric because both use the same protocol suite — that's why the header stack on the wire is identical to what the receiver validates."

---

## 8.2 Data Transmission

### Analog vs Digital

| | Analog signal | Digital signal |
|---|---|---|
| Values | Continuous (infinite levels) | Discrete (2+ levels, binary usually) |
| Example | Voice, AM/FM, sensor voltage | PC data, Ethernet bits, PCM voice |
| Noise | Degrades accuracy permanently | Regenerate at repeaters → error-free on hop |
| Bandwidth need | Low (voice ~4kHz) | Higher for same info |
| Used for | Legacy telephony, radio | Everything modern (IP/telephony) |

### Serial vs Parallel

**Serial** = 1 bit per clock on a single lane (USB, PCIe now, RS-232). **Parallel** = N bits per clock on N lines (old printer ports, ATA). Modern trend: **serial + high clock** wins because parallel suffers from **skew, crosstalk, EMI, pin cost** and clock skew at high speed; serial uses differential pairs/8b10b/64b66b encoding.

### Attenuation

**Loss of signal power/strength over distance** (amplitude decreases). Cause: medium resistance/impedance proportional to distance; measure in **dB** (attenuation = 10·log10(Pout/Pin), negative). Fix: repeaters/amplifiers, better cabling (fiber vs copper), regeneration; fiber attenuates barely (0.2–0.5 dB/km) vs copper pairs.

### Distortion

**Change of signal shape/waveform** as it travels — different frequency components propagate at different speeds (phase/frequency distortion) and different attenuations. Harmful at **high-rise edges** and for binary signals: transitions smear together. Fix: equalization, guard bands/rate limiting, line coding with controlled spectrum, fiber (single mode) minimal.

### Noise

**Unwanted random electrical signals** superimposed on the signal; sources: **thermal** (kT·B on resistors), **shot**, **intermodulation**, **crosstalk** (adjacent pairs), **impulse** (spikes/EMI). Metric: **SNR = signal power / noise power** (dB; the higher, the clearer). FEC/retransmission/CRC handle its effects; Shannon-Hartley: C = B·log2(1+SNR) sets the entropy limit.

### FDM vs TDM vs WDM

| Feature | FDM | TDM | WDM |
|---|---|---|---|
| Domain | Frequency (analog) | Time slots (digital) | Wavelength (light, = freq for fiber) |
| How | Split band into subchannels | Time divide each frame; each get slot | Multiple colors on one fiber |
| Example | TV/radio channels, DSL | PCM/T1 voice 24 slots, Ethernet time | DWDM metro 40/80/160 channels × 100G |
| Sharing | parallel simultaneous | round-robin | parallel simultaneous |
| Efficiency | Guard bands waste | slot unused = wasted | highest utilization |

(More in `01` §1.12; contrast with **CDMA** = code division, all share same band/time.)

### Guided vs Unguided media

**Guided** = signal travels along a conductor (twisted-pair, coaxial, fiber): secure, low interference, higher reliability, fixed capacity. **Unguided** = signal travels through free space via **electromagnetic waves** (radio, microwave, IR, light): mobile, no physical path, subject to interference/regulatory licenses/attenuation, prone to eavesdropping.

---

## 8.3 Switching

### Circuit vs Packet switching

| | Circuit | Packet |
|---|---|---|
| Path | Reserved/established first | Chosen per packet (dynamic) |
| Resources | Dedicated for whole call | Shared, statistical |
| Latency | Low constant (circuit delay) | Variable + queueing |
| Efficiency | Poor for bursty traffic | Excellent for bursty |
| Failure | Circuit breaks | Reroutes/out-of-order |
| Example | Traditional phone (PSTN) | Internet (IP) |

### Packet vs Message switching

**Message switching** = store-and-forward the **whole message** hop-by-hop (each switch spools entire message before forwarding). _Pros:_ full availability of intermediate store. _Cons:_ huge buffers, long delays (message must fully arrive before leaving), single point of loss. **Packet switching** = split into **small fixed/variable packets**, store-and-forward per packet, pipelined forwarding (a switch can forward packet N while still receiving N+1), much lower delay, better resilience/error recovery. → packet wins (see `02`).

### Connection-oriented vs Connectionless

**Connection-oriented:** establish a logical connection first; exchange sequence/state; reliable, ordered, predictable; then release — e.g., **TCP** (3-way handshake + connection state), **circuit switching**, **X.25/Frame Relay/ATM** virtual circuits. **Connectionless:** each packet carries full addressing, independent routing; simple, robust, no setup — e.g., **UDP**, **IP** datagram. Trade-off: setup overhead vs resilience/overhead.

### Datagram switching

Packet-switching mode where **each packet (datagram) is routed independently** — routers forward on destination address + current route table; packets can take different paths and arrive out of order (reassembly by TCP). **No connection state at routers**, no resource reservation → robust to failures, stateless, simple; but variable delay/ordering. Contrast with **virtual circuit** switching (fixed path, reserved, dedicated-ish — Frame Relay/ATM).

---

## 8.4 Data Link

### Error detection

Verify data integrity at the link layer: **VRC/LRC/CRC/Checksum/Hamming** (see `03`). Detection = receiver checks a value appended by sender (CRC, checksum, parity); **correction** (Hamming, FEC) locates + fixes within limits. Residual error probability from CRC-32 is tiny.

### CRC

**Cyclic Redundancy Check** — strongest for bursts; **binary division** of `data × 2^n / generator` → remainder appended as **FCS**; regenerating at receiver, remainder==0 → no error. Good for burst errors ≤ n (n = generator width − 1). Fixed cost, cheap in hardware (LFSR). Full worked example + harmonics in `03` §3.4.

### Checksum

**One's-complement sum** of data words; complement appended; re-sum at receiver == all-ones → OK. Used in Internet (IP, TCP, UDP, ICMP). Weaker than CRC for burst errors; O(n) software, no polynomial bursts guarantee. Full calculation in `03` §3.3.

### Hamming Code

Error-correcting code where `2^r ≥ m + r + 1` redundancy bits placed at powers of 2 positions, each covering a subset of positions; receiver recomputes and **the failing parity bits pinpoint the erroneous bit position**. Single-bit-correction (SEC); double-bit detection with extra bit (SEC-DED). Worked example in `03` §3.5.

### Flow control

Layer-2/4 mechanism to **prevent the sender from overwhelming the receiver's buffer** (stop-and-wait, sliding window, ARQ). At transport layer = **TCP flow control** with **receiver advertised window** (rwnd): sender never sends more than rwnd. `03` §3.6 + `06`.

### Sliding Window

Both sender and receiver keep a window of **sequence numbers**; sender window = number of outstanding (unACKed) frames allowed, advances as ACKs arrive (pipelining). Receiver window allows out-of-order buffering. With window W = 1, stop-and-wait; bigger W → higher utilization. Full diagrams + delay/bandwidth math in `03`/`10`.

### Stop-and-Wait ARQ

Sender sends 1 frame, waits for ACK (or timeout→retransmit); receiver only ACKs valid; timeout + sequence numbering handles lost frame & lost ACK. Simple, robust, **low utilization** → inefficient for high bandwidth-delay product. Attributes solved: BER (corruption→NAK/timeout), lost data, lost ACK, duplicate (sequence bit). `03` §3.7.

### Go-Back-N

Sliding-window protocol with window size ≤ 2^n−1; **cumulative ACKs**; on error/loss/**timeout**, retransmit the lost frame **and all later frames** (go-back-N). Robust, simple; wasted bandwidth on big windows. Receiver discards out-of-order. VS SR (selective repeat): SR only resends the missing one (window ≤ 2^(n−1), per-frame ACK). `03` §3.8.

---

## 8.5 Multiple Access

### ALOHA

Random access: transmit **whenever you have data** (pure ALOHA) — collisions destroy both; retransmit after random backoff. **Pure ALOHA max throughput ~18%** (G=0.5); **Slotted ALOHA** (transmit only at slot boundary) → **~37%**. Introduced congestion by statistics; basis for CSMA. `04` §4.2.

### CSMA

**Carrier Sense Multiple Access** — listen before transmit (sense the medium): reduces collisions vs ALOHA. Variants: **1-persistent** (transmit immediately if idle; collide if simultaneous), **non-persistent** (wait random delay then sense again; better at high load), **p-persistent** (with prob p transmit on idle, else wait slot). `04` §4.3.

### CSMA/CD

**CSMA with Collision Detection** (wired Ethernet, 802.3): after sending, **detect collision** (voltage/bit corruption), then **backoff (binary exponential)** and retry with jitter. Only works because sender can listen while transmitting (copper/fiber). Collision detection window = worst-case round trip (2·τ); minimum frame length ensures this (≥ 2×propagation delay). Replaced by full-duplex switched links. `04` §4.4.

### CSMA/CA

**CSMA with Collision Avoidance** (802.11 wireless): because radio **can't listen while transmitting** (CD impossible) and has hidden terminal problem — do **carrier sense + DIFS + random backoff + RTS/CTS** (optional) + per-frame **ACK**. Frame exchange (RTS→CTS→DATA→ACK); avoids rather than detects. `04` §4.5.

### Reservation

**Reservation access** = stations reserve a fixed slot/schedule before transmitting (e.g., reservation frames in 802.4/some multiaccess, RTS/CTS, calendar-based scheduling) → deterministic, collision-free but overhead/round-robin. It's listed as controlled/predictive access.

### Polling

**Central controller (primary)** polls each secondary in turn ("do you have data?") — used by 802.11 PCF, old terminals/mainframes, PPPoE ownership. Pros: no collisions, bounded delay; cons: must poll all (even idle), controller is single point of failure.

### Token Passing

**Token circulates** among stations; a station may transmit only while holding the token, then passes it on — used in **token bus (802.4)**, **token ring (802.5)**, **FDDI**. Deterministic, fair, no collision, bounded worst-case delay; overhead of idle token circulation + token loss recovery; deployment basically retired.

### FDMA

Frequency Division Multiple Access: split the band into **narrow frequency channels**, each user gets one for the call duration — GSM, FDMA legacy. Simple, fixed allocation, **wastes when idle**; guard bands between channels.

### TDMA

Time Division Multiple Access: the band is shared in **time slots per user/cell** within a frame — GSM, T1/E1 trunking. Each user transmits in assigned slot (typically with guard time); efficient for constant-rate traffic; idle slots waste; synchronization needed between users.

### CDMA

Code Division Multiple Access: **all users transmit simultaneously in same band** using **orthogonal spreading codes**; the receiver correlates with its code to extract a user (2.4 GHz ISM coexisting, 3G UMTS, GPS). Privacy/simultaneity, resistant to interference + multipath, but receiver complexity + capacity affected by "near-far" problem/power control. Contrast FDM/TDM: frequency/time/code dimension.

---

## 8.6 Network Devices

### Repeater

Layer-1: **regenerates the signal** (amplifies + cleans timing) to extend the segment; does not segment collision/broadcast domain — increases reach *within* the same LAN domain. Case: long Ethernet runs, fiber optical lines.

### Hub

Layer-1 multiport repeater: forwards **every bit to every port**; all in the same **single collision + broadcast domain**, shares bandwidth; inefficient/scalability-limited; essentially obsolete (replaced by switches). CSMA/CD operates among all hub-attached hosts.

### Bridge

Layer-2 device with a few ports: **learns MAC addresses**, forwards only intended ports (filters), reduces collision domains / broadcast lightly; may interconnect different media (e.g., fiber↔copper), runs STP to avoid loops. One broadcast domain maintained; per-port MAC table.

### Switch

Layer-2 (or L3) **bridging filtered at scale**: **MAC table → only forward frames to the destination port** (or flood unknown/broadcast); per-port collision domains, high throughput, VLAN isolation, QoS/ACL; transparent to hosts, no IP awareness (L2). Also supports MAC learning/aging, port-based features.

### Router

Layer-3 device: **routes IP packets** using a route table (static/OSPF/BGP), **forwards** to next hop, **network segmentation/subnets**, default gateway, **NAT**, **firewall**, **DHCP/VPN**, interconnects WAN/VLANs, breaks collision + broadcast domains. `05`.

### Gateway

Broadest term: **any device (often a router, or a host running translations) that connects networks/protocols and performs protocol conversion** — e.g., a **default gateway** (the router you send unknown to) and **protocol gateways** (email gateway, API gateway, IoT→HTTP). In exam vocab: gateway = interface between unlike networks (translates address/protocol); router = but with routing.

### Device comparison

| Device | Layer | Function | Collision domain breaks? | Broadcast domain breaks? |
|---|---|---|---|---|
| Repeater/Hub | 1 | Signal regenerate/flood | No | No |
| Bridge | 2 | MAC filtering | Yes (per port) | No |
| **Switch** | **2** | MAC forwarding/VLAN | Yes (per port) | Per VLAN yes/global no |
| **Router** | **3** | Route + NAT + FW | Yes | Yes |
| Gateway | 3+ | Protocol translation | — | — |

Memory: **Hub of silence; switch = smart bridge; router = street sign + customs.**

---

## 8.7 Network Layer

### Routing

Choosing the **path/path-way** packets should take through the internetwork. Algorithms: **static** (admin-configured) vs **dynamic**; **distance-vector** (RIP/BGP — "tell neighbors everything about the network"), **link-state** (OSPF/IS-IS — everyone floods, everyone computes Dijkstra). Goals: best path by metric (hops, delay, cost), loop-free topology, convergence under failures. `05` §5.2.

### Forwarding

The **local action**: moving an **incoming packet from the ingress interface to the outbound interface** using the **routing table (longest prefix match)**; often hardware (TCAM) at line rate. Difference: routing = control plane (build table), forwarding = data plane (execute it).

### Routing algorithms

- **Distance-vector (Bellman-Ford):** each node keeps (dest, cost, next-hop), exchanges whole tables with neighbors periodically; slow convergence, count-to-infinity problem → mitigated with split horizon/poison reverse/path vector (BGP).
- **Link-state (Dijkstra):** flood link info to all, everyone computes SPT; fast convergence, more CPU; OSPF.
- Heuristics vs optimal: flooding, shortest path, hierarchical (area/AS) scaling.

### IPv4

32-bit address `198.51.100.7` (dotted decimal), ~4.29B addresses. Header 20B options; TTL, protocol, checksum, fragmentation supported. Exhausted → IPv6 + NAT. Classes (A/B/C private blocks) + CIDR + subnet masks — full table in `05` §5.3.

### IPv6

128-bit hex (`2001:0db8:…`); **8 groups of 16-bit**; :: compression; **vast address space** per subnet (SLAAC + EUI-64/later privacy), no NAT needed, better multicast/anycast, simplified fixed header, ICMPv6/NDP (replaces ARP), IPsec integrated. Transition: dual-stack, 6to4/6in4, NAT64, tunneling. Comparison table in `05`.

### IP addressing

IPv4 classes, private ranges (10/8, 172.16/12, 192.168/16), loopback 127/8, link-local 169.254/16 (APIPA), multicast 224/4, broadcast 255.255.255.255; CIDR notation `X.X.X.X/len`; subnetting/supernetting; DHCP + static. IPv6 link-local `fe80::/10`, unique local `fc00::/7`, global `2000::/3`.

### Subnetting

Splitting a block to create multiple logical networks (improve routing, isolate broadcast, security): borrow host bits for subnet ID; **formula: subnets = 2^s, hosts = 2^h − 2** (all-0 network, all-1 broadcast). CIDR + VLSM; examples numerically solved in `05` §5.5 and `10` `#subnetting--cidr`.

### Public vs Private IP

| | Public | Private |
|---|---|---|
| Use | Internet | LAN internal + NAT |
| Ranges | Any except reserved | RFC 1918 (10/8, 172.16/12, 192.168/16) + address/loopback |
| Uniqueness | Globally unique (IANA/RIR) | Only reused within orgs (duplicates everywhere) |
| In/out | Routed on Internet | Never routed by ISP; NAT at edge |
| Example | 8.8.8.8 | 192.168.1.5 (home) |

---

## 8.8 Transport Layer

### TCP

**Reliable, connection-oriented, byte-stream** protocol over IP. Features: **3-way handshake**, **sequence + ACK numbers**, **window-based flow control (rwnd)**, **congestion control (cwnd: slow start/CA/AIMD)**, **retransmission (timeout + fast retransmit)**, **duplicate ACKs / cumulative ACK**, **out-of-order buffering**, **port multiplexing**, checksum. Ordered byte stream delivered intact or error reported. Full in `06` §5.8.

### UDP

**Connectionless, unreliable** transport: datagrams, no handshake, no ordering/ack, minimal header (8B), no congestion control. Best for **real-time/DNS/SNMP/dhcp/streaming/quic-over-UDP**, multicast, broadcast, need low latency overhead.

### TCP vs UDP

| | TCP | UDP |
|---|---|---|
| Connection | Connection-oriented (3-way) | Connectionless |
| Reliability | Reliable (ACK + retransmit) | Best-effort (drop) |
| Order | Ordered byte stream | No ordering |
| Flow/congestion | Both | Neither (app controls) |
| Overhead | higher (20B header + state) | low (8B header) |
| Use | Web, email, file, DB | DNS, video, VoIP, gaming |
| Bidirectional | Full-duplex streams | Datagrams independent |

### Port numbers

16-bit (0–65535) demux at transport: **well-known 0–1023** (HTTP 80, HTTPS 443, FTP 21, SSH 22, DNS 53/UDP, SMTP 25), **registered 1024–49151**, **ephemeral 49152–65535**. `ip`/`netstat`/`ss` to inspect. Full port table in `07` + `10`.

### Flow control

Transport-layer prevention of **receiver buffer overflow** → **advertised window rwnd** (receiver tells sender how much space it has). Sender never exceeds min(cwnd, rwnd). Contrast with congestion control (network, cwnd) — table in `10` `#important-comparisons`.

### Congestion control

Detect/prevent **network congestion** (router buffer overflow → packet drops → timeout): **slow start** (1 MSS → double each RTT until ssthresh), **congestion avoidance** (AIMD linear), **fast retransmit/fast recovery** (3 dup-ACKs), **timeout → ssthresh halved, cwnd = 1**. Variants Reno/Cubic/Vegas/BBR. Diagram + math in `06` §5.10.

### TCP 3-way handshake

`Client SYN(seq=x)` → `Server SYN-ACK(seq=y,ack=x+1)` → `Client ACK(seq=x+1,ack=y+1)`. Purpose: **synchronize sequence numbers**, prove both directions, negotiate MSS/window; each side assigns ISN. Diagrams/`ss` states SYN_SENT/ESTABLISHED. `06` §5.9.

### TCP termination

**4-way**: `FIN` (A→B) → `ACK` (B→A) → `FIN` (B→A) → `ACK` (A→B) + TIME_WAIT (2·MSL) so late segments die and both sides know. Half-close possible (one side FIN only). States CLOSE_WAIT/LAST_ACK/FIN_WAIT_1/2.

### Reliable transmission

TCP guarantees: **positive ACK with retransmission** (timeout), **duplicate detection via sequence numbers**, **reordering/buffering** of out-of-order, **window sliding** on rwnd, checksums for corruption, packet loss/congestion via cwnd adaptation. Each segment's `seq/ack` gives the end-to-end byte stream order. (For the exam, contrast with Stop-and-Wait/GBN bit-level reliability on link.)

---

## 8.9 Application Layer

### DNS

Distributed hierarchical naming DB: **stub → recursive resolver → root → TLD → authoritative → answer** (cache + TTL). Records A, AAAA, CNAME, MX, NS, TXT, PTR, SOA, SRV. Ports UDP/TCP 53. Full `07` §6.2 + `10` for resolution scenario.

### DNS resolution

Walk the hierarchy when cache misses: root referral → TLD → authoritative → IP; iterative (resolver asks) vs recursive (server asks on client's behalf); caching at all levels speeds it up. Diagnostics: `nslookup`, `dig +trace`.

### HTTP

App layer protocol for the **Web**: stateless **request/response**: request line (method URI version), headers, body; response status + headers + body. Methods GET/POST/PUT/DELETE/HEAD/OPTIONS/PATCH (safe vs idempotent); status 1xx/2xx/3xx (redirect)/4xx (client)/5xx (server); **cookies** restore sessions. HTTP/1.1 keep-alive + pipelining; **HTTP/2** multiplexing+HPACK; **HTTP/3 = QUIC over UDP**. `07` §6.4.

### HTTPS

**HTTP + TLS**: certificate chain → server identity (X.509 vs trust anchors), **key exchange (ECDHE) + forward secrecy**, bulk **AES-GCM**, integrity via AEAD+MAC; port 443. `07` §6.5.

### FTP

File transfer: two parallel connections — **control port 21** (commands) + **data port 20** (active mode) or a high ephemeral port (passive mode); stateful — keeps session state (user home dir, cwd); ASCII/binary modes; **SFTP** = file transfer over SSH (port 22) — a distinct protocol from FTP. FTP vs HTTP: FTP = bidirectional, supports resume and permissions; HTTP = simple one-request web fetch. `07` §6.6. FTP vs HTTP: FTP = bidirectional file transfer/resume/perms; HTTP = simple one-request web fetch. `07` §6.6.

### SMTP

Simple Mail Transfer Protocol — **pushes mail**: client (MUA) → mail server (MTA) → next MTA (relay) via **MX records**; port 25 (relay) / 587 (submission) **plain text commands like HELO, MAIL FROM, RCPT TO, DATA, QUIT**; long header lines; servers may use STARTTLS/ESMTP. `07` §6.7.

### POP3

**Post Office Protocol v3** — retrieving mail: ports 110 (clear) / 995 (SSL/TLS); downloads (fetch-and-delete), local storage, offline usage. Good tutorial/exam: POP3 = pull discrete download.

### DHCP

Dynamic Host Configuration Protocol — **DORA** (Discover, Offer, Request, Ack) on UDP 67/68; assigns IP + mask + gateway + DNS + lease (T1 renew 50%, T2 rebind 87.5%); broadcast at start, relay across subnets. `07` §6.8.

### Firewall

Layer-3/4+ gatekeeper **filtering traffic by rules** (5-tuple ACLs, stateful, next-gen with app awareness). Blocks/permits based on policy — protects the network perimeter. `07` §6.9.

### Antivirus

Endpoint security: **virus/malware scanner** — signatures (hash/pattern DB) + heuristics + sandbox behavior; quarantines/removes locally. Works on the machine, not the network. Firewall vs AV comparison table in `07`.

---

## 8.10 Scenario Questions (13 classic walkthroughs)

### 1. What happens when you type `google.com`?

1. **Input parse**: URL `google.com` → browser applies HSTS/cache, HTTP internal.
2. **DNS resolution** (system stack): check browser cache → OS cache → hosts file → resolver → root/TLD/auth up the chain; returns IP(s).
3. **TCP connect**: 3-way handshake to IP:80/443 (443 HTTPS).
4. **TLS** (HTTPS): ClientHello → ServerHello + cert chain → verify (CA) → key exchange → cipher → encrypted app data.
5. **HTTP request**: `GET / HTTP/1.1` + Host/headers + cookies; server responds (200 → HTML/CSS/JS).
6. **Render**: DOM/event loop/parser → layout → paint; subresources (images/fonts) refetch via same TCP pool or HTTP/2 streams.

### 2. How does DNS resolve a domain?

**Stub resolver → query server (recursive)** → if not cached: root server gives TLD NS, TLD gives authoritative NS, authoritative answers A/AAAA→IP; resolver caches (TTL) and returns; **negative caching** too. Walk: `google.com` → root → `.com` NS → `google.com` NS → answer. (illustrate with `dig +trace`.)

### 3. How does DHCP assign an IP?

1. Client has no IP → broadcast **DHCPDISCOVER** (src 0.0.0.0 → dst 255.255.255.255, UDP 68).
2. Server (or relay) replies **DHCPOFFER** (proposed IP + lease + mask + gw + DNS + server-id).
3. Client broadcasts **DHCPREQUEST** (accepts offer).
4. Server sends **DHCPACK** (commit); client configs; renewal at 50% (unicast REQUEST) → reACK; T2=87.5% rebind via broadcast.

### 4. How does a router forward a packet?

Ingress NIC → decap to IP → **routing decision via longest-prefix routing table lookup (FIB)** → if dest=own interface, go upward; **next hop chosen** → resolve next-hop MAC (ARP/NDP) → **change Layer-2 src/dst MACs** (IP unchanged) → queue/egress to outbound interface → transmit. NAT may rewrite source before that. Each hop repeats L2 rewrite.

### 5. How does a switch forward a frame?

Switch receives frame on a port → **learns source MAC → port in MAC table** (aging) → **looks up dest MAC**: known → forward to that port only; unknown → **flood** all ports (except ingress); multicast/broadcast → flood; VLAN tag respected; optional STP prevents loops; per-port MAC learning avoids unicast flooding.

### 6. How does TCP establish a connection?

Client sends **SYN seq=x** → server replies **SYN+ACK seq=y, ack=x+1** → client **ACK seq=x+1, ack=y+1**. Both sides now synchronized, connection ESTABLISHED; window/MSS negotiated; then byte-stream flows (sequence numbers continue by bytes sent). States: CLOSED → SYN_SENT → ESTABLISHED (client); LISTEN → SYN_RCVD → ESTABLISHED (server).

### 7. What happens when a packet is lost?

Sender times out (RTO) or sees **3 duplicate ACKs** → retransmit. If congestion was the cause → **slow start / fast recovery** kicks in (cwnd cuts, ssthresh halves). At transport: TCP recovery; at link: retransmission of frame (if benign); at DNS: retry queries; at app: UDP apps may simply drop (call/game) → Quality handling at app layer.

### 8. Why does HTTPS use TLS?

Classic Internet: HTTP is **plaintext** — anyone sniffing/on-path can read, tamper, replay (passwords, banking, sessions). TLS adds **confidentiality** (encrypt), **integrity** (AEAD/MAC), **authentication** (server certificate chain → prevents impersonation) + forward secrecy → modern commerce/identity depends on it (HSTS, PCI, etc.).

### 9. Why do we need NAT?

IPv4 **address exhaustion** — orgs reuse private RFC1918 space behind one public IP via **PAT (NAPT)**. Also gives topology hiding (protect internal IPs) and lets ISP issue limited public addresses; simple firewall-ish by default (unsolicited inbound dropped). IPv6 reduces the need (ample addresses) — see §7.3.

### 10. Why do we need subnetting?

**Efficient addressing & management**: shrink broadcast domains, isolate traffic, apply per-subnet security/QoS/policies, allow **route summarization** (supernetting) for small routing tables, split an org's block into logical departments/floors without renumbering; IP addressing efficiency — borrow host bits so you don't waste addresses. Worked: `10` `#subnetting--cidr`.

### 11. Why is DNS required?

Because humans remember **names**, machines use **numbers**, and a single hosts file **cannot scale** (updates, SPOF, traffic, geography) → distributed hierarchical replicated database + caching + TTL indirection (load balancing, failover, CDN possible under one name). See §7.1/`07` 6.2 "Why DNS is required".

### 12. What happens when DNS fails?

Effects: domain resolution fails → apps report "can't resolve host" (`nslookup` fails, `dig` NXDOMAIN/SERVFAIL, browser error). Diagnose: check local cache (`ipconfig /flushdns`), `/etc/resolv.conf`/DNS servers, test alternate resolver (`8.8.8.8`, `1.1.1.1`), verify hosts file, corporate split-horizon/DNS poisoning, ISP outage, TTL/cache corruption. Workaround: use IP directly (won't help virtual hosts), fix DNS servers; re-query after TTL.

### 13. What happens when the default gateway is unavailable?

Hosts within the LAN keep working locally, but **all external traffic fails** (no route out). Symptoms: ping local works, ping Internet fails; `tracert` shows stuck at first hop; ARP for gateway unanswered. Diagnose gateway link (`ip route show default`, ARP, NIC lights, `ping gateway`), restart router/link, check DHCP/DNS scope, VLAN/config, static routes; `ipconfig /renew` or re-add default route.

---

## Chapter 8 Revision

### Interview traps to avoid
- MAC vs IP (which is flat/permanent); OSI vs TCP/IP; TCP vs UDP (ordering/reliability); flow vs congestion control (rwnd vs cwnd); encapsulation vs decapsulation direction; NAT vs subnetting purpose; DNS vs DHCP job split.

### Scenario usage ladder
DNS resolve → TCP handshake → TLS → HTTP → render (question "type a URL"); DHCP DORA on boot; router hop = L2 rewrite + L3 forward; switch = MAC learning/flood; loss → retransmit + cwnd shrink; NAT/PAT for private internet; subnetting for isolation; gateway down = no egress.

### Exam questions
1. Answer each 8.1–8.9 item as a definition + one-line example.
2. Where do firewall rules and antivirus scanning each live (L3/4 network vs endpoint)?
3. Given captures: traffic to 443 with certs — TLS; repeated seq numbers — retransmission; SYN flood — congestion/handshake issue.
4. Numericals from this chapter → done in `10-final-exam-prep.md`.

---

*Proceed to [10-final-exam-prep.md](10-final-exam-prep.md) — definitions, diagrams, numericals (CRC/Hamming/subnetting/delays) and the 18 comparison tables for final revision.*