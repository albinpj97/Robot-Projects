from datetime import datetime


# +
def date_format_conversion(date_input):
    # print(date_input, ":", type(date_input))
    day = date_input.day
    month = date_input.month
    month_in_words = date_input.strftime("%b")
    year = date_input.year
    # print(day,month,month_in_words,year)
    return day, month_in_words, year


date_string = '18/09/19 01:55:19'
date_in = datetime.strptime(date_string, '%d/%m/%y %H:%M:%S')
day, month, year = date_format_conversion(date_in)
print(day, month, year)
# -


