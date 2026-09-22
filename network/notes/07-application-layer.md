# 07 — Application Layer Protocols

> Reference: Kurose & Ross Ch. 2 (application layer protocols: DNS, HTTP, email SMTP/SMTPS, P2P) + classic syllabus (DHCP, firewall vs antivirus). | TODO Chapter 6 | Priority: **MUST KNOW** — DNS resolution and the "type a URL" scenario are evergreen interview questions

---

## 6.1 Application Layer

### Purpose of Application Layer

The **top layer of the TCP/IP model** (OSI layer 7) — provides the **network services directly to user applications** and defines the message formats/protocols apps exchange (HTTP requests, SMTP envelopes, DNS queries). It is **not** the application itself: the browser is a program, **HTTP** is its application-layer protocol.

Responsibilities: application support (resource sharing, remote file access, directory services, communication — email, messaging), **data representation/encryption** (SSL/TLS typically layered here or above transport), session/dialog support handled inside apps (TCP/IP has no separate session/presentation layers).

> Interview answer: "The application layer defines the protocols applications use to talk over the network — HTTP for the web, DNS for name resolution, SMTP for mail. It sits on top of transport and uses port numbers to reach the right process; in TCP/IP the OSI session and presentation jobs are folded into it."

### Client-server model

The dominant Internet application architecture:

- **Client** — the initiator; typically runs on user's machine, starts the conversation, sends **requests**, displays responses. May be mobile/intermittent.
- **Server** — the responder; always-on powerful machine with a **well-known port/IP**, waits for requests, provides the service (web, mail, DNS, file), handles many clients concurrently (thread/event-driven).
- Communication: client → request → server → response → client. All traffic logically client↔server (even if CDN/replicas sit behind).

```text
  client (browser)  ── HTTP GET ──▶  server :80
                  ◀── HTML response ──
```

**Contrast — peer-to-peer:** no dedicated servers; peers both consume and provide (BitTorrent, some blockchains, WebRTC calls). Good for massive scale-out of supply; harder for discovery/security/always-on guarantees. Hybrid systems (Spotify: P2P cache + central catalog) common.

### Client

- User-facing endpoint: browser, mail client, mobile app, curl.
- Uses **ephemeral ports**; obtains IP via DHCP; initiates TCP/UDP connections to server's well-known port.
- Responsibilities: build requests (URLs, headers, auth), render/interpret responses, manage cookies/sessions locally.

### Server

- Service provider process bound to a **listening socket** on a well-known port (80, 443, 25, 53…).
- Features: **always available** (redundancy, LB), **stateless where possible** (scale horizontally), **concurrent** (handles thousands of connections), **scalable** (replicas, caches, CDNs).
- Multiple servers behind one IP: load balancers, anycast, round-robin DNS.

### Application protocol

The **agreed rules** for a specific application conversation: message syntax (HTTP request line, headers, body), semantics (status codes, methods), and timing (request→response causality, keep-alive rules).

Examples: **HTTP/HTTPS** (web), **DNS** (naming), **SMTP/POP3/IMAP** (mail), **FTP** (files), **DHCP** (auto config), **SSH** (secure shell), **SIP/RTP** (voice/video), **MQTT/AMQP** (IoT/messaging). Each protocol defines its own well-known port and message set — applications implement or speak them; the transport just carries bytes between ports.

---

## 6.2 DNS

### What is DNS?

**Domain Name System** — the Internet's **distributed hierarchical database and protocol** that translates **human-friendly domain names** (`www.google.com`) into **machine-friendly IP addresses** (`142.250.190.46`) and back (**reverse DNS**), plus other record types (mail servers, aliases…). Defined in RFCs 1034/1035; runs over **UDP port 53** (TCP 53 for zone transfers/large responses).

> Interview answer: "DNS is a distributed, hierarchical naming system that resolves domain names to IP addresses. Your stub resolver asks a recursive resolver; if not cached, the resolver walks the hierarchy — root, then TLD, then authoritative name server for the domain — until it gets the answer, which everyone then caches with a TTL."

### Why DNS is required

- Humans remember **names**; IP routing needs **numbers**. Centralizing every name→IP mapping in one file/host (the original `HOSTS.TXT`) **cannot scale** (constant global updates, single point of failure, traffic bottleneck).
- DNS distributes the database by **hierarchy of domains**, keeps it **replicated** (multiple NS per domain), **caches** aggressively for performance, and gives a stable indirection: you can move servers/change IPs while the name stays constant (load balancing, migration, failover via multiple A records).

### Domain name

The textual address of a node in the DNS tree, read **right-to-left**, labels separated by dots:

```text
 www. example. com.        (root)
  └ subdomain  └ TLD
        hierarchical: more specific on the left, generic on the right
 mail.server.dept.university.edu.in  → each dot = one tree edge
```

- Case-insensitive; max 253 chars total, 63 per label; letters/digits/hyphens (no leading/trailing `-`).
- **FQDN** (fully qualified domain name) ends with a trailing dot (root): `www.example.com.` — the final dot usually omitted when typed.
- Structure enables delegation: `com` registry → `example.com` owner manages everything under it freely (`www`, `mail`, `api` as children).

### IP address mapping

The core **A/AAAA records**:

- **A record** — name → **IPv4** address (e.g., `example.com → 93.184.216.34`).
- **AAAA record** — name → **IPv6** address ("quad-A" = 4×A = 32→128 bits, mnemonic).
- One name may have **multiple A/AAAA** (round-robin load spreading / failover); resolver returns them and the client picks (happy eyeballs prefers IPv6).

### DNS hierarchy

Four levels (conceptually), plus the root:

```text
                    . (root zone — 13 root server clusters A–M, anycast worldwide)
                   /|\
        .com   .org  .net  .in  …          ← TLD registries
        /   \
 example.com  google.com                   ← authoritative (registrant's) zone
  /    |    \
www   mail  api .example.com               ← host/subdomain records, delegated or inline
```

- **Delegation:** each level can NS-delegate sub-zones to other servers — distributing both administration and load.
- Non-domain labels like `53` in reverse `53.1.168.192.in-addr.arpa` build **reverse zones** (PTR records).

### Root server

- The **apex of the tree (`.`)** — knows (or delegates) where every **TLD** zone lives; answers with **referrals** to TLD name servers.
- **13 logical root server identities (A–M)** — physically **hundreds of instances via anycast** (each IP announced from many geographic sites → nearest instance answers). Root operators: ICANN/IANA oversight, Verisign, USC-ISI, NASA, RIPE, ICANN, US Army/DOD/NSI etc. (exam loves "why 13? — original UDP message size/authority design; anycast multiplies real servers to 1000+ sites").
- Your recursive resolver's config (or ISP) knows the root hints to start resolution.

### TLD server

- Manages the **top-level domain zone** (`.com`, `.org`, `.net`, country codes `.in`, `.uk`, plus new gTLDs `.app`, `.dev`…).
- On query for `example.com`'s A record, the root refers you to the **`.com` TLD servers**; those know the **authoritative name servers for each registered domain** (`ns1.example.com`) and refer the resolver there.
- Run by registries (Verisign for .com/.net, registry operators for ccTLDs under country policy).

### Authoritative server

