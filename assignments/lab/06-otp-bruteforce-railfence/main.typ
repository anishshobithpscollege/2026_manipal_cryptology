#import "/template/lib.typ": *
#import "/template/theme.typ": theme
#import "@preview/codly:1.3.0" as codly

#show: assignment.with(
  title: "One Time Pad, Brute Force and Rail Fence",
  number: "Assignment 06",
  kind: "Lab",
  date: datetime(year: 2026, month: 9, day: 27),
)

#show heading.where(level: 1): set heading(numbering: none)
#show heading.where(level: 2): set heading(numbering: none)

#let prog(path) = codly.local()[#raw(read(path), lang: "python", block: true)]

#let out(body) = block(breakable: true, above: 0.7em, below: 1.1em)[
  #text(size: 7.5pt, fill: theme.muted, weight: "bold", tracking: 0.6pt)[OUTPUT]
  #v(2pt)
  #codly.local(number-format: none)[#body]
]

== Question 1: One Time Pad

The pad must be as long as the message. If no key is typed, a random one is drawn with the `secrets` module.

#prog("programs/otp.py")

#out[```
Enter message (letters only): HELLO
Enter key, or press Enter to generate one: XMCKL
Plaintext : HELLO
Ciphertext: EQNVZ
Decrypted : HELLO
```]

#out[```
Enter message (letters only): HELLO
Enter key, or press Enter to generate one:
Generated key: EGJIM
Plaintext : HELLO
Ciphertext: LKUTA
Decrypted : HELLO
```]

A key of the wrong length is refused:

#out[```
Enter message (letters only): HELLO
Enter key, or press Enter to generate one: AB
Error: key length (2) must equal message length (5).
```]

== Question 2: Brute force on the shift cipher

#prog("programs/bruteforce.py")

#out[```
Key  0: MCI RWR WH
Key  1: LBH QVQ VG
Key  2: KAG PUP UF
Key  3: JZF OTO TE
Key  4: IYE NSN SD
Key  5: HXD MRM RC
Key  6: GWC LQL QB
Key  7: FVB KPK PA
Key  8: EUA JOJ OZ
Key  9: DTZ INI NY
Key 10: CSY HMH MX
Key 11: BRX GLG LW
Key 12: AQW FKF KV
Key 13: ZPV EJE JU
Key 14: YOU DID IT
Key 15: XNT CHC HS
Key 16: WMS BGB GR
Key 17: VLR AFA FQ
Key 18: UKQ ZEZ EP
Key 19: TJP YDY DO
Key 20: SIO XCX CN
Key 21: RHN WBW BM
Key 22: QGM VAV AL
Key 23: PFL UZU ZK
Key 24: OEK TYT YJ
Key 25: NDJ SXS XI
```]

Only key 14 gives readable English, so the plaintext is *YOU DID IT*.

== Question 3: Rail Fence encryption

#prog("programs/railfence.py")

#out[```
Enter plaintext: WE ARE DISCOVERED
Enter number of rails: 1
Error: rails must be between 2 and 15.
Enter number of rails: 3
Ciphertext: WECRERDSOEEAIVD
```]
