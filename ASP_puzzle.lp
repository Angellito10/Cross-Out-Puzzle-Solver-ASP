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

