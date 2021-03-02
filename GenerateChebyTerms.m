function cpxy = GenerateChebyTerms(X,Y,Z,N)

 
    [m,n] = term_gen(N);
    X = X/max(X);
    Y = Y/max(Y);
    Z = Z;
    ChebyMatrixX = zeros(length(X),N);
    ChebyMatrixY = zeros(length(Y),N);
    ChebyMatrixX(:,1) = 1;
    ChebyMatrixY(:,1) = 1;
    ChebyMatrixX(:,2) = X;
    ChebyMatrixY(:,2) = Y;
    
    for i = 1:length(X)
        for j = 3:N
            tempX(:,j) = (2*X.*ChebyMatrixX(:,m(j)+2)-ChebyMatrixX(:,m(j)+1));
            tempY(:,j) = (2*Y.*ChebyMatrixY(:,n(j)+2)-ChebyMatrixY(:,n(j)+1));
          
        
        end
    end
    ChebyMatrix = ChebyMatrixX.*ChebyMatrixY;
    
    coeffs = pinv(ChebyMatrix)*Z;
    
    
end
