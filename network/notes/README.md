# Computer Networking Notes — College Exams, IT Exams & Fresher Interviews

Interview- and exam-focused notes distilled from *Computer Networks: A Top-Down Approach* (Kurose & Ross) plus the classic college syllabus topics in [`../TODO.md`](../TODO.md). Every checkbox in the TODO maps to a section below.

## Reading order

| # | File | TODO chapter | Topics |
|---|---|---|---|
| 01 | [fundamentals](01-fundamentals.md) | Ch 1 | Data communication, LAN/MAN/WAN, topologies, OSI, TCP/IP, signals, transmission, multiplexing, media |
| 02 | [switching](02-switching.md) | Ch 2 | Circuit / packet / message switching, datagram vs virtual circuit |
| 03 | [data-link-layer](03-data-link-layer.md) | Ch 3 | Framing, checksum, CRC, Hamming, flow control, Stop-and-Wait, Go-Back-N |
| 04 | [multiple-access-and-devices](04-multiple-access-and-devices.md) | Ch 4 | ALOHA, CSMA/CD/CA, token passing, FDMA/TDMA/CDMA, repeater→gateway |
| 05 | [network-layer](05-network-layer.md) | Ch 5 §5.1–5.5 | Routing, IPv4/IPv6, addressing, subnetting/CIDR |
| 06 | [transport-and-security](06-transport-and-security.md) | Ch 5 §5.6–5.11 | TCP, handshake, congestion control, cryptography basics |
| 07 | [application-layer](07-application-layer.md) | Ch 6 | DNS, WWW, HTTP/HTTPS, FTP, SMTP/POP3, DHCP, firewall |
| 08 | [ieee-and-practical](08-ieee-and-practical.md) | Ch 7 | IEEE 802 family, NIC/MAC, home/LAN architecture, CLI commands |
| 09 | [interview-questions](09-interview-questions.md) | Ch 8 | Answered drill bank + the 13 scenario questions |
| 10 | [final-exam-prep](10-final-exam-prep.md) | Final prep | Definitions, diagram index, worked numericals, 18 comparison tables |

One-page rapid revision: [`../FINAL_NOTES.md`](../FINAL_NOTES.md).

## How to use

1. **Learn phase** — read 01→08 in order; after each file, answer its *Exam questions* and *Interview questions* out loud.
2. **Drill phase** — 09 daily in the last week before interviews; every scenario answer spoken, not read.
3. **Exam phase** — 10 for numericals and comparison tables; redo worked problems without looking.
4. **Final pass** — `../FINAL_NOTES.md` the night before; tick `../TODO.md` only when you can answer without notes.

## Conventions used in these notes

- `MUST KNOW` — appears in almost every fresher interview or exam.
- Interview answers are written as speakable blockquotes — say them out loud.
- Diagrams are ASCII so they survive printing and plain-text review.
- Numericals are worked step-by-step in [10-final-exam-prep.md](10-final-exam-prep.md), referenced from chapters.
- Book mapping: Kurose & Ross chapters cited in each header; classic syllabus topics (topologies, ALOHA, Hamming, IEEE 802) marked where they sit outside the book's top-down path.
