return local_class("TestResult", function(klass, instance)
    function klass:new()
        self.test = nil -- Test
        self.expectationsRan = 0 -- number
        self.failedExpectation = nil -- Expectation
    end

    instance.didPass = function(self)
        return self.failedExpectation == nil
    end
end)