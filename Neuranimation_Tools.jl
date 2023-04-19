import Base.+
function +(a::Float64, b::Observable)
    # float + observable
    a.+b[]
end

function +(a::Array{Float64}, b::Observable)
    # float array + observable
    a.+b[]
end

function +(a::Observable, b::Observable)
    # observable + observable
    a[].+b[]
end

function +(p::Point{2,Float32}, verts::Observable{Vector{Point{2, Float32}}})
    # point + observable vertices
    [p + v for v in verts[]]
end

function +(p::Observable{Point{2,Float32}}, verts::Observable{Vector{Point{2, Float32}}})
    # observable point + observable vertices
    [p[] + v for v in verts[]]
end

function +(p::Point{2,Float32}, q::Observable{Point{2, Float32}})
    # observable point + observable vertices
    p+q[]
end

import Base.-
function -(a::Float64, b::Observable)
    # float + observable
    a.-b[]
end

import Base.*
function *(a::Float64, b::Observable)
    a*b[]
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
    restpos::Vector{Point{2, Float32}}      # rest position in parent frame in ith state
    pos::Observable{Point{2, Float32}}      # position in parent frame
    Θ::Observable{Float32}                  # orientation in parent frame  
    jitter::Tuple{Point{2,Float32}, Float32}  # current jitter state (dr, dΘ), is subtracted before jitter
    jitterScale::Tuple{Float32, Float32, Float32}     # scaling for jitter x & y stepsize and angle
    state::Int64  # countable states  
    param::Vector{Float64}
    colour::Union{RGB{Float64}, Symbol}
    visibility::Float64                     # displayed colour is RGBA(R,G,B, visibility)
    outline::Float64                        # strokecolor = RGBA(0,0,0,outline)
end

# default constructor
# invisible object at origin 
# in state 1
function Component(name::String)
    Component(  name,                           # name
                nothing,                        # parent
                [],                             # child
                [Point2f(0.0,0.0)],             # vertex
                [Point2f(0.0, 0.0)],            # restpos                    
                Observable(Point2f(0.0, 0.0)),  # pos
                Observable(0.0),                # orientation  
                (Point2f(0,0), 0.0),            # jitter
                (1.0, 1.0, 1.0),                     #jitter scale
                1,                              # state
                [],                             # parameters
                RGB(0.,0.,0.),                     # colour 
                0.0,                            # invisible by default
                0.0                             # stroke alpha (0=invisible)
                )
end


function draw(ax::Axis, c::Component)
    # draw component and its children
    poly!(ax, lift(s->[worldPos(c)].+c.vertex, t), color = c.colour, strokewidth = 2, strokecolor = RGBA(0,0,0,c.outline))
    for child in c.child
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

function randomstep(c::Component, dr::Float32)
    # random step of average length r
    # repeated calls produce Brownian motion
    s = dr*randn()[]
    q = rand()[]
    J = Point2f([s*cos(q), s*sin(q)])
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


function jitter(c::Component, dr::Float32, dΘ::Float32)

    rotate(c, Float64(-c.jitter[2]))
    move(c, -c.jitter[1])

    # random step
    step = Point2f(c.jitterScale[1]*dr*randn()[], c.jitterScale[2]*dr*randn()[])
    # random turn
    rot = c.jitterScale[3]*dΘ*(2.0*rand()[]-1.0)
    move(c,step)
    rotate(c, rot)
    c.jitter = (step, rot)

    for ch in c.child
        jitter(ch, dr, dΘ)
    end
end


function dejitter(c::Component)
        # return to unjittered configuration
    rotate(c, Float64(-c.jitter[2]))
    move(c, -c.jitter[1])
    c.jitter = (Point2f(0,0), 0.0)
    for ch in c.child
        dejitter(ch)
    end
end



function adopt(me::Component)
    # add shape to child list of its parent
    # child must have a parent and children must have unique names
    if !any(s->s==me.name, [me.parent.child[i].name for i in 1:length(me.parent.child)]) # if not already a child of parent
        push!(me.parent.child, me)
       # me.pos = me.restpos[me.state] + me.parent.pos
    end
end

function getChild(c::Component, name::String)
    # return child of c whose name is name
    for ch in c.child
        if(ch.name==name) 
            return ch
        end
    end
    println("Error: ", c.name, " has no child named ", name, ".")
    return nothing
end


function move(c::Component, v::Point{2, Float32})
    # change position
    c.pos = v + c.pos
end

