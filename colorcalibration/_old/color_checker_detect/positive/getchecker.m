horz = [56 168 258 369 474 572];
vert = [84 188 299 407];
A = 0;
A = [vert(1) horz(1)]
for i=2:length(horz)
    A = [A; vert(1) horz(i)]
end



for j=2:length(vert)
    for i=1:length(horz)
        A = [A; vert(j) horz(i)]
    end
end
macbeth_checker_positions = A;
save('macbeth_checker_positions','macbeth_checker_positions');