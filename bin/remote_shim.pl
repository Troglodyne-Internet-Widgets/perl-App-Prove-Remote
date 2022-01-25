#!/usr/bin/env perl
use strict;
use warnings;

my $wd   = $ENV{'RPROVE_WORK_DIR'};
my $test = $ARGV[0];
my $ssh  = Net::OpenSSH->new($ENV{'RPROVE_HOST'});

# Print directly to stdout, as this function merges
# STDOUT & STDERR and discards STDIN.
# Do this to avoid TTY overflow, and because prove expects
# to capture output from STDOUT/ERR anyways.
my $system_opts = {
    'stdout_discard'   => 0,
    'stderr_discard'   => 0,
    'stderr_to_stdout' => 1,
    'stdin_discard'    => 1,
};

# Optionally move to the working directory.
my $cd = $wd ? "cd $wd && " : '';
$ssh->system(
    $system_opts, "${cd}$ENV{'RPROVE_INTERPRETER'} '$wd/$test'" 
);

# Net::OpenSSH sets this value correctly for our purposes here.
exit $?;
