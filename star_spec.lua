--@include settings.txt
local Settings = require('settings.txt')

local function requireStarUtil()
    --@include lib/star_util/util.lua
    require(Settings.libPath .. "/star_util/util.lua")
    --@include lib/star_util/class.lua
    require(Settings.libPath .. "/star_util/class.lua")
end
try(requireStarUtil, function()
    throw("StarSpec depends on StarUtil: get it from https://github.com/thource/star_util")
end)

local verboseProps = find.byModel(Settings.verboseModel, function(e)
    return chip():getPos():getDistance(e:getPos()) < 200
end)
verbose = #verboseProps > 0

envPrefix = "[CLIENT] "
if SERVER then envPrefix = "[SERVER] " end

--@includedir classes
local Test = require('classes/test.lua')
local TestPlatform = require('classes/test_platform.lua')
local TestSuite = require('classes/test_suite.lua')
local Expectation = require('classes/expectation.lua')

local testPlatform, test
function spec(body)
    -- only unit test on the owner's client
    if CLIENT and owner() ~= player() then return end

    testPlatform = TestPlatform.new()

    body()
    testPlatform:run()

    testPlatform = nil
    test = nil
    describedClass = nil
end

local function getCurrentTestSuite()
    return testPlatform.testSuites[#testPlatform.testSuites]
end

local function getCurrentTest()
    local suite = getCurrentTestSuite()
    return suite.tests[#suite.tests]
end

local function describeFunction(description, body)
    local suite = getCurrentTestSuite()
    if not suite then
        throw("describe called with a string before being called with a class")
    end

    test = Test.new()
    test.testSuite = suite
    if test.description ~= "" then test.description = test.description .. " " end
    test.description = test.description .. description
    
    body()
end

local function describeClass(class, body)
    if not class then
        throw("nil class passed to describe")
    end

    local testSuite = TestSuite.new()
    testSuite.testClass = class
    describedClass = class
    table.insert(testPlatform.testSuites, testSuite)

    body()
end

function describe(...)
    if not testPlatform then
        throw("describe() called before spec()")
    end

    local args = {...}
    if type(args[1]) == "string" then
        describeFunction(...)
    else
        describeClass(...)
    end
end

function it(description, body)
    if not testPlatform then
        throw("it() called before spec()")
    end
    if not getCurrentTestSuite() then
        throw("it() called before describe()")
    end

    local testCopy = table.copy(test)
    testCopy.testSuite = test.testSuite -- we don't want to copy the test suite
    if testCopy.description ~= "" then testCopy.description = testCopy.description .. " " end
    testCopy.description = testCopy.description .. description
    
    table.insert(testCopy.testSuite.tests, testCopy)

    body()
end

function expect(value)
    local test = getCurrentTest()

    if not test then
        throw("expect() called before it()")
    end

    local expectation = Expectation.new()
    expectation.value = value

    table.insert(test.expectations, expectation)

    return expectation
end