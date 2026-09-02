with open("cryptology.txt", "r") as file:
    for i, line in enumerate(file):
        print(f'{i + 1}.', line, end="")
