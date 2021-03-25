function [coeffs,termXY] = Chebyfit(X,Y,Z,N)
    [m,n]=term_gen(N+1); 
    syms('x','y');
    termx{1}= 1;
    termx{2} = x;
    termy{1} = 1;
    termy{2} = y;
    ChebyMatrix = zeros(N+1,length(X));
    for i = 3:N
        termx{i} = 2*x*termx{i-1}-termx{i-2};
        termy{i} = 2*y*termy{i-1}-termy{i-2};
        termx{i} = simplify(termx{i});
        termy{i} = simplify(termy{i});
    end
    termx = cell2sym(termx);
    termy = cell2sym(termy);
    termXY = termx(m+1).*termy(n+1);
    
    termXY = matlabFunction(termXY(2:end));
    
    ChebyMatrix(1,:) = 1;
    ChebyMatrix(2:end,:) = termXY(X,Y)';
    
    %coeffs = pinv(ChebyMatrix')*Z;
    coeffs = ChebyMatrix'\Z;
    

end