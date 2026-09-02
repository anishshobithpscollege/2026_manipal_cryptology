map = {
    "upper" : 0,
    "lower": 0,
    "digits": 0,
    "spaces": 0,
    "special": 0
}
with open("cryptology_no.txt", "r") as file:
    data = file.read()
    for i in range(0, len(data), 1):
        char = data[i]
        if char.isalpha() and char.isupper():
            map["upper"] += 1
        elif char.isalpha() and char.islower():
            map["lower"] += 1
        elif char.isdigit():
             map["digits"] += 1
        elif char.isspace():
             map["spaces"] += 1
        else:
             map["special"] += 1


for key, value in map.items():
    print(f'{key.title()} : {value}')
