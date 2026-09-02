#import "/template/lib.typ": *
#import "/template/theme.typ": theme

#show: assignment.with(
  title: "Affine and Hill Ciphers",
  number: "Assignment 03",
  kind: "Theory",
  date: datetime(year: 2026, month: 9, day: 1),
)

// Questions carry their own "Question N" label, so drop the auto number on the
// level-2 headings and keep it only on the thematic level-1 sections.
#show heading.where(level: 2): set heading(numbering: none)

// Remainder that stays in 0 .. m-1 even for negative inputs.
#let posmod(a, m) = calc.rem(calc.rem(a, m) + m, m)

// Euclid's algorithm for the greatest common divisor.
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

// Multiplicative inverse of a modulo m by search; none when gcd(a, m) != 1.
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

#let ee-steps(a) = {
  let r0 = 26
  let t0 = 0
  let r1 = a
  let t1 = 1
  let rows = ((none, r0, t0), (none, r1, t1))
  while r1 > 1 {
    let q = calc.quo(r0, r1)
    let r2 = r0 - q * r1
    let t2 = t0 - q * t1
    rows.push((q, r2, t2))
    r0 = r1
    t0 = t1
    r1 = r2
    t1 = t2
  }
  (rows, posmod(t1, 26))
}

#let bezout-block(b) = {
  if b == 1 {
    return block(breakable: false, above: 0.8em, below: 0.8em)[
      #text(weight: "bold", fill: theme.link)[Inverse of 1.] #h(0.3em)
      Trivially $1 times 1 = 1 equiv 1 space (mod 26)$, so $1^(-1) equiv 1$.
    ]
  }

  let (rows, inv) = ee-steps(b)
  let R = rows.map(x => x.at(1))
  let Q = rows.map(x => x.at(0))
  let k = R.len() - 1 // index of the remainder equal to 1

  // --- string helpers (all terms are concrete integers) ---
  let term-str = (c, v) => {
    let a = calc.abs(c)
    if a == 1 { str(v) } else { str(a) + " times " + str(v) }
  }
  // Two nonzero terms, positive coefficient written first for readability.
  let sum2 = (c1, v1, c2, v2) => {
    let (a1, u1, a2, u2) = if c1 < 0 and c2 > 0 { (c2, v2, c1, v1) } else { (c1, v1, c2, v2) }
    term-str(a1, u1) + (if a2 < 0 { " - " } else { " + " }) + term-str(a2, u2)
  }
  // c_low * R_low  combined with  c_high * (R_j2 - Q_h * R_j1), positive first.
  let nested = (cl, Rl, ch, Rj2, Qh, Rj1) => {
    let paren = "(" + str(Rj2) + " - " + (if Qh == 1 { str(Rj1) } else { str(Qh) + " times " + str(Rj1) }) + ")"
    let expanded = if calc.abs(ch) == 1 { paren } else { str(calc.abs(ch)) + " " + paren }
    let plain = term-str(cl, Rl)
    if cl > 0 {
      plain + (if ch < 0 { " - " } else { " + " }) + expanded
    } else {
      expanded + (if cl < 0 { " - " } else { " + " }) + plain
    }
  }

  let div-lines = ()
  for i in range(2, k + 1) {
    div-lines.push(str(R.at(i - 2)) + " &= " + str(Q.at(i)) + " times " + str(R.at(i - 1)) + " + " + str(R.at(i)))
  }
  div-lines.push(str(R.at(k - 1)) + " &= " + str(R.at(k - 1)) + " times 1 + 0 quad (\"gcd\" = 1)")
  let step1 = div-lines.join(" \\ ")

  let low = k - 2
  let high = k - 1
  let cl = 1
  let ch = -Q.at(k)
  let bs-lines = ("1 &= " + sum2(cl, R.at(low), ch, R.at(high)),)
  while high >= 2 {
    let Qh = Q.at(high)
    let nl = high - 2
    let nh = high - 1
    let c-nh = cl - ch * Qh
    let c-nl = ch
    bs-lines.push(
      "&= " + nested(cl, R.at(low), ch, R.at(high - 2), Qh, R.at(high - 1))
        + " = " + sum2(c-nl, R.at(nl), c-nh, R.at(nh)),
    )
    low = nl
    high = nh
    cl = c-nl
    ch = c-nh
  }
  let step2 = bs-lines.join(" \\ ")
  let cb = ch // coefficient sitting on b

  let concl = if cb == inv {
    $#cb times #b equiv 1 space (mod 26) quad ==> quad #b^(-1) equiv #inv$
  } else {
    $#cb times #b equiv 1 space (mod 26) quad ==> quad #b^(-1) equiv #cb equiv #inv$
  }

  block(breakable: false, above: 0.9em, below: 0.9em)[
    #text(weight: "bold", fill: theme.link)[Inverse of #b.]
    #set text(9.5pt)
    #v(1pt)
    #emph[Euclid - divide down to remainder 1:]
    #math.equation(block: true, eval(step1, mode: "math"))
    #emph[Back-substitution - write 1 using only #b and 26:]
    #math.equation(block: true, eval(step2, mode: "math"))
    #emph[Reduce modulo 26:] #h(0.4em) #concl
  ]
}

