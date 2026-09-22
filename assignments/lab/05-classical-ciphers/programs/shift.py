from common import read_text, read_int, read_mode, shift_text

text = read_text()
k = read_int("Enter shift key (0-25): ", 0, 25)
if read_mode() == "e":
    print("Ciphertext:", shift_text(text, k))
else:
    print("Plaintext :", shift_text(text, -k))
