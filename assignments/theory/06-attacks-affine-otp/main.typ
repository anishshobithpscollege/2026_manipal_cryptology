#import "/template/lib.typ": *
#import "/template/theme.typ": theme

#show: assignment.with(
  title: "Cryptanalysis of Shift, Affine and One-Time Pad Ciphers",
  number: "Assignment 06",
  kind: "Theory",
  date: datetime(year: 2026, month: 9, day: 21),
)

#show heading.where(level: 1): set heading(numbering: none)

#let result-box(lbl, val) = block(
  width: 100%,
  inset: (left: 11pt),
  stroke: (left: 2.5pt + theme.link),
  above: 1em,
  below: 1em,
)[
  #text(size: 8.5pt, fill: theme.muted, weight: "bold", tracking: 0.4pt)[#upper(lbl)]
  #v(2pt)
  #text(font: theme.fonts.mono, size: 13pt, weight: "bold", fill: theme.ink)[#val]
]

#let sh(s, k) = s.clusters().map(c => str.from-unicode(65 + calc.rem(calc.rem(str.to-unicode(c) - 65 - k, 26) + 26, 26))).join()

All letters use $A = 0, B = 1, dots, Z = 25$ and every result is reduced modulo 26.

= Question 1: Caesar's meeting

*Cryptanalysis model: ciphertext-only attack.* Antony holds only the ciphertext `EVIRE`, so he runs an exhaustive key search. The shift cipher has just 26 keys, and for each key $k$ he computes $P = (C - k) mod 26$ for every letter. `EVIRE` is $4, 21, 8, 17, 4$.

#figure(
  caption: [All 26 decryptions of `EVIRE`],
  table(
    columns: 8,
    align: center,
    inset: 4pt,
    stroke: 0.4pt + theme.rule,
    ..range(26).map(k => [#k: #raw(sh("EVIRE", k))]),
  ),
)

*a.* Only two keys give English words.

For $k = 4$:
$ 4 - 4 = 0 → A, quad 21 - 4 = 17 → R, quad 8 - 4 = 4 → E, quad 17 - 4 = 13 → N, quad 4 - 4 = 0 → A. $

For $k = 13$:
$ 4 - 13 = -9 equiv 17 → R, quad 21 - 13 = 8 → I, quad 8 - 13 = -5 equiv 21 → V, \ 17 - 13 = 4 → E, quad 4 - 13 = -9 equiv 17 → R. $

#result-box("Meaningful plaintexts", "ARENA (k = 4)   RIVER (k = 13)")

*b.* The ciphertext alone cannot settle the meeting place. `RIVER` points to the Tiber River and `ARENA` points to the Colosseum, which is a Roman amphitheatre built around an arena, so both fit the two options Caesar gave. Antony needs outside information, such as which place Caesar usually uses, or a second message with the same key.

*c.* A ciphertext-only attack can return more than one meaningful plaintext when the ciphertext is short. These wrong but plausible keys are called spurious keys. A longer ciphertext makes the correct key the only one that gives sensible text, so the attack works well on long messages and badly on very short ones like this.

= Question 2: Affine cipher, chosen-plaintext attack

*Cryptanalysis model: chosen-plaintext attack.* The attacker picks the plaintext `HAHAHA` and reads the ciphertext `NONONO` that comes back.

*a.* $H = 7, A = 0$ and $N = 13, O = 14$, so the pairs are $(7, 13)$ and $(0, 14)$. The repeating pattern gives only these two distinct pairs.

*b.* With $y = a x + b mod 26$:
$ 7a + b equiv 13 quad (1) $
$ 0 a + b equiv 14 quad (2) $

*c.* From (2), $b = 14$. Substituting into (1):
$ 7a equiv 13 - 14 = -1 equiv 25 (mod 26). $
The inverse of 7 is 15, since $7 times 15 = 105 = 4 times 26 + 1$. Then
$ a equiv 15 times 25 = 375 = 14 times 26 + 11 equiv 11 (mod 26). $
Check: $gcd(11, 26) = 1$, so $a$ is a valid key, and $11 times 7 + 14 = 91 = 3 times 26 + 13 equiv 13$ gives $N$.

*d.*
#result-box("Encryption function", "E(x) = (11x + 14) mod 26")

= Question 3: Affine cipher, known-plaintext attack

*Cryptanalysis model: known-plaintext attack.* The attacker did not choose the text but knows that the plaintext starts with `HA`, so the pairs $H → C$ and $A → R$ are known.

*a.* $H = 7 → C = 2$ and $A = 0 → R = 17$:
$ 7a + b equiv 2 quad (1), quad quad b equiv 17 quad (2). $
So $b = 17$ and
$ 7a equiv 2 - 17 = -15 equiv 11 (mod 26). $
With $7^(-1) = 15$:
$ a equiv 15 times 11 = 165 = 6 times 26 + 9 equiv 9 (mod 26). $
Check: $gcd(9, 26) = 1$, and $9 times 7 + 17 = 80 = 3 times 26 + 2 equiv 2$ gives $C$.

*b.*
#result-box("Encryption function", "E(x) = (9x + 17) mod 26")

*c.* The inverse of 9 satisfies $9 a^(-1) equiv 1 (mod 26)$. Since $9 times 3 = 27 equiv 1$, we get $9^(-1) = 3$. Decryption is
$ D(y) = 3 (y - 17) mod 26 = (3y - 51) mod 26 = (3y + 1) mod 26. $

*d.* Applying $D$ to `CRWWZ` $= 2, 17, 22, 22, 25$:

#figure(
  caption: [Decryption of `CRWWZ` with $D(y) = 3(y - 17) mod 26$],
  table(
    columns: 5,
    align: center,
    inset: 5pt,
    stroke: 0.4pt + theme.rule,
    [*Cipher*], [*y*], [*3(y − 17)*], [*mod 26*], [*Plain*],
    [C], [2], [3(−15) = −45], [7], [H],
    [R], [17], [3(0) = 0], [0], [A],
    [W], [22], [3(5) = 15], [15], [P],
    [W], [22], [3(5) = 15], [15], [P],
    [Z], [25], [3(8) = 24], [24], [Y],
  ),
)

