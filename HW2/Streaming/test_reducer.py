#!/usr/bin/env python
box1 = ["4.2", "4.3", "5.2", "5.3", "1"]
for x in range(0,3):
    print '%s' % '\t'.join(box1)

box2 = ["6.3", "6.3", "7.2", "7.3", "1"]
for x in range(0,10):
    print '%s' % '\t'.join(box2)

box2 = ["8.3", "8.3", "8.2", "8.3", "1"]
print '%s' % '\t'.join(box1)

