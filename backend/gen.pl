#!/usr/bin/env perl
use utf8;
use 5.12.0;
use Algorithm::Diff;
use String::Similarity;
my $prev = '：';
my $prev_title = '';
my @rows = <>;
my $comma = 'window.dodoData = [';
utf8::decode($_) for @rows;
binmode STDOUT, ':utf8';
for (sort @rows) {
    chomp;
    my ($this, $title) = split /\t/, $_, 2;
    my ($this_book, $this_quote) = split /：/, $this, 2 or die;
    my ($prev_book, $prev_quote) = split /：/, $prev, 2 or die;
    my ($p, $t) = ($prev_quote, $this_quote);
    $p =~ s/[。，！：；『、「」』，？]//g;
    $t =~ s/[。，！：；『、「」』，？]//g;
    my $prev_key = $prev_title;
    my $this_key = $title;
    ($prev_title, $prev) = ($title, $this);
    next if index($p, $t) >= 0 or index($t, $p) >= 0;
    next if $this_book ne $prev_book;
    my $similarity = similarity($p, $t);
    if ($similarity > 0.75) {
        my @p = split //, $prev_quote;
        my @t = split //, $this_quote;
        my @sdiffs  = Algorithm::Diff::sdiff( \@p, \@t );
        my ($pq, $tq);
        for my $row (@sdiffs) {
            my ($op, $px, $tx) = @$row;
            if ($op eq 'u') {
                $pq .= $px;
                $tq .= $tx;
            }
            else {
                $pq .= "`$px~" if length $px;
                $tq .= "`$tx~" if length $tx;
            }
        }
        $pq =~ s!~`!!g;
        $tq =~ s!~`!!g;
        print qq[$comma"$prev_book\\n$prev_key\\n$pq\\n$this_key\\n$tq"\n];
        $comma = ',';
    }
}
print "]\n";
