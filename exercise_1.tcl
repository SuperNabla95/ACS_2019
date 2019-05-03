#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue

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

#Create link between the nodes + trace
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns trace-queue $n0 $n1 $trace_file


#Give node position (for NAM)
$ns duplex-link-op $n0 $n1 orient right

#Setup a UDP connection
set udp_agent [new Agent/UDP]
$ns attach-agent $n0 $udp_agent
set null_agent [new Agent/Null]
$ns attach-agent $n1 $null_agent
$ns connect $udp_agent $null_agent
$udp_agent set fid_ 1

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp_agent
$cbr set type_ CBR
$cbr set packet_size_ 500
$cbr set rate_ 2Mb
#$cbr set random_ false

#Schedule events for the CBR and FTP agents
$ns at 0.5 "$cbr start"
$ns at 4.5 "$cbr stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"

#Print CBR packet size and interval
puts "CBR packet size = [$cbr set packet_size_]"
puts "CBR interval = [$cbr set interval_]"

#QueueMonitor creation:
$ns monitor-queue $n0 $n1 [open qm.txt w] 0.1
[$ns link $n0 $n1] queue-sample-timeout;

#Run the simulation
$ns run