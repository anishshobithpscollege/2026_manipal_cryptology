import re

with open("security_data.txt", "r") as file:
    data = file.read()

sessions = re.findall(r"SEC-\d{4}-\d{4}", data)

print("Session IDs found:")
for session in sessions:
    print(session)
