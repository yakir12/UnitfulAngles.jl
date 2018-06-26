using Unitful, UnitfulAngles
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

units = (u"doubleTurn", u"turn", u"halfTurn", u"quadrant", u"sextant", u"octant", u"clockPosition", u"hourAngle", u"compassPoint", u"hexacontade", u"brad", u"°", u"grad", u"arcminute", u"arcsecond", u"rad", u"diameterPart")
quantities = (0.5, 1, 2, 4, 6, 8, 12, 24, 32, 60, 256, 360, 400, 21600, 1296000, 2π, 120π)

@test all(1u"turn" ≈ q*u for (q, u) in zip(quantities, units))
for _f in (:sin, :cos, :tan, :sec, :csc, :cot), (q, u) in zip(quantities, units), a in 13:17
    @test @eval $_f(2π/$a) ≈ $_f($q*$u/$a)
end

for (_f, _x) in zip((:asin, :acos, :atan, :asec, :acsc, :acot), (.5, √3/2, √3/3, 2/√3, 2, √3))
    @test @eval $_f(u"°", $_x) ≈ 30u"°"
end

@test atan2(u"°", 1,1) == 45u"°"

@test convert(Dates.Time, 45u"°") == Dates.Time(3,0,0)

@test convert(u"°", Dates.Time(12,0,0)) == 180u"°"

####################
# for _f in (:sin, :cos), (q, u) in zip(qrats, rats)
    # @test @eval $(Symbol("$(_f)pi"))(2) === $_f($q*$u)
# end

