# os
This extends the os table to include os.date and other great functions! It keeps Lua's built-in os functionality, but has a few additions.

## date
Functions just like the vanilla Lua function, but padding can be toggled by inserting a '_' like so: os.date("%_x", os.time())
Note: tick() is the default unix time used for os.date()

```lua
os.date("*t")
```
returns a table with the following indices:
```
hour    14
min     36
wday    1
year    2003
yday    124
month   5
sec     33
day     4
```
String reference:
```
%a	abbreviated weekday name (e.g., Wed)
%A	full weekday name (e.g., Wednesday)
%b	abbreviated month name (e.g., Sep)
%B	full month name (e.g., September)
%c	date and time (e.g., 09/16/98 23:48:10)
%d	day of the month (16) [01-31]
%H	hour, using a 24-hour clock (23) [00-23]
%I	hour, using a 12-hour clock (11) [01-12]
%j	day of year [0-365] (March 1st is treated as day 0 of year)
%M	minute (48) [00-59]
%m	month (09) [01-12]
%n	New-line character ('\n')
%p	either "am" or "pm" ('_' makes it uppercase)
%r	12-hour clock time *	02:55:02 pm
%R	24-hour HH:MM time, equivalent to %H:%M	14:55
%s	day suffix
%S	second (10) [00-61]
%t	Horizontal-tab character ('\t')
%T	Basically %r but without seconds (HH:MM AM), equivalent to %I:%M %p	2:55 pm
%u	ISO 8601 weekday as number with Monday as 1 (1-7)	4
%w	weekday (3) [0-6 = Sunday-Saturday]
%x	date (e.g., 09/16/98)
%X	time (e.g., 23:48:10)
%Y	full year (1998)
%y	two-digit year (98) [00-99]
%%	the character `%´
```
Example:
```lua
local os = require(ThisModule)
print(os.date("It is currently %r"))
--> It is currently 03:36:30 pm
```
## clock
Returns how long the server has been active (it's just workspace.DistributedGameTime)

## isLeapYear
Internal function, but you can use it if you want. The first parameter is the year (should be an integer) and it returns a boolean indicating whether that year is/was/will be a leap year.

## monthLength
Finds the length of the desired month.
```
os.monthLength(3, 2017)
> 31
-- First parameter is the month [1-12]
-- Second paramter is the year
-- Returns how many days are in that month
```
