return local_class("Allow", function(klass, instance)
    function klass:new(target)
        self.target = target
        self.functionName = nil
    end

    -- useless function but makes the syntax nice
    function instance:to()
        return self
    end

    function instance:to_receive(functionName)
        if functionName == nil then
            throw("to_receive() called with no functionName")
        end

        self.functionName = functionName
        self.target[functionName] = function() end

        return self
    end

    function instance:and_return(value)
        if self.functionName == nil then
            throw("and_return() must be used after to_receive()")
        end

        self.target[self.functionName] = function() return value end

        return self
    end
end)