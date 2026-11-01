#import "/template/lib.typ": *
#import "/template/theme.typ": theme
#import "@preview/codly:1.3.0" as codly

#show: assignment.with(
  title: "Columnar Transposition and OpenSSL",
  number: "Assignment 07",
  kind: "Lab",
  date: datetime(year: 2026, month: 11, day: 1),
)

#show heading.where(level: 1): set heading(numbering: none)
#show heading.where(level: 2): set heading(numbering: none)

#let prog(path) = codly.local()[#raw(read(path), lang: "python", block: true)]

#let out(body) = block(breakable: true, above: 0.7em, below: 1.1em)[
  #text(size: 7.5pt, fill: theme.muted, weight: "bold", tracking: 0.6pt)[OUTPUT]
  #v(2pt)
  #codly.local(number-format: none)[#body]
]

= Part 1: Columnar transposition

The plaintext is written under the keyword row by row, padded with `X`, and the columns are read out in the alphabetical order of the keyword letters. Repeated letters are ordered left to right. Decryption rebuilds the columns and reads the rows.

== Shared functions

#prog("programs/common.py")

== Question a: Columnar transposition

#prog("programs/columnar.py")

#out[```
Enter text: We are discovered, flee at once
Enter keyword: ZEBRAS
Encrypt or Decrypt? (e/d): e
Ciphertext: EVLNXACDTXESEAXROFOXDEECXWIREE
```]

#out[```
Enter text: EVLNXACDTXESEAXROFOXDEECXWIREE
Enter keyword: ZEBRAS
Encrypt or Decrypt? (e/d): d
Plaintext : WEAREDISCOVEREDFLEEATONCEXXXXX
```]

Non-letter input and a ciphertext that cannot fill the grid are both refused:

#out[```
Enter text: 123
Error: text must contain at least one letter.
Enter text: Z
Enter keyword: ZEBRAS
Encrypt or Decrypt? (e/d): e
Ciphertext: XXXXXZ
```]

== Question b: Double columnar transposition

The message goes through the first keyword and the result through the second. Decryption undoes the second keyword first.

#prog("programs/double_columnar.py")

#out[```
Enter text: attack postponed until two am
Enter first keyword : CIPHER
Enter second keyword: KEY
Encrypt or Decrypt? (e/d): e
After pass 1: APNIMCPNOXATUWXTOELXTSDTXKOTAX
Ciphertext  : PMNAWOXDKAAIPXUTLSXTNCOTXETTOX
```]

#out[```
Enter text: PMNAWOXDKAAIPXUTLSXTNCOTXETTOX
Enter first keyword : CIPHER
Enter second keyword: KEY
Encrypt or Decrypt? (e/d): d
After pass 1: APNIMCPNOXATUWXTOELXTSDTXKOTAX
Plaintext   : ATTACKPOSTPONEDUNTILTWOAMXXXXX
```]

= Part 2: The OpenSSL tool

OpenSSL is an open source toolkit that implements TLS and a general purpose cryptography library, and ships a command line program, `openssl`, that exposes most of it. Commands have the form `openssl <command> [options]`. The version used here is OpenSSL 3.6.3, installed with Homebrew.

== Inspecting the installation

#out[```
$ openssl version
OpenSSL 3.6.3 9 Jun 2026 (Library: OpenSSL 3.6.3 9 Jun 2026)

$ openssl version -d
OPENSSLDIR: "/opt/homebrew/etc/openssl@3"
```]

`openssl list -cipher-algorithms` and `openssl list -digest-algorithms` print the available ciphers and hashes, and `openssl help` lists every command.

== Hashing and HMAC

`dgst` computes a message digest. Adding `-hmac` keys the digest, which gives a message authentication code. `-n` on `echo` stops the newline from being hashed.

#out[```
$ echo -n "cryptology" | openssl dgst -sha256
SHA2-256(stdin)= 82de894aea35b3a2df33da50897cb0de6072c7e7ba64264f553f23245fc2b277

$ echo -n "cryptology" | openssl dgst -sha256 -hmac "secret"
SHA2-256(stdin)= 8ac12ac61d401b15cb25d4806dcbee6cd6efe570bc19558001f0f27ddc280017
```]

== Encoding and random bytes

`base64` is an encoding, not encryption. `rand` draws bytes from the OpenSSL random generator.

#out[```
$ echo -n "cryptology" | openssl base64
Y3J5cHRvbG9neQ==

