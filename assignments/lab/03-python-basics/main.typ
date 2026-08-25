#import "/template/lib.typ": *
#import "/template/theme.typ": theme
#import "@preview/codly:1.3.0" as codly

#show: assignment.with(
  title: "Introduction to Python",
  number: "Assignment 03",
  kind: "Lab",
  date: datetime(year: 2026, month: 8, day: 25),
)

// Questions carry their own "Question N" label, so drop the auto number on
// level-2 headings and keep it only on the part headings.
#show heading.where(level: 2): set heading(numbering: none)

// Include a program straight from the programs/ folder, so the listing here is
// always the file that actually runs.
#let prog(path) = raw(read(path), lang: "python", block: true)

// A captured run. No line numbers, and an "Output" label so it reads apart from
// the source above it.
#let out(body) = block(breakable: true, above: 0.7em, below: 1.1em)[
  #text(size: 7.5pt, fill: theme.muted, weight: "bold", tracking: 0.6pt)[OUTPUT]
  #v(2pt)
  #codly.local(number-format: none)[#body]
]

// A before/after patch for the debugging question.
#let patch(body) = block(breakable: true, above: 0.7em, below: 1em)[
  #codly.local(number-format: none)[#body]
]

= Overview

This lab covers the basics of Python used in the later cryptology work: input and
arithmetic, the built-in data types, string slicing and character codes, blocking
and padding, character frequencies, arithmetic modulo 26, primality, the greatest
common divisor, and the modular inverse. It ends with a short client and server
exchange over a socket.

Each program is a file in the `programs/` folder beside this document. Every
listing is read from that file, and every output block is the real result of
running it on Python 3. Programs that read input show a sample run with the typed
values after each prompt.

= Python basics and debugging

== Question 1: Debugging and error types

Each fragment fails for a different reason. A `SyntaxError` is raised while Python
parses the file, before any line runs. A `NameError` and a `TypeError` are raised
later, when execution reaches the faulty line.

