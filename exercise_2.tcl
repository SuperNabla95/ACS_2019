#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red

#Open the NAM trace file
set nf [open out.nam w]
$ns namtrace-all $nf

#Open the Trace
set trace_file [open trace.tr w]

#Define a 'finish' procedure
proc finish {} {
        global ns nf trace_file
        $ns flush-trace
        #Close the NAM trace file
        close $nf
        #Close the trace_file
        close $trace_file
        #Execute NAM on the trace file
        exec nam out.nam &
        exit 0
}

#Create four nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

#Create link between the nodes + trace
$ns duplex-link $n0 $n4 2Mb 5ms DropTail
$ns duplex-link $n1 $n4 2Mb 5ms DropTail
$ns duplex-link $n4 $n5 1Mb 10ms DropTail
$ns duplex-link $n5 $n2 2Mb 5ms DropTail
$ns duplex-link $n5 $n3 2Mb 5ms DropTail
$ns trace-queue $n4 $n5 $trace_file


#Give node position (for NAM)
$ns duplex-link-op $n0 $n4 orient right-down
$ns duplex-link-op $n1 $n4 orient right-up
$ns duplex-link-op $n4 $n5 orient right
$ns duplex-link-op $n5 $n2 orient right-up
$ns duplex-link-op $n5 $n3 orient right-down

#Set Queue Size of link (n2-n3) to 10
$ns queue-limit $n4 $n5 10

#Setup Blue TCP connection
set tcp_ag1 [new Agent/TCP]
$ns attach-agent $n0 $tcp_ag1
set sink_ag1 [new Agent/TCPSink]
$ns attach-agent $n3 $sink_ag1
$ns connect $tcp_ag1 $sink_ag1
$tcp_ag1 set fid_ 1

#Setup Red TCP connection
set tcp_ag2 [new Agent/TCP]
$ns attach-agent $n1 $tcp_ag2
set sink_ag2 [new Agent/TCPSink]
$ns attach-agent $n2 $sink_ag2
$ns connect $tcp_ag2 $sink_ag2
$tcp_ag2 set fid_ 2

#Setup a FTP over TCP connection
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp_ag1
$ftp1 set type_ FTP

#Setup another FTP over TCP connection
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp_ag2
$ftp2 set type_ FTP

#Schedule events for the FTP agents
$ns at 0.5 "$ftp1 start"
$ns at 0.5 "$ftp2 start"
$ns at 9.5 "$ftp1 stop"
$ns at 9.5 "$ftp2 stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 10.0 "finish"

#Print CBR packet size and interval
#puts "CBR packet size = [$cbr set packet_size_]"
#puts "CBR interval = [$cbr set interval_]"

#QueueMonitor creation:
$ns monitor-queue $n4 $n5 [open qm.txt w] 0.1
[$ns link $n4 $n5] queue-sample-timeout;

#Run the simulation
$ns run