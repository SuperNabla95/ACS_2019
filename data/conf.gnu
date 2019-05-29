set term pdf

set output 'cwin.pdf'
set xlabel 'time (seconds)'
set ylabel 'congestion window (packets)'
plot 'trace_swnd_true.txt' with lines lw 2 lt rgb 'green', 'trace_swnd_false.txt' with lines lw 2 lt rgb 'red'

set output 'numseq.pdf'
set xlabel 'time (seconds)'
set xrange [0:2]
set ylabel 'sequence number'
plot 'numseq_true.txt' with lines lw 2 lt rgb 'green', 'numseq_false.txt' with lines lw 2 lt rgb 'red'


