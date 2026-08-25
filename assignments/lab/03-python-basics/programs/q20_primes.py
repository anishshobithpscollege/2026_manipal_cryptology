def is_prime(n):
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


number = int(input("Enter a number to test: "))
print(number, "is prime" if is_prime(number) else "is not prime")

low = int(input("Range start: "))
high = int(input("Range end: "))
primes = [n for n in range(low, high + 1) if is_prime(n)]
print(f"Primes in [{low}, {high}] : {primes}")
