# 06 — Transport Layer & Network Security

> Reference: Kurose & Ross Ch. 3 (transport layer: UDP/TCP, connection establishment, congestion control) + classic syllabus (security/cryptography basics). | TODO Chapter 5 §5.6–5.11 | Priority: **MUST KNOW** — TCP handshake and flow vs congestion control are interview staples

---

## 5.6 Transport Layer

### Purpose of Transport Layer

Layer 4 — **process-to-process (application-to-application) delivery on the destination host**, complementing the network layer's host-to-host job. The IP layer gets packets to the right *machine*; the transport layer gets the data to the right *program* (browser, mail client, game) on that machine — and defines **how well** delivery happens (reliable/ordered vs best-effort).

Core functions:
- **Segmentation & reassembly** — split app data into **segments**, number them, rebuild in order at the receiver.
- **Port addressing (demultiplexing)** — deliver to the correct socket/process.
- **End-to-end error control** (TCP) — ACKs, retransmission, in-order delivery.
- **Flow control** — match sender rate to *receiver's* buffer (protect receiver).
- **Congestion control** — match sender rate to *network's* capacity (protect the network).
- Connection management for connection-oriented service (setup/teardown).

> Interview answer: "The transport layer provides end-to-end, process-to-process communication between applications using port numbers. TCP gives reliable, ordered, congestion- and flow-controlled delivery; UDP gives minimal, connectionless best-effort datagrams — and the network layer in between only guarantees host-to-host best-effort forwarding."

### Process-to-process communication

Host-to-host (IP) is not enough: one server runs web, mail and DNS simultaneously; many clients hit it at once. The transport layer uses the **(src IP, src port, dst IP, dst port)** 4-tuple (**socket/flow identity**) to multiplex many conversations onto one host:

- **Multiplexing (sender):** gather data from multiple app processes, attach transport headers with **their own port numbers**, hand segments to IP.
- **Demultiplexing (receiver):** on arrival, use the **destination port** (and for TCP the full 4-tuple) to hand payload to the correct waiting socket/process.

### Port numbers

16-bit identifier (0–65535) of an application endpoint, carried in TCP/UDP headers.

| Range | Name | Use |
|---|---|---|
| **0 – 1023** | Well-known / system ports | Standard services: 20/21 FTP, 22 SSH, 23 Telnet, 25 SMTP, 53 DNS, 67/68 DHCP, 80 HTTP, 110 POP3, 143 IMAP, 443 HTTPS, 3306 MySQL… (binding needs admin) |
| **1024 – 49151** | Registered / user ports | Registered by vendors (e.g., 3306/5432 common DB, 8080 alt-http) — apps request them via IANA |
| **49152 – 65535** | Dynamic / ephemeral / private | Client sockets pick a free ephemeral port per outgoing connection automatically |

*Key facts:* ports are **per-host** namespaces (same number on different hosts are unrelated); a service **listens** on its well-known port while clients use ephemeral ports; TCP & UDP have **separate** port spaces (port 53-TCP = zone transfer, 53-UDP = normal queries).

### Segments

The **transport PDU**: payload from the application + transport header.

```text
 TCP segment: [ src port | dst port | seq# | ack# | flags | window | checksum | options | DATA ]
 UDP datagram: [ src port | dst port | length | checksum | DATA ]
```

- **MSS (Maximum Segment Size)** — max payload per segment, derived from path/interface **MTU** minus IP+TCP headers (e.g., MTU 1500 − 20 IP − 20 TCP = MSS 1460).
- Receiver **reassembles** using sequence numbers; out-of-order segments buffered (TCP) or delivered anyway (UDP).

### Multiplexing (sending side)
App → transport: each outgoing chunk tagged with the source port (and destination port of the service). One host runs many apps; one IP address serves all of them through distinct ports. TCP's 4-tuple lets even **same port pairs** (multiple clients to port 80) stay separate flows via different client ephemeral ports.

### Demultiplexing (receiving side)
- **TCP:** match incoming segment's **4-tuple (dst IP, dst port, src IP, src port)** exactly to the established connection control block → correct socket (also enables simultaneous different connections from same client IP if ephemeral ports differ).
- **UDP:** match **dst port only** (connectionless — no 4-tuple state) → socket; unknown port → ICMP port-unreachable.

---

## 5.7 Transport Services

### Reliable communication

End-to-end guarantee that data arrives **completely, correctly and in order**, or failure is reported — implemented by TCP via:

- **Sequence numbers** on every byte (TCP numbers *bytes*, not just segments).
- **Cumulative ACKs** ("received all bytes < next expected").
- **Timeouts + fast retransmit** (3 duplicate ACKs) → retransmission.
- **Checksum** over pseudo-header (src/dst IP + ports + TCP header/data) — catches corruption; corrupted segments dropped (no ACK → retransmit).
- **In-order delivery** via buffering out-of-order segments.
- **Duplicate suppression** by sequence numbers.

UDP & raw IP: **no reliability** (fire-and-forget) — apps that need it implement it themselves or use TCP/QUIC.

### Connection-oriented service

- **Setup before data:** TCP three-way handshake (SYN → SYN-ACK → ACK) agrees on initial sequence numbers (ISNs), options (MSS, window scale, SACK), and wakes both sockets.
- **Stateful:** both sides maintain the connection state (TCB): seq numbers, windows, timers, status (SYN-SENT, ESTABLISHED, FIN-WAIT…).
- **Graceful teardown** with FIN/ACK exchange so both sides flush data.
- **Ordered, reliable byte stream** over the connection — exactly what HTTP/FTP/SMTP expect.
- Contrast: UDP is **connectionless** — no setup, no state, each datagram independent (DNS, DHCP, VoIP, game packets prefer this).

*(Network-layer view of "connection": virtual circuits — Ch 2 — are different: state in routers. TCP is an **end-to-end connection in hosts only**; routers stay connectionless.)*

### Connectionless service

- No setup/teardown; each segment (UDP datagram) standalone with full port info.
- No ordering, reliability, or duplicate guarantees; minimal header (8 B UDP vs 20+ B TCP) → low latency/overhead.
- Unpredictable delay/jitter possible; caller may add its own app-level ACK/retry if needed.
- Examples: DNS queries, DHCP, SNMP, NTP, RTP media streams, live games (loss tolerable, latency not).

### Flow control (transport)

Protects the **receiver's buffer**: receiver advertises a **receive window (rwnd)** in every TCP header = how much more data it can buffer *right now*. Sender's usable window = **min(cwnd, rwnd)** (see congestion §5.10). When app is slow to read, rwnd shrinks (possibly to 0) → sender must stop/throttle; TCP does **zero-window probing** to learn when space returns — prevents receiver buffer overflow & forced segment drops.

### Congestion control

Protects the **network** from too many senders at once: TCP probes for capacity by slowly increasing rate (**slow start** → **congestion avoidance**), and backs off sharply on loss/ECN signals (assumed congestion) — **AIMD (additive increase, multiplicative decrease)** sawtooth around the fair share. Detail in §5.10. Distinct from flow control: that's *receiver*-limited, this is *path*-limited.

### Error control (transport)

