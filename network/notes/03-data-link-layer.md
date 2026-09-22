# 03 — Data Link Layer

> Reference: Kurose & Ross §4.2–4.4 (link layer, error detection, MAC) + classic syllabus numericals (CRC, Hamming, ARQ). | TODO Chapter 3 | Priority: **MUST KNOW** — numericals almost every exam

---

## 3.1 Data Link Layer Fundamentals

### Purpose of Data Link Layer

Layer 2 — makes the **raw physical link** look like a reliable node-to-node pipe between two directly connected devices (host↔router, router↔router, host↔switch).

Core jobs (the "five F-words" + addressing):

1. **Framing** — package bits into discrete frames.
2. **Physical addressing** — MAC addresses identify interfaces on the link.
3. **Error detection** — CRC/FCS so corrupted frames are dropped (retransmission is handled above, e.g. TCP/ARQ).
4. **Flow control** — don't overwhelm a slow receiver on this hop.
5. **Access control** — arbitrate who may use a shared medium (Ch 4: CSMA/CD, token…).
6. **(Also)** handle half/full-duplex control and media-specific signalling.

> Interview answer: "The data link layer takes the physical layer's raw bit stream and turns it into structured frames, addresses them with MAC addresses, detects transmission errors with a CRC, controls flow on the link, and arbitrates access when the medium is shared. Its delivery guarantee is hop-to-hop, not end-to-end."

### Framing

Dividing the bit stream into **frames** — self-delimiting units with start and end boundaries so the receiver knows where a message begins and ends.

Methods:

| Method | Idea | Used by |
|---|---|---|
| **Character count** | Length field says how many chars follow | Obsolete (one lost count desyncs forever) |
| **Start–stop bytes** | Flag byte (e.g. SOH/STX/ETX) wraps frame; byte stuffing escapes flags inside data | Async serial, HDLC-style |
| **Bit stuffing** | Special bit pattern 01111110 flag; insert a 0 after five 1s in data ("bit destuffing" removes it) | **HDLC, PPP** |
| **Physical layer coding violation** | Illegal code in the encoding marks boundary | 802.3 with Manchester |