#figure(
  caption: [The three bugs, their error type and the fix],
  {
    set text(9.5pt)
    table(
      columns: (0.5fr, 0.8fr, 1.6fr, 1.3fr),
      align: (center, left, left, left),
      table.header([\#], [Error type], [Cause], [Fix]),
      [1], [`SyntaxError`],
      [The string literal is never closed, so the file does not parse.],
      [Add the closing `"`.],
      [2], [`NameError`],
      [`mesage` is not defined. The name is `message`.],
      [Use the correct name `message`.],
      [3], [`TypeError`],
      [`input()` returns a `str`, and `str + int` is not allowed.],
      [Convert with `int(input(...))`.],
    )
  },
)

*Bug 1: unterminated string.* The closing quote is missing, so the string literal
never ends.

#patch[```diff
- print("Welcome to Cryptology Lab)
+ print("Welcome to Cryptology Lab")
```]

#out[```
  File "bug1.py", line 1
    print("Welcome to Cryptology Lab)
          ^
SyntaxError: unterminated string literal (detected at line 1)
```]

*Bug 2: misspelled name.* The variable is `message`, but the call reads `mesage`.
Python does not find that name and stops.

#patch[```diff
  message = "Python Programming"
- print(mesage)
+ print(message)
```]

#out[```
Traceback (most recent call last):
  File "bug2.py", line 2, in <module>
    print(mesage)
          ^^^^^^
NameError: name 'mesage' is not defined. Did you mean: 'message'?
```]

*Bug 3: string where a number is expected.* `input()` returns a string, so
`num + 10` adds an integer to a string. `int()` converts the input first, and the
addition then works.

#patch[```diff
- num = input("Enter a number: ")
+ num = int(input("Enter a number: "))
  result = num + 10
  print(result)
```]

#out[```
Enter a number: 5
Traceback (most recent call last):
  File "bug3.py", line 2, in <module>
    result = num + 10
             ~~~~^~~~
TypeError: can only concatenate str (not "int") to str
```]

The corrected program, with all three fixes applied:

#prog("programs/q01_debug.py")

#out[```
Welcome to Cryptology Lab
Python Programming
Enter a number: 5
15
```]

== Question 2: Printing text with quotes

A string in double quotes can hold an apostrophe, and a string in single quotes
can hold double quotes. Neither line needs an escape.

#prog("programs/q02_display.py")

#out[```
Welcome to Cryptology Lab
It's interesting to learn Python.
Students, "Welcome to the Cryptology Lab".
```]

== Question 3: Arithmetic operations

Both inputs are read as integers. Division with `/` gives a float, `//` gives
the floor of that division, `%` gives the remainder, and `**` raises to a power.

#prog("programs/q03_arithmetic.py")

#out[```
Enter the first number: 17
Enter the second number: 5
Addition : 22
Subtraction : 12
Multiplication : 85
Division : 3.4
Integer division : 3
Remainder : 2
Exponentiation : 1419857
```]

== Question 4: Inspecting a float

`type()` reports the class of the value, `abs()` drops the sign, and `round(x, 2)`
rounds to two decimal places.

#prog("programs/q04_float.py")

#out[```
Enter a floating-point number: -12.34567
Data type : <class 'float'>
Absolute value : 12.34567
Rounded to 2 dp : -12.35
```]

= Data types and collections

== Question 5: Built-in data types

One value of each of the eight types, printed with its value and the class that
`type()` returns for it.

#prog("programs/q05_data_types.py")

#out[```
int : 42 <class 'int'>
float : 3.14 <class 'float'>
complex : (2+3j) <class 'complex'>
str : 'Cryptology' <class 'str'>
list : [2, 3, 5, 7, 11] <class 'list'>
tuple : (1, 2, 3) <class 'tuple'>
set : {1, 2, 3} <class 'set'>
dict : {'cipher': 'AES', 'bits': 256} <class 'dict'>
```]

== Question 6: Immutable strings, mutable lists

The `id()` of each value is checked before and after a change. Concatenating to
the string makes a new object, so its id changes: the string cannot be altered in
place, which is what immutable means. Appending to the list keeps the same object,
so its id is unchanged, which is what mutable means. A reference to each original
is kept so its address is not reused.

#prog("programs/q06_mutability.py")

#out[```
String now : PYTHON3
Same object as before : False
List now : [1, 2, 3, 4]
Same object as before : True
```]

== Question 7: List operations on primes

`is_prime` tests trial divisors up to $sqrt(n)$. `primes_from` collects that many
primes from a start value. Five are generated first, then slicing reads parts of
the list, `append` adds the next prime, `extend` adds two more, and `len` counts
them.

#prog("programs/q07_prime_list.py")

#out[```
List : [2, 3, 5, 7, 11]
First three : [2, 3, 5]
Last element : 11
After append : [2, 3, 5, 7, 11, 13]
After extend : [2, 3, 5, 7, 11, 13, 17, 19]
Total elements : 8
```]

= String operations

Questions 8 to 12 all use the same string:

#align(center, box(inset: (y: 4pt))[#raw("message = \"CRYPTOLOGY USING PYTHON\"", lang: "python")])

== Question 8: Length, slicing and reversal

`message[:5]` takes the first five characters and `message[-6:]` the last six.
`message[3:8]` takes indices 3 to 7, since the end index is excluded, giving
`PTOLO`. `message[::-1]` steps backwards to reverse the string.

#prog("programs/q08_slicing.py")

#out[```
Length : 23
First five chars : CRYPT
Last six chars : PYTHON
Positions 3 to 8 : PTOLO
Reversed : NOHTYP GNISU YGOLOTPYRC
```]

== Question 9: Case, membership and replace

`lower()` and `upper()` return new strings in the other case. `in` tests whether
one string occurs inside another. `replace()` returns a copy with every match
substituted.

#prog("programs/q09_string_methods.py")

#out[```
Lowercase : cryptology using python
Back to uppercase : CRYPTOLOGY USING PYTHON
'PYTHON' present : True
Replaced : CRYPTOLOGY USING PROGRAMMING
```]

== Question 10: Removing spaces

Replacing each space with the empty string deletes the spaces and joins the
words. This is the same normalisation a cipher applies before encrypting.

#prog("programs/q10_remove_spaces.py")

#out[```
Without spaces : CRYPTOLOGYUSINGPYTHON
```]

== Question 11: Characters and code points

Iterating over a string yields its characters in order. `ord()` gives the
Unicode code point of each, which matches ASCII for these letters. The space
between the words shows up as code point 32.

#prog("programs/q11_ord.py")

#out[```
C : 67
R : 82
Y : 89
P : 80
T : 84
O : 79
L : 76
O : 79
G : 71
Y : 89
  : 32
U : 85
S : 83
I : 73
N : 78
G : 71
  : 32
P : 80
Y : 89
T : 84
H : 72
O : 79
N : 78
```]

== Question 12: Code points to characters

`chr()` is the inverse of `ord()`: it turns a code point back into a character.
Joining the results spells `ACIPHER`, which reads as "A CIPHER".

#prog("programs/q12_chr.py")

#out[```
Characters : ['A', 'C', 'I', 'P', 'H', 'E', 'R']
Word : ACIPHER
```]

= Text processing for cryptology

== Question 13: Plaintext preprocessing

`strip()` removes the leading and trailing spaces, `upper()` sets one case, and
`replace(" ", "")` removes the gaps between words. The three are chained in one
expression.

#prog("programs/q13_preprocess.py")

#out[```
Enter a message:   meet me tomorrow
Preprocessed : MEETMETOMORROW
```]

== Question 14: Grouping into blocks of five

Stepping the start index in fives and taking a five-character slice each time
splits the text into blocks. The last block is short when the length is not a
multiple of five.

#prog("programs/q14_grouping.py")

#out[```
Enter a string: CRYPTOLOGYLAB
CRYPT
OLOGY
LAB
```]

== Question 15: Padding the final block

`ljust(5, "X")` pads each block on the right to five characters with `X`. Only the
last block is short, so `LAB` becomes `LABXX`. The full blocks are already five
wide.

#prog("programs/q15_padding.py")

#out[```
Enter a string: CRYPTOLOGYLAB
CRYPT
OLOGY
LABXX
```]

== Question 16: Character frequency

A `defaultdict(int)` counts each character: an unseen key starts at zero, so
`frequency[c] += 1` needs no special case. `max(frequency, key=frequency.get)`
returns the character with the highest count. `T` and `I` both appear three times,
and `max()` returns `T`, the first one reached.

#prog("programs/q16_frequency.py")

#out[```
C : 1
R : 2
Y : 2
P : 1
T : 3
O : 2
L : 1
G : 2
I : 3
S : 2
N : 2
E : 2
Most frequent : T (3 times)
```]

== Question 17: Percentage frequency

The percentage frequency of a character is its count divided by the total, times
100. With 23 characters, a count of 3 gives $3 / 23 times 100 = 13.04%$ and a count
of 1 gives $4.35%$. Each value is rounded to two decimal places.

#prog("programs/q17_percentage.py")

#out[```
C : 1 (4.35%)
R : 2 (8.70%)
Y : 2 (8.70%)
P : 1 (4.35%)
T : 3 (13.04%)
O : 2 (8.70%)
L : 1 (4.35%)
G : 2 (8.70%)
I : 3 (13.04%)
S : 2 (8.70%)
N : 2 (8.70%)
E : 2 (8.70%)
```]

= Mathematical foundations for cryptology

== Question 18: Modular arithmetic

In Python the result of `%` takes the sign of the divisor, so a positive modulus
gives a result in $0$ to $25$ even for a negative input: $-3 mod 26 = 23$. The
program prints the five given cases, then reduces any entered integer modulo 26.

#prog("programs/q18_modular.py")

#out[```
29 mod 26 = 3
55 mod 26 = 3
78 mod 26 = 0
-3 mod 26 = 23
-29 mod 26 = 23
Enter an integer: 100
100 mod 26 = 22
```]

== Question 19: Alphabet representation

With $A = 0$ through $Z = 25$, a letter's number is `ord(letter) - ord("A")` and
a number's letter is `chr(value + ord("A"))`. The two conversions are inverses of
each other.

#prog("programs/q19_alphabet.py")

#out[```
Enter character: M
M : 12
Enter number: 12
12 : M
```]

== Question 20: Prime numbers

`is_prime` rejects anything below 2 and otherwise tries trial divisors up to
$sqrt(n)$. If none divides `n`, it is prime. The range is filtered with that test.

#prog("programs/q20_primes.py")

#out[```
Enter a number to test: 29
29 is prime
Range start: 10
Range end: 30
Primes in [10, 30] : [11, 13, 17, 19, 23, 29]
```]

== Question 21: GCD and coprimes

`math.gcd(a, b)` returns the greatest common divisor. Two numbers are coprime
when that divisor is 1. The three test pairs give the expected results: 15 and
26 are coprime, 18 and 24 share the factor 6, and 17 and 26 are coprime.

#prog("programs/q21_gcd.py")

#out[```
Enter the first integer: 15
Enter the second integer: 26
gcd(15, 26) = 1
Coprime
```]

#figure(
  caption: [The three test pairs],
  {
    set text(9.5pt)
    table(
      columns: (auto, auto, auto, auto),
      align: (center, center, center, center),
      table.header([$a$], [$b$], [$gcd(a, b)$], [Coprime?]),
      [15], [26], [1], [Yes],
      [18], [24], [6], [No],
      [17], [26], [1], [Yes],
    )
  },
)

== Question 22: Multiplicative inverse

The modular multiplicative inverse of $b$ modulo $m$ is the value $x$ with
$b x equiv 1 space (mod m)$. It exists only when $gcd(b, m) = 1$. `pow(b, -1, m)`
returns it directly and raises `ValueError` when none exists. The modulus defaults
to 26, the size of the alphabet.

#prog("programs/q22_inverse.py")

#out[```
Enter b: 3
Enter modulus m: 26
Inverse of 3 modulo 26 is 9 (check: 3 * 9 mod 26 = 1)
```]

#figure(
  caption: [Inverses modulo 26],
  {
    set text(9.5pt)
    table(
      columns: (auto, auto, auto, 1.4fr),
      align: (center, center, center, left),
      table.header([$b$], [$m$], [Inverse], [Check]),
      [3], [26], [9], [$3 dot 9 = 27 equiv 1 space (mod 26)$],
      [7], [26], [15], [$7 dot 15 = 105 equiv 1 space (mod 26)$],
      [4], [26], [none], [$gcd(4, 26) = 2$, so no inverse exists],
    )
  },
)

= Challenge

== Question 23: Client and server communication

The two programs talk over a TCP socket on the loopback address `127.0.0.1`. The
server binds to port 65432, listens, and accepts one connection. The client
connects, sends a message, and waits for the reply. The server returns the message
under ROT13 rather than a plain echo, so `HELLO SERVER` comes back as
`URYYB FREIRE`. The server is started first, then the client in a second terminal.

*Server.*

#prog("programs/q23_server.py")

*Client.*

#prog("programs/q23_client.py")

Running the server, then the client, gives the following two transcripts. The
port on the "Connected by" line is the client's ephemeral port and changes from
run to run.

#out[```
# Terminal 1 - server
Server listening on 127.0.0.1:65432
Connected by ('127.0.0.1', 54349)
Received : HELLO SERVER
Sent : URYYB FREIRE
```]

#out[```
# Terminal 2 - client
Sent : HELLO SERVER
Received : URYYB FREIRE
```]
