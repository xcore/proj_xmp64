set terminal epslatex color size 14cm, 8cm
set key inside left top #spacing 1 samplen 2 width -5
set logscale xy
set xlabel "Message size (KB)" offset 0,0
set ylabel "Average Latency ($\\mu s$)" offset 2,0
#set xtics(\
#    "1" 1,\
#    "1" 1000,\
#    "2" 2000,\
#    "3" 3000,\
#    "4" 4000,\
#    "5" 5000,\
#    "6" 6000,\
#    "7" 7000,\
#    "8" 8000,\
#    "9" 9000)
#set ytics(\
#    "0" 0,\
#    "0.1" 100000,\
#    "0.2" 200000,\
#    "0.3" 300000,\
#    "0.4" 400000,\
#    "0.5" 500000,\
#    "0.6" 600000,\
#    "0.7" 700000,\
#    "0.8" 800000,\
#    "0.9" 900000)

set output "average-latency.tex"
plot \
	"shift1.dat"  title "Shuffle" with linespoints,\
	"shift2.dat"  title "Transpose" with linespoints,\
	"bitcomp.dat" title "Bit-comp" with linespoints,\
	"bitrev.dat"  title "Bit-rev" with linespoints,\
	"random.dat"  title "Random" with linespoints


