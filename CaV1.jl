# developiong code for animating blobs in 2D

using GLMakie
using Colors

include("Neuranimation_Tools.jl") 

px_per_nm = 30.0    # pixels per nm
px_wide = 1920
px_high = 1080

view_wide = px_wide/px_per_nm
view_high = px_high/px_per_nm
xmax = 32.0
ymax = 24.0


fig = Figure(resolution = (px_wide,px_high), backgroundcolor = :lightgrey)
G_animation = fig[1:3,1] = GridLayout()   # animations in top left quadrant
G_trace     = fig[4,1] = GridLayout()   # voltage and current traces in bottom left
G_diag      = fig[1,2] = GridLayout()   # diagram of receptor cell  top right
G_controls  = fig[2,2] = GridLayout()   # controls bottom right


Ax_Animation = Axis(G_animation[1,1], 
                            backgroundcolor = :lightblue,
                            aspect = 32/24,
                            )

xlims!(Ax_Animation, [-xmax, xmax])
ylims!(Ax_Animation, [-ymax, ymax])
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
nCa = 2500.
nK  = 2500.
ionSize = 4.0
#Δm = apical_membrane_y - basal_membrane_y  # distance between membranes
draw_ions(Ax_Animation, nCa, (-xmax, apical_membrane_y+tail_length+head_width, 2.0*xmax, ymax-apical_membrane_y), colorant"darkgoldenrod", ionSize)
draw_ions(Ax_Animation, nK,  (-xmax, -ymax, 2.0*xmax,   ymax -tail_length-head_width), colorant"magenta", ionSize)

draw_ions(Ax_Animation, nK/50, (-xmax, apical_membrane_y+tail_length+head_width, 2.0*xmax, ymax-apical_membrane_y), colorant"magenta", ionSize)
draw_ions(Ax_Animation, nCa/50,  (-xmax, -ymax, 2.0*xmax,   ymax -tail_length-head_width), colorant"darkgoldenrod", ionSize)


draw_lipidbilayer(Ax_Animation, apical_membrane_y, head_width, tail_length, (0.05, .2))


# CaV channel
CaVα1I_wide = 3.0   # width of α1.I subunit

sLen = tail_length+2.5*head_width
CaV = Component("CaV")  # channel pore is parent of other components
CaV.vertex = Point2f[(-3.0, -sLen), (3.0, -sLen), (3.0, sLen), (-3.0, sLen)]
CaV.colour = :lightblue
CaV.restpos[] = Point2f(-16.0, apical_membrane_y)
CaV.pos = CaV.restpos[1]

# gate (s6)
CaVs6I = Component("Cavs6.I")
CaVs6I.vertex = pillShape(.25, 2.0*tail_length-1., .75)
CaVs6I.colour = RGB(.8, .7, .45)
CaVs6I.restpos[] = Point2f(0.0,0.0)
CaVs6I.parent=CaV; adopt(CaVs6I)

CaVs6II = Component("Cavs6.II")
CaVs6II.vertex = pillShape(.25, 2.0*tail_length-1., .75)
CaVs6II.colour = RGB(.8, .7, .45)
CaVs6II.restpos[] = Point2f(1.5,0.0)
CaVs6II.parent=CaV; adopt(CaVs6II)

#
CaVα1I = Component("CaVα1.I")  # left α1 subunit, base element of CaV channel
CaVα1I.vertex = pillShape(2.5, 2.0*(tail_length+1.25), (1.0, 1.5, 1.5, 2.0))
CaVα1I.colour = RGB(.9, .75, .4)
CaVα1I.restpos[] = Point2f(-2.0, 0.0)  # position to left of pore
CaVα1I.parent = CaV; adopt(CaVα1I)

CaVα1II = mirrorCopy(CaVα1I, "CaVα1II")
CaVα1II.colour =  RGB(.9, .75, .4)
CaVα1II.restpos[] = Point2f(2.0, 0.0)  # position to right of pore
CaVα1II.parent = CaV; adopt(CaVα1II)

# voltage sensor (s4)
CaVs4I = Component("Cavs4.I")
CaVs4I.vertex = pillShape(.25, 2.0*tail_length-1., .75)
CaVs4I.colour = RGB(.9, .8, .55)
CaVs4I.outline = .1
CaVs4I.restpos[] = Point2f(-2.0,-1.0)
CaVs4I.parent=CaV; adopt(CaVs4I)

CaVs4II = Component("Cavs4.II")
CaVs4II.vertex = pillShape(.25, 2.0*tail_length-1., .75)
CaVs4II.colour = RGB(.9, .8, .55)
CaVs4II.outline = .1
CaVs4II.restpos[] = Point2f(3.0,-1.0)
CaVs4II.parent=CaV; adopt(CaVs4II)

# inactivation gate
CaVIG = Component("CaVIG")
CaVIG.vertex = decompose(Point2f,Circle(Point2f(0,0), 2f0))
CaVIG.colour =RGB(.8, .7, .45)
CaVIG.restpos[] = Point2f(0.0,-5.5)
CaVIG.parent=CaV; adopt(CaVIG)


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

