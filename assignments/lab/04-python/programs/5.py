with open("cryptology.txt", "r") as file:
    data = file.read()
    char_count = len(data)
    word_count = len(data.split())
    line_count = len(data.split("\n"))

print(f"Character Count : {char_count}")
print(f"Word Count : {word_count}")
print(f"Line Count : {line_count}")
