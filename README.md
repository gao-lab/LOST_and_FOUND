# LOST-and-FOUND
- 2023-01-21 20:00, Zhengyang Wen
- This is a repository for data and scripts of LOST & FOUND

## Introduction
LOST & FOUND (LOcal Sequence based Tracing Founctional Orthologous UNit Death) is a pipeline for gene loss identification. With orthologous relations and genome alignment data, it can identify gene loss events efficiently. For more detailed information, please check the manuscript Genome-wide identification of gene loss events suggests loss relics as a potential source for functional lncRNAs in human. 

## Download
Dependencies:  
Scripts: python package - pyinterval  
         linux command - bedtools  
Data:    perl package - Ensembl Perl API  

```
tom@linux$ git clone git@github.com:gao-lab/LOST-and-FOUND.git
```
## Usage


Here, we demostrate how to use LOST & FOUND. The example used here is the identification of human gene loss in the manuscript Genome-wide identification of gene loss events suggests loss relics as a potential source for functional lncRNAs in human.  


Please note that to apply LOST & FOUND in other speices, the user may need to provide orthologous relation and genome alignment data in required format. We will show how to acquire required data in the Data Process part.


### 1.Identify gene loss candidates  

This step is to generate gene loss candidates of orthologous groups. 


It requires the following input:

````
--IDheader
# Headers of Ensembl Gene ID and their corresponding species name written in “Python dict format”
--OrthologousPath 
# Path that contains orthologous relation files. It should contains the orthologous relation files between anchor and target species branch. 
The orthologous relations file should contain the following columns (delimited by tab):

#Gene stable ID  Chromosome/scaffold name        Gene start (bp) Gene end (bp)   Human gene stable ID    Human chromosome/scaffold name  Human chromosome/scaffold start (bp)    Human chromosome/scaffold end (bp)      Human homology type     %id. target Human gene identical to query gene  %id. query gene identical to target Human gene.

Orthologous relation files can be obtained via Ensembl BioMart.

--AnchorSpeciesSet
# Names of anchor species written in “Python list format”
--TargetTree
# The phylogeny tree of target branch used for maximum parsimony inference, written in “Python list format”
--TargetSpecies
# Target species name
--OutputPath
# Path for output results
````



The output of this step is `Loss_candidates_of_orthologous_group`. Each line of this output represents an orthologous group and it consists of loss node, gene state in each species, gene number in each species and its gene members.  


Here, we show an example in `example/result/Loss_candidates_of_orthologous_group`:



