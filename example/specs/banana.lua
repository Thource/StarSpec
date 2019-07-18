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

            printTable(subject)

            expect(subject:isFruit()):to():equal(true)
        end)
    end)

    describe("#isAYellowFruit", function()
        it("returns true", function()
            local subject = describedClass.new()

            expect(subject:isFruit()):to():equal(true)
        end)

        context("when isFruit is mocked to return false", function()
            it("returns false", function()
                local subject = describedClass.new()

                allow(subject):to_receive('isFruit'):and_return(false)

                expect(subject):to():receive('isFruit'):once():and_return(false)
    
                expect(subject:isFruit()):to():equal(false)
            end)
        end)
    end)

    describe(".isBananaClass", function()
        context("when mocked to return false", function()
            it("returns false", function()
                allow(describedClass):to_receive('isBananaClass'):and_return(false)

                expect(describedClass.isBananaClass()):to():equal(false)
            end)
        end)

        it("resets and returns true again", function()
            expect(describedClass.isBananaClass()):to():equal(true)
        end)
    end)
end)