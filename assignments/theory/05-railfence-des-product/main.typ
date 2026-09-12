#import "/template/lib.typ": *
#import "/template/theme.typ": theme

#show: assignment.with(
  title: "Rail Fence, DES Primitives and Product Ciphers",
  number: "Assignment 05",
  kind: "Theory",
  date: datetime(year: 2026, month: 9, day: 5),
)

#show heading.where(level: 2): set heading(numbering: none)

#let letters(s) = upper(s).clusters().filter(c => c.match(regex("[A-Z0-9]")) != none)


// Rail index of every position in the zigzag.
#let rf-pattern(n, d) = {
  let r = 0
  let step = 1
  let p = ()
  for _ in range(n) {
    p.push(r)
    if d > 1 {
      if r == 0 { step = 1 } else if r == d - 1 { step = -1 }
      r = r + step
    }
  }
  p
}

#let rf-rails-enc(s, d) = {
  let ls = letters(s)
  let p = rf-pattern(ls.len(), d)
  range(d).map(r => range(ls.len()).filter(i => p.at(i) == r).map(i => ls.at(i)))
}

#let rf-enc(s, d) = rf-rails-enc(s, d).map(r => r.join()).join()

// Cut the ciphertext back into rails using the zigzag's rail lengths.
#let rf-rails-dec(ct, d) = {
  let ls = letters(ct)
  let p = rf-pattern(ls.len(), d)
  let rails = ()
  let k = 0
  for r in range(d) {
    let c = p.filter(x => x == r).len()
    rails.push(ls.slice(k, k + c))
    k = k + c
  }
  rails
}

#let rf-dec(ct, d) = {
  let ls = letters(ct)
  let p = rf-pattern(ls.len(), d)
  let rails = rf-rails-dec(ct, d)
  let idx = range(d).map(_ => 0)
  let out = ()
  for r in p {
    out.push(rails.at(r).at(idx.at(r)))
    idx.at(r) = idx.at(r) + 1
  }
  out.join()
}

// The zigzag drawn out: one column per position, one row per rail.
#let rf-grid(seq, d) = {
  let p = rf-pattern(seq.len(), d)
  set text(8pt)
  show table.cell: set text(weight: "regular")
  table(
    columns: (1fr,) * seq.len(),
    align: center + horizon,
    inset: 3.5pt,
    stroke: 0.4pt + theme.rule,
    fill: none,
    ..range(d)
      .map(r => range(seq.len()).map(i => if p.at(i) == r { [#seq.at(i)] } else { [] }))
      .flatten()
  )
}

#let rail-list(rails) = rails.enumerate().map(((i, r)) => [
  Rail #(i + 1): #raw(r.join())
]).join(h(1.2em))


#let read-seq(order) = range(order.len()).sorted(key: c => order.at(c))

#let rows-of(s, n, pad: "X") = {
  let ls = letters(s)
  while calc.rem(ls.len(), n) != 0 { ls.push(pad) }
  range(calc.quo(ls.len(), n)).map(r => ls.slice(r * n, r * n + n))
}

#let col-enc(s, order, pad: "X") = {
  let rows = rows-of(s, order.len(), pad: pad)
  read-seq(order).map(c => rows.map(r => r.at(c)).join()).join()
}

