local Comparator = require('comparator.lua')

return local_class("Expectation", function(klass, instance)
    function klass:new(target)
        self.invert = false -- boolean
        self.comparator = nil -- Comparator
        self.target = target

        local dbg = debugGetInfo(5)
        self.source = dbg.short_src:replace("SF:", "") .. ":" .. tostring(dbg.currentline)
    end

    -- useless function but makes the syntax nice
    function instance:to()
        self.invert = false
        if self.comparator then
            self.comparator.invert = self.invert
        end

        return self
    end

    function instance:to_not()
        self.invert = true
        if self.comparator then
            self.comparator.invert = self.invert
        end

        return self
    end

    function instance:equal(value)
        self.comparator = Comparator.Equal.new(self.target, value)
        self.comparator.invert = self.invert

        return self.comparator
    end

    function instance:receive(functionName)
        self.comparator = Comparator.Receive.new(self.target, functionName)
        self.comparator.invert = self.invert

        return self.comparator
    end

    function instance:check()
        return self.comparator:compare()
    end
end)