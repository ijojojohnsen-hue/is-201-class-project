#!/usr/bin/perl
use strict;
use warnings;
use File::Spec;
my $src = 'images/Mission photos';
my $dst = 'images/Mission photos_removed';
unless(-d $src){ die "Source not found: $src\n" }
mkdir $dst unless -d $dst;
opendir(my $dh, $src) or die $!;
my @files = grep { !/^\.DS_Store$/ && -f File::Spec->catfile($src, $_) } readdir($dh);
closedir $dh;
my $count = scalar @files;
my $keep = 30;
if($count <= $keep){ print "Only $count files found; nothing moved\n"; exit 0 }
srand();
my %keep;
while(keys %keep < $keep){ $keep{$files[int(rand(@files))]} = 1 }
my @moved;
foreach my $f (@files){
    unless($keep{$f}){
        my $s = File::Spec->catfile($src, $f);
        my $d = File::Spec->catfile($dst, $f);
        if(rename $s, $d){ push @moved, $f }
        else { warn "Failed to move $f: $!\n" }
    }
}
print "Total files: $count\n";
print "Kept: ", scalar(keys %keep), "\n";
print "Moved: ", scalar(@moved), "\n";
open my $kfh, '>', File::Spec->catfile($dst, 'kept_files.txt') or warn $!;
print $kfh join("\n", sort keys %keep);
close $kfh;
print "Kept list written to $dst/kept_files.txt\n";
