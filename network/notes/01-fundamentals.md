# 01 — Data Communication & Networking Fundamentals

> Reference: Kurose & Ross Ch. 1 (What Is the Internet?, network edge/core, what is a protocol?) + classic syllabus topics (topologies, signals, media). | TODO Chapter 1 | Priority: **MUST KNOW**

---

## 1.1 Introduction to Networking

### What is Data Communication?

**Data communication** is the exchange of data (information) between two or more devices through some form of transmission medium.

It requires four elements:

| Element | Role | Example |
|---|---|---|
| **Message** | The information to be sent | Text, file, voice, video |
| **Sender (Source)** | Device that sends the message | Laptop, phone, server |
| **Receiver (Destination)** | Device that receives the message | Server, another phone |
| **Transmission medium** | Physical path carrying the data | Copper wire, fiber, air |
| **Protocol** | Rules governing the exchange | TCP/IP, HTTP, Wi-Fi 802.11 |

> Interview answer: "Data communication is the transfer of data between a sender and a receiver over a transmission medium, governed by a set of agreed rules called a protocol. Without a common protocol the two devices cannot understand each other — like two people speaking different languages."

### Components of Data Communication

1. **Message** — the data itself (can be text, audio, video, images).
2. **Sender / Source** — originates the message.
3. **Receiver / Destination** — consumes the message.
4. **Transmission medium** — guided (cable) or unguided (wireless) channel.
5. **Protocol** — a set of rules (syntax, semantics, timing) that both sides follow.

### What is a Computer Network?

A **computer network** is two or more interconnected devices linked together to **share resources and communicate**.

> Interview answer: "A computer network is a set of devices connected by communication links that can share resources — files, printers, internet access — and exchange data under a common protocol."

### Why do we Need Computer Networks?

- **Resource sharing** — printers, storage, internet connection shared by many machines.
- **Communication** — email, messaging, video calls.
- **Data sharing / collaboration** — shared databases, Google Docs-style work.
- **Reliability** — alternative paths and backup machines; no single point of failure.
- **Cost efficiency** — one powerful server instead of many standalone PCs.
- **Scalability** — add new users/devices without redesigning the system.

### Network Criteria

A network must satisfy:

1. **Performance** — throughput and latency (see below).
2. **Reliability** — ability to recover from failures and keep data correct.
3. **Security** — protecting data from unauthorized access and modification.

### Network Performance

Measured mainly by:

- **Throughput** — how much data passes a point per second (bps).
- **Latency / Delay** — time for a bit to travel sender → receiver.
  - *Transmission delay* = L / R (packet bits ÷ link rate)
  - *Propagation delay* = d / s (distance ÷ signal speed)
  - *Processing* + *Queuing* delay at each router.
- **Bandwidth** — the maximum data rate a link can carry.

*Book note (Kurose §1.4):* modern LANs run at 100 Mbps–10 Gbps; end-to-end throughput is limited by the **bottleneck link**, not the fastest link.

### Network Reliability

- Measured by **failure frequency** (mean time between failures) and **recovery time**.
- Techniques: redundancy (RAID, replicated links), routing around failures, error detection/correction (Ch 3), acknowledgements and retransmission (TCP).

### Network Security

Modern networks face attacks; the CIA triad:

- **Confidentiality** — only intended parties read the data (encryption).
- **Integrity** — data not altered in transit (hashes, checksums).
- **Availability** — service stays up under attack (DDoS protection).
- Plus **authentication** (who you are) and **authorization** (what you may do).

*Book note:* Kurose Ch. 1 "networks under attack" — e.g. packet sniffing, IP spoofing, DoS. Countermeasures covered in §5.11 and §6.5 (HTTPS/TLS).

---

## 1.2 Types of Networks

| Type | Geographic span | Speed | Examples |
|---|---|---|---|
| **LAN** (Local Area Network) | Small area — home, office, building, campus | High (100 Mbps–10 Gbps) | Office Wi-Fi, school lab |
| **MAN** (Metropolitan Area Network) | City / town | Medium–High | City cable TV network, municipal Wi-Fi |
| **WAN** (Wide Area Network) | Country, continent, globe | Lower per link (varies) | The Internet, bank branch network |

- **LAN** — privately owned, single organization, low error rate, easy cabling.
- **MAN** — connects multiple LANs across a city; often operated by telecom/cable providers.
- **WAN** — public or leased carriers; may span countries; higher latency, more errors, complex routing.

### Internet

The **Internet** is the largest WAN: a global network of networks interconnected by routers using **TCP/IP**, spanning millions of LANs, MANs and WANs.

### LAN vs MAN vs WAN (quick comparison)

| Basis | LAN | MAN | WAN |
|---|---|---|---|
| Area | Building/campus | City | Country/continent |
| Ownership | Private | Often public/private mix | Public carriers |
| Speed | Highest | Medium | Lowest per link |
| Error rate | Low | Medium | Higher |
| Maintenance | Easy | Moderate | Complex |
| Examples | Home Wi-Fi | City network | Internet |

### Real-world examples

- LAN: your home router + laptop + phone.
- MAN: a university connecting two campuses across town with leased fiber.
- WAN: HDFC branches across India connected to a central data centre; the Internet itself.

---

## 1.3 Modes of Communication (direction of flow)

| Mode | Data flow | Sender↔Receiver | Example |
|---|---|---|---|
| **Simplex** | One direction only | Sender and receiver roles fixed | Keyboard → monitor, radio broadcast, TV |
| **Half duplex** | Both directions, **one at a time** | Roles can swap | Walkie-talkie, hub-based Ethernet |
| **Full duplex** | Both directions **simultaneously** | Both send & receive at once | Telephone, modern switch-based Ethernet |

### Simplex
One device sends, the other only receives. No reverse channel.

### Half Duplex
Both can transmit and receive, but **not at the same time** — must take turns. A shared channel is used in both directions sequentially.

### Full Duplex
Both directions at once. Implemented as two simplex channels (separate frequencies/wires) or by simultaneous bidirectional signalling.

### Comparison

