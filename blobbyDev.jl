# developiong code for animating blobs in 2D

using GLMakie
using Colors

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
    restpos::Point{2, Float32}  # rest/default location in parent frame 
    pos::Observable{Point{2, Float32}}      # current location in parent frame
    Θ::Float32  # rotation
    R::Float32  # scale
    state::Any  
    param::Any
    colour::Union{RGB{Float64}, RGBA{Float64}, Symbol, Nothing}
end

# default constructor
# invisible object at origin 
function Component(name::String)
    Component(  name,
                nothing,
                [],
                [Point2f(0.0,0.0)],
                Point2f(0.0, 0.0),
                Observable(Point2f(0.0, 0.0)),
                0.0,
                1.0,
                [],
                [],
                nothing
                )
end


function draw(ax::Axis, component::Component)
    # draw component and its children
    if !(component.colour==nothing)
        handle = poly!(ax, lift(s->[component.pos[]].+component.vertex, t), color = component.colour)
    end
    # for child in component.child
    #     draw(ax, child)
    # end
    handle
end





# function adopt(child::Component)
#     # add shape to child list of its parent
#     # child must have a parent and children must have unique names
#     if !any(s->s==child.name, [child.parent.child[i].name for i in 1:length(child.parent.child)]) # if not already a child of parent
#         push!(child.parent.child, child)
#     end
# end

base = Component("base")

base.vertex = Point2f[(0.0, 0.0), (5.0, 0.0), (5.0, 5.0), (0.0, 5.0)]
base.colour = :red

draw(ax_image, base)

# animate
framerate = 24
nframes = 96
for i in 1:nframes
  #  ablob[] = move(ablob, Point2f(randn()*h_noise_ampl,randn()*v_noise_ampl))
   # ablob[] = (Point2f(0.1,0.0)+ablob)[]
   base.pos[] += 0.1*randn(Point2f, 1)[]
    t[] = i
    sleep(1/framerate)
    # yield()
end


# ashape = Component("A", nothing, [], [Point2f(1.0, 2.0)], :red)
# bshape = Component("B", ashape,  [], [Point2f(1.0, 2.0)], :green)
# # ashape could not be constructed with child bshape because bshape did not exist then 
# # but now it does, so we can tell ashape that bshape is its child. 
# adopt(bshape)  