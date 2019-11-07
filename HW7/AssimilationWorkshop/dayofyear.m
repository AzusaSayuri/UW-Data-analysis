function yd = dayofyear(year,month,day)
%DAYOFYEAR Ordinal number of day in a year.
%
%   DAYOFYEAR(YEAR, MONTH, DAY) returns the ordinal
%   day number in the given year plus a fractional part depending on the
%   time of day.
%
%   Any missing MONTH or DAY will be replaced by 1.  HOUR, MINUTE or SECOND
%   will be replaced by zeros.
%
%   If no date is specified, the current date and time is used.  Gregorian
%   calendar is assumed.

%   Author:      Peter John Acklam
%   Time-stamp:  2002-03-03 12:52:04 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

%  Modified to have fixed # of inputs to try to improve efficiency M. Durand

   days_in_prev_months = [0 31 59 90 120 151 181 212 243 273 304 334];

   % Day in given month.
   yd = days_in_prev_months(month) ...               % days in prev. months
        + ( isleapyear(year) & ( month > 2 ) ) ...   % leap day
        + day;                                     % day in month
      