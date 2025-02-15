local Package = game:GetService("ReplicatedStorage").Fusion
local semiWeakRef = require(Package.Instances.semiWeakRef)
local onDestroy = require(Package.Instances.onDestroy)

return function()
	it("should run on explicit :Destroy()", function()
		local instance = Instance.new("Folder")
		local didRun = false
		onDestroy(semiWeakRef(instance), function()
			didRun = true
		end)
		instance:Destroy()
		task.wait()
		expect(didRun).to.equal(true)
	end)

	it("should run on garbage collect", function()
		local instance = Instance.new("Folder")
		local didRun = false
		onDestroy(semiWeakRef(instance), function()
			didRun = true
		end)
		instance = nil

		-- do a short timeout to give the gc time to run
		local startTime = os.clock()
		repeat
			task.wait()
		until didRun or os.clock() > startTime + 5

		expect(didRun).to.equal(true)
	end)

	it("should not run if the instance is still accessible", function()
		local instance = Instance.new("Folder")
		instance.Name = "FUSIONDELETETHIS"
		instance.Parent = game

		local didRun = false
		onDestroy(semiWeakRef(instance), function()
			didRun = true
		end)
		instance = nil

		-- do a short timeout to give the gc time to run
		local startTime = os.clock()
		repeat
			task.wait()
		until didRun or os.clock() > startTime + 5

		expect(didRun).to.equal(false)

		game.FUSIONDELETETHIS:Destroy()
	end)

	it("should forward arguments to the callback", function()
		local instance = Instance.new("Folder")
		local argsMatch = false
		onDestroy(semiWeakRef(instance), function(a, b, c)
			argsMatch = a == 2 and b == true and c == "foo"
		end, 2, true, "foo")
		instance:Destroy()
		task.wait()
		expect(argsMatch).to.equal(true)
	end)
end