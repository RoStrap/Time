--[[
	A class that continually calls a callback as long as a condition is true.
]]

local ConditionalPoller = {}
ConditionalPoller.__index = ConditionalPoller

function ConditionalPoller.new(interval, pollCallback, conditionCallback)
	return setmetatable({
		ConditionCallback = conditionCallback or function() return true end;
		PollCallback = pollCallback;
		Interval = interval;
		Polling = false;
		Destroyed = false;
	}, ConditionalPoller)
end

function ConditionalPoller:Poll()
	if self.Polling or self.Destroyed then
		return
	end

	self.Polling = true

	while self.ConditionCallback(self) and self.Polling do
		self.PollCallback(self)
		wait(self.Interval)
	end

	self.Polling = false
end

function ConditionalPoller:Cancel()
	self.Polling = false
end

function ConditionalPoller:Destroy()
	self:Cancel()
	self.Destroyed = true
end

return ConditionalPoller