- The **final source of truth** for a zone's records — operated by the domain owner or their DNS provider (Route53, Cloudflare, PowerDNS, BIND).
- Answers with **actual records** (A, MX, TXT, NS…), not referrals; includes **TTL** for caching.
- Typically **primary (master, writable)** + **secondaries (slaves, AXFR/IXFR zone transfer copies)** for redundancy; **stealth/hidden masters** and anycast CDNs (Cloudflare, Akamai) front many zones.
- If it says "no such domain" → **NXDOMAIN** is authoritative (no higher place to appeal).

### DNS resolver

The **client-side agent** that performs lookups on behalf of an application:

- **Stub resolver** — minimal library in OS/app (`getaddrinfo`) that asks the configured **recursive resolver**.
- **Recursive resolver** (ISP's `8.8.8.8` Google, `1.1.1.1` Cloudflare, `9.9.9.9` Quad9, corporate/internal resolvers) — does the full recursive walk (root→TLD→auth) **if cache is cold**, caches everything with TTLs, returns the final answer to the stub. When *you* run `dig @8.8.8.8`, 8.8.8.8 acts as the recursive resolver for you.
- Iterative vs recursive: stub→resolver is usually **recursive** (do it all for me); resolver→hierarchy uses **iterative referrals** (I ask root, take referral, ask next…).

### DNS resolution process (end-to-end, interview whiteboard version)

Example: resolving `www.example.com` with cold caches:

```text
 host/OS stub ──? www.example.com (A)──▶ recursive resolver (e.g. 8.8.8.8)
                                              │ cache miss
 resolver ──▶ root server  "who handles .com?"      → referral to .com NS (192.5.6.30…)
 resolver ──▶ .com TLD NS  "who is auth for example.com?" → referral to ns1.example.com
 resolver ──▶ ns1.example.com (authoritative)  "www.example.com?" → A 93.184.216.34, TTL 3600
 resolver ── caches answer (respecting TTL)
 resolver ──▶ host: 93.184.216.34
 host: connect TCP :443 to 93.184.216.34 (HTTP(S) next)
```

- **Iterative** by default in the hierarchy (each server may just refer you onward); the **stub** issued one **recursive** request to its resolver.
- **Caching everywhere** (resolver cache, OS cache, browser cache) with **TTL countdown** — subsequent lookups often answer in microseconds with zero upstream traffic.
- Failures: **no response → try next NS** (multiple A records for NS = redundancy); **SERVFAIL/NXDOMAIN/REFUSED** propagate up; **DNSSEC** (optional) signs records so resolvers verify authenticity (prevents cache poisoning data tampering — off-path attacks like Kaminsky bug target poisoning with transaction-ID/XID spoofing; DNSSEC + 0x20 + source-port randomization mitigate).

### DNS records (resource records — the zone file entries)

| Type | Full name | Maps… | Typical use |
|---|---|---|---|
| **A** | Address | name → **IPv4** | Main website/endpoint resolution |
| **AAAA** | IPv6 address | name → **IPv6** | Dual-stack hosts |
| **CNAME** | Canonical name | name → **another name** (alias) | `www → example.com` (whole-name replace; not with other records at same node; can't CNAME apex easily — use ANAME/ALIAS at provider) |
| **MX** | Mail exchange | name → mail server (**with priority 0=highest**) | Sending mail routing: `10 mail1.example.com` |
| **NS** | Name server | zone → authoritative NS hostname | Delegation: points child zone to its servers (also glue A records at parent when NS is in-below-child) |
| **PTR** | Pointer | **IP → name** (in `in-addr.arpa` / `ip6.arpa`) | Reverse DNS; used by mail servers to fight spam (rDNS checks), logs |
| **TXT** | Text | name → arbitrary string | SPF/DKIM/DMARC mail auth, domain verification (Google/AWS), ACME HTTP-01 challenges |
| **SOA** | Start of authority | zone metadata: primary NS, admin email, serial (version), refresh/retry/expire, default TTL | Zone file header; secondary transfer policy |
| **SRV** | Service | service/port → host (**_sip._tcp**…) | Service discovery (VoIP, MS AD, Kubernetes) — "which host runs X on port Y" with priority/weight |
| **ALIAS/ANAME** | (vendor ext.) | apex CNAME-like flattening | Point naked root domain to CDN target |

**Common DNS records** for interviews: A, AAAA, CNAME, MX, NS, PTR, TXT (SPF/DKIM/DMARC!), SOA, SRV — know at least these nine, with MX priority and PTR/reverse purpose especially.

### DNS caching

- **Every level caches**: OS stub cache, recursive resolver cache, router/browser caches, even root/TLD NS cache referrals.
- Each answer carries **TTL** (seconds) — resolver stores record until TTL expires, then re-queries (stale-while-revalidate patterns on CDNs).
- **Benefits:** massive load reduction (DNS traffic would explode otherwise), faster lookups (µs vs 100s of ms cold), resilience (resolver answers from cache even if hierarchy briefly down — until TTLs expire).
- **Downsides/attack surface:** **negative caching** (NXDOMAIN cached — brief domain-create delay), TTL trade-off (low = quick changes but more queries; high = cheap but slow propagation of IP changes), **cache poisoning** risk if forged responses accepted (DNSSEC validation + randomization defends), stale answers during migrations.

### DNS ports

- **UDP 53** — normal queries/responses (small, fast, low overhead; connectionless fits one-shot lookups). If response exceeds ~512 B (or EDNS0 buffer), server may truncate (TC bit) → client **retries over TCP 53**.
- **TCP 53** — **zone transfers** (AXFR full / IXFR incremental between primary→secondary), large/EDNS responses, DNSSEC-signed large answers increasingly common.
- Related ports/interview hooks: **853 DNS-over-TLS**, **443 DNS-over-HTTPS** (privacy), **546/547 DHCPv6**, root/TLD/authoritative NS all listen on both TCP+UDP 53.

---

## 6.3 WWW

### What is WWW?

The **World Wide Web** — an **information system of interlinked hypertext documents and resources**, accessed via **browsers** over the Internet using **HTTP(S)** and addressed by **URLs**; invented by Tim Berners-Lee at CERN (1989–91).

**Key distinction (evergreen interview question):** the **Internet** is the global *infrastructure* (routers, cables, TCP/IP) carrying many applications (email, SSH, DNS, games…); the **Web (WWW)** is just *one* application running on top of it via HTTP/HTTPS. Internet ≠ Web — "the Internet is the road, the Web is cars of one specific color (HTTP)."

### Web browser

The **client application** that fetches, interprets and renders web resources:
- Maintains **URL bar, tabs, cookies, cache, TLS trust store, JS engine, rendering engine** (Blink/WebKit/Gecko).
- Workflow: resolve hostname (**DNS**) → **TCP/TLS handshake** → send **HTTP request** → receive response (HTML/CSS/JS/images) → parse DOM/CSSOM → layout/paint → subresource requests (each may hit **CDN** via CNAME chain) → JavaScript runs, may trigger more fetches (XHR/fetch) → interactive page.
- Examples: Chrome, Firefox, Safari, Edge.

### Web server

The **server-side software + machine** that stores/serves web resources:
- Listens on **80 (HTTP) / 443 (HTTPS)** (and alt ports like 8080 for internal), accepts TCP, parses requests, routes to handlers (static files, PHP/Java/Python app, API), returns **HTTP responses** (status, headers, body).
- Software: **Apache httpd, Nginx** (reverse proxy + static), IIS, Caddy, cloud load balancers; frameworks (Express, Django…) sit behind them.
- Can host multiple **virtual hosts** (different sites) on one IP via `Host:` header routing; terminate TLS, do compression, caching headers, auth.

### URL

**Uniform Resource Locator** — the address of *any* resource on the web; full syntax:

```text
 scheme ://  host  [ :port ]  / path  ? query # fragment
   https   :// www.example.com :443 / articles/1 ? id=42 # comments

 scheme  = protocol (http, https, ftp, mailto…)
 host    = domain name or IP (DNS resolves it)
 port    = optional (defaults: http=80, https=443)
 path    = resource location on server (slash hierarchy)
 query   = parameters after '?' (& separated key=value) — sent to server
 fragment= after '#', kept client-side only (never sent to server; JS anchor/SPA route)
```

Related: **URN** (uniform resource *name* — persistent id like ISBN/DOI, "what it is") vs **URI** (uniform resource *identifier* — umbrella: URL locates, URN names). URI = URL + URN conceptually.

### Web request

Client → server message, **HTTP request format**:

```text
GET /index.html HTTP/1.1          ← method, target, version
Host: www.example.com             ← required since HTTP/1.1 (virtual hosting)
User-Agent: Mozilla/5.0 …
Accept: text/html, …
Connection: keep-alive
                                    ← blank line ends headers
(body for POST/PUT)
```

- Carries method, path, headers (cookies, auth, accept-types, conditional `If-None-Match`), optional body; sent over the TCP connection established to server's port (after TLS handshake for HTTPS).

### Web response

Server → client message:

```text
HTTP/1.1 200 OK                   ← version, status code, reason
Content-Type: text/html; charset=utf-8
Content-Length: 5120
Set-Cookie: session=abc; HttpOnly; Secure
Cache-Control: max-age=3600
                                ← blank line
<!DOCTYPE html> … body …        ← payload
```

- Status code communicates outcome (2xx/3xx/4xx/5xx — detailed in §6.4); headers set caching, cookies, security policies (HSTS, CSP); body carries the resource (HTML, JSON, image bytes…).

### Basic web architecture (one picture)

```text
 browser ──DNS A/AAAA──▶ resolver ──▶ root/TLD/authoritative hierarchy
    │
    ├──TCP SYN/ACK──▶ [edge LB / CDN node] ──(cache miss)──▶ origin app servers
    │        └─TLS (cert, ECDHE, AES)─┐        │                │
    ├──HTTP GET /page ────────────────┼────────▶ handlers ──▶ DB/cache
    │◀──200 HTML + Set-Cookie─────────┘
    ├──fetch /style.css, /app.js, /img/logo.png (parallel, keep-alive / HTTP2 streams)
    ├──POST /api/login (body: JSON) ──▶ auth ──▶ 302 redirect / session cookie
    └──render DOM → CSSOM → layout → pixels; JS fetch() → more API calls
```

Model notes: classic **3-tier** (browser client → web/app server → database server), **stateless HTTP** with cookies/session stores for state, **CDN** caches static assets at the edge (anycast + TTL), **reverse proxy** (Nginx) fronts app fleet, **REST/JSON** or GraphQL APIs between front/back — the shape of essentially every modern site.

---

## 6.4 HTTP

### HTTP overview

**Hypertext Transfer Protocol** — the foundation protocol of the Web: **application-layer, stateless, request–response** protocol exchanging **hypermedia/resources** between client and server. Text-based, human-readable (HTTP/2+ binary framed on the wire but same semantics), **default port 80**, HTTPS on **443**. Versions: HTTP/0.9 (simple GET), HTTP/1.0 (headers, per-request TCP), HTTP/1.1 (keep-alive, chunked, pipelining limits, mandatory Host), HTTP/2 (multiplexed streams, HPACK, server push, binary), HTTP/3 (QUIC/UDP, 0-RTT, no head-of-line blocking at transport).

**Stateless by design:** each request is independent; server keeps no memory of previous ones unless the app layers **cookies/sessions/tokens** on top (see below) — statelessness enables easy scaling/caching; cookies restore continuity for logins/carts.

### HTTP request

```text
 METHOD path/version CRLF        ← request line
 header: value CRLF …            ← headers (Host required, User-Agent, Accept, Cookie, Content-Type, Authorization…)
 CRLF                            ← empty line
 optional body                   ← for POST/PUT/PATCH (form data, JSON, files…)
```

Built by browser: method chosen by action (navigation = GET, form submit = POST/GET, JS fetch = various), URL parsed, headers added (cookies auto-attached), body if applicable.

### HTTP response

```text
 HTTP/version status reason CRLF
 header: value CRLF …            ← Content-Type, Content-Length/Encoding, Set-Cookie,
 CRLF                            ← Cache-Control, Location (3xx), Strict-Transport-Security…
 body                            ← resource bytes (may be empty for 204/304)
```

Server constructs: status from handler outcome, headers for type/caching/security, body from file/DB/template; optional `Set-Cookie` issues session id.

### HTTP methods (verbs — safe/idempotent properties matter)

| Method | Purpose | Body? | Safe? | Idempotent? |
|---|---|---|---|---|
| **GET** | Retrieve resource | No (shouldn't) | ✅ yes (no side effects) | ✅ yes |
| **HEAD** | Like GET but headers only, no body | No | ✅ | ✅ |
| **POST** | Create/submit/process (form, API create, actions) | Yes | ❌ | ❌ (usually) |
| **PUT** | Replace resource entirely at URI | Yes | ❌ | ✅ yes (same request twice = same state) |
| **PATCH** | Partial update | Yes | ❌ | ❌ not guaranteed |
| **DELETE** | Remove resource | Optional | ❌ | ✅ yes (delete twice = still deleted) |
| **OPTIONS** | List allowed methods/CORS preflight | No | ✅ | ✅ |
| **CONNECT** | Tunnel (HTTPS proxy CONNECT) | — | ❌ | ❌ |
| **TRACE** | Echo request back (diagnostic; often disabled — XST risk) | No | ✅ | ✅ |

*Interview nugget:* **idempotent** = repeating has same effect as once (safe to retry blindly — crucial for network retries/LoadBalancer behavior); GET/PUT/DELETE idempotent, POST is not (hence payment APIs use idempotency-keys).

### HTTP status codes

| Range | Class | Meaning | Common codes |
|---|---|---|---|
| **1xx** | Informational | Continue/switching protocols | `100 Continue`, `101 Switching Protocols` (WebSocket upgrade) |
| **2xx** | Success | Request OK | `200 OK`, `201 Created` (+ Location), `202 Accepted` (async), `204 No Content`, `206 Partial` (range requests) |
| **3xx** | Redirection | More action needed | `301 Moved Permanently` (permanent, updates bookmarks), `302/307` temporary (307 preserves method), `304 Not Modified` (cache hit — conditional GET), `308` permanent preserving method |
| **4xx** | Client error | Bad request from caller | `400 Bad Request` (malformed), `401 Unauthorized` (**authentication** — need login/credentials), `403 Forbidden` (**authorization** — authenticated but not allowed), `404 Not Found`, `405 Method Not Allowed`, `408 Timeout`, `409 Conflict`, `418 teapot`, `429 Too Many Requests` (rate limit), `451 Legal` |
| **5xx** | Server error | Server-side fault | `500 Internal Server Error` (unhandled exception), `501 Not Implemented`, `502 Bad Gateway` (upstream invalid — LB→dead backend), `503 Service Unavailable` (overloaded/maintenance), `504 Gateway Timeout` (upstream slow — LB timeout), `505 Version Not Supported` |

*Must-memorize five:* 200, 201, 301, 302, 304, 400, 401 vs 403 (frequent interview pair!), 404, 429, 500, 502, 503, 504.

### HTTP headers

Name:value metadata controlling **caching, content negotiation, security, auth, cookies, compression, routing**:

| Category | Headers | Purpose |
|---|---|---|
| Caching | `Cache-Control` (max-age, no-store), `Expires`, `ETag`, `If-None-Match`, `If-Modified-Since`, `Vary` | Freshness/validation; 304 revalidation |
| Content | `Content-Type`, `Content-Length`, `Content-Encoding` (gzip/br), `Accept*`, `Range`/`Accept-Ranges` | What/how body is encoded; partial content (206) |
| Cookies/Session | `Cookie` (req), `Set-Cookie` (resp: HttpOnly, Secure, SameSite, Domain, Path, Max-Age) | State on stateless HTTP; CSRF/XSS mitigations via flags |
| Security | `Strict-Transport-Security` (HSTS), `Content-Security-Policy`, `X-Content-Type-Options: nosniff`, `X-Frame-Options`/`frame-ancestors`, `X-XSS-Protection` (legacy), `Referrer-Policy`, CORS `Access-Control-*` | Browser-enforced hardening |
| Routing/proxy | `Host` (virtual hosting — required), `Location` (3xx/201), `X-Forwarded-For`/`X-Real-IP` (original client behind proxies/LBs) | Which site, where moved, real client IP |
| Connection | `Connection` (keep-alive/close), `Upgrade` (HTTP→WS/h2), HTTP/2 pseudo-headers (`:method`, `:authority`) | Transport/session behavior |
| Auth | `Authorization: Bearer …/Basic …`, `WWW-Authenticate` (401 challenge) | Credentials/tokens |

### Cookies

Small **state fragments** stored by the browser per (domain, path) rules and **automatically attached to matching future requests**:

```text
 Set-Cookie: session=abc123; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=3600; Domain=example.com
 Cookie: session=abc123          ← browser sends it back automatically
```

- **Purpose:** restore statefulness — sessions/logins (server maps session id → user), personalization (language, theme), shopping carts, analytics ids, tracking (3rd-party cookies — increasingly blocked).
- **Types:** 1st-party (same domain you're visiting — generally OK), 3rd-party (set by embedded other-domain resource — ads/trackers; Safari/Firefox/Chrome phase-outs, SameSite=Lax/Strict default mitigations).
- **Security flags:** `HttpOnly` (JS can't read — blocks XSS token theft), `Secure` (HTTPS only), `SameSite=Lax/Strict` (CSRF defense), short `Max-Age`, random high-entropy ids (session fixation defense — regenerate on login).
- Cookie-based session vs **JWT/Bearer tokens** (stateless, carried in `Authorization` header, no auto-send — chosen by SPAs/mobile APIs).

### HTTP vs HTTPS

See §6.5 for full security detail; quick contrast: HTTP = plaintext (headers, cookies, bodies sniffable/modifiable — MITM, session theft); HTTPS = HTTP **inside TLS** — encryption (confidentiality), server **certificate authentication** (you're talking to the real domain), integrity (tamper-evident). Same HTTP semantics/ports-above-transport; URL scheme differs (`https://`), default port 443; browsers mark HTTP as "Not Secure" (and HSTS upgrades/forces HTTPS).

---

## 6.5 HTTPS

### Why HTTPS is required

Plain HTTP over an open network (Wi-Fi, ISP hops) is fully exposed to any observer/relay:
- **Confidentiality loss:** passwords, cookies, card numbers, private messages sniffed (packet capture on café Wi-Fi, ISP logging).
- **Integrity attacks:** responses modified in transit — injected ads/malware, redirected banks (MITM).
- **No authentication:** you can't tell if "yourbank.com" response actually came from your bank — an attacker can spoof the server entirely (DNS spoof + fake site).
- **Downgrade/strip attacks** on login forms.

HTTPS solves all three via **TLS**: encrypt the channel, authenticate the server (certificates), detect tampering — plus platform benefits (browser trust signals, required for modern APIs/PWA features, SEO ranking, service workers only over HTTPS, SameSite/Cookie flags need Secure).

### TLS basics

**Transport Layer Security** (successor of SSL 3.0) — cryptographic protocol providing an **authenticated, encrypted channel** between two endpoints; runs **between TCP and HTTP** (so any app protocol can wrap it — mail, MQTT too). Versions: SSL obsolete (POODLE), TLS 1.0/1.1 deprecated, **TLS 1.2** widely supported, **TLS 1.3** current (fewer round trips, mandatory forward secrecy cipher suites, 0-RTT resumption — with replay caveats).

Services provided:
- **Key exchange** → shared **session keys** without transmitting them (Ephemeral **Diffie-Hellman ECDHE** in TLS 1.3 → **forward secrecy**: stolen server private key can't decrypt past captures).
- **Bulk symmetric encryption** of application data (**AES-128/256-GCM**, ChaCha20-Poly1305 — AEAD: encrypt + integrity together).
- **Message authentication** (HMAC/AEAD tags) — no silent tampering.
- **Server (optionally client) authentication** via certificates — see below.

### Encryption (what actually protects the data)

- Handshake phase uses **asymmetric crypto** (signatures to prove identity, DH to agree secrets) — deliberately slow/complex.
- Application phase switches to **symmetric AEAD** (fast) with keys derived from handshake (HKDF); per-record nonce/sequence numbers prevent replay/reorder; keys periodically updated (rekey) during long sessions.
- Cipher suite naming: `TLS_AES_128_GCM_SHA256` = key-exchange-independent AEAD algorithm + hash for key derivation (TLS1.3 style).

### Certificates

**Digital certificates (X.509)** bind a **domain name (and org info) to its public key**, signed by a trusted **Certificate Authority (CA)**:

```text
 Certificate {
   subject: CN=www.example.com, SAN=*.example.com, O=Example Inc
   issuer:  CN=DigiCert SHA2 Extended Validation…     ← the CA who signed it
   validity: notBefore / notAfter
   public key: ECDSA P-256 …
   extensions: keyUsage, SAN list, basicConstraints…
   signature: CA's digital signature over all above   ← E_priv_CA(H(certificate))
 }
```

- **Trust model (PKI):** browsers/OSes ship with **root CA store** (~100+ roots); chain of trust: leaf cert ← intermediate CA ← root CA (cross-signed bundles). Server presents **chain during TLS handshake**; client verifies signatures up to a trusted root, checks **SAN matches hostname**, validity dates, revocation (**OCSP staple, CRL, CRLite/short-lived certs**) → else "Not Secure"/connection error (NET::ERR_CERT_*).
- **DV/OV/EV** — domain/org/extended validation assurance levels (browsers removed green-padlock EV distinctions; still audits org identity).
- **Wildcard `*.example.com`** (one level), **SAN multi-domain** certs; **Let's Encrypt** = free automated short-lived DV certs (ACME protocol) — made HTTPS universal.
- **Self-signed** = not trusted out of the box (enterprise MITM proxies install their own root — corporate TLS inspection; or pinning/TOFU for apps).

### HTTPS workflow (full handshake — whiteboard version, TLS 1.3 simplified)

```text
 client                                             server
   │ TCP 3WHS (SYN/SYN-ACK/ACK)                        │
   │ 1. ClientHello: versions, cipher suites, key_share (ECDHE pub), random, SNI |
   │──────────────────────────────────────────────────▶│
   │              2. ServerHello: chosen suite, key_share, random              │
   │                 Certificate (chain, SAN=domain) + CertificateVerify (sig) │
   │                 (+ EncryptedExtensions, Finished)                        │
   │◀──────────────────────────────────────────────────│
   │ client verifies: chain to trusted root, SAN match, dates, revocation      │
   │   — derives shared secret from its ECDHE priv + server's pub key_share    |
   │ 3. Finished (MAC over handshake) ─────────────────▶│ verify + derive same keys
   │════ symmetric AEAD channel established (keys, IV/seq) ════│
   │ 4. HTTP: GET / (encrypted records) ───────────────▶│
   │◀────────────── 200 OK (encrypted) ─────────────────│
   │  (close_notify / TCP FIN…)                         │
```

- **Session resumption:** ticket/PSK lets returning clients resume with **0- or 1-RTT** (TLS1.3 0-RTT data — replayable by design, use only for idempotent requests).
- **SNI:** client states target hostname in clear ClientHello (classic = needed to pick cert on shared-IP servers; ECH/DNSSEC efforts aim to encrypt SNI too).

### HTTP vs HTTPS (comparison)

| Basis | HTTP | HTTPS |
|---|---|---|
| Scheme/port | `http://` :80 | `https://` :443 |
| Encryption | None — plaintext | **TLS** encrypted channel |
| Authentication | None (server can be spoofed) | **Certificate** proves domain identity |
| Integrity | No tamper detection | TLS AEAD detects any modification |
| SEO / browser UI | "Not Secure" warning | Padlock/Trusted; required for PWAs, HTTP/2 common use, many APIs |
| Performance | Slightly lighter (no handshake) | Handshake cost (amortized: resumption, session reuse; HTTP2 benefits often outweigh) |
| Cookies/security flags | Can't set `Secure`, HSTS N/A | `Secure`/`SameSite` + HSTS possible |
| Compliance | Not PCI-DSS compliant for card data | Required for handling payments (PCI), sensitive data |
| OSI/viewpoint | Application protocol as-is | HTTP tunneled inside TLS records (some call TLS "session/presentation") |

> Interview answer: "HTTPS is HTTP running inside a TLS session. TLS performs a certificate-authenticated key exchange — the server proves it owns the domain via a CA-signed X.509 certificate, both sides derive forward-secret symmetric keys, and all HTTP traffic then flows as authenticated encryption. That gives confidentiality, integrity and server authentication — which plain HTTP has none of. Same HTTP semantics, different scheme and port."

---

## 6.6 FTP

### FTP purpose

**File Transfer Protocol** (RFC 959) — application-layer protocol for **copying files between a client and a server** over TCP (reliable transfer of potentially large/binary files), with directory navigation, upload/download, resume options. Still common for legacy web deployment, automated transfers (vs SFTP/SCP for security), though largely superseded for interactive use.

### FTP architecture

**Out-of-band control model — two separate TCP connections** (classic exam point):

```text
 client                                    ftp server
   │                                         │
   │──── TCP :21  CONTROL connection ───────▶│  (commands + replies, stays open)
   │      USER, PASS, CWD, LIST, RETR, STOR  │
   │                                         │
   │──── TCP :20  DATA connection ──────────▶│  (or server→client :20 for active mode;
   │      file bytes / directory listings    │   passive: client opens ephemeral→server 21-derived port)
   │◀─── closes after each transfer ────────│
```

- **Default port 21 = control; port 20 = data (active mode server-initiated).**
- **Active vs passive:** active — server initiates data connection *back* to client's advertised port (breaks behind NAT/firewall); **passive (PASV)** — client asks server to listen on an ephemeral port, client connects *outward* (NAT/firewall-friendly; default behavior for most modern clients).
- Authentication: `USER`/`PASS` (plaintext by default — hence FTPS/SFTP), or **anonymous FTP** (`anonymous` / email as password) for public archives.
- Modes: **stream** (default), block, compressed; text (ASCII, converts line endings) vs binary (image — exact bytes) types.

### FTP control connection

- Established on **port 21**, carries the **command/reply protocol**: client commands (`USER`, `PASS`, `LIST`, `CWD`, `RETR` download, `STOR` upload, `QUIT`…) and server's numeric replies (`220` ready, `331` password needed, `150` opening data, `226` transfer complete, `550` failed…).
- **Stays open for the whole session** (interactive control channel) — only the data connection opens/closes per transfer.
- Human-readable ASCII protocol (easy to drive with `ftp` CLI or netcat in labs).

### FTP data connection

- A **separate TCP connection opened just for one transfer's payload** (file or directory listing), then closed — while control persists.
- Carries bulk bytes only (no commands) — enables control to stay responsive (abort transfers, issue new commands mid-transfer).
- Which side initiates depends on mode (**active: server :20 → client ephemeral; passive: client ephemeral → server high port**); exactly one data connection per concurrent transfer (parallel transfers = parallel data connections).

### FTP vs HTTP

| Basis | FTP | HTTP |
|---|---|---|
| Purpose | File transfer (browse dirs, upload/download) | Web resource retrieval (any content, request-response) |
| Connections | **Two: control 21 + data 20/ephemeral (out-of-band)** | Single connection per request session (80/443); data in-band |
| Model | Stateful session (logged in, cwd maintained) | **Stateless** (each request independent; cookies add state) |
| Direction | Sym-ish full-duplex commands, dedicated data pipe | Client GET/POST ←→ server response |
| Directory | Explicit CWD/LIST navigation metaphor | No native dirs — URLs/paths, listing = HTML page or API |
| Security default | Plaintext (USER/PASS exposed) | HTTPS/TLS ubiquitous |
| Resume/modes | Built-in REST, ASCII/binary modes, active/passive | Range requests (206) for resume; mostly binary-safe by headers |
| Modern use | Legacy hosting, automated batch feeds | Everything web; replaced FTP for most human file sharing (also SFTP/SCP object stores took over) |

*Interview line:* "FTP is a stateful two-connection file protocol (control on 21, data on 20/passive) designed before the web; HTTP is a stateless single-connection request-response protocol with URLs — most 'FTP sites' today have moved to HTTPS downloads, SFTP, or object storage presigned URLs."

---

## 6.7 Email Protocols

### Email architecture

The classic **store-and-forward** three-role model (analogy: post office system):

```text
  Alice's MUA (Outlook/Gmail app)          Bob's MUA
        │  compose + send                       ▲  fetch/read
        ▼                                       │
 [SMTP push: Alice MTA/box :25] ──SMTP──▶ [relay chain] ──SMTP──▶ [Bob's MTA :25]
        (mail server A)     hop-by-hop          (mail server B)
                                                     │
                                        Bob pulls via POP3 :110 / IMAP :143
                                                     ▼
                                          Bob's mailbox on server B
```

Roles:
- **MUA** — mail user agent (client: Thunderbird, Apple Mail, webmail JS).
- **MTA** — mail transfer agent (server daemon: Postfix, Sendmail, Exim) speaks **SMTP** to *push* mail onward.
- **MDA/IMAP server** — stores mail in mailbox, serves retrieval (**POP3/IMAP**) or filtering/delivery to folders.
- **Mail flow:** client **uploads** message to *its* server via SMTP; servers **relay** to each other via SMTP (hop by hop, with spool queues + retries); recipient **downloads** from *their* server via POP3/IMAP (or reads webmail which does IMAP server-side).

Ports: **SMTP 25** (server↔server default, often blocked from residential ISPs to fight spam), **587 submission** (client→server with auth, STARTTLS), **465 SMTPS** (implicit TLS legacy), **POP3 110 / POP3S 995**, **IMAP 143 / IMAPS 993**.

### SMTP

**Simple Mail Transfer Protocol** (RFC 5321) — the **push** protocol for **sending and relaying** mail: client→server *and* server→server.
- Text-based command/reply over TCP: `HELO/EHLO`, `MAIL FROM:`, `RCPT TO:` (per recipient), `DATA` (headers + body, dot-terminated), `QUIT`; replies `220/250/354/221…`.
- **One-way push by design** — SMTP delivers *to the recipient's server mailbox*; it does **not** let the recipient *read* mail (that's POP3/IMAP's job).
- Security extensions: **STARTTLS** opportunistic encryption on same port (587), **AUTH LOGIN/PLAIN** (submission), plus anti-spam/auth layers **SPF, DKIM, DMARC** (TXT/DNS-based — see §6.2 records), **MX record** routing selects the right destination server for `@example.com`.

### POP3

**Post Office Protocol v3** — the original **download-and-manage** retrieval protocol (default **110**, TLS variant **995**):
- Session: connect → `USER`/`PASS` (or APOP) → commands `LIST`, `RETR n` (retrieve), `DELE n` (mark delete), `QUIT` (apply deletions, often **leave or remove messages on server** per client config `leave mail on server`).
- Traditionally **downloads to the local client and (often) deletes from server** — single-device, offline-oriented model; limited server-side organization (no two-way sync of read/unread across devices, no server folders standardly).
- Simpler/lighter than IMAP; rarely chosen for multi-device modern life — survives in appliances, simple relays, exams.

### SMTP vs POP3 (and IMAP)

| Basis | SMTP | POP3 | IMAP |
|---|---|---|---|
| Direction/role | **Push/send & relay** (to server) | **Pull/fetch** (from server) | **Pull/sync** (from server) |
| Default port | 25 (also 587/465) | 110 (995 TLS) | 143 (993 TLS) |
| Analogy | Postman dropping mail to PO | Collecting all post from PO box to home | Reading post in the PO with shelf left intact |
| Server copy | Delivers into recipient's store | Often removed after download (optional keep) | **Kept on server** as source of truth |
| Sync model | Stateless per transaction | Mostly download-once; weak sync | Full **two-way sync**: folders, flags, search, partial fetch |
| Multi-device | N/A (transport) | Poor (conflicting copies) | Excellent (central mailbox, all clients consistent) |
| When to mention | "How mail moves between servers" | Legacy/simple single-client retrieval | Modern default for clients (Gmail/Outlook use IMAP; webmail = server-side IMAP) |

### Basic email flow (end-to-end, e.g., Alice gmail → Bob yahoo)

1. Alice's client composes → **SMTP submit** to `smtp.gmail.com:587` (STARTTLS + AUTH) — she uploads the message (client is SMTP *client* here).
2. Gmail's MTA looks up Yahoo's **MX record** (DNS §6.2) → connects to Yahoo's mail exchanger **port 25**, speaks SMTP (`MAIL FROM`, `RCPT TO`, `DATA`) — may relay via anti-spam gateways (SPF/DKIM/DMARC validated, content scanned).
3. Yahoo MTA **accepts and stores** Bob's message in his mailbox (spool → IMAP/POP store); if transient failure, **queues with retries** (store-and-forward reliability built into SMTP).
4. Bob opens mail app → authenticates **IMAPS 993** → syncs headers/bodies/flags → reads; replies reverse roles (Yahoo submit → Gmail MX via SMTP).
5. Server-side filters/MDA rules may divert (junk folders), signatures (DKIM) verified at each hop for trust.

---

## 6.8 DHCP

### What is DHCP?

**Dynamic Host Configuration Protocol** (RFC 2131/8415) — application-layer protocol that **automatically assigns IP addresses and network configuration parameters** to hosts on a network, from a managed pool, for a limited **lease time** — plus delivering subnet mask, default gateway, DNS servers, domain name, NTP, etc., in one transaction. Replaces manual static config and the ancient BOOTP (DHCP is a backward-compatible generalization of BOOTP; relay agent `ip helper` evolved from BOOTP relay).

> Interview answer: "DHCP auto-configures hosts: when a device joins a network it broadcasts a discover; a DHCP server offers an address from its pool; the device requests it; the server acknowledges with a lease and options like gateway and DNS. When the lease expires the address is renewed or released back to the pool — so admins manage a central pool instead of configuring every machine."

### Why DHCP is required

- **Zero-touch deployment** — hundreds of laptops/phones/printers/IoT join without per-device typing; BYOD friendliness.
- **Efficient address utilization** — leases recycle IPs when devices leave (cafeteria Wi-Fi with 5000 visitors can use 500 addresses); avoids manual typos/conflicts (**duplicate IP** misconfigurations are a classic outage).
- **Central control & consistency** — one place to change gateway/DNS/NTP enterprise-wide (push config change to all clients at renew); integration with **IPAM**.
- **Mobility** — device moves subnet (roams VLANs) → gets correct local config automatically on re-DHCP.
- **Complements DNS** — DHCP can update DNS records (dynamic DNS) for discovered hosts.

### DHCP server

- The authority holding the **address pool(s) / scopes** per subnet (e.g., `192.168.1.100–192.168.1.200`), **reservations** (MAC→fixed IP for printers/servers), and **option sets** (option 3 router, 6 DNS, 15 domain-name, 51 lease time, 119 search domains…).
- Software: Windows Server DHCP, ISC Kea/dhcpd, router/switch built-ins, dnsmasq (home routers), cloud-managed (UniFi, Meraki).
- Runs **UDP server port 67** (client uses **68**); typically **one server per subnet** with failover partnerships (split scopes / MCLT hot-standby) for redundancy.
- Maintains **binding database** (leased IP ↔ MAC ↔ hostname ↔ expiry) — powers audits, static-dynamic consistency.

### DHCP client

- Every modern OS/device ships a DHCP client (OS stack, phone radio, printer NIC): on link-up it runs the DORA exchange, applies options to interface (IP, mask, gw, DNS), starts **renewal timers**, sends **DHCPRELEASE** on graceful shutdown/interface down.
- Client identifier (usually MAC or client-id option 61) keys the reservation; client can also **probe** (ARP conflict check) before using offered IP (RFC 5227 context; DHCP itself trusts server's binding).

### DORA process (the four-message handshake — must memorize)

```text
  client (0.0.0.0)                    server (e.g. 192.168.1.1)
      │ 1. DHCPDISCOVER  (broadcast to 255.255.255.255, yiaddr=0)   "any server: I need an IP"
      │──────────────────────────────────────────────────────────▶
      │                    (optional several servers → multiple offers)
      │ 2. DHCPOFFER     (broadcast or unicast: offer IP, mask, gw, DNS, lease, server-id)
      │◀──────────────────────────────────────────────────────────│
      │ 3. DHCPREQUEST    (broadcast "I accept server S's offer X" — selects + confirms)
      │──────────────────────────────────────────────────────────▶
      │                    (other servers see REQUEST → withdraw their offers)
      │ 4. DHCPACK        (broadcast/unicast: final lease confirmation + full options)
      │◀──────────────────────────────────────────────────────────│
      │    client applies IP/mask/gw/DNS, ARP-probes, starts T1/T2 timers
      │  … later: DHCPREQUEST (unicast renew at T1=50%) → ACK  (T2=87.5% broadcast rebind)
      │    on shutdown: DHCPRELEASE → server marks address free
```

- **Why broadcast on a LAN?** client has **no IP yet** (source 0.0.0.0) and may not know server's MAC (no ARP possible pre-config) — hence L2 broadcast `FF:FF:FF:FF:FF:FF` + L3 limited broadcast `255.255.255.255`; **DHCP relay/helper** on the router forwards DORA across subnets to the central server (unicast to server, so central pools serve many VLANs).
- **Lease lifecycle timers:** T1 (renewal) ≈ 50% of lease → unicast REQUEST to original server; T2 (rebinding) ≈ 87.5% → broadcast REQUEST any server until expiry; expiry → client must stop using IP, restart DORA. Release returns address early.
- Message types ride in **option 53** (DISCOVER=1, OFFER=2, REQUEST=3, ACK=5, NAK=6, RELEASE=7, INFORM=8).

### DHCP messages

| Message | Direction | Meaning |
|---|---|---|
| **DHCPDISCOVER** | client → (broadcast) | "Who can give me an IP?" (client-id, params requested) |
| **DHCPOFFER** | server → client | "I can offer 192.168.1.55 for 24h + options" (yiaddr + option 54 server-id) |
| **DHCPREQUEST** | client → (broadcast) | "I choose that offer / renewing my lease" (option 50 requested IP, option 54 chosen server) |
| **DHCPACK** | server → client | "Lease confirmed — here are final options" (binding complete) |
| **DHCPNAK** | server → client | Offer/request rejected (wrong subnet, lease expired, pool gone) → client restarts DORA |
| **DHCPDECLINE** | client → server | "Offered IP already in use on wire (ARP conflict)" → server blacklists it |
| **DHCPRELEASE** | client → server | "I'm done — return address to pool" |
| **DHCPINFORM** | client → server | "I have static IP already, just need options (DNS/domain)" → server ACKs options only |

### DHCP vs DNS

| Basis | DHCP | DNS |
|---|---|---|
| Core job | **Assigns/leases IP + config** to hosts (how you *get* an address) | **Resolves names ↔ IPs** (how you *look up* addresses) |
| Transport | UDP 67/68, broadcast DORA on local link (relay across) | UDP/TCP 53, unicast query chain through hierarchy |
| Direction | Server **pushes** config to joining clients | Client **queries** for records; servers refer/answer |
| State/time | **Leases with expiry**, renewals (T1/T2), releases | **Records with TTL caches** (not leases) |
| When used | Device joining network / boot / renew | Constantly — every service lookup by name |
| Relationship | Server can **auto-update DNS** records for leased IPs (dynamic DNS integration); DHCP supplies DNS *server addresses* (option 6) so the client can then *use* DNS |

*One-line pair for interviews:* "DHCP tells your machine its own IP, gateway and which DNS servers to use; DNS then translates domain names into other machines' IP addresses — DHCP configures you, DNS resolves everyone else."

---

## 6.9 Network Protection

### Firewall

A **security device or software** positioned at trust boundaries (perimeter, segments, host) that **monitors and controls inbound/outbound traffic** according to **configured rules** — permitting legitimate flows and blocking unauthorized/malicious ones (the "gatekeeper between trusted internal network and untrusted external network / between security zones").

- Forms: **hardware appliance** (perimeter edge, NGFW like Palo Alto/Fortinet), **software/host** (Windows Firewall, iptables/nftables/ufw, cloud security groups, Kubernetes NetworkPolicy), **cloud WAF** (Cloudflare/AWS WAF L7), **next-gen** features (app awareness, IDS/IPS, TLS inspection, sandboxing, user-ID policies).
- Placement: **edge/perimeter** (Internet↔LAN), **segmentation** (DMZ↔internal, VLAN↔VLAN — zero-trust microsegments), **host-level** (last line of defense).
- Stateful inspection tracks connections (session table — knows an inbound packet belongs to an *outbound-initiated* TCP session vs unsolicited).

### Purpose of firewall

- Enforce **trust-zone policy**: what may cross (inbound deny-by-default, outbound allow-list for servers; enterprise egress control).
- Block **scans, exploits, C2 callbacks, DDoS volumetrics (with anti-DoS rules)**, geo/IP reputation, protocol misuse.
- **Isolate breaches laterally** — contain malware spread between segments even if one host is compromised (complements antivirus).
- Provide **logging/audit trail** of allowed/denied flows for forensics and compliance; support VPN termination & NAT interaction at edge.
- Core principle: **least privilege** — only required ports/protocols/IPs pass (e.g., allow 443 out, block 3389 from Internet).

### Packet filtering

The classic/simple firewall technique (static/stateless rules on header fields):

- Examines each packet's **5-tuple (src IP, dst IP, protocol, src port, dst port)** + flags against ordered rule list → **permit/deny/drop** (ACL on router interface, `iptables -A INPUT -p tcp --dport 22 -s 10.0.0.5 -j ACCEPT`).
- **Stateless:** each packet judged alone (unless stateful inspection layer added) — symmetric rules needed for return traffic; spoofing/source-routing risks if poorly written.
- **Pros:** fast, cheap (hardware ACLs line-rate), simple mental model, good baseline at L3/L4.
- **Cons:** blind to **payload/app layer** (malicious content inside an allowed 800-byte HTTPS POST), can't decode encrypted traffic without inspection, rule-list complexity → human error (over-permissive "any any" rules), no notion of user/app identity — hence **stateful inspection, proxies, and NGFW/DPI** layered for L7 decisions, plus **WAF** rules for HTTP-specific attacks (SQLi, XSS).

### Antivirus

**Endpoint security software** on hosts detecting/removing **malicious software** (malware) — viruses, worms, trojans, ransomware, spyware, keyloggers, some PUPs:

- Techniques: **signature matching** (known malware hashes/byte patterns — fast but blind to zero-days), **heuristics/behavior monitoring** (suspicious API calls: mass file encryption = ransomware, process injection), **cloud lookups, sandboxing** (execute in isolation), **ML classifiers**, **quarantine/clean** actions, real-time on-access + scheduled on-demand scans.
- Scope: operates on **files, memory, behavior at the OS/app layer** — the *content* on the machine, not the network flow policy.
- Modern suites = **endpoint protection platform (EPP)/EDR** (detect + respond + forensics), sometimes bundled with host firewall — but the *firewall vs antivirus* distinction below is what exams ask.

### Firewall vs Antivirus (classic exam/interview table)

| Basis | Firewall | Antivirus |
|---|---|---|
| What it protects | **Network traffic flows** crossing a boundary | **Files/programs/data** on the endpoint (malware) |
| Where it runs | Perimeter appliance, router, host software, cloud edge | On each host (endpoint) |
| Layer/OSI | Primarily **L3–L4** (packet/stateful), L7 in NGFW/WAF | OS/file system + app behavior (L7 content semantics) |
| Decision basis | IPs, ports, protocols, sessions, (apps/users in NGFW) | File hashes, signatures, behavior, heuristics |
| Stops | Unauthorized access, scans, blocked ports, policy violations | Infections already on disk/executing, malicious payloads |
| Blind spot | Encrypted/payload malware on *allowed* ports (e.g., HTTPS download) | Network recon/DoS/remote exploits before a file lands |
| Analogy | **Building security gate** — checks who/what enters the premises | **Doctor scanning what's inside the person** once they're in |
| Relationship | Complementary: firewall stops the door; antivirus catches what slips through allowed traffic (e.g., email attachments delivered over 443/25); **defense in depth** = both + patching + backups + user training |

> Interview line: "A firewall filters network flows by policy — it's about *traffic* crossing boundaries. Antivirus inspects endpoint files and behavior for malware — it's about *content* already on the machine. They defend different layers: you need both, because a firewall can't see inside an encrypted allowed session, and AV can't stop a port scan or DDoS."

---

## Chapter 6 Revision

### DNS resolution diagram
Stub → recursive resolver → (cache miss) → root referral → TLD referral → authoritative answer → cached → client; A/AAAA records return IPs; ports UDP/TCP **53** — full ASCII in §6.2.

### HTTP request/response
Request line (`GET /path HTTP/1.1` + headers + blank + body) / response (`200 OK` + headers + blank + body); methods GET/POST/PUT/DELETE/PATCH/HEAD/OPTIONS; statuses 1xx–5xx; stateless + cookies/sessions.

### HTTPS basics
HTTP inside **TLS**: ClientHello/ServerHello + **X.509 cert chain** verified against trusted roots (SAN match) + **ECDHE** key exchange (forward secrecy) → **AES-GCM** AEAD bulk encryption; ports 443; solves confidentiality, integrity, authentication (§6.5).

### SMTP/POP3
**SMTP pushes** mail client→server→server (port 25/587) using MX records; **POP3 (110)** downloads/removes, **IMAP (143)** syncs keeping server copy; flow diagram in §6.7.

### DHCP DORA
**D**iscover → **O**ffer → **R**equest → **A**ck (+release, renew at T1=50%, rebind T2=87.5%); UDP 67/68, broadcast before you have an IP, relay across subnets — diagram in §6.8.

### Protocol/port table (memorize)

| Protocol | Port (TCP unless noted) | Transport | Purpose |
|---|---|---|---|
| HTTP | 80 | TCP | Web |
| HTTPS | 443 | TCP | Web over TLS |
| FTP | 21 ctrl / 20 data | TCP | File transfer (out-of-band) |
| SSH | 22 | TCP | Secure shell/remote exec/SFTP |
| Telnet | 23 | TCP | Insecure remote CLI (legacy) |
| SMTP | 25 / 587 / 465 | TCP | Mail send/relay (submission/SMTPS) |
| DNS | 53 | **UDP** (+TCP for large/AXFR) | Name resolution |
| DHCP | 67 server / 68 client | **UDP** | Auto IP config (DORA) |
| POP3 | 110 / 995 (TLS) | TCP | Mail retrieval (download) |
| IMAP | 143 / 993 (TLS) | TCP | Mail sync (server-side folders) |
| SNMP | 161 agent / 162 trap | **UDP** | Device monitoring/management |
| NTP | 123 | **UDP** | Time sync |
| LDAP | 389 / 636 (TLS) | TCP | Directory services (AD) |
| RDP | 3389 | TCP | Windows remote desktop |
| SMB/CIFS | 445 | TCP | Windows file sharing |
| MySQL | 3306 | TCP | MySQL DB |
| PostgreSQL | 5432 | TCP | Postgres DB |
| SIP | 5060 / 5061 (TLS) | TCP/**UDP** | VoIP call setup |
| RADIUS | 1812/1813 (acct 1813/2069 typically 1812 auth) | **UDP** | 802.1X/auth (often 1812/1813) |
| SFTP/SCP | 22 | TCP | Secure file transfer over SSH |
| MQTT | 1883 / 8883 (TLS) | TCP | IoT messaging (broker) |

*(Fuller exam table + diagrams checklist: [10-final-exam-prep.md](10-final-exam-prep.md).)*

### Exam questions
1. What is the application layer's purpose? Client-server vs P2P with examples.
2. What is DNS? Explain its hierarchical architecture (root, TLD, authoritative, resolver) with a resolution diagram for `www.example.com`.
3. List important DNS record types (≥6) with functions; what is reverse DNS?
4. Why is DNS caching needed? Advantages and disadvantages; what are DNS ports?
5. Differentiate Internet vs WWW; describe URL structure with an example annotated.
6. Explain HTTP request and response formats; list methods with safe/idempotent properties and status code classes with examples.
7. What are cookies? How do they restore statefulness? Security flags (HttpOnly, Secure, SameSite).
8. Why is HTTPS needed? Explain TLS handshake (certificate + key exchange) and role of CA/PKI; compare HTTP vs HTTPS.
9. Explain FTP architecture: control vs data connection, active vs passive mode; FTP vs HTTP.
10. Describe email architecture; compare SMTP, POP3 and IMAP (ports, direction, model) with the full mail flow between two domains.
11. What is DHCP? Explain the DORA process with a diagram and lease renewal timers; DHCP vs DNS.
12. What is a firewall? Purpose, packet filtering basics; firewall vs antivirus (table).

### Interview questions
1. DNS in 60 seconds — walk the full resolution path for `google.com`.
2. What happens when you type a URL and press Enter? (full pipeline: URL parse → DNS → TCP → TLS → HTTP → render — see [09](09-interview-questions.md))
3. HTTP vs HTTPS — why does it matter and what does TLS actually do?
4. 401 vs 403 vs 404 vs 500 — one sentence each.
5. GET vs POST — when would you use each? Idempotency?
6. How does a cookie keep you logged in across requests on a stateless protocol?
7. SMTP vs POP3 vs IMAP — which does Gmail's app use? (IMAP; send via SMTP 587)
8. Walk through DHCP DORA — why is it all broadcast at the start?
9. DHCP and DNS seem similar — how do you explain the difference to a junior admin?
10. Firewall vs antivirus — give the building-gate vs doctor analogy and one real gap of each.
11. What is a CNAME vs an A record? When can't you use CNAME?
12. Why do we need MX records separately from A records?

### Quick revision notes
- App layer = protocols for apps (not the app itself); client-server dominant, P2P alternative; well-known ports below 1024.
- DNS = hierarchical distributed DB: stub→recursive→root→TLD→auth; A/AAAA, CNAME, MX, NS, PTR, TXT, SOA, SRV; cache+TTL; **UDP/TCP 53**.
- Internet ≠ Web; URL = scheme://host:port/path?query#frag; web = browser ↔ HTTP ↔ server (3-tier + CDN).
- HTTP = stateless request/response; methods + status classes; cookies restore state (HttpOnly/Secure/SameSite); HTTP/1.1→2→3 evolution.
- HTTPS = HTTP + TLS: cert chain proves identity, ECDHE gives forward secrecy, AES-GCM encrypts bulk; ports 443; PCI/HSTS/PWA need it.
- FTP = two connections (21 control, 20/passive data), stateful file protocol vs HTTP single-connection stateless.
- Email: MUA→SMTP submit→MTA relay (25, MX lookup)→store; retrieve via POP3 (110, downloads) / IMAP (143, syncs).
- DHCP DORA on 67/68 UDP: DISCOVER→OFFER→REQUEST→ACK; T1 renew 50%, T2 rebind 87.5%; relay across subnets; gives IP+gw+DNS — different job from DNS (resolution).
- Firewall = traffic gatekeeper by 5-tuple/stateful/NGFW policy; AV = endpoint malware scanner; complementary defense-in-depth.
