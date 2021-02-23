function Z = ChebySample(X,Y,coeffs,termXY)

    termXY = coeffs(2:end)'.*sym(termXY);
    totalterms = sum(termXY);
    termXY = matlabFunction(totalterms);
    Z = termXY(X,Y)+coeffs(1);

end