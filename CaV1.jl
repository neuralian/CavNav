# developiong code for animating blobs in 2D

using GLMakie
using Colors

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




px_per_nm = 30.0    # pixels per nm
px_wide = 1920
px_high = 1080


view_wide = px_wide/px_per_nm
view_high = px_high/px_per_nm


fig = Figure(resolution = (px_wide,px_high), backgroundcolor = :lightgrey)
ax_image = fig[1,1] = Axis(fig, 
    backgroundcolor = :lightblue,
   # targetlimits = BBox(-10, 10, -10, 10),
    aspect = 16.0/9.0,
    )
    xlims!(ax_image, [-32, 32])
    ylims!(ax_image, [-18, 18])
    #hidedecorations!(ax_image)

ax_current = fig[2,1] = Axis(fig)
rowsize!(fig.layout, 2, Fixed(100))
ax_voltage = fig[3,1] = Axis(fig)
rowsize!(fig.layout, 3, Fixed(100))

colsize!(fig.layout, 1, Relative(.67))

display(fig)

t = Observable(0.0)


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
        handle = poly!(ax, lift(s->[component.pos[]].+component.vertex, t), color = component.colour)
    end
    for child in component.child
        draw(ax, child)
    end
    handle
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
    if !any(s->s==child.name, [me.parent.child[i].name for i in 1:length(me.parent.child)]) # if not already a child of parent
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


base = Component("base")

base.vertex = Point2f[(0.0, 0.0), (5.0, 0.0), (5.0, 5.0), (0.0, 5.0)]
base.colour = :red

c1 = Component("C1")
c1.vertex = Point2f[(0.0, 0.0), (2.0, 0.0), (2.0, 3.0), (0.0, 3.0)]
c1.colour = :green
c1.parent = base; adopt(c1)


draw(ax_image, base)
#draw(ax_image, c1)

# animate
framerate = 24
nframes = 240
for i in 1:nframes
  #  ablob[] = move(ablob, Point2f(randn()*h_noise_ampl,randn()*v_noise_ampl))
   # ablob[] = (Point2f(0.1,0.0)+ablob)[]
   #base.pos[] = base.restpos[base.state] + 0.1*randn(Point2f, 1)[]
    move(c1, Point2f(.025, 0.0))
    move(base, Point2f(0.0, .025))
    J=randomstep(base, .1f0, .25f0)   # thermal noise perturbation
    t[] = i
    stepback(base, -J)     # reset perturbation after render (object is tethered)
    sleep(1/framerate)
    # yield()
end