| Basis | Simplex | Half Duplex | Full Duplex |
|---|---|---|---|
| Direction | One-way | Two-way alternate | Two-way simultaneous |
| Speed | Slowest | Medium | Fastest |
| Channel use | 1 simplex | 1 shared | 2 channels (or equiv.) |
| Example | TV remote/sensor | Walkie-talkie | Phone call, fiber link |

### Real-world examples
- Simplex: sensors reporting to a server, FM radio.
- Half duplex: old Ethernet hubs, CB radio, USB 1.1 (shared bus).
- Full duplex: telephone conversation, 100BASE-TX/FX switched Ethernet, fiber links.

---

## 1.4 Network Topologies

**Topology** = the geometric arrangement of computers/nodes and links — *physical* (actual cabling) vs *logical* (how data flows).

```text
BUS                     STAR                      RING
─┬─────┬─────┬─────     ┌───┐                     ┌───┐
 │     │     │          │   │                     │ ▼ │
server pc1   pc2     ┌──┴───┴──┐               ┌──┴───┴──┐
 (backbone)          │  switch  │               │  node   │
                     └─┬──┬──┬─┘               └─┬─────┬─┘
                    pc1 pc2 pc3                  └──▲──┘
```

```text
MESH (full: n(n-1)/2 links)         TREE (hierarchical star)
  A───B                              ┌──── root ────┐
  │╲ ╱│                              │      │      │
  │ ╳  │  (each node linked          hub1  hub2  hub3
  │╱ ╲ │   to every other)            │     │     │
  C───D                              pc    pc    pc
```

### Bus topology
All nodes attach to a single shared cable (backbone). One node transmits → signal travels both ends; ends are terminated to prevent reflection.
- **Advantages:** cheap, easy to install, good for small networks.
- **Disadvantages:** single point of failure (break in cable kills network), collisions grow with traffic, hard to troubleshoot, limited length/nodes.

### Star topology
Every node connects to a central device (hub/switch).
- **Advantages:** easy to add nodes; one node's failure doesn't kill others; simple troubleshooting; no collisions (with a switch).
- **Disadvantages:** central device is a single point of failure; more cabling than bus.

### Ring topology
Each node connects to exactly two neighbours forming a closed loop; data usually travels one direction (or both in dual-ring).
- **Advantages:** equal access (token), no collisions, ordered flow, cheap cabling for small nets.
- **Disadvantages:** one broken link/node can partition the ring (mitigated by dual-ring like FDDI), adding/removing nodes disrupts the ring, hard to troubleshoot.

### Mesh topology
Every node has a dedicated link to every other node.
- Full mesh links = **n(n−1)/2**; each node has degree **n−1**.
- Partial mesh: only critical nodes fully connected.
- **Advantages:** dedicated links → no congestion, fault tolerant (many alternative paths), private/secure links.
- **Disadvantages:** expensive — lots of cable and ports; complex installation and wiring; mostly impractical beyond small critical backbones.

### Tree topology
A hierarchy of stars — a root backbone with branches of hubs/switches ("star-bus"/"hierarchical star").
- **Advantages:** scalable, easy fault isolation by branch, suited to org charts/campus networks.
- **Disadvantages:** backbone failure affects a whole segment; more cabling; performance depends on root link.

### Hybrid topology
A mix of two or more basic topologies (e.g., star + ring, bus + star). Most real networks — LANs of stars connected in a mesh/WAN backbone — are hybrid.
- **Advantages:** reliability and scalability of combining strengths; natural for large real-world networks.
- **Disadvantages:** complex design and troubleshooting; higher cost.

### Advantages & disadvantages summary / Topology comparison

| Topology | Cabling cost | Fault isolation | Reliability | Best for |
|---|---|---|---|---|
| Bus | Lowest | Poor | Low (backbone = SPOF) | Tiny/legacy LANs |
| Star | Medium | Easy | High (node failures isolated) | Modern LANs (switched) |
| Ring | Low–Med | Moderate | Medium (loop break) | Token-ring/FDDI legacy |
| Mesh | Highest | Per-link | Highest (path redundancy) | Backbones, WANs, wireless mesh |
| Tree | Medium | Per-branch | Medium (root SPOF) | Campus/org hierarchy |
| Hybrid | Varies | Varies | Tunable | Real large networks |

---

## 1.5 Internet Basics

### What is the Internet?

A **network of networks**: millions of privately and publicly owned LANs, MANs and WANs linked by routers speaking **TCP/IP**, exchanging traffic using a best-effort packet-switched service.

> "The Internet is a specific global network of networks that uses TCP/IP interconnection; a network is the general term." — Internet ≠ Web: the **Web (WWW)** is one *application* running on the Internet (HTTP).

### Internet history

1. **ARPANET (1969)** — 4 nodes (UCLA, SRI, UCSB, Utah), packet switching, NCP protocol.
2. **TCP invented (1974)** — Cerf & Kahn; TCP/IP mandated on ARPANET **1 Jan 1983** ("flag day").
3. **DNS (1983/84)** — Paul Mockapetris; replaces host tables.
4. **NSFNET (1986)** — backbone linking supercomputing centres; commercial use grows.
5. **WWW (1991)** — Tim Berners-Lee at CERN; browsers (Mosaic 1993) trigger mass adoption.
6. **Modern era** — broadband, mobile 3G/4G/5G, cloud, IoT; tens of billions of devices.

### ISP (Internet Service Provider)

A company that sells Internet access:
- **Tier-1** — global backbones that peer with each other (traffic exchange by settlement-free peering); own long-haul fiber.
- **Tier-2** — regional providers; buy transit from Tier-1, peer with peers.
- **Tier-3 / local (ISP)** — last-mile access to homes/businesses (DSL, cable, fiber, 4G/5G); buy transit from upstream ISPs.

*Book note (Kurose §1.2):* end systems reach the Internet via **access networks** (DSL, cable, FTTH, 5G/4G/Wi-Fi) and then a hierarchy of ISPs.

### Client and Server

- **Client** — the machine/process that *requests* a service (browser, mail app).
- **Server** — the machine/process that *provides* the service, usually always-on with a well-known IP (web server, mail server).
- Same host can be both (your PC is a DNS client to the resolver, and a server if you host files).
- Model: **client–server** (centralized, persistent servers) vs **peer-to-peer** (peers share load directly, e.g. BitTorrent).

