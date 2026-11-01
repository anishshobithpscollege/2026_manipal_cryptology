from common import read_text, read_key, read_mode, columnar_encrypt, columnar_decrypt

text = read_text()
key1 = read_key("Enter first keyword : ")
key2 = read_key("Enter second keyword: ")

if read_mode() == "e":
    print("After pass 1:", columnar_encrypt(text, key1))
    print("Ciphertext  :", columnar_encrypt(columnar_encrypt(text, key1), key2))
else:
    try:
        step = columnar_decrypt(text, key2)
        print("After pass 1:", step)
        print("Plaintext   :", columnar_decrypt(step, key1))
    except ValueError as e:
        print("Error:", e)
