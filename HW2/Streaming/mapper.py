#!/usr/bin/env python

# From: http://www.michael-noll.com/tutorials/writing-an-hadoop-mapreduce-program-in-python/

import sys
import math

#the number of lines
D = 5

# input comes from STDIN (standard input)
for line in sys.stdin:
    # remove leading and trailing whitespace
    line = line.strip()
    # split the line which should be a pair of numbers (x_1, x_2)
    x_d = line.split()

    #keep pairs on same line counters
    out_line = [None]*D
    d = 0
    for x in x_d:
        x = float(x)

        #boundary precision to the tenths decimal place
        x_lo = math.floor(x*10)/10
        x_hi = math.ceil(x*10)/10

        #values lying on the boundary should follow left exclusion principle
        #(e.g. 5.4 < x <= 5.5) when x = 5.5
        if x_lo == x_hi:
            x_lo = x_hi - 0.1

        out_line[d] = x_lo
        out_line[d + 1] = x_hi
        d += 2

    # write the results to STDOUT (standard output);
    # what we output here will be the input for the
    # Reduce step, i.e. the input for reducer.py
    #
    #the trivial frequency is 1
    out_line[D - 1] = 1

    #FROM: http://stackoverflow.com/questions/5445970/printing-list-in-python-properly
    print '%s' % '\t'.join(map(str, out_line))
