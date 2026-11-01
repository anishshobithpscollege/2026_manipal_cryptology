#import "/template/lib.typ": *
#import "/template/theme.typ": theme
#import "@preview/codly:1.3.0" as codly

#show: assignment.with(
  title: "RSA and Diffie-Hellman Key Exchange",
  number: "Assignment 08",
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

== Shared helpers

Primality is tested with Miller-Rabin using 40 random bases, and prime candidates are drawn with the `secrets` module.

#prog("programs/common.py")

== Question 1: RSA

Two primes give `n = p * q` and `phi = (p - 1)(q - 1)`. The public exponent `e` must be coprime with `phi`, and the private exponent is `d = e^(-1) mod phi`. Each character is turned into its code point and encrypted on its own, so `n` has to be larger than the biggest code point in the message.

#prog("programs/rsa.py")

Input checks refuse a composite prime, equal primes and a bad exponent:

#out[```
Generate primes automatically? (y/n): n
Enter prime p: 60
Error: 60 is not prime.
Enter prime p: 61
Enter prime q: 61
Error: p and q must be different.
Enter prime p: 53
Enter prime q: 7
Enter public exponent e (1 < e < 312, coprime with phi): 17
p = 53, q = 7, n = 371, phi = 312
Public key (e, n): (17, 371)
Private key (d, n): (257, 371)
Enter message: Hello, RSA!
Ciphertext: [32, 306, 215, 215, 118, 95, 296, 269, 83, 193, 157]
Decrypted : Hello, RSA!
```]

The textbook values p = 61, q = 53, e = 17 give d = 2753:

#out[```
Generate primes automatically? (y/n): n
Enter prime p: 61
Enter prime q: 53
Enter public exponent e (1 < e < 3120, coprime with phi): 17
p = 61, q = 53, n = 3233, phi = 3120
Public key (e, n): (17, 3233)
Private key (d, n): (2753, 3233)
Enter message: Hello, RSA!
Ciphertext: [3000, 1313, 745, 745, 2185, 678, 1992, 1859, 2680, 2790, 1853]
Decrypted : Hello, RSA!
```]

This is textbook RSA with no padding, which is fine for a lab but not for real use.

== Question 2: Diffie-Hellman key exchange

Alice sends `A = g^a mod p`, Bob sends `B = g^b mod p`, and each raises what they received to their own private key. Both get `g^(ab) mod p`. The program offers the standard 2048-bit group from RFC 3526 or a small prime for working by hand.

#prog("programs/dh.py")

With p = 23, g = 5, a = 6 and b = 15:

#out[```
Use the standard 2048-bit group? (y/n): n
Enter prime p: 23
Enter generator g (2 to 21): 5
Generate Alice's private key randomly? (y/n): n
Enter Alice's private key (2 to 21): 6
Generate Bob's private key randomly? (y/n): n
Enter Bob's private key (2 to 21): 15
Alice public A = 8
Bob public B   = 19
Alice secret   = 2
Bob secret     = 2
Secrets match  : True
```]
