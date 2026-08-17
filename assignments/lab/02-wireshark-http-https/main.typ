#import "/template/lib.typ": *

#show: assignment.with(
  title: "Capturing Login Credentials over HTTP and HTTPS with Wireshark",
  number: "Assignment 02",
  kind: "Lab",
  course: "Cryptology",
  date: datetime(year: 2026, month: 8, day: 18)
)

= Aim

To investigate how login credentials are transmitted over HTTP and HTTPS, capture the
traffic with Wireshark from a separate attacker machine, and compare what a network sniffer
reads in each case. The portal, the account, and the password stay the same across both
runs. Only the transport protocol changes, which isolates the effect of encryption on the
credentials as they cross the network.

= Lab setup

The lab is a two-machine setup. A Kali Linux virtual machine, running under UTM, holds the
attacker tools, Wireshark and curl. The target is a deliberately insecure "Employee Portal"
login page served from a Docker container on the Mac host. The container builds on a shared
base image and adds Apache, PHP, and OpenSSL. It serves the same page over HTTP on port 80
and over HTTPS on port 443, with a self-signed certificate for the HTTPS side. The login
credentials are hardcoded in the PHP source, and a correct login reaches a dashboard page.
The container binds both ports on `0.0.0.0`, so the Kali VM reaches it across the
hypervisor's shared network at `192.168.64.1`. Both machines stay local, and nothing is
exposed to the public internet, which keeps the work inside the controlled environment the
brief asks for.

#figure(
  caption: [Lab environment],
  {
    set text(9.5pt)
    table(
      columns: (auto, 1fr),
      align: (left, left),
      table.header([Item], [Detail]),
      [Attacker], [Kali Linux VM under UTM, running Wireshark and curl],
      [Target], [Employee Portal login page in a Docker container on the Mac host],
      [Image], [Shared Ubuntu base image, with Apache, PHP, and OpenSSL added],
      [HTTP endpoint], [`http://192.168.64.1/`, port 80],
      [HTTPS endpoint], [`https://192.168.64.1/`, port 443, self-signed certificate],
      [Credentials], [`admin` / `supersecret123`],
      [Capture point], [Wireshark on the Kali interface `eth0`],
      [Isolation], [VM and host on a private hypervisor network, no public exposure],
    )
  },
)

The lab comes from the `manipal_labs` repository. On the host, cloning it and building the
shared `mlabs-base` image once is enough to bring the container up. The `wireshark_lab` folder
holds the Dockerfile, the Compose file, and the two PHP pages, and Docker Compose builds the
image on top of the base and starts the container.

```bash
# On the host: clone the labs and build the shared base image once
git clone https://github.com/anishshobithpscollege/manipal_labs.git
cd manipal_labs
docker build -t mlabs-base:latest .

# Bring up the Wireshark lab
cd labs/wireshark_lab
docker compose up -d --build
```

#figure(
  image("assets/setup-compose-up.png", width: 100%),
  caption: [`docker compose up -d --build` builds the image and starts the
    `wireshark_login_lab` container on the host.],
)

A status check confirms the container is running, with both the HTTP and HTTPS ports mapped
on `0.0.0.0`, so the VM can reach them.

#figure(
  image("assets/setup-compose-ps.png", width: 100%),
  caption: [`docker compose ps` shows the container up, with ports 80 and 443 published on
    `0.0.0.0`.],
)

= Capturing the traffic

== Finding the target address

The container runs on the host, and the Kali VM reaches it over the shared hypervisor
network. The address to aim at comes from the host's own interfaces. On the host, `ifconfig`
lists three IPv4 addresses.

```bash
# On the host
ifconfig | grep "inet "
inet 127.0.0.1 netmask 0xff000000
inet 10.55.2.161 netmask 0xfffff000 broadcast 10.55.15.255
inet 192.168.64.1 netmask 0xffffff00 broadcast 192.168.64.255
```

The first is the loopback address. `10.55.2.161` is the host on the physical network.
`192.168.64.1` is the host on the private network that UTM shares with the VM, where it sits
at `.1` as the gateway of that subnet. The container binds `0.0.0.0`, so it answers on all
three, but `192.168.64.1` is the host-to-VM link with no other traffic on it, which keeps the
capture clean. A ping from Kali confirms the host is reachable there, and the capture bears it
out: every packet runs from the Kali VM at `192.168.64.3` to the host at `192.168.64.1`.

== Sending the login

Wireshark is opened on the Kali interface `eth0`, and the login is sent from the Kali terminal
with curl, once over HTTP and once over HTTPS, using the same credentials each time.

```bash
# From Kali: confirm the host is reachable on the hypervisor network
ping -c 3 192.168.64.1

# HTTP: post the login in plain text
curl -d 'username=admin&password=supersecret123' -X POST http://192.168.64.1/index.php

# HTTPS: the same login, -k accepts the self-signed certificate
curl -k -d 'username=admin&password=supersecret123' -X POST https://192.168.64.1/index.php
```

