def rail_fence_encrypt(text, rails):
    fence = [[] for _ in range(rails)]
    row, step = 0, 1
    for c in text:
        fence[row].append(c)
        if row == 0:
            step = 1
        elif row == rails - 1:
            step = -1
        row += step
    return "".join("".join(r) for r in fence)


while True:
    text = input("Enter plaintext: ").replace(" ", "")
    if text:
        break
    print("Error: plaintext cannot be empty.")

while True:
    try:
        rails = int(input("Enter number of rails: "))
    except ValueError:
        print("Error: enter a whole number.")
        continue
    if 2 <= rails <= len(text):
        break
    print(f"Error: rails must be between 2 and {len(text)}.")

print("Ciphertext:", rail_fence_encrypt(text, rails))