### Packet-based communication

Data is chopped into **packets** (blocks with header + payload + trailer); each packet is routed independently and reassembled at the destination.
- Why packets? Efficient multiplexing of many flows on shared links; small buffers; parallel routing; damage limits loss to one packet.
- Packet-switched networks deliver packets **best-effort** — delay, reorder, or lose them; upper layers (TCP) recover.

### Basic Internet architecture

```text
   end systems (hosts)          network core              edge
┌────────────────────┐   ┌─────────────────────┐   ┌──────────┐
│ PC  phone  server ─┼───┤ access net → routers│───┤  routers │
└────────────────────┘   │  (packet switching) │   │ & links  │
                         └─────────────────────┘   └──────────┘
        edge: users/apps live here    core: routers + links move packets
```

- **Edge** — end systems running applications.
- **Core** — mesh of routers interconnected by links; historically circuit switching, Internet = **packet switching**.
- Two service models at the core: **circuit switching** (dedicated path — telephone) vs **packet switching** (statistical multiplexing — Internet). Details in [02-switching.md](02-switching.md).

---

## 1.6 Layered Network Architecture

### Why layering is needed

A full communication system (apps, reliability, routing, signalling, cables) is too complex to design as one blob. **Layering** decomposes it into smaller, independent sub-tasks:
- Each layer implements a **service** for the layer above via **interfaces**.
- Changes inside one layer don't force redesign of others (modularity).
- Divides standards work among specialists (IEEE = physical/DLL, IETF = TCP/IP, ISO = OSI).

Cost of layering: information must pass **down** through layers on send and **up** on receive — extra processing/headers at each hop (encapsulation overhead).

### Protocol

A **protocol** = the set of **rules** governing communication between two entities *at the same layer*: **syntax** (format), **semantics** (meaning of control bits), and **timing/ordering** (when to send, speed matching, response expectations).

> Analogy: a conversation protocol — both speakers must use the same language (syntax), agree what words mean (semantics), and take turns appropriately (timing).

Examples: TCP, IP, HTTP, Ethernet, Wi-Fi (802.11).

### Protocol stack

A **protocol stack** = the set of protocols at each layer that cooperate to provide end-to-end service. The two stacks in use:

- **TCP/IP model** — 4 layers: Application / Transport / Internet / Network Access. *The Internet's actual stack.*
- **OSI model** — 7 layers: reference model used for teaching and classification.

### Encapsulation

As data passes **down** the sender's stack, each layer **adds its own header** (and sometimes trailer) around the data — the process is **encapsulation**. Each unit has a name per layer:

```text
 sender                                              receiver
+--------+                                          +--------+
| App    |  message                                 | App    |  ▲
+--------+                                          +--------+  │
| Trans  |  +-----------+  segment                  | Trans  |  │
+--------+  | message   |  +------------------+     +--------+  │
| Internet|  +-----------+  | header | message |     | Internet|  de-
+--------+                  +------------------+     +--------+  capsu-
| Link   |                  | H | segment | T |  frame| Link   |  lation
+--------+                  +------------------+     +--------+  ▼
   bits:  0 1 0 1 1 0 ...  0 1 1 0
```

```text
 PDU names down the stack:
 App data  →  Transport SEGMENT (TCP) / DATAGRAM (UDP)
           →  Internet PACKET / DATAGRAM (IP)
           →  Link FRAME
           →  Physical BITS
```

The header added at layer N is only meaningful to layer-N entities on both ends (peer-to-peer protocol); intermediate routers only look at network/link headers relevant to them.

### Decapsulation

At the receiver the exact reverse: each layer **strips its header**, inspects control fields, and passes the payload **up** to the next layer until the application receives the original message. Error in a header ⇒ that layer drops the data and (optionally) reports/requests retransmission.

### Service vs protocol

| | **Service** | **Protocol** |
|---|---|---|
| What | A *promise* by a lower layer to the layer above (what is offered: reliable stream, datagrams, latency) | The *implementation rules* between peers at that layer |
| Direction | Vertical (layer → layer) | Horizontal (peer ↔ peer) |
| Analogy | The phone company guaranteeing call quality | The signalling standard the exchanges speak |
| Example | TCP service: reliable, ordered byte stream | TCP protocol: segments, ACKs, retransmission |

> A protocol lets one layer **implement** a service for the layer above. Services are defined by *what*; protocols by *how*.

### Layer responsibilities (summary)

| Layer | Core responsibility | Key protocols |
|---|---|---|
| Application | User-facing services, data representation | HTTP, DNS, SMTP, FTP, DHCP |
| Transport | Process-to-process delivery, reliability, flow/congestion control | TCP, UDP |
| Network/Internet | Host-to-host routing across networks, logical addressing | IP, ICMP, OSPF, BGP |
| Data Link | Node-to-node over one link, framing, MAC addressing, error detection, access control | Ethernet, Wi-Fi, PPP |
| Physical | Bits → signals on media; modulation, data rate, connectors | USB, DSL, 1000BASE-T |

*(Session & Presentation of OSI are handled by the application in TCP/IP — see §1.8.)*

---

## 1.7 OSI Model

**OSI** = Open Systems Interconnection reference model, 7 layers, by ISO — a *reference* (not a protocol suite; the Internet runs TCP/IP).

```text
+-----------------------------------+  ▲
| 7. Application     (user)         |  │
+-----------------------------------+  │
| 6. Presentation  (format/encrypt) |  data passes
+-----------------------------------+  ▼
| 5. Session    (dialog control)    |  ▲
+-----------------------------------+  │
| 4. Transport (end-to-end, process)|  strip/add
+-----------------------------------+  headers
| 3. Network    (routing, IP)       |  ▼
+-----------------------------------+  ▲
| 2. Data Link  (framing, MAC)      |  │
+-----------------------------------+  │
| 1. Physical   (bits, signals)     |  ▼
+-----------------------------------+
```

### Physical Layer (Layer 1)
- Concern: **transmission of raw bits** over a physical medium.
- Defines: voltage levels, pin connectors, data rates, modulation, topology (in part).
- Devices: hubs, repeaters, cables, modems, NIC hardware (signalling part).
- PDU: **bits**.

