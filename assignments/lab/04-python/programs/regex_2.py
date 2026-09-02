import re

with open("security_data.txt", "r") as file:
    data = file.read()

emails = re.findall(r"\w+@\w+\.\w+", data)

print("Email addresses found:")
for email in emails:
    print(email)