function rotate(c::Component,  Θ::Float64)
    # rotate component thru angle Θ around its origin
    # all descendents rotate around the same origin
    # nb to rotate a component (and descendents) around any point,
    # place a parent component (an axle) at that point and rotate the axle
    c.Θ = Θ + c.Θ
    R = rotationMatrix(Θ)
    c.vertex = [Point2f(R*v) for v in c.vertex]
    for ch in c.child
        rotate(ch,Θ)
    end
end

function rotationMatrix(Θ)
    [cos(Θ) -sin(Θ); sin(Θ) cos(Θ)]
end

function worldPos(c::Component)
    # position and orientation of c in world (axis) reference frame
    if c.parent==nothing
        return c.pos[]
    else
      return rotationMatrix(c.parent.Θ[])*c.pos[] + worldPos(c.parent)
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

function draw_ions(ax::Axis, n::Float64, r::NTuple{4, Float64}, colour::Color, markersize::Float64)
    # scatterplot n dots in rectangle defined by r = (x0,y0, w, h)

    scatter!(ax, lift(s->[Point2f(r[1] + r[3]*rand(), r[2]+r[4]*rand()) for i in 1:n],t), color = colour, markersize = markersize)

end

function draw_lipidbilayer(ax::Axis, y::Float64, headsize::Float64, taillength::Float64, noise::Tuple{Float64, Float64})
    # lipid bilayer across axis at y = y

    ntail = 8
    lipid_tail_h = collect(taillength*(1.0 .- (0:ntail)/(1.0*ntail)))
     #tailwobble = lift(s->vcat(0.0, rand(4)/16.0), t)

    # x-coordinates of heads
    x_pos = ax.limits[][1][1] .+ (0:1.5*headsize:(ax.limits[][1][2]-ax.limits[][1][1]))
    n = length(x_pos)  # number of heads
    hNoise1 = lift(s->noise[1]*headsize*randn(n),t)
    vNoise1 = lift(s->noise[2]*headsize*randn(n),t)
    hNoise2 = lift(s->noise[1]*headsize*randn(n),t)
    vNoise2 = lift(s->noise[2]*headsize*randn(n),t)

    q = 0.5
    scatter!(ax, lift(s->x_pos+q*hNoise1[],t), lift(s->y.+taillength.+q*vNoise1[], t),
                    markersize = headsize*32, color = :bisque, strokewidth = 1.0, strokecolor = :silver)
    scatter!(ax, lift(s->x_pos+q*hNoise1[],t), lift(s->y.-taillength.+q*vNoise1[], t),
                    markersize = headsize*32, color = :bisque, strokewidth = 1.0, strokecolor = :silver)
 

    for i in 1:n
        for j in headsize*[-1,1]/2.5
            lines!(ax, lift(s->x_pos[i].+j.+hNoise1[][i].+vcat([0.0],randn(ntail)/16.0),t), lift(s->y.+lipid_tail_h.+0.025.+vNoise1[][i], t), color = :bisque, linewidth = 3) 
            lines!(ax, lift(s->x_pos[i].+j.+hNoise1[][i].+vcat([0.0],randn(ntail)/16.0),t), lift(s->y.-lipid_tail_h.-0.025.+vNoise1[][i], t), color = :bisque, linewidth = 3) 
        end
    end

end

function pillShape(w::Float64, h::Float64, r::Union{Float64, Tuple{Float64,Float64,Float64,Float64 }})
    # losenge shape generator
    # width w, height h; r = (r1,r2,r3,r4) fillet radius on each corner anticlockwise from top right
    # or r = a float for the same fillet on all corners 
    # returns Vector{Point2f} of vertices, centred at (0,0)
    h = h/2.
    w = w/2.
    N = 5  # number of fillet segments
    if length(r)==1
        r = (r,r,r,r)
    end
    
    append!(
    [Point2f(w-r[1]+r[1]*cos(k*π/(2*N)), h-r[1]+r[1]*sin(k*π/(2*N))) for k in 1:N],
    [Point2f(-w+r[2]+r[2]*cos(k*π/(2*N)), h-r[2]+r[2]*sin(k*π/(2*N))) for k in (N+1):2*N],
    [Point2f(-w+r[3]+r[3]*cos(k*π/(2*N)), -h+r[3]+r[3]*sin(k*π/(2*N))) for k in (2*N+1):3*N],
    [Point2f(w-r[4]+r[4]*cos(k*π/(2*N)), -h+r[4]+r[4]*sin(k*π/(2*N))) for k in (3*N+1):4N]
    )


    # v = append!([(w, h), (w, -h) ], [(-w, -h), (-w, h)])
    # [Point2f(v[i]) for i in 1:length(v)]
end



function pBoltzmann(v::Float64, v0::Float64, λ::Float64)
    1.0 - 1.0/(1.0+exp((v-v0)/λ))
end