For the first row, $-45 + 2 times 26 = 7$.

#result-box("Plaintext", "HAPPY")

= Question 4: One-Time Pad

*Cryptanalysis model: none succeeds.* The pad gives perfect secrecy, so a ciphertext-only attack learns nothing. The key `NQXTP` is used here once, for one message, as the cipher requires.

*a.*
#figure(
  caption: [Numerical values],
  table(
    columns: 6,
    align: center,
    inset: 5pt,
    stroke: 0.4pt + theme.rule,
    [], [1], [2], [3], [4], [5],
    [*Plaintext*], [R = 17], [I = 8], [V = 21], [E = 4], [R = 17],
    [*Key*], [N = 13], [Q = 16], [X = 23], [T = 19], [P = 15],
  ),
)

*b.* Encryption, $C_i = (P_i + K_i) mod 26$:
$ 17 + 13 = 30 equiv 4 → E $
$ 8 + 16 = 24 → Y $
$ 21 + 23 = 44 equiv 18 → S $
$ 4 + 19 = 23 → X $
$ 17 + 15 = 32 equiv 6 → G $

#result-box("Ciphertext", "EYSXG")

*c.* Decryption, $P_i = (C_i - K_i) mod 26$, with `EYSXG` $= 4, 24, 18, 23, 6$:
$ 4 - 13 = -9 equiv 17 → R $
$ 24 - 16 = 8 → I $
$ 18 - 23 = -5 equiv 21 → V $
$ 23 - 19 = 4 → E $
$ 6 - 15 = -9 equiv 17 → R $

#result-box("Recovered plaintext", "RIVER")

*d.* Each condition protects against a different attack.

- *Random.* If the key follows a pattern, such as English words or a short phrase, the attacker can guess it. A truly random key makes every plaintext of the same length equally likely for a given ciphertext. For example, `EYSXG` would turn into `RIVER` under one key and into `ARENA` under another, with no way to tell which is right. This is Shannon's perfect secrecy.
- *As long as the plaintext.* A shorter key must repeat. A repeating key makes the cipher periodic, like Vigenere, and it can be broken with frequency analysis and the Kasiski test.
- *Used only once.* If two messages share a key, then $C_1 - C_2 equiv P_1 - P_2 (mod 26)$. The key cancels and the attacker is left with the difference of two plain texts, which can be solved by guessing common words. A known-plaintext pair also gives the key directly as $K = C - P$, which would decrypt every other message under that key.