$ openssl rand -hex 16 | wc -c
33
```]

== Symmetric encryption with `enc`

The file `message.txt` holds the line `Meet me at the library at noon`. `-pbkdf2` derives the key from the password with PBKDF2, which is the safe option, and `-salt` is on by default. `-a` base64 encodes the output so it can be pasted as text.

#out[```
$ openssl enc -aes-256-cbc -pbkdf2 -salt -in message.txt -out message.enc -pass pass:lab7secret

$ openssl enc -d -aes-256-cbc -pbkdf2 -in message.enc -pass pass:lab7secret
Meet me at the library at noon

$ openssl enc -aes-256-cbc -pbkdf2 -a -in message.txt -pass pass:lab7secret
U2FsdGVkX1/fMEsqK1S6mRFue6TL5OcOCLHMqCbfImCY9RhkDcA4P0V8nlbLlMWC
```]

The text `U2FsdGVkX1` is base64 for `Salted__`, the header OpenSSL writes before the random salt. The ciphertext differs on every run because the salt is fresh. A password on the command line is visible in the process list, so `-pass file:` or `-pass env:` is better outside a lab.

== RSA keys and encryption

#out[```
$ openssl genrsa -out private.pem 2048
$ openssl rsa -in private.pem -pubout -out public.pem
writing RSA key

$ openssl rsa -in private.pem -noout -text | head -3
Private-Key: (2048 bit, 2 primes)
modulus:
    00:b7:e7:d5:2c:12:b0:81:d8:45:28:59:14:d9:2d:

$ openssl pkeyutl -encrypt -pubin -inkey public.pem -in message.txt -out rsa.enc
$ openssl pkeyutl -decrypt -inkey private.pem -in rsa.enc
Meet me at the library at noon
```]

`pkeyutl` encrypts with the public key and decrypts with the private key. RSA can only encrypt data smaller than the modulus, so real systems encrypt a symmetric key this way.

== Digital signatures

#out[```
$ openssl dgst -sha256 -sign private.pem -out sig.bin message.txt
$ openssl dgst -sha256 -verify public.pem -signature sig.bin message.txt
Verified OK
```]

== Diffie-Hellman key agreement

Both sides share a parameter file, each makes a key pair, and `pkeyutl -derive` combines one private key with the other public key. Both ends reach the same secret.

#out[```
$ openssl genpkey -genparam -algorithm DH -pkeyopt dh_param:ffdhe2048 -out dhp.pem
$ openssl genpkey -paramfile dhp.pem -out a.pem
$ openssl genpkey -paramfile dhp.pem -out b.pem
$ openssl pkey -in a.pem -pubout -out a.pub
$ openssl pkey -in b.pem -pubout -out b.pub

$ openssl pkeyutl -derive -inkey a.pem -peerkey b.pub | xxd -p | head -c 32
409f5daf578b8abef4e35f38cd03a61f
$ openssl pkeyutl -derive -inkey b.pem -peerkey a.pub | xxd -p | head -c 32
409f5daf578b8abef4e35f38cd03a61f
```]

== Self signed certificate

#out[```
$ openssl req -x509 -newkey rsa:2048 -nodes -keyout k.pem -out cert.pem -days 30 -subj "/C=IN/O=Manipal/CN=lab.local"

$ openssl x509 -in cert.pem -noout -subject -dates -issuer
subject=C=IN, O=Manipal, CN=lab.local
notBefore=Nov  1 10:48:28 2026 GMT
notAfter=Dec  1 10:48:28 2026 GMT
issuer=C=IN, O=Manipal, CN=lab.local
```]

The subject and issuer are the same, which is what makes the certificate self signed. Browsers do not trust it unless it is added by hand.

== Command summary

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [`version`], [Show the OpenSSL version and build details.],
  [`list`], [List ciphers, digests and other algorithms.],
  [`enc`], [Symmetric encryption and decryption of files.],
  [`dgst`], [Hashes, HMACs, signing and verification.],
  [`rand`], [Random bytes in raw, hex or base64 form.],
  [`genrsa`, `rsa`], [Create and inspect RSA keys.],
  [`genpkey`, `pkey`], [Create and inspect keys and parameters of any type, including DH.],
  [`pkeyutl`], [Public key encrypt, decrypt, sign, verify and key derivation.],
  [`req`, `x509`], [Certificate requests, self signed certificates and certificate inspection.],
  [`s_client`], [Open a TLS connection to a server and show its handshake and certificate chain.],
  [`speed`], [Benchmark the algorithms on this machine.],
)
