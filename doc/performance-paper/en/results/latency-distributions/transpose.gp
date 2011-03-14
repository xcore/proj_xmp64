set terminal postscript eps enhanced color "Helvetica" 12
set output "distResults/Histogram_TRANSPOSE.ps"
set boxwidth 0.75 absolute
set style data histograms
set style histogram cluster gap 1
set style fill solid border -1
set xlabel "Message latency (ns)"
set ylabel "Count"
set xtics ("0" 0, "220" 10, "440" 20, "660" 30, "880" 40, "1100" 50, "1320" 60, "1540" 70, "1760" 80, "1980" 90)
plot \
'distResults/histData_TRANSPOSE.dat' using 1 t "TRANSPOSE" 