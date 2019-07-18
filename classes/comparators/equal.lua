local ValueBase = require('value_base.lua')

return local_class("Equal", function(klass, instance)
    klass.extend(ValueBase)

    function instance:compare()
        local pass = self.givenValue == self.expectedValue
        if self.invert then pass = not pass end
        return pass
    end

    function instance:describe()
        if self.invert then return self:describeInvert() end

        return tostring(self.givenValue) .. " == " .. tostring(self.expectedValue)
    end

    function instance:describeInvert()
        return tostring(self.givenValue) .. " ~= " .. tostring(self.expectedValue)
    end
end)