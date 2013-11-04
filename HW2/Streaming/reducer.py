#!/usr/bin/env python

from operator import itemgetter
import sys

#constants
current_count = 0
unit_count = 1
current_box = ["x1", "x2", "x3", "x4", "1"]
current_box_len = len(current_box)


# input comes from STDIN
for line in sys.stdin:
# remove leading and trailing whitespace
    line = line.strip()
    # parse the input we got from mapper.py
    box = line.split('\t', 4)
    if len(box) < current_box_len or len(box) < current_box_len:
        raise Exception("Error in splitting STDIN!")
    equal_box = True
    dim = 0
    while equal_box and dim < current_box_len:
        if current_box[dim] != box[dim]:
            equal_box = False
        dim += 1

    if equal_box:
        current_count += unit_count
    else:
        #finished counting for previous box
        if current_count != 0:
            current_box[current_box_len - 1] = str(current_count)
            print '%s' % ','.join(current_box)
        current_box = box
        current_count = unit_count

# do not forget to output the last box
current_box[current_box_len - 1] = str(current_count)
print '%s' % ','.join(current_box)
