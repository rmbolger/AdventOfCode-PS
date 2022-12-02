import sys

def combine(cube, cubes):
    state, ((x1,x2), (y1,y2), (z1,z2)) = cube

    todel = set()
    toadd = set()

    selfadded = False

    for (s1, xx1, xx2, yy1, yy2, zz1, zz2) in cubes:
        # no intersection => no splits
        if not (xx1 <= x2 and x1 <= xx2 and yy1 <= y2 and y1 <= yy2 and zz1 <= z2 and z1 <= zz2):
            continue

        # the common length on X
        nx1 = max(xx1, x1)
        nx2 = min(xx2, x2)

        # the common length on Y
        ny1 = max(yy1, y1)
        ny2 = min(yy2, y2)

        # the common length on Z
        nz1 = max(zz1, z1)
        nz2 = min(zz2, z2)

        todel.add((s1, xx1, xx2, yy1, yy2, zz1, zz2))
        selfadded = True

        # chop off what's outside common X!
        if xx1 < nx1:
            toadd.add((s1, xx1, nx1-1, yy1, yy2, zz1, zz2))

        if nx2 < xx2:
            toadd.add((s1, nx2+1, xx2, yy1, yy2, zz1, zz2))

        # chop off what's outside common Y!
        if yy1 < ny1:
            toadd.add((s1, nx1, nx2, yy1, ny1-1, zz1, zz2))

        if ny2 < yy2:
            toadd.add((s1, nx1, nx2, ny2+1, yy2, zz1, zz2))

        # chop off what's outside common Z!
        if zz1 < nz1:
            toadd.add((s1, nx1, nx2, ny1, ny2, zz1, nz1-1))

        if nz2 < zz2:
            toadd.add((s1, nx1, nx2, ny1, ny2, nz2+1, zz2))

        # we're left with the beautiful common core now <3
        #  (one last trick: make sure to also handle the case
        #     when our cube is fully engulfing the loop cube on each axis!)
        toadd.add((state, min(nx1,x1), max(nx2,x2), min(ny1,y1), max(ny2,y2), min(nz1,z1), max(nz2,z2)))

    for td in todel:
        cubes.remove(td)

    for ta in toadd:
        cubes.add(ta)

    if not selfadded:
        cubes.add((state, x1, x2, y1, y2, z1, z2))

cubes = set()
for step in sys.stdin:
    state, n = step.split()
    v = []
    for x in n.split(","):
        a, b = [int(i) for i in x.split("=")[1].split("..")]
        v.append((a,b))

    combine((state, v), cubes)

p1 = 0
p2 = 0
for state,x1,x2,y1,y2,z1,z2 in cubes:
    if state == 'on':
        for i in range(max(-50, x1), min(50, x2)+1):
            for j in range(max(-50, y1), min(50, y2)+1):
                for k in range(max(-50, z1), min(50, z2)+1):
                    p1 += 1
        p2 += abs(x2-x1+1) * abs(y2-y1+1) * abs(z2-z1+1)
print(p1)
print(p2)
