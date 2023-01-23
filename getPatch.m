%output is a vector that can be fed into a neural network
function Gc = getPatch(image, row, col, psize)
    x = image(row:row+psize-1, col:col+psize-1);
    Gc = reshape(x, psize^2, 1);
end