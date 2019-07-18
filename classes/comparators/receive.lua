local Base = require('base.lua')

return local_class("Receive", function(klass, instance)
    klass.extend(Base)

    function klass:new(target, functionName)
        self.target = target
        self.functionName = functionName
        self.receiveCount = 0
        self.expectedReceiveCount = -1
        self.actualReturn = nil
        self.expectedReturn = nil
        self.isExpectingReturn = false -- so people can expect nil

        local originalFunction = target[functionName]
        target[functionName] = function(...)
            self.receiveCount = self.receiveCount + 1

            if originalFunction then
                return originalFunction(...)
            end
        end
    end

    function instance:once()
        self.expectedReceiveCount = 1
        
        return self
    end

    function instance:times(n)
        self.expectedReceiveCount = n
        
        return self
    end

    function instance:and_return(value)
        self.isExpectingReturn = true
        self.expectedReturn = value

        local originalFunction = self.target[self.functionName]
        self.target[self.functionName] = function(...)
            local val = originalFunction(...)

            self.actualReturn = val

            return val
        end
    end

    function instance:compare()
        local pass = self.receiveCount == self.expectedReceiveCount
        if self.expectedReceiveCount == -1 then
            pass = self.receiveCount > 0
        end

        if self.isExpectingReturn then
            pass = pass and self.actualReturn == self.expectedReturn
        end

        if self.invert then return not pass end
        return pass
    end

    function instance:describe()
        if self.invert then return self:describeInvert() end

        local description = self.functionName
        if self.expectedReceiveCount > 0 and self.receiveCount ~= self.expectedReceiveCount then
            description = description .. " called " .. tostring(self.receiveCount) .. " times (expected " .. tostring(self.expectedReceiveCount) .. ")"
        end
        if self.isExpectingReturn and self.actualReturn ~= self.expectedReturn then
            if description ~= self.functionName then
                description = description .. " and"
            end

            description = description .. " returned " .. tostring(self.actualReturn) .. " (expected " .. tostring(self.expectedReturn) .. ")"
        end

        return description
    end

    function instance:describeInvert()
        local description = self.functionName
        if self.expectedReceiveCount > 0 and self.receiveCount ~= self.expectedReceiveCount then
            description = description .. " called " .. tostring(self.receiveCount) .. " times (expected !" .. tostring(self.expectedReceiveCount) .. ")"
        end
        if self.isExpectingReturn and self.actualReturn ~= self.expectedReturn then
            if description ~= self.functionName then
                description = description .. " and"
            end

            description = description .. " returned " .. tostring(self.actualReturn) .. " (expected !" .. tostring(self.expectedReturn) .. ")"
        end

        return description
    end
end)