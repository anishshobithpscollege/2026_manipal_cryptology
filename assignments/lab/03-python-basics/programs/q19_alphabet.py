letter = input("Enter character: ").strip().upper()
number = ord(letter) - ord("A")
print(letter, ":", number)

value = int(input("Enter number: "))
character = chr(value + ord("A"))
print(value, ":", character)
