local function requireStarUtil()
    --@include lib/star_util/util.lua
    require("lib/star_util/util.lua")
    --@include lib/star_util/class.lua
    require("lib/star_util/class.lua")
end
try(requireStarUtil, function()
    throw("StarSpec depends on StarUtil: get it from https://github.com/thource/star_util")
end)

local verbose = false
local cones = find.byModel("models/props_junk/trafficcone001a.mdl", function(e)
    return chip():getPos():getDistance(e:getPos()) < 200
end)
if #cones > 0 then
    verbose = true
end

local envPrefix = "[CLIENT] "
if SERVER then envPrefix = "[SERVER] " end

local TestPlatform = local_class("TestPlatform", function(klass, instance)
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
    end
end)

-- TestSuite is created on describeClass
local TestSuite = local_class("TestSuite", function(klass, instance)
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

local TestResult = local_class("TestResult", function(klass, instance)
    function klass:new()
        self.test = nil -- Test
        self.expectationsRan = 0 -- number
        self.failedExpectation = nil -- Expectation
    end

    instance.didPass = function(self)
        return self.failedExpectation == nil
    end
end)

-- TestSuite is created on it
local Test = local_class("Test", function(klass, instance)
    function klass:new()
        self.testSuite = nil -- TestSuite
        self.description = "" -- string
        self.expectations = {} -- Expectation[]
        self.result = nil -- TestResult
    end

    instance.run = function(self)
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

    instance.printResult = function(self)
        local resultAndReason = "pass"

        if not self.result:didPass() then
            resultAndReason = "fail (" .. self.result.failedExpectation.comparator:describe() .. ")"
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

local Comparator = local_class("Comparator", function(klass, instance)
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

Comparator.Equal = local_class("Equal", function(klass, instance)
    extend(Comparator)

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

local Expectation = local_class("Expectation", function(klass, instance)
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

local function appendfenv(func, appends)
    local env = table.copy(getfenv())
    for k, v in pairs(appends) do env[k] = v end
    setfenv(func, env)
end

local function expect(test, value)
    local expectation = Expectation.new()
    expectation.value = value

    table.insert(test.expectations, expectation)

    return expectation
end

local function it(test, description, body)
    local testCopy = table.copy(test)
    testCopy.testSuite = test.testSuite -- we don't want to copy the test suite
    if testCopy.description ~= "" then testCopy.description = testCopy.description .. " " end
    testCopy.description = testCopy.description .. description
    
    table.insert(testCopy.testSuite.tests, testCopy)

    appendfenv(body, {
        expect = function(value)
            return expect(testCopy, value)
        end,
        describedClass = test.testSuite.testClass
    })
    body()
end

local function describeFunction(test, description, body)
    local testCopy = table.copy(test)
    testCopy.testSuite = test.testSuite -- we don't want to copy the test suite
    if testCopy.description ~= "" then testCopy.description = testCopy.description .. " " end
    testCopy.description = testCopy.description .. description
    
    appendfenv(body, {
        describe = function(class, body)
            return describeFunction(testCopy, class, body)
        end,
        it = function(description, body)
            return it(testCopy, description, body)
        end,
        describedClass = test.testSuite.testClass
    })
    body()
end

local function describeClass(testPlatform, class, body)
    if not class then
        error("nil class passed to describe")
    end

    local testSuite = TestSuite.new()
    testSuite.testClass = class
    table.insert(testPlatform.testSuites, testSuite)
    local test = Test.new()
    test.testSuite = testSuite
    
    appendfenv(body, {
        describe = function(class, body)
            return describeFunction(test, class, body)
        end,
        it = it
    })
    body()
end

function spec(body)
    -- only unit test on the owner's client
    if CLIENT and owner() ~= player() then return end

    local testPlatform = TestPlatform.new()
    local specFuncs = {
        describe = function(class, body)
            return describeClass(testPlatform, class, body)
        end
    }
    local allFuncs = table.copy(specFuncs)
    allFuncs.load = function(path)
        local file = dofile(path)
        appendfenv(file, specFuncs)
        file()
    end
    allFuncs.loadDir = function(path)
        local files = util.dodir(path)

        for i, file in pairs(files) do
            appendfenv(file, specFuncs)
            file()
        end
    end

    appendfenv(body, allFuncs)
    body()

    --printTable(testPlatform.testSuites)
    testPlatform:run()
end