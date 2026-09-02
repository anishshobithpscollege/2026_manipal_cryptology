#import "/template/lib.typ": *
#import "/template/theme.typ": theme
#import "@preview/codly:1.3.0" as codly

#show: assignment.with(
  title: "File Handling and Regular Expressions",
  number: "Assignment 04",
  kind: "Lab",
  date: datetime(year: 2026, month: 9, day: 2),
)

// The two parts are literally "Level 1" and "Level 2", so drop the automatic
// section number and keep the level name. Questions carry their own label too.
#show heading.where(level: 1): set heading(numbering: none)
#show heading.where(level: 2): set heading(numbering: none)

// Include a program straight from the programs/ folder, so the listing here is
// always the file that actually runs.
#let prog(path) = codly.local()[#raw(read(path), lang: "python", block: true)]

// Show a plain text data file with no syntax colouring and no line numbers.
#let datafile(path) = codly.local(number-format: none)[#raw(read(path), block: true)]

// A captured run. No line numbers, and an "Output" label so it reads apart from
// the source above it.
#let out(body) = block(breakable: true, above: 0.7em, below: 1.1em)[
  #text(size: 7.5pt, fill: theme.muted, weight: "bold", tracking: 0.6pt)[OUTPUT]
  #v(2pt)
  #codly.local(number-format: none)[#body]
]

= Level 1: File handling

== Question 1: Writing five statements to a file

#prog("programs/1.py")

#out[```
Enter Statements :
Enter statement 1 of 5: Cryptology is the study of secure communication.
Enter statement 2 of 5: Cryptography focuses on protecting information.
Enter statement 3 of 5: Cryptanalysis focuses on analyzing cryptographic systems.
Enter statement 4 of 5: Plaintext represents the original message.
Enter statement 5 of 5: Ciphertext represents the transformed message.
```]

The five lines are now saved in `cryptology.txt`:

#datafile("programs/cryptology.txt")

== Question 2: Displaying the whole file

#prog("programs/2.py")

#out[```
Cryptology is the study of secure communication.
Cryptography focuses on protecting information.
Cryptanalysis focuses on analyzing cryptographic systems.
Plaintext represents the original message.
Ciphertext represents the transformed message.
```]

== Question 3: Numbering each line

#prog("programs/3.py")

#out[```
1. Cryptology is the study of secure communication.
2. Cryptography focuses on protecting information.
3. Cryptanalysis focuses on analyzing cryptographic systems.
4. Plaintext represents the original message.
5. Ciphertext represents the transformed message.
```]

== Question 4: Writing the numbered lines to a file

#prog("programs/4.py")

The result is stored in `cryptology_no.txt`:

#datafile("programs/cryptology_no.txt")

== Question 5: Counting lines, words and characters

#prog("programs/5.py")

#out[```
Character Count : 244
Word Count : 28
Line Count : 5
```]

== Question 6: Counting character categories

#prog("programs/6.py")

#out[```
Upper : 5
Lower : 207
Digits : 5
Spaces : 32
Special : 10
```]

== Question 7: Searching for a word

#prog("programs/7.py")

#out[```
Enter a word to search for: Cryptanalysis

Found 'Cryptanalysis' in the following lines:
Line 3: Cryptanalysis focuses on analyzing cryptographic systems.
```]

== Question 8: Lines containing "message"

#prog("programs/8.py")

#out[```
Found 'message' in the following lines:
Line 4: Plaintext represents the original message.
Line 5: Ciphertext represents the transformed message.
```]

== Question 9: An uppercase copy in a new file

#prog("programs/9.py")

The uppercase copy is stored in `normalized.txt`:

#datafile("programs/normalized.txt")

== Question 10: Lines that are only letters

#prog("programs/10.py")

== Question 11: Reversing a string from the user

#prog("programs/11.py")

#out[```
Enter a string: Cryptanalysis
Reversed : sisylanatpyrC
```]

== Question 12: Reversing the contents of a file

#prog("programs/12.py")

#out[```
.egassem demrofsnart eht stneserper txetrehpiC
.egassem lanigiro eht stneserper txetnialP
.smetsys cihpargotpyrc gnizylana no sesucof sisylanatpyrC
.noitamrofni gnitcetorp no sesucof yhpargotpyrC
.noitacinummoc eruces fo yduts eht si ygolotpyrC
```]

== Question 13: Simulating the tac command

#prog("programs/13.py")

#out[```
Ciphertext represents the transformed message.
Plaintext represents the original message.
Cryptanalysis focuses on analyzing cryptographic systems.
Cryptography focuses on protecting information.
Cryptology is the study of secure communication.
```]

= Level 2: Regular expressions


#datafile("programs/security_data.txt")

== Question 1: IPv4 addresses

#prog("programs/regex_1.py")

#out[```
IP addresses found:
192.168.10.15
10.10.5.21
```]

== Question 2: Email addresses

#prog("programs/regex_2.py")

#out[```
Email addresses found:
admin@securitylab.com
```]

== Question 3: Session identifiers

#prog("programs/regex_3.py")

#out[```
Session IDs found:
SEC-2026-1045
```]

== Question 4: Hexadecimal sequences

#prog("programs/regex_4.py")

#out[```
Hexadecimal sequences found:
a94f3c2d8e71b05f
```]

== Question 5: Lines mentioning a failure

#prog("programs/regex_5.py")

#out[```
Lines containing 'failed':
Failed login attempts: 5
User admin failed authentication
```]

== Question 6: Extracting a port number

#prog("programs/regex_6.py")

#out[```
Port number : 443
```]
