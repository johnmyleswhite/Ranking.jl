invlogit(z::Real) = 1 / (1 + exp(-clamp(z, -709, 709)))

function translateDtoG(D::Matrix)
	N = size(D, 1)
    G = Array(Float64, 0, 2)
    for i in 1:N
    	if D[i, 3] == 0.0
    		G = vcat(G, [D[i, 2] D[i, 1]])
    	elseif D[i, 3] == 1.0
    		G = vcat(G, [D[i, 1] D[i, 2]])
    	else # D[i, 3] == 0.5
    		G = vcat(G, [D[i, 1] D[i, 2]])
    		G = vcat(G, [D[i, 2] D[i, 1]])
	    end
    end
    return G
end
