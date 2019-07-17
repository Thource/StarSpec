class("Banana", function(klass, instance)
    function klass:new()
        self.isYellow = true
    end

    function instance:isFruit()
        return true
    end
end)