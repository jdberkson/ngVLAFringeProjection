function [Phi, Mod] = Equal_step(Im)
% Equal step phase shifting algorithm
Phi_t1 = zeros(size(Im,1),size(Im,2));
Phi_t2 = zeros(size(Im,1),size(Im,2));
nstep = size(Im,3);
for k = 1:nstep
    Phi_t1 = Phi_t1+Im(:,:,k)*sin(2*pi*k/nstep);
    Phi_t2 = Phi_t2+Im(:,:,k)*cos(2*pi*k/nstep);
end
%Create Phase Step Array
Phi = atan2(Phi_t1,Phi_t2);
Mod = sqrt(Phi_t1.^2+Phi_t2.^2);
end