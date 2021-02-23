function sag = XYSample(X,Y,coeffs,termXY)

    N = length(coeffs)-1;
    syms('x','y')
    f = (x+y)^(N-1);
    f = expand(f);
    terms = children(f);
    terms = coeffs(2:end)'.*terms;
    totalterms = sum(terms);
    totalterms = matlabFunction(totalterms);
    
    sag = totalterms(X,Y)+coeffs(1);
    


end