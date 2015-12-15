#!/usr/bin/perl
use strict;
use warnings;
use Bio::Phylo::IO qw'parse unparse';
use Bio::Phylo::Util::CONSTANT ':objecttypes';

# Usage: perl fasta2nexus.pl infile > outfile

my $file = shift;
my $proj = parse(
	'-format'     => 'fasta',
	'-file'       => $file,
	'-type'       => 'dna',
	'-as_project' => 1,
);
my ($matrix) = @{ $proj->get_items(_MATRIX_) };
$matrix->visit(sub{
	my $row = shift;
	my @parts = split /_/, $row->get_name;
	$row->set_name($parts[-1]);
});
print unparse(
	'-format' => 'nexus',
	'-phylo'  => $proj,
);
print <<'MRBAYES';
BEGIN MRBAYES;
	lset nst=6 rates=invgamma;
	mcmc ngen=10000 samplefreq=10;
	sumt burnin=250 contype=allcompat;
END;
MRBAYES
