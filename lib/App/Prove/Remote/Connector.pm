use strict;
use warnings;

use Net::OpenSSH ();
use Net::SFTP::Foreign ();

use experimental 'signatures';

# Cache the connections/objects internally
my ( $ssh, $sftp );
sub new ( $class,  $host='127.0.0.1', $verbosity ) {
    my $obj = bless {
        'ppid'      => $$, # May not need this ultimately
        'host'      => $host,
        'verbosity' => $verbosity
    }, $class;
    return $obj;
}

# Plenty o code duplication here, can probably golf down?
sub ssh ($self) {
    return $ssh if $ssh;
    print "# Connecting to $self->{'host'} via Net::OpenSSH" if $self->{'verbosity'} >= 1;
    $ssh = Net::OpenSSH->new($self->{'host'});
    return $ssh;
}

sub sftp ($self) {
    return $sftp if $sftp;
    print "# Connecting to $self->{'host'} via Net::SFTP::Foreign" if $self->{'verbosity'} >= 1;
    $sftp = Net::SFTP::Foreign->new($self->{'host'});
    return $sftp;
}

1;
