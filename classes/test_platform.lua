local Settings = require('../settings.txt')

return local_class("TestPlatform", function(klass, instance)
    function klass:new()
        self.testSuites = {} -- TestSuite[]
    end

    instance.run = function(self)
        if verbose then
            print(envPrefix .. "Running tests...")
        end

        for i, testSuite in pairs(self.testSuites) do
            testSuite:run()
        end

        self:printResult()
    end

    instance.printResult = function(self)
        local testsRan = 0
        local failures = 0

        for i, testSuite in pairs(self.testSuites) do
            for i, test in pairs(testSuite.tests) do
                testsRan = testsRan + 1

                if not test.result:didPass() then
                    failures = failures + 1
                end
            end
        end

        print(envPrefix .. "Tests ran. " .. tostring(testsRan) .. " tests, " .. tostring(failures) .. " failures")
        if not verbose then
            print("For more verbose results, spawn a " .. Settings.verboseModel .. " near the chip and update the chip")
        end
    end
end)