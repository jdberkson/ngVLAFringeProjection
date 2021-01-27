function OutMap = CropAperture(InMap,numpix)
    InMaptemp = InMap;
    InMap(~isnan(InMap)) = 1;
    InMap(isnan(InMap)) = 0;
    
    [M,N] = size(InMap);
    mask = InMap;
    tempmaskX = zeros(M,N);
    tempmaskY = zeros(M,N);

    for i = 1:M
        for j = 1:N
            if mask(i,j) == 1
                tempmaskX(i,j+numpix:end) = 1;
                break;
            end
        end
        for j = N:-1:1
            if mask(i,j) == 1
                tempmaskX(i,j-numpix:end) = 0;

                break;
            end
        end
    end
    for j = 1:N
        for i = 1:M
            if mask(i,j) == 1
                tempmaskY(i+numpix:end,j) = 1;
                break;
            end
        end
        for i = M:-1:1
            if mask(i,j) == 1
                tempmaskY(i-numpix:end,j) = 0;

                break;
            end
        end
    end
    newmask = tempmaskX.*tempmaskY;
%     mask(isnan(mask)) = 0;
%     figure; imagesc(mask-newmask)
   
    OutMap = InMaptemp.*newmask; 
    OutMap(OutMap == 0) = NaN;
   
end