```
Loss_node:Macaca-Gorilla-Human-Chimp    Exist_Shrew_1_Gorilla_0_Rat_1_Ryukyu_1_Human_0_Macaca_1_Chimp_1_Mouse_1 Num_Shrew_1_Gorilla_0_Rat_1_Ryukyu_1_Human_0_Macaca_1_Chimp_1_Mouse_1   MGP_PahariEiJ_G0025857  ENSMMUG00000016490      ENSPTRG00000045117      ENSMUSG00000027443      ENSRNOG00000004946      MGP_CAROLIEiJ_G0024414
Loss_node:Human-Chimp   Exist_Shrew_1_Gorilla_1_Rat_1_Ryukyu_1_Human_0_Macaca_1_Chimp_1_Mouse_1 Num_Shrew_1_Gorilla_1_Rat_1_Ryukyu_1_Human_0_Macaca_1_Chimp_1_Mouse_1   ENSPTRG00000051474      ENSMUSG00000046828      ENSMMUG00000000353      MGP_PahariEiJ_G0027346  ENSRNOG00000022762      MGP_CAROLIEiJ_G0014103  ENSGGOG00000026202
Loss_node:Macaca-Gorilla-Human-Chimp    Exist_Shrew_1_Gorilla_0_Rat_1_Ryukyu_1_Human_0_Macaca_1_Chimp_0_Mouse_1 Num_Shrew_3_Gorilla_0_Rat_7_Ryukyu_4_Human_0_Macaca_1_Chimp_0_Mouse_4   MGP_PahariEiJ_G0025265  ENSMUSG00000075159      MGP_PahariEiJ_G0025266  ENSMUSG00000075161      ENSMUSG00000075160      ENSRNOG00000050825      MGP_PahariEiJ_G0025264  ENSRNOG00000048383      MGP_CAROLIEiJ_G0023816  ENSRNOG00000050876      MGP_CAROLIEiJ_G0023814  MGP_CAROLIEiJ_G0023815  ENSRNOG00000045627      ENSMMUG00000016148      ENSMUSG00000075163
      ENSRNOG00000049276      ENSRNOG00000047728      MGP_CAROLIEiJ_G0023813  ENSRNOG00000048820
Loss_node:Human-Chimp   Exist_Shrew_1_Gorilla_1_Rat_1_Ryukyu_1_Human_0_Macaca_1_Chimp_1_Mouse_1 Num_Shrew_1_Gorilla_1_Rat_1_Ryukyu_1_Human_0_Macaca_1_Chimp_1_Mouse_1   ENSMUSG00000036924      ENSRNOG00000005103      ENSMMUG00000031138      ENSGGOG00000038343      MGP_CAROLIEiJ_G0024416  ENSPTRG00000050976      MGP_PahariEiJ_G0025859
Loss_node:Macaca-Gorilla-Human-Chimp    Exist_Shrew_1_Gorilla_0_Rat_1_Ryukyu_1_Human_0_Macaca_1_Chimp_0_Mouse_1 Num_Shrew_1_Gorilla_0_Rat_1_Ryukyu_1_Human_0_Macaca_1_Chimp_0_Mouse_1   ENSRNOG00000042494      ENSMMUG00000046571      MGP_CAROLIEiJ_G0028840  MGP_PahariEiJ_G0022598  ENSMUSG00000079346
Loss_node:Macaca-Gorilla-Human-Chimp    Exist_Shrew_1_Gorilla_0_Rat_1_Ryukyu_1_Human_0_Macaca_1_Chimp_0_Mouse_1 Num_Shrew_1_Gorilla_0_Rat_1_Ryukyu_1_Human_0_Macaca_1_Chimp_0_Mouse_1   ENSRNOG00000036897      ENSMUSG00000050645      MGP_PahariEiJ_G0025907  MGP_CAROLIEiJ_G0024464  ENSMMUG00000008796
```



##### Example for this step


```
tom@linux$ cd bin
tom@linux$ bash Identify_loss_candidates.sh \
--IDheader '{"Mouse":"ENSMUSG","Rat":"ENSRNOG","Ryukyu":"MGP_CAROLIEiJ_G","Shrew":"MGP_PahariEiJ_G","Human":"ENSG","Chimp":"ENSPTRG","Macaca":"ENSMMUG","Gorilla":"ENSGGOG"}' \
--OrthologousPath ../example/data/OrtholougousRelation/ \
--AnchorSpeciesSet '["Mouse","Rat","Ryukyu","Shrew"]' \
--TargetTree '[[["Chimp","Human"],"Gorilla"],"Macaca"]' \
--TargetSpecies Human \
--OutputPath ../example/result/
```



### 2.Identify Partial Loss Events  

This step is to confirm Partial Loss Events and tracing their loss relics. 


It requires the following input:


````
--LossCandidate
# Loss candidate file, the output of last step
--AnchorHeader
# Header of Ensembl Gene ID of the species used as anchor tracing loss relics
--TargetSpecies 
# Target species name. Please make sure it is identical to the target species name in the genome alignment data
--GenomeAlignment
# Path for genome alignment data. You can take `example/data/GenomeAlignment/Blocks_for_Loss_candidates_HUMAN` as an example.
In the Data Process part, we will show how to acquire this data
--RegionThreshold
# Threshold that determines whether merge or split regions when tracing loss relics
--OutputPath
# Path for output results
  ````



The output of this step includes `Partial_Loss_Events` and `Orthologous_group_candidate_for_Complete_Loss`. `Partial_Loss_Events` contains Partial Loss Events, each line of which represents a Partial Loss Event. And it is in table format (delimited by tab): `#RelicChr RelicStart RelicEnd AnchorGene`.  


Here, we show an exmaple in `example/result/Partial_Loss_Events`:


