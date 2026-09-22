# Network — FINAL NOTES (The Night-Before Sheet)

> One page, everything you must be able to say cold: the syllabus core from [`TODO.md`](TODO.md). Read these, then drill with [`notes/09-interview-questions.md`](notes/09-interview-questions.md) and [`notes/10-final-exam-prep.md`](notes/10-final-exam-prep.md).

## The 3 memory backbones
1. **No internet, no phone call**: a network = nodes + links + protocols; the *protocol* is the "what/when" contract.
2. **Stacks**: OSI 7 (Ph-D-Da-N-T-Se-Pr-A) ↔ TCP/IP 4 (App-TCP/IP-Link). Encapsulation adds headers going down; decapsulation strips going up.
3. **The pipe**: bits → frames (L2, MAC) → packets (L3, IP) → segments (L4, TCP/UDP) → app data.

## Layer truths you will be asked
- **Physical**: bits on wire/air; repeater & hub regenerate/flood.
- **Data link**: framing, MAC, CRC + ARQ; switch (L2) forwards by MAC table.
- **Network**: routing & forwarding, IP addressing + subnetting/CIDR; router (L3) = route + NAT + gateway.
- **Transport**: TCP (reliable, ordered, flow+congestion) vs UDP (fast, no guarantees); ports 0–65535.
- **Application**: HTTP 80 / HTTPS 443 / DNS 53 / DHCP 67-68 / SMTP 25-587 / POP3 110 / IMAP 143 / FTP 21-20 / SSH 22.

## Devices cheat-sheet (layer = the one they "operate" on)
| Device | Layer | Job |
|---|---|---|
| Repeater | 1 | Regenerate signal |
| Hub | 1 | Flood to all ports |
| Bridge / Switch | 2 | MAC learn + forward; switch isolates collision domains |
| Router | 3 | Route + forward + NAT/NAT-PAT + firewall |
| Gateway | 3+ | Protocol-translate between unlike networks |

## The equations (all exam-favorite)
- `subnets = 2^s`, `hosts per subnet = 2^h − 2`
- `transmission delay = bits / rate`; `propagation delay = distance / c`
- S&W utilization = `t_trans / (t_trans + 2·t_prop)`; window needed ≥ `R·RTT / L`
- CRC: append n zeros (deg of generator), mod-2 divide, append remainder; remainder 0 ⇒ no error
- Hamming redundancy: `2^r ≥ m + r + 1`; parity bits at positions 1,2,4,8…; error bit = binary of failing parities
- Checksum: one's-complement sum, wrap carry, take complement, re-sum at receiver ⇒ all-ones
- Throughput = min(link capacities on path)
- Utilization up: pipelining, sliding window, big windows; drop: ACK per RTT on S&W

## 13 scenarios (interview gold — say each aloud)
1. **Type a URL** → DNS → TCP 3-way → (HTTPS: TLS) → HTTP GET → render.
2. **DNS resolution** → cache → resolver → root → TLD → authoritative → cached answer.
3. **DHCP** → Discover → Offer → Request → Ack (DORA), lease renew 50% / rebind 87.5%.
4. **Router forward** → look up best route (longest prefix) → rewrite MACs, keep IP → next hop.
5. **Switch forward** → learn src MAC, lookup dst → known port or flood.
6. **TCP connect** → SYN, SYN-ACK, ACK (seq+ack synchronization).
7. **Packet lost** → timeout / 3 dup-ACK → retransmit + congestion window shrink.
8. **Why HTTPS uses TLS** → plaintext HTTP = interceptable; TLS gives confidentiality+integrity+server auth.
9. **Why NAT** → IPv4 exhaustion, hide topology, one public IP shared (PAT); IPv6 removes the need.
10. **Why subnetting** → shrink broadcast domains, isolate, summarize (CIDR), per-zone policy.
11. **Why DNS** → humans remember names, machines use numbers; single hosts-file can't scale → distributed hierarchy + cache + TTL.
12. **DNS fails** → resolution errors; check cache/flush, resolv.conf, alternate 8.8.8.8/1.1.1.1, hosts file, split-horizon, TTL, ISP DNS outage.
13. **Gateway down** → LAN works, all egress fails; check default route, ARP for gateway, link/NIC, restart, DHCP renew.

## Troubleshooting ladder (memorize in this order)
`ping` (host alive?) → `tracert`/`traceroute` (where path breaks) → `nslookup`/`dig` (name resolves?) → `ipconfig`/`ip`/`ifconfig` (am I configured? default gateway?) → `netstat`/`ss` (is the port listening?) → `curl` (does the service answer on HTTP?)

## 18 comparisons in one breath
OSI↔TCP/IP · LAN↔MAN↔WAN · Simplex↔Half↔Full · Analog↔Digital · Serial↔Parallel · FDM↔TDM↔WDM · Circuit↔Packet · TCP↔UDP · IPv4↔IPv6 · MAC↔IP · Switch↔Router · Hub↔Switch · CSMA/CD↔CSMA/CA · Flow↔Congestion · HTTP↔HTTPS · DNS↔DHCP · SMTP↔POP3 · Firewall↔Antivirus.

## Final self-test gate
Can you, with a blank page: draw OSI + TCP/IP + 3-way handshake + DNS loop + DHCP DORA? Solve CRC, Hamming, subnetting, S&W delay cold? Answer every scenario in 60 seconds? Then tick `TODO.md` and walk in.

*Companion files: [`notes/README.md`](notes/README.md) (index + reading order), [`notes/10-final-exam-prep.md`](notes/10-final-exam-prep.md) (numericals + tables), [`notes/09-interview-questions.md`](notes/09-interview-questions.md) (drill bank).*