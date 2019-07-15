--@include lib/star_spec.lua
require("lib/star_spec.lua")

--@includedir lib/star_spec_example/classes
dodir("lib/star_spec_example/classes")

spec(function()
    --@includedir lib/star_spec_example/specs
    loadDir("lib/star_spec_example/specs")

    -- load("lib/star_spec_example/specs/banana.lua")
    -- load("lib/star_spec_example/specs/car.lua")
end)