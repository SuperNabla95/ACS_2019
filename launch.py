import os

os.system("""ns exercise_2.tcl""" )
os.system("""awk '{if(($1=="r")&&($3=="4") && ($4=="5") && ($9 == "0.0")){print $2,$6}}' trace.tr > filtered.txt""")
os.system("""awk -f throughput.awk filtered.txt > link45_v3.dat""")