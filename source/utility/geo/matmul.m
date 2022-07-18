%% multiply matrix
function C = matmul(tr, n, k, m, alpha, A, B, beta)
for i=1:n
    for j=1:k
        d=0.0;
        switch tr
            case "NN"
                for x=1:m
                    d = d+A(i,x)*B(x,j);
                end
            case "NT" 
                for x=1:m
                    d = d+A(i,x)*B(j,x);
                end
            case "TN" 
                for x =1:m
                    d = d+A(x,i)*B(x,j);
                end
            case "TT" 
                for x=1:m
                    d = d + A(x,i)*B(j,x);
                end
        end
        
        if beta==0.0 
            C(i,j)=alpha*d;
        else
            C(i,j)=alpha*d+beta*C(i,j);
        end
    end
end
end