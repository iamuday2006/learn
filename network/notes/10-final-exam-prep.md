# 10 — Final Exam Preparation (Definitions, Diagrams, Numericals, Comparisons)

> Reference: TODO "Final Exam Preparation" (important definitions, important diagrams, important numericals, important comparisons). | Priority: **MUST KNOW** for college + IT exams — this file is the last-24h revision hub; interactively: read down, cover the answers, recite aloud.
>
> **Jump-to anchors used by other note files:** [`#crc`](#crc) · [`#hamming-code`](#hamming-code) · [`#subnetting--cidr`](#subnetting--cidr) · [`#sliding-window--delays`](#sliding-window--delays) · [`#numericals`](#numericals) · [`#important-comparisons`](#important-comparisons)

---

## Important Definitions

Say each out loud in one or two sentences, then add the technical detail after.

| Term | Definition (exam-marked core) |
|---|---|
| **Network** | Interconnection of two or more independent devices via communication links, sharing resources and data according to protocols. |
| **Protocol** | The set of agreed rules governing the syntax, semantics, and timing of data exchange between entities. |
| **LAN** | Local Area Network — a network confined to a building/campus, high speed, privately owned (Ethernet/Wi-Fi). |
| **MAN** | Metropolitan Area Network — typically spans a city, interconnecting LANs (fiber ring, WiMAX). |
| **WAN** | Wide Area Network — spans countries/continents, formed by routers + leased links (the Internet). |
| **OSI** | Open Systems Interconnection — ISO's 7-layer reference model (Physical → Data Link → Network → Transport → Session → Presentation → Application). |
| **TCP/IP** | The actual protocol suite of the Internet: Application, Transport (TCP/UDP), Internet (IP), Link. |
| **Packet** | A protocol data unit at the network layer — IP header + payload (fragment of the transport stream). |
| **Frame** | A data-link-layer PDU — MAC headers + payload + FCS/CRC, carrying a packet within a LAN segment. |
| **Switching** | The process of establishing/assigning paths or forwarding data units between nodes (circuit/packet/message). |
| **Routing** | Selecting the best path through a network for packets (control plane), often vs **forwarding** (data plane execution). |
| **IP address** | 32-bit (v4) / 128-bit (v6) logical node address, hierarchical (network + host) for inter-network routing. |
| **MAC address** | 48-bit hardware address of the NIC, unique within LANs, used for frame delivery (Layer 2). |
| **Port** | 16-bit transport identifier (0–65535) selecting the application process on a host. |
| **DNS** | Distributed hierarchical naming system translating domain names ↔ IP addresses (UDP/TCP 53). |
| **DHCP** | Dynamic Host Configuration Protocol — auto-assigns IP/mask/gateway/DNS via DORA (UDP 67/68). |
| **HTTP** | HyperText Transfer Protocol — stateless request/response Web protocol (TCP 80). |
| **TCP** | Transmission Control Protocol — reliable, connection-oriented, ordered byte stream (flow + congestion control). |
| **UDP** | User Datagram Protocol — connectionless, unreliable datagrams, low overhead; used by real-time/DNS. |

Extra one-liner extras that appear in model answers: **Encapsulation** = adding headers as data descends the stack; **Decapsulation** = stripping them on the way up. **Checksum** = one's-complement sum used for integrity; **CRC** = polynomial-division remainder for burst-error detection; **CSMA/CD** = listen, transmit, detect collision, backoff; **CSMA/CA** = listen + avoid collisions (RTS/CTS + ACK) for wireless; **ARP** = resolve IP→MAC on a segment; **NAT** = rewrite src/dst addresses at the edge to conserve public IPv4; **TTL/HL** = max hops (decremented per router); **MTU** = max frame payload size on a link (typical 1500 B).

---

## Important Diagrams

Practice drawing each freehand with labelled boxes and arrows; check against the chapter for the full picture.

1. **OSI model** — 7 stacked layers, top→bottom: Application, Presentation, Session, Transport, Network, Data Link, Physical; note device per layer (switch L2, router L3).
2. **TCP/IP model** — 4/5 layers; side-by-side mapping OSI↔TCP/IP.
3. **Encapsulation** — `data → segment(TCP) → packet(IP) → frame(Eth)` wrapping; also decapsulation downward arrow.
4. **Network topologies** — bus, star, ring, mesh, tree, hybrid (`01` §1.4).
5. **Circuit switching** — dedicated path with setup diagram (A–B through 3 switches, reserved).
6. **Packet switching** — store-and-forward, packets may take different routes, out-of-order arrival.
7. **CRC** — sender division table (mod-2), reminder appended; receiver division remainder = 0 (`03` §3.4 + [`#crc`](#crc) below).
8. **Sliding Window** — sender window of sequence numbers sliding as ACKs arrive; track cwnd/rwnd.
9. **Go-Back-N** — timeline: frame 2 lost → retransmit frames 2..N, receiver discards out-of-order (`03` §3.8).
10. **CSMA/CD** — X->Y collision near shared cable: both detect within 2·τ, backoff, retry.
11. **CSMA/CA** — DIFS + backoff slots + RTS/CTS handshake reserve the channel, then DATA, then ACK.
12. **Network devices** — host → hub/switch/router/gateway chain with layer labels (repeater L1, hub L1, switch L2, router L3, gateway L4+).
13. **TCP 3-way handshake** — `SYN → SYN-ACK → ACK` with seq/ack values (`06` §5.9).
14. **TCP termination** — `FIN → ACK → FIN → ACK` 4-way + TIME_WAIT.
15. **DNS resolution** — browser cache → host cache → resolver → root → TLD → authoritative → answer back (`07` §6.2).
16. **DHCP DORA** — 4 broadcast/unicast messages Discover→Offer→Request→Ack (`07` §6.8).
17. **HTTP request/response** — request line + headers + body; response status + headers + body (`07` §6.4).

Top-5 to actually draw in the exam: **OSI, TCP/IP, 3-way handshake, DNS resolution, DHCP DORA.**

---

## Important Numericals (#numericals)

Worked, exam-relevant problems. Do them again without looking, checking units as you go.

### Transmission delay (#numericals)

Time to push all bits onto the link = **packet bits / link rate**.

`L = 1000 bytes = 8000 bits, R = 1 Mbps = 10⁶ bps → t_trans = 8000 / 10⁶ = 8 ms`.

### Propagation delay

Time for a bit to travel the link = distance / speed (typical copper/fiber ≈ 2×10⁸ m/s).

`d = 2000 km broadcast, v = 2×10⁸ m/s → t_prop = 2000×10³ / 2×10⁸ = 10 ms`.

Total time (no queueing) = t_trans + t_prop; for store-and-forward router count each hop's t_trans.

### Throughput

**min(bottleneck link, per-flow share)** = smallest capacity across the path.

`path: host(100 Mbps) → router(10 Mbps) → server(50 Mbps) with 5 flows sharing the 10 Mbps → per-flow ≤ 2 Mbps; overall ≤ 10 Mbps`.

Check: throughput bottleneck = __min of links__, not average.

### CRC (#crc)

**Procedure: divide `data·2ⁿ` (append n zeros, n = generator bits − 1) by generator (mod-2), append the n-bit remainder (FCS). Receiver divides data+FCS; remainder 0 ⇒ no error.**

Worked classic (mod-2 division, XOR without borrow):
- Data `1101011011`, generator G = `10011` (deg 4 → append 4 zeros): `11010110110000 ÷ 10011 → remainder 1110` → transmitted = data + `1110`.
- Receiver recomputes: no leftover → accepted; else discard/retransmit.
- Capability: detects all burst errors ≤ n bits, any odd number of bit errors, all patterns not divisible by G. CRC-32 (Ethernet) → 32-bit FCS.

### Checksum

One's-complement sums (wrap-around carry added back); sender complements → FCS; receiver sums all (incl. FCS) → all 1-bits ⇒ ok.

Worked in `03` §3.3 (sum, carry wrap, complement).

### Hamming Code (#hamming-code)

**Rule: place parity bits at positions 2^i (1,2,4,8…); each parity covers positions where that bit ∈ the position's binary index; extra overall parity → SEC-DED. `2^r ≥ m + r + 1` picks r; formula locates the erroneous bit position.**

Worked in `03` §3.5:
- m=4 data bits, need r: 2³=8 ≥ 4+3+1=8 → r=3, positions p1,p2,p4.
- Build codeword, transmit; receiver recomputes → the *binary* of failing parities (p4 high bit, p2, p1 low) gives the wrong bit's position → flip it.

**Practise the spins:** how many parity bits for 8/16 data bits (answer 4/5), single-error correction.

### Sliding Window & Delays (#sliding-window--delays)

**Stop-and-Wait link utilization = t_trans / (t_trans + 2·t_prop)** (WAIT most of high bandwidth-delay). With window W: utilization ≈ **W·t_trans / (t_trans + 2·t_prop)**, sent bytes = W·L.

Worked: `L = 1000 B = 8000 bits, R = 10 Mbps → t_trans = 0.8 ms; link 5000 km, v=2×10⁸ → t_prop = 25 ms`. RTT = 2×t_prop = 50 ms. S&W utilization = 0.8/(0.8+50) ≈ **1.6%**. To fill the pipe: W ≥ (0.8+50)/0.8 ≈ 63.5 → round up (or bits: bandwidth-delay product = R×RTT = 10⁷×0.05 = 500,000 bits = 62500 B → window ≥ 63 frames) →

With W≥64: utilization ≈ 100%. See `03` §3.6–3.8 for GBN timing diagrams.

### Basic IP addressing

- IPv4 is 32 bits: `198.51.100.7/24` → net `198.51.100.0`, broadcast `198.51.100.255`, hosts `254`.
- Convert: `192.168.1.150` → binary, and back. Private: `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`.

### Subnetting & CIDR (#subnetting--cidr)

**Formulas: subnets = 2^s (s = borrowed host bits); usable hosts/subnet = 2^h − 2 (minus network + broadcast).**

Worked 1: **/24 → 4 subnets of /26.** Borrow 2 bits → s=2, subnets = 4, h = 26−? no: host bits = 32−26 = 6 → hosts = 2⁶−2 = 62. Subnets: `…0/26`, `…64/26`, `…128/26`, `…192/26`. Broadcasts: last of each (+63).

Worked 2: **CIDR supernet:** `192.168.8.0/24 + 192.168.9.0/24 … 192.168.15.0/24` (8 × /24) → summarize as `192.168.8.0/21` (align to 8 → 8 blocks). Bandwidth/debugs: only advertise one prefix, aggregation.

Worked 3: Hosts needed 500 → choose /23: 2⁹−2=510 hosts; block size 512 → 192.168.10.0/23 covers 10.0–10.1.255.

**Do not skip:** how many IPs in /30 (2 usable), what's the subnet for `172.20.30.45/27` (start = 32×⌊45/32⌋? → 172.20.30.32/27, broadcast …63, hosts 33–62).

---

## Important Comparisons (#important-comparisons)

The 18 tables the exam loves — fill in the second column from memory, then check the chapter.

1. **OSI vs TCP/IP** — 7 vs 4/5 layers; standard-first vs implemented-first; session/presentation folded (`09` 8.1).
2. **LAN vs MAN vs WAN** — scope, ownership, speed, latency (`09` 8.1).
3. **Simplex vs Half vs Full duplex** — one-way vs either-but-not-both vs simultaneous both directions.
4. **Analog vs Digital** — continuous vs discrete; noise/regeneration (`01`, `09` 8.2).
5. **Serial vs Parallel** — 1 lane vs N lanes; skew/crosstalk kills parallel at high speed (`09` 8.2).
6. **FDM vs TDM vs WDM** — frequency/time/wavelength division; guard bands vs slots vs colors (`01`, `09` 8.2).
7. **Circuit vs Packet** — dedicated path/resources vs shared/statistical; latency vs efficiency (`02`, `09` 8.3).
8. **TCP vs UDP** — connection/reliability/order/overhead/use cases (`06`, `09` 8.8).
9. **IPv4 vs IPv6** — 32 vs 128-bit; NAT vs no-NAT; header; ARP vs NDP (`05`, `09` 8.7).
10. **MAC vs IP** — L2 burned-in flat local vs L3 logical hierarchical global (`08` 7.2).
11. **Switch vs Router** — L2 MAC forward vs L3 route+forward+NAT/FW; collision/broadcast domain split (`04`, `09` 8.6).
12. **Hub vs Switch** — L1 flood-all vs L2 smart filter; single vs per-port collision domain.
13. **CSMA/CD vs CSMA/CA** — detect on wired vs avoid on wireless; 2·τ minimum frame vs RTS/CTS+ACK (`04`).
14. **Flow vs Congestion control** — receiver buffer overflow (advertised window rwnd) vs network overload (cwnd/AIMD) (`06`, `09` 8.8).
15. **HTTP vs HTTPS** — 80 vs 443; plaintext vs TLS (confidentiality/integrity/auth) (`07` §6.4–6.5).
16. **DNS vs DHCP** — name↔IP resolution (hierarchy + cache, UDP 53) vs IP assignment (DORA, UDP 67/68) (`07` §6.2/6.8).
17. **SMTP vs POP3** — push mail (25/587) vs pull (110); server-side relay vs client download (`07` §6.7).
18. **Firewall vs Antivirus** — network traffic gatekeeper vs endpoint malware scanner (`07` §6.9).

> Recall pattern for all 18: **(purpose / layer / port(s) / one concrete difference)** — that fits any exam variant.

---

### 5-minute sky-check

1. Name the 7 OSI layers bottom-up. 2. Which layer does a switch live in? 3. Ports for HTTP, HTTPS, DNS, DHCP server, SMTP, POP3? (80, 443, 53, 67, 25, 110.) 4. `2^r ≥ m+r+1` — what code? 5. Lowest-division remainder proves what? 6. Two things NAT solves; one it can't (address exhaustion; topology hiding; breaks end-to-end/needs ALG). 7. CSMA/CD vs CSMA/CA one-line each. 8. What does DHCP DORA stand for? 9. Which protocol is ordered & reliable vs unordered & fast? 10. With `ping` failing but `nslookup` working — where's the break? (routing/host unreachable ≠ DNS.)

*Then read [FINAL_NOTES.md](../FINAL_NOTES.md) for the one-page confessional and interview polish.*