set term pdf

set output 'cwin.pdf'
set xlabel 'time (seconds)'
set ylabel 'congestion window (packets)'
plot 'trace_swnd.txt' using 1:2 with lines lw 2 lt rgb 'red', 'trace_swnd.txt' using 1:3 with lines lw 2 lt rgb 'blue'




