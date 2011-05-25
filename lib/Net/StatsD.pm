package Net::StatsD;
use Moose;
use IO::Socket;

=head1 NAME

Net::StatsD - Sends statistics to etsy's stats daemon over UDP

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Sends statistics to the stats daemon over UDP

    use Net::StatsD;

    my $s = Net::StatsD->new();
    $s->increment('logins');
    $s->increment(['errors','exceptions.unhandled']));

    $s->timing('process.initialize', $initialize_ms);

=head1 METHODS

=head2 timing

Log timing information

=cut

sub timing {
    my ($self, $stat, $time, $sample_rate) = @_;

    $sample_rate ||= 1;
    $self->send({$stat => "$time|ms"}, $sample_rate);
}

=head2 increment

Increments one or more stats counters

=cut

sub increment {
    my ($self, $stats, $sample_rate) = @_;

    $sample_rate ||= 1;
    $self->update_stats($stats, 1, $sample_rate);
}

=head2 decrement

Decrements one or more stats counters.

=cut

sub decrement {
    my ($self, $stats, $sample_rate) = @_;

    $sample_rate ||= 1;
    $self->update_stats($stats, -1, $sample_rate);
}

=head2 update_stats

Updates one or more stats counters by arbitrary amounts.

=cut

sub update_stats {
    my ($self, $stats, $delta, $sample_rate) = @_;

    $delta ||= 1;
    $sample_rate ||= 1;
    if (ref($stats) ne 'ARRAY') {
        $stats = [$stats];
    }
    my %data = ();
    foreach my $stat (@$stats) {
        $data{$stat} = "$delta|c";
    }

    $self->send(\%data, $sample_rate);
}

=head2 send_data

Squirt the metrics over UDP

=cut

sub send {
    my ($self, $data, $sample_rate) = @_;

    $sample_rate ||= 1;

    # sampling
    my %sampled_data = ();

    if ($sample_rate < 1) {
        while ( my ($stat, $value) = each(%$data) ) {
            if ( rand() <= $sample_rate ) {
                $sampled_data{$stat} = "$value|\@$sample_rate";
            }
        }
    }
    else {
        %sampled_data = %$data;
    }

    # Failures in any of this should be silently ignored
    eval {
        my $host = $ENV{'STATSD_HOST'} || 'localhost';
        my $port = $ENV{'STATSD_PORT'} || '1234';
        my $fp = IO::Socket::INET->new(
		    PeerAddr => $host,
		    PeerPort => $port,
		    Proto => 'udp',
    	);
    	return if (!$fp);
    	while ( my ($stat, $value) = each(%sampled_data) ) {
    	    print $fp "$stat:$value";
    	}
    	close $fp;
    };
}

=head1 AUTHOR

Horacio Gonzalez, C<< <horacio.gonzalez at lan.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-statsd at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-StatsD>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::StatsD


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-StatsD>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-StatsD>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-StatsD>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-StatsD/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Horacio Gonzalez.

This program is released under the following license: artistic


=cut

1; # End of Net::StatsD