```
20      50081127        50113258        ENSMUSG00000078923
3       130244494       130264171       ENSMUSG00000032572
18      35290366        35306215        ENSMUSG00000063281
12      6867383 6870974 ENSMUSG00000023456
2       55284026        55287618        ENSMUSG00000032673
1       225119276       225402030       ENSMUSG00000047369
1       11654670        11662291        ENSMUSG00000029001
11      57741398        57743051        ENSMUSG00000076437
2       200871146       200889344       ENSMUSG00000026035
3       101649455       101651246       ENSMUSG00000071533
```



`Orthologous_group_candidate_for_Complete_Loss` contains the candidates for Complete Loss Events.


##### Example for this step


```
tom@linux$ bash Identify_Partial_Loss.sh \
--LossCandidate ../example/result/Loss_candidates_of_orthologous_group \
--AnchorHeader ENSMUSG \
--TargetSpecies homo_sapiens \
--GenomeAlignment ../example/data/GenomeAlignment/Blocks_for_Loss_candidates_HUMAN \
--OutputPath ../example/result/ \
--RegionThreshold 500000
```



### 3.Identify Complete Loss Events


This step is to confirm Complete Loss Events and locate their synteny regions.


It requires the following input:


````
--AnchorHeader
# Header of Ensembl Gene ID of the species used as anchor
--TargetSpecies
# Target species name. Please make sure it is identical to the target species name in the genome alignment data.
--GenomeAlignment
# Path for nearby genome blocks data. You can take `example/data/GenomeAlignment/Blocks_for_Complete_Loss_HUMAN` as an example.
In the Data Process part, we will show how to acquire this data
--NearestBlocksAlignment
# Path for closest genome blocks data. You can take `example/data/GenomeAlignment/Blocks_for_tracing_Complete_Loss_region_HUMAN` as an example.
In the Data Process part, we will show how to acquire this data
--OutputPath
# Path for output results
````


The output of this step includes `Complete_Loss_Events` and `Complete_Loss_synteny_region`. `Complete_Loss_Events` contains the anchor gene id of each Complete Loss Event. `Complete_Loss_synteny_region` contains their synteny region and it is in table format (delimited by tab): `#AnchorGene  SyntenyChr SyntenyStart SyntenyEnd`


Here, we show an exmaple in `example/result/Complete_Loss_synteny_region`:


```
ENSMUSG00000072647      12      111842236       112160327
ENSMUSG00000110012      11      4690793 5581774
ENSMUSG00000111273      12      55185714        55790565
ENSMUSG00000023577      3       51721810        51935219
ENSMUSG00000061295      11      48110031        49952593
ENSMUSG00000058981      1       159218919       159478969
ENSMUSG00000062527      1       159218919       159478969
ENSMUSG00000063251      17      41008954        41275722
ENSMUSG00000032493      3       46744650        46847719
ENSMUSG00000044041      17      41491422        41552084
ENSMUSG00000022798      3       119093920       119176274
ENSMUSG00000045031      4       122710737       122827273
ENSMUSG00000021953      8       11226515        11558020
ENSMUSG00000069708      6       132503457       132734611
ENSMUSG00000069707      6       132503457       132734611
```



##### Example for this step


```
tom@linux$ bash Identify_Complete_Loss.sh \
--AnchorHeader ENSMUSG \
--TargetSpecies homo_sapiens \
--GenomeAlignment ../example/data/GenomeAlignment/Blocks_for_Complete_Loss_HUMAN \
--NearestBlocksAlignment ../example/data/GenomeAlignment/Blocks_for_tracing_Complete_Loss_region_HUMAN \
--OutputPath ../example/result/
```

### 4.Filter Assembly Gap

This step is to filter loss events overlapped with assembly gap. 


It requires the following input:


````
--PartialLoss
# Partial Loss Events, the output of step 2
--CompleteLoss
# Complete Loss Events with synteny regions, the output of step 3
--AssemblyGap
# Assembly Gap file, in bed format
--OutputPath
# Path for output results
  ````

The output of this step includes `Partial_Loss_Events_without_gap` and `Complete_Loss_Events_without_gap`. 

##### Example for this step


```
tom@linux$ bash Filter_assembly_gap.sh \
--PartialLoss ../example/result/Partial_Loss_Events \
--CompleteLoss ../example/result/Complete_Loss_synteny_region \
--AssemblyGap ../example/data/Human_assembly_gap.bed \
--OutputPath ../example/result/
```


## Data Process

