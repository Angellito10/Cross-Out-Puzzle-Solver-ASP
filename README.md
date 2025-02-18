# Cross-Out-Puzzle-Solver-ASP
Cross-Out is a puzzle where you’re given a grid of symbols. Your task is to “cross out” certain cells so that:

Below is a **more explanatory** and **detailed** `README.md` that follows a style similar to the example you shared (about Yao’s Garbled Circuit). It expands on the **Cross-Out Puzzle** concept, **objectives**, **constraints**, **logic flow**, and **implementation details**. You can copy and paste this directly into your GitHub repository.

---

# Cross-Out Puzzle Solver

> **Author:** Your Name  
> **Date:** YYYY-MM-DD  

---

## Table of Contents

1. [Project Overview](#project-overview)  
2. [Objective](#objective)  
3. [Puzzle Explanation](#puzzle-explanation)  
4. [Constraints and Logic Flow](#constraints-and-logic-flow)  
5. [Implementation Details](#implementation-details)  
6. [ASP Code Explanation](#asp-code-explanation)  
7. [Visualization Script Explanation](#visualization-script-explanation)  
8. [Running the Solver and Visualizer](#running-the-solver-and-visualizer)  
9. [Ethical Considerations](#ethical-considerations)  
10. [Conclusion](#conclusion)  
11. [License](#license)  
12. [Contact](#contact)

---

## Project Overview

This project implements an **automated Cross-Out Puzzle solver** using **Answer Set Programming (ASP)**. A Cross-Out Puzzle provides a rectangular grid of symbols, where some cells must be “crossed out” to satisfy certain **logical and connectivity constraints**. 

This repository:
- Leverages **Clingo** (an ASP solver) to perform the puzzle-solving.
- Includes a **Python script** for visualizing the solver’s output in a human-readable grid.
- Demonstrates how **declarative constraints** can elegantly solve complex combinatorial puzzles.

---

## Objective

The primary objective is to:
1. **Determine** which cells in a grid should be crossed out so that:
   - **No symbol repeats** in any row or column among the active (non-crossed-out) cells.
   - **No two crossed-out cells** are adjacent (horizontally or vertically).
   - **All non-crossed-out cells** form a **single connected region** via vertical/horizontal moves.
2. **Provide** an easily modifiable solution where:
   - The **grid** (puzzle input) can be changed by editing `cell/3` facts.
   - The **constraints** remain consistent, ensuring the puzzle is solved automatically.

---

## Puzzle Explanation

### Inputs and Outputs

- **Puzzle Input:** A set of `cell(Row, Column, "Symbol")` facts that define a rectangular grid.
- **Solver Output:** 
  - A set of `crossedout(Row, Column, "Symbol")` facts indicating which cells should be crossed out.
  - The remaining cells (not crossed out) represent the final, valid configuration.

### Example Grid (5×5)

Consider the following puzzle:

```
c  e  b  b  c
b  e  a  d  e
a  d  a  c  e
c  a  b  e  c
e  b  a  a  a
```

Each cell is encoded as:

```
cell(1,1,"c"). cell(1,2,"e"). cell(1,3,"b"). cell(1,4,"b"). cell(1,5,"c").
cell(2,1,"b"). cell(2,2,"e"). cell(2,3,"a"). cell(2,4,"d"). cell(2,5,"e").
cell(3,1,"a"). cell(3,2,"d"). cell(3,3,"a"). cell(3,4,"c"). cell(3,5,"e").
cell(4,1,"c"). cell(4,2,"a"). cell(4,3,"b"). cell(4,4,"e"). cell(4,5,"c").
cell(5,1,"e"). cell(5,2,"b"). cell(5,3,"a"). cell(5,4,"a"). cell(5,5,"a").
```

---

## Constraints and Logic Flow

1. **Unique Symbols in Rows and Columns**  
   - For any two cells in the same row or column, **only one** can remain active if they share the same symbol.
   - Crossed-out cells are “ignored” in this uniqueness check.

2. **No Adjacent Cross-Outs**  
   - A crossed-out cell cannot have a neighbor (up, down, left, or right) that is also crossed out.
   - This ensures scattered or isolated crosses, preventing clusters of crossed cells.

3. **Contiguous Non-Crossed-Out Region**  
   - After deciding which cells to cross out, the remaining (active) cells must form a single connected component.
   - We use a **root selection** and **reachability** propagation to ensure there is exactly one contiguous area.

### Detailed Logic Flow

1. **Symbol Check**  
   The solver looks at each row and column. If two cells share the same symbol, **not both** can remain uncrossed.  
2. **Cross-Out Adjacency Check**  
   A neighbor relation is established (only horizontal/vertical). Any pair of neighbors **cannot** both be crossed out.  
3. **Connectivity Enforcement**  
   - The solver picks **one** non-crossed cell as a “root” (using a deterministic `#min` approach).  
   - It recursively marks all neighboring non-crossed cells as reachable.  
   - Any cell that remains non-crossed but is **not** reachable from the root is disallowed.

---

## Implementation Details

1. **Answer Set Programming (ASP):**  
   - **Choice Rule**: Nondeterministically guess which cells to cross out.  
   - **Constraints**: Enforce row/column uniqueness, no adjacent crosses, and connectivity.

2. **Optimization & Determinism:**  
   - We define adjacency **minimally** (only to the right and down), then add a **symmetry** rule.  
   - We use a **deterministic** root selection to avoid multiple solutions differing only by the choice of “seed.”

3. **Visualization:**  
   - The solver’s output is written to `output.txt`.  
   - A Python script (`visual.py`) parses the `cell/3` and `crossedout/3` facts, then prints the grid with “X” for crossed-out cells.

---

## ASP Code Explanation

The **`ASP_puzzle.lp`** file combines **puzzle facts** (the grid) and the **constraint logic**:

```prolog
% (1) Example Puzzle (5x5)
cell(1,1,"c"). cell(1,2,"e"). cell(1,3,"b"). cell(1,4,"b"). cell(1,5,"c").
cell(2,1,"b"). cell(2,2,"e"). cell(2,3,"a"). cell(2,4,"d"). cell(2,5,"e").
cell(3,1,"a"). cell(3,2,"d"). cell(3,3,"a"). cell(3,4,"c"). cell(3,5,"e").
cell(4,1,"c"). cell(4,2,"a"). cell(4,3,"b"). cell(4,4,"e"). cell(4,5,"c").
cell(5,1,"e"). cell(5,2,"b"). cell(5,3,"a"). cell(5,4,"a"). cell(5,5,"a").

% (2) Choice Rule
{ crossedout(R, C, S) } :- cell(R, C, S).

% (3) Uniqueness
:- cell(R, C1, S), cell(R, C2, S), C1 < C2, not crossedout(R, C1, S), not crossedout(R, C2, S).
:- cell(R1, C, S), cell(R2, C, S), R1 < R2, not crossedout(R1, C, S), not crossedout(R2, C, S).

% (4) No Adjacent Cross-Outs
adjacent(R, C, R, C+1) :- cell(R, C, _), cell(R, C+1, _).  % Right
adjacent(R, C, R+1, C) :- cell(R, C, _), cell(R+1, C, _).  % Down
adjacent(R, C, R1, C1) :- adjacent(R1, C1, R, C).          % Symmetry
:- crossedout(R, C, _), crossedout(Rn, Cn, _), adjacent(R, C, Rn, Cn).

% (5) Connectivity
root(X, Y) :- cell(X, Y, _), not crossedout(X, Y, _),
              #min { (X1, Y1) : cell(X1, Y1, _), not crossedout(X1, Y1, _) } = (X, Y).

reachable(X, Y) :- root(X, Y).
reachable(Xn, Yn) :- reachable(X, Y), adjacent(X, Y, Xn, Yn), not crossedout(Xn, Yn, _).

:- cell(X, Y, _), not crossedout(X, Y, _), not reachable(X, Y).

% (6) Optional: Force At Least One Cross-Out
% :- { crossedout(_, _, _) } = 0.

% (7) Output
#show cell/3.
#show crossedout/3.
```

---

## Visualization Script Explanation

The **`visual.py`** script reads the solver output (`output.txt`) and prints the puzzle:

```python
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
```

- **Regex** is used to capture `cell(...)` and `crossedout(...)` facts.  
- The grid is then **reconstructed** and displayed with `X` in crossed-out cells.

---

## Running the Solver and Visualizer

1. **Install Clingo**  
   If you haven’t installed Clingo, download it from [Potassco Releases](https://github.com/potassco/clingo/releases) or build from source.

2. **Run Clingo**  
   ```bash
   clingo ASP_puzzle.lp -n 0 > output.txt
   ```
   - `-n 0` computes all solutions. Deterministic root selection typically yields one solution per crossing pattern.

3. **Visualize**  
   ```bash
   python3 visual.py
   ```
   - The script reads `output.txt` and prints the puzzle, with crossed-out cells marked as “X.”

4. **Validation**  
   - Check that no symbol repeats in a row/column ignoring X’s.  
   - Ensure that no two X’s are adjacent.  
   - Confirm that all remaining cells are connected in a single region.

---

## Ethical Considerations

While this puzzle solver is recreational, the underlying **constraint-solving** methods have broad applicability, including:

1. **Dual-Use Technology**  
   Similar optimization techniques can be repurposed for scheduling, logistics, or military planning.

2. **Human Oversight**  
   In high-stakes scenarios, ensuring a human-in-the-loop can prevent harmful or unintended consequences.

3. **Transparency & Accountability**  
   Systems using advanced AI/ASP methods should document how decisions are made to facilitate audits and ethical reviews.

4. **Responsible Innovation**  
   Even academic tools can have societal impacts if adapted for real-world, mission-critical tasks. Researchers and developers must consider ethical implications.

---

## Conclusion

This **Cross-Out Puzzle Solver** demonstrates how **ASP** can elegantly address constraint satisfaction problems with minimal, declarative code. Key features include:

- **Deterministic** root selection to avoid duplicate solutions.  
- **Minimal adjacency** definition to reduce redundant facts.  
- **Optional** constraint to force at least one cross-out.  
- A **visualization script** that clarifies the solver’s output.

Whether you are exploring ASP for fun puzzles or more serious applications, this repository provides a solid foundation for further development and experimentation.

---

## License

This project is released under the [MIT License](LICENSE) (or choose your own license). You are free to use, modify, and distribute the code for academic or personal projects. For commercial or other uses, please review the license terms or contact the author.

---

## Contact

- **Author**: Your Name or Organization  
- **Email**: [Your Email Address]  
- **GitHub**: [Your GitHub Profile URL]  

Feel free to open an issue or pull request if you have ideas for improvement, or email me directly for questions and collaborations.

---

**Happy Puzzling with ASP!**
