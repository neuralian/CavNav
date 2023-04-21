function make_CaV(location::Tuple{Float64, Float64}, Θ::Float64)
    # CaV channel, orientation Θ (0 = upright, π = upside-down)

    R = rotationMatrix(Θ)


    CaV_colour = RGB(0.722,0.525,0.043)*0.8
    CaVα1I_wide = 3.0   # width of α1.I subunit

    sLen = tail_length + 2.5 * head_width
 


    CaV_axis = Component("CaV_axis")
    CaV_axis.vertex = decompose(Point2f, Circle(Point2f(0, 0), 0.25f0))
    CaV_axis.colour = :lightblue
    CaV_axis.restpos =  [Point2f(location)]
    CaV_axis.pos[] = CaV_axis.restpos[1]
    CaV_axis.jitterScale = (0.0, 0.0, 0.0)

    CaVpore = Component("CaV_pore")  # channel pore is parent of other components
    CaVpore.vertex = Point2f[[-3.0, -sLen], [3.0, -sLen], [3.0, sLen], [-3.0, sLen]]
    CaVpore.colour = :lightblue
    CaVpore.restpos = [Point2f(0.0, 0.0)]
    CaVpore.pos[] = CaVpore.restpos[1]
    CaVpore.parent = CaV_axis
    adopt(CaVpore)



    # gate (s6)
    CaVs6I = Component("Cavs6.I")
    CaVs6I.vertex = pillShape(2.5, 2.0 * tail_length - 1.0, 0.45)
    CaVs6I.colour = CaV_colour*.85
    CaVs6I.jitterScale = (3.0, 1.0, 0.5)
    CaVs6I.restpos = [Point2f(-1.5, 0.0)]
    CaVs6I.pos[] = CaVs6I.restpos[1]
    CaVs6I.parent = CaV_axis
    adopt(CaVs6I)

    CaVs6II = Component("Cavs6.II")
    CaVs6II.vertex = pillShape(2.5, 2.0 * tail_length - 1.0, 0.45)
    CaVs6II.colour = CaV_colour*.85
    CaVs6II.jitterScale = (3.0, 1.0, 0.5)
    CaVs6II.restpos = [Point2f(1.5, 0.0)]
    CaVs6II.pos[] = CaVs6II.restpos[1]
    CaVs6II.parent = CaV_axis
    adopt(CaVs6II)


    CaVα1I = Component("CaVα1.I")  # left α1 subunit, base element of CaV channel
    CaVα1I.vertex = pillShape(3.5, 2.0 * (tail_length + 1.25), (1.0, 1.5, 1.5, 2.0))
    CaVα1I.colour = CaV_colour
    CaVα1I.restpos = [Point2f(-2.25, 0.0)]  # position to left of pore
    CaVα1I.pos[] = CaVα1I.restpos[1]
    CaVα1I.parent = CaV_axis
    adopt(CaVα1I)

    CaVα1II = mirrorCopy(CaVα1I, "CaVα1II")
    CaVα1II.colour = CaV_colour
    CaVα1II.restpos = [Point2f(2.25, 0.0)]  # position to right of pore
    CaVα1II.pos[] = CaVα1II.restpos[1]
    CaVα1II.parent = CaV_axis
    adopt(CaVα1II)

    # voltage sensor (s4)
    CaVs4I = Component("Cavs4.I")
    CaVs4I.vertex = pillShape(0.65, 2.0 * tail_length - 1.0, 0.2)
    CaVs4I.colour = CaV_colour*1.2
    CaVs4I.outline = 0.1
    CaVs4I.restpos = [Point2f(-1.5, -0.75)]
    CaVs4I.pos[] = CaVs4I.restpos[1]
    CaVs4I.parent = CaV_axis
    adopt(CaVs4I)

    CaVs4II = Component("Cavs4.II")
    CaVs4II.vertex = pillShape(0.65, 2.0 * tail_length - 1.0, 0.2)
    CaVs4II.colour = CaV_colour*1.2
    CaVs4II.outline = 0.1
    CaVs4II.restpos = [Point2f(1.5, -0.75)]
    CaVs4II.pos[] = CaVs4II.restpos[1]
    CaVs4II.parent = CaV_axis
    adopt(CaVs4II)

    # inactivation gate, ball and chain rotating around axis
    CaVIGa = Component("CaVIG.axis")
    CaVIGa.vertex = decompose(Point2f, Circle(Point2f(0, 0), 0.25f0))
    CaVIGa.colour = CaV_colour
    CaVIGa.restpos = [Point2f(-2.5, -4.65)]
    CaVIGa.pos[] = CaVIGa.restpos[1]
    CaVIGa.jitterScale = (0.0, 0.0, 8.0)
    CaVIGa.parent = CaV_axis
    adopt(CaVIGa)

    CaVIGc = Component("CaVIG.chain")
    CaVIGc.vertex = pillShape(1.5, 0.5, 0.2)
    CaVIGc.colour = CaV_colour
    CaVIGc.restpos = [Point2f(0.75, 0.0)]
    CaVIGc.pos[] = CaVIGc.restpos[1]
    CaVIGc.parent = CaVIGa
    adopt(CaVIGc)

    CaVIG = Component("CaVIG")
    CaVIG.vertex = decompose(Point2f, Circle(Point2f(0, 0), 1.25f0))
    CaVIG.colour = CaV_colour
    CaVIG.restpos = [Point2f(1.8, 0.0)]
    CaVIG.pos[] = CaVIG.restpos[1]
    CaVIG.parent = CaVIGc
    adopt(CaVIG)

    rotate(CaVIGa, -π / 4)

    CaV_axis