In this part, we will show how to acquire the genome alignment data required in the pipeline. Please note that this part relies on the **[Ensembl Perl API](https://www.ensembl.org/info/docs/api/index.html)**. Make sure that it has been installed and can be used properly.


**Note: Since the genome alignment dataset is large, it would be SLOW to acquire these data through Ensembl server. We strongly recommend you to [install the Ensembl database](http://mart.ensembl.org/info/docs/webcode/mirror/install/index.html) and acquire these data locally.**



### Acquire genome alignment data for loss candidates



This step is to acquire the geneome alignment data `Blocks_for_Loss_candidates` required in step **2.Identify Partial Loss Events**. 


It requires the following input:



```
--Host
# Host of the ensembl database. 'ensembldb.ensembl.org' to access database through Ensembl server
--User
# User of the ensembl database. 'anonymous' to access database through Ensembl server
--AnchorSpecies 
# Anchor species name, make sure this name can be recognized by Ensembl Perl API
--MethodLinkType 
# Method name for mulitple genome alignment dataset, such as "EPO", "PECAN" or "EPO_EXTENDED". You can visit Ensembl to check the available alignment dataset
--SpeciesSetName
# Species set name for mulitple genome alignment dataset, such as "mammals", "primates" or "amniotes". You can visit Ensembl to check the available alignment dataset
--AnchorIDHeader
# Header of Ensembl Gene ID of the species used as anchor
--LossCandidate 
# Loss candidates dataset, the output of the first step 'Identify gene loss candidates'
--OrthologousPath 
# Path that contains orthologous relation files
--OutputPath 
# Path for output results
```


##### Example for this step


```
tom@linux$ cd bin
tom@linux$ bash Get_alignmentblocks_for_loss_candidates.sh \
--Host 'ensembldb.ensembl.org' \
--User 'anonymous' \
--AnchorSpecies Mouse \
--MethodLinkType EPO \
--SpeciesSetName mammals \
--AnchorIDHeader ENSMUSG \
--LossCandidate ../example/result/Loss_candidates_of_orthologous_group \
--OrthologousPath ../example/data/OrtholougousRelation/ \
--OutputPath YourDatapath/
```


### Acquire genome alignment data for Complete Loss


This step is to acquire the geneome alignment data `Blocks_for_tracing_Complete_Loss_region` and `Blocks_for_Complete_Loss` required in step **3.Identify Complete Loss Events**. 


It requires the following input:


```
--Host 
# Host of the ensembl database. 'ensembldb.ensembl.org' to access database through Ensembl server
--User
# User of the ensembl database. 'anonymous' to access database through Ensembl server
--AnchorSpecies Mouse 
# Anchor species name, make sure this name can be recognized by Ensembl Perl API
--TargetSpecies homo_sapiens 
# Target species name. Please make sure it is identical to the target species name in the genome alignment data
--MethodLinkType
# Method name for mulitple genome alignment dataset, such as "EPO", "PECAN" or "EPO_EXTENDED". You can visit Ensembl to check the available alignment dataset
--SpeciesSetName
# Species set name for mulitple genome alignment dataset, such as "mammals", "primates" or "amniotes". You can visit Ensembl to check the available alignment dataset
--AnchorIDHeader
# Header of Ensembl Gene ID of the species used as anchor
--CompleteLossCandidate
# Complete Loss candidates dataset, the output of the second step 'Identify Partial Loss Events'
--OrthologousPath 
# Path that contains orthologous relation files
--OutputPath 
# Path for output results
--ExtendLength
# Length extended in the upstream and downstream of anchor gene for alignment blocks. Here, we recommend the value 
```


##### Example for this step


```
tom@linux$ bash Get_alignmentblocks_for_CompleteLoss.sh \
--Host 'ensembldb.ensembl.org' \
--User 'anonymous' \
--AnchorSpecies Mouse \
--TargetSpecies homo_sapiens \
--MethodLinkType EPO \
--SpeciesSetName mammals \
--AnchorIDHeader ENSMUSG \
--CompleteLossCandidate ../example/result/Orthologous_group_candidate_for_Complete_Loss \
--OrthologousPath ../example/data/OrtholougousRelation/ \
--OutputPath YourDatapath/ \
--ExtendLength 1000000
```