### Data Link Layer (Layer 2)
- Concern: node-to-node delivery **over a single link**.
- Functions: **framing** (how bits form frames), **physical addressing** (MAC), **error detection** (CRC), **flow control** (stop-and-wait/sliding window on the link), **access control** (who may use the shared medium — Ch 4).
- Devices: switches, bridges, NICs.
- Sublayers: **LLC** (logical link control) and **MAC** (medium access control).
- PDU: **frame**. Detail in [03-data-link-layer.md](03-data-link-layer.md).

### Network Layer (Layer 3)
- Concern: **source-to-destination delivery across multiple networks** (end-to-end across the path).
- Functions: logical addressing (**IP**), **routing** (path choice) and **forwarding** (hop-by-hop), congestion control at this level.
- Devices: **routers**, layer-3 switches.
- PDU: **packet** (datagram). Detail in [05-network-layer.md](05-network-layer.md).

### Transport Layer (Layer 4)
- Concern: **process-to-process** delivery at the destination host.
- Functions: segmentation & reassembly, **port addressing**, end-to-end **error recovery**, **flow control**, **congestion control**.
- Protocols: **TCP** (reliable, connection-oriented), **UDP** (unreliable, connectionless).
- Devices: not a separate device — implemented in hosts (OS kernel); firewalls often act here.
- PDU: **segment** (TCP) / **datagram** (UDP). Detail in [06-transport-and-security.md](06-transport-and-security.md).

### Session Layer (Layer 5)
- Concern: establishing, managing and **terminating sessions** between applications.
- Functions: dialogue control (who transmits when — half-duplex/full-duplex turns), synchronization (checkpoints for recovery), dialog separation.
- Examples: NetBIOS, RPC, PPTP session handling. *In TCP/IP this is merged into the application.*

### Presentation Layer (Layer 6)
- Concern: **syntax and semantics** of the data — the "translator".
- Functions: **character encoding** (ASCII↔EBCDIC), **serialization** (JSON/XML), **encryption/decryption**, **compression**.
- Examples: JPEG, GIF, MPEG, TLS record formatting. *In TCP/IP handled inside applications.*

### Application Layer (Layer 7)
- Concern: providing services **directly to user applications**.
- Protocols: HTTP, HTTPS, DNS, SMTP, FTP, DHCP, SNMP, Telnet/SSH.
- Note: this layer is *not* the application itself (browser ≠ HTTP) — it's the set of protocols apps use.

### Responsibility of each layer (one-liners)

1. **Physical** — move bits; signalling & media.
2. **Data Link** — move frames one hop; framing, MAC, error detection, link flow control.
3. **Network** — move packets end-to-end across networks; IP addressing & routing.
4. **Transport** — move segments between processes; ports, reliability, flow & congestion control.
5. **Session** — open/run/close dialogues; checkpoints.
6. **Presentation** — format, encrypt, compress data.
7. **Application** — user services & protocols.

### PDU of each layer

| OSI layer | PDU | Address used |
|---|---|---|
| 7–5 | Data / message | — |
| 4 Transport | **Segment** (TCP) / Datagram (UDP) | **Port number** |
| 3 Network | **Packet / datagram** | **IP address** |
| 2 Data Link | **Frame** | **MAC address** |
| 1 Physical | **Bits / signal** | — |

### Encapsulation through OSI (worked example — sending an email)

1. App layer produces the message; SMTP adds its header → data.
2. Transport (TCP) adds ports, seq/ack → **segment**.
3. Network layer adds src/dst **IP** → **packet**.
4. Data link adds src/dst **MAC** + CRC → **frame**.
5. Physical turns frame into **bits** → signals on wire.
6. Each router repeats 4→3 (strip L2, read L3, new L2 header for next hop).
7. Receiver reverses: bits → frame (CRC check) → packet (IP check) → segment (TCP reassembly, port demux) → message to mail app.

### OSI layer diagram

Print/draw this in exams (mnemonic bottom→top: **P**lease **D**o **N**ot **T**hrow **S**ausage **P**izza **A**way):

```text
        ┌─────────────┐
   7    │ Application │  HTTP, DNS, SMTP
        ├─────────────┤
   6    │ Presentation│  JPEG, TLS format, ASCII
        ├─────────────┤
   5    │   Session   │  RPC, NetBIOS, dialog control
        ├─────────────┤
   4    │  Transport  │  TCP, UDP     — segment  — ports
        ├─────────────┤
   3    │   Network   │  IP, OSPF     — packet   — IP addr
        ├─────────────┤
   2    │  Data Link  │  Ethernet     — frame    — MAC addr
        ├─────────────┤
   1    │   Physical  │  1000BASE-T   — bits     — (no addr)
        └─────────────┘
```

---

## 1.8 TCP/IP Model

The Internet's actual architecture — a **protocol suite**, not just a reference. 4 layers (some texts show 5 by splitting Network Access).

```text
   TCP/IP                          OSI equivalent
+-----------------------+       7 ┌─────────────┐
| 4. Application        |       6 │ Presentation│
|   HTTP DNS SMTP FTP   |       5 │   Session   |
+-----------------------+       4 ├─────────────┤
| 3. Transport          |         │  Transport  |
|   TCP   UDP           |         ├─────────────┤
+-----------------------+       3 │   Network   │
| 2. Internet           |         ├─────────────┤
|   IP ICMP ARP OSPF    |       2 │  Data Link  |
+-----------------------+       1 ├─────────────┤
| 1. Network Access     |         │   Physical  │
| (Link) Ethernet Wi-Fi |         └─────────────┘
+-----------------------+
```

### Application layer
- Encompasses OSI's **Application + Presentation + Session**.
- Protocols: **HTTP/HTTPS, DNS, SMTP, FTP, DHCP, SSH, SNMP**.
- Responsibilities: user services, data representation/encryption (TLS), session handling inside apps.

### Transport layer
- **TCP** — connection-oriented, reliable, ordered byte stream: segmentation, ACKs, retransmission, flow & congestion control.
- **UDP** — connectionless, best-effort datagrams: minimal overhead, no guarantees (used by DNS, video, games, DHCP).
- Provides **process-to-process** communication via **port numbers**.

