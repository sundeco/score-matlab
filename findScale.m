%scales an image affinely to minimize MSE
function output = findScale(X, Y)
    a1 = sum(sum(X.*X));
    a2 = sum(sum(X));
    a3 = a2;
    a4 = numel(X);
    b1 = sum(sum(X.*Y));
    b2 = sum(sum(Y));
    rhs = [a1 a2; a3 a4];
    lhs = [b1; b2];
    out = rhs\lhs;
    const = out(2);
    lin = out(1);
    output = lin*X + const;
end