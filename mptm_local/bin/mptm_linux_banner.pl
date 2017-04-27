#!/usr/bin/perl
# MPTM Lite Edition 1.0
# For Text Mining of PTMs
# Programmed by DongDong Sun
# Final revised on Sep 30, 2016
require '../lib/ie_phosphorylation.pl';
require '../lib/ie_methylation.pl';
require '../lib/ie_glycosylation.pl';
require '../lib/ie_hydroxylation.pl';
require '../lib/ie_acetylation.pl';
require '../lib/ie_amidation.pl';
require '../lib/ie_myristoylation.pl';
require '../lib/ie_sulfation.pl';
require '../lib/ie_anchor.pl';
require '../lib/ie_disulfide.pl';
require '../lib/ie_ubiquitination.pl';
use LWP::Simple;
mptm();
sub crosstalk {

	my @each_dep  = @_;
	my @crosstalk = ('NULL');

	for ( my $i = 0 ; $i < @each_dep ; $i++ ) {
		if ( $each_dep[$i] =~ /crosstalk/i ) {
			my $crosstalk_str = '';
			for ( my $j = 0 ; $j < @each_dep ; $j++ ) {
				if (   $each_dep[$j] =~ /.+\(.+?-\d+'?, phospho.*-\d+'?\)/i
					|| $each_dep[$j] =~ /.+\(phospho.*-\d+'?, .+?-\d+'?\)/i )
				{
					$crosstalk_str .= 'Phosphorylation,';
				}
				elsif ($each_dep[$j] =~ /.+\(.+?-\d+'?, methyl.*-\d+'?\)/i
					|| $each_dep[$j] =~ /.+\(methyl.*-\d+'?, .+?-\d+'?\)/i )
				{
					$crosstalk_str .= 'Methylation,';
				}
				elsif ( $each_dep[$j] =~
					/.+\(.+?-\d+'?, (?:glyco.*|O-GlcNAc.*)-\d+'?\)/i
					|| $each_dep[$j] =~
					/.+\((?:glyco.*|O-GlcNAc.*)-\d+'?, .+?-\d+'?\)/i )
				{
					$crosstalk_str .= 'Glycosylation,';
				}
				elsif ($each_dep[$j] =~ /.+\(.+?-\d+'?, acety.*-\d+'?\)/i
					|| $each_dep[$j] =~ /.+\(acety.*-\d+'?, .+?-\d+'?\)/i )
				{
					$crosstalk_str .= 'Acetylation,';
				}
				elsif ($each_dep[$j] =~ /.+\(.+?-\d+'?, amid.*-\d+'?\)/i
					|| $each_dep[$j] =~ /.+\(amid.*-\d+'?, .+?-\d+'?\)/i )
				{
					$crosstalk_str .= 'Amidation,';
				}
				elsif ($each_dep[$j] =~ /.+\(.+?-\d+'?, hydroxy.*-\d+'?\)/i
					|| $each_dep[$j] =~ /.+\(hydroxy.*-\d+'?, .+?-\d+'?\)/i )
				{
					$crosstalk_str .= 'Hydroxylation,';
				}
				elsif ($each_dep[$j] =~ /.+\(.+?-\d+'?, myrist.*-\d+'?\)/i
					|| $each_dep[$j] =~ /.+\(myrist.*-\d+'?, .+?-\d+'?\)/i )
				{
					$crosstalk_str .= 'Myristoylation,';
				}
				elsif ($each_dep[$j] =~ /.+\(.+?-\d+'?, sulfa.*-\d+'?\)/i
					|| $each_dep[$j] =~ /.+\(sulfa.*-\d+'?, .+?-\d+'?\)/i )
				{
					$crosstalk_str .= 'Sulfation,';
				}
				elsif ( $each_dep[$j] =~
					/.+\(.+?-\d+'?, (?:anchor.*|GPI.*)-\d+'?\)/i
					|| $each_dep[$j] =~
					/.+\((?:anchor.*|GPI.*)-\d+'?, .+?-\d+'?\)/i )
				{
					$crosstalk_str .= 'GPI-Anchor,';
				}
				elsif ($each_dep[$j] =~ /.+\(.+?-\d+'?, disulf.*-\d+'?\)/i
					|| $each_dep[$j] =~ /.+\(disulf.*-\d+'?, .+?-\d+'?\)/i )
				{
					$crosstalk_str .= 'Disulfide,';
				}
				elsif ( $each_dep[$j] =~
					/.+\(.+?-\d+'?, (?:ubiquit.*|Ub.*)-\d+'?\)/i
					|| $each_dep[$j] =~
					/.+\((?:ubiquit.*|Ub.*)-\d+'?, .+?-\d+'?\)/i )
				{
					$crosstalk_str .= 'Ubiquitination,';
				}
			}
			@crosstalk = push_finding( $crosstalk_str, @crosstalk );
		}
	}

	return @crosstalk;

}
sub split_pmid {
	my $string = shift;
	$string =~ s/^\s+|\s+$//g;    # trip leading and trailing whitespaces
	my @all_pmids;
	if ( $string =~ /^(\d+)$/ ) {    # only one pmid
		push @all_pmids, $1;
	}
	elsif ( $string =~ /,/ ) {       # split with comma
		@all_pmids = split ( /,/, $string);
		@all_pmids = grep { $_ = $1 if /(\S+)/ }
		  @all_pmids
		  ;    # retain the element in array that containing pmid with no spaces
	}
	else{
		@all_pmids = split (/\s+/, $string);    # split with space
	}
	return @all_pmids;
}



sub file_suffix {
	my $time = time;
	my $rand = int( rand(1000000) + 1000 );
	my $suffix = $time + $rand; # define a random number appending the file name
	return $suffix;
}