### Internet / Network layer
- **IP** (IPv4/IPv6): host-to-host addressing and datagram delivery, best-effort.
- Supporting protocols: **ICMP** (error/control — ping), **ARP** (IP→MAC on local link), routing protocols **OSPF/BGP**, **NAT** at edge routers.
- Connectionless; each packet routed independently.

### Network Access / Link layer
- Combines OSI **Physical + Data Link**: moving frames over the local link.
- **Ethernet (IEEE 802.3)**, **Wi-Fi (802.11)**, PPP; MAC addressing, framing, error detection, media access.
- Book (Kurose): sometimes shown as a single "network edge/access" concern plus link.

### Responsibilities

| TCP/IP layer | Responsibility | Addressing |
|---|---|---|
| Application | User services, formatting, encryption | URL / domain |
| Transport | Process-to-process, reliability, flow/congestion | **Port** |
| Internet | Routing across networks, host addressing | **IP** |
| Network Access | Frame delivery on one link | **MAC** |

### TCP/IP encapsulation

```text
App data
  + TCP/UDP header                 → segment
    + IP header                    → packet (IP datagram)
      + Ethernet header + FCS      → frame
        + preamble/SFD             → bits on wire
```

Each hop: router decapsulates to **IP** (layer 2), consults routing table, re-encapsulates in a **new link-layer header** for the outgoing interface (TTL decremented per hop).

### OSI vs TCP/IP (key exam comparison)

| Basis | OSI | TCP/IP |
|---|---|---|
| Nature | Reference model (theoretical) | Actual protocol suite in use |
| Layers | 7 | 4 (or 5) |
| Developed by | ISO | DoD / IETF |
| Approach | Protocol-independent reference | Protocol-driven; protocols first, model after |
| Session/Presentation | Separate layers | Merged into Application |
| Transport service | Connection-oriented + connectionless defined | TCP (CO) + UDP (CL) both in use |
| Reliability | Can guarantee at each layer | Best-effort IP; reliability optional at transport |
| Header size | Larger (more layers) | Smaller (fewer layers) |
| Adoption | Teaching, vendor classification | The Internet |

> Interview answer: "OSI is a 7-layer *reference* model that cleanly separates session and presentation concerns; TCP/IP is the 4-layer *protocol suite* the Internet actually runs, where those functions live inside applications. OSI explains *what* each concern is; TCP/IP is how it's implemented — and every real packet you capture with Wireshark follows TCP/IP, not OSI."

