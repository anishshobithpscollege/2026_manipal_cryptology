import secrets
import string

ALPHA = string.ascii_uppercase


def clean(text):
    return "".join(c for c in text.upper() if c in ALPHA)


def otp(text, key, decrypt=False):
    sign = -1 if decrypt else 1
    return "".join(
        ALPHA[(ALPHA.index(t) + sign * ALPHA.index(k)) % 26] for t, k in zip(text, key)
    )


while True:
    message = clean(input("Enter message (letters only): "))
    if message:
        break
    print("Error: message must contain at least one letter.")

key = clean(input("Enter key, or press Enter to generate one: "))
if not key:
    key = "".join(secrets.choice(ALPHA) for _ in message)
    print("Generated key:", key)
elif len(key) != len(message):
    raise SystemExit(f"Error: key length ({len(key)}) must equal message length ({len(message)}).")

cipher = otp(message, key)
print("Plaintext :", message)
print("Ciphertext:", cipher)
print("Decrypted :", otp(cipher, key, decrypt=True))
