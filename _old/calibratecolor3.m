% M 
function [M, M_scaled, transformMAtrix1, transformMAtrix2]  = calibratecolor3(P,Q)
    % M: matrix that minimizes the least squares calculation (3x3)
    % M: calculated with inverse penrose; 
    % M_scaled: all elements divided by sum(M(2,:)), 
    % as suggested in Bastani et all
    % result is 3x3 matrix (equivalent to Px = Q)
    %transformation_Matrix_0 is a 3x1 vect, M calculated from invers
    %transformation_Matrix_2 is a 3x1 vect, with M scaled 
   %
    %M =  Q*P'*(inv(P*P'));
    
    M = P\Q;
    
    E_M = zeros(size(P*M));
     
    for i=1:length(P) % E_m IS 3X1 column vector
        E_M = E_M + ( (abs(P(i,:)*M-Q(i,:))).^2 );
    end

    
    E_M = E_M./sum(E_M(2));
    
    transformMAtrix1 = E_M; %first result
    
    %% 2nd calculation
    %E_M = zeros(size(M*P(:,1)));
    E_M = zeros(size(P*M));
    
    M_scaled = M./(sum(M(2,:)));

    for i=1:length(P) % E_m IS 3X1 column vector
        E_M = E_M + ( (abs(P(i,:)*M-Q(i,:))).^2 );
    end
    
    transformMAtrix2 = E_M; % now scaled
end