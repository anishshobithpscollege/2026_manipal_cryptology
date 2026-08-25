text = "PYTHON"
original = text
text = text + "3"
print("String now :", text)
print("Same object as before :", id(text) == id(original))

numbers = [1, 2, 3]
alias = numbers
numbers.append(4)
print("List now :", numbers)
print("Same object as before :", id(numbers) == id(alias))
