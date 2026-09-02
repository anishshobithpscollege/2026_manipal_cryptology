import re

with open("security_data.txt", "r") as file:
    data = file.read()

match = re.search(r"Port (\d+)", data)

if match:
    print(f"Port number : {match.group(1)}")
