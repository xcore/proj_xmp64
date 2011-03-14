set terminal postscript eps enhanced color "Helvetica" 12
set output "distResults/Histogram_BITCOMP.ps"
set boxwidth 0.75 absolute
set style data histograms
set style histogram cluster gap 1
set style fill solid border -1
set xlabel "Message latency (ns)"
set ylabel "Count"
set xtics ("0" 0, "130" 10, "260" 20, "390" 30, "520" 40, "650" 50, "780" 60, "910" 70, "1040" 80, "1170" 90)
plot \
'distResults/histData_BITCOMP.dat' using 1 t "BITCOMP" 