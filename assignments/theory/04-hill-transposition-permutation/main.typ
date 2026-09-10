#import "/template/lib.typ": *
#import "/template/theme.typ": theme

#show: assignment.with(
  title: "Hill Decryption, Transposition and Permutations",
  number: "Assignment 04",
  kind: "Theory",
  date: datetime(year: 2026, month: 8, day: 29),
)

// Questions carry their own "Question N" label, so drop the auto number on the
// level-2 headings and keep it only on the thematic level-1 sections.
#show heading.where(level: 2): set heading(numbering: none)

#let posmod(a, m) = calc.rem(calc.rem(a, m) + m, m)

#let mygcd(a, b) = {
  a = calc.abs(a)
  b = calc.abs(b)
  while b != 0 {
    let t = calc.rem(a, b)
    a = b
    b = t
  }
  a
}

#let modinv(a, m) = {
  let r = none
  for x in range(1, m) {
    if posmod(a * x, m) == 1 {
      r = x
      break
    }
  }
  r
}

// Letter <-> number with A = 0 .. Z = 25.
#let L2N(c) = str.to-unicode(upper(c)) - 65
#let N2L(n) = str.from-unicode(65 + posmod(n, 26))
#let letters(s) = upper(s).clusters().filter(c => c != " ")


#let mget(M, i, j) = M.at(i).at(j)
#let mat-det(M) = mget(M, 0, 0) * mget(M, 1, 1) - mget(M, 0, 1) * mget(M, 1, 0)
#let mat-inv(M) = {
  let di = modinv(posmod(mat-det(M), 26), 26)
  if di == none { return none }
  (
    (posmod(di * mget(M, 1, 1), 26), posmod(di * (-mget(M, 0, 1)), 26)),
    (posmod(di * (-mget(M, 1, 0)), 26), posmod(di * mget(M, 0, 0), 26)),
  )
}
#let mat-mul(A, B) = range(2).map(i => range(2).map(j =>
  posmod(mget(A, i, 0) * mget(B, 0, j) + mget(A, i, 1) * mget(B, 1, j), 26)
))
#let mat26(M) = math.mat(delim: "[", ..M)

#let hill-dec(s, K) = {
  let Ki = mat-inv(K)
  let ls = letters(s)
  let out = ()
  let i = 0
  while i < ls.len() {
    let c1 = L2N(ls.at(i))
    let c2 = L2N(ls.at(i + 1))
    out.push(N2L(mget(Ki, 0, 0) * c1 + mget(Ki, 0, 1) * c2))
    out.push(N2L(mget(Ki, 1, 0) * c1 + mget(Ki, 1, 1) * c2))
    i = i + 2
  }
  out.join()
}

