__precompile__(true)

module UnitfulAngles

using Unitful
using Unitful: @unit, Quantity, NoDims, FreeUnits
import Base: sin, cos, tan, sec, csc, cot, asin, acos, atan, asec, acsc, acot, atan2, convert

# export arcsin, arccos, arctan, arcsec, arccsc, arccot, arctan2

######################### Angle units ##########################################
@unit turn          "τ"             Turn          1             false
@unit halfTurn      "π"             HalfTurn      turn//2       false
@unit quadrant      "⦜"             Quadrant      turn//4       false
@unit sextant       "sextant"       Sextant       turn//6       false
@unit myRad         "myRad"         MyRadian      turn/2π       false
@unit octant        "octant"        Octant        turn//8       false
@unit clockPosition "clockPosition" ClockPosition turn//12      false
@unit hourAngle     "hourAngle"     HourAngle     turn//24      false
@unit compassPoint  "compassPoint"  CompassPoint  turn//32      false
@unit hexacontade   "hexacontade"   Hexacontade   turn//60      false
@unit brad          "brad"          BinaryRadian  turn//256     false
@unit my°           "my°"           MyDegree      turn//360     false
@unit diameterPart  "diameterPart"  DiameterPart  myRad/60      false
@unit grad          "ᵍ"             Gradian       turn//400     false
@unit arcminute     "′"             Arcminute     turn//21600   false
@unit arcsecond     "″"             Arcsecond     turn//1296000 false

######################### Functions ############################################

# cos and sin have *pi versions, and *d versions
for _f in (:cos, :sin)
    @eval $_f{T}(x::Quantity{T,typeof(NoDims),typeof(halfTurn)}) = $(Symbol("$(_f)pi"))(ustrip(x))
    @eval $_f{T}(x::Quantity{T,typeof(NoDims),typeof(my°)}) = $(Symbol("$(_f)d"))(ustrip(x))
    @eval $_f{T}(x::Quantity{T,typeof(NoDims),typeof(myRad)}) = $_f(ustrip(x))
    @eval $_f{T}(x::Quantity{T,typeof(NoDims),typeof(diameterPart)}) = $_f(ustrip(uconvert(myRad, x)))
    for _x in (turn, quadrant, sextant, octant, clockPosition, hourAngle, compassPoint, hexacontade, brad, grad, arcminute, arcsecond)
        @eval $_f{T}(x::Quantity{T,typeof(NoDims),typeof($_x)}) = $(Symbol("$(_f)pi"))(ustrip(uconvert(halfTurn, x)))
    end
end

# These functions don't have *pi versions, but have *d versions
for _f in (:tan, :sec, :csc, :cot)
    @eval $_f{T}(x::Quantity{T,typeof(NoDims),typeof(my°)}) = $(Symbol("$(_f)d"))(ustrip(x))
    @eval $_f{T}(x::Quantity{T,typeof(NoDims),typeof(myRad)}) = $_f(ustrip(x))
    for _x in (turn, halfTurn, quadrant, sextant, octant, clockPosition, hourAngle, compassPoint, hexacontade, brad, diameterPart, grad, arcminute, arcsecond)
        @eval $_f{T}(x::Quantity{T,typeof(NoDims),typeof($_x)}) = $_f(ustrip(uconvert(myRad, x)))
    end
end

# Inverse functions
for _f in (:acos, :asin, :atan, :asec, :acsc, :acot)
    # @eval $(Symbol("arc$(_f)"))(x::Number) = $(Symbol("a$(_f)"))(x)*myRad
    @eval $_f(T::FreeUnits, x::Number) = uconvert(T, $_f(x)*myRad)
end
atan2(T::FreeUnits, y::Number, x::Number) = uconvert(T, atan2(y, x)*myRad)

# Fun conversion between time and angles
# NOTE: not sure if to use `convert` or `uconvert`
function convert(T::FreeUnits, t::Dates.Time)
    x = t - Dates.Time(0,0,0)
    S = typeof(x)
    uconvert(T, x/convert(S, Dates.Hour(1))*hourAngle)
end
convert(::Type{Dates.Time}, x::Quantity) = Dates.Time(0,0,0) + Dates.Nanosecond(round(Int, ustrip(uconvert(hourAngle, x))*3600000000000))


# As per the Unitful documentation
const localunits = Unitful.basefactors
function __init__()
    merge!(Unitful.basefactors, localunits)
    Unitful.register(UnitfulAngles)
end

end # module
