import re

with open("security_data.txt", "r") as file:
    lines = file.readlines()

print("Lines containing 'failed':")
for line in lines:
    if re.search(r"failed", line, re.IGNORECASE):
        print(line.strip())