end


function make_BK(location::Float64)

    BK_colour =  RGB(0.6,0.4,0.6)

    # BK channel
    BKα1I_wide = 3.0   # width of α1.I subunit

    sLen = tail_length + 2.5 * head_width
    BK = Component("BK")  # channel pore is parent of other components
    BK.vertex = Point2f[(-3.0, -sLen), (3.0, -sLen), (3.0, sLen), (-3.0, sLen)]
    BK.colour = :lightblue
    BK.restpos = [Point2f(location, apical_membrane_y)]
    BK.pos[] = BK.restpos[1]

    # gate (s6)
    BKs6I = Component("BKs6.I")
    BKs6I.vertex = pillShape(2.5, 2.0 * tail_length - 1.0, 0.45)
    BKs6I.colour = BK_colour*0.85
    BKs6I.jitterScale = (3.0, 1.0, 0.5)
    BKs6I.restpos = [Point2f(-1.5, 0.0)]
    BKs6I.pos[] = BKs6I.restpos[1]
    BKs6I.parent = BK
    adopt(BKs6I)

    BKs6II = Component("BKs6.II")
    BKs6II.vertex = pillShape(2.5, 2.0 * tail_length - 1.0, 0.45)
    BKs6II.colour = BK_colour*0.85
    BKs6II.jitterScale = (3.0, 1.0, 0.5)
    BKs6II.restpos = [Point2f(1.5, 0.0)]
    BKs6II.pos[] = BKs6II.restpos[1]
    BKs6II.parent = BK
    adopt(BKs6II)


    BKα1I = Component("BKα1.I")  # left α1 subunit, base element of BK channel
    BKα1I.vertex = pillShape(3.5, 2.0 * (tail_length + 1.25), (1.0, 1.5, 1.5, 2.0))
    BKα1I.colour = BK_colour
    BKα1I.restpos = [Point2f(-2.25, 0.0)]  # position to left of pore
    BKα1I.pos[] = BKα1I.restpos[1]
    BKα1I.parent = BK
    adopt(BKα1I)

    BKα1II = mirrorCopy(BKα1I, "BKα1II")
    BKα1II.colour = BK_colour
    BKα1II.restpos = [Point2f(2.25, 0.0)]  # position to right of pore
    BKα1II.pos[] = BKα1II.restpos[1]
    BKα1II.parent = BK
    adopt(BKα1II)

    # voltage sensor (s4)
    BKs4I = Component("BKs4.I")
    BKs4I.vertex = pillShape(0.65, 2.0 * tail_length - 1.0, 0.2)
    BKs4I.colour = BK_colour*1.25
    BKs4I.outline = 0.1
    BKs4I.restpos = [Point2f(-1.5, -0.75)]
    BKs4I.pos[] = BKs4I.restpos[1]
    BKs4I.parent = BK
    adopt(BKs4I)

    BKs4II = Component("BKs4.II")
    BKs4II.vertex = pillShape(0.65, 2.0 * tail_length - 1.0, 0.2)
    BKs4II.colour =  BK_colour*1.25 #RGB(0.8, 0.5, 0.8)
    BKs4II.outline = 0.1
    BKs4II.restpos = [Point2f(1.5, -0.75)]
    BKs4II.pos[] = BKs4II.restpos[1]
    BKs4II.parent = BK
    adopt(BKs4II)

    # RCKs  RIGHT
    BKRCK1cR = Component("BKRCK1cR")
    BKRCK1cR.vertex = pillShape(0.65, tail_length, 0.2)
    BKRCK1cR.colour = BK_colour
    BKRCK1cR.restpos = [Point2f(0.5, -4.5)]
    BKRCK1cR.pos[] = BKRCK1cR.restpos[1]
    BKRCK1cR.jitterScale = (1.0, 1.0, 1.0)
    BKRCK1cR.parent = BKs6II
    adopt(BKRCK1cR)

    BKRCK1R = Component("BKRCK1R")
    BKRCK1R.vertex = pillShape(tail_length, tail_length/2.0, 1.0)
    BKRCK1R.colour = BK_colour
    BKRCK1R.restpos = [Point2f(1.0, -1.0)]
    BKRCK1R.pos[] = BKRCK1R.restpos[1]
    BKRCK1R.jitterScale = (1.0, 1.0, 1.0)
    BKRCK1R.parent = BKRCK1cR
    adopt(BKRCK1R)

    # Ca regulator
    # connector to RCK1
    BKRCK2cR = Component("BKRCK2cR")
    BKRCK2cR.vertex = pillShape(0.65, 0.75*tail_length, 0.2)
    BKRCK2cR.colour = BK_colour
    BKRCK2cR.restpos = [Point2f(1.0, -1.0)]
    BKRCK2cR.pos[] = BKRCK2cR.restpos[1]
    BKRCK2cR.jitterScale = (1.0, 1.0, 1.0)
    BKRCK2cR.parent = BKRCK1R
    adopt(BKRCK2cR)

    BKRCK2R = Component("BKRCK2R")
    BKRCK2R.vertex = pillShape(tail_length, tail_length/2.0, 1.0)
    BKRCK2R.colour = BK_colour
    BKRCK2R.restpos = [Point2f(-1.0, -0.95)]
    BKRCK2R.pos[] = BKRCK2R.restpos[1]
    BKRCK2R.jitterScale = (1.0, 1.0, 1.0)
    BKRCK2R.parent = BKRCK2cR
    adopt(BKRCK2R)

    # RCKs LEFT
    BKRCK1cL = Component("BKRCK1cL")
    BKRCK1cL.vertex = pillShape(0.65, tail_length, 0.2)
    BKRCK1cL.colour = BK_colour
    BKRCK1cL.restpos = [Point2f(-0.5, -4.5)]
    BKRCK1cL.pos[] = BKRCK1cL.restpos[1]
    BKRCK1cL.jitterScale = (1.0, 1.0, 1.0)
    BKRCK1cL.parent = BKs6I
    adopt(BKRCK1cL)

    BKRCK1L = Component("BKRCK1R")
    BKRCK1L.vertex = pillShape(tail_length, tail_length/2.0, 1.0)
    BKRCK1L.colour = BK_colour
    BKRCK1L.restpos = [Point2f(-1.0, -1.0)]
    BKRCK1L.pos[] = BKRCK1L.restpos[1]
    BKRCK1L.jitterScale = (1.0, 1.0, 1.0)
    BKRCK1L.parent = BKRCK1cL
    adopt(BKRCK1L)

    # Ca regulator
    # connector to RCK1
    BKRCK2cL = Component("BKRCK2c")
    BKRCK2cL.vertex = pillShape(0.65, 0.75*tail_length, 0.2)
    BKRCK2cL.colour = BK_colour
    BKRCK2cL.restpos = [Point2f(-1.0, -1.0)]
    BKRCK2cL.pos[] = BKRCK2cL.restpos[1]
    BKRCK2cL.jitterScale = (1.0, 1.0, 1.0)
    BKRCK2cL.parent = BKRCK1L
    adopt(BKRCK2cL)

    BKRCK2L = Component("BKRCK2L")
    BKRCK2L.vertex = pillShape(tail_length, tail_length/2.0, 1.0)
    BKRCK2L.colour = BK_colour
    BKRCK2L.restpos = [Point2f(1.0, -0.95)]
    BKRCK2L.pos[] = BKRCK2L.restpos[1]
    BKRCK2L.jitterScale = (1.0, 1.0, 1.0)
    BKRCK2L.parent = BKRCK2cL
    adopt(BKRCK2L)

    BK
end


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