with open("cryptology.txt", "r") as file, open("cryptology_no.txt", "w") as file_no:
    for i, line in enumerate(file, start=1):
        file_no.write(f'{i}. {line}')
