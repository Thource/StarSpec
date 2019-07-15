--@include lib/star_spec/star_spec.lua
require("lib/star_spec/star_spec.lua")

--@includedir lib/star_spec/example/classes
dodir("lib/star_spec/example/classes")

spec(function()
    --@includedir lib/star_spec/example/specs
    loadDir("lib/star_spec/example/specs")

    -- load("lib/star_spec/example/specs/banana.lua")
    -- load("lib/star_spec/example/specs/car.lua")
end)