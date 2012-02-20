MONTHS = [
  "January", "February", "March"
  "April",   "May",      "June"
  "July",    "August",   "September"
  "October", "November", "December"
]

# Public: Convert a date to a "%M %d, %yyyy" format.
# 
# Returns String.
exports.toString = (date) ->
  "#{MONTHS[date.getMonth()]} #{date.getDate()}, #{date.getFullYear()}"

# Public: Get the string month by 0-index.
# 
# Returns String.
exports.month = (monthIndex) ->
  MONTHS[monthIndex]

# Public: Check whether or not the 2 dates are the same day
# (as determined by year,month,date).
# 
# Returns Boolean.
exports.sameDay = sameDay = (date1, date2) ->
  return date1.getDate()     == date2.getDate()  &&
         date1.getMonth()    == date2.getMonth() &&
         date1.getFullYear() == date2.getFullYear()

# Public: Check if the date occurred today.
# 
# Returns Boolean.
exports.isToday = isToday = (date) ->
  return sameDay date, (new Date())

# Public: Convert the date to a time.
# 
# Returns String "HOUR:MIN AM".
exports.getTime = getTime = (date) ->
  hours = date.getHours()
  if hours > 12
    hours -= 12
    suffix = "PM"
  else
    suffix = "AM"
  time = "#{padZeros(hours, 2)}:#{padZeros(date.getMinutes(), 2)} #{suffix}"


# Public: Pad the number with zeros on the left.
# 
# Examples
# 
#   padZeros(5, 2)
#   # => "05"
# 
# Returns String.
exports.padZeros = padZeros = (num, len) ->
  len -= num.toString().length
  if len > 0
    return new Array(len + 1).join("0") + num
  return num

