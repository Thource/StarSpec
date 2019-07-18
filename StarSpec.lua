--@include settings.txt
local Settings = require('settings.txt')

local function requireStarUtil()
    --@include lib/StarUtil/util.lua
    require(Settings.libPath .. "/StarUtil/util.lua")
    --@include lib/StarUtil/class.lua
    require(Settings.libPath .. "/StarUtil/class.lua")
end
try(requireStarUtil, function()
    throw("StarSpec depends on StarUtil: get it from https://github.com/thource/StarUtil")
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
local Allow = require('classes/allow.lua')
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

function context(description, body)
    if not testPlatform then
        throw("context() called before spec()")
    end

    local suite = getCurrentTestSuite()
    if not suite then
        throw("context() called before describe()")
    end

    test = Test.new()
    test.testSuite = suite
    if test.description ~= "" then test.description = test.description .. " " end
    test.description = test.description .. description
    
    body()
end

function clone(obj, seen)
    -- Handle non-tables and previously-seen tables.
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end

    -- New table; mark it as seen an copy recursively.
    local s = seen or {}
    s[obj] = res
    for k, v in pairs(obj) do
        res[clone(k, s)] = clone(v, s)
    end
    return res
end

function it(description, itBody)
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

    setfenv(itBody, table.copy(_G))
    itBody()
end

function expect(target)
    local test = getCurrentTest()

    if not test then
        throw("expect() called before it()")
    end

    local expectation = Expectation.new(target)

    table.insert(test.expectations, expectation)

    return expectation
end

function allow(target)
    local test = getCurrentTest()

    if not test then
        throw("allow() called before it()")
    end

    local allow = Allow.new(target)

    return allow
end