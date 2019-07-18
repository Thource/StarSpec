return local_class("Base", function(klass, instance)
    function klass:new()
        self.invert = false
    end

    function instance:compare()
        return false
    end

    function instance:describe()
        return "???"
    end
end)