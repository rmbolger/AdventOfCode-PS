#!/usr/bin/env python3
"""Advent of Code"""

from __future__ import print_function
from copy import deepcopy

DIRS = [
    (1, 0),
    (-1, 0),
    (0, 1),
    (0, -1),
    (1, 1),
    (1, -1),
    (-1, 1),
    (-1, -1)
]

def occupied():
    return sum(l[r][c] == "#" for r in range(m) for c in range(n))

def evolve(threshold=4):
    for r in range(m):
        for c in range(n):
            o = adjacent(r, c)
            if l[r][c] == "L" and o == 0:
                lnew[r][c] = "#"
            elif l[r][c] == "#" and o >= threshold:
                lnew[r][c] = "L"

# Part 1

# def adjacent(row, col):
#     out = 0
#     for x, y in DIRS:
#         r, c = row + x, col + y
#         if not (0 <= r < m and 0 <= c <n):
#             continue
#         out += l[r][c] == "#"
#     return out

# with open("d11.txt") as f:
#     l = list(map(list, f.read().splitlines()))
# m, n = len(l), len(l[0])
# old = -1
# while old != (k:=occupied()):
#     old = k
#     lnew = deepcopy(l)
#     evolve()
#     l = lnew

# print(k)

# Part 2
def adjacent(row, col):
    out = 0
    for x, y in DIRS:
        r, c = row + x, col + y
        while (valid:=(0 <= r < m and 0 <= c < n)) and l[r][c] == ".":
            r, c = r + x, c + y
        if valid and l[r][c] == "#":
            out += 1
    return out

with open("d11.txt") as f:
    l = list(map(list, f.read().splitlines()))
m, n = len(l), len(l[0])
old = -1
while old != (k:=occupied()):
    old = k
    lnew = deepcopy(l)
    evolve(5)
    l = lnew
print(k)
