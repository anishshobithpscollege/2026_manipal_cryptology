import secrets

SMALL_PRIMES = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)


def is_prime(n, rounds=40):
    if n < 2:
        return False
    for p in SMALL_PRIMES:
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for _ in range(rounds):
        x = pow(secrets.randbelow(n - 3) + 2, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def generate_prime(bits):
    while True:
        n = secrets.randbits(bits) | (1 << (bits - 1)) | 1
        if is_prime(n):
            return n


def read_int(prompt, lo=None, hi=None):
    while True:
        try:
            n = int(input(prompt).strip())
        except ValueError:
            print("Error: enter a whole number.")
            continue
        if (lo is not None and n < lo) or (hi is not None and n > hi):
            print(f"Error: value must be between {lo} and {hi}.")
            continue
        return n


def read_prime(prompt, lo=2):
    while True:
        n = read_int(prompt, lo)
        if is_prime(n):
            return n
        print(f"Error: {n} is not prime.")


def read_choice(prompt, options):
    while True:
        c = input(prompt).strip().lower()
        if c in options:
            return c
        print(f"Error: choose one of {', '.join(options)}.")