// Letter <-> number with A = 0 .. Z = 25.
#let L2N(c) = str.to-unicode(upper(c)) - 65
#let N2L(n) = str.from-unicode(65 + posmod(n, 26))
#let letters(s) = s.clusters().filter(c => c != " ")

// Affine cipher on a whole string.
#let affine-enc(s, a, b) = letters(s).map(c => N2L(a * L2N(c) + b)).join()
#let affine-dec(s, a, b) = {
  let ai = modinv(a, 26)
  letters(s).map(c => N2L(ai * (L2N(c) - b))).join()
}

// 2x2 matrices as ((a, b), (c, d)).
#let mget(M, i, j) = M.at(i).at(j)
#let mat-det(M) = mget(M, 0, 0) * mget(M, 1, 1) - mget(M, 0, 1) * mget(M, 1, 0)
#let mat-inv(M) = {
  let d = posmod(mat-det(M), 26)
  let di = modinv(d, 26)
  if di == none { return none }
  (
    (posmod(di * mget(M, 1, 1), 26), posmod(di * (-mget(M, 0, 1)), 26)),
    (posmod(di * (-mget(M, 1, 0)), 26), posmod(di * mget(M, 0, 0), 26)),
  )
}
#let mat-mul(A, B) = range(2).map(i => range(2).map(j =>
  posmod(mget(A, i, 0) * mget(B, 0, j) + mget(A, i, 1) * mget(B, 1, j), 26)
))
// Render a 2x2 matrix inside math mode: $#mat26(K)$.
#let mat26(M) = math.mat(delim: "[", ..M)

// Hill cipher, key K applied to column vectors of digraphs.
#let hill-enc(s, K) = {
  let ls = letters(s)
  let out = ()
  let i = 0
  while i < ls.len() {
    let p1 = L2N(ls.at(i))
    let p2 = L2N(ls.at(i + 1))
    out.push(N2L(mget(K, 0, 0) * p1 + mget(K, 0, 1) * p2))
    out.push(N2L(mget(K, 1, 0) * p1 + mget(K, 1, 1) * p2))
    i = i + 2
  }
  out.join()
}

// A boxed final answer, in the monospace face so it reads as a result.
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

#let invalid-box(lbl, val) = block(
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

