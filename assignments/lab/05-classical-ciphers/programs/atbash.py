from common import read_text, read_mode


def atbash(text):
    out = []
    for c in text:
        if c.isascii() and c.isalpha():
            base = ord("A") if c.isupper() else ord("a")
            out.append(chr(base + 25 - (ord(c) - base)))
        else:
            out.append(c)
    return "".join(out)


text = read_text()
read_mode()  # atbash is symmetric, the mode only changes the label
print("Result:", atbash(text))
