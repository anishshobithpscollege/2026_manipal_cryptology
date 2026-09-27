CIPHERTEXT = "MCI RWR WH"

for k in range(26):
    plain = "".join(
        chr((ord(c) - ord("A") - k) % 26 + ord("A")) if c.isalpha() else c
        for c in CIPHERTEXT
    )
    print(f"Key {k:2d}: {plain}")
