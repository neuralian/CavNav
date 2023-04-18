# developiong code for animating blobs in 2D

using GLMakie
using Colors

include("Neuranimation_Tools.jl")
include("CaV_components.jl")

px_per_nm = 30.0    # pixels per nm
px_wide = 1920
px_high = 1080

view_wide = px_wide / px_per_nm
view_high = px_high / px_per_nm
xmax = 32.0
ymax = 24.0


fig = Figure(resolution=(px_wide, px_high), backgroundcolor=:lightgrey)
G_animation = fig[1, 1] = GridLayout(tellwidth=false, tellheight=false)  # animations in top left quadrant
G_trace = fig[2, 1] = GridLayout(tellwidth=false, tellheight=false)   # voltage and current traces in bottom left
G_plot = fig[1, 2] = GridLayout(tellwidth=false, tellheight=false)   # diagram of receptor cell  top right
G_controls = fig[2, 2] = GridLayout(tellwidth=false, tellheight=false)   # controls bottom right

colsize!(fig.layout, 1, Relative(0.5))
rowsize!(fig.layout, 1, Relative(2 / 3))

Ax_Animation = Axis(G_animation[1, 1],
    backgroundcolor=:lightblue,
    aspect=32 / 24,
)

xlims!(Ax_Animation, [-xmax, xmax])
ylims!(Ax_Animation, [-ymax, ymax])
#hidedecorations!(Ax_Animation)

Ax_currentTrace = Axis(G_trace[1, 1])
#rowsize!(fig.layout, 2, Fixed(100))
Ax_voltageTrace = Axis(G_trace[2, 1])
#rowsize!(fig.layout, 3, Fixed(100))

Ax_Plot = Axis(G_plot[1, 1], aspect=1.0)

#colsize!(fig.layout, 1, Relative(.67))





display(fig)

t = Observable(0.0)

# lipid bilayer parameters
head_width = 0.5
tail_length = 3.5  # height of lipid head above 0 = middle of membrane
apical_membrane_y = 0.0
#basal_membrane_y = -8.0

# ions 
nCa = 2500.0
nK = 2500.0
ionSize = 4.0
#Δm = apical_membrane_y - basal_membrane_y  # distance between membranes
draw_ions(Ax_Animation, nCa, (-xmax, apical_membrane_y + tail_length + head_width, 2.0 * xmax, ymax - apical_membrane_y), colorant"darkgoldenrod", ionSize)
draw_ions(Ax_Animation, nK, (-xmax, -ymax, 2.0 * xmax, ymax - tail_length - head_width), colorant"magenta", ionSize)

draw_ions(Ax_Animation, nK / 50, (-xmax, apical_membrane_y + tail_length + head_width, 2.0 * xmax, ymax - apical_membrane_y), colorant"magenta", ionSize)
draw_ions(Ax_Animation, nCa / 50, (-xmax, -ymax, 2.0 * xmax, ymax - tail_length - head_width), colorant"darkgoldenrod", ionSize)

draw_lipidbilayer(Ax_Animation, apical_membrane_y, head_width, tail_length, (0.05, 0.2))

CaV_location = -14.0
CaV = make_CaV(CaV_location)    # CaV object 
CaVIGa = getChild(CaV, "CaVIG.axis") # inactivation gate rotates around this axis

draw(Ax_Animation, CaV)


vMax = 25.0
vMin = -75.0
vSlider = Slider(G_controls[1, 1:5], range=vMin:0.1:vMax, startvalue=-40.0, tellwidth=false, width=Relative(2 / 3))
r = lift(vSlider.value) do q
    rotate(CaVIGa, (-π/4.0+(π/4.0)*(75.0+q)/100.0-CaVIGa.Θ)[])
    t[] = 1
end



# controls
#G_controls = buttongrid = GridLayout()
ResetButton = Button(G_controls[2, 2], label="RESET", tellwidth=false)
on(ResetButton.clicks) do n
    dejitter(CaV)
    t[] = 1
end

framerate = 12
nframes = 64





#sleep(5)
# animate

function animationStep()

        jitter(CaV, 0.1f0, 0.05f0)   # thermal noise perturbation

end




runButton = Button(G_controls[2, 4], label="RUN", tellwidth=false)

isRunning = Observable(false)
on(runButton.clicks) do clicks
    if isRunning[]
        isRunning[] = false
        runButton.label = "RUN"
    else
        isRunning[] = true
        runButton.label = "PAUSE"
    end
end

on(runButton.clicks) do clicks
    @async  while isRunning[]
        isopen(fig.scene) || break
        animationStep()
        t[] = 1
        sleep(0.1 / framerate)
        yield()
    end
end

function touch()
    t[] = 1
end
