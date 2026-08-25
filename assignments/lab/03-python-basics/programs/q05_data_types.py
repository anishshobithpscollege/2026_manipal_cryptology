an_int = 42
a_float = 3.14
a_complex = 2 + 3j
a_str = "Cryptology"
a_list = [2, 3, 5, 7, 11]
a_tuple = (1, 2, 3)
a_set = {1, 2, 3}
a_dict = {"cipher": "AES", "bits": 256}

variables = [
    ("int", an_int),
    ("float", a_float),
    ("complex", a_complex),
    ("str", a_str),
    ("list", a_list),
    ("tuple", a_tuple),
    ("set", a_set),
    ("dict", a_dict),
]

for name, value in variables:
    print(f"{name} : {value!r} {type(value)}")
