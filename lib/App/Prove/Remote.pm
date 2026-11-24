package App::Prove::Remote;

# ABSTRACT: Run prove here, and each test on another host over SSH

use 5.014;

use strict;
use warnings FATAL => 'all';

1;

__END__

=for test_synopsis BEGIN { die "SKIP: the synopsis is a shell command, not perl\n"; }

=head1 SYNOPSIS

    rprove --host test.test --workdir /srv/checkout -v t/

=head1 DESCRIPTION

This distribution installs L<rprove>, a wrapper around L<prove>.  B<rprove>
runs C<prove> on your machine, and C<prove> runs each test on another host
over SSH, with L<Net::OpenSSH>.  The TAP and the exit code of each test come
back to C<prove>, so the summary is the same as if the tests ran on your
machine.

Use it when a test must run in a disposable environment, such as a virtual
machine, instead of on your machine.  It can also run from the orchestrator of
a CI system.

B<rprove> does not copy anything to the remote host.  Before you run it, put
the tests and the code that they test on the remote host.  See L<rprove> for
the options.

This module has no code.  It holds the documentation of the distribution.

=head1 INSTALLATION

    cpanm App::Prove::Remote

The tests of L<Net::OpenSSH> try to connect to localhost over SSH.  If that
host does not accept your key, install L<Net::OpenSSH> first with
C<cpanm --notest Net::OpenSSH>.

=head1 TROUBLESHOOTING

B<rprove> connects with your OpenSSH client and its configuration.  If
C<ssh> connects to the host without a password prompt, B<rprove> connects too.
If it cannot connect, the test fails with the message from L<Net::OpenSSH>.

=head1 SEE ALSO

L<rprove>

L<App::Prove>

L<Net::OpenSSH>

=cut
