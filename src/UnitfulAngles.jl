__precompile__(true)

module UnitfulAngles

using Unitful
using Unitful: @unit, Quantity, NoDims
export @u_str

import Base: sin, cos, tan, sec, csc, cot, asin, acos, atan, asec, acsc, acot, atan2, convert

######################### Angle units ##########################################
@unit doubleTurn    "§"             DoubleTurn    4π*u"rad"     false # = 2*turn
@unit turn          "τ"             Turn          2π*u"rad"     false
@unit halfTurn      "π"             HalfTurn      turn//2       false
@unit quadrant      "⦜"             Quadrant      turn//4       false
@unit sextant       "sextant"       Sextant       turn//6       false
@unit octant        "octant"        Octant        turn//8       false
@unit clockPosition "clockPosition" ClockPosition turn//12      false
@unit hourAngle     "hourAngle"     HourAngle     turn//24      false
@unit compassPoint  "compassPoint"  CompassPoint  turn//32      false
@unit hexacontade   "hexacontade"   Hexacontade   turn//60      false
@unit brad          "brad"          BinaryRadian  turn//256     false
@unit diameterPart  "diameterPart"  DiameterPart  1u"rad"/60    false # ≈ turn/377
@unit grad          "ᵍ"             Gradian       turn//400     false
@unit arcminute     "′"             Arcminute     u"°"//60      false # = turn/21,600
@unit arcsecond     "″"             Arcsecond     u"°"//3600    false # = turn/1,296,000

######################### Functions ############################################

# cos and sin have *pi versions, and *d versions
for _f in (:cos, :sin)
    @eval $_f{T}(x::Quantity{T, typeof(NoDims), typeof(halfTurn)}) = $(Symbol("$(_f)pi"))(ustrip(x))
    @eval $_f{T}(x::Quantity{T, typeof(NoDims), typeof(diameterPart)}) = $_f(ustrip(uconvert(u"rad", x)))
    for _u in (doubleTurn, turn, quadrant, sextant, octant, clockPosition, hourAngle, compassPoint, hexacontade, brad, grad, arcminute, arcsecond)
        @eval $_f{T}(x::Quantity{T, typeof(NoDims), typeof($_u)}) = $(Symbol("$(_f)pi"))(ustrip(uconvert(halfTurn, x)))
    end
end

# These functions don't have *pi versions, but have *d versions
for _f in (:tan, :sec, :csc, :cot)
    @eval $_f{T}(x::Quantity{T, typeof(NoDims), typeof(diameterPart)}) = $_f(ustrip(uconvert(u"rad", x)))
    for _u in (doubleTurn, turn, halfTurn, quadrant, sextant, octant, clockPosition, hourAngle, compassPoint, hexacontade, brad, grad, arcminute, arcsecond)
        @eval $_f{T}(x::Quantity{T, typeof(NoDims), typeof($_u)}) = $(Symbol("$(_f)d"))(ustrip(uconvert(u"°", x)))
    end
end

# Inverse functions
for _f in (:acos, :asin, :atan, :asec, :acsc, :acot),
    _u in (diameterPart, u"°", u"rad", doubleTurn, turn, halfTurn, quadrant, sextant, octant, clockPosition, hourAngle, compassPoint, hexacontade, brad, grad, arcminute, arcsecond)
    @eval $_f(::typeof($_u), x::Number) = uconvert($_u, $_f(x)*u"rad")
end

for _u in (diameterPart, u"°", u"rad", doubleTurn, turn, halfTurn, quadrant, sextant, octant, clockPosition, hourAngle, compassPoint, hexacontade, brad, grad, arcminute, arcsecond)
    @eval atan2(::typeof($_u), y::Number, x::Number) = uconvert($_u, atan2(y, x)*u"rad")
end

# Fun conversion between time and angles
# NOTE: not sure whether to use `convert` or `uconvert`
for _u in (diameterPart, u"°", u"rad", doubleTurn, turn, halfTurn, quadrant, sextant, octant, clockPosition, hourAngle, compassPoint, hexacontade, brad, grad, arcminute, arcsecond)
    @eval begin
        function convert(::typeof($_u), t::Dates.Time)
            x = t - Dates.Time(0, 0, 0)
            S = typeof(x)
            uconvert($_u, x/convert(S, Dates.Hour(1))*hourAngle)
        end
    end
    @eval convert{T}(::Type{Dates.Time}, x::Quantity{T, typeof(NoDims), typeof($_u)}) = Dates.Time(0, 0, 0) + Dates.Nanosecond(round(Int, ustrip(uconvert(hourAngle, x))*3600000000000))
end

# Enable precompilation with Unitful extended units
# http://ajkeller34.github.io/Unitful.jl/stable/extending/#precompilation
const localunits = Unitful.basefactors
function __init__()
    merge!(Unitful.basefactors, localunits)
    Unitful.register(UnitfulAngles)
end

end # module