Full comparison table: [10-final-exam-prep.md](10-final-exam-prep.md#important-comparisons).

---

## 1.9 Data and Signals

### Data vs signal

- **Data** — information to be communicated (discrete or continuous).
- **Signal** — the **electromagnetic form** of that data actually propagated on the medium.

Data → **encoding/modulation** → signal → medium → signal → **decoding** → data.

### Analog data
Continuous information with a **continuous range of values** in both time and amplitude — e.g., voice (sound pressure), temperature, handwritten signature.

### Digital data
**Discrete** values — binary digits 0 and 1 — stored/transmitted as distinct levels (files, integers, keystrokes).

### Analog signal
A continuously varying wave (usually sinusoidal) over time — carries analog or digitized data over phone lines, radio.

Key characteristics: **amplitude, frequency, phase** (see below). Band-limited; repeats periodically if periodic.

### Digital signal
Discrete voltage levels that change at defined instants — e.g., two levels for 0/1 (NRZ), five levels (MLT-3), or Manchester encoding.

- Immune-ish to accumulated noise (regenerate at each hop — repeaters), simpler circuitry, easier multiplexing.
- Needs more bandwidth than the data rate for a given distance (harmonics).

### Periodic vs non-periodic signals

| Periodic | Non-periodic (aperiodic) |
|---|---|
| Pattern repeats every period **T** | No repeating pattern |
| Contains energy only at discrete frequencies (line/spectrum of harmonics) | Energy spread over a **continuous** frequency range |
| Speech-tone, clock, carrier waves | Computer data, bursty traffic |

Real signals (like data signals) are neither purely one nor the other; data signals are typically **aperiodic**, which is why they need wide bandwidth.

### Amplitude
The **maximum height/strength** of the wave (voltage, wattage). Determines signal strength; degrades with distance (→ attenuation).

### Frequency
Number of **cycles per second** — unit **Hertz (Hz)**. f = 1/T where T = period (seconds).
- Low frequency = long wavelength = travels further, carries less info/sec.
- Bandwidth of a signal = difference between highest and lowest frequency it contains.

### Phase
The **relative position** of the wave's point within one cycle, expressed in **degrees/radians** (0°, 90°/¼ cycle, 180°/½ cycle, 270°, 360°=full).
Phase shift = one wave lagging/leading another — used in PSK modulation to encode bits.

### Wavelength (λ)
Distance covered by **one complete cycle** of a travelling wave:

```text
λ = v / f   (metres;  v = propagation speed in the medium)
```

- In free space v ≈ c = 3×10⁸ m/s; in copper ≈ 2×10⁸ m/s; in fiber ≈ 2×10⁸ m/s.
- Example: 1 GHz radio in air → λ = 0.3 m.

### Bit rate (data rate)
Number of **bits transmitted per second** — unit **bps** (kbps, Mbps, Gbps, Tbps).

```text
Bit rate = bits per signal element × signal elements per second
```

### Baud rate
Number of **signal elements (symbol changes) per second** — unit **baud/symbols per second**.

```text
Bit rate = baud rate × bits per signal element (n)
```

- If each signal element carries 1 bit: **bit rate = baud rate** (e.g., simple 2-level NRZ).
- If 4 voltage levels → n = log₂4 = 2 bits/element → 600 baud = 1200 bps.
- **Exam trap:** baud ≠ bits. Baud is *symbols*, bits is *information*.

---

## 1.10 Transmission

### Parallel transmission
Multiple bits sent **simultaneously over multiple wires** (typically 8 data wires + ground).
- **Fast** — one clock tick moves a byte.
- **Costly/heavy cable**, skew over long distances (bits arrive slightly apart), impractical beyond short distances.
- Used inside machines: IDE/ATA, printer parallel port (LPT), internal buses.

### Serial transmission
Bits sent **one after another over a single channel** (one wire/pair/frequency).
- Cheaper cabling, works over long distances, no skew.
- Slower in raw clock terms but modern serial links run at extremely high clock rates.
- Used everywhere external: USB, SATA, Ethernet, fiber, serial RS-232.

### Asynchronous transmission
"Start–stop" character framing: each byte (or small block) sent independently with a **start bit** (and 1–2 stop bits); idle line between characters. Receiver resynchronises on each start bit.
- **No shared clock line** between sender and receiver.
- Simple, low cost, small overhead per byte (20–30% for 8N1), suited to bursty/interactive traffic (keyboard, serial console).
- Timing mismatch over a long character → error; hence short frames.

```text
 idle ──┐S│D0│D1│D2│D3│D4│D5│D6│D7│P│St│ idle ──┐S│ next byte …
        start bit(s)                     stop
```

### Synchronous transmission
Data sent as **continuous streams**; sender and receiver share a **clock** (separate clock line or embedded in signal coding — e.g., Manchester). Data organised into **blocks/frames** (thousands of bytes) with preamble/synchronisation patterns instead of per-byte start/stop.
- Efficient (minimal overhead), high speed, suited to bulk/constant traffic.
- Complex, expensive clocking, errors affect whole blocks (mitigated by CRC/ACK at Ch 3).

### Parallel vs Serial

| Basis | Parallel | Serial |
|---|---|---|
| Wires | Many data lines | One (or one pair/frequency) |
| Speed over distance | Fast short-range; skew limits range | Scales to very high rates long-distance |
| Cost | Expensive/heavy cable | Cheap |
| Clocking | Simpler | May embed clock in encoding |
| Examples | Internal buses, LPT | USB, Ethernet, SATA, fiber |

---

## 1.11 Transmission Impairment

**Impairment** = degradation of the signal between sender and receiver → errors and loss.

### Attenuation
The signal **weakens (loses amplitude)** as it travels — measured in **decibels**:

```text
dB = 10 log₁₀ (P_out / P_in)     power ratio
dB = 20 log₁₀ (V_out / V_in)     voltage ratio
```

- Caused by resistance (copper), scattering/absorption (fiber, air).
- Fix: **amplifiers** (boost signal *and* noise) or **regenerators/boosters** (digital: sample, reshape, retime — noise not accumulated).
- Rule of thumb: voice telephone needs ≥ −9 dB at receiver; too little attenuation ⇒ inter-symbol interference.

### Distortion
The signal's **shape changes** because different frequency components travel at **different speeds** (delay distortion) or follow different paths (**multipath** in wireless — reflected ray arrives late, interferes).
- Worst on twisted pair (frequency-dependent attenuation/delay) → equalisers.
- Cannot be fixed by amplification alone; changes relative phases/amplitudes.

### Noise
Unwanted energy interfering with the signal:

| Type | Cause |
|---|---|
| **Thermal (white Gaussian)** | Electron agitation in conductors; increases with temperature/bandwidth |
| **Intermodulation** | New frequencies generated when signals of different frequencies mix in a non-linear device |
| **Cross-talk** | Induction between adjacent pairs/wires (next-door conversation) |
| **Impulse (random/pick-up)** | Lightning, switching spikes, faulty shielding — bursts |

### Signal-to-noise ratio (SNR)

```text
SNR = P_signal / P_noise   (often in dB: SNR_dB = 10 log₁₀ ratio)
```

- Higher SNR ⇒ cleaner signal ⇒ higher possible data rate.
- **Shannon capacity** (theoretical max bit rate of a noisy channel):

```text
C = B × log₂ (1 + SNR)   bps    (B = bandwidth in Hz)
```

- **Nyquist** (noise-free channel, discrete levels):

```text
C = 2 × B × log₂ L      bps    (L = number of signal levels)
```

*Exam use:* give B and SNR → compute Shannon limit; give B and L → Nyquist limit. Worked examples in [10-final-exam-prep.md](10-final-exam-prep.md#numericals).

### Effects of transmission impairment
- Bit errors (detected by CRC, corrected by Hamming — Ch 3).
- Delay/jitter (affects voice/video — addressed by transport QoS).
- Reduced effective throughput (retransmissions).
- Complete signal loss if attenuation exceeds receiver sensitivity.

---

## 1.12 Multiplexing

### Why multiplexing is needed
A long-haul link (ocean fiber, cell tower airtime) is **expensive**; instead of dedicating it per pair of users, **many signals share one medium** — economies of scale, lower cost per user.

### Multiplexer (MUX)
A device/technique that **combines n input lines into one shared channel** for transmission.

### Demultiplexer (DEMUX)
At the receiving end, **separates** the composite signal back into the individual channels and delivers each to the correct output. MUX+DEMUX are always paired; they agree on the multiplexing scheme (FDM/TDM/WDM).

```text
 in1 ┐            shared medium              ┌ out1
 in2 ┼──▶ [ MUX ] ═══════════════▶ [ DEMUX ]─┼ out2
 in3 ┤                                        ├ out3
```

### FDM — Frequency Division Multiplexing
The bandwidth of the link is **split into distinct frequency bands**; each user/channel gets its own band, all transmitted **simultaneously**. Guard bands between channels prevent overlap/interference.
- **Analog** technique; used in radio/TV broadcasting, cable TV (each channel = a band), OFDM in Wi-Fi/LTE (modern multi-carrier variant).
- Pros: simple, supports continuous streams. Cons: fixed allocation (idle band wasted), inter-channel interference needs guard bands.

### TDM — Time Division Multiplexing
The link is shared **in time**: each channel gets the **whole bandwidth** for a fixed **time slot** in a repeating frame; slots cycle round-robin.
- **Digital** technique; base TDM: synchronous (slots fixed, may be empty) vs statistical/stat TDM (slots allocated on demand — better utilisation).
- Used in: telephone T1/E1 lines, GSM frames, sensor polling.
- Pros: simple, digital-friendly, flexible allocation with stat-TDM. Cons: needs tight synchronisation; sync TDM wastes empty slots.

```text
 TDM frame:  | C1 | C2 | C3 | C4 | C1 | C2 | C3 | C4 | …
 FDM bands:  |--A--|--B--|--C--|--D--|  (all at once, different Hz)
```

### WDM — Wavelength Division Multiplexing
**FDM applied to light**: multiple optical signals, each on a **different wavelength (colour)** of laser, share **one optical fibre** simultaneously.
- Coarse WDM (CWDM): few channels, cheaper lasers; Dense WDM (DWDM): dozens–hundreds of channels on one fiber — backbone capacity multiplied by N.
- Conceptually identical to FDM but at optical frequencies; no electrical bottleneck.

### FDM vs TDM vs WDM

| Basis | FDM | TDM | WDM |
|---|---|---|---|
| Divides… | Frequency bands | Time slots | Light wavelengths |
| Signals coexist | Simultaneously | Take turns | Simultaneously |
| Medium type | Analog-friendly | Digital-friendly | Optical fiber |
| Synchronisation | Filter tuning | Critical (clock) | Laser wavelength precision |
| Waste | Guard bands, idle bands | Empty slots (sync TDM) | Unused spectrum |
| Example | Radio, cable TV | T1/E1, GSM | DWDM backbone |

### Practical examples
- **FDM:** FM radio — 88–108 MHz split into 200 kHz channels per station; cable TV carries hundreds of channels over one coax.
- **TDM:** Your mobile call occupies 1 of 8 time slots in a GSM frame; T1 line multiplexes 24 voice channels.
- **WDM:** A single undersea fiber carries ~100+ Tb/s by stacking DWDM channels; your home fiber (GPON) splits wavelengths for upstream/downstream/data (WDM + power splitting).

---

## 1.13 Transmission Media

The physical path between sender and receiver, grouped into **guided (wired)** and **unguided (wireless)**.

### Guided Media

#### Twisted Pair
Two insulated copper wires twisted together; the twists **cancel electromagnetic interference** and reduce **crosstalk** between pairs (each wire sees similar external noise → differential reception rejects it).
- Cheapest, easiest to install; limited distance (~100 m for Ethernet), susceptible to EMI and eavesdropping.
- Used in: telephone lines (2 pairs), LAN Ethernet cables (4 pairs).

#### UTP — Unshielded Twisted Pair
Just the twisted insulated pairs — no metal foil.
- **Pros:** cheap, flexible, easy to terminate (RJ-45), standard for LANs (Cat5e/6/6a → 1 Gbps–10 Gbps over ≤100 m).
- **Cons:** more vulnerable to external EMI/crosstalk; signals attenuate fast (needs repeaters/switches periodically).
- Examples: Cat5e, Cat6, Cat6a Ethernet patch cables.

#### STP — Shielded Twisted Pair
Each pair (or the bundle) wrapped in metallic foil/braid.
- **Pros:** much better EMI/RFI rejection — required near motors, industrial plant, hospital equipment.
- **Cons:** thicker, stiffer, pricier, needs proper grounding (a floating shield can act as an antenna).

#### Coaxial Cable
Central copper conductor, foam dielectric, metallic braid/shield, outer jacket — the shield confines the signal and blocks interference.

```text
 ┌ signal conductor (core)
 │ ┌ dielectric insulator
 │ │     ┌ braided shield
 ▼ ▼     ▼
 ●━━━━━●████●─────── outer jacket
```

- Better shielding and bandwidth than twisted pair; longer runs without amplification; more expensive & harder to install.
- Impedance: **50 Ω** (thick/thin Ethernet, older LANs), **75 Ω** (cable TV / broadband — carries analog video + DOCSIS data).
- Types: **baseband** (digital, single signal — Ethernet) vs **broadband** (analog, FDM of multiple signals — cable TV).

#### Fiber Optic Cable
Thin glass/plastic strand carrying **pulses of light (laser or LED)** via **total internal reflection**.
- **Pros:** enormous bandwidth (Tbps), extreme low attenuation, **immunity to EMI/crosstalk** (no electrical signal to induce), hard to tap securely, lightweight, no sparking (hazardous areas).
- **Cons:** expensive to purchase/install/terminate, fragile (careful bending), needs optical transceivers, splicing needs skill.

#### Single-mode fiber (SMF)
- Core diameter ≈ **8–10 µm**; laser source; light takes **one path (mode)**.
- Lowest attenuation (~0.2 dB/km @1550 nm), highest distance/bandwidth — **long haul, undersea, carrier backbones** (10–100+ km, no regeneration).
- Expensive lasers/connectors.

#### Multimode fiber (MMF)
- Larger core **50/62.5 µm**; LED or VCSEL source; many light **modes** travel → **modal dispersion** limits distance/bandwidth.
- Shorter reach (≤2 km at 1 Gbps; ~300–550 m at 10 Gbps) — **LAN/data-centre backbone**, cheaper optics.
- Typical: OM3/OM4 aqua-colored 10 GbE up to 300–400 m.

#### Guided media comparison

| Media | Bandwidth | Distance | EMI immunity | Cost | Typical use |
|---|---|---|---|---|---|
| UTP Cat5e/6 | 100 MHz–500 MHz → 1–10 Gbps | ≤100 m | Low | Lowest | Office LAN, home Ethernet |
| STP | Similar to UTP | ≤100 m | Medium | Higher | Industrial environments |
| Coax (75Ω) | Hundreds of MHz | ~hundreds of m | Medium | Medium | Cable TV/DOCSIS |
| Multimode fiber | High (modal-limited) | 300 m–2 km | Complete (optical) | High | Data-centre, floor risers |
| Single-mode fiber | Very high | 10–100+ km | Complete (optical) | Highest | WAN/carrier, FTTx |

### Unguided Media

#### Wireless communication basics
Data carried by **electromagnetic waves through air/vacuum** — no physical conductor. Governed by radio regulations (ITU/ national spectrum authorities), subject to **attenuation, multipath fading, interference, eavesdropping**.
- Signals radiate from omnidirectional or directional antennas; **bandwidth is shared** → needs access protocols (Ch 4: CSMA/CA).
- Bands commonly used: ISM 2.4 GHz (Wi-Fi, Bluetooth, microwave ovens), 5 GHz / 6 GHz (Wi-Fi), licensed cellular bands, 60 GHz (802.11ad/ay), satellite C/Ku/Ka bands.

#### Wi-Fi
**IEEE 802.11** family — wireless LAN using CSMA/CA over 2.4/5/6 GHz ISM bands.
- Standards: 802.11b (11 Mbps, 2.4G), 802.11a/g (54 Mbps), 802.11n (Wi-Fi 4, ~600 Mbps), 802.11ac (Wi-Fi 5, ~3.5 Gbps), 802.11ax (Wi-Fi 6/6E, OFDMA, high density).
- Typical range: tens of metres indoors; AP + mesh extends coverage.

#### Bluetooth
**IEEE 802.15.1** — short-range (~10 m, up to 100 m Class 1) **WPAN** on 2.4 GHz using frequency-hopping spread spectrum (FHSS, 1600 hops/s) to dodge interference.
- Personal devices: headsets, keyboards, tethering, BLE (Bluetooth Low Energy) for wearables/IoT.
- Master–slave piconets (1 master + 7 active slaves); scatternets link piconets.

#### Infrared
**Line-of-sight** light in the near-IR band (~850–950 nm) — remotes, IrDA links, some short-range dongles.
- Cannot penetrate walls (useful privacy/security in one room); needs direct path; ambient light interferes; cheap, unregulated spectrum.

#### Satellite
A repeater in geostationary orbit (**GEO**, ~35,786 km above equator, matches Earth's rotation ⇒ fixed antenna aim) or LEO/MEO constellations (Starlink ~550 km, lower latency).
- Uplink (ground→sat), transponder amplifies/shifts frequency, downlink (sat→ground).
- **Pros:** global coverage incl. remote/rural/maritime/aviation.
- **Cons:** **long propagation delay** (~250 ms round-trip GEO — noticeable in calls), expensive terminals, rain fade, limited spectrum, less secure (wide beam).

### Guided vs Unguided media

| Basis | Guided | Unguided |
|---|---|---|
| Path | Physical conductor/cable | Free space (air/vacuum) |
| Examples | Twisted pair, coax, fiber | Wi-Fi, Bluetooth, satellite, radio |
| Security | Harder to tap | Open to eavesdropping/interference |
| EMI | Affects copper; fiber immune | Inherently exposed to interference |
| Cost of medium | Cable + installation | Spectrum licences/antennas |
| Mobility | Fixed | Supports mobility |
| Attenuation | Higher (copper), low (fiber) | Follows inverse-square + weather |

---

## Chapter 1 Revision

### Important definitions
Data communication · protocol · computer network · LAN/MAN/WAN · topology · simplex/half/full duplex · bandwidth · throughput · latency · attenuation · SNR · multiplexing (FDM/TDM/WDM) · encapsulation · PDU · OSI · TCP/IP · bit rate vs baud rate · ISP · packet · client-server.

### Important diagrams
1. OSI 7-layer stack with PDU & address per layer.
2. TCP/IP 4-layer stack mapped to OSI.
3. Encapsulation/deapsulation flow (sender down, receiver up).
4. Bus / star / ring / mesh / tree / hybrid topologies.
5. MUX → shared link → DEMUX with FDM bands vs TDM slots.
6. Single-mode vs multimode fiber cross-section.

### Important comparisons
- LAN vs MAN vs WAN · Simplex vs Half vs Full duplex · OSI vs TCP/IP · Analog vs digital data · Serial vs parallel · Async vs sync · FDM vs TDM vs WDM · Guided vs unguided · UTP vs STP vs coax vs fiber · Single-mode vs multimode · Bit rate vs baud rate · Service vs protocol — full tables in [10-final-exam-prep.md](10-final-exam-prep.md).

### Exam questions
1. Define data communication; list its five components.
2. State four reasons we need computer networks and three network criteria.
3. Differentiate LAN, MAN and WAN with examples.
4. Draw and compare bus, star, ring and mesh topologies; give the full-mesh link formula.
5. Explain simplex, half-duplex and full-duplex with one example each.
6. What is layering? Why is it needed? Define protocol and protocol stack.
7. Describe encapsulation and decapsulation with a diagram; list PDUs at each layer.
8. Draw the OSI model; state the responsibility, PDU and address of every layer.
9. Compare OSI and TCP/IP models.
10. Define amplitude, frequency, phase and wavelength; relate bit rate to baud rate.
11. Differentiate parallel and serial, asynchronous and synchronous transmission.
12. Explain attenuation, distortion and noise; state SNR and Shannon capacity formula.
13. What is multiplexing? Compare FDM, TDM and WDM with diagrams.
14. Compare guided media (UTP, coax, fiber single/multimode) and unguided media (Wi-Fi, Bluetooth, infrared, satellite).

### Interview questions
1. What is a computer network, and why do we need one?
2. Explain the OSI model without notes — what is each layer's one job?
3. What's the difference between the OSI and TCP/IP models? Which does the Internet use?
4. Walk me through encapsulation when I send an HTTP request.
5. Protocol vs service — what's the difference?
6. LAN vs WAN in one sentence each.
7. What's the difference between bit rate and baud rate?
8. Why do we twist the pairs in a cable?
9. When would you choose single-mode over multimode fiber?
10. FDM vs TDM — which does a mobile phone frame use?

### Quick revision notes
- 4 communication elements→5 components incl. protocol.
- LAN<MAN<WAN by span; Internet = largest WAN, runs TCP/IP.
- Simplex / half / full: one-way / alternate / simultaneous.
- Mesh links = n(n−1)/2; star SPOF = central switch; bus SPOF = backbone.
- Protocol = syntax + semantics + timing, horizontal; service = vertical promise.
- Encapsulation: message → segment → packet → frame → bits; reverse = decapsulation.
- OSI 7 = App/Present/Session/Trans/Net/DataLink/Physical; TCP/IP 4 = App/Trans/Internet/Access.
- PDU/addresses: segment/port, packet/IP, frame/MAC.
- Bit rate = baud × bits-per-element; λ = v/f.
- Impairment: attenuation (dB, amplify/regenerate), distortion (multipath/freq-dependent), noise (thermal/cross-talk) → SNR ⇒ Shannon C = B log₂(1+SNR).
- FDM=frequency, TDM=time, WDM=wavelengths of light.
- Fiber: SMF long-haul single mode; MMF short-reach multi-mode (modal dispersion).
