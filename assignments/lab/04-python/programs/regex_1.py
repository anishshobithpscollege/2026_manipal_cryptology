import re

with open("security_data.txt", "r") as file:
    data = file.read()

ips = re.findall(r"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}", data)

print("IP addresses found:")
for ip in ips:
    print(ip)
