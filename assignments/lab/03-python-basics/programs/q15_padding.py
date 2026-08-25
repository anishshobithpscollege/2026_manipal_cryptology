text = input("Enter a string: ")

for start in range(0, len(text), 5):
    print(text[start:start + 5].ljust(5, "X"))
