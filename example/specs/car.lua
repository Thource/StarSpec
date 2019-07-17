describe(Car, function()
    describe(".new", function()
        it("has the correct attrs assigned", function()
            local subject = describedClass.new()

            expect(subject.wheels):to():equal(4)
        end)
    end)

    describe("#getSpeed", function()
        it("returns 400", function()
            local subject = describedClass.new()

            expect(subject:getSpeed()):to():equal(400)
        end)
    end)
end)