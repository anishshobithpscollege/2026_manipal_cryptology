import secrets
from common import read_int, read_prime, read_choice

DEFAULT_P = 0xFFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3DC2007CB8A163BF0598DA48361C55D39A69163FA8FD24CF5F83655D23DCA3AD961C62F356208552BB9ED529077096966D670C354E4ABC9804F1746C08CA18217C32905E462E36CE3BE39E772C180E86039B2783A2EC07A28FB5C55DF06F4C52C9DE2BCBF6955817183995497CEA956AE515D2261898FA051015728E5A8AACAA68FFFFFFFFFFFFFFFF
DEFAULT_G = 2


def public_value(g, private, p):
    return pow(g, private, p)


def shared_secret(other_public, private, p):
    return pow(other_public, private, p)


def read_private(name, p):
    if read_choice(f"Generate {name}'s private key randomly? (y/n): ", ("y", "n")) == "y":
        return secrets.randbelow(p - 3) + 2
    return read_int(f"Enter {name}'s private key (2 to {p - 2}): ", 2, p - 2)


if read_choice("Use the standard 2048-bit group? (y/n): ", ("y", "n")) == "y":
    p, g = DEFAULT_P, DEFAULT_G
else:
    p = read_prime("Enter prime p: ", 5)
    g = read_int(f"Enter generator g (2 to {p - 2}): ", 2, p - 2)

a = read_private("Alice", p)
b = read_private("Bob", p)

A = public_value(g, a, p)
B = public_value(g, b, p)
print("Alice public A =", A if p.bit_length() < 64 else hex(A)[:40] + "...")
print("Bob public B   =", B if p.bit_length() < 64 else hex(B)[:40] + "...")

sa = shared_secret(B, a, p)
sb = shared_secret(A, b, p)
print("Alice secret   =", sa if p.bit_length() < 64 else hex(sa)[:40] + "...")
print("Bob secret     =", sb if p.bit_length() < 64 else hex(sb)[:40] + "...")
print("Secrets match  :", sa == sb)
