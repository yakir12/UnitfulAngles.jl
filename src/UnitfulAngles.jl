module UnitfulAngles

import Unitful
import Dates
using Unitful: @unit, Quantity, NoDims, @u_str, uconvert, ustrip
import Unitful: rad, °
import Base: sin, cos, tan, sec, csc, cot, asin, acos, atan, asec, acsc, acot, convert


######################### Angle units ##########################################
@unit turn          "τ"             Turn           2π*rad        false
@unit doubleTurn    "§"             DoubleTurn     2turn         false
@unit halfTurn      "π"             HalfTurn       turn//2       false
@unit quadrant      "⦜"             Quadrant       turn//4       false
@unit sextant       "sextant"       Sextant        turn//6       false
@unit octant        "octant"        Octant         turn//8       false
@unit clockPosition "clockPosition" ClockPosition  turn//12      false
@unit hourAngle     "hourAngle"     HourAngle      turn//24      false
@unit compassPoint  "compassPoint"  CompassPoint   turn//32      false
@unit hexacontade   "hexacontade"   Hexacontade    turn//60      false
@unit brad          "brad"          BinaryRadian   turn//256     false
@unit diameterPart  "diameterPart"  DiameterPart   rad//60       false # ≈ turn/377
@unit grad          "ᵍ"             Gradian        turn//400     false
@unit arcminute     "′"             Arcminute      °//60         false # = turn/21,600
@unit arcsecond     "″"             Arcsecond      °//3600       false # = turn/1,296,000
# enable shorthand for arcseconds: e.g., 'mas' - milliarcsecond
@unit as            "as"            ArcsecondShort °//3600       true

######################### Functions ############################################

# cos and sin have *pi versions, and *d versions
for _f in (:cos, :sin)
    @eval $_f(x::Quantity{T, NoDims, typeof(halfTurn)}) where {T} = $(Symbol("$(_f)pi"))(ustrip(x))
    @eval $_f(x::Quantity{T, NoDims, typeof(diameterPart)}) where {T} = $_f(ustrip(uconvert(rad, float(x))))
    for _u in (doubleTurn, turn, quadrant, sextant, octant, clockPosition, hourAngle, compassPoint, hexacontade, brad, grad, arcminute, arcsecond)
        @eval $_f(x::Quantity{T, NoDims, typeof($_u)}) where {T} = $(Symbol("$(_f)pi"))(ustrip(uconvert(halfTurn, float(x))))
    end
end

# These functions don't have *pi versions, but have *d versions
for _f in (:tan, :sec, :csc, :cot)
    @eval $_f(x::Quantity{T, NoDims, typeof(diameterPart)}) where {T} = $_f(ustrip(uconvert(rad, x)))
    for _u in (doubleTurn, turn, halfTurn, quadrant, sextant, octant, clockPosition, hourAngle, compassPoint, hexacontade, brad, grad, arcminute, arcsecond)
        @eval $_f(x::Quantity{T, NoDims, typeof($_u)}) where {T} = $(Symbol("$(_f)d"))(ustrip(uconvert(°, float(x))))
    end
end

# Inverse functions
for _f in (:acos, :asin, :atan, :asec, :acsc, :acot),
    _u in (diameterPart, °, rad, doubleTurn, turn, halfTurn, quadrant, sextant, octant, clockPosition, hourAngle, compassPoint, hexacontade, brad, grad, arcminute, arcsecond)
    @eval $_f(::typeof($_u), x::Number) = uconvert($_u, $_f(x)*rad)
end

for _u in (diameterPart, °, rad, doubleTurn, turn, halfTurn, quadrant, sextant, octant, clockPosition, hourAngle, compassPoint, hexacontade, brad, grad, arcminute, arcsecond)
    @eval atan(::typeof($_u), y::Number, x::Number) = uconvert($_u, atan(y, x)*rad)
end

_tohour(x::T) where {T <: Dates.TimePeriod} = x/convert(T, Dates.Hour(1)) # credit to kristoffer.carlsson see https://discourse.julialang.org/t/convert-time-interval-to-seconds/3806/2

# Fun conversion between time and angles
# NOTE: not sure whether to use `convert` or `uconvert`
for _u in (diameterPart, °, rad, doubleTurn, turn, halfTurn, quadrant, sextant, octant, clockPosition, hourAngle, compassPoint, hexacontade, brad, grad, arcminute, arcsecond)
    @eval begin
        function convert(::typeof($_u), t::Dates.Time)
            x = t - Dates.Time(0, 0, 0)
            uconvert($_u, _tohour(x)*hourAngle)
        end
    end
    @eval convert(::Type{Dates.Time}, x::Quantity{T, NoDims, typeof($_u)}) where {T} = Dates.Time(0, 0, 0) + Dates.Nanosecond(round(Int, ustrip(uconvert(hourAngle, x))*3600000000000))
end

# Enable precompilation with Unitful extended units
# http://ajkeller34.github.io/Unitful.jl/stable/extending/#precompilation
const localunits = Unitful.basefactors
function __init__()
    merge!(Unitful.basefactors, localunits)
    Unitful.register(UnitfulAngles)
end

end # module
