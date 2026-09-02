print("Enter Statements : ")

arr = []

while len(arr) < 5:
    line = input(f"Enter statement {len(arr) + 1} of 5: ").strip()
    if line:
        arr.append(line)
    else:
        print("Error: Statement cannot be blank. Please try again.")

with open('cryptology.txt', "w") as file:
    file.write('\n'.join(arr))
