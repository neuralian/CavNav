# extend + to add constant to Observable
using GLMakie
GLMakie.activate!()
using Observables

# Overload + operator for observables & floats (I came from c++ - sue me)
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

import Base.*
function *(a::Float64, b::Observable)
    lift(s->a*b[],t)
end



using GLMakie
GLMakie.activate!()
# CaV channel animation 
# MGP April 2023

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

t = Observable(0.0)

# lipid bilayer
head_wide = .725
head_high = 2.5   # height of lipid head above 0 = middle of membrane
x_pos = collect(-(view_wide/2.0):head_wide:(view_wide/2.0))
hwobble = lift(s->randn(length(x_pos))/36.0, t)
vwobble = lift(s->randn(length(x_pos))/16.0, t)
#y_pos = lift(s->2.5*(1.0.+randn(length(x_pos))/64.0), t)
#y_pos = lift(s->2.5.+vwobble[], t)
y_pos = head_high+vwobble  # declare outer y_pos vector of floats

ym_pos = lift(s->-2.25.+vwobble[], t)
ntail = 8
lipid_tail_h = collect(2.5*(1.0 .- (0:ntail)/(1.01*ntail)))
tailwobble = lift(s->vcat(0.0, rand(4)/16.0), t)


scatter!(ax_image,x_pos+hwobble, head_high+vwobble, markersize = 22, color = :bisque, strokewidth = 1.0, strokecolor = :silver)


scatter!(ax_image,x_pos+hwobble, -head_high+vwobble, markersize = 22, color = :bisque, strokewidth = 1.0, strokecolor = :silver)

# i = 4
# j = 1
# lines!(ax_image, x_pos[i]+j.+vcat([0.0],randn(4)/16.0), lift(s->vwobble[][i], t)+lipid_tail_h, color = :bisque, linewidth = 2)  #

for i in 1:length(x_pos)
    for j in head_wide*[-1,1]/8
        # nb vwobble is an observable listening to t, but vwobble[][i] is a float not listening to anything, 
        # We use an anonymous function to make it listen to t, so the lipid tails update on each frame
        lines!(ax_image, x_pos[i]+j+lift(s->vcat([0.0],randn(ntail)/16.0),t), lipid_tail_h+lift(s->vwobble[][i], t), color = :bisque, linewidth = 4) 
        lines!(ax_image, x_pos[i]+j+lift(s->vcat([0.0],randn(ntail)/16.0),t), -lipid_tail_h+lift(s->vwobble[][i], t), color = :bisque, linewidth = 4) 
    end
end



hidedecorations!(ax_image)

display(fig)
framerate = 24
nframes = 240
for i in 1:nframes
    t[] = i
    sleep(0.5/framerate)
    # yield()
end



