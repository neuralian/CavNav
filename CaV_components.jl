function make_CaV(location::Float64)
    # CaV channel
    CaVα1I_wide = 3.0   # width of α1.I subunit

    sLen = tail_length + 2.5 * head_width
    CaV = Component("CaV")  # channel pore is parent of other components
    CaV.vertex = Point2f[(-3.0, -sLen), (3.0, -sLen), (3.0, sLen), (-3.0, sLen)]
    CaV.colour = :lightblue
    CaV.restpos = [Point2f(location, apical_membrane_y)]
    CaV.pos[] = CaV.restpos[1]

    # gate (s6)
    CaVs6I = Component("Cavs6.I")
    CaVs6I.vertex = pillShape(2.5, 2.0 * tail_length - 1.0, 0.45)
    CaVs6I.colour = RGB(0.8, 0.7, 0.45)
    CaVs6I.jitterScale = (3.0, 1.0, 0.5)
    CaVs6I.restpos = [Point2f(-1.5, 0.0)]
    CaVs6I.pos[] = CaVs6I.restpos[1]
    CaVs6I.parent = CaV
    adopt(CaVs6I)

    CaVs6II = Component("Cavs6.II")
    CaVs6II.vertex = pillShape(2.5, 2.0 * tail_length - 1.0, 0.45)
    CaVs6II.colour = RGB(0.8, 0.7, 0.45)
    CaVs6II.jitterScale = (3.0, 1.0, 0.5)
    CaVs6II.restpos = [Point2f(1.5, 0.0)]
    CaVs6II.pos[] = CaVs6II.restpos[1]
    CaVs6II.parent = CaV
    adopt(CaVs6II)


    CaVα1I = Component("CaVα1.I")  # left α1 subunit, base element of CaV channel
    CaVα1I.vertex = pillShape(3.5, 2.0 * (tail_length + 1.25), (1.0, 1.5, 1.5, 2.0))
    CaVα1I.colour = RGB(0.9, 0.75, 0.4)
    CaVα1I.restpos = [Point2f(-2.25, 0.0)]  # position to left of pore
    CaVα1I.pos[] = CaVα1I.restpos[1]
    CaVα1I.parent = CaV
    adopt(CaVα1I)

    CaVα1II = mirrorCopy(CaVα1I, "CaVα1II")
    CaVα1II.colour = RGB(0.9, 0.75, 0.4)
    CaVα1II.restpos = [Point2f(2.25, 0.0)]  # position to right of pore
    CaVα1II.pos[] = CaVα1II.restpos[1]
    CaVα1II.parent = CaV
    adopt(CaVα1II)

    # voltage sensor (s4)
    CaVs4I = Component("Cavs4.I")
    CaVs4I.vertex = pillShape(0.65, 2.0 * tail_length - 1.0, 0.2)
    CaVs4I.colour = RGB(0.9, 0.8, 0.55)
    CaVs4I.outline = 0.1
    CaVs4I.restpos = [Point2f(-1.5, -0.75)]
    CaVs4I.pos[] = CaVs4I.restpos[1]
    CaVs4I.parent = CaV
    adopt(CaVs4I)

    CaVs4II = Component("Cavs4.II")
    CaVs4II.vertex = pillShape(0.65, 2.0 * tail_length - 1.0, 0.2)
    CaVs4II.colour = RGB(0.9, 0.8, 0.55)
    CaVs4II.outline = 0.1
    CaVs4II.restpos = [Point2f(1.5, -0.75)]
    CaVs4II.pos[] = CaVs4II.restpos[1]
    CaVs4II.parent = CaV
    adopt(CaVs4II)

    # inactivation gate, ball and chain rotating around axis
    CaVIGa = Component("CaVIG.axis")
    CaVIGa.vertex = decompose(Point2f, Circle(Point2f(0, 0), 0.25f0))
    CaVIGa.colour = RGB(0.8, 0.7, 0.45)
    CaVIGa.restpos = [Point2f(-2.5, -4.65)]
    CaVIGa.pos[] = CaVIGa.restpos[1]
    CaVIGa.jitterScale = (0.0, 0.0, 8.0)
    CaVIGa.parent = CaV
    adopt(CaVIGa)

    CaVIGc = Component("CaVIG.chain")
    CaVIGc.vertex = pillShape(1.5, 0.5, 0.2)
    CaVIGc.colour = RGB(0.9, 0.75, 0.4)
    CaVIGc.restpos = [Point2f(0.75, 0.0)]
    CaVIGc.pos[] = CaVIGc.restpos[1]
    CaVIGc.parent = CaVIGa
    adopt(CaVIGc)

    CaVIG = Component("CaVIG")
    CaVIG.vertex = decompose(Point2f, Circle(Point2f(0, 0), 1.25f0))
    CaVIG.colour = RGB(0.9, 0.75, 0.4)
    CaVIG.restpos = [Point2f(1.8, 0.0)]
    CaVIG.pos[] = CaVIG.restpos[1]
    CaVIG.parent = CaVIGc
    adopt(CaVIG)

    rotate(CaVIGa, -π / 4)

    CaV
end


