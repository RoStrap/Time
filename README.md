# Date
Time and Date formatter mimicking the vanilla os.date function.

```lua
local Date = Resources:LoadLibrary("Date")
```
Demo:
```lua
-- ISO 8601:
print(Date("%FT%X"))    -- 2018-05-24T00:57:02
print(Date("%FT%X%#z")) -- 2018-05-24T01:05:34-05:00
```

Functions just like the vanilla Lua `os.date` function, but padding can be toggled by inserting a '#' like so: `Date("%#x", os.time())`

```lua
table.foreach(Date("*t"), print)
```

Returns a table with the following indices:

```
hour 6
min 16
wday 5
day 24
month 5
year 2018
sec 29
yday 144
isdst false
```

String reference:

```
%c = "%a %b %e %X %Y";
%D = "%m/%d/%y";
%F = "%Y-%m-%d";
%n = "\n";
%R = "%H:%M";
%r = "%I:%M:%S %p";
%T = "%I:%M %p";
%t = "\t";
%v = "%e-%b-%Y";
%X = "%H:%M:%S";
%x = "%m/%d/%y";

%% = the character `%´
%a = abbreviated weekday name (e.g., Wed)
%A = full weekday name (e.g., Wednesday)
%b = abbreviated month name (e.g., Sep)
%B = full month name (e.g., September)
%C = century: (year / 100) single digits are preceded by a zero
%d = day of the month (16) [01-31]
%e = day of month as decimal number [ 1, 31]
%g = Same year as in %G, but as a decimal number without century [00, 99]
%G = a 4-digit year as a decimal number with century
%H = hour, using a 24-hour clock (23) [00-23]
%I = hour, using a 12-hour clock (11) [01-12]
%j = day of year [001-366] (March 1st is treated as day 0 of year)
%k = Hour in 24-hour format [ 0, 23]
%l = Hour in 12-hour format [ 1, 12]
%m = month (09) [01, 12]
%M = minute (48) [00, 59]
%p = either "am" or "pm" ('#' makes it uppercase)
%s = Day of year suffix: e.g. 12th, 31st, 22nd
%S = Second as decimal number [00, 59]
%u = ISO 8601 weekday as number with Monday as 1 [1, 7]
%U = Week of year, Sunday Based [00, 53]
%V = week number of year (Monday as beginning of week) [01, 53]
%w = weekday (3) [0-6 = Sunday-Saturday]
%W = Week of year with Monday as first day of week [0, 53]
%y = two-digit year (98) [00, 99]
%Y = full year (1998)
%z = Time zone offset from UTC in the form [+-]%02Hours%02Minutes, e.g. +0500
```

Example:

```lua
print(Date("It is currently %#r"))
--> It is currently 1:41:20 am
```
