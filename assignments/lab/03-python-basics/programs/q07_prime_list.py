def is_prime(n):
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


def primes_from(start, count):
    found = []
    n = start
    while len(found) < count:
        if is_prime(n):
            found.append(n)
        n += 1
    return found


primes = primes_from(2, 5)
print("List :", primes)
print("First three :", primes[:3])
print("Last element :", primes[-1])

primes.append(primes_from(primes[-1] + 1, 1)[0])
print("After append :", primes)

primes.extend(primes_from(primes[-1] + 1, 2))
print("After extend :", primes)

print("Total elements :", len(primes))