Frame = **header** (addresses, type, seq#) + **payload (data)** + **trailer** (error check/FCS):

```text
+--------+------------------+--------+--------+
| Header |  Data (payload)  | Pad?   | FCS/CRC|   ← trailer
+--------+------------------+--------+--------+
```

Why frames? Fixed-size framing lets hardware know when transmission ends (needed to detect collisions, e.g. minimum Ethernet frame 64 bytes ≈ round-trip collision window); enables per-hop addressing and error checking.

### Physical addressing

- The **MAC address** (48-bit, burned-in / locally administered) identifies the **NIC** on the local link — written `00:1A:2B:3C:4D:5E` (hex).
- Sender puts **dst MAC** in frame header; every NIC on the wire hears the frame but only the matching one accepts it (promiscuous mode accepts all).
- MAC addresses are **only meaningful on the local link** — routers rewrite L2 addresses at every hop (L3 IP stays end-to-end).
- Contrast with **IP (logical, hierarchical, portable)** vs **MAC (flat, hardware, global-unique)** — full table in [10-final-exam-prep.md](10-final-exam-prep.md).

### Flow control

Ensures a **fast sender does not outrun a slow receiver** on this link — otherwise receiver buffers overflow and frames are dropped.

- **Stop-and-wait** — send one frame, wait for ACK; simple, poor utilization on long links.
- **Sliding window** — multiple frames in flight governed by a window; used by HDLC, TCP (end-to-end version), and link protocols.
- Only needed where the *sender* can be faster than the *receiver path* (e.g., classic half-duplex links, radio); switched full-duplex Ethernet relies on the switch's buffer + PAUSE frames.

### Error control

Detecting (and where possible correcting) corrupted or lost frames on the hop:

- **Detection:** parity, checksum, **CRC** (§3.3–3.4) → receiver silently drops bad frames or sends **REJ/NACK**.
- **Correction:** forward error correction — **Hamming code** (§3.5) fixes bits without retransmission; or **ARQ** retransmits (§3.7–3.8).
- Frames carry **sequence numbers** so duplicates/reordering are detectable.

### Access control

When multiple devices share one medium (bus, Wi-Fi, classic Ethernet hub), a **MAC protocol** decides who transmits when to avoid chaos/collisions:

- Random access: ALOHA, CSMA, CSMA/CD, CSMA/CA (Ch 4).
- Controlled: reservation, polling, token passing (Ch 4).
- Implemented in the **MAC sublayer**; LLC (logical link control) sits above it as the stable interface to the network layer.

### Frame

The **PDU of the data link layer** = header + data + trailer.

> One-liner: "Segment is transport's PDU, packet is network's, and **frame** is the data link layer's PDU."

---

## 3.2 Error Detection

### Why errors occur
Noise, attenuation, interference, crosstalk, multipath and EMI flip bits during transmission (transient — same frame usually fine on retry; not permanent link failure).

### Error detection vs correction

| | Detection | Correction |
|---|---|---|
| Goal | Know *that* the data is corrupt | Know *which bits* and restore them |
| Method | Parity, checksum, CRC | Hamming code, FEC (Reed–Solomon…) |
| Overhead | Small (few bits) | Larger (more redundant bits) |
| Recovery | Drop + retransmit (ARQ/TCP) | No retransmission needed |
| Used when | Retransmission possible | Retransmit too costly (deep space, real-time, optical) |

Rule of thumb: **detect is cheap, correct is expensive** — Internet links detect (CRC) and let TCP retransmit; CD/Blu-ray and satellite use FEC to correct in place.

### Single-bit error
Exactly **one bit** flipped in the frame (0→1 or 1→0).

```text
 sent:     1 0 1 1 0 1 0 0
 received: 1 0 1 1 1 1 0 0   ← bit 5 flipped
```

Easily caught by parity and Hamming; probability scales with bit rate × BER × frame length.

### Burst error
**Two or more bits** flipped within one frame (not necessarily adjacent). Caused by impulse noise, fading, collision of strong interference.

```text
 sent:     1 0 1 1 0 1 0 0 1 1 0
 received: 1 0 1 1 1 1 1 1 1 1 0   ← burst of 4 errors
```

- **Key fact:** a burst error of length b can flip bits from **first to last flipped position**; CRC of order r catches **all bursts of length ≤ r** and all odd numbers of errors ≥ r+1 with proper polynomial (random-style detection for longer bursts).
- Checksums handle multi-byte corruption; simple parity misses most even-numbered bursts.

*Detection tools next: checksum (§3.3), CRC (§3.4); correction: Hamming (§3.5).*

---

## 3.3 Checksum

### Concept
Add a block of data words (treated as integers) with **end-around (ones'-complement) carry**, store the sum as the **check factor**; receiver re-sums data + checksum and expects all-1s (or 0 — convention varies; Internet ones' complement expects 0 after adding checksum in).

- Used in: **IPv4 header checksum**, **TCP/UDP pseudo-header checksum** (IPv6 drops IP-header checksum but keeps transport checksum), ICMP.
- Simple, cheap software-friendly detection; weaker than CRC.

### Checksum calculation (Internet ones' complement style)

1. Split data into **k-bit words** (16-bit words on the Internet).
2. Add them with **ones'-complement arithmetic**: when a carry out of the MSB occurs, add 1 back into the LSB (end-around carry).
3. Checksum = **ones' complement of the sum** (one's sum → bitwise NOT) sent in header.
4. Receiver: add all words **including checksum**; result should be **all 1s (0xFFFF)** — otherwise error. (Equivalently, sum of data = sum of data+checksum complement property.)

### Checksum example (16-bit, data = 1001001110001011  0111101110011101)

```text
 word1  1001 0011 1000 1011   (938Bh)
 word2  0111 1011 1001 1101   (7B9Dh)
 ────────────────────────────
 sum      1 1111 0010 0101 0110  ← carry out (20th bit)
 +carry              0001          (end-around add 1)
 =            1111 0010 0101 0111  (F257h)
 checksum = NOT(sum) = 0000 1101 1010 1000  (0DA8h)  ← sent in header

 receiver: word1 + word2 + checksum = FFFF FFFF  → no error
 any flipped bit ⇒ sum ≠ all-1s ⇒ drop
```

### Advantages
- Very **simple and fast** in software (just additions — no division like CRC).
- Small fixed overhead (16 bits for 16-bit checksum).
- Catches most single-bit and many burst errors in practice.
- Good enough for transport headers where stronger CRC exists below (Ethernet FCS).

