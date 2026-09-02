with open("cryptology.txt", "r") as file:
    data = file.read().upper()


with open("normalized.txt", "w") as file2:
    file2.write(data)
