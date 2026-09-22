#import "/template/lib.typ": *
#import "/template/theme.typ": theme
#import "@preview/codly:1.3.0" as codly

#show: assignment.with(
  title: "Classical Ciphers in Python",
  number: "Assignment 05",
  kind: "Lab",
  date: datetime(year: 2026, month: 9, day: 22),
)

#show heading.where(level: 1): set heading(numbering: none)
#show heading.where(level: 2): set heading(numbering: none)

#let prog(path) = codly.local()[#raw(read(path), lang: "python", block: true)]

#let out(body) = block(breakable: true, above: 0.7em, below: 1.1em)[
  #text(size: 7.5pt, fill: theme.muted, weight: "bold", tracking: 0.6pt)[OUTPUT]
  #v(2pt)
  #codly.local(number-format: none)[#body]
]

Every program reads its input from the keyboard, rejects bad input with a message and asks again, and keeps the shared helpers in `common.py`.

== Shared helpers

#prog("programs/common.py")

== Shift cipher

#prog("programs/shift.py")

#out[```
Enter text: Attack at Dawn!
Enter shift key (0-25): 5
Encrypt or Decrypt? (e/d): e
Ciphertext: Fyyfhp fy Ifbs!
```]

#out[```
Enter text: Fyyfhp fy Ifbs!
Enter shift key (0-25): 5
Encrypt or Decrypt? (e/d): d
Plaintext : Attack at Dawn!
```]

An out-of-range key is rejected:

#out[```
Enter text: abc
Enter shift key (0-25): 30
Error: value must be between 0 and 25.
Enter shift key (0-25): 4
Encrypt or Decrypt? (e/d): e
Ciphertext: efg
```]

== Caesar cipher

The Caesar cipher is the shift cipher with the key fixed at 3.

#prog("programs/caesar.py")

#out[```
Enter text: Attack at Dawn!
Encrypt or Decrypt? (e/d): e
Ciphertext: Dwwdfn dw Gdzq!
```]

#out[```
Enter text: Dwwdfn dw Gdzq!
Encrypt or Decrypt? (e/d): d
Plaintext : Attack at Dawn!
```]

== ROT13

#prog("programs/rot13.py")

#out[```
Enter text: Hello, World!
ROT13 output: Uryyb, Jbeyq!
Applied again: Hello, World!
```]

== Atbash cipher

#prog("programs/atbash.py")

#out[```
Enter text: Attack at Dawn!
Encrypt or Decrypt? (e/d): e
Result: Zggzxp zg Wzdm!
```]

== Affine cipher

The key `a` must be coprime with 26, otherwise decryption has no modular inverse.

#prog("programs/affine.py")

#out[```
Enter text: Attack at Dawn!
Enter key a (must be coprime with 26): 4
Error: gcd(4, 26) is not 1. Valid values: 1,3,5,7,9,11,15,17,19,21,23,25
Enter key a (must be coprime with 26): 5
Enter key b (0-25): 5
Encrypt or Decrypt? (e/d): e
Ciphertext: Fwwfpd fw Ufls!
```]

#out[```
Enter text: Fwwfpd fw Ufls!
Enter key a (must be coprime with 26): 5
Enter key b (0-25): 5
Encrypt or Decrypt? (e/d): d
Plaintext : Attack at Dawn!
```]
