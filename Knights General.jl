using ExtendableGrids
using GridVisualize
using Triangulate: Triangulate, TriangulateIO, triangulate
using Printf
using CairoMakie

colcode = ['n','r','g','b','y']

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

function make_grid(lpn; n=2)
    cols = colcode[1:n]
    grid = [[copy(cols) for i in -lpn:lpn] for j in -lpn:lpn]
    return grid
end

Knight(a,b) = [[a,b], [a-2,b-1], [a-2,b+1],[a-1,b-2],[a-1,b+2],[a+1,b-2],[a+1,b+2],[a+2,b-1],[a+2,b+1]]

function getAttacked(space, lpn; func=Knight)
    lim=2*lpn+1
    a=space[1]
    b=space[2]
    out = func(a,b)
    i=length(out)
    while i>1
        if out[i][1]<1 || out[i][2]<1 || out[i][1]>lim || out[i][2]>lim
            deleteat!(out,i)
        end
        i-=1
    end
    return out
end

function attack(gr, spacei, spacej, col)
    val = gr[spacei][spacej]
    if length(val)==0 || isuppercase(val[1])
        return
    end
    i=1
    while i<=length(val)
        if val[i] != col
            deleteat!(val, i)
        else
            i+=1
        end
    end
    gr[spacei][spacej]=val
end

function placeBlack2(gr,sp, lpn; sym=false, func=Knight)
    n=1
    while n <= length(sp)
        i=sp[n]
        a=i[1]+lpn+1
        b=i[2]+lpn+1
        val = gr[a][b]
        if val == [] || (!sym && isuppercase(val[1]))
            deleteat!(sp,n)
        elseif 'n' in val
            for j in getAttacked([a,b],lpn; func)
                if 'r' in gr[j[1]][j[2]]
                    pop!(gr[j[1]][j[2]])
                end
            end
            if !sym
                gr[a][b]=['N']
            end
            deleteat!(sp,n)
	        break
        else
	    n+=1
	end
    end
end

function placeRed2(gr,sp, lpn; sym=false, func=Knight)
    n=1
    while n <= length(sp)
        i=sp[n]
        a=i[1]+lpn+1
        b=i[2]+lpn+1
        val = gr[a][b]
        if val==[] || (!sym && isuppercase(val[1]))
            deleteat!(sp,n)
        elseif 'r' in val
            for j in getAttacked([a,b],lpn; func) 
                if 'n' in gr[j[1]][j[2]]
                    popfirst!(gr[j[1]][j[2]])
                end
            end
            if !sym
                gr[a][b]=['R']
            end
            deleteat!(sp,n)
	        break
        else
	    n+=1
	end
    end
end

function placecol(gr,sp, lpn, col; sym=false, func=Knight)
    n=1
    while n <= length(sp)
        i=sp[n]
        a=i[1]+lpn+1
        b=i[2]+lpn+1
        val = gr[a][b]
        if val == [] || (!sym && isuppercase(val[1]))
            deleteat!(sp,n)
        elseif col in val
            for j in getAttacked([a,b],lpn; func)
                attack(gr,j[1],j[2], col)
            end
            if !sym
                gr[a][b]=[uppercase(col)]
            end
            deleteat!(sp,n)
	        break
        else
	    n+=1
	    end
    end
end


function fill(gr,sp,lpn; no=2, sym=false, funcs=[Knight for i in 1:no])
    if no==2
        black = true
        while length(sp)>0
            if black
                placeBlack2(gr,sp,lpn; sym, func=funcs[1])
                black=false
            else
                placeRed2(gr,sp,lpn; sym, func= funcs[2])
                black=true
            end
        end
    else
        cols = colcode[1:no]
        n=1
        while length(sp)>0
            placecol(gr, sp, lpn, cols[n]; sym, func=funcs[n])
            n+=1
            if n>no
                n=1
            end
        end
    end
end