- Detection: **checksum** (TCP mandatory, UDP optional but usually on) over pseudo-header + payload; bad segment silently discarded (TCP will recover via timeout/dup-ACK; UDP won't).
- Recovery: retransmission via **RTO timeout** and **fast retransmit** (3 dup ACKs → skip waiting for full RTO).
- The network layer does not retransmit ( routers just drop ); link layer may ARQ per hop (Ch 3) — but **only end-to-end transport gives true host-to-host reliability** (each hop's success doesn't guarantee path success — end-to-end argument).

---

## 5.8 TCP

### TCP overview

**Transmission Control Protocol** — the Internet's flagship **connection-oriented, reliable, byte-stream** transport. Full-featured: connection management, ordered delivery, retransmission, flow control *and* congestion control. Almost all "must arrive correctly" traffic (web, email, file transfer, APIs) rides TCP. (Kurose Ch. 3.5: "principles of reliable data transfer" → TCP as the concrete protocol.)

### TCP features

- **Connection-oriented** — 3-way handshake before data; graceful FIN teardown.
- **Reliable** — ACKs, retransmission, checksum, in-order byte stream.
- **Byte-stream service** — no message boundaries preserved (unlike UDP/datagram); app frames via delimiters/lengths.
- **Full-duplex** — both directions simultaneously, each direction has independent seq/ACK/window.
- **Flow-controlled** — receiver's rwnd honored.
- **Congestion-controlled** — sender rate adapts to network (slow start, CA, fast recovery).
- **Stream-oriented segmentation** — MSS-sized segments, piggybacked ACKs, delayed ACK, Nagle batching options.
- **20-byte minimum header** with options (MSS, timestamps, SACK permitted, window scale).

### TCP segment (header essentials)

```text
+-------------------------------+------+
| src port (16) | dst port (16) |      |
+-------------------------------+      |
|         sequence number (32)         |
+-------------------------------+      |
|     acknowledgment number (32)       |
+---+---+---+---+---+---+------+-------+
|Hd |rsv|C E U A P R S F | window (16) |
+---+---+---+---+---+---+------+-------+
|  checksum (16)        | urgent (16)   |
+-----------------------+--------------+
| options (MSS, wscale, SACK, TS...)   |
+--------------------------------------+
|              DATA ...                |
```

- **Seq #** — byte offset of this segment's first data byte in the stream (ISN randomised for security).
- **ACK #** — next byte the receiver expects (**cumulative**: "everything before it received").
- **Flags:** SYN (connect), ACK, FIN (close), RST (abort), PSH (push now), URG (urgent pointer valid).
- **Window** — receiver's advertised buffer space (flow control) in bytes.
- **Checksum** — mandatory, includes IPv4 pseudo-header (src/dst IP, protocol, TCP length).
- Options: **MSS**, **Window Scale** (multiply rwnd > 64 KB), **SACK** (selective ACK of holes), **Timestamps** (RTT measurement, PAWS).

### Sequence number

- Counts **bytes**, not segments: SYN/FIN each consume 1 sequence number; data segment's seq = first data byte's stream offset.
- Sender: `next_seq = seq + data_length`; receiver's **ACK = seq + length** (next expected byte).
- Enables: ordering, reassembly, duplicate detection, gap identification (→ SACK/fast retransmit), window arithmetic (`send_unack` … `send_next` within window).

### ACK

- **Cumulative acknowledgment:** ACK n ⇒ "all bytes up to n−1 arrived; send n next."
- Delayed ACK (wait ~40 ms for piggyback opportunity, but ACK every 2nd full segment / must within 500 ms).
- **Fast retransmit trigger:** **3 duplicate ACKs** (ACK = same value 3×) ⇒ sender infers segment after that point lost, retransmits **without waiting for timeout** (assumes gap not reordering).
- **SACK** option: receiver lists non-contiguous blocks received → sender retransmits *only holes* (selective reject behavior on top of cumulative ACK base).

### Retransmission

Triggers:
1. **RTO timeout** — retransmit oldest unacked segment; enter **slow start** (back off congestion window: cwnd resets, halves effectively via ssthresh).
2. **Fast retransmit** (3 dup ACKs) → retransmit immediately, enter **fast recovery** (halve cwnd, not full reset — Reno/Cubic behavior).
3. SACK hints fill gaps efficiently.

Duplicate retransmissions are harmless (receiver discards dupes by seq, re-ACKs).

### Timeout (RTO)

- Must be **> measured RTT** — adaptive: `SRTT = (1−α)·SRTT + α·R` (α=1/8), `RTTVAR` similarly; RFC 6298: `RTO = SRTT + 4·RTTVAR` (min 1 s typically, backed off exponentially on repeated timeouts — each successive RTO doubles).
- Too-short RTO → spurious retransmissions (waste, shrink cwnd); too-long → stalls on real loss. Karn's algorithm: don't sample RTT from retransmitted segments (ambiguous).

### Reliable data transfer (how TCP achieves it — "rdt over lossy channel" story)

```text
 send window (unacked in flight)        recv window (buffer, rwnd)
 [seq a ......... seq b)  ───── segments ────▶  [expected c .... free space)
        │  ACK(c) comes back → slide left ◀──────┘
        │ timeout / 3 dup-ACK → retransmit hole
```

1. Each byte numbered; sender tracks `SND.UNA` (oldest unacked) → `SND.NXT`.
2. Transmit within **min(cwnd, rwnd)**; start RTO timer.
3. Receiver: if in-order → deliver, ACK cumulative; if gap → buffer, dup-ACK/SACK; if dup → discard, re-ACK.
4. Sender on ACK → slide window, advance timer; on loss signal → retransmit; on success → grow cwnd (congestion control §5.10).
5. Connection ends only after both FINs ACKed — all data flushed before close.

Result: an **in-order, error-free, duplicate-free byte stream** presented to the app, despite best-effort IP beneath — the end-to-end principle in action (any link-layer ARQ is bonus, not substitute).

---

## 5.9 TCP Connection

### Connection establishment

Both sides must agree to talk, exchange ISNs, and align options **before sending data** — done by the **three-way handshake**. Simultaneous open is possible (both SYN → both SYN-ACK → both ACK) but rare.

### Three-way handshake

```text
 client                                    server
   │ 1. SYN      (seq = ISN_c, MSS, wscale, SACK…) │
   │──────────────────────────────────────────────▶│ SYN-RECEIVED
   │                                              │ (alloc TCB, reserve buffer)
   │◀─────────────────────────────────────────────│
   │ 2. SYN-ACK (seq = ISN_s, ack = ISN_c+1, opts) │
   │                                              │
   │ 3. ACK      (seq = ISN_c+1, ack = ISN_s+1)   │
   │──────────────────────────────────────────────▶│ ESTABLISHED
   │◀── data may flow both ways, piggybacked ACKs ─│
```

**Why exactly three, not two?** (classic interview): the third ACK confirms the server's SYN-ACK was received — without it, the server can't distinguish a **fresh valid connection** from a **stale/duplicated old SYN** or a **spoofed/random SYN flood** (half-open waste). Three-way also lets both sides confirm **initial sequence numbers** propagate and exchange initial window/options both ways. (SYN cookies mitigate SYN-flood resource exhaustion by encoding state in the ISN itself.)

### SYN

- **Synchronize sequence numbers** flag: first segment of each direction, carries the sender's **ISN** (initial sequence number — randomised per RFC 6528 to prevent off-path prediction/session hijack and stale-segment confusion).
- SYN consumes **one** sequence number (like data of length 1) so it's reliably ACKed/retransmitted like data.
- Server response SYN-ACK sets ACK flag + ack = client ISN + 1.

### SYN-ACK

- Server's reply combining its own **SYN** (server's ISN) with **ACK** of client's SYN (ISN_c + 1).
- Server enters SYN-RECEIVED (half-open) state, pending final ACK; timeout → retransmit SYN-ACK (retries give "connection refused" / RST if nothing listens).

