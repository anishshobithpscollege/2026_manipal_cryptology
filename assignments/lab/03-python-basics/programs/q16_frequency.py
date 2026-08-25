from collections import defaultdict

text = "CRYPTOLOGYISINTERESTING"

frequency = defaultdict(int)
for character in text:
    frequency[character] += 1

for character, count in frequency.items():
    print(character, ":", count)

most_common = max(frequency, key=frequency.get)
print("Most frequent :", most_common, f"({frequency[most_common]} times)")
