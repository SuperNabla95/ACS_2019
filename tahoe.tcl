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
$ns color 1 Blue

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
        global ns trace_swnd tcp_ag
        set now [$ns now]
        set curr_cwnd [$tcp_ag set cwnd_]
        set curr_wnd [$tcp_ag set window_]
        if { $curr_wnd < $curr_cwnd } {
        set swnd $curr_wnd
        } else {
        set swnd $curr_cwnd
        }
        puts $trace_swnd "$now $swnd $curr_cwnd"
        $ns at [expr $now + $interval] "sampleswnd $interval"
}

proc altri_tcp_var { step } {
        global ns tcp_ag numseq
        set now [$ns now]
        set seqno [$tcp_ag set t_seqno_ ]
        set sst [$tcp_ag set ssthresh_ ]
        puts $numseq "$now $seqno $sst"
        $ns at [expr $now+$step] "altri_tcp_var $step"
}

#Create four nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

#Create link between the nodes + trace
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 50Kb 10ms DropTail

#$ns trace-queue $n4 $n5 $trace_file

#Give node position (for NAM)
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right

#Set Queue Size of link (n2-n3) to 10
$ns queue-limit $n1 $n2 9

#Setup Blue TCP connection
set tcp_ag [new Agent/TCP]
$ns attach-agent $n0 $tcp_ag
set sink_ag1 [new Agent/TCPSink]
$ns attach-agent $n2 $sink_ag1
$ns connect $tcp_ag $sink_ag1
$tcp_ag set fid_ 1



$tcp_ag set window_ 50

#Setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp_ag

#Call proc to sample windows
sampleswnd 0.1

#call proc sequence numbers
altri_tcp_var 0.1

#QueueMonitor creation:
$ns monitor-queue $n1 $n2 [open qm.txt w] 0.1
[$ns link $n1 $n2] queue-sample-timeout;

#Schedule events for the FTP agents
$ns at 0.1 "$ftp start"
$ns at 59.9 "$ftp stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 60.0 "finish"


#Run the simulation
$ns run