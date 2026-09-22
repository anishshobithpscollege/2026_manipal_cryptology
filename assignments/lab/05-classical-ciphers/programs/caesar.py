from common import read_text, read_mode, shift_text

KEY = 3  # Caesar cipher is the shift cipher with a fixed key of 3

text = read_text()
if read_mode() == "e":
    print("Ciphertext:", shift_text(text, KEY))
else:
    print("Plaintext :", shift_text(text, -KEY))
