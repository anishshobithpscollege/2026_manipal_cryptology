from math import gcd
from common import read_text, read_int, read_mode, mod_inverse


def affine(text, a, b, decrypt=False):
    inv = mod_inverse(a) if decrypt else None
    out = []
    for c in text:
        if c.isascii() and c.isalpha():
            base = ord("A") if c.isupper() else ord("a")
            x = ord(c) - base
            y = inv * (x - b) % 26 if decrypt else (a * x + b) % 26
            out.append(chr(y + base))
        else:
            out.append(c)
    return "".join(out)


text = read_text()
while True:
    a = read_int("Enter key a (must be coprime with 26): ")
    if gcd(a, 26) == 1:
        break
    print(f"Error: gcd({a}, 26) is not 1. Valid values: 1,3,5,7,9,11,15,17,19,21,23,25")
b = read_int("Enter key b (0-25): ", 0, 25)

if read_mode() == "e":
    print("Ciphertext:", affine(text, a, b))
else:
    print("Plaintext :", affine(text, a, b, decrypt=True))
