#!/usr/bin/env perl

use 5.014;

use strict;
use warnings FATAL => 'all';

use re '/aasx';

=head1 NAME

t/rprove.t - what rprove hands to prove, and what the shim runs on the remote host

=head1 DESCRIPTION

L<Net::OpenSSH> is mocked: C<new> builds an object that does not connect, and
C<system> runs the command in a local C<sh>, which stands in for the shell of
the remote host.  L<App::Prove/run> is mocked, so no test runs under C<prove>.

=cut

# It imports by being loaded, which ProhibitUnusedImports cannot see.
use Test2::V1 -i;    ## no critic (ProhibitUnusedImports)
use Test2::Tools::Exception qw{dies lives};
use Test::MockModule        qw{strict};
use Capture::Tiny           qw{capture};
use Cwd                     ();
use File::Temp              qw{tempdir};
use Net::OpenSSH::Constants qw{OSSH_MASTER_FAILED OSSH_SLAVE_CMD_FAILED};
use Scalar::Util            qw{dualvar};

use FindBin ();

# A program, not a module on @INC.
ok( lives { require "$FindBin::Bin/../bin/rprove" }, 'bin/rprove loads as a module, and runs nothing' )    ## no critic (RequireBarewordIncludes)
  or bail_out("bin/rprove does not load: $@");

# A tree on the fake remote host: a test that passes, one that exits 3 after
# its plan is done, and one that warns.  The work directory has a space in it.
my $remote  = Cwd::abs_path( tempdir( CLEANUP => 1 ) );
my $workdir = "$remote/work dir";
mkdir $workdir     or die $!;
mkdir "$workdir/t" or die $!;
mkdir "$remote/t"  or die $!;
write_test( "$workdir/t/pass.t",  q{print "1..1\nok 1 - in the work directory\n"; exit 0;} );
write_test( "$remote/t/pass.t",   q{print "1..1\nok 1 - in the starting directory\n"; exit 0;} );
write_test( "$workdir/t/exit3.t", q{print "1..1\nok 1\n"; exit 3;} );
write_test( "$workdir/t/warns.t", q{print "1..1\nok 1\n"; warn "a warning\n"; exit 0;} );

my ( @hosts, @system_opts, $fake_error );
my $ssh = Test::MockModule->new('Net::OpenSSH');
$ssh->redefine(
    new => sub {
        my ( $class, $host ) = @_;
        push @hosts, $host;
        return $ssh->original('new')->( $class, $host, connect => 0 );
    }
);
$ssh->redefine( error => sub { return $fake_error } );
my $fake_system = sub {
    my ( undef, $opts, $command ) = @_;
    push @system_opts, $opts;
    $command .= ' 2>&1'       if $opts->{stderr_to_stdout};
    $command .= ' </dev/null' if $opts->{stdin_discard};
    system( 'sh', '-c', $command );    ## no critic (ProhibitShellDispatch) the fake shell of the remote host
    $fake_error = $? ? OSSH_SLAVE_CMD_FAILED : 0;
    return !$?;
};
$ssh->redefine( system => $fake_system );

# remote_shim($test) run from the directory where ssh starts on the fake remote
# host, with %env as the environment.  Returns the exit code and what it printed.
sub shim {
    my ( $test, %env ) = @_;
    local @ENV{ keys %env } = values %env;
    $fake_error = 0;
    my $was = Cwd::getcwd();
    chdir $remote or die "Cannot chdir to $remote: $!";
    my $code;
    my ( $out, $err ) = capture { $code = App::Prove::Remote::Script::remote_shim($test) };
    chdir $was or die $!;
    return ( $code, $out, $err );
}

