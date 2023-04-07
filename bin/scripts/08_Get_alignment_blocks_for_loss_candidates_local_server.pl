

use Bio::EnsEMBL::Registry;
Bio::EnsEMBL::Registry->load_registry_from_db(
    -host => '202.205.131.17',
    -user => 'Anonymous',
);


use Bio::EnsEMBL::Compara::DBSQL::DBAdaptor;

my $host   = '202.205.131.17';
my $user   = 'Anonymous';
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

my $human_genome_db = $genome_db_adaptor->fetch_by_name_assembly('homo_sapiens');
my $mouse_genome_db = $genome_db_adaptor->fetch_by_name_assembly('mus_musculus');

my $method_link_species_set_adaptor = Bio::EnsEMBL::Registry->get_adaptor(
    'Multi', 'compara', 'MethodLinkSpeciesSet'
);

my $human_mouse_lastz_net_mlss =
$method_link_species_set_adaptor->fetch_by_method_link_type_registry_aliases("EPO", ["Mouse", "Human", "Chimpanzee", "Gorilla", "Orangutan","pan_paniscus", "Gibbon",
    "Vervet-AGM", "Olive baboon", "Macaque", "macaca_fascicularis", "Marmoset",
    "Mouse Lemur", "Mus_spretus", "Ryukyu mouse", "Shrew mouse", "Rat",
    "Prairie vole", "Rabbit", "Cat", "Dog", "Horse", "Sheep", "capra_hircus", "Cow", "Pig"]
);
my $output_format = "fasta";
my $alignIO = Bio::AlignIO->newFh(
    -interleaved => 0,
    -fh => \*STDOUT,
    -format => $output_format,
    -idlength => 10
);


#依据参照物种基因组选定区域来获取block
#my $query_species = 'Human';
my $query_species = $ARGV[0];
# print $ARGV[0];


my $slice_adaptor = Bio::EnsEMBL::Registry->get_adaptor(
    $query_species, 'core', 'Slice'
);

my $line_use = <STDIN>;
chomp $line_use;
my @line_strings = split(" ", $line_use);

my $gene_id = $line_strings[0];
my $start_cor = $line_strings[2];
my $end_cor = $line_strings[3];

my $query_slice = $slice_adaptor->fetch_by_gene_stable_id($gene_id);
my $genomic_align_blocks = $genomic_align_block_adaptor->fetch_all_by_MethodLinkSpeciesSet_Slice($human_mouse_lastz_net_mlss,$query_slice);

foreach my $genomic_align_block( @{ $genomic_align_blocks   }  )
{
    my $restricted_gab = $genomic_align_block->restrict_between_reference_positions(int($start_cor), int($end_cor), undef, 1);
    #print $restricted_gab;
    if(defined($restricted_gab)){
    my $simple_align = $restricted_gab->get_SimpleAlign;
    print ">";
    print $gene_id;
    #print $alignIO $simple_align;
    foreach my $seq ($simple_align->each_seq()){
        my $out = $seq->get_nse();
        print ">";
        print $out;
        print "\n";
        }
    }
}

