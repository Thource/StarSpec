class("Banana", function(klass, instance)
    function klass:new()
        self.isYellow = true
    end

    function klass.isBananaClass()
        return true
    end

    function instance:isFruit()
        return true
    end

    function instance:isAYellowFruit()
        return self:isFruit() and self.isYellow
    end
end)