set terminal postscript eps enhanced color "Helvetica" 12
set output "distResults/Histogram_BITREV.ps"
set boxwidth 0.75 absolute
set style data histograms
set style histogram cluster gap 1
set style fill solid border -1
set xlabel "Message latency (ns)"
set ylabel "Count"
set xtics ("0" 0, "240" 10, "480" 20, "720" 30, "960" 40, "1200" 50, "1440" 60, "1680" 70, "1920" 80, "2160" 90)
plot \
'distResults/histData_BITREV.dat' using 1 t "BITREV" 