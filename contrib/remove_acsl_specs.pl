#!/usr/bin/env perl

use warnings;
use strict;
use Fcntl qw(:flock SEEK_END);

unless (@ARGV) {
	die("usage: $0 <files>\n");
}

foreach my $file (@ARGV) {
	if (-f $file && -r _) {
		if (open(my $fh, '+<', $file)) {
			flock($fh, LOCK_EX)
				or warn "Can't lock file $file: $!\n";

			my $text = join('', <$fh>);
			if ($text =~ s!
				(?<line_begin>^)? # line start
				\h*               # whitespaces
				(?:
				# multiline spec
				# match /*@
				/\*\h*\@
				[^*]*\*+
				(?:[^/*][^*]*\*+)*/
				# remove trailing newline if possible and
				# line started from comment
				\h*(?(<line_begin>)\n)?
				|
				# singleline spec
				//\h*\@(?:[^\\]|[^\n][\n]?)*?
				# remove trailing newline if
				# line started from comment
				(?(<line_begin>)\n)
				)
				!!xmg) {
				seek $fh, 0, 0;
				truncate $fh, 0;
				print $fh $text;
			}

			close($fh)
				or warn "Close failed: $!";
		} else {
			warn "Can't open file $file: $!";
		}
	} else {
		warn("Unknown file: $file\n");
	}
}
