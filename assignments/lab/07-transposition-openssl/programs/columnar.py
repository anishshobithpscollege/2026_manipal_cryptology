from common import read_text, read_key, read_mode, columnar_encrypt, columnar_decrypt

text = read_text()
key = read_key()

if read_mode() == "e":
    print("Ciphertext:", columnar_encrypt(text, key))
else:
    try:
        print("Plaintext :", columnar_decrypt(text, key))
    except ValueError as e:
        print("Error:", e)
