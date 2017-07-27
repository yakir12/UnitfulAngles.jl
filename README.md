# UnitfulAngles

[![Build Status](https://travis-ci.org/yakir12/UnitfulAngles.jl.svg?branch=master)](https://travis-ci.org/yakir12/UnitfulAngles.jl)

[![Coverage Status](https://coveralls.io/repos/yakir12/UnitfulAngles.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/yakir12/UnitfulAngles.jl?branch=master)

[![codecov.io](http://codecov.io/github/yakir12/UnitfulAngles.jl/coverage.svg?branch=master)](http://codecov.io/github/yakir12/UnitfulAngles.jl?branch=master)

A supplemental units package for `Unitful.jl`.

`UnitfulAngles.jl` introduces all the angular units found in the wikipedia [angle-article](https://en.wikipedia.org/wiki/Angle#Units). In addition to the `Radian` and `Degree` units already available in `Unitful.jl`, the following units are introduced: `Turn`, `HalfTurn`, `Quadrant`, `Sextant`, `Octant`, `ClockPosition`, `HourAngle`, `CompassPoint`, `Hexacontade`, `BinaryRadian`, `DiameterPart`, `Gradian`, `Arcminute`, and `Arcsecond`.

## Special features

- All the trigonometric functions (`sin`, `sinc`, `cos`, `cosc`, `tan`, `sec`, `csc`, and `cot`) work as expected:
```julia
julia> using UnitfulAngles

julia> sin(30u"°")
0.5

julia> cos(π*u"rad")
-1.0

julia> tan(1u"octant")
1.0
```

- In order to get inverse functions (`acos`, `acot`, `acsc`, `asec`, `asin`, `atan`, and `atan2`) to return a specific unit, specify the desired unit as the first argument: 
```julia
julia> asin(u"turn", 1)
0.25 τ
```

Because all the trigonometric functions work correctly regardless of the type of their argument, there is no need to convert between the units. However, to specifically convert one unit to the other, use `Unitful.jl`'s `uconvert` function:
```julia
julia> using Unitful

julia> uconvert(u"clockPosition", 128u"brad")
6//1 clockPosition
```

- As a bonus, you can also convert between an angle and `Dates.Time`:
```julia
julia> convert(Dates.Time, 200u"grad")
12:00:00

julia> convert(u"sextant", Dates.Time(4,0,0))
1.0 sextant
```
