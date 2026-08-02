using ExtendableGrids
using GridVisualize
using Triangulate: Triangulate, TriangulateIO, triangulate
using Printf
using CairoMakie


function make_spiral(lpn)
    sp = [[0,0]]
    for i in 1:lpn
        j=-i+1
        while j<i
            push!(sp, [i,j])
            j+=1
        end
        while j>=-i
            push!(sp, [j,i])
            j-=1
        end
        j=i-1
        while j>-i
            push!(sp, [-i,j])
            j-=1
        end
        while j<=i
            push!(sp, [j,-i])
            j+=1
        end
    end
    return sp
end

function make_grid(lpn)
    grid = [[['b','r'] for i in -lpn:lpn] for j in -lpn:lpn]
    return grid
end

function getAttacked(space, lpn)
    lim=2*lpn+1
    a=space[1]
    b=space[2]
    out = [space, [a-2,b-1], [a-2,b+1],[a-1,b-2],[a-1,b+2],[a+1,b-2],[a+1,b+2],[a+2,b-1],[a+2,b+1]]
    i=length(out)
    while i>1
        if out[i][1]<1 || out[i][2]<1 || out[i][1]>lim || out[i][2]>lim
            deleteat!(out,i)
        end
        i-=1
    end
    return out
end

function placeBlack(gr,sp, lpn)
    n=1
    while n <= length(sp)
        i=sp[n]
        a=i[1]+lpn+1
        b=i[2]+lpn+1
        val = gr[a][b]
        if val == []
            deleteat!(sp,n)
        elseif 'b' in val
            for j in getAttacked([a,b],lpn)
                if 'r' in gr[j[1]][j[2]]
                    pop!(gr[j[1]][j[2]])
                end
            end
            deleteat!(sp,n)
	        break
        else
	    n+=1
	end
    end
end

function placeRed(gr,sp, lpn)
    n=1
    while n <= length(sp)
        i=sp[n]
        a=i[1]+lpn+1
        b=i[2]+lpn+1
        val = gr[a][b]
        if val==[]
            deleteat!(sp,n)
        elseif 'r' in val
            for j in getAttacked([a,b],lpn) 
                if 'b' in gr[j[1]][j[2]]
                    popfirst!(gr[j[1]][j[2]])
                end
            end
            deleteat!(sp,n)
	        break
        else
	    n+=1
	end
    end
end

function fill(gr,sp,lpn)
    black = true
    while length(sp)>0
        if black
            placeBlack(gr,sp,lpn)
            black=false
        else
            placeRed(gr,sp,lpn)
            black=true
        end
    end
end

function construct(lpn)
    sp = make_spiral(lpn)
    grid = make_grid(lpn)
    fill(grid, sp, lpn)
    return grid
end


out_grid = construct(5)

colour_map = Dict(
    [] => RGBf(1,1,1),
    ['b'] => RGBf(0,0,0),
    ['r'] => RGBf(1,0,0)
)

img = [colour_map[out_grid[i][j]] for i in 1:length(out_grid), j in 1:length(out_grid)]

image(img)

a=[1,2,3]
println(a[1:2])
