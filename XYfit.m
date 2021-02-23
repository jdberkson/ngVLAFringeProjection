function coeffs = XYfit(X,Y,Z,N)

    syms('x','y')
    f = (x+y)^(N-1);
    f = expand(f);

    terms = children(f);
    terms = matlabFunction(terms);
    XYMatrix = zeros(length(X),N+1);
    XYMatrix(:,1) = 1;
    XYMatrix(:,2:end) = terms(X,Y);
    
    coeffs = pinv(XYMatrix)*Z;

    
    
end