subtest remote_shim => sub {
    my %env = ( RPROVE_HOST => 'remote.test.test', RPROVE_WORK_DIR => $workdir, RPROVE_INTERPRETER => $^X );

    @hosts = ();
    my ( $code, $out ) = shim( 't/pass.t', %env );
    is( $code,   0,                                      'A test that passes exits 0' );
    is( $out,    "1..1\nok 1 - in the work directory\n", 'and runs from the work directory, a path with a space in it' );
    is( \@hosts, ['remote.test.test'],                   'It connects to the host in RPROVE_HOST' );

    ( $code, $out ) = shim( 't/pass.t', %env, RPROVE_WORK_DIR => '' );
    is( $code, 0,                                          'With no work directory, a relative test still runs' );
    is( $out,  "1..1\nok 1 - in the starting directory\n", 'from the directory where ssh starts' );

    ( $code, $out ) = shim( 't/exit3.t', %env );
    is( $code, 3, 'The exit code of the test is the exit code of the shim, so prove sees the failure' );

    ( $code, $out ) = shim( 't/warns.t', %env );
    like( $out, qr{^a[ ]warning$}m, 'What the test prints to standard error comes back on standard output, for prove to show' );
    is( $system_opts[-1]{stdin_discard}, 1, 'The test reads nothing from the terminal of the caller' );

    ( $code, $out ) = shim( q{t/it's here.t}, %env, RPROVE_INTERPRETER => 'echo' );
    is( $out, "t/it's here.t\n", 'The remote shell gets the test path as one word, quotes and all' );

    ( $code, $out ) = shim( 't/pass.t', %env, RPROVE_INTERPRETER => "$^X -w" );
    is( $code, 0, 'The interpreter can carry arguments' );

    is( dies { shim( undef, %env ) }, "No test passed in!\n", 'It dies without a test' );

    $ssh->redefine( error => sub { return dualvar( OSSH_MASTER_FAILED, 'connection refused' ) } );
    is(
        dies { shim( 't/pass.t', %env ) },
        "Cannot connect to remote.test.test: connection refused\n",
        'It dies with the error of ssh when it cannot connect, naming the host'
    );
    $ssh->redefine( error => sub { return $fake_error } );

    $ssh->redefine( system => sub { $fake_error = dualvar( OSSH_MASTER_FAILED, 'master process exited' ); return } );
    is(
        dies { shim( 't/pass.t', %env ) },
        "Cannot run t/pass.t on remote.test.test: master process exited\n",
        'It dies when ssh fails, rather than taking a stale $? for the exit code of the test'
    );
    $ssh->redefine( system => $fake_system );
};

subtest exit_code => sub {
    is( App::Prove::Remote::Script::exit_code(0),   0,   'Exit 0 is 0' );
    is( App::Prove::Remote::Script::exit_code(256), 1,   'Exit 1 is 1, not the wait status 256, which exit() would take as 0' );
    is( App::Prove::Remote::Script::exit_code(9),   255, 'A process killed by a signal fails' );
};

subtest run => sub {
    my ( @proves, $passes );
    my $prove = Test::MockModule->new('App::Prove');
    $prove->redefine(
        run => sub {
            my ($self) = @_;
            push @proves, {
                exec    => $self->exec,
                merge   => $self->merge,
                argv    => $self->argv,
                verbose => $self->verbose,
                env     => { map { $_ => $ENV{$_} } qw{RPROVE_HOST RPROVE_WORK_DIR RPROVE_INTERPRETER} },
            };
            return $passes;
        }
    );

    local @ENV{qw{RPROVE_HOST RPROVE_WORK_DIR RPROVE_INTERPRETER}};
    $passes = 1;
    is( App::Prove::Remote::Script::run(qw{--host remote.test.test --workdir /bogus/work --interpreter /bogus/perl -v t/a.t}), 0, 'It exits 0 when prove passes' );
    is(
        $proves[-1],
        {
            exec    => $0,
            merge   => 1,
            argv    => ['t/a.t'],
            verbose => 1,
            env     => { RPROVE_HOST => 'remote.test.test', RPROVE_WORK_DIR => '/bogus/work', RPROVE_INTERPRETER => '/bogus/perl' },
        },
        'Prove runs each test with rprove itself, merged, and gets the options of prove; the shim gets the rest in its environment'
    );
    is( $ENV{RPROVE_HOST}, undef, 'The environment is put back afterwards, so this process is not taken for the shim' );

    $passes = 0;
    is( App::Prove::Remote::Script::run('t/a.t'), 1, 'It exits 1 when prove fails' );
    is(
        $proves[-1]{env},
        { RPROVE_HOST => '127.0.0.1', RPROVE_WORK_DIR => '', RPROVE_INTERPRETER => '/usr/bin/perl' },
        'The defaults: the local host, no work directory, and /usr/bin/perl'
    );
};

done_testing();

sub write_test {
    my ( $path, $code ) = @_;
    open my $fh, '>', $path or die "Cannot write $path: $!";
    print {$fh} "$code\n" or die $!;
    close $fh             or die $!;
    return;
}
