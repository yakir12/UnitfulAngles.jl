using Unitful, UnitfulAngles
import Dates
using Test

units = (u"doubleTurn", u"turn", u"halfTurn", u"quadrant", u"sextant", u"octant", u"clockPosition", u"hourAngle", u"compassPoint", u"hexacontade", u"brad", u"°", u"grad", u"arcminute", u"arcsecond", u"as", u"rad", u"diameterPart")
quantities = (0.5, 1, 2, 4, 6, 8, 12, 24, 32, 60, 256, 360, 400, 21600, 1296000, 1296000, 2π, 120π)

@test all(1u"turn" ≈ q*u for (q, u) in zip(quantities, units))
for _f in (:sin, :cos, :tan, :sec, :csc, :cot), (q, u) in zip(quantities, units), a in 13:17
    @test @eval $_f(2π/$a) ≈ $_f($q*$u/$a)
end

for (_f, _x) in zip((:asin, :acos, :atan, :asec, :acsc, :acot), (.5, √3/2, √3/3, 2/√3, 2, √3))
    @test @eval $_f(u"°", $_x) ≈ 30u"°"
end

# specific tests for 'as' - make sure prefixes work (all values should be equal to 1 arcsecond)
for qty in (1e24u"yas", 1e21u"zas", 1e18u"aas", 1e15u"fas", 1e12u"pas", 1e9u"nas", 1e6u"μas", 1e6u"µas", 1e3u"mas",
            1e2u"cas", 10u"das", 1u"as", 1e-1u"daas", 1e-2u"has", 1e-3u"kas", 1e-6u"Mas", 1e-9u"Gas", 1e-12u"Tas",
            1e-15u"Pas", 1e-18u"Eas", 1e-21u"Zas", 1e-24u"Yas")
    for _f in (sin, cos, tan, sec, csc, cot)
        @test  _f(qty) ≈ _f(deg2rad(1/3600))
    end
end

@test atan(u"°", 1,1) == 45u"°"

@test convert(Dates.Time, 45u"°") == Dates.Time(3,0,0)

@test convert(u"°", Dates.Time(12,0,0)) == 180u"°"

####################
# for _f in (:sin, :cos), (q, u) in zip(qrats, rats)
    # @test @eval $(Symbol("$(_f)pi"))(2) === $_f($q*$u)
# end

