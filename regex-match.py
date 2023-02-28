#!/usr/bin/env python3

# This script accepts two arguments, a regular expression and a string to match
# against.
# It will print out the string if it matches the regular expression, or nothing
# if it does not.

import re
import sys

# Get the regular expression and string to match from the command line
regex = sys.argv[1]
string = sys.argv[2]

# Compile the regular expression
regex = re.compile(regex)

# Match the string against the regular expression
match = regex.match(string)

# If there is a match, print the string
if match:
    print(string)
