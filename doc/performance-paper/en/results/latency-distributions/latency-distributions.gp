set terminal epslatex color size 14cm, 6.5cm
set nokey
set style data histograms
set style histogram cluster gap 1
#set style fill solid border -1
set style fill solid
set xlabel "Message latency (ns)" offset 0,0
set ylabel "Count" offset 0,0
set xtic rotate by -90 scale 0
set xtics (\
    "0" 0,\
    "130" 10,\
    "260" 20,\
    "390" 30,\
    "520" 40,\
    "650" 50,\
    "780" 60,\
    "910" 70,\
    "1040" 80,\
    "1170" 90)

set output "latency-dist-bitcomp.tex"
plot \
'bitcomp.dat' using 1 t "bitcomp"

set output "latency-dist-bitrev.tex"
plot \
'bitrev.dat' using 1 t "bitrev" 

set output "latency-dist-random.tex"
plot \
'random.dat' using 2 t "random" 

set output "latency-dist-shuffle.tex"
plot \
'shuffle.dat' using 1 t "shuffle" 

set output "latency-dist-transpose.tex"
plot \
'transpose.dat' using 2 t "transpose" 