#let hill-dec-table(s, K) = {
  let Ki = mat-inv(K)
  let ls = letters(s)
  let rows = ()
  let i = 0
  while i < ls.len() {
    let c1 = L2N(ls.at(i))
    let c2 = L2N(ls.at(i + 1))
    let t1 = mget(Ki, 0, 0) * c1 + mget(Ki, 0, 1) * c2
    let t2 = mget(Ki, 1, 0) * c1 + mget(Ki, 1, 1) * c2
    rows.push((
      [#ls.at(i)#ls.at(i + 1)],
      [$vec(#[#c1], #[#c2])$],
      [$#mget(Ki, 0, 0) times #c1 + #mget(Ki, 0, 1) times #c2 = #t1 equiv #posmod(t1, 26)$],
      [$#mget(Ki, 1, 0) times #c1 + #mget(Ki, 1, 1) times #c2 = #t2 equiv #posmod(t2, 26)$],
      [#N2L(t1)#N2L(t2)],
    ))
    i = i + 2
  }
  set text(8.5pt)
  table(
    columns: (auto, auto, 1fr, 1fr, auto),
    align: (center, center, left, left, center).map(a => a + horizon),
    table.header([Pair], [$C$], [$p_1 = "row"_1 K^(-1) C mod 26$], [$p_2 = "row"_2 K^(-1) C mod 26$], [Plain]),
    ..rows.flatten(),
  )
}

// Read position of each column: 1 for the alphabetically first keyword letter,
// with repeated letters broken left to right.
#let key-order(kw) = {
  let ls = letters(kw)
  let idx = range(ls.len()).sorted(key: i => ls.at(i) + str(i))
  let order = ls.map(_ => 0)
  for (rank, i) in idx.enumerate() { order.at(i) = rank + 1 }
  order
}

// Columns in the order they are read off.
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

#let col-dec-rows(ct, order) = {
  let ls = letters(ct)
  let n = order.len()
  let nrows = calc.quo(ls.len(), n)
  let cols = range(n).map(_ => ())
  let k = 0
  for c in read-seq(order) {
    cols.at(c) = ls.slice(k, k + nrows)
    k = k + nrows
  }
  range(nrows).map(r => range(n).map(c => cols.at(c).at(r)))
}

#let col-dec(ct, order) = col-dec-rows(ct, order).map(r => r.join()).join()

// Grid with one or two header rows above the letters.
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

#let cipher-groups(s, n: 5) = {
  let ls = letters(s)
  range(calc.ceil(ls.len() / n))
    .map(i => ls.slice(i * n, calc.min(i * n + n, ls.len())).join())
    .join(" ")
}


#let perm-inv(p) = range(1, p.len() + 1).map(v => p.position(x => x == v) + 1)
#let perm-row(p) = p.map(x => [#x])

#let perm-table(p) = {
  let q = perm-inv(p)
  set text(9.5pt)
  table(
    columns: (auto,) + (1fr,) * p.len(),
    align: center + horizon,
    fill: (_, row) => if row == 0 { theme.head-fill },
    table.header([$i$], ..range(1, p.len() + 1).map(i => [#i])),
    [$f(i)$], ..perm-row(p),
    [$f^(-1)(i)$], ..perm-row(q),
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

= Hill cipher decryption

$P = K^(-1) C mod 26$, so invert the key first. For $K = mat(delim: "[", a, b; c, d)$,
$ K^(-1) = (det K)^(-1) mat(delim: "[", d, -b; -c, a) space (mod 26). $

== Question 1: Decrypt "HLDTQIHJDXWQCMAG"

#let k1 = ((3, 2), (5, 7))
#let d1 = posmod(mat-det(k1), 26)
$K = #mat26(k1)$. $det K = 21 - 10 = #mat-det(k1)$, $#d1^(-1) equiv #modinv(d1, 26)$
(since $11 times 19 = 209 = 8 dot 26 + 1$), so
$K^(-1) = #modinv(d1, 26) mat(delim: "[", 7, -2; -5, 3) equiv #mat26(mat-inv(k1))$.

#align(center, hill-dec-table("HLDTQIHJDXWQCMAG", k1))

#result-box("Plaintext", hill-dec("HLDTQIHJDXWQCMAG", k1))

Reads `TOP SECRET MESSAGE`.

== Question 2: Decrypt "RXAODY"

#let k2 = ((24, 19), (5, 14))
#let d2 = posmod(mat-det(k2), 26)
$K = #mat26(k2)$. $det K = 336 - 95 = 241 equiv #d2$, $#d2^(-1) equiv #modinv(d2, 26)$
($7 times 15 = 105 = 4 dot 26 + 1$), so
$K^(-1) = #modinv(d2, 26) mat(delim: "[", 14, -19; -5, 24) equiv #mat26(mat-inv(k2))$.

#align(center, hill-dec-table("RXAODY", k2))

#result-box("Plaintext", hill-dec("RXAODY", k2))

= Confusion vs. diffusion

#align(center, {
    set text(9.5pt)
    table(
      columns: (auto, auto, auto, auto, 1.6fr),
      align: (left, center, center, center, left).map(a => a + horizon),
      table.header([Cipher], [Value?], [Position?], [Property], [Justification]),
      [Shift], [Yes], [No], [Confusion], [$y = x + k$: swaps letters, keeps order.],
      [Multiplicative], [Yes], [No], [Confusion], [$y = a x$: swaps letters, keeps order.],
      [Affine], [Yes], [No], [Confusion], [$y = a x + b$: swaps letters, keeps order.],
      [Transposition], [No], [Yes], [Diffusion], [Letters only move; counts unchanged.],
    )
  })

Substitution changes each letter but keeps its position, which gives confusion.
Transposition keeps each letter but moves its position, which gives diffusion. Each
is weak alone: substitution falls to frequency analysis and transposition to
anagramming. Product ciphers such as DES and AES use both.

= Transposition: encryption

`The arrow is pointing north direction`, no spaces, 32 letters:
#align(center, raw(letters("The arrow is pointing north direction").join()))
Write into the grid row by row, read columns top to bottom in the numbered order.

== Question 3: Simple, key = 4

#let s4 = "The arrow is pointing north direction"
#let o4 = (1, 2, 3, 4)
#align(center, grid-table(rows-of(s4, 4), o4))
#result-box("Ciphertext", cipher-groups(col-enc(s4, o4)))

== Question 4: Keyword = ATLAS

#let oA = key-order("ATLAS")
Order (two `A`s left to right): 1, 5, 3, 2, 4. Pad with 3 `X`s.
#align(center, grid-table(rows-of(s4, 5), oA, label-row: letters("ATLAS")))
#result-box("Ciphertext", cipher-groups(col-enc(s4, oA)))

== Question 5: Double, BREAK then LOG

#let oB = key-order("BREAK")
#let oL = key-order("LOG")
#let pass1 = col-enc(s4, oB)
Pass 1 output feeds pass 2.
#align(center, grid-table(rows-of(s4, 5), oB, label-row: letters("BREAK")))
#result-box("After BREAK", cipher-groups(pass1))
#align(center, grid-table(rows-of(pass1, 3), oL, label-row: letters("LOG")))
#result-box("Ciphertext", cipher-groups(col-enc(pass1, oL)))

= Transposition: decryption

Rows $=$ length $div$ columns. Cut the ciphertext into that many blocks, one per
column in read order, read back across rows.

== Question 6: Simple, key = 10

#let c6 = "TIDIE MRNME REOGO SANOW RSLTP EEEDO SSSNU AHTUD BIENP GODAE PEIXD ELNSX"
#let o6 = range(1, 11)
60 letters, 10 columns → 6 rows. `TIDIEM` is column 1, and so on.
#align(center, grid-table(col-dec-rows(c6, o6), o6))
#result-box("Plaintext", col-dec(c6, o6))
`TROOPS HEADING WEST NEED MORE SUPPLIES SEND GENERAL DUBOIS MEN TO AID`.

== Question 7: Keyword = SECRET

#let c7 = "ILEDT NHPTR SOIIT MAXSA XERXT ANONI SNFOT X"
#let o7 = key-order("SECRET")
Order #o7.map(str).join(", "), 6 letters per column.
#align(center, grid-table(col-dec-rows(c7, o7), o7, label-row: letters("SECRET")))
#result-box("Plaintext", col-dec(c7, o7))
`THIS IS A PLAIN TEXT FOR DEMONSTRATION`.

== Question 8: Keyword = PLAIN

#let c8 = "VEY EAX ARA ATX HGD"
#let o8 = key-order("PLAIN")
Order #o8.map(str).join(", "), 3 letters per column.
#align(center, grid-table(col-dec-rows(c8, o8), o8, label-row: letters("PLAIN")))
#result-box("Plaintext", col-dec(c8, o8))
`HAVE A GREAT DAY`.

= Permutations

$f^(-1)(v)$ is the position holding $v$ in $f$.

#let perms = ((4, 3, 1, 5, 2), (7, 4, 1, 3, 5, 2, 6), (4, 1, 3, 2), (3, 5, 1, 4, 2))

#for (i, p) in perms.enumerate() [
  == Question #(9 + i): Inverse of #p.map(str).join(" ")
  #perm-table(p)
  #result-box("Inverse", perm-inv(p).map(str).join("  "))
]

Q12 is its own inverse.
