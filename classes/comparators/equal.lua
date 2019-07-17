local Base = require('base.lua')

return local_class("Equal", function(klass, instance)
    klass.extend(Base)

    instance.compare = function(self)
        local pass = self.givenValue == self.expectedValue
        if self.invert then pass = not pass end
        return pass
    end

    instance.describe = function(self)
        if self.invert then return self:describeInvert() end

        return tostring(self.givenValue) .. " == " .. tostring(self.expectedValue)
    end

    instance.describeInvert = function(self)
        return tostring(self.givenValue) .. " ~= " .. tostring(self.expectedValue)
    end
end)