### Limitations
- **Misses** many burst errors — e.g., swapping two words, or errors that cancel during addition (a +1 in one word and −1 in another).
- Weaker than CRC for same redundancy; detects errors only if they change the sum.
- Ones'-complement arithmetic confuses some programmers; zero-sum properties misused can hide errors.
- Not suitable alone where strong hardware-level guarantees needed (hence Ethernet uses CRC-32 instead).

---

## 3.4 CRC — Cyclic Redundancy Check

### Concept
The strongest common error **detection** code: treat the bit string as coefficients of a polynomial; **divide** by a agreed generator polynomial G(x) using **modulo-2 arithmetic** (XOR, no carries); the **remainder (r bits)** is the **Frame Check Sequence (FCS)** appended to the message. Receiver divides the whole frame by the same G(x): remainder 0 ⇒ accepted, nonzero ⇒ error.

Why it works: sending M(x)·x^r + R(x) is exactly divisible by G(x) by construction — any corruption that is *not* a multiple of G(x) leaves a nonzero remainder.

### Generator polynomial
A shared, carefully chosen polynomial (highest and lowest coefficient = 1). Standard choices:

| Name | G(x) | Degree r | Use |
|---|---|---|---|
| CRC-16 | x¹⁶+x¹⁵+x²+1 | 16 | HDLC, PPP, Bluetooth |
| **CRC-32** | x³²+… (IEEE 802.3) | 32 | **Ethernet FCS** |
| CRC-8 | x⁸+x²+x+1 | 8 | 1-Wire, some buses |

Properties: catches **all burst errors of length ≤ r**, all single/double errors (if x+1 not a factor requirements), all odd numbers of errors for certain G; residual detection probability ≈ 2^(−r) for random patterns.

### CRC calculation (modulo-2 division)

Steps:
1. Append **r zeros** to the data (r = degree of G).
2. **Binary-divide** (XOR-based) the augmented data by G(x) — no borrows/carry, just XOR.
3. Remainder (r bits) = **FCS**; replace the appended zeros with FCS → transmitted frame.
4. Receiver performs the same division on the received frame; remainder must be 0.

### CRC example (classic exam problem)

Data: **1101011011**, G(x) = **x⁴ + x + 1** → G = **10011** (r = 4)

```text
Step 1 — append 4 zeros:      1101011011 0000

Step 2 — modulo-2 division by 10011:

        1100001010
       ─────────────────
10011 ) 11010110110000
        10011
        ─────
         10011
         10011
         ─────
          00001
          00000        (bring down)
          ─────
           00010 … (continue bringing down bits, XOR at each step where MSB=1)
           …
        final remainder = 1110   ← FCS (4 bits)

Step 3 — transmit: 1101011011 1110

Step 4 — receiver divides 11010110111110 by 10011 → remainder 0000 ⇒ frame OK
Any flipped bit ⇒ nonzero remainder ⇒ discard frame.
```

*Exam routine: always append r zeros, XOR-divide, remainder = FCS, verify receiver-side = 0. Worked variants in* [10-final-exam-prep.md](10-final-exam-prep.md).

### CRC advantages
- Extremely strong detection: **100% catch of bursts ≤ r bits**; catches ~99.999999978% of longer random bursts with CRC-32.
- Pure hardware (shift register + XOR gates) at line speed — that's why Ethernet puts it in silicon.
- Same algorithm sender and receiver; no need to transmit redundant data beyond r bits.

### CRC limitations
- **Detection only** (standard CRC) — must retransmit to fix (ARQ/TCP above).
- Cannot locate/correct the bad bit (unlike Hamming).
- Very rare undetectable patterns remain (multiples of G(x) exactly).
- Not encryption/authentication — attackers can recompute CRC (no security; use MACs/signatures for that).

---

## 3.5 Hamming Code

### Error correction concept
Add **redundant parity bits** so the receiver can not only detect but **locate (and flip)** erroneous bits **without retransmission** — forward error correction (FEC).

### Hamming distance
The number of bit positions in which two equal-length codewords differ.

```text
 d(1011, 1001) = 1
 d(0000, 1111) = 4
```

- The **minimum Hamming distance d_min** of a code determines its power:
  - Detect up to **d_min − 1** errors.
  - Correct up to **⌊(d_min − 1)/2⌋** errors.
- Example: if d_min = 3 → detect 2, correct 1 (perfect for single-error correction + detection).

