from common import read_text, shift_text

# ROT13 is its own inverse, so one function does both encryption and decryption
text = read_text()
result = shift_text(text, 13)
print("ROT13 output:", result)
print("Applied again:", shift_text(result, 13))
