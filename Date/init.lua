-- Time and Date formatter mimicking the vanilla os.date function
-- @readme https://github.com/RoStrap/Time/blob/master/README.md
-- @author Validark

local V_Helper = require(script:FindFirstChild("V_Helper"))

local Suffixes = {"st", "nd", "rd"}
local DayNames = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
local MonthNames = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}

local CHAR_EXCLAMATION = ("!"):byte()

local Patterns = {
	c = "%a %b %e %X %Y";
	D = "%m/%d/%y";
	F = "%Y-%m-%d";
	n = "\n";
	R = "%H:%M";
	r = "%I:%M:%S %p";
	T = "%I:%M %p";
	t = "\t";
	v = "%e-%b-%Y";
	X = "%H:%M:%S";
	x = "%m/%d/%y";

	["#c"] = "%#x, %#X";
	["#r"] = "%#I:%M:%S %p";
	["#T"] = "%#I:%M %p";
	["#X"] = "%#H:%M:%S";
	["#x"] = "%A, %B %#d, %#Y";
}

for Tag, Pattern in next, Patterns do
	Patterns[Tag] = Pattern:gsub("%%(#?%a)", Patterns)
end

local os_date = os.date

local TimeZoneOffset, TimeZoneOffset2 do
	local TimeData = os_date("*t")
	local Data = os_date("*t", os.time(TimeData))
	local Deviation = (60 * Data.hour + Data.min) - (60 * TimeData.hour + TimeData.min)
	local AbsoluteDeviation = math.abs(Deviation)

	TimeZoneOffset2 = ("%s%02d:%02d"):format(Deviation < 0 and "-" or "+", AbsoluteDeviation / 60, AbsoluteDeviation % 60)
	TimeZoneOffset = TimeZoneOffset2:gsub(":", "", 1)
end

local function YearWhichMostDaysOfThisWeekAreWithin(TimeData)
	-- Returns whether most days of this week are outside this year
	-- @returns TimeData.year + 0 if most days of this week are in this year
	-- @returns TimeData.year + 1 if most days of this week are in next year
	-- @returns TimeData.year - 1 if most days of this week are in last year
	-- Note: Treats Monday as the beginning of the week

	local yday = TimeData.yday

	if yday < 4 then
		local wday = TimeData.wday == 1 and 6 or TimeData.wday - 2 -- [0, 6] Monday as Beginning
		local MondayOfWeek = TimeData.day - wday -- Get the TimeData.day of the first day of this week
		return MondayOfWeek < -2 and TimeData.year - 1 or TimeData.year
	elseif yday > 362 then
		local wday = TimeData.wday == 1 and 6 or TimeData.wday - 2 -- [0, 6] Monday as Beginning
		local MondayOfWeek = TimeData.day - wday -- Get the TimeData.day of the first day of this week
		return MondayOfWeek > 28 and TimeData.year + 1 or TimeData.year
	end

	return TimeData.year
end

local Tags

