# 02 — Switching Techniques

> Reference: Kurose & Ross §1.3 (circuit switching vs packet switching in the network core) + classic syllabus (message switching, datagram vs VC). | TODO Chapter 2 | Priority: **MUST KNOW**

---

## 2.1 Switching Fundamentals

### What is switching?

**Switching** = the technique of **connecting multiple links together** to establish a path between two devices that are not directly connected, so data can travel source → destination through intermediate nodes (switches/routers).

> Interview answer: "Switching is how a network builds a communication path across intermediate nodes when sender and receiver don't share a direct link. The intermediate device decides, per connection or per packet, where the incoming data should go next."

### Why switching is required?

- Direct (point-to-point) links between **every** pair of devices is physically and economically impossible: n devices would need **n(n−1)/2** links (and each device n−1 interfaces).
- Long distances make dedicated user-to-user cabling absurd.
- Switching lets a **small number of shared links** serve many users by establishing/reusing paths on demand (multiplexing the expensive resource).
- Enables global reach: any host can reach any host through a chain of switched links.

### Switch vs direct communication

| Basis | Direct communication | Switched communication |
|---|---|---|
| Path | Dedicated single link (or full mesh) | Path through intermediate switches/routers |
| Cost | n(n−1)/2 links for full connectivity | Far fewer links; devices only connect locally |
| Setup | Always there | Path set up per call (circuit) or per packet (packet switching) |
| Use case | Two devices constantly talking, tiny embedded links | Telephone networks, the Internet — everything real |
| Example | USB cable PC↔printer | Every call/web page: host → router → … → server |

### Store-and-forward concept

The foundational mechanism of switching nodes: a switch **receives the entire incoming unit** (message/packet/frame), **stores it in a buffer**, checks it for errors / reads its header, **looks up the outgoing path**, then forwards it.

```text
 in ──▶ [ receive ALL → buffer → header/CRC check → routing lookup → transmit ] ──▶ out
```

- **Store-and-forward latency** for a packet of L bits on a link of rate R: transmission delay **L/R** at each hop (the node must receive the whole packet before releasing the first bit onward).
- Contrast with **cut-through switching** (used by some modern layer-2/3 switches): forward as soon as the destination header is read — lower latency, no full-packet error check.
- Every classic switching type (circuit, message, packet) relies on this store-then-forward discipline at each node.

---

## 2.2 Circuit Switching

### Concept
A **dedicated communication path** (a fixed sequence of links and switch connections) is established between sender and receiver **before any data flows**, and that path's resources (a whole channel/frequency/time slot) are **reserved exclusively** for the duration of the session — like a private telephone line.

### Connection establishment
1. Caller sends a **setup/calling request** with destination address.
2. Request travels hop-by-hop; each switch finds a free channel on the next link and **reserves it**, passing the request along.
3. When the destination accepts, a **connect-ack** returns along the reserved path.
4. Now the end systems have a **guaranteed circuit** — reserved bandwidth end-to-end.

### Data transfer
- Both sides send data over the **dedicated path** — no other session may use those reserved channels.
- **No packet headers needed for routing** at intermediate switches — they just follow the pre-connected crossbar path (like water through pre-opened pipes).
- Fixed, predictable **delay**; constant data rate; no queuing loss on this path.

### Connection termination
- Either party signals hang-up; release message travels along the path; each switch **frees the reserved channel** for reuse.
- Resources idle during silence remain reserved (the classic inefficiency of circuit switching).

### Advantages
- **Guaranteed, constant bandwidth** — no queuing, predictable delay ⇒ excellent for **real-time voice/video**.
- Simple intermediate nodes once set up — no per-packet routing/processing.
- No packet loss or out-of-order delivery during the session.
- Private, interference-free channel.

### Disadvantages
- **Inefficient resource use** — channel reserved even when idle (silence in a call); capacity cannot be shared statistically.
- **Setup delay** — every call pays connection-establishment latency before first bit.
- **Scalability** — n simultaneous calls need n complete paths' worth of capacity; expensive for bursty computer traffic.
- If a link/node on the path fails, the **whole circuit dies** — must re-establish.
- Poor fit for the bursty on-off nature of data traffic (web, email).

