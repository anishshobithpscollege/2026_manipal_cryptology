b = int(input("Enter b: "))
m = int(input("Enter modulus m: "))

try:
    inverse = pow(b, -1, m)
    print(f"Inverse of {b} modulo {m} is {inverse} "
          f"(check: {b} * {inverse} mod {m} = {b * inverse % m})")
except ValueError:
    print(f"No inverse of {b} modulo {m} (they are not coprime).")