Tags = setmetatable({
	-- Sources
	-- https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man3/strftime.3.html
	-- https://msdn.microsoft.com/en-us/library/fe06s4ak.aspx

	["%"] = function() return "%" end;

	A = function(TimeData) -- Full weekday name
		return DayNames[TimeData.wday]
	end;

	a = function(TimeData) -- Abbreviated weekday name
		return DayNames[TimeData.wday]:sub(1, 3)
	end;

	B = function(TimeData) -- Full month name
		return MonthNames[TimeData.month]
	end;

	b = function(TimeData) -- Abbreviated month name
		return MonthNames[TimeData.month]:sub(1, 3)
	end;

	C = function(TimeData) -- (year / 100) as decimal number; single digits are preceded by a zero
		return ("%02d"):format(TimeData.year / 100)
	end;

	["#C"] = function(TimeData) -- (year / 100) as decimal number
		return (TimeData.year - TimeData.year % 100) / 100
	end;

	d = function(TimeData) -- Day of month as decimal number [01, 31]
		return ("%02d"):format(TimeData.day)
	end;

	["#d"] = function(TimeData) -- Day of month as decimal number [1, 31]
		return TimeData.day
	end;

	e = function(TimeData) -- Day of month as decimal number [ 1, 31]
		return ("%2d"):format(TimeData.day)
	end;

	G = function(TimeData)
		-- %G is replaced by a year as a decimal number with century.
		-- This year is the one that contains the greater part of the week (Monday as the first day of the week)

		return ("%04d"):format(YearWhichMostDaysOfThisWeekAreWithin(TimeData))
	end;

	g = function(TimeData)
		-- %g is replaced by the same year as in %G, but as a decimal number without century (00-99).

		return ("%02d"):format(YearWhichMostDaysOfThisWeekAreWithin(TimeData) % 100)
	end;

	H = function(TimeData) -- Hour in 24-hour format [00, 23]
		return ("%02d"):format(TimeData.hour)
	end;

	["#H"] = function(TimeData) -- Hour in 24-hour format [0, 23]
		return TimeData.hour
	end;

	I = function(TimeData) -- Hour in 12-hour format [01, 12]
		local Hours = TimeData.hour
		return ("%02d"):format(Hours > 12 and Hours - 12 or Hours == 0 and 12 or Hours)
	end;

	["#I"] = function(TimeData) -- Hour in 12-hour format [1, 12]
		local Hours = TimeData.hour
		return Hours > 12 and Hours - 12 or Hours == 0 and 12 or Hours
	end;

	j = function(TimeData) -- Day of year as decimal number [001, 366]
		return ("%03d"):format(TimeData.yday)
	end;

	["#j"] = function(TimeData) -- Day of year as decimal number [1, 366]
		return TimeData.yday
	end;

	k = function(TimeData) -- Hour in 24-hour format [ 0, 23]
		return ("%2d"):format(TimeData.hour)
	end;

	l = function(TimeData) -- Hour in 12-hour format [ 1, 12]
		local Hours = TimeData.hour
		return ("%2d"):format(Hours > 12 and Hours - 12 or Hours == 0 and 12 or Hours)
	end;

	M = function(TimeData) -- Minute as decimal number [00, 59]
		return ("%02d"):format(TimeData.min)
	end;

	["#M"] = function(TimeData) -- Minute as decimal number [0, 59]
		return TimeData.min
	end;

	m = function(TimeData) -- Month as decimal number [01, 12]
		return ("%02d"):format(TimeData.month)
	end;

	["#m"] = function(TimeData) -- Month as decimal number [1, 12]
		return TimeData.month
	end;

	p = function(TimeData) -- Current locale's AM/PM indicator for 12-hour clock
		return TimeData.hour > 11 and "PM" or "AM"
	end;

	["#p"] = function(TimeData) -- Current locale's am/pm indicator for 12-hour clock
		return TimeData.hour > 11 and "pm" or "am"
	end;

	S = function(TimeData) -- Second as decimal number [00, 59]
		return ("%02d"):format(TimeData.sec)
	end;

	["#S"] = function(TimeData) -- Second as decimal number [0, 59]
		return TimeData.sec
	end;

	s = function(TimeData) -- Day of year suffix: e.g. 12th, 31st, 22nd
		local Days = TimeData.day
		return (Days < 21 and Days > 3 or Days > 23 and Days < 31) and "th" or Suffixes[Days % 10]
	end;

	U = function(TimeData) -- Week of year, Sunday Based [00, 53]
		local x = (TimeData.yday - TimeData.wday)
		return ("%02d"):format(1 + (x - x % 7) / 7)
	end;

	["#U"] = function(TimeData) -- Week of year, Sunday Based [0, 53]
		local x = (TimeData.yday - TimeData.wday)
		return 1 + (x - x % 7) / 7
	end;

	u = function(TimeData) -- Weekday (Monday as first day of week) [1, 7]
		return TimeData.wday == 1 and 7 or TimeData.wday - 1
	end;

	V = function(TimeData)
		-- Validark tried to write logic for this but couldn't get the math to work. Pls help
		-- replaced by the week number of the year (Monday as the first day of the week) as a decimal
		-- number (01-53).  If the week containing January 1 has four or more days in the new year, then it
		-- is week 1; otherwise it is the last week of the previous year, and the next week is week 1

		return ("%02d"):format(V_Helper.isowy(V_Helper.CountDays(TimeData.year - 1) + TimeData.yday))
	end;

	W = function(TimeData) -- Week of year as decimal number, with Monday as first day of week [0, 53]
		return ("%02d"):format(Tags["#W"](TimeData))
	end;

	["#W"] = function(TimeData) -- Week of year as decimal number, with Monday as first day of week [0, 53]
		local Offset = TimeData.wday - 2
		local PreviousMonday = TimeData.yday - (Offset == -1 and 6 or Offset) -- [0, 6]
		local Divisible = PreviousMonday % 7
		return Divisible == 0 and PreviousMonday / 7 or 1 + (PreviousMonday - Divisible) / 7
	end;

	w = function(TimeData) -- Weekday [0, 6], Sunday as beginning
		return TimeData.wday - 1
	end;

	Y = function(TimeData) -- Year with century, as decimal number with 4 digits
		return ("%04d"):format(TimeData.year)
	end;

	["#Y"] = function(TimeData) -- Year with century, as raw decimal number
		return TimeData.year
	end;

	y = function(TimeData) -- Year without century, as decimal number [00, 99]
		return ("%02d"):format(TimeData.year % 100)
	end;

	["#y"] = function(TimeData) -- Year without century, as decimal number [0, 99]
		return TimeData.year % 100
	end;

	Z = function()
		error("Impossible to get timezone without location")
	end;

	z = function() -- Time zone offset from UTC in the form [+-]%02Hours%02Minutes, e.g. +0500
		return TimeZoneOffset
	end;

	["#z"] = function() -- Time zone offset from UTC in the form [+-]%02Hours:%02Minutes, e.g. +05:00
		return TimeZoneOffset2
	end;
}, {
	__index = function(_, i) -- Error on invalid tag
		error("bad argument to 'Time.Date' (invalid tag '%" .. i .. "')")
	end;
})

Tags.h = Tags.b
Tags["#e"] = Tags["#d"]
Tags["#k"] = Tags["#H"]
Tags["#l"] = Tags["#I"]

function Tags:__index(i)
	return Tags[i](self)
end

local function Date(StringToFormat, Unix)
	local TimeData

	if StringToFormat then
		if StringToFormat:byte() == CHAR_EXCLAMATION then
			TimeData = os_date("!*t", Unix)
			StringToFormat = StringToFormat:sub(2)
		else
			TimeData = os_date("*t", Unix)
		end
	else
		TimeData = os_date("*t", Unix)
		StringToFormat = "%c"
	end

	TimeData.seed = Unix

	return (
		StringToFormat
			:gsub("%%(#?%a)", Patterns)
			:gsub("%%(#?.)", setmetatable(TimeData, Tags))
	)
end

return Date
