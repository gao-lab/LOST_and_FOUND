
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

my $host = $ARGV[0];
my $user = $ARGV[1];

$registry->set_reconnect_when_lost(1);

$registry->load_registry_from_db(
  -host => $host,
  -user => $user,
);

use Bio::EnsEMBL::Compara::DBSQL::DBAdaptor;
my $host   = $host;
my $user   = $user;
my $dbname = 'ensembl_compara_94';

my $comparadb= new Bio::EnsEMBL::Compara::DBSQL::DBAdaptor(
    -host   => $host,
    -user   => $user,
    -dbname => $dbname,
    -species=> 'Multi',
);

my $genomic_align_block_adaptor = Bio::EnsEMBL::Registry->get_adaptor(
    'Multi', 'compara', 'GenomicAlignBlock'
);

my $genome_db_adaptor = Bio::EnsEMBL::Registry->get_adaptor(
    'Multi', 'compara', 'GenomeDB'
);

my $method_link_species_set_adaptor = Bio::EnsEMBL::Registry->get_adaptor(
    'Multi', 'compara', 'MethodLinkSpeciesSet'
);

my $human_mouse_lastz_net_mlss =
$method_link_species_set_adaptor->fetch_by_method_link_type_species_set_name($ARGV[3], $ARGV[4]);

my $output_format = "fasta";
my $alignIO = Bio::AlignIO->newFh(
    -interleaved => 0,
    -fh => \*STDOUT,
    -format => $output_format,
    -idlength => 10
);

my $query_species = $ARGV[2];

my $slice_adaptor = Bio::EnsEMBL::Registry->get_adaptor(
    $query_species, 'core', 'Slice'
);



my $line = <STDIN>;

my $line_use = $line;
chomp $line_use;
my @line_strings = split(" ", $line_use);
my $start_cor = $line_strings[2] - $ARGV[5];
my $end_cor = $line_strings[2];
my $chr = $line_strings[1];
my $query_slice = $slice_adaptor->fetch_by_region('chromosome', $chr, $start_cor, $end_cor);
my $genomic_align_blocks = $genomic_align_block_adaptor->fetch_all_by_MethodLinkSpeciesSet_Slice($human_mouse_lastz_net_mlss,$query_slice);
foreach my $genomic_align_block( @{ $genomic_align_blocks   }  )
{
    my $simple_align = $genomic_align_block->get_SimpleAlign;
    print ">";
    print $line_strings[0], " Upstreams_Blocks";
    foreach my $seq ($simple_align->each_seq()){
        my $out = $seq->get_nse();
        print ">";
        print $out;
        print "\n";
    }
}