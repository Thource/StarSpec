local Base = require('base.lua')

return local_class("ValueBase", function(klass, instance)
    function klass:new(givenValue, expectedValue)
        self.givenValue = givenValue
        self.expectedValue = expectedValue
        self.invert = false
    end
end)