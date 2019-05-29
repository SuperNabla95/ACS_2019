set term pdf

set output 'queue_length.pdf'
set xlabel 'time (seconds)'
set ylabel 'average size'
plot 'temp.a' with lines lw 2 lt rgb 'blue', 'temp.q' with lines lw 2 lt rgb 'red', 'qm.txt' using 1:4 with lines lw 2 lt rgb 'green'


