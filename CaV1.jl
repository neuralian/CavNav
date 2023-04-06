# developiong code for animating blobs in 2D

using GLMakie
using Colors

include("Neuranimation_Tools.jl") 

px_per_nm = 30.0    # pixels per nm
px_wide = 1920
px_high = 1080

view_wide = px_wide/px_per_nm
view_high = px_high/px_per_nm


fig = Figure(resolution = (px_wide,px_high), backgroundcolor = :lightgrey)
ax_image = fig[1,1] = Axis( fig, 
                            backgroundcolor = :lightblue,
                            aspect = 16.0/9.0,
                            )
xlims!(ax_image, [-32, 32])
ylims!(ax_image, [-18, 18])
hidedecorations!(ax_image)

ax_current = fig[2,1] = Axis(fig)
rowsize!(fig.layout, 2, Fixed(100))
ax_voltage = fig[3,1] = Axis(fig)
rowsize!(fig.layout, 3, Fixed(100))

colsize!(fig.layout, 1, Relative(.67))

display(fig)

t = Observable(0.0)

# lipid bilayer parameters
head_width= .5
tail_length = 1.5   # height of lipid head above 0 = middle of membrane
apical_membrane_y = 8.0

# ions 
nCa = 1000
nK  = 1000
draw_ions(ax_image, nCa, (-32., apical_membrane_y+tail_length*1.25, 64., 16.), colorant"darkgoldenrod", 8.)
draw_ions(ax_image, nK, (-32., apical_membrane_y-tail_length*1.25, 64., -16.), colorant"magenta", 8.)

draw_lipidbilayer(ax_image, apical_membrane_y, head_width, tail_length, (0.025, .1))

# CaV channel
CaVα1I_wide = 3.0   # width of α1.I subunit

CaV = Component("CaV")  # channel pore is parent of other components
CaV.vertex = Point2f[(-.5, -4.0), (.5, -4.0), (.5, 4.0), (-.5, 4.0)]
CaV.colour = :lightblue
CaV.restpos[] = Point2f(-16.0, apical_membrane_y)
CaV.pos = CaV.restpos[1]

#
CaVα1I = Component("CaVα1.I")  # left α1 subunit, base element of CaV channel
CaVα1I.vertex = pillShape(7.0, 2.0, 1.0)
CaVα1I.colour = RGB(.9, .75, .4)
CaVα1I.restpos[] = Point2f(-1.25, 0.0)  # position to left of pore
CaVα1I.parent = CaV; adopt(CaVα1I)

CaVα1II = mirrorCopy(CaVα1I, "CaVα1II")
CaVα1II.colour =  RGB(.9, .75, .4)
CaVα1II.restpos[] = Point2f(1.25, 0.0)  # position to right of pore
CaVα1II.parent = CaV; adopt(CaVα1II)

# c1 = Component("C1")
# c1.vertex = Point2f[(0.0, 0.0), (2.0, 0.0), (2.0, 3.0), (0.0, 3.0)]
# c1.colour = :green
# c1.parent = α1L; adopt(c1)


draw(ax_image, CaV)
#draw(ax_image, c1)

#sleep(5)
# animate
framerate = 12
nframes = 64
for i in 1:nframes
  #  ablob[] = move(ablob, Point2f(randn()*h_noise_ampl,randn()*v_noise_ampl))
   # ablob[] = (Point2f(0.1,0.0)+ablob)[]
   #base.pos[] = base.restpos[base.state] + 0.1*randn(Point2f, 1)[]
   # move(c1, Point2f(.025, 0.0))
   # move(CaV, Point2f(0.0, .025))
    J=randomstep(CaV, .1f0, .25f0)   # thermal noise perturbation
    t[] = i
    stepback(CaV, -J)     # reset perturbation after render (object is tethered)
    sleep(.1/framerate)
    #yield()
end

