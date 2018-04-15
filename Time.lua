-- Extends the os table to include the full os.date functionality included in vanilla Lua
-- @readme https://github.com/RoStrap/Time/blob/master/README.md
-- @author Validark

-- Necessary data tables
local Suffixes = {"st", "nd", "rd"}
local DayNames = {[0] = "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
local MonthNames = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
local MonthLengths = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

local function IsLeapYear(Year)
	return Year % 4 == 0 and (Year % 25 ~= 0 or Year % 16 == 0)
end

local function GetMonthLength(Month, Year)
	return Month == 2 and IsLeapYear(Year) and 29 or MonthLengths[Month]
end

-- Localize functions
local function Date(StringToFormat, UnixSeconds)
	--- Allows you to use os.date in RobloxLua!
	--		date ([format [, time]])
	-- This doesn't include the explanations for the math. If you want to see how the numbers work, see the following:
	-- http://howardhinnant.github.io/date_algorithms.html#civil_from_days
	--
	-- @param string StringToFormat
	--		If present, function date returns a string formatted by the tags in StringToFormat.
	--		If StringToFormat starts with "!", date is formatted in UTC.
	--		If StringToFormat is "*t", date returns a table
	--		Placing "_" in the middle of a tag (e.g. "%_d" "%_I") removes padding
	--		String Reference: https://github.com/Narrev/NevermoreEngine/blob/patch-5/Modules/Utility/readme.md
	--		@default "%c"
	--
	-- @param number UnixSeconds
	--		If present, UnixSeconds is the time to be formatted. Otherwise, date formats the current time.
	--		The amount of Seconds since 1970 (negative numbers are occasionally supported)
	--		@default tick()

	-- @returns a string or a table containing date and time, formatted according to the given string format. If called without arguments, returns the equivalent of date("%c").

	-- Find whether StringToFormat was used
	if StringToFormat then
		if type(StringToFormat) == "number" then -- If they didn't pass a StringToFormat, and only passed UnixSeconds through
			if type(UnixSeconds) == "string" then error("Invalid parameters passed to os.date. Your parameters might be in the wrong order") end
			UnixSeconds, StringToFormat = StringToFormat, "%c"
		elseif type(StringToFormat) == "string" then
			if not StringToFormat:find("*t") and not StringToFormat:find("%%[_cxXTrRaAbBdHIjMmpsSuwyY]") then
				warn("[os.date] \"" .. StringToFormat .. "\" has nothing to format")
			end
			local UTC
			StringToFormat, UTC = StringToFormat:gsub("^!", "") -- If StringToFormat begins in '!', use os.time()
			-- if UTC == 1 and UnixSeconds then warn("Cannot determine time to format for os.date: Use either an \"!\" at the beginning of the string OR pass a time parameter") end
			UnixSeconds = UnixSeconds or UTC == 1 and os.time()
		end
	else -- If they did not pass a formatting string
		StringToFormat = "%c"
	end

	-- Set UnixSeconds
	UnixSeconds = tonumber(UnixSeconds) or tick()

	-- Get Hours, Minutes, and Seconds
	local Hours = math.floor(UnixSeconds / 3600 % 24)
	local Minutes = math.floor(UnixSeconds / 60 % 60)
	local Seconds = math.floor(UnixSeconds % 60)

	-- Get Days, Month and Year
	local Days = math.floor(UnixSeconds / 86400) + 719468
	local WeekDay = (Days + 3) % 7 -- Day of week with Sunday @0 [0, 6]
	local Year = math.floor((Days >= 0 and Days or Days - 146096) / 146097) -- 400 Year bracket
	Days = (Days - Year * 146097) -- Days into 400 Year bracket [0, 146096]
	local Years = math.floor((Days - math.floor(Days / 1460) + math.floor(Days / 36524) - math.floor(Days / 146096)) / 365)	-- Years into 400 Year bracket[0, 399]
	Days = Days - (365 * Years + math.floor(Years / 4) - math.floor(Years / 100)) -- Days into Year with March 1st @0 [0, 365]
	local Month = math.floor((5 * Days + 2) / 153) -- Month with March @0 [0, 11]
	local YearDay = Days
	Days = Days - math.floor((153 * Month + 2) / 5) + 1 -- Days into Month [1, 31]
	if (Month < 10) then
		YearDay = YearDay + 31 + (IsLeapYear(Year) and 28 or 29)
	else
		YearDay = YearDay - 273 - 32
	end
	Month = Month + (Month < 10 and 3 or -9) -- Actual Month [1, 12]
	Year = Years + Year*400 + (Month < 3 and 1 or 0) -- Actual Year

	-- table.foreach(Time.Date("*t", 34*86400 + os.time() - 7*3600), print)
	-- TODO: Fix yearday

	if StringToFormat == "*t" then -- Return a table if "*t" was used
		return {year = Year, month = Month, day = Days, yday = YearDay, wday = WeekDay, hour = Hours, min = Minutes, sec = Seconds}
	end

	-- Return formatted string
	return (
		StringToFormat
			:gsub("%%c",  "%%x %%X")
			:gsub("%%_c", "%%_x %%_X")
			:gsub("%%x",  "%%m/%%d/%%y")
			:gsub("%%_x", "%%_m/%%_d/%%y")
			:gsub("%%X",  "%%H:%%M:%%S")
			:gsub("%%_X", "%%_H:%%M:%%S")
			:gsub("%%T",  "%%I:%%M %%p")
			:gsub("%%_T", "%%_I:%%M %%p")
			:gsub("%%r",  "%%I:%%M:%%S %%p")
			:gsub("%%_r", "%%_I:%%M:%%S %%p")
			:gsub("%%R",  "%%H:%%M")
			:gsub("%%_R", "%%_H:%%M")
			:gsub("%%a", DayNames[WeekDay]:sub(1, 3))
			:gsub("%%A", DayNames[WeekDay])
			:gsub("%%b", MonthNames[Month]:sub(1, 3))
			:gsub("%%B", MonthNames[Month])
			:gsub("%%d", ("%02d"):format(Days))
			:gsub("%%_d", Days)
			:gsub("%%H", ("%02d"):format(Hours))
			:gsub("%%_H", Hours)
			:gsub("%%I", ("%02d"):format(Hours > 12 and Hours - 12 or Hours == 0 and 12 or Hours))
			:gsub("%%_I", Hours > 12 and Hours - 12 or Hours == 0 and 12 or Hours)
			:gsub("%%j", ("%02d"):format(YearDay))
			:gsub("%%_j", YearDay)
			:gsub("%%M", ("%02d"):format(Minutes))
			:gsub("%%_M", Minutes)
			:gsub("%%m", ("%02d"):format(Month))
			:gsub("%%_m", Month)
			:gsub("%%n", "\n")
			:gsub("%%p", Hours >= 12 and "pm" or "am")
			:gsub("%%_p", Hours >= 12 and "PM" or "AM")
			:gsub("%%s", (Days < 21 and Days > 3 or Days > 23 and Days < 31) and "th" or Suffixes[Days % 10])
			:gsub("%%S", ("%02d"):format(Seconds))
			:gsub("%%_S", Seconds)
			:gsub("%%t", "\t")
			:gsub("%%u", WeekDay == 0 and 7 or WeekDay)
			:gsub("%%w", WeekDay)
			:gsub("%%Y", Year)
			:gsub("%%y", ("%02d"):format(Year % 100))
			:gsub("%%_y", Year % 100)
			:gsub("%%%%", "%%")
	)
end

return {
	Date = Date;
	IsLeapYear = IsLeapYear;
	GetMonthLength = GetMonthLength;
}
