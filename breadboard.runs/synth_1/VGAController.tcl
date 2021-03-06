# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
namespace eval ::optrace {
  variable script "C:/Users/Jessica Yang/Documents/ece350/breadboard/breadboard.runs/synth_1/VGAController.tcl"
  variable category "vivado_synth"
}

# Try to connect to running dispatch if we haven't done so already.
# This code assumes that the Tcl interpreter is not using threads,
# since the ::dispatch::connected variable isn't mutex protected.
if {![info exists ::dispatch::connected]} {
  namespace eval ::dispatch {
    variable connected false
    if {[llength [array get env XILINX_CD_CONNECT_ID]] > 0} {
      set result "true"
      if {[catch {
        if {[lsearch -exact [package names] DispatchTcl] < 0} {
          set result [load librdi_cd_clienttcl[info sharedlibextension]] 
        }
        if {$result eq "false"} {
          puts "WARNING: Could not load dispatch client library"
        }
        set connect_id [ ::dispatch::init_client -mode EXISTING_SERVER ]
        if { $connect_id eq "" } {
          puts "WARNING: Could not initialize dispatch client"
        } else {
          puts "INFO: Dispatch client connection id - $connect_id"
          set connected true
        }
      } catch_res]} {
        puts "WARNING: failed to connect to dispatch server - $catch_res"
      }
    }
  }
}
if {$::dispatch::connected} {
  # Remove the dummy proc if it exists.
  if { [expr {[llength [info procs ::OPTRACE]] > 0}] } {
    rename ::OPTRACE ""
  }
  proc ::OPTRACE { task action {tags {} } } {
    ::vitis_log::op_trace "$task" $action -tags $tags -script $::optrace::script -category $::optrace::category
  }
  # dispatch is generic. We specifically want to attach logging.
  ::vitis_log::connect_client
} else {
  # Add dummy proc if it doesn't exist.
  if { [expr {[llength [info procs ::OPTRACE]] == 0}] } {
    proc ::OPTRACE {{arg1 \"\" } {arg2 \"\"} {arg3 \"\" } {arg4 \"\"} {arg5 \"\" } {arg6 \"\"}} {
        # Do nothing
    }
  }
}

proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
OPTRACE "synth_1" START { ROLLUP_AUTO }
set_param chipscope.maxJobs 1
set_param synth.incrementalSynthesisCache {C:/Users/Jessica Yang/AppData/Roaming/Xilinx/Vivado/.Xil/Vivado-14548-DESKTOP-S43D2TC/incrSyn}
set_param xicom.use_bs_reader 1
set_msg_config -id {Synth 8-256} -limit 10000
set_msg_config -id {Synth 8-638} -limit 10000
OPTRACE "Creating in-memory project" START { }
create_project -in_memory -part xc7a100tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir {C:/Users/Jessica Yang/Documents/ece350/breadboard/breadboard.cache/wt} [current_project]
set_property parent.project_path {C:/Users/Jessica Yang/Documents/ece350/breadboard/breadboard.xpr} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo {c:/Users/Jessica Yang/Documents/ece350/breadboard/breadboard.cache/ip} [current_project]
set_property ip_cache_permissions {read write} [current_project]
OPTRACE "Creating in-memory project" END { }
OPTRACE "Adding files" START { }
read_mem {{C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/logic.mem}}
read_verilog -library xil_defaultlib {
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/vga/RAM.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/ROM.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/vga/VGATimingGenerator.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/Wrapper.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/add/add_32.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/add/add_8.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/alu.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/and_gate.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/multdiv/multiplier/control.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/multdiv/counter/counter_7.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/regfile/decoder.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/register/dffe_ref.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/multdiv/divider/divider_nonres.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/multdiv/multiplier/mult_booth.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/multdiv/multdiv.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/mux/mux_2_32.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/mux/mux_4_32.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/mux/mux_8_32.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/not_gate.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/or_gate.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/processor.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/regfile/regfile.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/register/register_32.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/register/register_64.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/register/register_65.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/register/register_7.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/segment_decoder.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/sign_extend_17.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/sll/sll_1.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/sll/sll_16.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/sll/sll_2.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/sll/sll_4.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/sll/sll_8.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/sll/sll_barrel.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/sra/sra_1.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/sra/sra_16.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/sra/sra_2.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/sra/sra_4.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/sra/sra_8.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/alu/sra/sra_barrel.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/processor/register/tri_state.v}
  {C:/Users/Jessica Yang/Documents/ece350/breadboard/vga/VGAController.v}
}
OPTRACE "Adding files" END { }
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc {{C:/Users/Jessica Yang/Documents/ece350/breadboard/vga/constraints.xdc}}
set_property used_in_implementation false [get_files {{C:/Users/Jessica Yang/Documents/ece350/breadboard/vga/constraints.xdc}}]

set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

OPTRACE "synth_design" START { }
synth_design -top VGAController -part xc7a100tcsg324-1
OPTRACE "synth_design" END { }


OPTRACE "write_checkpoint" START { CHECKPOINT }
# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef VGAController.dcp
OPTRACE "write_checkpoint" END { }
OPTRACE "synth reports" START { REPORT }
create_report "synth_1_synth_report_utilization_0" "report_utilization -file VGAController_utilization_synth.rpt -pb VGAController_utilization_synth.pb"
OPTRACE "synth reports" END { }
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
OPTRACE "synth_1" END { }
