-- @author Validark

-- Necessary data tables
local dayNames = {[0] = "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
local monthLengths = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
local suffixes = {"st", "nd", "rd"}

-- Localize functions
local time = os.time
local floor, sub, find, gsub, format = math.floor, string.sub, string.find, string.gsub, string.format
local type, tick, tonumber = type, tick, tonumber

return setmetatable({
	date = function(formatString, unix)
		--- Allows you to use os.date in RobloxLua!
		--		date ([format [, time]])
		-- This doesn't include the explanations for the math. If you want to see how the numbers work, see the following:
		-- http://howardhinnant.github.io/date_algorithms.html#civil_from_days
		--
		-- @param string formatString
		--		If present, function date returns a string formatted by the tags in formatString.
		--		If formatString starts with "!", date is formatted in UTC.
		--		If formatString is "*t", date returns a table
		--		Placing "_" in the middle of a tag (e.g. "%_d" "%_I") removes padding
		--		String Reference: https://github.com/Narrev/NevermoreEngine/blob/patch-5/Modules/Utility/readme.md
		--		@default "%c"
		--
		-- @param number unix
		--		If present, unix is the time to be formatted. Otherwise, date formats the current time.
		--		The amount of seconds since 1970 (negative numbers are occasionally supported)
		--		@default tick()

		-- @returns a string or a table containing date and time, formatted according to the given string format. If called without arguments, returns the equivalent of date("%c").

		-- Find whether formatString was used
		local formatStringType, UTC = type(formatString)
		if formatStringType == "number" then -- If they didn't pass a formatString, and only passed unix through
			unix, formatString = formatString, type(unix) ~= "string" and "%c" or error("Invalid parameters passed to os.date. Your parameters might be in the wrong order")
		elseif formatStringType == "string" then
			formatString, UTC = gsub(formatString, "^!", "") -- If formatString begins in '!', use os.time()
		end
		-- Set unix
		unix = tonumber(unix) or UTC == 1 and time() or tick()

		-- Get hours, minutes, and seconds
		local hours, minutes, seconds = unix / 3600 % 24, unix / 60 % 60, unix % 60
		hours, minutes, seconds = hours - hours % 1, minutes - minutes % 1, seconds - seconds % 1

		-- Get days, month and year
		local days = unix / 86400 - unix / 86400 % 1 + 719468
		local wday = (days + 3) % 7 -- Day of week with Sunday @0 [0, 6]
		local year = (days >= 0 and days or days - 146096) / 146097 -- 400 Year bracket
		year = year - year % 1
		days = (days - year * 146097) -- Days into 400 year bracket [0, 146096]
		local years = (days - days/1460 + days/36524 - days/146096 + days/1460 % 1 - days/36524 % 1 + days/146096 % 1)/365	-- Years into 400 Year bracket[0, 399]
		years = years - years % 1
		days = days - (365.24*years - years*0.25 % 1 + years*0.01 % 1) -- Days into year with March 1st @0 [0, 365]		
		local month = (5*days + 2)/153 - (5*days + 2)/153 % 1 -- Month with March @0 [0, 11]
		local yday = days
		days = days - 30.6*month + 0.6 + (30.6*month + 0.4) % 1 -- Days into month [1, 31]
		month = month + (month < 10 and 3 or -9) -- Actual month [1, 12]
		year = years + year*400 + (month < 3 and 1 or 0) -- Actual Year

		-- Return a table if "*t" was used, otherwise return formatted string
		return formatString == "*t" and {year = year, month = month, day = days, yday = yday, wday = wday, hour = hours, min = minutes, sec = seconds} or (gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(formatString or "%c",
			"%%c",  "%%x %%X"),
			"%%_c", "%%_x %%_X"),
			"%%x",  "%%m/%%d/%%y"),
			"%%_x", "%%_m/%%_d/%%y"),
			"%%X",  "%%H:%%M:%%S"),
			"%%_X", "%%_H:%%M:%%S"),
			"%%T",  "%%I:%%M %%p"),
			"%%_T", "%%_I:%%M %%p"),
			"%%r",  "%%I:%%M:%%S %%p"),
			"%%_r", "%%_I:%%M:%%S %%p"),
			"%%R",  "%%H:%%M"),
			"%%_R", "%%_H:%%M"),
			"%%a", sub(dayNames[wday], 1, 3)),
			"%%A", dayNames[wday]),
			"%%b", sub(months[month], 1, 3)),
			"%%B", months[month]),
			"%%d", format("%02d", days)),
			"%%_d", days),
			"%%H", format("%02d", hours)),
			"%%_H", hours),
			"%%I", format("%02d", hours > 12 and hours - 12 or hours == 0 and 12 or hours)),
			"%%_I", hours > 12 and hours - 12 or hours == 0 and 12 or hours),
			"%%j", format("%02d", yday)),
			"%%_j", yday),
			"%%M", format("%02d", minutes)),
			"%%_M", minutes),
			"%%m", format("%02d", month)),
			"%%_m", month),
			"%%n", "\n"),
			"%%p", hours >= 12 and "pm" or "am"),
			"%%_p", hours >= 12 and "PM" or "AM"),
			"%%s", (days < 21 and days > 3 or days > 23 and days < 31) and "th" or suffixes[days % 10]),
			"%%S", format("%02d", seconds)),
			"%%_S", seconds),
			"%%t", "\t"),
			"%%u", wday == 0 and 7 or wday),
			"%%w", wday),
			"%%Y", year),
			"%%y", format("%02d", year % 100)),
			"%%_y", year % 100),
			"%%%%", "%%")
		)
	end;

	clock = function()
		return workspace.DistributedGameTime
	end;

	isLeapYear = function(year)
		return year % 4 == 0 and (year % 25 ~= 0 or year % 16 == 0)
	end;

	monthLength = function(month, year)
		return month == 2 and year % 4 == 0 and (year % 25 ~= 0 or year % 16 == 0) and 29 or monthLengths[month]
	end;
}, {__index = os})
