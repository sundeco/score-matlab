function GcT = GcT(myvec, row, col, psize, imsize)
    GcT = zeros(imsize, imsize);
    GcT(row:row+psize-1, col:col+psize-1) = reshape(myvec, psize, psize);
end