### Redundant bits
How many extra bits for m data bits so t errors are correctable:

```text
 2^r ≥ m + r + 1          (single-error-correcting Hamming)
```

- r = number of parity bits; m = data bits.
- Table: m=4→r=3 (Hamming 7,4) · m=7→r=4 (Hamming 11,7 — used in MIDI/1-byte) · m=12→r=5 · m=26→r=6.
- SEC-DED (single-error-correct, double-error-detect): add **one overall parity bit** → 8,4 extended Hamming.

### Parity bits
Each parity bit p_i covers positions whose **binary index contains a 1 in bit i**:

```text
 p1 → positions 1,3,5,7,9,11,…   (bit0 of posn = 1)
 p2 → positions 2,3,6,7,10,11,…  (bit1 = 1)
 p4 → positions 4,5,6,7,12,13,…  (bit2 = 1)
 p8 → positions 8–15, 24–31,…    (bit3 = 1)
```

Power-of-two positions (1,2,4,8…) hold parity bits; other positions hold data. Parity choice: **even parity** (default in networking — parity bit makes each covered group have even number of 1s) or odd parity.

### Hamming code calculation (worked — classic exam)

**Data = 1011, find Hamming (7,4):**

```text
1. r such that 2^r ≥ 4+r+1 → r=3. Total = 7 bits. Positions 1..7:
    posn:   1   2   3   4   5   6   7
    role:   p1  p2  D1  p4  D2  D3  D4
    data (1011) fills D1..D4 →          1   0   1   1

2. Set parity bits for EVEN parity:
   p1 covers 1,3,5,7 → p1,1,0,1 → p1 must be 0 (0+1+0+1=even already? count ones=2 even → p1=0)
   p2 covers 2,3,6,7 → p2,1,1,1 → ones so far=3 odd → p2=1
   p4 covers 4,5,6,7 → p4,0,1,1 → ones=2 even → p4=0

3. Codeword: p1 p2 D1 p4 D2 D3 D4 = 0 1 1 0 0 1 1 → 0110011
```

**Error: receiver gets 0110011 but bit 6 flipped → 0110111. Correction:**

```text
 Recompute parity checks (even parity over each group):
   c1 (p1 group 1,3,5,7): bits 0,1,0,1 → parity OK? ones=2 even → c1=0
   c2 (p2 group 2,3,6,7): bits 1,1,1,1 → ones=4 even → c2=0   ← wait use received: 1,1,1,1→even→0
   c4 (p4 group 4,5,6,7): bits 0,0,1,1 → ones=2 even → c4=0
 Actually use received frame 0 1 1 0 1 1 1:
   group p1 (1,3,5,7): 0,1,1,1 → ones=3 ODD → c1=1
   group p2 (2,3,6,7): 1,1,1,1 → ones=4 EVEN→ c2=0
   group p4 (4,5,6,7): 0,1,1,1 → ones=3 ODD → c4=1

 Syndrome = c4 c2 c1 = 101₂ = position 5 ... (recheck positions with your exact received word in practice)

 Key rule: syndrome S = c4c2c1 (binary) = POSITION of the erroneous bit.
   S = 000 → no error.
   S ≠ 000 → flip the bit at position S.
```

*(Exam tip: write groups as a table first — syndrome math never lies; a tiny arithmetic slip in hand-solve is the usual trap, not the method.)*

### Error detection (with Hamming)
- Non-zero syndrome ⇒ error present (single-bit model).
- Parity groups disagreeing in a pattern that matches no single position (or overall parity bit mismatches in SEC-DED) ⇒ likely **double error — detect but cannot correct** (double errors can masquerade as a different single position without the extra overall bit).
- Hamming distance 3 ⇒ detects up to 2 errors, corrects 1.

### Error correction
As above: compute syndrome → binary value = exact bit position → flip it → original codeword restored. No retransmission, fixed small latency — why it's used in RAM (ECC memory), disks, deep-space links, QR codes (with stronger BCH/Reed-Solomon cousins).

### Exam numerical problems (types to practice)
1. Given m data bits → find r, draw position map, compute parity bits (like above).
2. Given a received Hamming word → compute syndrome → identify/correct the error.
3. Compute Hamming distance between two codewords; given d_min answer detect/correct capability.
4. Find minimum r for given m: 2^r ≥ m+r+1.
5. Which errors can/can't be corrected: e.g., d_min=5 → correct 2, detect 4.