#let affine-enc-table(s, a, b) = {
  let rows = ()
  for c in letters(s) {
    let x = L2N(c)
    let t = a * x + b
    let y = posmod(t, 26)
    rows.push(([#upper(c)], [#x], [$#a times #x + #b = #t$], [#y], [#N2L(y)]))
  }
  set text(9.5pt)
  table(
    columns: (auto, auto, 1fr, auto, auto),
    align: (center, center, left, center, center).map(a => a + horizon),
    table.header([Plain], [$x$], [$#a x + #b$], [$mod 26$], [Cipher]),
    ..rows.flatten(),
  )
}

#let affine-dec-table(s, a, b) = {
  let ai = modinv(a, 26)
  let rows = ()
  for c in letters(s) {
    let y = L2N(c)
    let t = ai * (y - b)
    let x = posmod(t, 26)
    rows.push(([#upper(c)], [#y], [$#ai (#y - #b) = #t$], [#x], [#N2L(x)]))
  }
  set text(9.5pt)
  table(
    columns: (auto, auto, 1fr, auto, auto),
    align: (center, center, left, center, center).map(a => a + horizon),
    table.header([Cipher], [$y$], [$#ai (y - #b)$], [$mod 26$], [Plain]),
    ..rows.flatten(),
  )
}

#let hill-table(s, K) = {
  let ls = letters(s)
  let rows = ()
  let i = 0
  while i < ls.len() {
    let p1 = L2N(ls.at(i))
    let p2 = L2N(ls.at(i + 1))
    let t1 = mget(K, 0, 0) * p1 + mget(K, 0, 1) * p2
    let t2 = mget(K, 1, 0) * p1 + mget(K, 1, 1) * p2
    let c1 = posmod(t1, 26)
    let c2 = posmod(t2, 26)
    rows.push((
      [#upper(ls.at(i))#upper(ls.at(i + 1))],
      [$vec(#[#p1], #[#p2])$],
      [$#mget(K, 0, 0) times #p1 + #mget(K, 0, 1) times #p2 = #t1 equiv #c1$],
      [$#mget(K, 1, 0) times #p1 + #mget(K, 1, 1) times #p2 = #t2 equiv #c2$],
      [#N2L(c1)#N2L(c2)],
    ))
    i = i + 2
  }
  set text(8.5pt)
  table(
    columns: (auto, auto, 1fr, 1fr, auto),
    align: (center, center, left, left, center).map(a => a + horizon),
    table.header([Pair], [$P$], [$c_1 = "row"_1 P mod 26$], [$c_2 = "row"_2 P mod 26$], [Cipher]),
    ..rows.map(r => r).flatten(),
  )
}
== Question 1: Inverses of each integer modulo 26

$ b times t + 26 times s = 1 $

#(1, 3, 5, 7, 9, 11, 15, 17, 19, 21, 23, 25).map(bezout-block).join()

= Affine cipher

The affine cipher sends a letter $x$ to $ y = (a x + b) mod 26 $ and brings it back
with $ x = a^(-1)(y - b) mod 26, $ where $a^(-1)$ is the inverse worked out in
Question 1. That inverse only exists when $gcd(a, 26) = 1$, which is exactly the
condition for a usable key.

== Question 2: Encrypt a chosen string, $a = 5$, $b = 8$

Since $gcd(5, 26) = 1$, this key is fine. Taking `SECURITY` as the plaintext, each
letter runs through $(5 x + 8) mod 26$.

#figure(
  caption: [Affine encryption of `SECURITY` with $a = 5$, $b = 8$],
  affine-enc-table("SECURITY", 5, 8),
)

#result-box("Ciphertext, a = 5, b = 8", affine-enc("SECURITY", 5, 8))

== Question 3: Encrypt "HI", $a = 11$, $b = 5$

Again $gcd(11, 26) = 1$, so the key holds up. Each letter maps through $(11 x + 5) mod 26$.

#figure(
  caption: [Affine encryption of `HI` with $a = 11$, $b = 5$],
  affine-enc-table("HI", 11, 5),
)

#result-box("Ciphertext of HI", affine-enc("HI", 11, 5))

== Question 4: Decrypt "UCR", function $9 x + 2$

This ciphertext used $a = 9$, $b = 2$. Undoing it needs $9^(-1)$, which is $3$
(as $9 times 3 = 27 equiv 1$), so decryption reads $x = 3(y - 2) mod 26$.

#figure(
  caption: [Affine decryption of `UCR`, $a = 9$, $b = 2$],
  affine-dec-table("UCR", 9, 2),
)

#result-box("Plaintext of UCR", affine-dec("UCR", 9, 2))

== Question 5: Decrypt "KDYXJUWDEXZY", $a = 3$, $b = 4$

With $gcd(3, 26) = 1$ the key is valid, and $3^(-1) equiv 9$ (since
$3 times 9 = 27 equiv 1$). Every ciphertext letter then comes back through
$x = 9(y - 4) mod 26$.

#figure(
  caption: [Affine decryption of `KDYXJUWDEXZY`, $a = 3$, $b = 4$],
  affine-dec-table("KDYXJUWDEXZY", 3, 4),
)

#result-box("Plaintext", affine-dec("KDYXJUWDEXZY", 3, 4))

== Question 6: An invalid multiplier, $k_1 = 13$, $k_2 = 4$

The multiplier $k_1 = 13$ is not a valid key: $gcd(13, 26) = 13$, not $1$. The
question asks to encrypt with it regardless, which is a clean way to see what goes
wrong. The rule is $(13 x + 4) mod 26$.

The problem is that $13 x mod 26$ only ever lands on two values. For even $x$,
$13 x$ is a multiple of $26$, so $13 x equiv 0$ and the letter becomes
$0 + 4 = 4 =$ `E`. For odd $x$, $13 x equiv 13$, so it becomes $13 + 4 = 17 =$ `R`.
Every letter collapses to `E` or `R`, decided by nothing but whether its number is
even or odd.

#figure(
  caption: [Encrypting `INPUT` with the invalid key $a = 13$, $b = 4$],
  affine-enc-table("INPUT", 13, 4),
)

#figure(
  caption: [Encrypting `ALTER` with the invalid key $a = 13$, $b = 4$],
  affine-enc-table("ALTER", 13, 4),
)

#result-box("INPUT encrypts to", affine-enc("INPUT", 13, 4))
#result-box("ALTER encrypts to", affine-enc("ALTER", 13, 4))

*The issue.* `INPUT` and `ALTER` have the same run of even and odd letters, so both
land on the same string, #raw(affine-enc("INPUT", 13, 4)). With all $26$ letters
crammed onto two ciphertext letters the map stops being one-to-one, so it cannot be
reversed: `ERRER` could have come from `INPUT`, `ALTER`, or any other word with that
parity pattern. That is what $gcd(a, 26) != 1$ breaks, and why $13$ is never allowed
as a multiplier.

= Hill cipher and matrix keys

A $2 times 2$ Hill cipher uses a key matrix $K$ over $ZZ_26$. The key works only
when its determinant is invertible modulo $26$ — that is, $gcd(det K, 26) = 1$. When
it is, the inverse key is

$ K^(-1) = (det K)^(-1) mat(delim: "[", d, -b; -c, a) space (mod 26), quad
  "for" quad K = mat(delim: "[", a, b; c, d). $

== Question 7: Inverse of the key matrix modulo 26

#let k7 = ((3, 2), (5, 7))
Take the key as $K = #mat26(k7)$. Its determinant is
$det K = 3 times 7 - 2 times 5 = #mat-det(k7)$, and
$gcd(#posmod(mat-det(k7), 26), 26) = 1$, so $K$ inverts. Here
$#posmod(mat-det(k7), 26)^(-1) equiv #modinv(posmod(mat-det(k7), 26), 26)
space (mod 26)$, so multiplying the adjugate $mat(delim: "[", 7, -2; -5, 3)$ by it and
reducing modulo $26$ gives:

#result-box("Inverse key K^-1 (mod 26)", $#mat26(mat-inv(k7))$)

*Check.* Multiplying back, $K K^(-1) = #mat26(mat-mul(k7, mat-inv(k7)))$ — the
identity, so the inverse is right.

== Question 8: Inverse of the matrix modulo 26

#let k8 = ((11, 13), (2, 3))
For $K = #mat26(k8)$, $det K = 11 times 3 - 13 times 2 = #mat-det(k8)$, and
$gcd(#posmod(mat-det(k8), 26), 26) = 1$, so it inverts. Since
$#posmod(mat-det(k8), 26)^(-1) equiv #modinv(posmod(mat-det(k8), 26), 26)
space (mod 26)$, multiplying the adjugate $mat(delim: "[", 3, -13; -2, 11)$ by it and
reducing modulo $26$ gives:

#result-box("Inverse matrix (mod 26)", $#mat26(mat-inv(k8))$)

*Check.* $K K^(-1) = #mat26(mat-mul(k8, mat-inv(k8)))$ once more — the identity.

== Question 9: Is the key valid?

#let k9 = ((2, 14), (13, 21))
For $K = #mat26(k9)$, the determinant is
$det K = 2 times 21 - 14 times 13 = #mat-det(k9) equiv #posmod(mat-det(k9), 26)
space (mod 26)$. Checking whether that inverts,

$ gcd(#posmod(mat-det(k9), 26), 26) = #mygcd(posmod(mat-det(k9), 26), 26) != 1. $

The determinant shares a factor with $26$, so it has no inverse modulo $26$, and
neither does $K$.

#invalid-box(
  "Key invalid",
  [The determinant is $#posmod(mat-det(k9), 26) space (mod 26)$, and
    $gcd(#posmod(mat-det(k9), 26), 26) = #mygcd(posmod(mat-det(k9), 26), 26)$. Since that
    is not $1$, the key can't drive the Hill cipher, so there is nothing to encrypt or
    decrypt here.],
)

== Question 10: Encrypt "SOLVED" with the Hill cipher

#let k10 = ((3, 8), (7, 11))
The key is $K = #mat26(k10)$, and
$det K = 3 times 11 - 8 times 7 = #mat-det(k10) equiv #posmod(mat-det(k10), 26)$. Since
$gcd(#posmod(mat-det(k10), 26), 26) = 1$, it is a valid key, so encryption can go
ahead.

`SOLVED` breaks into the digraphs `SO`, `LV`, `ED`. Each pair becomes a column
vector $P$, and its ciphertext is $C = K P mod 26$.

#figure(
  caption: [Hill encryption of `SOLVED` under $K = #mat26(k10)$],
  hill-table("SOLVED", k10),
)

#result-box("Ciphertext of SOLVED", hill-enc("SOLVED", k10))
