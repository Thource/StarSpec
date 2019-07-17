return local_class("Base", function(klass, instance)
    function klass:new(givenValue, expectedValue)
        self.givenValue = givenValue
        self.expectedValue = expectedValue
        self.invert = false
    end

    instance.compare = function(self)
        return false
    end

    instance.describe = function(self)
        return "???"
    end
end)