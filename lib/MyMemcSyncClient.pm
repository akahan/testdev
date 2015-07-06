=encoding utf8

=cut

package MyMemcSyncClient;

use Modern::Perl;
use IO::Socket::INET;

use constant MEMC_HOST => "127.0.0.1";
use constant MEMC_PORT => "11211";

=head1 PRIVATE

=over

=cut

=item _send_and_read

Откроем сокет, отправим данные и прочитаем

=cut

sub _send_and_read {
    my ( $command ) = @_;

    my $socket = IO::Socket::INET->new(
        PeerAddr => MEMC_HOST,
        PeerPort => MEMC_PORT,
        Proto    => 'tcp'
    );

    $socket->send($command) or die "Can't send to socket.";

    my $buf;
    $socket->recv( $buf, 1024);
    $socket->close;

    my @data = split "\r\n", $buf;

    return @data;
}

=back

=cut


=head1 METHODS

=over

=cut

=item new

=cut

sub new {
    my ( $class, %param ) = @_;
    return bless {}, $class;
}

=item set

Запишем значение value по ключу key

=cut

sub set {
    my ( $self, $key, $value, %param ) = @_;

    my $flags = 0;
    my $exptime = $param{exptime} || 3600;
    my $length = length "$value";

    my $command = sprintf "set %s %u %u %u\r\n%s\r\n", $key, $flags, $exptime, $length, $value;
    my @data = _send_and_read($command); # Отправим команду и прочитаем ответ

    unless ( $data[0] eq "STORED" ) {
        $self->{_error} = $data[0];
        return '';
    }

    1;
}

=item get

Прочитаем значение по ключу key

=cut

sub get {
    my ( $self, $key ) = @_;

    my $command = sprintf "get %s\r\n", $key;
    my @data = _send_and_read($command); # Отправим команду и прочитаем ответ

    unless ( $data[0] =~ /^VALUE/ ) {
        $self->{_error} = $data[0];
        return '';
    }

    my $value = $data[1];

    return $value;
}

=item delete

Удалим запись по ключу key

=cut

sub delete {
    my ( $self, $key ) = @_;

    my $command = sprintf "delete %s\r\n", $key;
    my @data = _send_and_read($command); # Отправим команду и прочитаем ответ

    unless ( $data[0] eq "DELETED" ) {
        $self->{_error} = $data[0];
        return '';
    }

    1;
}

=back

=cut

1;