### Real-world example
- **Traditional landline telephone network (PSTN)** — the classic example: dial, ring, dedicated 64 kbps voice channel until hang-up.
- Old leased lines between company branches (E1/T1 circuits).
- Modern circuit-switched-ish: some cellular voice channels and MPLS label-switched paths (quasi-permanent).

---

## 2.3 Packet Switching

### Concept
The message is broken into **packets**; each packet is **independently routed** hop-by-hop through the network using **statistical multiplexing** of shared links. No dedicated path is reserved — packets of many sessions interleave on every link.

### Packet structure
Each packet carries (at minimum):

```text
+----------------+---------------------------+---------------+
| Header         | Payload (data chunk)      | Trailer (CRC) |
| src/dst IP,    | piece of the message      | error check   |
| pkt #, TTL,... |                           | (link layer)  |
+----------------+---------------------------+---------------+
```

- **Header** — addressing + control info so each router knows where to send it next and the receiver can reassemble.
- **Payload** — typically 500–1500 bytes (Internet MTU ≈ 1500 bytes).
- **Trailer** — frame check sequence at link layer (Ch 3).
- Sequence numbers let the destination **reorder** packets that arrive out of sequence.

### Store-and-forward
Every router receives the **complete packet**, buffers it, checks the header, consults its **routing table**, then transmits it on the best outgoing link — L/R delay at each hop. Packets of different sessions **queue** behind each other (queuing delay; may drop when buffers full ⇒ Internet's best-effort model; TCP retransmits).

### Advantages
- **Efficient use of links** — many conversations statistically share each link; no idle reserved capacity.
- **No setup delay** — first packet can be sent immediately.
- **Robust/fault-tolerant** — if a link fails, subsequent packets are simply routed another way (only in-flight packets may be lost).
- Natural fit for **bursty** computer traffic (on-off demand).
- **Scalable** — incremental cost of adding a user is tiny compared to reserving a full circuit.

### Disadvantages
- **No guaranteed bandwidth or delay** — queuing, jitter, variable path ⇒ unsuitable for real-time without extra QoS.
- **Packet loss, duplication, reordering** possible — needs recovery above (TCP/Ch 3 ARQ).
- **Per-packet processing overhead** — headers at every hop, routing lookups, error checks.
- **Security** — shared links are harder to isolate; eavesdropping/traffic analysis possible.
- End-to-end **delay variable** (jitter) — bad for voice/video unless buffered (playout delay).

### Real-world example
- **The Internet** — the definitive packet-switched network: TCP/IP packets from your browser, streaming, gaming, all interleaved on shared fiber.
- Email, file transfer, web — everything over IP.
- Wi-Fi frames and Ethernet frames between your device and router are packet switching one hop at a time.

---

## 2.4 Message Switching

### Concept
The **entire message** (email, file, no size limit) is sent **store-and-forward** from node to node: each node receives the **whole message**, stores it (on disk/buffer), waits for a free outgoing link, then forwards it — like a message relay / old telegraph hubs. **No circuit is established**, and the message is not split into packets.

### Store-and-forward (message level)
```text
 A ── full msg ──▶ node1 (store whole msg) ── wait for free link ──▶ node2 (store) ──▶ B
```
- Each hop incurs delay = full message transmission time (**size / link rate**) + queuing for an idle link.
- Nodes need **large storage** (whole messages, potentially GBs) buffered between hops.

### Advantages
- No setup delay / no dedicated line needed — efficient for occasional, large transfers.
- Links can be shared by many messages statistically (better utilization than circuit switching).
- Error checking at each hop: corrupted messages dropped/re-requested hop-by-hop.
- No fixed path — any available route can be used per hop; communication lines are utilized efficiently.

### Disadvantages
- **Huge latency** — must receive and store the entire message before forwarding; unacceptable for interactive/real-time traffic.
- **Massive storage requirement** at every intermediate node.
- **No real-time guarantee** — queuing behind long messages (poor for voice/video).
- A failure mid-route loses/delays the whole stored message.
- Wasteful for small messages (fixed overhead of full store cycle per hop).

### Limitations (why it lost to packet switching)
- Cannot handle **real-time** traffic (telephone-era PSTN moved to circuit switching for calls; data moved to packet switching).
- Does not scale to the Internet's heterogeneous, high-speed links — storing GB messages at core routers is impossible operationally.
- Essentially **obsolete for live networks**; historically the **telegraph network** and early node-to-node networks; concepts live on in **application-level relays** (SMTP store-and-forward mail servers, message queues like Kafka — each relay stores the whole message then forwards).

---

## 2.5 Connection Models

### Connection-oriented communication
- A **path/association is established first** (handshake), data follows that logical channel, then explicit teardown.
- Guarantees: **ordering, reliability, flow control** (all bytes arrive, in order, no loss — or reported failure).
- Overhead: setup + per-segment control (ACKs) + teardown.
- Examples: **TCP**, circuit switching, telephone call, HTTP/1.1 over TCP.

### Connectionless communication
- **No setup** — each unit (datagram) is independent: carries full destination address, routed on its own; may take different paths.
- No delivery/order guarantee — receiver gets whatever arrives; recovery (if needed) is the application's job.
- Lower overhead, lower latency to first byte; perfect for request/response and streaming.
- Examples: **UDP**, IP datagrams, postal mail, DNS queries, live video.

### Datagram switching
The **connectionless packet-switching** service model:
- Every packet (datagram) is routed **independently** using its own header address.
- Packets of one message may travel **different paths** and arrive **out of order** (or not at all).
- No per-flow state in the network core — routers just match destination prefix → next hop (like IP/Internet).
- Failure of one path doesn't kill the flow — next packet reroutes automatically.

### Virtual circuit concept
The **connection-oriented packet-switching** service model — *packets, but a circuit-like path*:
- A **virtual circuit ID (VCI)** is assigned at setup; all packets of the flow carry that short VC ID.
- Routers keep a **per-VC table entry** (incoming VC# → outgoing link + outgoing VC#) — state along the path, but **no physical channel is reserved**: capacity still shared statistically.
- All packets follow the **same path** ⇒ **in-order delivery**; resources can be scheduled/QoS'd per VC; failure of the path breaks the whole VC (needs re-establish).
- Examples: **ATM, X.25, Frame Relay, MPLS**, TCP itself (an end-to-end virtual circuit over IP).

```text
 Datagram:                     Virtual circuit:
 pkt1 ──▶ R1 ──▶ R3 ──▶ D     setup: A→R1→R2→D assigns VCI=7
 pkt2 ──▶ R1 ──▶ R2 ──▶ D     all packets follow same path with VC#7
 pkt3 ──▶ R1 ──▶ R4 ──▶ D     (or store VC#7 in per-hop tables)
 (independent paths)           (single logical path, shared links)
```

### Connection-oriented vs Connectionless

| Basis | Connection-oriented | Connectionless |
|---|---|---|
| Setup | Required (handshake/circuit) | None — send immediately |
| Path | Fixed/logical path for the session | Each unit routed independently |
| Ordering | Guaranteed | Not guaranteed |
| Reliability | End-to-end guarantees (or explicit failure) | Best-effort |
| Overhead | Setup + per-packet state/acks | Minimal headers only |
| Examples | TCP, ATM, PSTN | UDP, IP datagrams |
| Failure mid-path | Session/VC affected | Individual units reroute |

---

## 2.6 Switching Comparison

### Circuit vs Packet switching

| Basis | Circuit switching | Packet switching |
|---|---|---|
| Principle | Dedicated path reserved before data | Packets share links statistically |
| Resource use | Reserved even when idle (inefficient) | Only while sending (efficient) |
| Setup delay | Yes (dial/setup + ack) | No |
| Delay | Fixed, predictable | Variable (queuing → jitter) |
| Overhead per unit | Almost none after setup | Header at every hop |
| Reliability | Fixed path — one failure kills session | Reroute around failures |
| Best for | Real-time voice/video, constant bit rate | Bursty data, Internet, web/email |
| Example | PSTN telephone | Internet TCP/IP |

### Packet vs Message switching

| Basis | Message switching | Packet switching |
|---|---|---|
| Unit sent | Entire message, uncut | Message split into packets |
| Storage needed | Whole message at each node | One packet buffer at each node |
| Latency | Very high (L/rate per hop + queue) | Lower (small packets; pipelining) |
| Real-time usable | No | Yes (with QoS/TCP tuning) |
| Routing | Store whole, forward on free link | Per-packet header routing |
| Status | Obsolete for live nets (telegraph) | The Internet's model |

### Connection-oriented vs Connectionless
See §2.5 table. One-line exam form: **CO = establish path/session first, guarantee order/reliability (TCP, circuit, VC); CL = no setup, independent units, best-effort (UDP, IP, datagram).**

### Datagram vs Virtual Circuit

| Basis | Datagram | Virtual circuit |
|---|---|---|
| Path | Per-packet decision — may change | Single path chosen at setup |
| Addressing | Full destination address in every packet | Short **VCI** in every packet; routers map tables |
| Router state | Only destination-prefix table (global) | Per-VC state at every hop on path |
| Ordering | May arrive out of order | In order (same path, scheduled) |
| Failure | Reroute per packet automatically | Whole VC must be re-established |
| Call setup | None | Required (like a "soft" circuit) |
| Example | Internet (IP) | ATM, MPLS, Frame Relay |
| Overhead | Bigger header (full address) | Tiny per-packet label; setup cost once |

> Interview answer: "Datagram switching treats every packet independently with full addressing and lets routers choose paths hop by hop — that's how IP works, robust and stateless. A virtual circuit assigns a circuit ID at setup so all packets of a flow follow one path with per-hop state — it buys ordering and QoS at the cost of setup and path fragility. Circuit switching goes further and physically reserves bandwidth."

---

## Chapter 2 Revision

### Diagrams
1. Circuit switching: setup → dedicated path → data → release (draw reserved channels at each switch).
2. Packet switching: interleaved packets of two sessions on one shared link.
3. Message switching: whole message stored at node1, node2 before forwarding.
4. Datagram (different paths) vs virtual circuit (one path, VCI labels).

### Important definitions
Switching · store-and-forward · circuit · packet · message · connection-oriented · connectionless · datagram · virtual circuit (VCI) · statistical multiplexing · jitter.

### Comparison questions
1. Circuit vs packet switching (table above).
2. Packet vs message switching.
3. Connection-oriented vs connectionless.
4. Datagram vs virtual circuit.
5. Why did packet switching beat message switching for the Internet?
6. Why does voice still prefer circuit-like guarantees?

### Exam questions
1. Define switching; why can't we use direct communication for the whole Internet?
2. Explain store-and-forward with the L/R delay formula.
3. Describe the three phases of circuit switching; list 3 advantages and 3 disadvantages.
4. What is a packet? Draw its structure. Explain how packet switching works with a diagram.
5. Define message switching; why is it not used in modern networks?
6. Differentiate connection-oriented and connectionless services with examples.
7. Compare datagram and virtual-circuit approaches (4 points min).
8. Which switching suits real-time voice? Which suits web browsing? Justify.

### Interview questions
1. What is switching in one sentence?
2. Circuit vs packet switching — which does the Internet use and why?
3. What is store-and-forward and where does its delay come from?
4. Datagram vs virtual circuit — give an example of each.
5. Connection-oriented vs connectionless in 30 seconds.
6. Why does packet switching use bandwidth more efficiently?
7. What's the difference between message switching and packet switching?
8. Where do you still see circuit switching today?

### Quick revision notes
- Switching = path via intermediate nodes; kills the n(n−1)/2 full-mesh problem.
- Store-and-forward: receive whole unit → buffer → check header → forward; hop delay = L/R.
- Circuit: setup → dedicated reserved path → data (no headers needed) → release. Guaranteed but idle-wasting; PSTN.
- Packet: split to packets, statistical share, per-packet routing; efficient, best-effort, jittery; Internet.
- Message: store entire message each hop; huge latency/storage; telegraph-era, obsolete live.
- CO handshake first + ordered reliable (TCP/VC); CL no setup + best-effort (UDP/IP).
- Datagram = per-packet path, full address, stateless routers; VC = one path, short VCI, per-hop state, ordered.
