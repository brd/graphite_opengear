#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use Net::SNMP;
use IO::Socket;

my $opengear_host = 'test.example.com';
my $opengear_community = 'public'
my $graphite_host = '127.0.0.1';
my $graphite_path = 'env.server_room';

my ($session, $error) = Net::SNMP->session(
	Hostname => $opengear_host,
	Community => $opengear_community,
) or die "Session: $!";

my $temp_oid  = ".1.3.6.1.4.1.25049.16.4.1.3.1";
my $humid_oid = ".1.3.6.1.4.1.25049.16.4.1.4.1";

my $epoch = time;

# Poll
my $temp = $session->get_request("$temp_oid") or die "failed to poll temperature: $!";
my $humid = $session->get_request("$humid_oid") or die "failed to poll humidity: $!";

#print "temp is: $temp->{$temp_oid}\n";
#print "humid is: $humid->{$humid_oid}\n";

# Setup graphite connection
my $client = IO::Socket::INET->new(
		Proto => 'tcp',
		PeerAddr => $graphite_host,
		PeerPort => 2003,
	) or die "Cannot connect: $!";

# Send data to graphite
say $client "$graphite_path " . $temp->{$temp_oid} . ' ' . $epoch;
say $client "$graphite_path " . $humid->{$humid_oid} . ' ' . $epoch;

$client->close();

$session->close();
