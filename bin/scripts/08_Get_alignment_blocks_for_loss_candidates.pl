

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->set_reconnect_when_lost(1);

my $host = $ARGV[0];
my $user = $ARGV[1];

$registry->load_registry_from_db(
  -host => $ARGV[0],
  -user => $ARGV[1],
);
#  -host => 'ensembldb.ensembl.org',
#  -user => 'anonymous',
use Bio::EnsEMBL::Compara::DBSQL::DBAdaptor;

my $host   = $ARGV[0];
my $user   = $ARGV[1];
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
    $method_link_species_set_adaptor->fetch_by_method_link_type_species_set_name(
    $ARGV[3], $ARGV[4]
);

my $query_species = $ARGV[2];

my $slice_adaptor = $registry->get_adaptor(
    $query_species, 'core', 'slice'
);

my $line = <STDIN>;
chomp $line;
my @line_strings = split(" ", $line);
my $gene_id = $line_strings[0];
my $start_cor = $line_strings[2];
my $end_cor = $line_strings[3];
my $query_slice = $slice_adaptor->fetch_by_gene_stable_id($gene_id);
my $genomic_align_blocks = $genomic_align_block_adaptor->fetch_all_by_MethodLinkSpeciesSet_Slice($human_mouse_lastz_net_mlss,$query_slice);
foreach my $genomic_align_block( @{ $genomic_align_blocks   }  )
{
    my $restricted_gab = $genomic_align_block->restrict_between_reference_positions(int($start_cor), int($end_cor));
    if(defined($restricted_gab)){
    my $simple_align = $restricted_gab->get_SimpleAlign;
    print '>';
    print $gene_id;
    foreach my $seq ($simple_align->each_seq()) {
        my $out = $seq->get_nse();
        print ">";
        print $out;
        print "\n";
        }
    }
}

