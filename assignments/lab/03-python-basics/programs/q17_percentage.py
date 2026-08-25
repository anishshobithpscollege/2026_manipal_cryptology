from collections import defaultdict

text = "CRYPTOLOGYISINTERESTING"
total = len(text)

frequency = defaultdict(int)
for character in text:
    frequency[character] += 1

for character, count in frequency.items():
    percentage = count / total * 100
    print(f"{character} : {count} ({percentage:.2f}%)")
