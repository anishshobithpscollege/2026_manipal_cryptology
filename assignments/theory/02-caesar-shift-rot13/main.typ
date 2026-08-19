#import "/template/lib.typ": *
#import "/template/theme.typ": theme
#import "@preview/cetz:0.5.2"

#show: assignment.with(
  title: "Caesar, Shift and ROT13 Ciphers",
  number: "Assignment 02",
  kind: "Theory",
  course: "Cryptology",
  date: datetime(year: 2026, month: 8, day: 17)
)

#let posmod(a, m) = calc.rem(calc.rem(a, m) + m, m)

#let no-space(s) = s.clusters().filter(c => c != " ")

#let apply-shift(s, k) = {
  s.clusters().map(c => {
    let u = str.to-unicode(c)
    if u >= 65 and u <= 90 {
      str.from-unicode(65 + posmod(u - 65 + k, 26))
    } else if u >= 97 and u <= 122 {
      str.from-unicode(97 + posmod(u - 97 + k, 26))
    } else { c }
  }).join()
}

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

#let alpha-table = {
  let build(a, b) = {
    let lr = ([*Letter*],)
    let vr = ([*Value*],)
    for i in range(a, b + 1) {
      lr.push([#str.from-unicode(65 + i)])
      vr.push([#i])
    }
    (lr, vr)
  }
  let (l1, v1) = build(0, 12)
  let (l2, v2) = build(13, 25)
  set text(9pt)
  table(
    columns: 14,
    align: center + horizon,
    inset: 5pt,
    fill: none,
    ..l1, ..v1, ..l2, ..v2,
  )
}

#let enc-compare-table(s) = {
  let rows = ()
  for c in no-space(s) {
    let x = str.to-unicode(upper(c)) - 65
    rows.push((
      [#upper(c)],
      [#x],
      [#str.from-unicode(65 + posmod(x + 3, 26))],
      [#str.from-unicode(65 + posmod(x + 7, 26))],
      [#str.from-unicode(65 + posmod(x + 13, 26))],
    ))
  }
  set text(9.5pt)
  table(
    columns: (auto, auto, 1fr, 1fr, 1fr),
    align: center + horizon,
    table.header([Plain], [$x$], [Caesar \ $(+3)$], [Shift \ $(+7)$], [ROT13 \ $(+13)$]),
    ..rows.flatten(),
  )
}

#let decrypt-table(s, k) = {
  let rows = ()
  for c in no-space(s) {
    let y = str.to-unicode(upper(c)) - 65
    let diff = y - k
    let p = posmod(diff, 26)
    rows.push(([#upper(c)], [#y], [#diff], [#p], [#str.from-unicode(65 + p)]))
  }
  set text(9.5pt)
  table(
    columns: (auto, auto, auto, auto, auto),
    align: center + horizon,
    table.header([Cipher], [$y$], [$y - #k$], [$mod 26$], [Plain]),
    ..rows.flatten(),
  )
}

#let cipher-wheel(shift) = cetz.canvas(
  length: 1cm,
  {
    import cetz.draw: *
    let n = 26
    let ro = 3.35 // outer edge
    let rm = 2.75 // ring boundary
    let ri = 2.15 // inner edge
    let step = 360deg / n

    circle((0, 0), radius: ro, stroke: 0.7pt + theme.muted)
    circle((0, 0), radius: rm, stroke: 0.5pt + theme.rule)
    circle((0, 0), radius: ri, stroke: 0.7pt + theme.muted)

    for i in range(n) {
      let ang = 90deg - i * step
      // sector divider between the two rings
      let bang = 90deg - (i + 0.5) * step
      line(
        (ri * calc.cos(bang), ri * calc.sin(bang)),
        (ro * calc.cos(bang), ro * calc.sin(bang)),
        stroke: 0.3pt + theme.rule,
      )
      // outer plaintext letter
      let rp = (ro + rm) / 2
      content(
        (rp * calc.cos(ang), rp * calc.sin(ang)),
        text(9pt, fill: theme.ink)[#str.from-unicode(65 + i)],
      )
      // inner ciphertext letter (= plaintext index + shift)
      let rq = (rm + ri) / 2
      content(
        (rq * calc.cos(ang), rq * calc.sin(ang)),
        text(9pt, fill: theme.link, weight: "bold")[#str.from-unicode(65 + posmod(i + shift, 26))],
      )
    }
    content((0, 0.35), text(8.5pt, fill: theme.muted)[shift])
    content((0, -0.35), text(13pt, fill: theme.link, weight: "bold")[$#shift$])
  },
)

#let p1 = "CHASE YOUR DREAMS"
#let c2a = "WRWDOOB VHFUHW PHVVDJH"
#let c2b = "SJB DTWP YNRJ"
#let c2c = "FRAQ ZBER PBSSRR"

= The shift cipher

A shift cipher moves every letter a fixed number of places along the alphabet and
wraps from `Z` back to `A`. Write each letter as a number first, `A = 0` through
`Z = 25`.

#figure(
  caption: [Letter values, $A = 0$ to $Z = 25$],
  alpha-table,
)

For a key $k$, a plaintext letter $x$ and a ciphertext letter $y$ satisfy:

$ "Encrypt:" quad y = (x + k) mod 26 quad quad "Decrypt:" quad x = (y - k) mod 26 $

Three named cases appear in this assignment:

- *Caesar cipher.* A shift of $k = 3$, the cipher of Julius Caesar.
- *Shift cipher.* The general case, any key $k$.
- *ROT13.* A shift of $k = 13$. Since $13 + 13 = 26 equiv 0 space (mod 26)$, applying
  it twice returns the original text, so one operation both encrypts and decrypts.

= Encryption of "CHASE YOUR DREAMS"

The plaintext is `CHASE YOUR DREAMS`. Convert each letter to its number $x$, then
apply the three shifts $k = 3$, $k = 7$ and $k = 13$ with $y = (x + k) mod 26$.
The table below gives all three.

#figure(
  caption: [Encryption of `CHASE YOUR DREAMS` under the three shifts],
  enc-compare-table(p1),
)

== (a) Caesar cipher ($k = 3$)

#result-box("Ciphertext, Caesar k = 3", apply-shift(p1, 3))

#figure(
  caption: [Cipher disk for a shift of $3$ (Caesar). Outer ring is plaintext,
    inner ring (blue) is ciphertext. Reading inward encrypts: $A -> D$, $B -> E$,
    $X -> A$. Turning the inner ring by $k$ positions gives any shift cipher.],
  kind: image,
  supplement: [Figure],
  cipher-wheel(3),
)

== (b) Shift cipher, key $7$

#result-box("Ciphertext, shift k = 7", apply-shift(p1, 7))

#figure(
  caption: [Cipher disk for a shift of $7$. Outer ring is plaintext,
    inner ring (blue) is ciphertext. Reading inward encrypts: $A -> H$, $B -> I$,
    $X -> Q$. Turning the inner ring by $k$ positions gives any shift cipher.],
  kind: image,
  supplement: [Figure],
  cipher-wheel(7),
)

== (c) ROT13 ($k = 13$)

#result-box("Ciphertext, ROT13", apply-shift(p1, 13))

ROT13 is its own inverse. Applying it again to the ciphertext above returns
`CHASE YOUR DREAMS`. On the disk, the outer-to-inner and inner-to-outer shifts are
both $13$.

#figure(
  caption: [ROT13 cipher disk ($k = 13$). The mapping is symmetric, $A <-> N$,
    $B <-> O$, and so on, so one wheel setting both encrypts and decrypts.],
  kind: image,
  supplement: [Figure],
  cipher-wheel(13),
)

#pagebreak()

= Decryption

Decryption reverses the shift. Convert each ciphertext letter $y$ to its number,
subtract the key, and reduce modulo $26$ back into $0 dots 25$ to read the plaintext
letter, $x = (y - k) mod 26$.

== (a) Caesar cipher: decrypt `WRWDOOB VHFUHW PHVVDJH`

Caesar uses $k = 3$, so $x = (y - 3) mod 26$.

#figure(
  caption: [Caesar decryption of `WRWDOOB VHFUHW PHVVDJH`, $k = 3$],
  decrypt-table(c2a, 3),
)

#result-box("Plaintext, Caesar", apply-shift(c2a, -3))

== (b) Shift cipher, key $5$: decrypt `SJB DTWP YNRJ`

Here $k = 5$, so $x = (y - 5) mod 26$. When $y - 5$ is negative, add $26$ to bring
it back into range. For `B`: $1 - 5 = -4 equiv 22 = $ `W`.

#figure(
  caption: [Shift decryption of `SJB DTWP YNRJ`, $k = 5$],
  decrypt-table(c2b, 5),
)

#result-box("Plaintext, shift k = 5", apply-shift(c2b, -5))

The last word decrypts cleanly to `TIME`, which fixes the shift at $5$. Re-encrypting
`NEW YORK TIME` with $k = 5$ reproduces the given ciphertext. The first two words are
not ordinary English, so the source ciphertext holds a transcription slip. The result
above is the exact output of the arithmetic.

== (c) ROT13: decrypt `FRAQ ZBER PBSSRR`

ROT13 decrypts with the same $k = 13$.

#figure(
  caption: [ROT13 decryption of `FRAQ ZBER PBSSRR`, $k = 13$],
  decrypt-table(c2c, 13),
)

#result-box("Plaintext, ROT13", apply-shift(c2c, -13))
