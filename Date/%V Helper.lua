-- Functions that work for "%V" because I couldn't figure out the proper math. Send help please
-- https://github.com/Tieske/date

local isowy do
	local floor = math.floor
	local function mod(n,d) return n - d*floor(n/d) end

	local function dayfromyear(y) -- y must be int!
		return 365*y + floor(y/4) - floor(y/100) + floor(y/400)
	end

	local function breakdaynum(g)
		local g = g + 306
		local y = floor((10000*g + 14780)/3652425)
		local d = g - dayfromyear(y)
		if d < 0 then y = y - 1; d = g - dayfromyear(y) end
		local mi = floor((100*d + 52)/3060)
		return (floor((mi + 2)/12) + y), mod(mi + 2,12), (d - floor((mi*306 + 5)/10) + 1)
	end

	local function weekday(dn) return mod(dn + 1, 7) end

	local function makedaynum(y, m, d)
		local mm = mod(mod(m,12) + 10, 12)
		return dayfromyear(y + floor(m/12) - floor(mm/10)) + floor((mm*306 + 5)/10) + d - 307
	end

	-- get daynum of isoweek one of year y
	local function isow1(y)
		local f = makedaynum(y, 0, 4) -- get the date for the 4-Jan of year `y`
		local d = weekday(f)
		d = d == 0 and 7 or d -- get the ISO day number, 1 == Monday, 7 == Sunday
		return f + (1 - d)
	end

	function isowy(dn)
		local w1;
		local y = (breakdaynum(dn))
		if dn >= makedaynum(y, 11, 29) then
			w1 = isow1(y + 1);
			if dn < w1 then
				w1 = isow1(y);
			else
				y = y + 1;
			end
		else
			w1 = isow1(y);
			if dn < w1 then
				w1 = isow1(y-1)
				y = y - 1
			end
		end
		return floor((dn-w1)/7)+1, y
	end
end

local CountDays do
	local floor = math.floor

	local function GetLeaps(year)
		--- Returns the number of Leap days in a given amount of years
		return floor(year / 4) - floor(year / 100) + floor(year / 400)
	end

	function CountDays(year)
		--- Returns the number of days in a given number of years
		return 365*year + GetLeaps(year)
	end
end

--[[
local YearWhichMostDaysOfWeekAreWithin = YearWhichMostDaysOfThisWeekAreWithin(TimeData)

local FirstWeekOffset do
	local FirstWeekDay = (TimeData.wday - TimeData.yday + 1) % 7
	local FirstWeekHas4OrMoreDays = 1 < FirstWeekDay and FirstWeekDay < 6
	FirstWeekOffset = FirstWeekHas4OrMoreDays and 1 or 0
end

-- print(YearWhichMostDaysOfWeekAreWithin < TimeData.year and 1 or YearWhichMostDaysOfWeekAreWithin > TimeData.year and 2 or YearWhichMostDaysOfWeekAreWithin == TimeData.year and 3)

if YearWhichMostDaysOfWeekAreWithin < TimeData.year then
	TimeData = os_date("!*t", os.time{month = 12; day = 31; year = YearWhichMostDaysOfWeekAreWithin})
elseif YearWhichMostDaysOfWeekAreWithin > TimeData.year then
	return "01"
end

local WeekOfYear = Tags["#W"](TimeData)
return ("%02d"):format(FirstWeekOffset + WeekOfYear)
--]]
--[[
local FirstWeekDay = (TimeData.wday - TimeData.yday + 1) % 7
local FirstWeekHas4OrMoreDays = 1 < FirstWeekDay and FirstWeekDay < 6

local Offset = TimeData.wday - 2
local WeekNumber = math.ceil((TimeData.yday - (Offset == -1 and 6 or Offset)) / 7) + (FirstWeekHas4OrMoreDays and 1 or 0)

if WeekNumber == 54 then
	return "01"
else
	return 0 < WeekNumber and ("%02d"):format(WeekNumber) or
end
--]]
--[[
local FirstWeekOffset do
	local FirstWeekDay = (TimeData.wday - TimeData.yday + 1) % 7
	local FirstWeekHas4OrMoreDays = 1 < FirstWeekDay and FirstWeekDay < 6
	FirstWeekOffset = FirstWeekHas4OrMoreDays and 1 or 0
end

local Offset = TimeData.wday - 2
local PreviousMonday = TimeData.yday - (Offset == -1 and 6 or Offset) -- [0, 6]
local Divisible = PreviousMonday % 7
local WeekOfYear = Divisible == 0 and PreviousMonday / 7 or 1 + (PreviousMonday - Divisible) / 7
--]]
-- Tests:
-- print(Date("%c %U %W %V %G", os.time{month = 12; day = 31; year = 2015}))
-- for y = 2000, 2020 do print(Date("%c %U %W %V %G", os.time{month = 1; day = 1; year = y})) end

return {
	isowy = isowy;
	CountDays = CountDays;
}