#let grid-table(rows, order, label-row: none) = {
  let n = order.len()
  let head = if label-row == none { () } else { label-row.map(x => [#x]) }
  let nhead = if label-row == none { 1 } else { 2 }
  set text(9.5pt)
  table(
    columns: (1fr,) * n,
    align: center + horizon,
    fill: (_, row) => if row < nhead { theme.head-fill },
    table.header(..head, ..order.map(x => [#x])),
    ..rows.flatten().map(c => [#c]),
  )
}

#let groups(s, n: 5) = {
  let ls = letters(s)
  range(calc.ceil(ls.len() / n))
    .map(i => ls.slice(i * n, calc.min(i * n + n, ls.len())).join())
    .join(" ")
}


#let HEX = "0123456789ABCDEF"
#let hex-nibble(c) = HEX.clusters().position(x => x == upper(c))
#let hex-bits(h) = {
  upper(h)
    .clusters()
    .filter(c => c != " ")
    .map(c => {
      let v = hex-nibble(c)
      range(4).map(i => calc.rem(calc.quo(v, calc.pow(2, 3 - i)), 2))
    })
    .flatten()
}

#let nibble-val(bits, i) = (
  bits.at(i) * 8 + bits.at(i + 1) * 4 + bits.at(i + 2) * 2 + bits.at(i + 3)
)

#let bits-hex(bits) = {
  range(0, bits.len(), step: 4)
    .map(i => HEX.clusters().at(nibble-val(bits, i)))
    .join()
}

#let bits-nibbles(bits) = {
  range(0, bits.len(), step: 4)
    .map(i => bits.slice(i, i + 4).map(str).join())
    .join(" ")
}

#let set-bits(bits) = range(bits.len()).filter(i => bits.at(i) == 1).map(i => i + 1)

#let IP = (
  58, 50, 42, 34, 26, 18, 10, 2,
  60, 52, 44, 36, 28, 20, 12, 4,
  62, 54, 46, 38, 30, 22, 14, 6,
  64, 56, 48, 40, 32, 24, 16, 8,
  57, 49, 41, 33, 25, 17, 9, 1,
  59, 51, 43, 35, 27, 19, 11, 3,
  61, 53, 45, 37, 29, 21, 13, 5,
  63, 55, 47, 39, 31, 23, 15, 7,
)

#let ip-apply(bits) = IP.map(i => bits.at(i - 1))

#let ip-table(hi: ()) = {
  set text(9pt)
  show table.cell: set text(weight: "regular")
  table(
    columns: (1fr,) * 8,
    align: center + horizon,
    inset: 5pt,
    fill: (col, row) => if hi.contains(row * 8 + col + 1) { rgb("#ffe9a8") },
    ..IP.map(v => [#v])
  )
}

#let S1 = (
  (14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7),
  (0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8),
  (4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0),
  (15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13),
)

#let s1-table(hr: -1, hc: -1) = {
  set text(8.5pt)
  table(
    columns: (auto,) + (1fr,) * 16,
    align: center + horizon,
    inset: 4pt,
    fill: (col, row) => if row == 0 or col == 0 { theme.head-fill } else if (
      row - 1 == hr and col - 1 == hc
    ) { rgb("#ffe9a8") },
    table.header([], ..range(16).map(c => text(8pt)[#c])),
    ..range(4)
      .map(r => ([#r],) + S1.at(r).map(v => [#v]))
      .flatten()
  )
}

#let bin4(v) = range(4).map(i => str(calc.rem(calc.quo(v, calc.pow(2, 3 - i)), 2))).join()


#let ADFGVX = "ADFGVX"
#let SQUARE = "NA1C3H8TB2OME5WRPD4F6G7I9J0KLQSVXYZU"
#let adfgvx-pair(c) = {
  let i = SQUARE.clusters().position(x => x == upper(c))
  ADFGVX.clusters().at(calc.quo(i, 6)) + ADFGVX.clusters().at(calc.rem(i, 6))
}

#let square-table() = {
  set text(9.5pt)
  table(
    columns: (auto,) + (1fr,) * 6,
    align: center + horizon,
    inset: 5.5pt,
    fill: (col, row) => if row == 0 or col == 0 { theme.head-fill },
    table.header([], ..ADFGVX.clusters().map(c => [*#c*])),
    ..range(6)
      .map(r => ([*#ADFGVX.clusters().at(r)*],) + SQUARE.clusters().slice(r * 6, r * 6 + 6).map(c => [#c]))
      .flatten()
  )
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

#let note-box(lbl, val) = block(
  width: 100%,
  inset: (left: 11pt),
  stroke: (left: 2.5pt + rgb("#b23b3b")),
  above: 1em,
  below: 1em,
)[
  #text(size: 8.5pt, fill: rgb("#b23b3b"), weight: "bold", tracking: 0.4pt)[#upper(lbl)]
  #v(2pt)
  #text(size: 10.5pt, fill: theme.ink)[#val]
]

= Rail fence cipher

Write the message in a zigzag across $d$ rails, then read the rails in order. Only
positions change.

== Question 1: Encrypt "Enjoy your Journey"

#let m1 = "Enjoy your Journey"
16 letters: #raw(letters(m1).join()).

*Depth 2.*
#align(center, rf-grid(letters(m1), 2))
#rail-list(rf-rails-enc(m1, 2))
#result-box("Ciphertext, depth 2", groups(rf-enc(m1, 2)))

*Depth 3.*
#align(center, rf-grid(letters(m1), 3))
#rail-list(rf-rails-enc(m1, 3))
#result-box("Ciphertext, depth 3", groups(rf-enc(m1, 3)))

== Question 2: My own message

#let m2 = "Cryptology is fun"
`Cryptology is fun`, 15 letters: #raw(letters(m2).join()).

*Depth 2.*
#align(center, rf-grid(letters(m2), 2))
#result-box("Ciphertext, depth 2", groups(rf-enc(m2, 2)))

*Depth 3.*
#align(center, rf-grid(letters(m2), 3))
#result-box("Ciphertext, depth 3", groups(rf-enc(m2, 3)))

== Question 3: Decrypt "EOCSNYUWLEJYREASONS", depth 4

#let c3 = "EOCSNYUWLEJYREASONS"
Rail lengths #rf-rails-dec(c3, 4).map(r => str(r.len())).join(", "). Cut into those
blocks:
#rail-list(rf-rails-dec(c3, 4))
#align(center, rf-grid(letters(rf-dec(c3, 4)), 4))
#result-box("Plaintext", rf-dec(c3, 4))
`ENJOY YOUR NEW CLASSES`.

== Question 4: Decrypt "BOOIGUYUBOSNUUTYRKAS", depth 3

#let c4 = "BOOIGUYUBOSNUUTYRKAS"
Rail lengths #rf-rails-dec(c4, 3).map(r => str(r.len())).join(", ").
#rail-list(rf-rails-dec(c4, 3))
#align(center, rf-grid(letters(rf-dec(c4, 3)), 3))
#result-box("Plaintext", rf-dec(c4, 3))
`BUY YOUR BOOKS IN AUGUST`.

== Question 5: Decrypt "SEMSERTISINCMOO", depth 2

#let c5 = "SEMSERTISINCMOO"
Split #rf-rails-dec(c5, 2).at(0).len() / #rf-rails-dec(c5, 2).at(1).len(), interleave.
#rail-list(rf-rails-dec(c5, 2))
#align(center, rf-grid(letters(rf-dec(c5, 2)), 2))
#result-box("Plaintext", rf-dec(c5, 2))

= Permutation cipher

== Question 6: Encrypt "We are discovered", key 53124

#let m6 = "We are discovered"
#let o6 = (5, 3, 1, 2, 4)
Five columns, filled row by row. Each digit is that column's read position, so
columns come off 3, 4, 2, 5, 1. `WEAREDISCOVERED`, 15 letters, three full rows.
#align(center, grid-table(rows-of(m6, 5), o6))
#result-box("Ciphertext, key 53124", groups(col-enc(m6, o6)))

Taking the digits instead as $f = (5, 3, 1, 2, 4)$ (block $i$ = column
$f(i)$) gives
#raw(groups((5, 3, 1, 2, 4).map(k => rows-of(m6, 5).map(r => r.at(k - 1)).join()).join())).
The two readings are inverses, so state the convention with the key.

= DES primitives

== Question 7: Initial permutation of `0002 0000 0000 0001` (hex)

#let in7 = hex-bits("0002 0000 0000 0001")
#let out7 = ip-apply(in7)
Bits numbered from 1 on the left. Entry $j$ of IP names the input bit going to
output $j$.
#align(center, ip-table(hi: (25, 63)))

Input: #box(text(font: theme.fonts.mono, size: 9pt, bits-nibbles(in7))). Only bits
#set-bits(in7).map(str).join(" and ") are set.

- Bit 15 → row 8, entry 7 → position $7 times 8 + 7 = 63$.
- Bit 64 → row 4, entry 1 → position $3 times 8 + 1 = 25$.

Output: #box(text(font: theme.fonts.mono, size: 9pt, bits-nibbles(out7))).

#result-box(
  "IP output (hex)",
  range(0, 16, step: 4).map(i => bits-hex(out7).clusters().slice(i, i + 4).join()).join(" "),
)

== Question 8: XOR of M = 1101, K = 1011

XOR gives 1 where the bits differ.
#align(center, {
    set text(10pt)
    table(
      columns: (auto,) + (1fr,) * 4,
      align: center + horizon,
      fill: (col, _) => if col == 0 { theme.head-fill },
      [Position], [$b_1$], [$b_2$], [$b_3$], [$b_4$],
      [$M$], [1], [1], [0], [1],
      [$K$], [1], [0], [1], [1],
      [$C = M xor K$], [0], [1], [1], [0],
    )
  })
#result-box("Ciphertext C", "0110")

Self-inverse: $0110 xor 1011 = 1101$ back.

== Question 9: S-box 1 on input 000000

Outer bits pick the row, inner four the column. For $000000$: row $= b_1 b_6 = 0$,
column $= b_2 b_3 b_4 b_5 = 0$.
#align(center, s1-table(hr: 0, hc: 0))
#result-box("S-box 1 output", bin4(S1.at(0).at(0)))

Entry is #S1.at(0).at(0) → #bin4(S1.at(0).at(0)).

= Product cipher: ADFGVX

== Question 10: Explore the ADFGVX cipher

A substitution stage then a transposition stage. The 26 letters and 10 digits fill
a $6 times 6$ square with rows/columns labelled A, D, F, G, V, X.

*Stage 1, fractionation.* Replace each character by its row label then column
label, doubling the length.
#align(center, square-table())
#align(center, {
    set text(9.5pt)
    table(
      columns: (auto,) * 7,
      align: center + horizon,
      fill: (_, row) => if row == 0 { theme.head-fill },
      table.header([Char], ..letters("ATTACK").map(c => [#c])),
      [Pair], ..letters("ATTACK").map(c => raw(adfgvx-pair(c))),
    )
  })
#let frac = letters("ATTACK").map(c => adfgvx-pair(c)).join()
#result-box("After substitution", groups(frac, n: 2))

*Stage 2, columnar transposition.* Write the pairs under a keyword, read columns
alphabetically. The two symbols for one character split into different columns.
#let o10 = (1, 5, 4, 3, 2, 6)
#align(center, grid-table(rows-of(frac, 6), o10, label-row: letters("CIPHER")))
#result-box("ADFGVX ciphertext", groups(col-enc(frac, o10), n: 2))

Neither stage is secure alone. The square is a monoalphabetic substitution and the
transposition is a plain anagram. Together they block both attacks: frequency counts
on the ciphertext only see the six labels, and anagramming has to work on
half-characters. DES and AES use the same substitution-and-transposition
combination, repeated over many rounds.
