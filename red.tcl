if { $argc == 0 } {
    #set is_fastrtx [lindex $argv 0]
    #set sim [lindex $argv 1]
} else { 
    puts "Usage is: $argv0"
    exit 1
}

#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Red
$ns color 2 Blue

#Open the NAM trace file
set nf [open    out.nam w]
$ns namtrace-all $nf

#Open the Trace
set trace_file [open trace.tr w]
$ns trace-all $trace_file

#open windows file
set trace_swnd [open trace_swnd.txt w]

#open numseq file
set numseq [open numseq.txt w]

#Define a 'finish' procedure
proc finish {} {
        global ns nf trace_file trace_swnd numseq
        $ns flush-trace
        #Close the NAM trace file
        close $nf
        #Close the trace_file
        close $trace_file
        #close windows file
        close $trace_swnd
        #close numseq file
        close $numseq
        #Execute NAM on the trace file
        #exec nam out.nam &
        exit 0
}

proc sampleswnd { interval } {
        global ns trace_swnd ftcp1 ftcp2
        set now [$ns now]
        set curr_cwnd_1 [$ftcp1 set cwnd_]
        set curr_cwnd_2 [$ftcp2 set cwnd_]
        puts $trace_swnd "$now $curr_cwnd_1 $curr_cwnd_2"
        $ns at [expr $now + $interval] "sampleswnd $interval"
}

proc altri_tcp_var { step } {
        global ns ftcp1 numseq
        set now [$ns now]
        set seqno [$ftcp1 set t_seqno_ ]
        set sst [$ftcp1 set ssthresh_ ]
        puts $numseq "$now $seqno $sst"
        $ns at [expr $now+$step] "altri_tcp_var $step"
}

#Create four nodes
set s1 [$ns node]
set s2 [$ns node]
set r1 [$ns node]
set r2 [$ns node]
set s3 [$ns node]
set s4 [$ns node]

#Create link between the nodes + trace
$ns duplex-link $s1 $r1 10Mb 2ms DropTail
$ns duplex-link $s2 $r1 10Mb 3ms DropTail
$ns duplex-link $r1 $r2 1.5Mb 20ms RED
$ns duplex-link $r2 $s3 10Mb 4ms DropTail
$ns duplex-link $r2 $s4 10Mb 5ms DropTail

#$ns trace-queue $n4 $n5 $trace_file

#Give node position (for NAM)
$ns duplex-link-op $s1 $r1 orient right-down
$ns duplex-link-op $s2 $r1 orient right-up
$ns duplex-link-op $r1 $r2 orient right
$ns duplex-link-op $r2 $s3 orient right-up
$ns duplex-link-op $r2 $s4 orient right-down

#Set Queue Size of link (n2-n3) to 10
$ns queue-limit $r1 $r2 25

#Setup Blue TCP connection
set ftcp1 [new Agent/TCP/Reno]
set ftcp1_sink [new Agent/TCPSink]
$ns attach-agent $s1 $ftcp1
$ns attach-agent $s3 $ftcp1_sink
$ns connect $ftcp1 $ftcp1_sink
$ftcp1 set fid_ 1

$ftcp1 set window_ 50

#Setup a FTP over TCP connection
set ftp1 [new Application/FTP]
$ftp1 attach-agent $ftcp1

#Setup Red TCP connection
set ftcp2 [new Agent/TCP/Reno]
set ftcp2_sink [new Agent/TCPSink]
$ns attach-agent $s2 $ftcp2
$ns attach-agent $s4 $ftcp2_sink
$ns connect $ftcp2 $ftcp2_sink
$ftcp2 set fid_ 2

$ftcp2 set window_ 50

#Setup a FTP over TCP connection
set ftp2 [new Application/FTP]
$ftp2 attach-agent $ftcp2

#Call proc to sample windows
sampleswnd 0.1

#call proc sequence numbers
altri_tcp_var 0.1

#QueueMonitor creation:
$ns monitor-queue $r1 $r2 [open qm.txt w] 0.1
[$ns link $r1 $r2] queue-sample-timeout;

#Schedule events for the FTP agents
$ns at 0 "$ftp1 start"
$ns at 3 "$ftp2 start"
$ns at 10 "$ftp1 stop"
$ns at 10 "$ftp2 stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 10.0 "finish"


#Run the simulation
$ns run