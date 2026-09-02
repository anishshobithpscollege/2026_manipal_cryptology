import re

with open("security_data.txt", "r") as file:
    data = file.read()

hexes = re.findall(r"[0-9a-fA-F]{6,}", data)

print("Hexadecimal sequences found:")
for value in hexes:
    print(value)
