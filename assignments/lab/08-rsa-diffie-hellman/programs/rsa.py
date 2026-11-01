from math import gcd
from common import generate_prime, read_int, read_prime, read_choice

BITS = 16


def make_keys(p, q, e):
    n, phi = p * q, (p - 1) * (q - 1)
    return (e, n), (pow(e, -1, phi), n)


def encrypt(text, public):
    e, n = public
    return [pow(ord(c), e, n) for c in text]


def decrypt(blocks, private):
    d, n = private
    return "".join(chr(pow(b, d, n)) for b in blocks)


if read_choice("Generate primes automatically? (y/n): ", ("y", "n")) == "y":
    p = generate_prime(BITS)
    q = generate_prime(BITS)
    while q == p:
        q = generate_prime(BITS)
else:
    while True:
        p = read_prime("Enter prime p: ")
        q = read_prime("Enter prime q: ")
        if p == q:
            print("Error: p and q must be different.")
        elif p * q <= 255:
            print("Error: p * q must exceed 255 to hold a character.")
        else:
            break

phi = (p - 1) * (q - 1)
while True:
    e = read_int(f"Enter public exponent e (1 < e < {phi}, coprime with phi): ", 2, phi - 1)
    if gcd(e, phi) == 1:
        break
    print(f"Error: gcd({e}, {phi}) is not 1.")

public, private = make_keys(p, q, e)
print(f"p = {p}, q = {q}, n = {p * q}, phi = {phi}")
print("Public key (e, n):", public)
print("Private key (d, n):", private)

while True:
    message = input("Enter message: ")
    if message:
        break
    print("Error: message cannot be empty.")

if any(ord(c) >= p * q for c in message):
    raise SystemExit("Error: message has a character larger than n.")

blocks = encrypt(message, public)
print("Ciphertext:", blocks)
print("Decrypted :", decrypt(blocks, private))
