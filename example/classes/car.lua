--@include lib/star_util/class.lua
require("lib/star_util/class.lua")

class("Car", function(klass, instance)
    function klass:new()
        self.wheels = 4
    end

    function instance:getSpeed()
        return 400
    end
end)