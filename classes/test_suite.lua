return local_class("TestSuite", function(klass, instance)
    function klass:new()
        self.testClass = nil -- Class
        self.tests = {} -- Test[]
    end

    instance.run = function(self)
        if verbose then
            print(envPrefix .. "Testing " .. self.testClass.name)
        end

        for i, test in pairs(self.tests) do
            test:run()
        end

        if verbose then
            self:printResult()
        end
    end

    instance.printResult = function(self)
        local testsRan = 0
        local failures = 0

        for i, test in pairs(self.tests) do
            testsRan = testsRan + 1

            if not test.result:didPass() then
                failures = failures + 1
            end
        end

        print(envPrefix .. self.testClass.name .. ": " .. tostring(testsRan) .. " tests, " .. tostring(failures) .. " failures")
    end
end)