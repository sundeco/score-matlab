function overlaparr = getDivision(lsize, psize, overlap)
    overlaparr = zeros(lsize, lsize);
    for i = 1:overlap:lsize-psize+1
        for j = 1:overlap:lsize-psize+1
            bruh = zeros(lsize, lsize);
            bruh(i:i+psize-1, j:j+psize-1) = 1;
            overlaparr = overlaparr + bruh;
        end
    end
    for i = 1:lsize
        for j = 1:lsize
            if overlaparr(i,j) == 0
                overlaparr(i,j) = 1;
            end
        end
    end
end