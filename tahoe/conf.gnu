set term pdf

set output 'cwin.pdf'
set xlabel 'time (seconds)'
set ylabel 'congestion window (packets)'
plot 'trace_swnd.txt' with lines lw 2 lt rgb 'blue'
set output 'numseq.pdf'
set xlabel 'time (seconds)'
set xrange [0:2]
set ylabel 'sequence number'
plot 'numseq.txt' with lines lw 2 lt rgb 'blue'


