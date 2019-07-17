local Comparator = require('comparator.lua')

return local_class("Expectation", function(klass, instance)
    function klass:new()
        self.invert = false -- boolean
        self.comparator = nil -- Comparator
        self.value = nil
    end

    -- useless function but makes the syntax nice
    instance.to = function(self)
        self.invert = false
        if self.comparator then
            self.comparator.invert = self.invert
        end

        return self
    end

    instance.to_not = function(self)
        self.invert = true
        if self.comparator then
            self.comparator.invert = self.invert
        end

        return self
    end

    instance.equal = function(self, value)
        self.comparator = Comparator.Equal.new(self.value, value)
        self.comparator.invert = self.invert
    end

    instance.check = function(self)
        return self.comparator:compare()
    end
end)