sub call_pubmed {
	my @all_pmids = @_;
	my $db        = 'pubmed';
	my $id_list;
	for ( my $i = 0 ; $i < $#all_pmids ; $i++ ) {
		$id_list .= $all_pmids[$i] . ',';
	}
	$id_list .= $all_pmids[$#all_pmids];

	my $base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';

	# call Efetch
	my $url =
	  $base . "efetch.fcgi?db=$db&id=$id_list&rettype=medline&retmode=text";
	my $data = LWP::Simple::get($url);

	# If network cannot work or no pmid
	if ( !$data || $data =~ /\bError occurred\b/ ) {
print "222";
		my $suffix = 0;
		return $suffix;
	}
	else {


		# save the data
		my $suffix = file_suffix();
		open DATA, '>', "../files/pubmed/pubmed_$suffix.txt"
		  or die "Can't open a new file to write the data: $!";
		flock( DATA, 2 ) or die;    # lock the file
		print DATA $data;           # write data
		flock( DATA, 8 ) or die;    # unlock the file
		close DATA;
		return $suffix;

	}
}

sub deal_pubmed {
	my $suffix = shift;
	@all_pmids = ();
	my $i = 0;
	open PUBMED, '<', "../files/pubmed/pubmed_$suffix.txt";
	while (<PUBMED>) {
		if (/PMID- (.+)/) {
			my $pmid = $1;
			chomp($pmid);
			$all_pmids[$i] = $pmid;
			$i++;
			open CONTENT, '>', "../files/init_file/${pmid}_${suffix}.txt";
		}
		if (/TI  - (.+)/) {
			chomp($1);
			print CONTENT $1;
			while (<PUBMED>) {
				chomp;
				s/^\s+/ /;    # Replace the start spaces to an space
				s/\s+$//;     # Trip the end spaces
				if (/^[A-Z]{2,}\s+?- .+/) {
					last;
				}
				else {
					print CONTENT;
				}
			}
		}
		if (/AB  - (.+)/) {
			chomp($1);
			print CONTENT " $1";
			while (<PUBMED>) {
				chomp;
				s/^\s+/ /;    # Replace the start spaces to an space
				s/\s+$//;     # Trip the end spaces
				if (/^[A-Z]{2,}\s+?- .+/) {
					last;
				}
				else {
					print CONTENT;
				}
			}
		}
	}
	return @all_pmids;
	close CONTENT;
	close PUBMED;

}


sub banner {
	my $file_suffix = shift;
print $file_suffix;
	my $input       = $file_suffix;
	my ( $fname, $output_sentence, $output_entity );
	if ( $file_suffix =~ /(.*?)\.txt/ ) {
		$fname           = $1;
		$output_sentence = $fname . '_sen.xml';
		$banner_sentence = $fname . '_sen.txt';
		$output_entity   = $fname . '_ner.xml';
	}

	chdir '../lingpipe/demos/generic/bin/'
	  or die "Can't chdir to lingpipe bin dir: $!"; # change to lingpipe bin dir
`sh cmd_sentence_en_bio.sh "-inFile=../../../../files/init_file/$input" "-outFile=../../../../files/lingpipe_sen/$output_sentence"`;
	chdir '../../../../bin/'
	  or die "Can't back to bin dir: $!";       # back to cgi-bin dir
	# process lingpipe generated sen file
	open SEN, '<', "../files/lingpipe_sen/$output_sentence"
	  or die "Can't open lingpipe generated sentence file to read: $!";
	  	open BAN, '>>', "../files/banner_sen/$banner_sentence"
	  or die "Can't open banner sentence file to write: $!";
	my ( @sentences, @sen_filter_ids, @sen_filter );

	while (<SEN>) {
		chomp;
		@sentences = /<s i="\d+">(.+?)<\/s>/g;    # capture xml label <s>...</s>
		@sentences = grep $_ !~ /^\d+?\.|^[A-Z]+?\./, @sentences
		  ;    # replace the sentence only containing digits and upper character

		for ( my $sen_id = 0 ; $sen_id < @sentences ; $sen_id++ ) {

			# find sentence triggers in initial split sentence
			if (

				$sentences[$sen_id] =~
/phospho|methyl|glyco|O-GlcNAc|acety|amid|hydroxy|myrist|sulfa|anchor|GPI|glycosylphosphatidylinositol|phosphatidylinositol|disulf|cyste?ine|ubiquit|E1|E2|E3|E4|E6|crosstalk/i

			  )
			{
				push @sen_filter_ids, $sen_id

				  ; # save sen_filter_ids into @sen_filter_ids array, start from 0
				push @sen_filter,
				  $sentences[$sen_id];  # save sen_filter into @sen_filter array
				  print BAN $sen_id." ".$sentences[$sen_id]."\n";
			}

		}
	}
	close SEN;
	close BAN;
	#call banner tool
	chdir '../BANNER/'
	  or die "Can't chdir to lingpipe bin dir: $!"; # change to lingpipe bin dir
`sh test.sh "../files/banner_sen/$banner_sentence" "bc2geneMention/train/GENE.eval" "bc2geneMention/train/ALTGENE.eval" "result/model.in" "../files/banner_ner/"`;
	chdir '../bin/'
	  or die "Can't back to bin dir: $!";       # back to cgi-bin dir
	rename "../files/banner_ner/mention.txt","../files/banner_ner/".$output_entity;
	# process lingpipe generated ner file
	open NER, '<', "../files/banner_ner/$output_entity"
	  or die "Can't open banner generated ner file to read: $!";
	my (@genes);	# write the mapped sentence to sen_map file if it has sentence triggers
	
	while (<NER>) {
		chomp;

		my @arr = split('\|',$_);
		push @genes, ($arr[2]);
	}
	close NER;
			push @genes, (
			'dual specificity tyrosine-phosphorylated and regulated kinase 1A',
			'VASP',
			'gammaH2AX histone',
			'alpha-CaMKII',
			'matrix protein',
			'calcineurin',
			'cAMP-dependent protein kinase',
			'opsin',
			'Ca2+ release channel',
			'enzyme I',
			'Mitogen-activated protein (MAP) kinase',
			'fructose-1,6-bisphosphatase',
			'fructose-2,6-bisphosphatase',
			'type II (beta) protein kinase C',
			'lipoprotein-associated coagulation inhibitor',
			'Acanthamoeba myosins I',
			'fructose-1,6-bisphosphatase',
			'PFK-2/FBPase-2',
			'Brain proline-directed protein kinase',
			'p34cdc2:cyclin B',
			'polyoma middle T/pp60c-src complex',
			"adenosine cyclic 3',5'-phosphate dependent protein kinase",
			'calcium-dependent protein kinases',
'Ca2+/calmodulin- (CaM) dependent phosphoprotein phosphatase calcineurin',
			'hippocalcin',
			'Gln252',
			'allophycocyanins',
			'equilibrative nucleoside transporter-2',
			'equilibrative nucleoside transporter-1',
			'hENT1',
			'hENT2',
			'HIF',
			'alpha-subunit',
			'myristoyl-CoA',
			'erythrocyte protein 4.2',
			'band 4.2',
			'pheromone-responsive G alpha protein',
			'CP29',
			'H4',
			'Bactericidal\/permeability-increasing protein',
			'POI',
			'yolk protein 2',
			'Chromogranin A',
			'Chromogranin B',
			'factor V',
			'C4',
			'fourth component of human complement',
			'promastigote surface protease',
			'PSP',
			'Prespore-specific antigen',
			'anaphase-promoting complex',
			'Parkin',
			'conjugating human enzyme 8',
			'Topors',
			'H3K4',
			'H3',
		);
	# post-process all the gene names
	my ( %gene_name, @gene_names, %map_rule );
	foreach my $name (@genes) {
		my $flag = 1;

   # don't map the digital number names or amino acid names or other wrong names
		if ( $name !~
/^\d+$|\bAla\b|\bArg\b|\bAsn\b|\bAsp\b|\bCys\b|\bGln\b|\bGlu\b|\bGly\b|\bHis\b|\bIle\b|\bLeu\b|\bLys\b|\bMet\b|\bPhe\b|\bSer|D\b|\bThr\b|\bTrp\b|\bTyr\b|\bVal\b|\bPro\b|\bAla\d+\b|\bArg\d+\b|\bAsn\d+\b|\bAsp\d+\b|\bCys\d+\b|\bGln\d+\b|\bGlu\d+\b|\bGly\d+\b|\bHis\d+\b|\bIle\d+\b|\bLeu\d+\b|\bLys\d+\b|\bMet\d+\b|\bPhe\d+\b|\bSer\d+\b|\bThr\d+\b|\bTrp\d+\b|\bTyr\d+\b|\bVal\d+\b|\bPro\d+\b|\b[T|t]\d+\b|\b[Y|y]\d+\b|\bAlaP\b|\bArgP\b|\bAsnP\b|\bAspP\b|\bCysP\b|\bGlnP\b|\bGluP\b|\bGlyP\b|\bHisP\b|\bIleP\b|\bLeuP\b|\bLysP\b|\bMetP\b|\bPheP\b|\bSerP\b|\bThrP\b|\bTrpP\b|\bTyrP\b|\bValP\b|\bProP\b/
			&& $name !~
/(\bAlanine\b|\bArginine\b|\bAsparagine\b|\bAspartic\b|\bCysteine\b|\bGlutamine\b|\bGlutamic\b|\bGlycine\b|\bHistidine\b|\bIsoleucine\b|\bLeucine\b|\bLysine\b|\bMethionine\b|\bPhenylalanine\b|\bProline\b|\bSerine\b|\bThreonine\b|\bTryptophan\b|\bTyrosine\b|\bValine\b)(-\d+$| \d+$)/i
			&& $name !~
/terminal|terminus|sites?|residues?|positions?|^insulin\S*$|^trypsin\w*$|^\S*chymotryp\w*$|\S*A[T|D]P\w*$|^proteins?$|^(?:protein|insulin-sensitive|endogenous|nuclear|exogenous|membranal|cytoplasmic|major|minor) kinases?$|(?:serine|threonine|tyrosine) protein kinases?|phospho-forms?|.*?virus$|.*?domain\S*$|.*?subunit\S*$|.*?region\S*$|.*?isoform\S*$|^a isoenzyme$|^N delta 1$|alphaalpha|^CaM?$|genes?$|^VTA$/i
			&& $name !~
/.*?glycoprotein.*?|^glycosyl$|.*?hydroxylase.*?|^Myristoylated NCS-1$|^GF-amide$|^protein acetyltransferase$|.*?O-GlcNAc.*?|^N\d+(\w+)?$|^N- and O$|^.*O-linked N-acetylglucosamine$|^methylasparagine in allophycocyanin$|^Acetyladenylate( or)?$|^(AcAMP)$|^extracellular glycosyl$|.*GPI-anchored.*|^GPI$|^Acetylated$|^C\d+$|.*chain.*|.*sulfation.*|^N:-glycosidase$|^phosphatidylinositol-anchored membrane protein$|.*GPI.*|^protein-protein$|\bNmt\b|\bCa\(2+\b|\btransducin\b/i
			&& $name !~
/\bS-adenosyl-l-\[methyl-\(3\b|\bPCR\b|\bMSP\b|\bE3 ligase\b|^ubiquitin-conjugating enzyme$|\bE2\b|\bE3 ubiquitin ligase\b|\bubiquitin\b|\bligase\b|\bpolyubiquitinated\b|\bubiquitin\b|\bE3 ligases\b|\bUb\b|\bRING finger protein\b|\bRING-H2 finger protein\b|\bubiquitin-protein  ligase\b|\bhuman ubiquitin-conjugating enzymes\b|\bE3\b/i
		  )
		{
			if (   $name =~ /.*?\(.*?\).*?/
				|| $name =~ /.*?\[.*?\].*?/
				|| $name =~ /.*?\{.*?\}.*?/ )
			{ # if had matched pair of parentheses, write it to the hash arrays directly
				if ( length($name) > 1 ) {
					$gene_name{$name} = length($name);
					$flag = 0;
				}
			}
			elsif ( $name =~ /\(|\)|\[|\]|\{|\}/ ) {    # if found parentheses
				my @split_name = split /\(|\)|\[|\]|\{|\}/,
				  $name;    # split name by parentheses
				for ( my $i = 0 ; $i < @split_name ; $i++ ) {
					$split_name[$i] =~ s/(^\W+|\W+$)//g
					  ;     # trip all the leading and trailing \W character
					if ( $split_name[$i] =~ /[A-Z]/ )
					{ # if found capital letter, write it to the hash arrays directly
						if ( length( $split_name[$i] ) > 1 ) {
							$gene_name{ $split_name[$i] } =
							  length( $split_name[$i] );
							$flag = 0;
						}
					}
				}
			}
			if (   $name =~ /^(.+?) to .+?$/
				|| $name =~ /^(.+?) on (?:serine|threonine|tyrosine) \d+?$/i
				|| $name =~ /^(.+?) is$/ )
			{
				my $name_new = $1;
				if ( length($name_new) > 1 ) {
					$gene_name{$name_new} = length($name_new);
					$flag = 0;
				}
			}
			if ( $name =~ /^(?:minor|major|\d+-(?:kDa|kilodalton)) (.+?)$/i ) {
				my $name_new_1 = $1;
				if ( length($name_new_1) > 1 ) {
					if ( $name_new_1 !~ /^kinases?$|^proteins?$/i ) {
						$gene_name{$name_new_1} = length($name_new_1);
						$flag = 0;
					}
					else {
						$flag = 0;
					}
				}
			}
			if (   $name !~ /^[P|p]rotein kinase [A-Z]/
				&& $name =~ /^protein kinase (.+)$/i )
			{
				my $name_new_1 = $1;
				if ( length($name_new_1) > 1 ) {
					$gene_name{$name_new_1} = length($name_new_1);
				}
				$flag = 0;
			}
			if ( $name =~ /^(.+?)[-| ]phosphorylated (.+?)$/i ) {
				if ( $2 =~ /and/ ) {
					$flag = 1;
				}
				else {
					my $name_new_1 = $1;
					if ( length($name_new_1) > 1 ) {
						$gene_name{$name_new_1} = length($name_new_1);
						$flag = 0;
					}
					my $name_new_2 = $2;
					if ( length($name_new_2) > 1 ) {
						$gene_name{$name_new_2} = length($name_new_2);
						$flag = 0;
					}
				}
			}

			if ( $flag && length($name) > 1 ) {    # normal names
				$gene_name{$name} = length($name);
			}
		}
	}

	sub sort_by_len {
		if    ( length($a) < length($b) ) { 1 }
		elsif ( length($a) > length($b) ) { -1 }
		else                              { 0 }
	}
	@gene_names = sort sort_by_len keys %gene_name;    # sort by string length
	@gene_names = grep { $_ !~ /^[A-Z]-(?:[A-Z]-)+?[A-Z]$/ } @gene_names;

	#    print $_ . "<br>\n" foreach @gene_names;
	# map gene names
	my ( @sen_have_trigger_ids, @sen_have_triggers );
	my $sen_count = -1;                                # init sentence number
	foreach my $each_sen (@sen_filter) {
		$sen_count++;    # count the sentence number
		my $c = 0;       # PROi

		my $d = @gene_names;
		foreach my $each_gene (@gene_names) {
			$c++;
			my $original_name           = $each_gene;
			my $original_name_quotemeta = quotemeta($each_gene);
			my $replace_name            = 'PRO' . $c;

			# replace original name by PROi
			while ( $each_sen =~ /(\S+\/$original_name_quotemeta)\b/ig ) {
				my $name_new = $1;    # new name
				$d += 1;
				my $replace_name_new = 'PRO' . $d;    # new replaced name
				     # replace original name to replaced name
				if ( $name_new =~ s/\(|\)//g ) {
					$name_new = quotemeta($name_new);
					$each_sen =~ s/$name_new/$replace_name_new/i;
					$name_new =~ s/\\//g;    # delete all \ character
					$map_rule{$replace_name_new} = $name_new;
				}
				else {
					$name_new = quotemeta($name_new);
					$each_sen =~ s/$name_new/$replace_name_new/i;
					$name_new =~ s/\\//g;    # delete all \ character
					$map_rule{$replace_name_new} = $name_new;
				}
			}
			while ( $each_sen =~ /\b($original_name_quotemeta\/\S+)/ig ) {
				my $name_new = $1;           # new name
				$d += 1;
				my $replace_name_new = 'PRO' . $d;    # new replaced name
				     # replace original name to replaced name
				if ( $name_new =~ s/\(|\)//g ) {
					$name_new = quotemeta($name_new);
					$each_sen =~ s/$name_new/$replace_name_new/i;
					$name_new =~ s/\\//g;    # delete all \ character
					$map_rule{$replace_name_new} = $name_new;
				}
				else {
					$name_new = quotemeta($name_new);
					$each_sen =~ s/$name_new/$replace_name_new/i;
					$name_new =~ s/\\//g;    # delete all \ character
					$map_rule{$replace_name_new} = $name_new;
				}
			}
			if (
				$each_sen =~ s/\b($original_name_quotemeta)\b/$replace_name/ig )
			{
				$1 =~ s/\\//g;
				$map_rule{$replace_name} = $1;
			}
		}
		# save the results to the array
		push @sen_have_trigger_ids,
		  $sen_filter_ids[$sen_count]; # save sen_have_trigger_ids, start from 0
		push @sen_have_triggers, $each_sen;    # save sen_have_triggers
		                                       #	}

	}
	# write the mapped sentence to sen_map file if it has sentence triggers
	if (@sen_have_triggers) {
		open MAP, '>', "../files/sen_map/$fname.map"
		  or die "Can't open a new file to write mapped file: $!";
		print MAP $_ . "\n" foreach @sen_have_triggers;
		close MAP;
	}

	return ( $fname, \@sentences, \@sen_have_trigger_ids, \@sen_have_triggers,
		\%map_rule );
}
sub lingpipe {
	my $file_suffix = shift;
print $file_suffix;
	my $input       = $file_suffix;
	my ( $fname, $output_sentence, $output_entity );
	if ( $file_suffix =~ /(.*?)\.txt/ ) {
		$fname           = $1;
		$output_sentence = $fname . '_sen.xml';
		$output_entity   = $fname . '_ner.xml';
	}

	chdir '../lingpipe/demos/generic/bin/'
	  or die "Can't chdir to lingpipe bin dir: $!"; # change to lingpipe bin dir
`sh cmd_sentence_en_bio.sh "-inFile=../../../../files/init_file/$input" "-outFile=../../../../files/lingpipe_sen/$output_sentence"`;
`sh cmd_ne_en_bio_genetag.sh "-inFile=../../../../files/init_file/$input" "-outFile=../../../../files/lingpipe_ner/$output_entity"`;
	chdir '../../../../bin/'
	  or die "Can't back to bin dir: $!";       # back to cgi-bin dir
	# process lingpipe generated sen file
	open SEN, '<', "../files/lingpipe_sen/$output_sentence"
	  or die "Can't open lingpipe generated sentence file to read: $!";
	my ( @sentences, @sen_filter_ids, @sen_filter );

	while (<SEN>) {
		chomp;
		@sentences = /<s i="\d+">(.+?)<\/s>/g;    # capture xml label <s>...</s>
		@sentences = grep $_ !~ /^\d+?\.|^[A-Z]+?\./, @sentences
		  ;    # replace the sentence only containing digits and upper character

		for ( my $sen_id = 0 ; $sen_id < @sentences ; $sen_id++ ) {

			# find sentence triggers in initial split sentence
			if (

				$sentences[$sen_id] =~
/phospho|methyl|glyco|O-GlcNAc|acety|amid|hydroxy|myrist|sulfa|anchor|GPI|glycosylphosphatidylinositol|phosphatidylinositol|disulf|cyste?ine|ubiquit|E1|E2|E3|E4|E6|crosstalk/i

			  )
			{
				push @sen_filter_ids, $sen_id

				  ; # save sen_filter_ids into @sen_filter_ids array, start from 0
				push @sen_filter,
				  $sentences[$sen_id];  # save sen_filter into @sen_filter array
			}

		}
	}
	close SEN;

	# process lingpipe generated ner file
	open NER, '<', "../files/lingpipe_ner/$output_entity"
	  or die "Can't open lingpipe generated ner file to read: $!";
	my (@genes);
	while (<NER>) {
		chomp;
		@genes = /<ENAMEX TYPE="GENE">(.+?)<\/ENAMEX>/g
		  ;   # capture xml label <ENAMEX>...</ENAMEX>
		      # add gene names that lingpipe cannot recognize or wrongly labeled
		push @genes, (
			'dual specificity tyrosine-phosphorylated and regulated kinase 1A',
			'VASP',
			'gammaH2AX histone',
			'alpha-CaMKII',
			'matrix protein',
			'calcineurin',
			'cAMP-dependent protein kinase',
			'opsin',
			'Ca2+ release channel',
			'enzyme I',
			'Mitogen-activated protein (MAP) kinase',
			'fructose-1,6-bisphosphatase',
			'fructose-2,6-bisphosphatase',
			'type II (beta) protein kinase C',
			'lipoprotein-associated coagulation inhibitor',
			'Acanthamoeba myosins I',
			'fructose-1,6-bisphosphatase',
			'PFK-2/FBPase-2',
			'Brain proline-directed protein kinase',
			'p34cdc2:cyclin B',
			'polyoma middle T/pp60c-src complex',
			"adenosine cyclic 3',5'-phosphate dependent protein kinase",
			'calcium-dependent protein kinases',
'Ca2+/calmodulin- (CaM) dependent phosphoprotein phosphatase calcineurin',
			'hippocalcin',
			'Gln252',
			'allophycocyanins',
			'equilibrative nucleoside transporter-2',
			'equilibrative nucleoside transporter-1',
			'hENT1',
			'hENT2',
			'HIF',
			'alpha-subunit',
			'myristoyl-CoA',
			'erythrocyte protein 4.2',
			'band 4.2',
			'pheromone-responsive G alpha protein',
			'CP29',
			'H4',
			'Bactericidal\/permeability-increasing protein',
			'POI',
			'yolk protein 2',
			'Chromogranin A',
			'Chromogranin B',
			'factor V',
			'C4',
			'fourth component of human complement',
			'promastigote surface protease',
			'PSP',
			'Prespore-specific antigen',
			'anaphase-promoting complex',
			'Parkin',
			'conjugating human enzyme 8',
			'Topors',
			'H3K4',
			'H3',
		);
	}
	close NER;

	# post-process all the gene names
	my ( %gene_name, @gene_names, %map_rule );
	foreach my $name (@genes) {
		my $flag = 1;

   # don't map the digital number names or amino acid names or other wrong names
		if ( $name !~
/^\d+$|\bAla\b|\bArg\b|\bAsn\b|\bAsp\b|\bCys\b|\bGln\b|\bGlu\b|\bGly\b|\bHis\b|\bIle\b|\bLeu\b|\bLys\b|\bMet\b|\bPhe\b|\bSer|D\b|\bThr\b|\bTrp\b|\bTyr\b|\bVal\b|\bPro\b|\bAla\d+\b|\bArg\d+\b|\bAsn\d+\b|\bAsp\d+\b|\bCys\d+\b|\bGln\d+\b|\bGlu\d+\b|\bGly\d+\b|\bHis\d+\b|\bIle\d+\b|\bLeu\d+\b|\bLys\d+\b|\bMet\d+\b|\bPhe\d+\b|\bSer\d+\b|\bThr\d+\b|\bTrp\d+\b|\bTyr\d+\b|\bVal\d+\b|\bPro\d+\b|\b[T|t]\d+\b|\b[Y|y]\d+\b|\bAlaP\b|\bArgP\b|\bAsnP\b|\bAspP\b|\bCysP\b|\bGlnP\b|\bGluP\b|\bGlyP\b|\bHisP\b|\bIleP\b|\bLeuP\b|\bLysP\b|\bMetP\b|\bPheP\b|\bSerP\b|\bThrP\b|\bTrpP\b|\bTyrP\b|\bValP\b|\bProP\b/
			&& $name !~
/(\bAlanine\b|\bArginine\b|\bAsparagine\b|\bAspartic\b|\bCysteine\b|\bGlutamine\b|\bGlutamic\b|\bGlycine\b|\bHistidine\b|\bIsoleucine\b|\bLeucine\b|\bLysine\b|\bMethionine\b|\bPhenylalanine\b|\bProline\b|\bSerine\b|\bThreonine\b|\bTryptophan\b|\bTyrosine\b|\bValine\b)(-\d+$| \d+$)/i
			&& $name !~
/terminal|terminus|sites?|residues?|positions?|^insulin\S*$|^trypsin\w*$|^\S*chymotryp\w*$|\S*A[T|D]P\w*$|^proteins?$|^(?:protein|insulin-sensitive|endogenous|nuclear|exogenous|membranal|cytoplasmic|major|minor) kinases?$|(?:serine|threonine|tyrosine) protein kinases?|phospho-forms?|.*?virus$|.*?domain\S*$|.*?subunit\S*$|.*?region\S*$|.*?isoform\S*$|^a isoenzyme$|^N delta 1$|alphaalpha|^CaM?$|genes?$|^VTA$/i
			&& $name !~
/.*?glycoprotein.*?|^glycosyl$|.*?hydroxylase.*?|^Myristoylated NCS-1$|^GF-amide$|^protein acetyltransferase$|.*?O-GlcNAc.*?|^N\d+(\w+)?$|^N- and O$|^.*O-linked N-acetylglucosamine$|^methylasparagine in allophycocyanin$|^Acetyladenylate( or)?$|^(AcAMP)$|^extracellular glycosyl$|.*GPI-anchored.*|^GPI$|^Acetylated$|^C\d+$|.*chain.*|.*sulfation.*|^N:-glycosidase$|^phosphatidylinositol-anchored membrane protein$|.*GPI.*|^protein-protein$|\bNmt\b|\bCa\(2+\b|\btransducin\b/i
			&& $name !~
/\bS-adenosyl-l-\[methyl-\(3\b|\bPCR\b|\bMSP\b|\bE3 ligase\b|^ubiquitin-conjugating enzyme$|\bE2\b|\bE3 ubiquitin ligase\b|\bubiquitin\b|\bligase\b|\bpolyubiquitinated\b|\bubiquitin\b|\bE3 ligases\b|\bUb\b|\bRING finger protein\b|\bRING-H2 finger protein\b|\bubiquitin-protein  ligase\b|\bhuman ubiquitin-conjugating enzymes\b|\bE3\b/i
		  )
		{
			if (   $name =~ /.*?\(.*?\).*?/
				|| $name =~ /.*?\[.*?\].*?/
				|| $name =~ /.*?\{.*?\}.*?/ )
			{ # if had matched pair of parentheses, write it to the hash arrays directly
				if ( length($name) > 1 ) {
					$gene_name{$name} = length($name);
					$flag = 0;
				}
			}
			elsif ( $name =~ /\(|\)|\[|\]|\{|\}/ ) {    # if found parentheses
				my @split_name = split /\(|\)|\[|\]|\{|\}/,
				  $name;    # split name by parentheses
				for ( my $i = 0 ; $i < @split_name ; $i++ ) {
					$split_name[$i] =~ s/(^\W+|\W+$)//g
					  ;     # trip all the leading and trailing \W character
					if ( $split_name[$i] =~ /[A-Z]/ )
					{ # if found capital letter, write it to the hash arrays directly
						if ( length( $split_name[$i] ) > 1 ) {
							$gene_name{ $split_name[$i] } =
							  length( $split_name[$i] );
							$flag = 0;
						}
					}
				}
			}
			if (   $name =~ /^(.+?) to .+?$/
				|| $name =~ /^(.+?) on (?:serine|threonine|tyrosine) \d+?$/i
				|| $name =~ /^(.+?) is$/ )
			{
				my $name_new = $1;
				if ( length($name_new) > 1 ) {
					$gene_name{$name_new} = length($name_new);
					$flag = 0;
				}
			}
			if ( $name =~ /^(?:minor|major|\d+-(?:kDa|kilodalton)) (.+?)$/i ) {
				my $name_new_1 = $1;
				if ( length($name_new_1) > 1 ) {
					if ( $name_new_1 !~ /^kinases?$|^proteins?$/i ) {
						$gene_name{$name_new_1} = length($name_new_1);
						$flag = 0;
					}
					else {
						$flag = 0;
					}
				}
			}
			if (   $name !~ /^[P|p]rotein kinase [A-Z]/
				&& $name =~ /^protein kinase (.+)$/i )
			{
				my $name_new_1 = $1;
				if ( length($name_new_1) > 1 ) {
					$gene_name{$name_new_1} = length($name_new_1);
				}
				$flag = 0;
			}
			if ( $name =~ /^(.+?)[-| ]phosphorylated (.+?)$/i ) {
				if ( $2 =~ /and/ ) {
					$flag = 1;
				}
				else {
					my $name_new_1 = $1;
					if ( length($name_new_1) > 1 ) {
						$gene_name{$name_new_1} = length($name_new_1);
						$flag = 0;
					}
					my $name_new_2 = $2;
					if ( length($name_new_2) > 1 ) {
						$gene_name{$name_new_2} = length($name_new_2);
						$flag = 0;
					}
				}
			}

			if ( $flag && length($name) > 1 ) {    # normal names
				$gene_name{$name} = length($name);
			}
		}
	}

	sub sort_by_len {
		if    ( length($a) < length($b) ) { 1 }
		elsif ( length($a) > length($b) ) { -1 }
		else                              { 0 }
	}
	@gene_names = sort sort_by_len keys %gene_name;    # sort by string length
	@gene_names = grep { $_ !~ /^[A-Z]-(?:[A-Z]-)+?[A-Z]$/ } @gene_names;

	#    print $_ . "<br>\n" foreach @gene_names;

	# map gene names
	my ( @sen_have_trigger_ids, @sen_have_triggers );
	my $sen_count = -1;                                # init sentence number
	foreach my $each_sen (@sen_filter) {
		$sen_count++;    # count the sentence number
		my $c = 0;       # PROi

		my $d = @gene_names;
		foreach my $each_gene (@gene_names) {
			$c++;
			my $original_name           = $each_gene;
			my $original_name_quotemeta = quotemeta($each_gene);
			my $replace_name            = 'PRO' . $c;

			# replace original name by PROi
			while ( $each_sen =~ /(\S+\/$original_name_quotemeta)\b/ig ) {
				my $name_new = $1;    # new name
				$d += 1;
				my $replace_name_new = 'PRO' . $d;    # new replaced name
				     # replace original name to replaced name
				if ( $name_new =~ s/\(|\)//g ) {
					$name_new = quotemeta($name_new);
					$each_sen =~ s/$name_new/$replace_name_new/i;
					$name_new =~ s/\\//g;    # delete all \ character
					$map_rule{$replace_name_new} = $name_new;
				}
				else {
					$name_new = quotemeta($name_new);
					$each_sen =~ s/$name_new/$replace_name_new/i;
					$name_new =~ s/\\//g;    # delete all \ character
					$map_rule{$replace_name_new} = $name_new;
				}
			}
			while ( $each_sen =~ /\b($original_name_quotemeta\/\S+)/ig ) {
				my $name_new = $1;           # new name
				$d += 1;
				my $replace_name_new = 'PRO' . $d;    # new replaced name
				     # replace original name to replaced name
				if ( $name_new =~ s/\(|\)//g ) {
					$name_new = quotemeta($name_new);
					$each_sen =~ s/$name_new/$replace_name_new/i;
					$name_new =~ s/\\//g;    # delete all \ character
					$map_rule{$replace_name_new} = $name_new;
				}
				else {
					$name_new = quotemeta($name_new);
					$each_sen =~ s/$name_new/$replace_name_new/i;
					$name_new =~ s/\\//g;    # delete all \ character
					$map_rule{$replace_name_new} = $name_new;
				}
			}
			if (
				$each_sen =~ s/\b($original_name_quotemeta)\b/$replace_name/ig )
			{
				$1 =~ s/\\//g;
				$map_rule{$replace_name} = $1;
			}
		}

		# save the results to the array
		push @sen_have_trigger_ids,
		  $sen_filter_ids[$sen_count]; # save sen_have_trigger_ids, start from 0
		push @sen_have_triggers, $each_sen;    # save sen_have_triggers
		                                       #	}
	}

	# write the mapped sentence to sen_map file if it has sentence triggers
	if (@sen_have_triggers) {
		open MAP, '>', "../files/sen_map/$fname.map"
		  or die "Can't open a new file to write mapped file: $!";
		print MAP $_ . "\n" foreach @sen_have_triggers;
		close MAP;
	}

	return ( $fname, \@sentences, \@sen_have_trigger_ids, \@sen_have_triggers,
		\%map_rule );

}

sub shift_input {

	my $search_query = shift;
	$search_query =~ s/\s+/+/g;
	return $search_query;
}
sub standford_parser {
	my $fname  = shift;
	my $input  = "../files/sen_map/$fname.map";
	my $output = "../files/sen_dep/$fname.dep";
	chdir "../stanford_parser/"
	  or die "Can't chdir to stanford_parser dir: $!";
	`sh lexparser.sh $input > $output`;
	chdir "../bin/"
	  or die "Can't back to cgi-bin dir: $!";
}

sub push_finding {
	my ( $finding, @array ) = @_;
	pop @array if $array[0] eq "NULL";
	unless (@array) {
		push @array, $finding;    # push mapped name into array
	}
	else {
		my $dictionary;
		foreach my $each (@array) {
			$dictionary .= $each
			  ; # bulid a dictionary containing all existing elements in the array
		}
		my $finding_quotemeta = quotemeta($finding);
		unless ( $dictionary =~ /$finding_quotemeta/ ) {    # remove duplicates
			push @array, $finding;
		}
	}
	return @array;
}

sub substrate_appositive {
	my ( $each_dep_ref, $i, $substrate_ref, $finding ) = @_;
	my @each_dep  = @{$each_dep_ref};
	my @substrate = @{$substrate_ref};

	my $tmp;
	if ( $i > 2 ) {
		$tmp = $i - 3;
	}
	else {
		$tmp = 0;
	}
	for ( my $j = $tmp ; $j < @each_dep ; $j++ ) {
		my $finding_new;
		if (   $each_dep[$j] !~ /(?:prep_by)\($finding-\d+, PRO\d+-\d+\)/
			&& $each_dep[$j] =~ /.+?\($finding-\d+, (PRO\d+)-\d+\)/ )
		{
			$finding_new = $1;
			@substrate =
			  push_finding( $finding_new, @substrate );    # push new findings
		}
	}

	return @substrate;
}

sub kinase_appositive {
	my ( $each_dep_ref, $i, $kinase_ref, $finding ) = @_;
	my @each_dep = @{$each_dep_ref};
	my @kinase   = @{$kinase_ref};

	my $tmp;
	if ( $i > 2 ) {
		$tmp = $i - 3;
	}
	else {
		$tmp = 0;
	}
	for ( my $j = $tmp ; $j < @each_dep ; $j++ ) {
		my $finding_new;
		if (   $each_dep[$j] !~ /(?:prep_by)\($finding-\d+, PRO\d+-\d+\)/
			&& $each_dep[$j] =~ /.+?\($finding-\d+, (PRO\d+)-\d+\)/ )
		{
			$finding_new = $1;
			@kinase = push_finding( $finding_new, @kinase ); # push new findings
		}
	}
	return @kinase;
}

sub number_appositive {
	my ( $each_dep_ref, $i, $finding ) = @_;
	my @each_dep = @{$each_dep_ref};
	my @numbers;
	push @numbers, $finding;

	my $tmp;
	if ( $i > 2 ) {
		$tmp = $i - 3;
	}
	else {
		$tmp = 0;
	}
	for ( my $j = $tmp ; $j < @each_dep ; $j++ ) {
		if ( $each_dep[$j] =~ /.+?\($finding-\d+, (\d+)-\d+\)/ ) {
			my $number_new = $1;
			push @numbers, $number_new;    # push new number
		}
	}
	return @numbers;
}


sub ie_phospho {
	my ( $suffix, $fname, $each_pmid, $sentences_ref, $sen_have_trigger_ids_ref,
		$map_rule_ref, $flag_sid )
	  = @_;
	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "Phosphorylation";

	if ( -e "../files/sen_dep/$fname.dep" ) {

		open DEP, '<', "../files/sen_dep/$fname.dep"
		  or die "Can't open dep file: $!";

		# split into each sentence's dep
		my ( $sen_str, @substrate, @kinase, @site );
		my $i = -1;    # Set counter
		while (<DEP>) {
			if (/^\R/) {
				chomp;
				$i++;

				# split each_sen_dep into each_dep and start to parse
				my @each_dep = split /\R/, $sen_str;

				@substrate = substrate_pattern_phospho(@each_dep);
				@kinase    = kinase_pattern_phospho(@each_dep);
				@site      = site_pattern_phospho(@each_dep);
				@crosstalk = crosstalk(@each_dep);

				my @substrate_original = @substrate;
				my @kinase_original    = @kinase;
				my @site_original      = @site;

				unless ( $substrate[0] eq 'NULL'
					&& $kinase[0] eq 'NULL'
					&& $site[0]   eq 'NULL' )
				{

					# show all found elements in the table
					unless ( $substrate[0] eq 'NULL' ) {
						if ( @substrate > 1 ) {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @substrate;
						}
						else {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @substrate;
						}
					}
					foreach (@substrate) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $kinase[0] eq 'NULL' ) {
						if ( @kinase > 1 ) {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @kinase;
						}
						else {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @kinase;
						}
					}
					foreach (@kinase) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $site[0] eq 'NULL' ) {
						s/\(//;
						if ( @site > 1 ) {
							@site = map { $_ . ',' } @site;
						}
						else {
							@site = map { $_ } @site;
						}
					}
					foreach (@site) {    # replace \/ to /
						s#\\\/#\/#;
					}

					my $sen_map_id =
					  @{$sen_have_trigger_ids_ref}[$i] + 1;    # start from 0

					# write the results to a file
					if ($each_pmid) {
						print RESULT
"$each_pmid\t$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}
					else {
						print RESULT
"$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}

				}

				$sen_str = '';    # clear the string
			}

			$sen_str .= $_;
		}
		close DEP;
	}
}

sub ie_methylation {
	my ( $suffix, $fname, $each_pmid, $sentences_ref, $sen_have_trigger_ids_ref,
		$map_rule_ref, $flag_sid )
	  = @_;

	#remove mark
	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "Methylation";
	if ( -e "../files/sen_dep/$fname.dep" ) {

		open DEP, '<', "../files/sen_dep/$fname.dep"
		  or die "Can't open dep file: $!";

		# split into each sentence's dep
		my ( $sen_str, @substrate, @kinase, @site );
		my $flag = 0;     # Set flag
		my $i    = -1;    # Set counter
		while (<DEP>) {
			if (/^\R/) {
				chomp;
				$i++;

				# split each_sen_dep into each_dep and start to parse
				my @each_dep = split /\R/, $sen_str;

				@substrate = substrate_pattern_methylation(@each_dep);
				@kinase    = kinase_pattern_methylation(@each_dep);
				@site      = site_pattern_methylation(@each_dep);
				@crosstalk = crosstalk(@each_dep);

				my @substrate_original = @substrate;
				my @kinase_original    = @kinase;
				my @site_original      = @site;

				unless ( $substrate[0] eq 'NULL'
					&& $kinase[0] eq 'NULL'
					&& $site[0]   eq 'NULL' )
				{

					$flag++;    # increase flag if find one of three elements


					# show all found elements in the table
					unless ( $substrate[0] eq 'NULL' ) {
						if ( @substrate > 1 ) {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @substrate;
						}
						else {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @substrate;
						}
					}
					foreach (@substrate) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $kinase[0] eq 'NULL' ) {
						if ( @kinase > 1 ) {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @kinase;
						}
						else {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @kinase;
						}
					}
					foreach (@kinase) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $site[0] eq 'NULL' ) {
						if ( @site > 1 ) {
							@site = map { $_ . ',' } @site;
						}
						else {
							@site = map { $_ } @site;
						}
					}
					foreach (@site) {      # replace \/ to /
						s#\\\/#\/#;
					}

					my $sen_map_id =
					  @{$sen_have_trigger_ids_ref}[$i] + 1;    # start from 0

					# write the results to a file
					if ($each_pmid) {
						print RESULT
"$each_pmid\t$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";

					}
					else {
						print RESULT
"$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}

				}

				$sen_str = '';    # clear the string
			}

			$sen_str .= $_;
		}
		close DEP;
	}
}

sub ie_glycosylation {
	my ( $suffix, $fname, $each_pmid, $sentences_ref, $sen_have_trigger_ids_ref,
		$map_rule_ref, $flag_sid )
	  = @_;

	#remove mark
	grep( s#<span class=\"substrate\">(.*?)<\/span>#$1#ig, @{$sentences_ref} );
	grep( s#<span class=\"kinase\">(.*?)<\/span>#$1#ig,    @{$sentences_ref} );
	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "Glycosylation";

	if ( -e "../files/sen_dep/$fname.dep" ) {

		open DEP, '<', "../files/sen_dep/$fname.dep"
		  or die "Can't open dep file: $!";

		# split into each sentence's dep
		my ( $sen_str, @substrate, @kinase, @site );
		my $flag = 0;     # Set flag
		my $i    = -1;    # Set counter
		while (<DEP>) {
			if (/^\R/) {
				chomp;
				$i++;

				# split each_sen_dep into each_dep and start to parse
				my @each_dep = split /\R/, $sen_str;

				@substrate = substrate_pattern_glycosylation(@each_dep);
				@kinase    = kinase_pattern_glycosylation(@each_dep);
				@site      = site_pattern_glycosylation(@each_dep);
				@crosstalk = crosstalk(@each_dep);

				my @substrate_original = @substrate;
				my @kinase_original    = @kinase;
				my @site_original      = @site;

				unless ( $substrate[0] eq 'NULL'
					&& $kinase[0] eq 'NULL'
					&& $site[0]   eq 'NULL' )
				{



					# show all found elements in the table
					unless ( $substrate[0] eq 'NULL' ) {
						if ( @substrate > 1 ) {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @substrate;
						}
						else {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @substrate;
						}
					}
					foreach (@substrate) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $kinase[0] eq 'NULL' ) {
						if ( @kinase > 1 ) {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @kinase;
						}
						else {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @kinase;
						}
					}
					foreach (@kinase) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $site[0] eq 'NULL' ) {
						if ( @site > 1 ) {
							@site = map { $_ . ',' } @site;
						}
						else {
							@site = map { $_ } @site;
						}
					}
					foreach (@site) {      # replace \/ to /
						s#\\\/#\/#;
					}

					my $sen_map_id =
					  @{$sen_have_trigger_ids_ref}[$i] + 1;    # start from 0

					# write the results to a file
					if ($each_pmid) {
						print RESULT
"$each_pmid\t$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}
					else {
						print RESULT
"$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}

				}

				$sen_str = '';    # clear the string
			}

			$sen_str .= $_;
		}
		close DEP;
	}

}

sub ie_acetylation {
	my ( $suffix, $fname, $each_pmid, $sentences_ref, $sen_have_trigger_ids_ref,
		$map_rule_ref, $flag_sid )
	  = @_;

	#remove mark
	grep( s#<span class=\"substrate\">(.*?)<\/span>#$1#ig, @{$sentences_ref} );
	grep( s#<span class=\"kinase\">(.*?)<\/span>#$1#ig,    @{$sentences_ref} );
	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "Acetylation";

	if ( -e "../files/sen_dep/$fname.dep" ) {

		open DEP, '<', "../files/sen_dep/$fname.dep"
		  or die "Can't open dep file: $!";

		# split into each sentence's dep
		my ( $sen_str, @substrate, @kinase, @site );
		my $i = -1;    # Set counter
		while (<DEP>) {
			if (/^\R/) {
				chomp;
				$i++;

				# split each_sen_dep into each_dep and start to parse
				my @each_dep = split /\R/, $sen_str;


				@substrate = substrate_pattern_acetylation(@each_dep);
				@kinase    = kinase_pattern_acetylation(@each_dep);
				@site      = site_pattern_acetylation(@each_dep);
				@crosstalk = crosstalk(@each_dep);

				my @substrate_original = @substrate;
				my @kinase_original    = @kinase;
				my @site_original      = @site;

				unless ( $substrate[0] eq 'NULL'
					&& $kinase[0] eq 'NULL'
					&& $site[0]   eq 'NULL' )
				{

					# show all found elements in the table
					unless ( $substrate[0] eq 'NULL' ) {
						if ( @substrate > 1 ) {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @substrate;
						}
						else {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @substrate;
						}
					}
					foreach (@substrate) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $kinase[0] eq 'NULL' ) {
						if ( @kinase > 1 ) {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @kinase;
						}
						else {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @kinase;
						}
					}
					foreach (@kinase) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $site[0] eq 'NULL' ) {
						if ( @site > 1 ) {
							@site = map { $_ . ',' } @site;
						}
						else {
							@site = map { $_ } @site;
						}
					}
					foreach (@site) {      # replace \/ to /
						s#\\\/#\/#;
					}

					my $sen_map_id =
					  @{$sen_have_trigger_ids_ref}[$i] + 1;    # start from 0

					# write the results to a file
					if ($each_pmid) {
						print RESULT
"$each_pmid\t$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";


					}
					else {
						print RESULT
"$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}

				}

				$sen_str = '';    # clear the string
			}

			$sen_str .= $_;
		}
		close DEP;
	}
	else {

		#		print_html_no_phos( $suffix, $fname, $each_pmid, $ptm_name,
		#			@sentences_init );    # no phos information
	}
}

sub ie_amidation {
	my ( $suffix, $fname, $each_pmid, $sentences_ref, $sen_have_trigger_ids_ref,
		$map_rule_ref, $flag_sid )
	  = @_;

	#remove mark
	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "Amidation";

	if ( -e "../files/sen_dep/$fname.dep" ) {

		open DEP, '<', "../files/sen_dep/$fname.dep"
		  or die "Can't open dep file: $!";

		# split into each sentence's dep
		my ( $sen_str, @substrate, @kinase, @site );
		my $i = -1;    # Set counter
		while (<DEP>) {
			if (/^\R/) {
				chomp;
				$i++;

				# split each_sen_dep into each_dep and start to parse
				my @each_dep = split /\R/, $sen_str;

				@substrate = substrate_pattern_amidat(@each_dep);
				@kinase    = kinase_pattern_amidat(@each_dep);
				@site      = site_pattern_amidat(@each_dep);
				@crosstalk = crosstalk(@each_dep);

				my @substrate_original = @substrate;
				my @kinase_original    = @kinase;
				my @site_original      = @site;

				unless ( $substrate[0] eq 'NULL'
					&& $kinase[0] eq 'NULL'
					&& $site[0]   eq 'NULL' )
				{

					# show all found elements in the table
					unless ( $substrate[0] eq 'NULL' ) {
						if ( @substrate > 1 ) {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @substrate;
						}
						else {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @substrate;
						}
					}
					foreach (@substrate) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $kinase[0] eq 'NULL' ) {
						if ( @kinase > 1 ) {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @kinase;
						}
						else {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @kinase;
						}
					}
					foreach (@kinase) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $site[0] eq 'NULL' ) {
						if ( @site > 1 ) {
							@site = map { $_ . ',' } @site;
						}
						else {
							@site = map { $_ } @site;
						}
					}
					foreach (@site) {      # replace \/ to /
						s#\\\/#\/#;
					}

					my $sen_map_id =
					  @{$sen_have_trigger_ids_ref}[$i] + 1;    # start from 0

					# write the results to a file
					if ($each_pmid) {
						print RESULT
"$each_pmid\t$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";

					}
					else {
						print RESULT
"$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}

				}

				$sen_str = '';    # clear the string
			}

			$sen_str .= $_;
		}
		close DEP;
	}
	else {

		#		print_html_no_phos( $suffix, $fname, $each_pmid, $ptm_name,
		#			@sentences_init );    # no phos information
	}
}

sub ie_hydroxylation {
	my ( $suffix, $fname, $each_pmid, $sentences_ref, $sen_have_trigger_ids_ref,
		$map_rule_ref, $flag_sid )
	  = @_;
	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "Hydroxylation";

	if ( -e "../files/sen_dep/$fname.dep" ) {

		open DEP, '<', "../files/sen_dep/$fname.dep"
		  or die "Can't open dep file: $!";

		# split into each sentence's dep
		my ( $sen_str, @substrate, @kinase, @site );
		my $i = -1;    # Set counter
		while (<DEP>) {
			if (/^\R/) {
				chomp;
				$i++;

				# split each_sen_dep into each_dep and start to parse
				my @each_dep = split /\R/, $sen_str;

				@substrate = substrate_pattern_hydroxy(@each_dep);
				@kinase    = kinase_pattern_hydroxy(@each_dep);
				@site      = site_pattern_hydroxy(@each_dep);
				@crosstalk = crosstalk(@each_dep);

				my @substrate_original = @substrate;
				my @kinase_original    = @kinase;
				my @site_original      = @site;

				unless ( $substrate[0] eq 'NULL'
					&& $kinase[0] eq 'NULL'
					&& $site[0]   eq 'NULL' )
				{

					# show all found elements in the table
					unless ( $substrate[0] eq 'NULL' ) {
						if ( @substrate > 1 ) {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @substrate;
						}
						else {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @substrate;
						}
					}
					foreach (@substrate) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $kinase[0] eq 'NULL' ) {
						if ( @kinase > 1 ) {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @kinase;
						}
						else {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @kinase;
						}
					}
					foreach (@kinase) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $site[0] eq 'NULL' ) {
						if ( @site > 1 ) {
							@site = map { $_ . ',' } @site;
						}
						else {
							@site = map { $_ } @site;
						}
					}
					foreach (@site) {      # replace \/ to /
						s#\\\/#\/#;
					}

					my $sen_map_id =
					  @{$sen_have_trigger_ids_ref}[$i] + 1;    # start from 0

					# write the results to a file
					if ($each_pmid) {
						print RESULT
"$each_pmid\t$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}
					else {
						print RESULT
"$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}

				}

				$sen_str = '';    # clear the string
			}

			$sen_str .= $_;
		}
		close DEP;
	}
	else {

		#		print_html_no_phos( $suffix, $fname, $each_pmid, $ptm_name,
		#			@sentences_init );    # no phos information
	}
}

sub ie_myristoylation {
	my ( $suffix, $fname, $each_pmid, $sentences_ref, $sen_have_trigger_ids_ref,
		$map_rule_ref, $flag_sid )
	  = @_;
	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "Myristoylation";

	if ( -e "../files/sen_dep/$fname.dep" ) {

		open DEP, '<', "../files/sen_dep/$fname.dep"
		  or die "Can't open dep file: $!";

		# split into each sentence's dep
		my ( $sen_str, @substrate, @kinase, @site );
		my $i = -1;    # Set counter
		while (<DEP>) {
			if (/^\R/) {
				chomp;
				$i++;

				# split each_sen_dep into each_dep and start to parse
				my @each_dep = split /\R/, $sen_str;

				@substrate = substrate_pattern_myrist(@each_dep);
				@kinase    = kinase_pattern_myrist(@each_dep);
				@site      = site_pattern_myrist(@each_dep);
				@crosstalk = crosstalk(@each_dep);

				my @substrate_original = @substrate;
				my @kinase_original    = @kinase;
				my @site_original      = @site;

				unless ( $substrate[0] eq 'NULL'
					&& $kinase[0] eq 'NULL'
					&& $site[0]   eq 'NULL' )
				{

					# show all found elements in the table
					unless ( $substrate[0] eq 'NULL' ) {
						if ( @substrate > 1 ) {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @substrate;
						}
						else {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @substrate;
						}
					}
					foreach (@substrate) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $kinase[0] eq 'NULL' ) {
						if ( @kinase > 1 ) {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @kinase;
						}
						else {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @kinase;
						}
					}
					foreach (@kinase) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $site[0] eq 'NULL' ) {
						if ( @site > 1 ) {
							@site = map { $_ . ',' } @site;
						}
						else {
							@site = map { $_ } @site;
						}
					}
					foreach (@site) {      # replace \/ to /
						s#\\\/#\/#;
					}

					my $sen_map_id =
					  @{$sen_have_trigger_ids_ref}[$i] + 1;    # start from 0

					# write the results to a file
					if ($each_pmid) {
						print RESULT
"$each_pmid\t$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";

					}
					else {
						print RESULT
"$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}

				}

				$sen_str = '';    # clear the string
			}

			$sen_str .= $_;
		}
		close DEP;
	}
}

sub ie_sulfation {
	my ( $suffix, $fname, $each_pmid, $sentences_ref, $sen_have_trigger_ids_ref,
		$map_rule_ref, $flag_sid )
	  = @_;
	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "Sulfation";

	if ( -e "../files/sen_dep/$fname.dep" ) {

		open DEP, '<', "../files/sen_dep/$fname.dep"
		  or die "Can't open dep file: $!";

		# split into each sentence's dep
		my ( $sen_str, @substrate, @kinase, @site );
		my $i = -1;    # Set counter
		while (<DEP>) {
			if (/^\R/) {
				chomp;
				$i++;

				# split each_sen_dep into each_dep and start to parse
				my @each_dep = split /\R/, $sen_str;

				@substrate = substrate_pattern_sulf(@each_dep);
				@kinase    = kinase_pattern_sulf(@each_dep);
				@site      = site_pattern_sulf(@each_dep);
				@crosstalk = crosstalk(@each_dep);

				my @substrate_original = @substrate;
				my @kinase_original    = @kinase;
				my @site_original      = @site;

				unless ( $substrate[0] eq 'NULL'
					&& $kinase[0] eq 'NULL'
					&& $site[0]   eq 'NULL' )
				{

					# show all found elements in the table
					unless ( $substrate[0] eq 'NULL' ) {
						if ( @substrate > 1 ) {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @substrate;
						}
						else {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @substrate;
						}
					}
					foreach (@substrate) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $kinase[0] eq 'NULL' ) {
						if ( @kinase > 1 ) {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @kinase;
						}
						else {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @kinase;
						}
					}
					foreach (@kinase) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $site[0] eq 'NULL' ) {
						if ( @site > 1 ) {
							@site = map { $_ . ',' } @site;
						}
						else {
							@site = map { $_ } @site;
						}
					}
					foreach (@site) {      # replace \/ to /
						s#\\\/#\/#;
					}

					my $sen_map_id =
					  @{$sen_have_trigger_ids_ref}[$i] + 1;    # start from 0

					# write the results to a file
					if ($each_pmid) {
						print RESULT
"$each_pmid\t$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";

					}
					else {
						print RESULT
"$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}

				}

				$sen_str = '';    # clear the string
			}

			$sen_str .= $_;
		}
		close DEP;
	}
}

sub ie_anchor {
	my ( $suffix, $fname, $each_pmid, $sentences_ref, $sen_have_trigger_ids_ref,
		$map_rule_ref, $flag_sid )
	  = @_;
	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "GPI-Anchor";

	if ( -e "../files/sen_dep/$fname.dep" ) {

		open DEP, '<', "../files/sen_dep/$fname.dep"
		  or die "Can't open dep file: $!";

		# split into each sentence's dep
		my ( $sen_str, @substrate, @kinase, @site );
		my $i = -1;    # Set counter
		while (<DEP>) {
			if (/^\R/) {
				chomp;
				$i++;

				# split each_sen_dep into each_dep and start to parse
				my @each_dep = split /\R/, $sen_str;

				@substrate = substrate_pattern_anchor(@each_dep);
				@kinase    = kinase_pattern_anchor(@each_dep);
				@site      = site_pattern_anchor(@each_dep);
				@crosstalk = crosstalk(@each_dep);

				my @substrate_original = @substrate;
				my @kinase_original    = @kinase;
				my @site_original      = @site;

				unless ( $substrate[0] eq 'NULL'
					&& $kinase[0] eq 'NULL'
					&& $site[0]   eq 'NULL' )
				{

					# show all found elements in the table
					unless ( $substrate[0] eq 'NULL' ) {
						if ( @substrate > 1 ) {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @substrate;
						}
						else {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @substrate;
						}
					}
					foreach (@substrate) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $kinase[0] eq 'NULL' ) {
						if ( @kinase > 1 ) {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @kinase;
						}
						else {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @kinase;
						}
					}
					foreach (@kinase) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $site[0] eq 'NULL' ) {
						if ( @site > 1 ) {
							@site = map { $_ . ',' } @site;
						}
						else {
							@site = map { $_ } @site;
						}
					}
					foreach (@site) {      # replace \/ to /
						s#\\\/#\/#;
					}

					my $sen_map_id =
					  @{$sen_have_trigger_ids_ref}[$i] + 1;    # start from 0

					# write the results to a file
					if ($each_pmid) {
						print RESULT
"$each_pmid\t$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}
					else {
						print RESULT
"$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}

				}

				$sen_str = '';    # clear the string
			}

			$sen_str .= $_;
		}
		close DEP;
	}
}

sub ie_ubiquitination {
	my ( $suffix, $fname, $each_pmid, $sentences_ref, $sen_have_trigger_ids_ref,
		$map_rule_ref, $flag_sid )
	  = @_;
	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "Ubiquitination";

	if ( -e "../files/sen_dep/$fname.dep" ) {

		open DEP, '<', "../files/sen_dep/$fname.dep"
		  or die "Can't open dep file: $!";

		# split into each sentence's dep
		my ( $sen_str, @substrate, @kinase, @site );
		my $i = -1;    # Set counter
		while (<DEP>) {
			if (/^\R/) {
				chomp;
				$i++;

				# split each_sen_dep into each_dep and start to parse
				my @each_dep = split /\R/, $sen_str;

				@substrate = substrate_pattern_ubiquitination(@each_dep);
				@kinase    = kinase_pattern_ubiquitination(@each_dep);
				@site      = site_pattern_ubiquitination(@each_dep);
				@crosstalk = crosstalk(@each_dep);

				my @substrate_original = @substrate;
				my @kinase_original    = @kinase;
				my @site_original      = @site;

				unless ( $substrate[0] eq 'NULL'
					&& $kinase[0] eq 'NULL'
					&& $site[0]   eq 'NULL' )
				{

					# show all found elements in the table
					unless ( $substrate[0] eq 'NULL' ) {
						if ( @substrate > 1 ) {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @substrate;
						}
						else {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @substrate;
						}
					}
					foreach (@substrate) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $kinase[0] eq 'NULL' ) {
						if ( @kinase > 1 ) {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @kinase;
						}
						else {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @kinase;
						}
					}
					foreach (@kinase) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $site[0] eq 'NULL' ) {
						if ( @site > 1 ) {
							@site = map { $_ . ',' } @site;
						}
						else {
							@site = map { $_ } @site;
						}
					}
					foreach (@site) {      # replace \/ to /
						s#\\\/#\/#;
					}

					my $sen_map_id =
					  @{$sen_have_trigger_ids_ref}[$i] + 1;    # start from 0

					# write the results to a file
					if ($each_pmid) {
						print RESULT
"$each_pmid\t$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}
					else {
						print RESULT
"$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}
				}

				$sen_str = '';    # clear the string
			}

			$sen_str .= $_;

		}
		close DEP;
	}
}

sub ie_disulfide {
	my ( $suffix, $fname, $each_pmid, $sentences_ref, $sen_have_trigger_ids_ref,
		$map_rule_ref, $flag_sid )
	  = @_;

	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "Disulfide";

	if ( -e "../files/sen_dep/$fname.dep" ) {

		open DEP, '<', "../files/sen_dep/$fname.dep"
		  or die "Can't open dep file: $!";

		# split into each sentence's dep
		my ( $sen_str, @substrate, @kinase, @site );
		my $i = -1;    # Set counter
		while (<DEP>) {
			if (/^\R/) {
				chomp;
				$i++;

				# split each_sen_dep into each_dep and start to parse
				my @each_dep = split /\R/, $sen_str;

				@substrate = substrate_pattern_disulfide(@each_dep);
				@kinase    = kinase_pattern_disulfide(@each_dep);
				@site      = site_pattern_disulfide(@each_dep);
				@crosstalk = crosstalk(@each_dep);

				my @substrate_original = @substrate;
				my @kinase_original    = @kinase;
				my @site_original      = @site;

				unless ( $substrate[0] eq 'NULL'
					&& $kinase[0] eq 'NULL'
					&& $site[0]   eq 'NULL' )
				{

					# show all found elements in the table
					unless ( $substrate[0] eq 'NULL' ) {
						if ( @substrate > 1 ) {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @substrate;
						}
						else {
							@substrate = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @substrate;
						}
					}
					foreach (@substrate) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $kinase[0] eq 'NULL' ) {
						if ( @kinase > 1 ) {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} 
									  . $2
									  . ${$map_rule_ref}{$3} . ',';
								}
								else { ${$map_rule_ref}{$_} . ',' }
							} @kinase;
						}
						else {
							@kinase = map {
								if (/^(PRO\d+)(.+?)(PRO\d+)$/)
								{
									${$map_rule_ref}{$1} . $2
									  . ${$map_rule_ref}{$3};
								}
								else { ${$map_rule_ref}{$_} }
							} @kinase;
						}
					}
					foreach (@kinase) {    # replace \/ to /
						s#\\\/#\/#;
					}

					unless ( $site[0] eq 'NULL' ) {
						if ( @site > 1 ) {
							@site = map { $_ . ',' } @site;
						}
						else {
							@site = map { $_ } @site;
						}
					}
					foreach (@site) {      # replace \/ to /
						s#\\\/#\/#;
					}

					my $sen_map_id =
					  @{$sen_have_trigger_ids_ref}[$i] + 1;    # start from 0

					# write the results to a file
					if ($each_pmid) {
						print RESULT
"$each_pmid\t$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";

					}
					else {
						print RESULT
"$sen_map_id\t@substrate\t@kinase\t@site\t$sentences_init[${$sen_have_trigger_ids_ref}[$i]]\t$ptm_name\n";
					}

				}

				$sen_str = '';    # clear the string
			}

			$sen_str .= $_;
		}
		close DEP;
	}
}

sub preprocess {
	my @pmids = @_;    #receive pmids
	if (@pmids) {

		print "111";
		# call pubmed API to download the file that formated in MEDLINE form
		my $suffix = call_pubmed(@pmids); # return unique file suffix
		if ( $suffix != 0 ) {

			# process the auto-download pubmed file
			deal_pubmed($suffix);

			# start parsing
			foreach my $each_pmid (@pmids) {
				my $pmid_suffix = $each_pmid . '_' . $suffix . '.txt';
				open EACH, '+<',
				  "../files/init_file/$pmid_suffix";    # read and write mode
				flock( EACH, 2 );
				my $count = <EACH>;
				if ( $count =~
					s/ [\(|\[][A-Z][a-z]+?,?.+?\(\d+\).+?,? \d+-\d+[\)|\]]//g
					|| $count =~ s/ [\(|\[][A-Z][a-z]+? .+?, \d+?[\)|\]]//g )
				{
					seek( EACH, 0, 0 );
					truncate( EACH, 0 );
					print EACH $count;
					#flock( EACH, 8 );
					#close EACH;
				}
				flock( EACH, 8 );
				close EACH;

				# call lingpipe sub function
				my ( $fname, $sentences_ref, $sen_have_trigger_ids_ref,
					$sen_have_triggers_ref, $map_rule_ref )
				  = banner($pmid_suffix);
				my @sentences            = @{$sentences_ref};
				my @sen_have_trigger_ids = @{$sen_have_trigger_ids_ref};

				my @sen_have_triggers    = @{$sen_have_triggers_ref};
				if ( @sen_have_trigger_ids && @sen_have_triggers ) {

					standford_parser($fname);    # stanford_parser parsing
				}

				# information extraction
				#chose PTM process
				my %triggers_hash;
				foreach $iterms (@sen_have_triggers) {

					if ( $iterms =~ /phospho/i ) {

						$triggers_hash{'phosphorylation'}++;
					}
					if ( $iterms =~ /methyl/i ) {
						$triggers_hash{'methylation'}++;
					}
					if ( $iterms =~ /glyco|O-GlcNAc/i ) {

						$triggers_hash{'glycosylation'}++;
					}
					if ( $iterms =~ /acety/i ) {
						$triggers_hash{'acetylation'}++;
					}
					if ( $iterms =~ /amid/i ) {
						$triggers_hash{'amidation'}++;
					}
					if ( $iterms =~ /hydroxy/i ) {
						$triggers_hash{'hydroxylation'}++;
					}
					if ( $iterms =~ /myrist/i ) {
						$triggers_hash{'myristoylation'}++;
					}
					if ( $iterms =~ /sulfa/i ) {
						$triggers_hash{'sulfation'}++;
					}
					if ( $iterms =~ /anchor|GPI|glycosylphosphatidylinositol/i )
					{
						$triggers_hash{'gpi_anchor'}++;
					}
					if ( $iterms =~ /disulf/i ) {
						$triggers_hash{'disulfide'}++;
					}
					if ( $iterms =~ /ubiquit|Ub|E1|E2|E3|E6/i ) {
						$triggers_hash{'ubiquitination'}++;
					}
				}
				my $max_trigger;
				my $max_trigger_value =
				  ( sort { $b <=> $a } values %triggers_hash )[0];
				while ( ( $Key, $Value ) = each(%triggers_hash) ) {
					if ( $Value == $max_trigger_value ) {
						$max_trigger = $Key;
					}
				}
				if ( $max_trigger eq 'phosphorylation' ) {
					ie_phospho( $suffix, $fname, $each_pmid, $sentences_ref,
						$sen_have_trigger_ids_ref, $map_rule_ref );
				}
				elsif ( $max_trigger eq 'methylation' ) {
					ie_methylation( $suffix, $fname, $each_pmid, $sentences_ref,
						$sen_have_trigger_ids_ref, $map_rule_ref );
				}
				elsif ( $max_trigger eq 'glycosylation' ) {
					ie_glycosylation( $suffix, $fname, $each_pmid,
						$sentences_ref, $sen_have_trigger_ids_ref,
						$map_rule_ref );
				}
				elsif ( $max_trigger eq 'acetylation' ) {
					ie_acetylation( $suffix, $fname, $each_pmid, $sentences_ref,
						$sen_have_trigger_ids_ref, $map_rule_ref );
				}
				elsif ( $max_trigger eq 'amidation' ) {
					ie_amidation( $suffix, $fname, $each_pmid, $sentences_ref,
						$sen_have_trigger_ids_ref, $map_rule_ref );
				}
				elsif ( $max_trigger eq 'hydroxylation' ) {
					ie_hydroxylation( $suffix, $fname, $each_pmid,
						$sentences_ref, $sen_have_trigger_ids_ref,
						$map_rule_ref );
				}
				elsif ( $max_trigger eq 'myristoylation' ) {
					ie_myristoylation( $suffix, $fname, $each_pmid,
						$sentences_ref, $sen_have_trigger_ids_ref,
						$map_rule_ref );
				}
				elsif ( $max_trigger eq 'sulfation' ) {
					ie_sulfation( $suffix, $fname, $each_pmid, $sentences_ref,
						$sen_have_trigger_ids_ref, $map_rule_ref );
				}
				elsif ( $max_trigger eq 'gpi_anchor' ) {
					ie_anchor( $suffix, $fname, $each_pmid, $sentences_ref,
						$sen_have_trigger_ids_ref, $map_rule_ref );
				}
				elsif ( $max_trigger eq 'disulfide' ) {
					ie_disulfide( $suffix, $fname, $each_pmid, $sentences_ref,
						$sen_have_trigger_ids_ref, $map_rule_ref );
				}
				elsif ( $max_trigger eq 'ubiquitination' ) {
					ie_ubiquitination( $suffix, $fname, $each_pmid,
						$sentences_ref, $sen_have_trigger_ids_ref,
						$map_rule_ref );
				}

			}
		
		}
	}else{
		print "Input file is empty!";
	}

}

sub mptm {

	open(INPUT,"$ARGV[0]") or die $!;
	open(RESULT,">>$ARGV[1]") or die $!;
	my @pmids;
	while(<INPUT>){
		s/\s+//;
		push(@pmids,$_);
		preprocess(@pmids);
		@pmids=();
	}
close INPUT;
close RESULT;
print "\n2014 All Rights Reserved. Design by HI_lab @ USTC \n";
}


