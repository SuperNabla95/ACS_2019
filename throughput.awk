#awk '{if(($1=="r")&&($3=="4") && ($4=="5") && ($9 == "0.0")){print $2,$6}}' trace.tr > filtered.txt 
#awk -f throughput.awk filtered.txt > data.dat


BEGIN {size = 0}
{size += $2; print $1,(size/$1)}
END {}