with open('cryptology_no.txt', 'r', encoding='utf-8') as file:
    for line_num, line in enumerate(file, start=1):
        if line.isalpha():
            print(f"Line {line_num}: {line}")
