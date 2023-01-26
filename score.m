%evaluate the score function for the whole image using x, patch network 
function grad = score(x, net, overlaparr, overlap, psize)
    grad = 0 * x;
    lsize = size(x, 1);
    for i = 1:overlap:lsize-psize+1
        for j = 1:overlap:lsize-psize+1
            Gc = getPatch(x, i, j, psize);
            sV = predict(net, Gc');
            grad = grad + GcT(sV, i, j, psize, lsize);
        end
    end
    grad = -grad;%./overlaparr;
end