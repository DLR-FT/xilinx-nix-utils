array set args [list -prj_file "" -name "" -out "" -jobs 1 {*}$argv]

set prj_file $args(-prj_file)
set name $args(-name)
set out_dir $args(-out)
set jobs $args(-jobs)

if {$prj_file eq ""} {
    puts "missing -prj_file arg."
    exit 1
}

if {$out_dir eq ""} {
    set out_dir [file dirname $prj_file]
}

open_project $prj_file

if {$name eq ""} {
    set name [get_project]
}

delete_runs -quiet impl_1
launch_runs impl_1 -to_step write_bitstream -jobs $jobs
wait_on_run impl_1

open_run impl_1
write_bitstream -force [file join $out_dir $name.bit]
write_hw_platform -fixed -force [file join $out_dir $name.xsa]