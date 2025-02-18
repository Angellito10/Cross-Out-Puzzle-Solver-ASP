import re

with open("output.txt") as f:
    data = f.read()

cell_facts = re.findall(r'cell\((\d+),(\d+),"([^"]+)"\)', data)
crossed_facts = re.findall(r'crossedout\((\d+),(\d+),"([^"]+)"\)', data)

if not cell_facts:
    print("No cell facts found. Please ensure the ASP output includes cell/3 facts.")
    exit(1)

rows = max(int(r) for (r, c, s) in cell_facts)
cols = max(int(c) for (r, c, s) in cell_facts)

grid = {}
for (r, c, s) in cell_facts:
    grid[(int(r), int(c))] = s

crossed = {(int(r), int(c)) for (r, c, s) in crossed_facts}

print("Visualized Grid (X marks a crossed-out cell):")
for i in range(1, rows+1):
    row_str = ""
    for j in range(1, cols+1):
        if (i, j) in crossed:
            row_str += " X "
        else:
            row_str += f" {grid[(i, j)]} "
    print(row_str)

