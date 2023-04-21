# developiong code for animating blobs in 2D

using GLMakie
using Colors

include("Neuranimation_Tools.jl")
include("CaV_components.jl")

px_per_nm = 30.0    # pixels per nm
px_wide = 1440
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

colsize!(fig.layout, 1, Relative(2/3))
rowsize!(fig.layout, 1, Relative(2 / 3))

Ax_Animation = Axis(G_animation[1, 1],
    backgroundcolor=:lightblue,
    aspect=32 / 24
)

xlims!(Ax_Animation, [-xmax, xmax])
ylims!(Ax_Animation, [-ymax, ymax])
hidedecorations!(Ax_Animation)

Ax_currentTrace = Axis(G_trace[1, 1])
#rowsize!(fig.layout, 2, Fixed(100))
Ax_voltageTrace = Axis(G_trace[2, 1])
#rowsize!(fig.layout, 3, Fixed(100))

vMin = -80.0
vMax = 20.0
v = vMin:vMax
sColour = RGB(.4, .4, .8)
tColour = RGB(0.8, 0.9, 0.6)
rColour = RGB(1.0, 0.8, 0.6)
Ax_BoltzmannCurves = Axis(G_plot[1, 1], aspect=2.0, backgroundcolor = RGB(.975,0.95,0.925), title = "CaV 1.3 (L-type)")
xlims!(vMin, vMax)
ylims!(0.0, 1.05)
text!(0.0, 0.5; text = "Shark", color = sColour)
text!(0.0, 0.4; text = "Trichoplax", color = RGBA(tColour, .85))
text!(0.0, 0.3; text = "Rat", color = rColour*.85)

lines!(Ax_BoltzmannCurves, v, pBoltzmann.(v, tCaV_Ap50, tCaV_Ak), color = RGB(0.8, 0.9, 0.6), linewidth = 2)
lines!(Ax_BoltzmannCurves, v, pBoltzmann.(v, tCaV_Ip50, tCaV_Ik), color = RGB(0.8, 0.9, 0.6), linewidth = 2)

lines!(Ax_BoltzmannCurves, v, pBoltzmann.(v, rCaV_Ap50, rCaV_Ak), color = RGB(1.0, 0.8, 0.6), linewidth = 2)
lines!(Ax_BoltzmannCurves, v, pBoltzmann.(v, rCaV_Ip50, rCaV_Ik), color = RGB(1.0, 0.8, 0.6), linewidth = 2)

lines!(Ax_BoltzmannCurves, v, pBoltzmann.(v, sCaV_Ap50, sCaV_Ak), color = RGB(.4, .4, .8), linewidth = 3)
lines!(Ax_BoltzmannCurves, v, pBoltzmann.(v, sCaV_Ip50, sCaV_Ik), color =  RGB(.4, .4, .8), linewidth = 3)


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

draw_lipidbilayer(Ax_Animation, apical_membrane_y, head_width, tail_length, (0.1, 0.5))

CaV_location = -13.0
CaV = make_CaV(CaV_location)    # CaV object 
CaVIGa = getChild(CaV, "CaVIG.axis") # inactivation gate rotates around this axis
draw(Ax_Animation, CaV)


BK_location = 13.0
BK= make_BK(BK_location)    # CaV object 
draw(Ax_Animation, BK)




vMax = 25.0
vMin = -75.0
vSlider = Slider(G_controls[1, 1:5], range=vMin:0.1:vMax, startvalue=-40.0, tellwidth=false, width=Relative(2 / 3))
r = lift(vSlider.value) do q
    rotate(CaVIGa, (-π/4.0+(π/4.0)*(75.0+q)/100.0-CaVIGa.Θ)[])
    t[] = 1
end



# controls
#G_controls = buttongrid = GridLayout()

framerate = 12
nframes = 64





#sleep(5)
# animate

function animationStep()

        jitter(CaV, 0.1f0, 0.05f0)   # thermal noise perturbation
        jitter(BK, 0.1f0, 0.05f0) 
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

ResetButton = Button(G_controls[2, 2], label="RESET", tellwidth=false)
on(ResetButton.clicks) do n
    isRunning[] = false
    runButton.label = "RUN"    
    dejitter(CaV)
    dejitter(BK)
    t[] = 1
end


# @time touch()  # how long does it take to update scene?
function touch()
    t[] = 1
end
