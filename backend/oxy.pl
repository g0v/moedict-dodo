#!/usr/bin/env perl
use utf8;
use File::Slurp;
# http://kcwu.csie.org/~kcwu/tmp/synonyms.html
@_ = File::Slurp::read_file('synonyms.html', binmode => ':utf8' ) ;
my $comma = "window.dodoOxynyms = [";
while ($_ = shift @_) {
    /^(\S+)\s+(\S+)/ or die $_;
    my $next = shift @_;
    $next =~ s{<[/ab][^>]*>}{}g;
    my $len = 0;
    while ($next =~ s{\-}{}) {
        $len++;
    }
    next unless $len <= 4;
    chomp $next;
    $next =~ s/\s+$//;
    $next =~ /(\S+).*\s(\S+)/ or die "X?$next";
    my $tokens = join "、", map { "「$_」" } split(/\s*[<>]\s*/, $next);
    my $key = "$1$2";
    next if $1 eq '異日';
    if ($len > 2) {
        print qq[$comma"教育部重編國語辭典修訂本\\n$1\\n「$1」、「$2」的意思`相反~。\\n$2\\n${tokens}中，相鄰的詞意思`近似~。"\n];
    }
    else {
        print qq[$comma"教育部重編國語辭典修訂本\\n$1\\n「$1」、「$2」的意思`相反~。\\n$2\\n${tokens}的意思`近似~。"\n];
    }
    $comma = ",";
}
print "]\n";