function construct(lpn; no=2, sym=false, funcs=[Knight for i in 1:no])
    sp = make_spiral(lpn)
    grid = make_grid(lpn; n=no)
    fill(grid, sp, lpn; no, sym, funcs)
    return grid
end




sym_colour_map = Dict(
    [] => RGBf(1,1,1),
    ['n']  => RGBf(0,0,0),
    ['r']  => RGBf(1,0,0),
    ['g']  => RGBf(0,1,0),
    ['b']  => RGBf(0,0,1),
    ['y']  => RGBf(1,1,0)
)

colour_map = Dict(
    [] => RGBf(1,1,1),
    ['N']  => RGBf(0,0,0),
    ['R']  => RGBf(1,0,0),
    ['G']  => RGBf(0,1,0),
    ['B']  => RGBf(0,0,1),
    ['Y']  => RGBf(1,1,0)
)

function creategrid(gr; sym=false)
    if sym
        img = [sym_colour_map[out_grid[i][j]] for i in 1:length(out_grid), j in 1:length(out_grid)]
    else
        img = [colour_map[out_grid[i][j]] for i in 1:length(out_grid), j in 1:length(out_grid)]
    end
    image(img)
end

Drider(a,b) =  [[a,b], [a-2,b-1],[a-2,b], [a-2,b+1],[a-1,b-2],[a-1,b+2],[a,b-2],[a,b+2],[a+1,b-2],[a+1,b+2],[a+2,b-1],[a+2,b],[a+2,b+1]]
lDrider(a,b) =  [[a,b], [a-2,b-1],[a-2,b],[a-1,b+2],[a,b-2],[a,b+2],[a+1,b-2],[a+2,b],[a+2,b+1]]
rDrider(a,b) =  [[a,b], [a-2,b], [a-2,b+1],[a-1,b-2],[a,b-2],[a,b+2],[a+1,b+2],[a+2,b-1],[a+2,b]]
king(a,b) = [[a,b],[a-1,b-1],[a-1,b],[a-1,b+1],[a,b-1],[a,b+1],[a+1,b-1],[a+1,b],[a+1,b+1]]
lKnight(a,b) = [[a,b], [a-2,b-1], [a-1,b+2],[a+1,b-2],[a+2,b+1]]
rKnight(a,b) = [[a,b], [a-2,b+1], [a-1,b-2],[a+1,b+2],[a+2,b-1]]
wall(a,b) = [[a,b], [a-2,b-2], [a-2,b-1], [a-2,b+1],[a-2,b+2],[a-1,b-2],[a-1,b+2],[a+1,b-2],[a+1,b+2],[a+2,b-2],[a+2,b-1],[a+2,b+1],[a+2,b+2]]
sKnight(a,b) = [[a,b],[a-1,b+2],[a+1,b+2]]
silver(a,b) = [[a,b],[a-1,b-1],[a-1,b+1],[a,b+1],[a+1,b-1],[a+1,b+1]]
gold(a,b) = [[a,b],[a-1,b],[a-1,b+1],[a,b-1],[a,b+1],[a+1,b],[a+1,b+1]]




out_grid = construct(300;no=3, sym=true, funcs=[lDrider,rDrider,lDrider,gold,gold])
creategrid(out_grid; sym=true)


#Noted
#[Knight, wall, wall]
#[wall,knight, knight]
#[wall,Knight, sKnight]
#[wall,sKnight, Knight]
#[wall, sKnight, wall]
#[wall, silver, gold]
#[sKnight, wall, Knight]
#[Knight, sKnight, wall]
#[Knight, gold, wall]
#[Lknight, lKnight]
#[sKnight, lKnight, lKnight]
#[silver, sKnight, lKnight]
#[silver,silver,lKnight]
#[gold, silver, lKnight]
#[Knight, lKnight, sKnight]
#[rKnight, Knight, lKnight], [rKnight,lKnight,Knight]