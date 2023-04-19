using GLMakie
using Distributions

vMin = -80.0
vMax = 20.0
v = vMin:vMax

function pOpen(v::Union{Vector{Float64}, StepRangeLen}, v50::Float64, v100::Float64)
    # activation/inactivation curve
    # open state probability at membrane potential v
    # p50 = voltage where p(open) = 0.5
    # p100 = voltage where p(open) = 1.0 (3sd)
    d = Normal(v50, abs(v100-v50)/3.0)
    if v100>v50
        return cdf.(d,v)
    else
        return 1.0 .- cdf(d,v)
    end
end

function pBoltzmann(v::Float64, v0::Float64, λ::Float64)
    1.0 - 1.0/(1.0+exp((v-v0)/λ))
end


fig = Figure(resolution=(800, 800), backgroundcolor=:lightgrey)


Ax = Axis(fig[1, 1],
    backgroundcolor=:lightblue,
    aspect=1,
)
xlims!(vMin, vMax)
ylims!(0.0, 1.2)
display(fig)


# shark CaV1.3 channel parameters Bellono et al. 2017
sCaV_Ap50 = -42.68   # sCaV activation channel open prob is 0.5 at -40mV
sCaV_Ak = 5.0   # sCaV activation channel open prob is 1.0 at -20mV
sCaV_Ip50  = -42.0   # inactivation
sCaV_Ik = -6.0
 
# rat CaV1.3 channel parameters Bellono et al. 2017
rCaV_Ap50 = -18.16
rCaV_Ak = 5.0
rCaV_Ip50 = -42.0
rCaV_Ik = -5.0

# trichoplax CaV1 channel parameters Gauberg et al. 2022
tCaV_Ap50 = -27.9
tCaV_Ak   = 8.4
tCaV_Ip50 = -55.9
tCaV_Ik = -7.85


lines!(Ax, v, pBoltzmann.(v, tCaV_Ap50, tCaV_Ak), color = :green)
lines!(Ax, v, pBoltzmann.(v, tCaV_Ip50, tCaV_Ik), color = :green)

lines!(Ax, v, pBoltzmann.(v, sCaV_Ap50, sCaV_Ak), color = :blue)
lines!(Ax, v, pBoltzmann.(v, sCaV_Ip50, sCaV_Ik), color = :blue)

lines!(Ax, v, pBoltzmann.(v, rCaV_Ap50, rCaV_Ak), color = :red)
lines!(Ax, v, pBoltzmann.(v, rCaV_Ip50, rCaV_Ik), color = :red)


# lines!(Ax, v, pOpen(v, sCaV_Ap50, sCaV_Ap100), color = :blue)
# lines!(Ax, v, pOpen(v, sCaV_Ip50, sCaV_Ip100), color = :blue)

# lines!(Ax, v, pOpen(v, rCaV_Ap50, rCaV_Ap100), color = :red)
# lines!(Ax, v, pOpen(v, rCaV_Ip50, rCaV_Ip100), color = :red)

# lines!(Ax, v, pOpen(v, tCaV_Ap50, tCaV_Ap100), color = :green)
# lines!(Ax, v, pOpen(v, tCaV_Ip50, tCaV_Ip100), color = :green)