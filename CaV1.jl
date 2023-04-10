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
G_animation = fig[1:3,1] = GridLayout()   # animations in top left quadrant
G_trace     = fig[4,1] = GridLayout()   # voltage and current traces in bottom left
G_diag      = fig[1,2] = GridLayout()   # diagram of receptor cell  top right
G_controls  = fig[2,2] = GridLayout()   # controls bottom right


Ax_Animation = Axis(G_animation[1,1], 
                            backgroundcolor = :lightblue,
                            aspect = 12.0/9.0,
                            )
xlims!(Ax_Animation, [-32, 32])
ylims!(Ax_Animation, [-18, 18])
hidedecorations!(Ax_Animation)

Ax_currentTrace = Axis(G_trace[1,1])
#rowsize!(fig.layout, 2, Fixed(100))
Ax_voltageTrace = Axis(G_trace[2,1])
#rowsize!(fig.layout, 3, Fixed(100))

#colsize!(fig.layout, 1, Relative(.67))

display(fig)

t = Observable(0.0)

# lipid bilayer parameters
head_width= .5
tail_length = 3.5  # height of lipid head above 0 = middle of membrane
apical_membrane_y = 0.0
#basal_membrane_y = -8.0

# ions 
nCa = 2500
nK  = 2500
ionSize = 4.0
Δm = apical_membrane_y - basal_membrane_y  # distance between membranes
draw_ions(Ax_Animation, nCa, (-view_wide/2.0, apical_membrane_y+tail_length+head_width, view_wide, view_high/2-apical_membrane_y), colorant"darkgoldenrod", ionSize)
draw_ions(Ax_Animation, nK,  (-view_wide/2.0, -view_high/2.0, view_wide,   view_high/2 -tail_length-head_width), colorant"magenta", ionSize)

draw_ions(Ax_Animation, nK/50, (-view_wide/2.0, apical_membrane_y+tail_length+head_width, view_wide, view_high/2-apical_membrane_y), colorant"magenta", ionSize)
draw_ions(Ax_Animation, nCa/50,  (-view_wide/2.0, -view_high/2.0, view_wide,   view_high/2 -tail_length-head_width), colorant"darkgoldenrod", ionSize)


draw_lipidbilayer(Ax_Animation, apical_membrane_y, head_width, tail_length, (0.05, .2))


# CaV channel
CaVα1I_wide = 3.0   # width of α1.I subunit

sLen = tail_length+2.5*head_width
CaV = Component("CaV")  # channel pore is parent of other components
CaV.vertex = Point2f[(-3.0, -sLen), (3.0, -sLen), (3.0, sLen), (-3.0, sLen)]
CaV.colour = :lightblue
CaV.restpos[] = Point2f(-16.0, apical_membrane_y)
CaV.pos = CaV.restpos[1]

#
CaVα1I = Component("CaVα1.I")  # left α1 subunit, base element of CaV channel
CaVα1I.vertex = pillShape(2.5, 2.0*(tail_length+1.25), (1.0, 1.5, 1.5, 3.0))
CaVα1I.colour = RGB(.9, .75, .4)
CaVα1I.restpos[] = Point2f(-2.0, 0.0)  # position to left of pore
CaVα1I.parent = CaV; adopt(CaVα1I)

CaVα1II = mirrorCopy(CaVα1I, "CaVα1II")
CaVα1II.colour =  RGB(.9, .75, .4)
CaVα1II.restpos[] = Point2f(2.0, 0.0)  # position to right of pore
CaVα1II.parent = CaV; adopt(CaVα1II)

# voltage sensor (s4 segment)
CaVs41 = Component("Cavs4.1")
CaVs41.vertex = pillShape(1.0, 2.0*tail_length, .2)
CaVs41.colour = RGB(.9, .85, .6)
CaVs41.restpos[] = Point2f(-1.0,0)
CaVs41.parent=CaV; adopt(CaVs41)

# c1 = Component("C1")
# c1.vertex = Point2f[(0.0, 0.0), (2.0, 0.0), (2.0, 3.0), (0.0, 3.0)]
# c1.colour = :green
# c1.parent = α1L; adopt(c1)


draw(Ax_Animation, CaV)
#draw(Ax_Animation, c1)

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