### ACK

- Third message: pure ACK (no SYN), ack = ISN_s + 1, seq = ISN_c + 1 — both reach **ESTABLISHED**; data can flow immediately after (client's first data may even ride with this ACK).

### Connection termination

TCP is **full-duplex → each direction closes independently** (4-way FIN handshake overall; often combined to 3 messages via piggybacking):

```text
 A                                            B
   │ 1. FIN  (seq = x, "I'm done sending")      │
   │────────────────────────────────────────────▶│ (B may still send data)
   │ 2. ACK  (ack = x+1)   ← A enters FIN-WAIT-2 │
   │◀────────────────────────────────────────────│
   │        … B sends its remaining data …       │
   │ 3. FIN  (seq = y, from B)                   │
   │◀────────────────────────────────────────────│
   │ 4. ACK  (ack = y+1)                         │
   │────────────────────────────────────────────▶│ B → TIME-WAIT (2·MSL) → closed
   │ A → TIME-WAIT if it initiated close…        │
```

- After FIN: sender in **FIN-WAIT-1**, on ACK → **FIN-WAIT-2** (await other FIN); receives peer FIN → ACK → **TIME-WAIT**.
- **TIME-WAIT lasts 2 × MSL** (Maximum Segment Lifetime, typically 60 s Linux = 120 s): (a) ensure final ACK reaches B (if lost, B re-FINs, A still alive to re-ACK), (b) let straggling duplicates of old connection die before ISN space reused.
- **Simultaneous close** (both FIN together): both ACK each other's → both TIME-WAIT.
- **RST (reset)** — abrupt/abortive close (crash, unread data on close, invalid segment to closed port) → immediate teardown without FIN dance ("connection reset by peer").

### FIN

- **Finish** flag: sender has no more data for that direction; consumes a sequence number like SYN; receiver must ACK it; receiver may still transmit on its own direction until it also sends FIN.

### TCP connection lifecycle (state diagram)

```text
         active open (SYN)                passive open (SYN)
 CLOSED ────────────────▶ SYN-SENT ──┐   LISTEN ◀────────────── (server bind/listen)
    │                       ▲   SYN-ACK│ ▲ accept│
    │                       └── ACK ───┤ │       │
    │                            ▼     ▼ │       ▼
    │                        ESTABLISHED ◀─── SYN-RCVD (got SYN, sent SYN-ACK, got ACK)
    │                    close()│ FIN ▲ close()│
    │                           ▼     │       ▼
    │                     FIN-WAIT-1 ─┼──▶ CLOSING / FIN-WAIT-2
    │                           │ ACK │       │ FIN
    │                           ▼     │       ▼
    │                     FIN-WAIT-2 ─┴─▶ LAST-ACK ── ACK ──▶ (closed)
    │                           │ FIN from peer
    │                           ▼
    └── (timeout etc.)     TIME-WAIT (2MSL) ──▶ CLOSED
```

States to know for interviews: **LISTEN** (server waiting), **SYN-SENT/SYN-RCVD** (handshake), **ESTABLISHED** (data), **FIN-WAIT-1/2, CLOSING, LAST-ACK, TIME-WAIT** (teardown — TIME-WAIT dominated by the **closing side** of the connection; many `TIME_WAIT` sockets = that host closed many connections actively), **CLOSED**.

---

## 5.10 Congestion Control

### What is congestion?

**Congestion** = the network's routers/links being asked to carry **more traffic than their collective capacity/queues can absorb** → queues grow, delay balloons, buffers overflow and packets **drop** — senders retransmit, making it worse (congestive collapse risk). Manifests as: high/variable latency (queueing), packet loss, reduced throughput, jitter spikes, even connection resets.

```text
 offered load ──▶ ▲ throughput
                  │        ╭────── capacity
                  │      ╱   (loss & collapse beyond)
                  │    ╱
                  └──╱─────────────── utilization
         sweet spot: keep pipe ~full but queues near-empty
```

### Causes of congestion

- **Many senders → one bottleneck link/router** (aggregate demand > service rate of the slowest hop — e.g., many campus flows crossing one WAN edge).
- **Slow service rate at egress** (outgoing link slower than incoming aggregate; traffic bursts).
- **Traffic characteristics** — short, bursty flows arriving together (mouse flows) congest queues even at average util < 100%.
- **Insufficient buffers / poor queue management** (drop-tail overflow; bufferbloat trade-off: big buffers = low loss but huge delay).
- **Slow receivers / mismatched rates** upstream (classic case; flow control handles receiver side, congestion is path-wide).
- **Routing changes / hot spots / failing links** temporarily concentrating load (microloops during convergence).
- **Malicious/overload (DoS)** — deliberate over-offer.

### Congestion control

Mechanisms to **keep offered load ≤ sustainable capacity**, avoiding collapse while keeping utilization high:

- **Open loop (preventive):** design-time QoS — traffic shaping (leaky bucket), admission control, scheduling (WFQ), provisioned buffers — no feedback used.
- **Closed loop (reactive):** measure delay/loss/ECN and adjust send rate — the TCP model:
  - TCP maintains **congestion window cwnd**; usable flight = **min(cwnd, rwnd)**.
  - **Slow start:** cwnd = 1 MSS, grows +1 MSS per ACK (exponential, doubles each RTT) until **ssthresh** or loss.
  - **Congestion avoidance:** past ssthresh → linear +1 MSS/RTT (cautious probing, AIMD sawtooth).
  - **Loss/ECN signal:** timeout → ssthresh = cwnd/2, cwnd = 1 (back to slow start); 3-dup-ACK → ssthresh = cwnd/2, cwnd = ssthresh + 3 (fast recovery), Reno/CUBIC variants.
  - **ECN (Explicit Congestion Notification):** routers mark IP ECN bits instead of dropping; sender reacts like a mild loss signal (fewer drops for short flows).
  - Modern variants: **CUBIC** (Linux default — cubic growth around W_max), **BBR** (model-based bw/RTT estimation, less loss-driven) — name-drop in senior interviews.
- Network-side aids: RED/WRED (early random drop to avoid global sync), AQM, fair queueing, traffic policing/shaping.

### Flow control vs congestion control (guaranteed exam table)

| Basis | Flow control | Congestion control |
|---|---|---|
| Protects | **Receiver** (its buffer/CPU) | **Network** (routers, links, queues) |
| Problem | Sender faster than *destination* can consume | Aggregate load faster than *path* can carry |
| Mechanism (TCP) | Receiver advertises **rwnd** in ACKs | Sender-managed **cwnd** (slow start/CA/fast recovery) |
| Who controls | **Receiver** (dictates window) | **Sender** reacting to network signals (loss/ECN/delay) |
| Signal | Window value (may hit 0 → zero-window probe) | Loss, 3 dup-ACKs, ECN mark, RTT inflation |
| Applicable to | Any protocol with buffers (also DLL, HDLC) | Primarily end-to-end (TCP) + network QoS |
| Can both limit? | Yes — actual rate = **min(cwnd, rwnd)** | |

> Interview answer: "Flow control is about the receiver — it advertises its buffer window so a fast sender doesn't overrun it. Congestion control is about the network — the sender probes available path capacity with slow start and additive increase, and backs off multiplicatively on loss or ECN because congestion is the likely cause. TCP limits itself to the minimum of the two windows — and that's how the Internet stays stable under millions of simultaneous senders without any central scheduler."

### TCP congestion control basics (summary drill)

1. Start: cwnd = 1 MSS, ssthresh = 64 KB (example) → slow start doubles cwnd per RTT (1→2→4→8…).
2. Hit ssthresh or loss → transition rules as above.
3. On loss: cut ssthresh & cwnd (AIMD) → sawtooth probing just under capacity; fair-share converges across competing flows.
4. Retransmission & reliability mechanics from §5.8 integrate with these window changes (`min(cwnd, rwnd)` each ACK).

Timing-diagram / numerical types (window vs time sketch, transmission vs propagation delay contributions): worked in [10-final-exam-prep.md](10-final-exam-prep.md).

---

## 5.11 Network Security & Cryptography

### Why network security is required

Networks carry money, identity, medical, state and trade secrets over **untrusted shared media** (public Internet, Wi-Fi). Threats: eavesdropping (**confidentiality attacks** — passive sniffing), tampering (**integrity attacks** — packet modification, MITM), impersonation (**authentication attacks** — spoofing, phishing, session hijack), denial (**availability attacks** — DDoS, jamming), plus ransomware, replay, and insider abuse. Security = designing **countermeasures into protocols** (TLS, IPsec, MACs, firewalls) so the CIA goals hold under attack.

### Confidentiality

Only **authorized parties** can *read* the content — anyone intercepting sees gibberish.
- Tool: **encryption** — transform plaintext P → ciphertext C with key; only keyholder can reverse (decrypt).
- Attacks prevented: sniffing/packet capture, wiretapping, stolen backups (if encrypted), traffic *content* leaks (metadata still visible without extra measures).
- Guarantees given to legitimate receiver: they recover P exactly.

### Integrity

Data is **not modified** (accidentally or maliciously) in transit/storage — receiver can trust bytes are what sender produced.
- Tools: **hashes / MACs** — sender attaches a fingerprint (CRC weak, **HMAC** cryptographic); receiver recomputes and compares; any flip changes digest.
- Related: **non-repudiation** (via digital signatures) — sender cannot later deny having sent it.
- Note: encryption alone ≠ integrity (ECB malleability etc.) — real protocols combine both (TLS AEAD modes: AES-GCM = encrypt + integrity in one).

### Authentication

Proving **who you are** (entity authentication) and often **freshness** (anti-replay):
- **Password / knowledge factors**, **tokens/certificates** (something you have), **biometrics** (something you are); often **multi-factor** combos.
- Network protocols: **TLS server certificates** (PKI proves "this really is google.com"), **mutual TLS**, **CHAP/802.1X**, **SSH keys**, **IPsec IKE** pre-shared keys/certs, challenge-response to avoid sending the secret itself.
- Session tokens/cookies after login; **nonce + timestamp** to defeat replay.

### Availability

The system remains **usable by authorized users** when needed — uptime as a security property.
- Threats: **DDoS** (volumetric UDP/amplification floods, protocol attacks like SYN floods — mitigated by SYN cookies, scrubbing centers, anycast), physical cuts/jamming, ransomware locking data, resource exhaustion bugs.
- Countermeasures: redundancy/replication, CDN/scrubbing, rate limiting, load balancing, failover, spare capacity, backups (offline/immutable), HA design.
- Often forgotten in textbook CIA triads — call it out in interviews: "security without availability is a locked door with no one inside to open it — and attackers know that."

### Symmetric encryption

**One shared secret key** encrypts and decrypts (`E_k(P) = C`, `D_k(C) = P`). Same key both sides.
- **Pros:** fast (10–100× faster than asymmetric), simple, great for bulk data (AES-256-GCM, ChaCha20).
- **Cons:** **key distribution problem** — how do two parties who never met agree on a key over an insecure channel? (the classic problem cryptography was built to solve); scales poorly (n users ⇒ n(n−1)/2 pairwise keys); no built-in identity proof or non-repudiation.
- Modes: ECB (insecure pattern-leak), CBC, CTR, **GCM** (authenticated encryption — preferred).
- Examples: **AES** (winner, 128/192/256-bit), **DES/3DES** (obsolete/legacy), **Blowfish/Twofish**, one-time pad (perfect secrecy if truly random & single-use).

### Asymmetric encryption

**Public + private key pair**: one public (shared freely), one private (secret, math-linked). `E_pub(P)` decryptable only by `D_priv`; signatures use the reverse (`E_priv` verifiable by `E_pub`).
- Solves **key distribution & identity**: senders need only the recipient's published key; private key never transmitted.
- **Pros:** secure key exchange (Diffie-Hellman), **digital signatures** (authenticity + non-repudiation), scalable (one keypair per user, PKI directories).
- **Cons:** **slow** (100–1000× symmetric — RSA 4096 vs AES), heavy computation → never used for bulk payload directly.
- **Hybrid design (real world):** asymmetric (RSA/ECDH) to authenticate + agree a **session key**; then symmetric (AES) encrypts the actual data — exactly what **TLS** does.
- Examples: **RSA** (factoring), **ECC/ECDSA/Ed25519** (elliptic curves — small keys, mobile/IoT friendly), **Diffie-Hellman** (key *agreement* not encryption per se), **X.509 certificates**, **PGP** web-of-trust vs CA-PKI.

### Hashing

A **one-way function**: arbitrary input → fixed-size **digest** (e.g., SHA-256 → 32 bytes), computationally infeasible to invert or find collisions.
- Security properties: preimage resistance, second-preimage resistance, collision resistance.
- Uses: **password storage** (with salt + slow KDF: bcrypt/scrypt/Argon2 — never plain SHA of a password), **message integrity** (digest of file proves unchanged), **fingerprints** (certificate fingerprints, git commit hashes), Merkle trees, proof-of-work.
- Examples: **MD5** & **SHA-1** — **broken for collision resistance** (don't use for signatures/certs; ok for non-adversarial checksums only), **SHA-2 family** (SHA-256/384/512 — widely deployed), **SHA-3** (Keccak — alternative sponge design), **HMAC** (hash + secret key → keyed integrity — HMAC-SHA256 in APIs/tokens/JWT).
- Hash ≠ encryption: **not reversible by design**; no key (unless HMAC) → no confidentiality.

### Digital signature

Asymmetric operation proving **authenticity, integrity and non-repudiation** of a message/document:

```text
 sign:    signature = E_priv( H(message) )        (often with hashing first for speed)
 verify:  E_pub(signature) ==? H(message)          anyone with sender's public key checks
```

- Properties: only holder of private key could produce it; any bit change to message breaks digest match; **non-repudiation** — sender cannot later claim "I didn't sign" (unlike symmetric MAC where both share the key and could have forged).
- Real systems: **code signing** (Windows/Android app updates), **TLS certificates** (CA signs the site's public key), **SSH host keys**, **git commit signing (GPG/SSH sigs)**, **email S/MIME/PGP**, software package repos.
- **Signature ≠ encryption** — signing doesn't hide the message (combine with encryption when both needed — PGP, TLS).
- **MAC vs signature:** HMAC needs shared key (both could forge → no non-repudiation, faster, good within one org/session); signatures use keypairs (public verifiability, third-party auditability).

### Basic cryptography concepts (glossary for rapid-fire)

| Term | Meaning |
|---|---|
| Plaintext / Ciphertext | Original data / scrambled output |
| Key | Secret parameter controlling E/D (or generation) |
| Algorithm/cipher | The transformation rule (public, Kerckhoffs: security lives in the key not the algorithm) |
| Encryption / Decryption | P→C / C→P |
| Block vs stream cipher | Fixed-block (AES blocks) vs byte/bit-at-a-time (ChaCha, CTR) |
| Brute force | Try all keys — key length sets cost (128-bit = 2^128 ops) |
| Man-in-the-middle | Active attacker relaying & altering both directions — defeats naive crypto; solved by authenticated key exchange (certificates, fingerprints) |
| Replay attack | Resending a valid old message — countered by nonces/timestamps/seq (challenge-response) |
| Salting | Random per-password value before hashing — kills rainbow tables |
| PKI / CA / X.509 | Hierarchy issuing & verifying certificates binding identity ↔ public key |
| Forward secrecy | Session keys uncompromised even if long-term private key later stolen (ephemeral Diffie-Hellman — TLS ECDHE) |
| Kerckhoffs's principle | System secure even if algorithm public; keep only key secret |

**How it all fits (TLS in one breath)** — handshake: client/server hello → server presents **X.509 cert (CA digital signature over its public key)** → client verifies signature chain (authentication) → **ephemeral Diffie-Hellman** agrees session keys (asymmetric phase, forward secrecy) → both switch to **symmetric AES-GCM** (bulk encryption + integrity) → app data flows. Full HTTPS workflow in [07-application-layer.md](07-application-layer.md).

---

## Chapter 5 Revision (§5.6–5.11)

### TCP handshake diagram
Draw 3-way (SYN / SYN-ACK / ACK) with ISNs and states (SYN-SENT, SYN-RCVD, ESTABLISHED) — see §5.9; know *why 3 messages* (third ACK confirms server's SYN-ACK, completes ISN agreement both ways).

### TCP connection termination
4-way FIN exchange, each direction independent; TIME-WAIT = 2×MSL (final ACK safety + stale segment drain); RST for abortive close. State diagram in §5.9.

### Flow vs congestion control
- Flow: **rwnd** from receiver protects receiver buffer; zero-window probe on rwnd=0.
- Congestion: **cwnd** by sender from network signals (loss/ECN/RTT); slow start / CA / fast recovery, AIMD sawtooth.
- Effective window = **min(cwnd, rwnd)** — say this sentence in every interview. Table in §5.10.

### IPv4 vs IPv6
See §5.3 / [10](10-final-exam-prep.md) — 32b/128b, header size, checksum, fragmentation locus, broadcast vs multicast, NDP vs ARP, IPsec, flow label.

### Important interview questions
1. Transport layer purpose — process-to-process in 20 seconds; multiplexing/demultiplexing via ports.
2. TCP vs UDP — feature table + which app uses which & why (live examples).
3. Walk the three-way handshake on a whiteboard; why not two-way?
4. TIME-WAIT: who enters it, why 2×MSL, what breaks if skipped (stale segments, ACK loss).
5. How does TCP guarantee reliability? (seq, cumulative ACK, timeout, fast retransmit, checksum, in-order buffer)
6. Flow vs congestion control — clear distinction + min(cwnd, rwnd).
7. What happens on 3 duplicate ACKs vs a retransmission timeout? (fast retransmit+recovery vs slow start reset)
8. Symmetric vs asymmetric vs hashing vs signatures — what problem does each solve? How does TLS combine them?
9. Why is availability part of security? Give a DDoS mitigation.
10. Digital signature vs MAC — non-repudiation difference.

### Important exam questions
1. State transport layer responsibilities; differentiate from network layer (host-to-host vs process-to-process).
2. Explain port numbers & well-known/registered/ephemeral ranges; role of multiplexing/demultiplexing.
3. Compare connection-oriented (TCP) and connectionless (UDP) transport services.
4. Describe TCP segment header fields (≥6) with functions.
5. Draw and explain the TCP three-way handshake; explain connection termination with FIN states.
6. Explain TCP reliability mechanisms (seq/ACK/retransmit/timeout) with a timing diagram.
7. What is congestion? Causes? Explain TCP congestion control phases (slow start, CA, fast recovery).
8. Differentiate flow control and congestion control (table).
9. Define confidentiality, integrity, authentication, availability with one technique each.
10. Compare symmetric and asymmetric encryption; explain how digital signatures work with a diagram/formula; why do real systems use hybrid crypto?
11. What is hashing? Properties? Compare hash vs encryption; mention MD5/SHA status.
12. Explain digital signature: properties, process, non-repudiation, examples.

### Quick revision notes
- Transport = end-to-end process delivery: ports (well-known<1024, registered, ephemeral), segment = TCP PDU / datagram = UDP PDU; multiplex on send, demux on 4-tuple (TCP) or dst port (UDP).
- UDP: 8 B header, no setup/reliability/flow/congestion — DNS/VoIP/games. TCP: 20+ B, connection, reliable byte stream, ordered, flow + congestion control — web/email/files.
- Reliability = byte seq# + cumulative ACK + RTO (SRTT+4·RTTVAR) + fast retransmit (3 dup ACKs) + checksum (+ SACK).
- Handshake: SYN → SYN-ACK → ACK (agree ISNs/options, 3rd msg confirms); teardown FIN/ACK ×2 dirs; TIME-WAIT 2MSL; states incl. LISTEN/SYN-SENT/ESTABLISHED/FIN-WAIT/LAST-ACK/TIME-WAIT.
- Congestion = load > path capacity → queue/loss/collapse; TCP: cwnd, slow start exp → ssthresh → linear CA; timeout→reset, 3dup→halve+fast recovery; ECN marks; AIMD sawtooth; min(cwnd,rwnd).
- Security CIA(+A): confidentiality=encryption (sym fast/bulk vs asym slow/key-exchange+signatures — hybrid in TLS), integrity=hash/HMAC, auth=certs/challenge-response, availability=redundancy/DDoS defense; signature = E_priv(H(m)) → non-repudiation; MD5/SHA-1 broken, SHA-2/3 live; forward secrecy via ephemeral DH.
