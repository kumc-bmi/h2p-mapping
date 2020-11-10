# takes two csvs (argv[1] argv[2])
# prints to stdout csv containing all of csv(a) + unique keys of csv(b)

import csv
import sys

# import both csvs into memory
with open(sys.argv[1], newline='') as f:
    reader = csv.reader(f)
    dict_a = {row[0]:row[1] for row in reader}

with open(sys.argv[2], newline='') as f:
    reader = csv.reader(f)
    dict_b = {row[0]:row[1] for row in reader}

for key,value in dict_b.items():
    if key not in dict_a:
        dict_a.update({key:value})

for key,value in dict_a.items():
    print('"' + key + '","' + value + '"')
