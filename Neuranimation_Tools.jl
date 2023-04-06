import Base.+
function +(a::Float64, b::Observable)
    # float + observable
    lift(s->a.+b[],t)
end

function +(a::Array{Float64}, b::Observable)
    # float array + observable
    lift(s->a.+b[],t)
end

function +(a::Observable, b::Observable)
    # observable + observable
    lift(s->a[].+b[],t)
end

function +(p::Point{2,Float32}, verts::Observable{Vector{Point{2, Float32}}})
    # point + observable vertices
    lift(s->[p + v for v in verts[]],t)
end

function +(p::Observable{Point{2,Float32}}, verts::Observable{Vector{Point{2, Float32}}})
    # observable point + observable vertices
    lift(s->[p[] + v for v in verts[]],t)
end

function +(p::Point{2,Float32}, q::Observable{Point{2, Float32}})
    # observable point + observable vertices
    lift(s->p+q[],t)
end

import Base.*
function *(a::Float64, b::Observable)
    lift(s->a*b[],t)
end

# animation utilities
function move(verts::Observable{Vector{Point{2, Float32}}}, p::Point{2,Float32})
    # returns shifted vertices (not updated observable)
    (p + verts)[]
end



mutable struct Component
    # parent of root component is nothing (of type Nothing)
    # root component moves in Axis frame, other components move in their parent frame
    # Component is invisible if its colour is nothing
    name:: String
    parent::Union{Component, Nothing} 
    child::Vector{Component}
    vertex::Vector{Point{2, Float32}}
    restpos::Vector{Point{2, Float32}}      # rest/default location in parent frame (can be per state)
    pos::Observable{Point{2, Float32}}      # current location in parent frame
    Θ::Float32  # rotation
    R::Float32  # scale
    state::Int64  # countable states  
    param::Vector{Float64}
    colour::Union{RGB{Float64}, RGBA{Float64}, Symbol, Nothing}
end

# default constructor
# invisible object at origin 
# in state 1
function Component(name::String)
    Component(  name,
                nothing,
                [],
                [Point2f(0.0,0.0)],
                [Point2f(0.0, 0.0)],
                Observable(Point2f(0.0, 0.0)),
                0.0,
                1.0,
                1,
                [],
                nothing
                )
end


function draw(ax::Axis, component::Component)
    # draw component and its children
    if !(component.colour==nothing)
        poly!(ax, lift(s->[component.pos[]].+component.vertex, t), color = component.colour)
    end
    for child in component.child
        draw(ax, child)
    end
end

# function drawjitter(ax::Axis, component::Component, dx::Float64, dy::Float64)
#     # draw component and its children
#     if !(component.colour==nothing)
#         handle = poly!(ax, lift(s->[component.pos[]+Point2f(dx*randn(), dy*randn())].+component.vertex, t), color = component.colour)
#     end
#     for child in component.child
#         draw(ax, child)
#     end
#     handle
# end

function randomstep(c::Component, dx::Float32, dy::Float32)
    # random step
    # repeated calls produce Brownian motion
    J = Point2f([dx*randn(), dy*randn()])
    move(c, J)
    J
end

function stepback(c::Component, J::Point2f)
    # reverse  step in random walk
    # call this after rendering to put c back where it was before J=randomstep()
    # to simulate thethered object buffetted by thermal noise 
    # nb its just an alias for move()
    move(c, J)
end

function adopt(me::Component)
    # add shape to child list of its parent
    # child must have a parent and children must have unique names
    if !any(s->s==me.name, [me.parent.child[i].name for i in 1:length(me.parent.child)]) # if not already a child of parent
        push!(me.parent.child, me)
        me.pos = me.restpos[me.state] + me.parent.pos
    end
end

function move(c::Component, v::Point{2, Float32})
    # change position
    c.pos = v + c.pos
    for d in c.child
        move(d,v)
    end
end

function mirrorCopy(c::Component, name::String)
    # make a mirror image copy (new object) & renaME
    u = deepcopy(c)
    for i in 1:length(u.vertex)
        v = decompose(Float32, u.vertex[i])  # get coordinates as vector
        u.vertex[i] = Point2f(-v[1], v[2])
    end
    u.name = name
    u
end 

function draw_ions(ax::Axis, n::Int64, r::NTuple{4, Float64}, colour::Color, markersize::Float64)
    # scatterplot n dots in rectangle defined by r = (x0,y0, w, h)

    scatter!(ax, lift(s->[Point2f(r[1] + r[3]*rand(), r[2]+r[4]*rand()) for i in 1:n],t), color = colour, markersize = markersize)

end

function draw_lipidbilayer(ax::Axis, y::Float64, headsize::Float64, taillength::Float64, noise::Tuple{Float64, Float64})
    # lipid bilayer across axis at y = y

    ntail = 8
    lipid_tail_h = collect(taillength*(1.0 .- (0:ntail)/(1.0*ntail)))
     #tailwobble = lift(s->vcat(0.0, rand(4)/16.0), t)

    # x-coordinates of heads
    x_pos = ax.limits[][1][1] .+ (0:headsize:(ax.limits[][1][2]-ax.limits[][1][1]))
    n = length(x_pos)  # number of heads
    hNoise1 = lift(s->noise[1]*headsize*randn(n),t)
    vNoise1 = lift(s->noise[2]*headsize*randn(n),t)
    hNoise2 = lift(s->noise[1]*headsize*randn(n),t)
    vNoise2 = lift(s->noise[2]*headsize*randn(n),t)

    scatter!(ax_image, lift(s->x_pos+hNoise1[],t), lift(s->y.+taillength.+vNoise1[], t),
                    markersize = headsize*32, color = :bisque, strokewidth = 1.0, strokecolor = :silver)
    scatter!(ax_image, lift(s->x_pos+hNoise2[],t), lift(s->y.-taillength.+vNoise2[], t),
                    markersize = headsize*32, color = :bisque, strokewidth = 1.0, strokecolor = :silver)
 

    for i in 1:n
        for j in headsize*[-1,1]/4
            lines!(ax_image, x_pos[i]+j+lift(s->hNoise1[][i].+vcat([0.0],randn(ntail)/16.0),t), y.+lipid_tail_h+lift(s->vNoise1[][i], t), color = :bisque, linewidth = 2) 
            lines!(ax_image, x_pos[i]+j+lift(s->hNoise2[][i].+vcat([0.0],randn(ntail)/16.0),t), y.-lipid_tail_h+lift(s->vNoise2[][i], t), color = :bisque, linewidth = 2) 
        end
    end

end

function pillShape(h::Float64, w::Float64, cham::Float64)
    # returns Vector{Point2f} of vertices, centred at (0,0)
    v = append!([(w/2, h/2), (w/2, -h/2) ], [(-w/2, -h/2), (-w/2, h/2)])
    [Point2f(v[i]) for i in 1:length(v)]
end