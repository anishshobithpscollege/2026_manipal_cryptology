from math import gcd


def read_text(prompt="Enter text: "):
    while True:
        text = input(prompt).strip()
        if not text:
            print("Error: text cannot be empty.")
        elif not any(c.isalpha() for c in text):
            print("Error: text must contain at least one letter.")
        else:
            return text


def read_int(prompt, lo=None, hi=None):
    while True:
        raw = input(prompt).strip()
        try:
            n = int(raw)
        except ValueError:
            print("Error: enter a whole number.")
            continue
        if (lo is not None and n < lo) or (hi is not None and n > hi):
            print(f"Error: value must be between {lo} and {hi}.")
            continue
        return n


def read_mode():
    while True:
        m = input("Encrypt or Decrypt? (e/d): ").strip().lower()
        if m in ("e", "d"):
            return m
        print("Error: type 'e' or 'd'.")


def shift_text(text, k):
    out = []
    for c in text:
        if c.isascii() and c.isalpha():
            base = ord("A") if c.isupper() else ord("a")
            out.append(chr((ord(c) - base + k) % 26 + base))
        else:
            out.append(c)
    return "".join(out)


def mod_inverse(a, m=26):
    if gcd(a, m) != 1:
        raise ValueError(f"{a} has no inverse mod {m}")
    return pow(a, -1, m)
