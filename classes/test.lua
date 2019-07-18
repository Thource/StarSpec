local TestResult = require('test_result.lua')

return local_class("Test", function(klass, instance)
    function klass:new()
        self.testSuite = nil -- TestSuite
        self.description = "" -- string
        self.expectations = {} -- Expectation[]
        self.result = nil -- TestResult
    end

    function instance:run()
        self.result = TestResult.new()
        self.result.test = self

        for i, expectation in pairs(self.expectations) do
            self.result.expectationsRan = self.result.expectationsRan + 1

            if not expectation:check() then
                self.result.failedExpectation = expectation

                break
            end
        end

        if verbose then
            self:printResult()
        end
    end

    function instance:printResult()
        local resultAndReason = "pass"

        if not self.result:didPass() then
            resultAndReason = "fail (" .. self.result.failedExpectation.comparator:describe() .. ") @ " .. self.result.failedExpectation.source
        end

        local message = self.description .. ": " .. resultAndReason

        if CLIENT then
            printMessage(2, envPrefix .. message .. "\n")
        else
            -- TODO: find a way to print to console from SERVER
            print(envPrefix .. message)
        end
    end
end)