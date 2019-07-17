describe(Banana, function()
    describe(".new", function()
        it("has the correct attrs assigned", function()
            local subject = describedClass.new()

            expect(subject.isYellow):to():equal(true)
        end)
    end)

    describe("#isFruit", function()
        it("returns true", function()
            local subject = describedClass.new()

            expect(subject:isFruit()):to():equal(true)
        end)
    end)
end)