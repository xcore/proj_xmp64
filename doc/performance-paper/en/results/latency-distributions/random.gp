set terminal postscript eps enhanced color "Helvetica" 12
set output "distResults/Histogram_RANDOM.ps"
set boxwidth 0.75 absolute
set style data histograms
set style histogram cluster gap 1
set style fill solid border -1
set xlabel "Message latency (ns)"
set ylabel "Count"
set xtics ("0" 0, "250" 10, "500" 20, "750" 30, "1000" 40, "1250" 50, "1500" 60, "1750" 70, "2000" 80, "2250" 90)
plot \
'distResults/histData_RANDOM.dat' using 1 t "RANDOM" 