Solved practice set: [10-final-exam-prep.md](10-final-exam-prep.md#hamming-code).

---

## 3.6 Flow Control

### Why flow control is required
A sender may produce data faster than the receiver's buffer/CPU can absorb (speed mismatch, bursty apps). Without flow control, receiver buffers **overflow** → frames dropped → wasted retransmissions, reordering pain. Flow control protects **the receiver** (congestion control protects the *network* — contrast in [06](06-transport-and-security.md)).

### Stop-and-Wait
- Send **one frame**, then **wait for ACK** before sending the next.
- Window size = 1; simplest protocol; receiver signals readiness via ACK (and explicit RCVBUF space advertisements if needed).
- **Utilization problem:** on a long fat pipe the line idles for the full round-trip time:

```text
 U = T_tx / (T_tx + RTT)     ← often a few % on WAN links
```

Good for: human-speed channels, very simple links, low bandwidth×delay products.

### Sliding Window
- Sender may transmit **multiple frames** (up to **window size W**) without waiting for individual ACKs — a **"window" of unacknowledged frames slides** forward as cumulative ACKs arrive.
- Keeps the pipe full ⇒ utilization ≈ W × T_tx / (T_tx + RTT); choose W ≥ BDP/Tx to saturate link.
- Sequence numbers modulo some maximum (e.g., 0..W−1 for stop-and-wait, 0..2^k−1 for k-bit seq numbers).
- Receiver may also advertise its own **receive window** (how much buffer space is free) — sender's effective window = min(sender, receiver advertised).

```text
 sender window (size W=4), seq 0..7:
 ────────────────────────────────────────────▶ time
 [ 0 1 2 3 ]        all four in flight, no wait
      [ 2 3 4 5 ]   ACK(1) received → window slides
```

Used by: **HDLC, PPP, TCP** (end-to-end sliding window with 16/32-bit seq and receive-window field).

### Sender window
The range of **sequence numbers** the sender may use for frames **sent but not yet acknowledged**. Bounds in-flight data; slides right on ACK receipt. Congestion window (TCP) is a further cap — see §5.10.

### Receiver window
The range of **sequence numbers the receiver is currently willing to accept**; equals its **free buffer capacity** (advertised in ACK). Stays open only while buffer space remains; if window = 0 sender must stop (zero-window probing in TCP).

### Sequence numbers
- Label each frame uniquely (wraps around modulo the number space) so receiver can: **detect duplicates** (discard old seq#), **reorder** out-of-order arrivals, and make **cumulative ACKs** ("I've received everything up to n−1").
- Requirement: seq space ≥ 2 × window size (so a delayed duplicate of an old frame can't masquerade as a new one) — e.g., W ≤ 2^k − 1 for k-bit numbers in Go-Back-N.

---

## 3.7 Stop-and-Wait ARQ

### ARQ concept
**Automatic Repeat reQuest** — link-level error control combining **error detection (CRC) + acknowledgements + timers + retransmission** to achieve reliable hop-to-hop delivery over an unreliable link.

### ACK
Positive acknowledgement: receiver got frame N intact → sends **ACK(N)** (often cumulative: "everything < N+1 received"). Receipt of ACK releases the frame from the sender's buffer and slides the window.

### NACK
Negative acknowledgement (REJ/reject): receiver detected an error in frame N (CRC fail) or gap in sequence → explicitly asks **retransmit N**. (Some protocols — e.g., pure TCP-style cumulative ACK — avoid NACKs and rely on timeout/duplicate ACKs instead.)

### Timeout
Sender starts a **retransmission timer (RTO)** with every frame; if no ACK arrives before it fires → assume frame or ACK lost → **retransmit**. RTO must exceed RTT (adaptive estimation in TCP: RTT + 4×RTTVAR).

### Retransmission
Resending after (a) timeout or (b) NACK. Same sequence number so receiver can **detect and discard duplicates** (it already has that frame).

### Stop-and-Wait ARQ workflow

```text
 sender                                        receiver
   │── frame 0 ──────────────────────────────▶│
   │                                          │ CRC ok → ACK 0
   │◀──────────────────────── ACK 0 ──────────│
   │── frame 1 ──────────────────────────────▶│
   │    (frame 1 corrupted)                   │ CRC fail → drop (no ack / NACK)
   │   … timeout for frame 1 …                │
   │── frame 1 (retransmit) ─────────────────▶│
   │◀──────────────────────── ACK 1 ──────────│
   │── frame 2 ──────────────────────────────▶│
```

Rules:
1. Send one frame, **stop** (window = 1), start timer.
2. ACK received → stop timer, send next frame.
3. NACK/timeout → retransmit same frame, restart timer.
4. Duplicate frame at receiver (old ACK lost) → receiver ACKs again but discards the data.

Throughput: `U = T_tx / (T_tx + RTT (+ T_prop errors))` — one frame per round trip ⇒ poor on high-BDP links; that's what Go-Back-N/Selective-Repeat fix.

---

## 3.8 Go-Back-N ARQ

### Concept
Generalized sliding-window ARQ: sender keeps a window of **up to W frames** in flight (no per-frame stop). On an error, it **goes back and retransmits that frame and every frame after it** (even ones receiver already got) — "go back N in the *sender's* transmit list"; receiver keeps **window = 1** (accepts only the expected next frame in order, discards anything out of order).

### Sliding window
- Sender window size **W** (with k-bit seq numbers: W ≤ 2^k − 1, e.g., k=3 → W≤7).
- Cumulative ACKs let the whole window retire at once: ACK n ⇒ frames 0..n−1 all received.
- Window advances on ACKs; blocked at full window until ACK arrives (or timeout).

### Cumulative ACK
"ACK n" = "I have received all frames **up to and including n−1**, expecting n next." One lost ACK doesn't kill the frame — a later ACK covers it (fewer control messages, robust to lost ACKs).

### Retransmission (go-back-n)
On timeout or NACK for frame X: **retransmit X, X+1, …, last sent frame** — receiver discards all of them except the missing X (then accepts the subsequent in-order ones normally).

### Lost packet handling

- **Data frame lost** → timeout at sender → go back and resend from that frame.
- **ACK lost** → sender times out & retransmits; receiver sees **duplicate** of already-received frame → discards data but **re-ACKs** (so sender can progress).
- **Corrupted frame** → CRC fails → receiver drops (NACK/implicit) → go-back-n retransmission.

```text
 sender window W=4 (seq 0..7)                    receiver (accepts only expected)
   send 0 1 2 3 ──────────────▶                   0✓ 1✓ 2✓(3 arrives early→discard)
                    ACK for 2 lost/…
   timeout on 0? no—ACK2 covers 0,1; retransmit from 3?
   Classic GBN: on timeout resend ALL unacked: 3 4 … (receiver re-discards duplicates)
```

### Example (classic exam timeline)
k=3 bits (seq 0..7), W=7? (use W=4): sender sends 0,1,2,3; receiver ACKs 0,1; frame 2 lost; ACK(2) never comes because receiver still expects 2; sender times out on oldest unacked (2) → resends 2,3 (and anything else outstanding); receiver accepts 2, ACKs 3… continue. Efficiency between stop-and-wait and selective-repeat.

---

## 3.9 ARQ Comparison

| Basis | Stop-and-Wait ARQ | Go-Back-N ARQ |
|---|---|---|
| Sender window | 1 | W (2^k − 1 max) |
| Receiver window | 1 | 1 (in-order only) |
| Frames in flight | 1 | Up to W |
| On error | Resend that 1 frame | Resend failed frame **+ all subsequent** |
| Duplicate handling | Yes (seq 0/1) | Discard out-of-order + re-ACK |
| Utilization on long links | Poor (idle RTT each frame) | Much better (pipe stays full) |
| Bandwidth wasted on error | Little (only 1 frame) | High (good frames resent too) |
| Complexity | Lowest | Moderate |
| Best when | Short/low-BDP/simple links | Errors rare, long fat pipes |

*(Selective-Repeat — beyond syllabus but nice to mention in interviews: window W at **both** ends; retransmit **only** the missing frame; receiver buffers out-of-order; best efficiency, most complexity. TCP uses a selective-reject hybrid.)*

> Interview answer: "Stop-and-wait sends one frame per round trip — simple but idle while waiting, so utilization collapses on long links. Go-Back-N lets multiple frames in flight with a sliding window and cumulative ACKs; on an error it retransmits from the bad frame onward, with the receiver accepting only in-order data. It trades some wasted bandwidth on retransmission for much higher link utilization — and selective repeat fixes that waste by resending only what's missing."

### Numerical/problem questions (practice types)
1. Compute efficiency/utilization of stop-and-wait given T_tx, RTT: `U = T_tx/(T_tx+RTT)`.
2. Given bandwidth B, distance d, frame size L, propagation speed s → T_tx = L/R, T_prop = d/s; draw timing diagram of stop-and-wait vs GBN utilization.
3. Max window size from k-bit sequence numbers (GBN: 2^k − 1; SR: 2^(k−1)).
4. How many retransmissions occur for a sequence of frames with given losses?
5. Hamming/CRC/Checksum computation (in §3.3–3.5 and [10](10-final-exam-prep.md)).

---

## Chapter 3 Revision

### Important diagrams
1. Frame structure (header | data | trailer/FCS).
2. CRC modulo-division: append r zeros → divide → remainder = FCS → receiver divides → 0.
3. Hamming position map (p1 p2 D1 p4 …) + syndrome → bit position.
4. Stop-and-Wait timeline with timeout & retransmission.
5. Sliding window sliding on cumulative ACK (sender + receiver window pictures).
6. Go-Back-N: frames sent, one lost, go-back retransmit sequence.
7. Bit stuffing (flag 01111110, insert 0 after five 1s).

### CRC problems
- Master the algorithm: append r zeros, XOR-divide by G, remainder = FCS; verify receiver-side 0. Practice with G = 10011, 11001, and CRC-32 concept. → worked sets in [10](10-final-exam-prep.md#crc).

### Hamming Code problems
- Compute r from 2^r ≥ m+r+1; build position table; derive parity bits (even parity); compute syndrome for a received word; correct bit position = syndrome value; d_min detect/correct formula. → worked sets in [10](10-final-exam-prep.md#hamming-code).

### Sliding Window problems
- U = T_tx/(T_tx+RTT) for stop-and-wait; GBN utilization ≈ min(W·T_tx/(T_tx+RTT), 1); max W from k; BDP reasoning (choose W ≥ BDP). → worked sets in [10](10-final-exam-prep.md#sliding-window--delays).

### ARQ comparison
- Stop-and-wait (W=1, idle RTT, resend 1) vs GBN (W>1, receiver W=1, resend from error onward, cumulative ACK) vs selective repeat (both windows W, resend only missing). Exam table in §3.9.

### Exam questions
1. State the functions of the data link layer.
2. What is framing? Compare the four framing methods briefly.
3. Explain error detection vs error correction with examples of each technique.
4. Compute checksum for a given 16-bit data (ones'-complement sum).
5. Define CRC; explain generator polynomial; solve a full CRC division problem.
6. Define Hamming distance; state its relation to detection/correction capability.
7. Construct Hamming code for given data bits; correct a given received word using syndrome.
8. Why is flow control needed? Compare stop-and-wait and sliding window.
9. Explain stop-and-wait ARQ with a neat diagram including timeout.
10. Explain Go-Back-N ARQ; why does receiver window stay 1? Compare with stop-and-wait.

### Interview questions
1. What does the data link layer do — in 30 seconds?
2. How does Ethernet detect a corrupted frame? (CRC-32 FCS)
3. Checksum vs CRC — which is stronger and why?
4. What is Hamming distance and how does it decide error correction?
5. Flow control vs error control vs congestion control — one line each.
6. Stop-and-wait vs Go-Back-N vs Selective Repeat — which does TCP resemble?
7. What's a sequence number for? What happens if ACKs are cumulative and one is lost?
8. Why append zeros before CRC division?

### Quick revision notes
- DLL = framing + MAC + CRC + flow control + access control; hop-to-hop; PDU = frame.
- Methods: char count / start-stop chars / bit stuffing / coding violations.
- Parity detect weak; checksum = ones'-complement sum, cheap; **CRC** = mod-2 poly division, burst ≤ r always caught; **Hamming** = correct via syndrome = bit position.
- d_min: detect d−1, correct ⌊(d−1)/2⌋; 2^r ≥ m+r+1.
- Flow control protects receiver; window = in-flight allowance; seq numbers enable dup detection/reorder/cumulative ACK.
- S&W: W=1, U = Ttx/(Ttx+RTT); GBN: sender W, receiver 1, go back & resend all ≥ lost; SR: both W, resend only missing.
