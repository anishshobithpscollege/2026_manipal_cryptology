word = input("Enter a word to search for: ").strip()

with open('cryptology.txt', 'r', encoding='utf-8') as file:
    lines = file.readlines()
    found = []

    for no, line in enumerate(lines, start=1):
        if word.lower() in line.lower():
            found.append((no, line.strip()))

    if found:
        print(f"\nFound '{word}' in the following lines:")
        for num, text in found:
            print(f"Line {num}: {text}")
    else:
        print(f"\n' {word}' was not found in cryptology.txt.")