= HTTP: the password in the clear

With Wireshark capturing on `eth0`, the display filter `http.request.method == "POST"`
isolates the login request. The credentials are sent from Kali with curl over plain HTTP.

#figure(
  image("assets/http-curl-kali.png", width: 100%),
  caption: [The HTTP login sent from Kali. The `ping` confirms the host is reachable at
    `192.168.64.1`, and the `curl` posts the credentials over plain HTTP.],
)

The POST lands in the capture straight away, sourced from the Kali VM at `192.168.64.3` and
addressed to the host at `192.168.64.1`. Wireshark parses the request body and lists the form
fields, `username = admin` and `password = supersecret123`, and the same characters sit in the
packet bytes on the right. Nothing has been decrypted or reconstructed. The password crossed
the network in that form, exposed to anyone watching the interface.

#figure(
  image("assets/http-wireshark-post.png", width: 100%),
  caption: [The captured POST on `eth0`. Wireshark decodes the form fields
    `username = admin` and `password = supersecret123`, and the same text appears in the
    packet bytes on the right.],
)

= HTTPS: the same login, encrypted

The same login is repeated over HTTPS. The `-k` flag accepts the self-signed certificate,
whose subject name is `localhost` and does not match the target IP.

#figure(
  image("assets/https-curl-kali.png", width: 100%),
  caption: [The same login sent over HTTPS from Kali. The `-k` flag accepts the self-signed
    certificate.],
)

For the capture, the display filter `tls` shows the encrypted session, since Wireshark decodes
no HTTP request this time. The traffic appears as TLSv1.3 records, `Client Hello`,
`Server Hello`, and a run of `Application Data` packets. The handshake negotiates the session
keys first, after which the login rides inside the `Application Data` records. Selecting one
shows only ciphertext in the bytes pane, with no readable `username` or `password`. The same
credentials were sent, but TLS wrapped them before they left the host, so the capture holds
nothing but scrambled bytes.

#figure(
  image("assets/https-wireshark-tls.png", width: 100%),
  caption: [The same login over HTTPS, filtered on `tls`. The capture shows TLSv1.3 records,
    `Client Hello`, `Server Hello`, and `Application Data`, and the payload bytes are
    ciphertext.],
)

= HTTP and HTTPS side by side

Both captures come from the same login, sent from Kali to `192.168.64.1`. The table below
lines up what the sniffer read in each one.

#figure(
  caption: [What the sniffer saw over each protocol],
  {
    set text(9.5pt)
    table(
      columns: (1.1fr, 1.5fr, 1.4fr),
      align: (left, left, left),
      table.header([Aspect], [HTTP, port 80], [HTTPS, port 443]),
      [Transport], [Plain text], [Encrypted with TLSv1.3],
      [Display filter used], [`http.request.method == "POST"`], [`tls`],
      [POST body in the capture], [Readable: \
        `username=admin&` \
        `password=supersecret123`],
      [Not readable, only TLS records],
      [Password recovery], [Direct, from the POST packet],
      [Not possible without the session keys],
      [What the sniffer sees], [Form fields decoded in plain text],
      [`Application Data` bytes are ciphertext],
    )
  },
)

= Role of encryption

The only change between the two runs is the scheme in the URL. The portal, the password, and
the server are identical. Over HTTP the password reaches the network as the characters typed
into the form, so a sniffer on the path reads it with no effort. Over HTTPS, TLS wraps the
request before it leaves the host, and the sniffer receives bytes that carry no meaning on
their own.

TLS contributes in three ways. It keeps the payload confidential, which is what hides the
password. It protects integrity with a message authentication code, so any
change to the ciphertext in transit is detected. And in a real deployment it authenticates
the server through a certificate signed by a trusted authority, which prevents an attacker
from posing as the site. This lab uses a self-signed certificate, so the client warns that it
cannot vouch for the server's identity, yet the encryption still functions. That warning
concerns trust, not the strength of the encryption.

This gap is the reason a login page must run over HTTPS. Plain HTTP trusts every device
between the browser and the server: the local network, a rogue Wi-Fi access point, an ISP, or
a compromised router. Any one of them can read the password. HTTPS removes that trust from the
network and places it in the keys instead, and the packet capture demonstrates the result. One
run leaves a password that anyone on the network can copy. The other leaves a block of bytes
that is useless without the session secret.

= Conclusion

The capture makes the difference concrete. Over HTTP, `admin` and `supersecret123` are
recovered directly from the captured POST packet, where Wireshark decoded the form fields sent
across the network. Over HTTPS, the same login produces only TLSv1.3 records, and the
`Application Data` payload is ciphertext. Encryption is what closes that gap, and it is the
reason credentials must never travel over plain HTTP.
