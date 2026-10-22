def read_text(prompt="Enter text: "):
    while True:
        text = "".join(c for c in input(prompt).upper() if c.isalpha() and c.isascii())
        if text:
            return text
        print("Error: text must contain at least one letter.")


def read_key(prompt="Enter keyword: "):
    while True:
        key = input(prompt).strip().upper()
        if len(key) < 2:
            print("Error: keyword needs at least 2 characters.")
        elif not (key.isalpha() and key.isascii()):
            print("Error: keyword must contain letters only.")
        else:
            return key


def read_mode():
    while True:
        m = input("Encrypt or Decrypt? (e/d): ").strip().lower()
        if m in ("e", "d"):
            return m
        print("Error: type 'e' or 'd'.")


def column_order(key):
    return sorted(range(len(key)), key=lambda i: (key[i], i))


def columnar_encrypt(text, key, pad="X"):
    cols = len(key)
    text += pad * (-len(text) % cols)
    rows = [text[i:i + cols] for i in range(0, len(text), cols)]
    return "".join("".join(r[c] for r in rows) for c in column_order(key))


def columnar_decrypt(cipher, key):
    cols = len(key)
    if len(cipher) % cols:
        raise ValueError(f"ciphertext length must be a multiple of {cols}")
    height = len(cipher) // cols
    grid = [[""] * cols for _ in range(height)]
    for n, c in enumerate(column_order(key)):
        for r in range(height):
            grid[r][c] = cipher[n * height + r]
    return "".join("".join(r) for r in grid)
