--@include ../star_spec.lua
require("../star_spec.lua")

--@includedir classes
util.dodir("classes")

spec(function()
    --@includedir specs
    loadDir("specs")

    -- load("specs/banana.lua")
    -- load("specs/car.lua")
end)