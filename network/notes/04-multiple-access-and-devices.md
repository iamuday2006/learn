# 04 — Multiple Access Protocols & Network Devices

> Reference: Kurose & Ross §4.4 (multiple access links & protocols: ALOHA, CSMA, CSMA/CD, CSMA/CA, token) + classic syllabus (network devices, domains). | TODO Chapter 4 | Priority: **MUST KNOW**

---

## 4.1 Multiple Access

### What is Multiple Access?

**Multiple access** = the problem (and set of solutions) of **many devices sharing one common communication medium** — a single frequency, one cable/bus, one satellite channel — so they can transmit without destroying each other's signals.

> Interview answer: "Multiple access is how independent stations arbitrate use of a shared channel. The MAC protocol decides who may transmit when, minimizing collisions while keeping utilization high."

### Why multiple access protocols are required

- A shared medium (one fiber segment, one radio band, one satellite transponder) is **expensive** — letting all stations transmit simultaneously without coordination produces **collisions** (garbled signals = wasted channel time).
- A **multiple access protocol** is a distributed algorithm all stations follow: rules for sensing, waiting, transmitting, and recovering from collisions.
- Design goals: **collisions minimal**, **fairness**, **high throughput/efficiency**, **simplicity/distributed** (no central bottleneck), works despite propagation delay (stations can't instantly know others started).

### Shared communication medium

Examples: one coaxial bus with taps (classic Ethernet), one Wi-Fi cell's air interface, one satellite transponder's downlink, one token-ring cable. All stations hear every transmission (or could); bandwidth is a shared pie.

### Collision

Two (or more) stations transmit **at the same time** → signals **superpose** at the receiver → corrupted beyond recovery → both frames lost; the overlapping interval wastes channel time. Must then be recovered via retransmission after a random backoff (which itself must avoid synchronized re-entry).

```text
 A: ──▄▄▄▄▄▄▄──
 B:      ──▄▄▄▄▄▄▄──      (overlap = collision zone, both frames ruined)
        ▓▓▓▓▓▓▓▓▓
         collision
```

Key insight: collision probability rises with load and with **propagation delay** (a station keeps transmitting unaware another already started) — that's why protocols "listen before talk" and why Ethernet frames have a **minimum length** (to detect collision while still transmitting).

---

## 4.2 Random Access

### Random Access concept
All stations can transmit **whenever they have data** (subject to the protocol's rules); **collisions are allowed to happen** and handled by a deterministic/retransmission mechanism — typically **wait a random backoff time** before retrying (randomization de-synchronizes competitors). Throughput-efficiency depends on load: low load → fast access; high load → collisions dominate.

Family: **Pure ALOHA → Slotted ALOHA → CSMA → CSMA/CD → CSMA/CA**.

### ALOHA
Developed at University of Hawaii (1970) to connect islands' terminals to a central computer over radio — the ancestor of all random access. Idea: transmit whenever you have a packet; if an ACK doesn't come (collision detected by central receiver), retransmit after a **random delay**.

### Pure ALOHA
- **No timing coordination**: stations send frames **as soon as they arrive**.
- Vulnerable period: a frame of duration T collides with any frame starting in the **2T window** (T before + T after its start) — if another frame begins anywhere in that span, overlap ⇒ collision.
- Maximum throughput: **S = 1/(2e) ≈ 0.184** (18.4%) of channel capacity — even at offered load G=0.5.
- Simple, fully distributed; collapses under load.

```text
 time ──▶
 A:    ┌──────┐      collision if any frame overlaps A's 2T window
 B:        ┌──────┐   ← overlaps A → both lost
 C:              ┌─────┐
```

### Slotted ALOHA
- Time divided into **slots of exactly one frame duration T**; stations may **only start transmitting at slot boundaries** (synchronized, e.g., by beacon/slot markers).
- Vulnerable period shrinks to **T** (only frames in the *same* slot collide — a frame either owns the slot fully or loses it).
- Maximum throughput: **S = 1/e ≈ 0.368** (36.8%) at G = 1 — **double pure ALOHA**.
- Idle slots waste capacity if no one transmits; if the slot had been used, it's fully utilized.
- Emergent property: at G=1, P(success in a slot) = G·e^(−G) → peaks at 1/e.

### ALOHA comparison

| Basis | Pure ALOHA | Slotted ALOHA |
|---|---|---|
| Timing | Asynchronous, send anytime | Slot-synchronized, send at slot start |
| Vulnerable window | 2T | T |
| Max throughput | ≈ **18.4%** (1/2e) | ≈ **36.8%** (1/e) |
| Complexity | Trivial | Needs global slot sync |
| Idle waste | Less structure | Empty slots wasted |
| Best for | Low-load, simple radio nets | Moderate load, cellular/GSM-like frames |

*Fun fact used in exams: slotted ALOHA doubles efficiency by halving the vulnerable period; GSM downlink frames are a slotted-ALOHA descendant for random access (RACH).*

---

## 4.3 CSMA

### CSMA concept
**Carrier Sense Multiple Access** — stations **listen to (sense) the channel before transmitting**; if busy, they defer; if idle, they transmit. Cuts collisions drastically vs ALOHA because most transmissions start only on quiet channels. Residual collisions come from **propagation delay**: station B doesn't yet hear A's signal that left moments ago, so both start "on idle".

### Carrier sensing
- Physical: detect energy/carrier above threshold on the medium (wire voltage, RF energy detection + CCA in Wi-Fi).
- Logical: also check for valid preamble/coding as "busy".
- Limitation: **cannot sense while transmitting** on a shared medium (can't hear your own echo of others) — motivates CSMA/CD (wired) and CSMA/CA (wireless) variants. And sensing can't eliminate collisions entirely due to finite propagation speed.

### 1-persistent CSMA
- Sense channel: **if idle → transmit immediately (with probability 1)**; if busy → **continuously sense** until it becomes idle, then transmit **immediately** (100% probability).
- **Aggressive** — highest responsiveness when idle, but the worst collision behavior under contention: all waiting stations pile onto the channel the instant it frees (they were all sensing it busy together).
- Used conceptually by classic Ethernet (before collision detection).

### Non-persistent CSMA
- Sense: if idle → transmit; if busy → **do NOT wait watching the channel** — instead wait a **random time**, re-sense, repeat.
- Stations don't stampede the moment the channel frees ⇒ **fewer collisions**, but introduces **unnecessary idle delays** (channel may go idle while a station is in its random wait) ⇒ lower utilization under low load.
- Middle ground between responsiveness and collision avoidance.

### p-persistent CSMA
- Works on **slotted time**: when the channel is found idle, transmit with **probability p**; with probability **(1−p)** defer to the **next slot** and repeat the rule.
- If busy → wait for idle (continuous sensing) then apply the p-rule.
- Balances aggression (p close to 1 ≈ 1-persistent) and patience (small p spreads load): e.g., p = 0.1 spreads N waiting stations over many slots.
- Used in: **Wi-Fi DCF** (p=1 after backoff, conceptually), **Token Ring/802.5** idle-slot claiming, some cellular random access.

**Summary line for exams:** *1-persistent = transmit now if idle (collide more); non-persistent = random retry (collide less, may idle); p-persistent = probabilistic gentle take-over of idle slots.*

---

## 4.4 CSMA/CD

### CSMA/CD concept
**Carrier Sense Multiple Access with Collision Detection** — the medium-access discipline of **classic Ethernet (IEEE 802.3)** on shared/bused links: listen before talk, **and while talking keep listening** for a collision; abort immediately when detected.

### Collision detection
While transmitting, the NIC compares the signal on the wire with what it's sending (voltage/amplitude excursion beyond threshold = collision; also invalid Manchester encoding / excessive jitter).
- Detection typically finishes within **2 × propagation delay (2τ)** — the "collision window" / slot time.
- Must **finish transmitting a runt?** No — stop normal data, send a brief **jam signal** (32–48 bits of random pattern) to ensure all stations notice, then stop.

### Collision handling (algorithm)

1. **Sense** channel. Idle → transmit. Busy → defer (1-persistent until idle).
2. **While transmitting, monitor** for collision.
3. Collision detected → **abort** transmission immediately, send **jam signal**.
4. Increment **collision counter (attempt number n)**; if **n > 16** → give up, report "excessive collisions" error up the stack.
5. Otherwise compute **binary exponential backoff** wait, then go to step 1.

```text
 sense ──▶ idle ──▶ transmit ──▶ collision? ──yes──▶ jam → backoff → retry
                        │                          │ n>16 → drop frame
                        no ──▶ done (ACK-free link layer)
```

### Ethernet relationship
- CSMA/CD is *why* classic Ethernet frames have a **minimum size of 64 bytes**: a station must still be transmitting when the collision echo from the farthest node returns (frame_time ≥ 2τ) — otherwise it finishes and thinks the collision "belated frame" happened. 10 Mb/s × 51.2 µs ≈ 64 bytes for a 2,500 m (later 100 m with hubs) segment.
- **Modern switched full-duplex Ethernet does not use CSMA/CD** — point-to-point links to a switch have no contention; collision detection is disabled (still called 802.3). CSMA/CD remains the textbook model for shared half-duplex/busbased LANs (and appears constantly in exams).
- CSMA/CD's beauty: after a collision, stations back off **deterministically-randomly** so exactly one usually wins the next slot (like slotted ALOHA with smarter sensing).

### Binary exponential backoff (BEB)
After the n-th collision (n ≤ 16), pick **k uniformly from {0, 1, …, 2^min(n,10) − 1}**, wait **k × slot_time** (slot = 2τ = 51.2 µs on 10 Mb Ethernet), then re-sense and try again.

```text
 n=1 → choose k ∈ {0,1}          n=2 → {0..3}     n=3 → {0..7} …
 n≥10 → window freezes at 1024 slots until success/n>16
```

- Early collisions → small window → quick retry (few losers).
- Heavy congestion → window grows exponentially → **spreads** retries, dampens the system, gives ~stable throughput under overload (interactive stations get priority as short-term losers back off less).
- After 16 attempts → frame dropped (error to higher layer; TCP will retry later).
- Downside (classic interview point): **unfairness/starvation** — a station that keeps colliding can lock out new stations wanting to start (their first collision lands them in tiny k=0/1 window vs incumbents in big windows); also non-deterministic delay (bad for real-time — one reason for switched/802.11 alternatives).

### CSMA/CD workflow (one picture)

```text
 ┌─ sense ─┐ idle: send        collision while sending:
 │ busy:   │──────────────▶  detect → jam → n=n+1
 │ wait/back│                     │
 └─────────┘                 n≤16? ──▶ BEB: wait k slots (k ∈ [0, 2^min(n,10)-1])
                                 │        → re-sense, retry
                                 n>16 → abort, report error
```

---

## 4.5 CSMA/CA

### CSMA/CA concept
**Carrier Sense Multiple Access with Collision Avoidance** — the access method of **Wi-Fi (IEEE 802.11)**. On a wireless link a station **cannot detect collisions while transmitting** (its own transmission drowns out any incoming collision echo — the **hidden terminal** problem makes it worse), so instead of detecting, it **avoids collisions proactively** through inter-frame spaces, random backoff, and optional handshakes.

### Collision avoidance (mechanisms)

1. **Listen before talk (CSMA)** — defer while medium busy (physical + virtual carrier sense).
2. **Inter-frame spaces** — mandatory quiet gaps that also prioritize traffic classes:
   - **DIFS** (DCF IFS) before normal data (longest wait).
   - **SIFS** (short IFS) before ACK/CTS/response (shortest → these get channel first).
   - **PIFS, AIFS** for higher-priority/QoS frames.
3. **Random backoff** — even if the channel is idle after DIFS, wait a **random slot count** (0..CW−1) of slot times; CW (contention window) doubles on failed transmissions (up to CWmax), resets on success — same *idea* as BEB but **countdown pauses when medium goes busy** (frozen), resumes later so stations don't skip while others talk.
4. **Virtual carrier sense (NAV)** — frames carry a **Duration/ID field** announcing how long the medium will be busy (upcoming data+ACK); other stations set their **Network Allocation Vector** countdown and treat the channel as busy without even hearing energy — solves hidden-terminal sensing gaps.
5. **RTS/CTS handshake (optional)** — see below for the big guns against hidden terminals.

### Wireless communication (why Wi-Fi differs from Ethernet)
- **Hidden terminal:** A and C out of range of each other, both in range of B (AP). A can't hear C → both send to B simultaneously → collision at B that neither can detect beforehand.
- **Exposed terminal:** B transmitting to A; C hears B and defers even though its own send to D wouldn't collide — wasted opportunity.
- No collision detection possible: signal is ~10⁻⁵ of transmit power when reflected back; half-duplex radio can't RX while TX.
- ⇒ Avoidance + ACKs (collision ⇒ frame never ACKed ⇒ backoff & retry) replace CD.
- Wireless channels are inherently lossy (fading, interference) — **loss ≠ collision**, but Wi-Fi treats unACKed frames similarly (retransmit with backoff), while higher layers disambiguate.

### RTS (Request To Send)
Short control frame from sender to receiver announcing intent + **duration** of the upcoming data exchange. Stations hearing RTS defer (set NAV). Solved the hidden-terminal launch problem: only the intended receiver's neighborhood knows to shut up for the exact data duration.

### CTS (Clear To Send)
Receiver replies (after SIFS) with CTS echoing the duration — **broadcast to everyone in the receiver's range** (the ones the sender couldn't hear). Now *both* neighborhoods are silent for data + ACK. Data follows; ACK after SIFS.

```text
 A ──RTS──▶ AP ──CTS──▶   (CTS heard by C too)
 A ◀────── data ────── AP
 A ◀──── ACK (SIFS) ─── AP
        (NAV set at C from RTS/CTS durations → C silent throughout)
```

- Overhead: RTS/CTS worth it only for **large frames** (threshold `RTSThreshold`, default often 256 B in 802.11 — tiny management frames skip it); small frames' handshake costs more than a collision recovery.
- 802.11 also fragments large MSDUs to limit bad-frame cost on lossy air.

### CSMA/CD vs CSMA/CA

| Basis | CSMA/CD | CSMA/CA |
|---|---|---|
| Used by | Classic/shared **Ethernet** (802.3) | **Wi-Fi** (802.11) |
| Collision strategy | **Detect** while sending, abort + jam | **Avoid** up front: backoff, IFS, RTS/CTS |
| Can detect mid-Tx? | Yes (wired voltage compare) | No (can't hear over own TX) |
| Recovery | BEB backoff, retry (16 max) | CW backoff, retry with ACK timeout |
| Overhead | Jam + wasted slot on collision | IFS + mandatory backoff + optional RTS/CTS |
| Medium | Shared bus/hub segments | Open air, hidden terminals |
| Modern usage | Full-duplex switched Ethernet disables it | Everywhere on wireless |

---

## 4.6 Controlled Access

Where the medium access is **negotiated/assigned** rather than contested — no collisions by design, but coordination overhead and possible idle waste.

### Reservation
- Time (or frequency) divided into **slots**; each station has a **reserved slot** to announce demand or send data — often a two-level scheme: small **reservation mini-slots** (one per station) where stations signal "I have data", then a schedule packs actual data slots accordingly.
- **Pros:** collision-free, deterministic, fair allocations, efficient under known heavy demand.
- **Cons:** wasted slots for silent stations, scalability of the reservation table, fixed structure (poor for bursty newcomers).
- Examples: reservation ALOHA, **GSM frame structure** (uplink slots), cable modems (DOCSIS grants), satellite TDMA reservations.

### Polling
- Central **primary controller** (master) explicitly **invites** each secondary ("polling") in turn: "do you have data? send now." Token passed logically by the master.
- **Pros:** master controls order/priority, collision-free, easy to measure utilization.
- **Cons:** master is a **single point of failure**; waiting forpolling rounds adds latency for low-priority stations; polling overhead even when idle; scales poorly (poll N stations each cycle).
- Examples: mainframe terminal networks (BSC/SDLC), Bluetooth **master–slave piconet** polling (TDD slots), some fieldbus/industrial nets.

### Token Passing
- A special small frame — the **token** — circulates (logically or physically) around the ring/topology. Only the station **holding the token** may transmit (for up to token-holding time), then passes the token to the next station in address order.
- **Pros:** strictly **collision-free**, bounded worst-case access delay (good for real-time), fair round-robin sharing, no central master (distributed).
- **Cons:** token loss/duplication (needs monitoring/recovery), passing overhead, ring rewiring can break token path (FDDI dual-ring helps), under low load a station must still wait for the token (though "early token release" / grab helps).
- Examples: **IEEE 802.5 Token Ring** (IBM), **FDDI** (fiber backbone, dual counter-rotating rings), **Token Bus 802.4** (logical ring on physical bus — once used in factories/ARCNET).
- Note: token ring's actual idle-slot claiming internally uses **p-persistent** ideas; the exam-level story is: token = explicit permission to transmit.

### Advantages and disadvantages (controlled access overall)

| | Advantages | Disadvantages |
|---|---|---|
| Reservation | No collisions, planned efficiency under load | Waste when reserved slots unused; rigid |
| Polling | Master control, priority, no collisions | Master SPOF; polling latency/overhead |
| Token passing | Collision-free, deterministic bounded delay, fair | Token management complexity; idle-token wait; ring fragility |

**Contrast line:** random access = *simple & great at low load, messy at high load*; controlled access = *predictable & collision-free, but coordination overhead and less agile for bursts.*

---

## 4.7 Channelization

**Channelization** = sharing a wide channel by splitting it into **orthogonal sub-channels** (frequency, time, or code) — multiple stations transmit **simultaneously without collisions** because their signals are separable at the receiver. Family: FDM/TDM/CDM (physical multiplexing view — Ch 1) specialized for multi-station access: **FDMA, TDMA, CDMA**.

### Channelization concept
Instead of arbitrating *who may talk now* (random/controlled access), give each station a **guaranteed orthogonal dimension**: a frequency band, a time slot, or a unique code. Orthogonality ⇒ superposition is separable ⇒ no collisions, no backoff.

### FDMA — Frequency Division Multiple Access
- Bandwidth split into **discrete frequency bands**; each station assigned one band for the whole session; guard bands separate neighbours.
- Stations transmit **continuously in parallel** at their own frequency.
- Simple analog-friendly; fixed allocation wastes the band when a station is silent.
- Example: traditional **AMPS cellular**, cable TV channels, classic FDM telephony.

### TDMA — Time Division Multiple Access
- Time divided into **repeating frames of slots**; each station gets specific slot(s) per frame and transmits only in them (full bandwidth, brief bursts); synchronization is critical.
- Fixed assignment wastes a slot when its owner is idle (statistical TDMA / demand assignment improves this).
- Example: **GSM** (8 users per carrier, each one slot/frame), satellite TDMA systems.

### CDMA — Code Division Multiple Access
- **Every station transmits simultaneously over the entire spectrum**, each spreading its signal with a unique **orthogonal (or pseudo-orthogonal) spreading code** (chips sequence, e.g., length-64 Walsh codes); receiver multiplies by the same code to **despread** desired signal; others integrate to ~0.
- No collisions ever; inherent resistance to narrowband interference/jamming (processing gain); "soft capacity" — more users = raised noise floor, graceful degradation.
- Requires precise power control (near–far problem: strong nearby transmitter drowns others) and tight sync.
- Example: **3G (CDMA2000, WCDMA/UMTS)**, GPS (all satellites same freq, different codes).

```text
 FDMA:  ──freq──▶  [ A ][ B ][ C ][ D ]     each owns a band, always
 TDMA:  ──time──▶  |A|B|C|D|A|B|C|D|…      each owns a slot, in turn
 CDMA:  ──all at once, all freqs──           A⊕codeA, B⊕codeB superposed;
                                              desplice with matching codes
```

### FDMA vs TDMA vs CDMA

| Basis | FDMA | TDMA | CDMA |
|---|---|---|---|
| Divides… | Frequency | Time | Codes (spread spectrum) |
| Simultaneous users | All, different bands | One per slot, same band | All, same band+time |
| Synchronization | Filter tuning | Critical (slot sync) | Chip-level sync + power control |
| Guard/resource | Guard bands | Guard times/slots | Walsh/orthogonal codes |
| Collision risk | None | None (if synced) | None (interference as noise) |
| Capacity trade-off | Fixed channels | Fixed slots | Interference-limited soft capacity |
| Example | AMPS, cable TV | GSM, satellite TDMA | 3G CDMA, GPS |
| Complexity | Lowest | Medium | Highest (codes, power control) |

---

## 4.8 Network Devices

### Repeater
- **Layer 1 (Physical)** device: receives a **weakened/distorated signal, regenerates & retimes it** (for digital) and retransmits with original strength on the other segment.
- **Does NOT** filter traffic — it forwards everything including collisions and broadcast; **one collision domain** on both sides.
- Extends cable distance (e.g., Ethernet max 100 m → add repeater to extend); 5-4-3 repeater rule on classic Ethernet (max 5 segments, 3 populated, 4 repeaters).
- Not smart enough to connect different media/speeds/protocols (a "dumb amplifier").

### Hub
- Essentially a **multi-port repeater** — all ports in one shared medium: bit arriving at one port is **regenerated and broadcast out every other port**.
- **Layer 1** device; **one collision domain** for the entire hub; **one broadcast domain** (same as its network — hubs don't segment either).
- Half-duplex only in practice (shared collision domain); every device sees all frames (only the addressed NIC accepts, but all must CSMA/CD).
- Obsolete for real networks — replaced by switches; still appears in exams/interviews as "dumb splitter".

### Bridge
- **Layer 2 device**: reads **MAC addresses**, maintains a **filtering/forwarding table** (MAC learning: source MAC → incoming port), forwards a frame **only to the segment that needs it**; floods unknown destinations & broadcasts.
- **Segments collision domains** (separate per port) — each port is its own CSMA/CD domain — but **broadcast domain stays one** across the bridge.
- Can join **different link types/speeds** (e.g., Ethernet ↔ Wireless bridge), performs basic error filtering (drops frames with bad CRC rather than forwarding) and rate buffering between segments.
- Half- vs full-duplex domain conversion; simple, transparent (transparent bridge standard IEEE 802.1D).
- Conceptual ancestor of the switch; one large bridge = a switch.

### Switch
- **Layer 2 multi-port bridge** — the workhorse of modern LANs: per-port **collision domain**, MAC-address table (`MAC → port`), forwards frames **only to the destination port** (unicast), floods broadcasts/multicast/unknown unicast.
- **Layer:** Data Link (some "layer-3 switches" also route IP — hybrid).
- Features: **full-duplex** point-to-point links to each endpoint (CSMA/CD disabled), **cut-through vs store-and-forward** forwarding, VLANs (802.1Q), QoS, port mirroring (span), link aggregation.
- **One broadcast domain** per VLAN (by default, whole switch = one broadcast domain until VLANs split it).
- Learning example: PC1 on port 1 sends to PC5 → switch records PC1↔port1; frame floods unknown dest; when PC5 replies, switch learns PC5↔port5 → future traffic PC1↔PC5 switched privately at wire speed.

### Router
- **Layer 3 device**: forwards **packets** between different networks using **IP addresses** and a **routing table** (destination prefix → next-hop interface), making decisions per packet via routing protocols (OSPF, BGP, static).
- **Separates both collision domains AND broadcast domains** — broadcasts do not pass through a router by default (broadcast stops at each interface's broadcast domain).
- Function: path selection across networks, packet filtering/NAT/firewall duties, WAN connectivity, TTL decrement, re-encapsulates new L2 header per hop.
- The device that makes the **Internet** possible (joins LANs, LANs, WANs).

### Gateway
- A device/box that connects **dissimilar environments** — different architectures, protocols, or entire stacks (e.g., OSI ↔ TCP/IP, SNA ↔ IP, email system X ↔ Y, corporate LAN ↔ legacy mainframe).
- Operates at **higher layers too** (up to Application) — actually **translates/converts** protocols (a protocol converter), not just forwards frames/packets.
- In home use "gateway" loosely = the **router/Wi-Fi box** (default gateway = the router IP your subnet uses to leave the network) — but in exams, gateway = protocol translator at layer ≥4 (often called a layer-4+ gateway / brouter may combine bridge+router roles).
- Broadest definition: any device that converts between two different network worlds (firewalls, proxy servers also called application gateways).

### Function of each device / Layer at which each operates

| Device | OSI layer | Addressing used | Broadcast domain | Collision domain | Main function |
|---|---|---|---|---|---|
| Repeater | 1 | None | Passes (same) | Passes (same — one big) | Regenerate weak signals, extend distance |
| Hub | 1 | None | One (whole hub) | **One (all ports)** | Multi-port repeater, broadcast to all |
| Bridge | 2 | MAC | One (across bridge) | **One per port** | Learn MAC table, filter/forward frames |
| Switch | 2 (L3-switch = 2+3) | MAC (IP for L3) | One per VLAN (default 1) | **One per port** | High-speed per-port frame switching |
| Router | 3 | **IP** | **Splits** (each iface own) | **One per interface** | Route packets between networks |
| Gateway | 4–7 | Any / protocol-level | Depends on design | Depends | Protocol conversion between different stacks |

### Collision domain
A network segment where **frame collisions can occur** — all devices that could hear each other transmit simultaneously under CSMA/CD.
- Repeater/hub: everything attached = **one** collision domain.
- Bridge/switch: **each port = its own collision domain** (segmentation multiplies domains — the key exam answer for "why switch beats hub").
- Router: each interface = separate collision domain (and separate L2 segment).
- Full-duplex switch port: effectively **no collisions at all** (dedicated two-wire path).

### Broadcast domain
A set of devices where **broadcast frames (FF:FF:FF:FF:FF:FF)** propagate — every host receives them.
- Hub, bridge, switch (same VLAN): **do not stop broadcasts** → one broadcast domain.
- **Router interfaces: broadcasts terminate** — each interface defines a separate broadcast domain (this is the core reason broadcast storms are contained at layer 3; VLANs exist to carve broadcast domains inside a switch).
- Gateway/firewall policies may further filter.

```text
           collision domains (per switch port)          broadcast domain (L2 VLAN)
 [PC1]──p1│
           │ sw1 ──p5── [router if1]
 [PC2]──p2│                 │ each router iface =
           │                 │ separate broadcast domain
 [PC3]──p3│            [Internet / other LAN]
```

### Device comparison (exam table)

| Basis | Repeater | Hub | Bridge | Switch | Router | Gateway |
|---|---|---|---|---|---|---|
| Layer | 1 | 1 | 2 | 2 (L3: 2+3) | 3 | 4–7 |
| Smartness | Regenerate | Broadcast all | MAC learn/filter | Per-port MAC switch | IP route/lookup | Protocol translate |
| Collision domain | Extends one | Whole hub = 1 | Splits (per port) | Splits (per port) | Per interface | Varies |
| Broadcast domain | Same | Same | Same | Same (per VLAN) | **Splits** | Varies |
| Filters by | No | No | MAC | MAC / VLAN | IP + port/ACL | Full protocol rules |
| Speed (typical) | Signal only | Signal only | Software, slow | Wire-speed hardware | Packet lookup cost | Per-protocol |
| Example use | Extend cable | Legacy shared LAN | Join 2 segments | Office LAN core | Home/office gateway, ISP | Legacy system interconnect, "default gateway" in homes |

> Interview answer: "A hub is a dumb multi-port repeater flooding everything into one collision and broadcast domain. A bridge learns MAC addresses and filters per segment — one collision domain per port, still one broadcast domain. A switch is a high-speed multi-port bridge doing the same at wire speed with full-duplex ports — the default LAN device today. A router works at layer 3 with IP addresses, routes between networks and *contains* broadcast domains. A gateway converts between entirely different protocol stacks at layer 4 and above — and in home usage the word 'gateway' is loosely used for the router box."

---

## Chapter 4 Revision

### ALOHA problems
- Pure ALOHA vulnerable window 2T → max S = 1/2e ≈ 18.4%; Slotted ALOHA vulnerable window T → max S = 1/e ≈ 36.8%; given G, success probability (pure: G·e^(−2G); slotted: G·e^(−G)) — numerical types in [10](10-final-exam-prep.md).

### CSMA concepts
- Sense before send; 1-persistent (immediate on idle — collide more), non-persistent (random wait — collide less, idle more), p-persistent (probabilistic slot claim).

### CSMA/CD
- Detect while sending → jam → BEB (k ∈ [0, 2^min(n,10)−1], 16 attempts max) → Ethernet min frame 64 B = collision-visibility window; **disabled on modern full-duplex switched Ethernet**.

### CSMA/CA
- Wireless: **can't detect** collisions → **avoid** via DIFS + random backoff + NAV + optional **RTS/CTS**; ACK after SIFS; CW doubles on failure; solves hidden terminal.

### Access protocol comparison

| Family | Rule | Example |
|---|---|---|
| Random | Contend, back off on collision | ALOHA, CSMA family |
| Controlled reservation | Pre-booked slots | Reservation ALOHA, DOCSIS |
| Controlled polling | Master invites each node | Bluetooth piconet, mainframe SDLC |
| Controlled token | Only token-holder transmits | Token Ring 802.5, FDDI |
| Channelization | Orthogonal freq/time/code | FDMA, TDMA, CDMA (GSM, 3G) |

### Network device comparison
- Layer 1: repeater/hub (one collision domain whole hub). Layer 2: bridge/switch (collision domain per port, broadcast domain intact per VLAN). Layer 3: router (splits broadcast domains, routes IP). Layer 4+: gateway (protocol conversion). Full matrix in §4.8.

### Important diagrams
1. Collision on a shared bus + jam + backoff timeline.
2. Slotted ALOHA frame slots (successful/empty/collided).
3. CSMA/CA RTS/CTS/ACK exchange with NAV bars at hidden node.
4. Token ring circulation; reservation mini-slots; polling sequence.
5. FDMA bands / TDMA slots / CDMA codes superposition.
6. Hub vs switch: one collision domain vs per-port domains; router splitting broadcast domains.

### Exam questions
1. What is a multiple access protocol? Why are they needed? State design goals.
2. Compare pure and slotted ALOHA with throughput derivations/results (1/2e vs 1/e).
3. Explain 1-persistent, non-persistent and p-persistent CSMA with a comparison.
4. What is CSMA/CD? Explain collision detection, jam signal and binary exponential backoff. Why min frame size 64 bytes?
5. Why can't CSMA/CD be used on Wi-Fi? Explain CSMA/CA with RTS/CTS and NAV (with hidden terminal diagram).
6. Compare random access vs controlled access; describe reservation, polling and token passing with pros/cons.
7. Explain FDMA, TDMA and CDMA with diagrams; compare the three.
8. Compare repeater, hub, bridge, switch, router and gateway (layer + function + domains).
9. Define collision domain and broadcast domain; which devices split which?
10. Why did switches replace hubs in LANs?

### Interview questions
1. Multiple access in one sentence — and why does Wi-Fi use a different method than Ethernet?
2. Walk through binary exponential backoff — what problem does it solve, what's its unfairness?
3. CSMA/CD vs CSMA/CA — which, where, why?
4. What's the hidden terminal problem and how does RTS/CTS fix it?
5. Hub vs switch — what actually changes when you replace one with the other?
6. How does a switch learn MAC addresses?
7. Which device stops broadcasts — hub, switch, or router? Why?
8. FDMA/TDMA/CDMA — which does your mobile phone use daily (GSM=TDMA, 3G=CDMA)?
9. Collision domain vs broadcast domain — define each and give a device that splits it.
10. When would you still use a bridge instead of a switch?

### Quick revision notes
- Multiple access = share one medium; collisions = simultaneous overlap → garbage.
- ALOHA: no sensing (pure 2T vulnerable, 18.4%; slotted T, 36.8%) → CSMA sense first → CD (wired, detect+jam+BEB) / CA (wireless, avoid via backoff+NAV+RTS/CTS).
- Controlled: reservation (slots pre-assigned), polling (master polling — SPOF), token (only token-holder talks — ring/FDDI, bounded delay).
- Channelization: FDMA=freq, TDMA=time, CDMA=code+spreading (power control!) — no collisions ever.
- Devices: repeater/hub L1 flood; bridge/switch L2 MAC-learn (switch = per-port collision domain); router L3 IP-route (splits broadcast); gateway L4+ protocol-translate.
- Collision domain: hub=1, switch port=1, router iface=1. Broadcast domain: hub/bridge/switch=1 (per VLAN), router splits, gateway varies.
