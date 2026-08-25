import math

a = int(input("Enter the first integer: "))
b = int(input("Enter the second integer: "))

g = math.gcd(a, b)
print(f"gcd({a}, {b}) = {g}")
print("Coprime" if g == 1 else "Not coprime")
