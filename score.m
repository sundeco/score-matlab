%evaluate the score function for the whole image using x, patch network 
function grad = score(x, net, overlaparr, overlap, psize)
    grad = 0 * x;
    lsize = size(x, 1);
    tot_patches = floor(((lsize - psize) / overlap + 1)) ^ 2;
    stackedarr = zeros(tot_patches, psize^2);
    a = 1;
    for i = 1:overlap:lsize-psize+1
        for j = 1:overlap:lsize-psize+1
            Gc = getPatch(x, i, j, psize);
            stackedarr(a,:) = Gc;
            a = a+1;
        end
    end
    stackedout = predict(net, stackedarr);
    a = 1;
    for i = 1:overlap:lsize-psize+1
        for j = 1:overlap:lsize-psize+1
            sV = stackedout(a,:);
            grad = grad + GcT(sV, i, j, psize, lsize);
            a = a+1;
        end
    end
    grad = -grad;%./overlaparr;
end