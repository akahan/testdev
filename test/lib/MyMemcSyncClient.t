use Modern::Perl;
use lib::gitroot qw/:lib/;
use Test::Spec;
use MyMemcSyncClient;

my $class = "MyMemcSyncClient";

describe MyMemcSyncClient => sub {
    describe process  => sub {
        my $client;

        before all => sub {
            $client = $class->new();
        };

        it "should be $class" => sub {
            isa_ok $client, $class;
        };

        it "set" => sub {
            is $client->set( "testkey", 38792 ), 1;
        };

        it "get" => sub {
            is $client->get( "testkey" ), 38792;
        };

        it "delete" => sub {
            is $client->delete( "testkey" ), 1;
            is $client->get( "testkey" ), '';
        };
    };
};

runtests unless caller;
