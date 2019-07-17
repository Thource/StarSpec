--@include ../star_spec.lua
require("../star_spec.lua")

--@includedir classes
util.dodir("classes")

spec(function()
    --@includedir specs
    util.dodir("specs")

    -- dofile("specs/banana.lua")
    -- dofile("specs/car.lua")
end)