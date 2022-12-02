from collections import defaultdict
neighbours = defaultdict(list)

for line in open(0):
    a, b = line.strip().split('-')
    neighbours[a] += [b]
    neighbours[b] += [a]

def search(part, seen=set(), cave='start'):
    if cave == 'end': return 1
    if cave in seen:
        if cave == 'start': return 0
        if cave.islower():
            if part == 1: return 0
            else: part = 1

    return sum(search(part, seen|{cave}, n)
                 for n in neighbours[cave])

print(search(part=1), search(part=2))
