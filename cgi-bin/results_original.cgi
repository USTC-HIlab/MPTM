# Perl CGI Edition 1.0
# For Text Mining of PTM
# Heuristic Algorithm
# Programmed by DongDong Sun,Mang Wang
# Final revised on Sep 30, 2013
BEGIN {
	delete $INC{"/home/bmi/wwwroot/mptm/cgi-bin/mysql.pl"};
}
require '/home/bmi/wwwroot/mptm/cgi-bin/ie_phosphorylation.pl';
require '/home/bmi/wwwroot/mptm/cgi-bin/ie_methylation.pl';
require '/home/bmi/wwwroot/mptm/cgi-bin/ie_glycosylation.pl';
require '/home/bmi/wwwroot/mptm/cgi-bin/ie_hydroxylation.pl';
require '/home/bmi/wwwroot/mptm/cgi-bin/ie_acetylation.pl';
require '/home/bmi/wwwroot/mptm/cgi-bin/ie_amidation.pl';
require '/home/bmi/wwwroot/mptm/cgi-bin/ie_myristoylation.pl';
require '/home/bmi/wwwroot/mptm/cgi-bin/ie_sulfation.pl';
require '/home/bmi/wwwroot/mptm/cgi-bin/ie_anchor.pl';
require '/home/bmi/wwwroot/mptm/cgi-bin/ie_disulfide.pl';
require '/home/bmi/wwwroot/mptm/cgi-bin/ie_ubiquitination.pl';
require '/home/bmi/wwwroot/mptm/cgi-bin/mysql.pl';
require '/home/bmi/wwwroot/mptm/cgi-bin/ie_otherinfo.pl';
use LWP::Simple;

sub insert_recordpmid {
	my @pmids = @_;
	for ( my $i=0 ; $i < @pmids ; $i++ ) {
		eval {
			my $self = newdb( "localhost", "ptminfo", "root", "1234" );
			dosql( $self, "DELETE FROM recordpmid WHERE pmid= '$pmids[$i]'" );

			dosql( $self, "INSERT  recordpmid (pmid) VALUES ('$pmids[$i]')" );
		};
	}
}

sub split_pmid {
	my $string = shift;
	$string =~ s/^\s+|\s+$//g;    # trip leading and trailing whitespaces
	my @all_pmids;
	if ( $string =~ /^(\d+)$/ ) {    # only one pmid
		push @all_pmids, $1;
	}
	elsif ( $string =~ /,/ ) {       # split with comma
		@all_pmids = split /,/, $string;
		@all_pmids = grep { $_ = $1 if /(\S+)/ }
		  @all_pmids
		  ;    # retain the element in array that containing pmid with no spaces
	}
	else {
		@all_pmids = split /\s+/, $string;    # split with space
	}
	return @all_pmids;
}

sub search_pmid {
	my @pmid = @_;
	my $self = newdb( "localhost", "ptminfo", "root", "1234" );
	my $rows;
	my @is_pmid;
	my @pmid_has_info;
	for ( my $i = 0 ; $i < @pmid ; $i++ ) {
		eval {
			$rows = dosql( $self,
				"SELECT pmid FROM ptmtext WHERE pmid = '$pmid[$i]'" );
		};
		if ( $rows eq '0E0' ) {
			push( @is_pmid, $pmid[$i] );
		}else{
			push( @pmid_has_info, $pmid[$i] );
		}
	}
	return (\@is_pmid,\@pmid_has_info);
}

sub search_pmid_record {
	my @pmid = @_;
	my $self = newdb( "localhost", "ptminfo", "root", "1234" );
	my $rows;
	my @is_pmid;
	for ( my $i = 0 ; $i < @pmid ; $i++ ) {
		eval {
			$rows = dosql( $self,
				"SELECT pmid FROM recordpmid WHERE pmid = '$pmid[$i]'" );
		};
		if ( $rows eq '0E0' ) {
			push( @is_pmid, $pmid[$i] );
		}
	}
	return @is_pmid;
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

sub lingpipe {
	my $file_suffix = shift;
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
	chdir '../../../../cgi-bin/'
	  or die "Can't back to cgi-bin dir: $!";       # back to cgi-bin dir

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
/^\d+$|\bAla\b|\bArg\b|\bAsn\b|\bAsp\b|\bCys\b|\bGln\b|\bGlu\b|\bK\d+\b|\bGly\b|\bHis\b|\bIle\b|\bLeu\b|\bLys\b|\bMet\b|\bPhe\b|\bSer|D\b|\bThr\b|\bTrp\b|\bTyr\b|\bVal\b|\bPro\b|\bAla\d+\b|\bArg\d+\b|\bAsn\d+\b|\bAsp\d+\b|\bCys\d+\b|\bGln\d+\b|\bGlu\d+\b|\bGly\d+\b|\bHis\d+\b|\bIle\d+\b|\bLeu\d+\b|\bLys\d+\b|\bMet\d+\b|\bPhe\d+\b|\bSer\d+\b|\bThr\d+\b|\bTrp\d+\b|\bTyr\d+\b|\bVal\d+\b|\bPro\d+\b|\b[T|t]\d+\b|\b[Y|y]\d+\b|\bAlaP\b|\bArgP\b|\bAsnP\b|\bAspP\b|\bCysP\b|\bGlnP\b|\bGluP\b|\bGlyP\b|\bHisP\b|\bIleP\b|\bLeuP\b|\bLysP\b|\bMetP\b|\bPheP\b|\bSerP\b|\bThrP\b|\bTrpP\b|\bTyrP\b|\bValP\b|\bProP\b/
			&& $name !~
/(\bAlanine\b|\bArginine\b|\bAsparagine\b|\bAspartic\b|\bCysteine\b|\bGlutamine\b|\bGlutamic\b|\bGlycine\b|\bHistidine\b|\bIsoleucine\b|\bLeucine\b|\bLysine\b|\bMethionine\b|\bPhenylalanine\b|\bProline\b|\bSerine\b|\bThreonine\b|\bTryptophan\b|\bTyrosine\b|\bValine\b)(-\d+$| \d+$)/i
			&& $name !~
/terminal|terminus|promoter|sites?|residues?|positions?|^insulin\S*$|^trypsin\w*$|^\S*chymotryp\w*$|\S*A[T|D]P\w*$|^proteins?$|^(?:protein|insulin-sensitive|endogenous|nuclear|exogenous|membranal|cytoplasmic|major|minor) kinases?$|(?:serine|threonine|tyrosine) protein kinases?|phospho-forms?|.*?virus$|.*?domain\S*$|.*?subunit\S*$|.*?region\S*$|.*?isoform\S*$|^a isoenzyme$|^N delta 1$|alphaalpha|^CaM?$|genes?$|^VTA$/i
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

sub keyWordsRetrievalPubmed {

	# Get searching keywords by users
	# For example
	my ( $search, $selectptm,$disease,$time ) = @_;
	if($time ne ''){
			$time = $time."[pdat]";
	}
	my $input_ptm;
	$input_ptm = $search . " AND " . $disease . " AND " . $time;
	if ( $selectptm eq '0' ) {
		$input_ptm .= " AND Phosphorylation";
	}
	elsif ( $selectptm eq '1' ) {
		$input_ptm .= " AND Methylation";
	}
	elsif ( $selectptm eq '2' ) {
		$input_ptm .= " AND Glycosylation";
	}
	elsif ( $selectptm eq '3' ) {
		$input_ptm .= " AND Acetylation";
	}
	elsif ( $selectptm eq '4' ) {
		$input_ptm .= " AND Amidation";
	}
	elsif ( $selectptm eq '5' ) {
		$input_ptm .= " AND Hydroxylation";
	}
	elsif ( $selectptm eq '6' ) {
		$input_ptm .= " AND Myristoylation";
	}
	elsif ( $selectptm eq '7' ) {
		$input_ptm .= " AND Sulfation";
	}
	elsif ( $selectptm eq '8' ) {
		$input_ptm .= " AND GPI-Anchor";
	}
	elsif ( $selectptm eq '9' ) {
		$input_ptm .= " AND Disulfide";
	}
	elsif ( $selectptm eq '10' ) {
		$input_ptm .= " AND Ubiquitination";
	}
	else {
		$input_ptm .=
		  " AND Phosphorylation " .
		  "OR Methylation " .
		  "OR Glycosylation " .
		  "OR Acetylation " .
		  "OR Amidation " .
		  "OR Hydroxylation " .
		  "OR Myristoylation " .
		  "OR Sulfation " .
		  "OR GPI-Anchor " .
		  "OR Disulfide " .
		  "OR Ubiquitination";
	}

	my $query = shift_input($input_ptm);
	my $db    = 'pubmed';

	#assemble the esearch URL
	my $base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';

#my $url  = $base . "esearch.fcgi?db=$db&term=$query&retmax=100&usehistory=y&field=abstract";
	my $url =
	  $base . "esearch.fcgi?db=$db&term=$query&usehistory=y&retmax=10000&field=abstract";

	#post the esearch URL
	my $output = get($url);

	#parse WebEnv and QueryKey
	my $web   = $1 if ( $output =~ /<WebEnv>(\S+)<\/WebEnv>/ );
	my $key   = $1 if ( $output =~ /<QueryKey>(\d+)<\/QueryKey>/ );
	my $count = $1 if ( $output =~ /<Count>(\d+)<\/Count>/ );
	my @search_pmid;
	while ( $output =~ /<Id>(\d+)<\/Id>/g ) {
		push( @search_pmid, $1 );
	}
	return @search_pmid;
}

#sub keyWordsRetrieval {
#	my ( $input, $selectptm ) = @_;
#	if ( $selectptm eq '0' ) {
#		$input_ptm = "Phosphorylation";
#	}
#	elsif ( $selectptm eq '1' ) {
#		$input_ptm = "Methylation";
#	}
#	elsif ( $selectptm eq '2' ) {
#		$input_ptm = "Glycosylation";
#	}
#	elsif ( $selectptm eq '3' ) {
#		$input_ptm = "Acetylation";
#	}
#	elsif ( $selectptm eq '4' ) {
#		$input_ptm = "Amidation";
#	}
#	elsif ( $selectptm eq '5' ) {
#		$input_ptm = "Hydroxylation";
#	}
#	elsif ( $selectptm eq '6' ) {
#		$input_ptm = "Myristoylation";
#	}
#	elsif ( $selectptm eq '7' ) {
#		$input_ptm = "Sulfation";
#	}
#	elsif ( $selectptm eq '8' ) {
#		$input_ptm = "GPI-Anchor";
#	}
#	elsif ( $selectptm eq '9' ) {
#		$input_ptm = "Disulfide";
#	}
#	elsif ( $selectptm eq '10' ) {
#		$input_ptm = "Ubiquitination";
#	}
#	my @result;
#	my @search_pmids;
#
#	my $self = newdb( "localhost", "ptminfo", "root", "1234" );
#	@result = query( $self,
#"SELECT * FROM ptmdetails WHERE (substrate REGEXP '$input' OR kinase REGEXP '$input') AND ptm_type = '$input_ptm'"
#	);
#	for ( my $i = 0 ; $i < @result ; $i++ ) {
#		push( @search_pmids, $result[$i][0] );
#	}
#	return @search_pmids;
#}

sub standford_parser {
	my $fname  = shift;
	my $input  = "../files/sen_map/$fname.map";
	my $output = "../files/sen_dep/$fname.dep";
	chdir "../stanford_parser/"
	  or die "Can't chdir to stanford_parser dir: $!";
	`sh lexparser.sh $input > $output`;
	chdir "../cgi-bin/"
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

#sub print_html_phos {
#	my ( $pmid, $sentences_ref, $ptm_name ) = @_;
#	my @sentences = @{$sentences_ref};
#	my $total_sen = @sentences;
#	open FHTML, '>>', "../result_htmls/$ptm_name.html"
#	  or die "Can't open a file to write results: $!";
#	print FHTML
#qq(<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
#<html xmlns="http://www.w3.org/1999/xhtml">
#<head>
#<link href="../css/results.css" rel="stylesheet" type="text/css" />
#<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
#</head>
#<body>
#<div id="content">
#			<div class="post">
#				<div class="entry">
#);
#	print FHTML qq(<table>
#       <tr>
#          <th colspan="4">Summary</th>
#       </tr>
#     <tr>
#        <td><strong>PMID</strong></td>
#        <td><strong>Total Sentences</strong></td>
#        <td><strong>$ptm_name</strong></td>
#        <td><strong>Text Evidence</strong></td>
#  </tr>
# <tr>
#    <td><a href="http://www.ncbi.nlm.nih.gov/pubmed/?term=$pmid" target="_blank">$pmid</a></td>
#   <td class="label_summary">$total_sen</td>
#  <td class="label_summary">See Details</td>
# <td class="label_summary">See Text Evidence</td>
# </tr>
#<tr>
#   <th colspan="4">Details</th>
# </tr>
#<tr>
#<td>&nbsp;&nbsp;<strong>SID</strong>&nbsp;&nbsp;</td>
#<td><strong>Substrate</strong></td>
#<td><strong>Kinase</strong></td>
# <td><strong>Site</strong></td>
#  </tr>);
#	close(FHTML);
#}

sub ie_phospho {
	my ( $suffix, $fname, $each_pmid, $sentences_ref, $sen_have_trigger_ids_ref,
		$map_rule_ref, $flag_sid )
	  = @_;
	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "Phosphorylation";

	my $origin_text = '';
	for ( my $i = 0 ; $i < @sentences_init ; $i++ ) {
		$origin_text .= $sentences_init[$i];
	}
	eval {    
		      
		my $self = newdb( "localhost", "ptminfo", "root", "1234" );

		$rows =
		  dosql( $self, "SELECT pmid FROM ptmtext WHERE pmid = '$each_pmid'" );
		if ( $rows eq '0E0' ) {

			
			$origin_text =~ s/'/''/g;

			
			$origin_text =~ s/\(//g;
			$origin_text =~ s/\)//g;
			chomp($origin_text);
			my $disease_text   = get_disease_text($origin_text);
			my $organisms_text = get_organisms($origin_text);
			my $goterms        = get_goterms($origin_text);
			my $title = get_title($organisms_text);
			dosql( $self,
"INSERT  ptmtext (pmid,origin_text,disease_text,organisms_text,ptm_type,goterms,title) VALUES ($each_pmid,'$origin_text','$disease_text','$organisms_text','$ptm_name','$goterms','$title')"
			);
		}
	};

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
						eval { 
							    
							my $self =
							  newdb( "localhost", "ptminfo", "root", "1234" );
							dosql( $self,
"delete from ptmdetails where pmid = $each_pmid and sentence_id = $sen_map_id"
							);

							
							my $sentences =
							  $sentences_init[ ${$sen_have_trigger_ids_ref}[$i]
							  ];
							$sentences =~ s/'/''/g;

							
							my $substrate_value = join( '', @substrate );
							$substrate_value =~ s/\(//g;
							$substrate_value =~ s/\)//g;
							my $kinase_value = join( '', @kinase );
							$kinase_value =~ s/\(//g;
							$kinase_value =~ s/\)//g;
							my $site_value = join( '', @site );
							$site_value =~ s/\(//g;
							$site_value =~ s/\)//g;
							dosql( $self,
"insert  ptmdetails (pmid,sentence_id,substrate,kinase,site,text_evidence,ptm_type,crosstalk) VALUES ($each_pmid,$sen_map_id,'$substrate_value','$kinase_value','$site_value','$sentences','$ptm_name','@crosstalk')"
							);
						};
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

	
	my $origin_text = '';
	for ( my $i = 0 ; $i < @sentences_init ; $i++ ) {
		$origin_text .= $sentences_init[$i];
	}
	eval {   
		      
		my $self = newdb( "localhost", "ptminfo", "root", "1234" );

		$rows =
		  dosql( $self, "select * from ptmtext where pmid = '$each_pmid'" );
		if ( $rows eq '0E0' ) {

			
			$origin_text =~ s/'/''/g;

			
			$origin_text =~ s/\(//g;
			$origin_text =~ s/\)//g;
			my $disease_text   = get_disease_text($origin_text);
			my $organisms_text = get_organisms($origin_text);
			my $goterms        = get_goterms($origin_text);
			my $title = get_title($organisms_text);
			dosql( $self,
"INSERT  ptmtext (pmid,origin_text,disease_text,organisms_text,ptm_type,goterms,title) VALUES ($each_pmid,'$origin_text','$disease_text','$organisms_text','$ptm_name','$goterms','$title')"
			);
		}
	};
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

					if ( $flag == 1 ) {

						#						$ptm_hash{$ptm_name} = 1;

						# only print this html tags once

						#	print_html_phos( $each_pmid, $sentences_ref,
						#		$ptm_name );

					}

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
						eval { 
							    
							my $self =
							  newdb( "localhost", "ptminfo", "root", "1234" );
							dosql( $self,
"delete from ptmdetails where pmid = $each_pmid and sentence_id = $sen_map_id"
							);

							
							my $sentences =
							  $sentences_init[ ${$sen_have_trigger_ids_ref}[$i]
							  ];
							$sentences =~ s/'/''/g;

							
							my $substrate_value = join( '', @substrate );
							$substrate_value =~ s/\(//g;
							$substrate_value =~ s/\)//g;
							my $kinase_value = join( '', @kinase );
							$kinase_value =~ s/\(//g;
							$kinase_value =~ s/\)//g;
							my $site_value = join( '', @site );
							$site_value =~ s/\(//g;
							$site_value =~ s/\)//g;
							dosql( $self,
"insert  ptmdetails (pmid,sentence_id,substrate,kinase,site,text_evidence,ptm_type,crosstalk) VALUES ($each_pmid,$sen_map_id,'$substrate_value','$kinase_value','$site_value','$sentences','$ptm_name','@crosstalk')"
							);
						};
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

	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "Glycosylation";

	
	my $origin_text = '';
	for ( my $i = 0 ; $i < @sentences_init ; $i++ ) {
		$origin_text .= $sentences_init[$i];
	}
	eval {    
		      
		my $self = newdb( "localhost", "ptminfo", "root", "1234" );

		$rows =
		  dosql( $self, "select * from ptmtext where pmid = '$each_pmid'" );
		if ( $rows eq '0E0' ) {

			
			$origin_text =~ s/'/''/g;

			
			$origin_text =~ s/\(//g;
			$origin_text =~ s/\)//g;
			my $disease_text   = get_disease_text($origin_text);
			my $organisms_text = get_organisms($origin_text);
			my $goterms        = get_goterms($origin_text);
			my $title = get_title($organisms_text);
			dosql( $self,
"INSERT  ptmtext (pmid,origin_text,disease_text,organisms_text,ptm_type,goterms,title) VALUES ($each_pmid,'$origin_text','$disease_text','$organisms_text','$ptm_name','$goterms','$title')"
			);
		}
	};

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
						eval { 
							    
							my $self =
							  newdb( "localhost", "ptminfo", "root", "1234" );
							dosql( $self,
"delete from ptmdetails where pmid = $each_pmid and sentence_id = $sen_map_id"
							);

							
							my $sentences =
							  $sentences_init[ ${$sen_have_trigger_ids_ref}[$i]
							  ];
							$sentences =~ s/'/''/g;

							
							my $substrate_value = join( '', @substrate );
							$substrate_value =~ s/\(//g;
							$substrate_value =~ s/\)//g;
							my $kinase_value = join( '', @kinase );
							$kinase_value =~ s/\(//g;
							$kinase_value =~ s/\)//g;
							my $site_value = join( '', @site );
							$site_value =~ s/\(//g;
							$site_value =~ s/\)//g;
							dosql( $self,
"insert  ptmdetails (pmid,sentence_id,substrate,kinase,site,text_evidence,ptm_type,crosstalk) VALUES ($each_pmid,$sen_map_id,'$substrate_value','$kinase_value','$site_value','$sentences','$ptm_name','@crosstalk')"
							);
						};
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

	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "Acetylation";

	
	my $origin_text = '';
	for ( my $i = 0 ; $i < @sentences_init ; $i++ ) {
		$origin_text .= $sentences_init[$i];
	}
	eval {    
		     
		my $self = newdb( "localhost", "ptminfo", "root", "1234" );

		$rows =
		  dosql( $self, "select * from ptmtext where pmid = '$each_pmid'" );
		if ( $rows eq '0E0' ) {

			
			$origin_text =~ s/'/''/g;

			
			$origin_text =~ s/\(//g;
			$origin_text =~ s/\)//g;
			my $disease_text   = get_disease_text($origin_text);
			my $organisms_text = get_organisms($origin_text);
			my $goterms        = get_goterms($origin_text);
			my $title = get_title($organisms_text);
			dosql( $self,
"INSERT  ptmtext (pmid,origin_text,disease_text,organisms_text,ptm_type,goterms,title) VALUES ($each_pmid,'$origin_text','$disease_text','$organisms_text','$ptm_name','$goterms','$title')"
			);
		}
	};

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
						eval { 
							    
							my $self =
							  newdb( "localhost", "ptminfo", "root", "1234" );
							dosql( $self,
"delete from ptmdetails where pmid = $each_pmid and sentence_id = $sen_map_id"
							);

							
							my $sentences =
							  $sentences_init[ ${$sen_have_trigger_ids_ref}[$i]
							  ];
							$sentences =~ s/'/''/g;

							
							my $substrate_value = join( '', @substrate );
							$substrate_value =~ s/\(//g;
							$substrate_value =~ s/\)//g;
							my $kinase_value = join( '', @kinase );
							$kinase_value =~ s/\(//g;
							$kinase_value =~ s/\)//g;
							my $site_value = join( '', @site );
							$site_value =~ s/\(//g;
							$site_value =~ s/\)//g;
							dosql( $self,
"insert  ptmdetails (pmid,sentence_id,substrate,kinase,site,text_evidence,ptm_type,crosstalk) VALUES ($each_pmid,$sen_map_id,'$substrate_value','$kinase_value','$site_value','$sentences','$ptm_name','@crosstalk')"
							);
						};
					}

				}

				$sen_str = '';    # clear the string
			}

			$sen_str .= $_;
		}
		close DEP;

		#		if ( $flag == 0 ) {
		#
		#			$ptm_name = "Phosphorylation";
		#
		#			#		print_html_no_phos( $suffix, $fname, $each_pmid, $ptm_name,
		#			#				@sentences_init );    # no phos information
		#		}
		#		else {

		# print the labeled information
		#remove  site mark
		#			grep( s/(<span class="site">.*<\/span>)?<br \/>//g,
		#				@{$sentences_ref} );
		#			if ( grep { $_ !~ /^\d+/ } @{$sentences_ref} ) {
		#				my $id = 0;
		#				@{$sentences_ref} =
		#				  map { ++$id . "\. " . $_ . "<br />\n" } @{$sentences_ref};
		#
		#				$flag_sid++;
		#			}
		#			else {
		#				@{$sentences_ref} = map { $_ . "<br />\n" } @{$sentences_ref};
		#			}

#			open FHTML, '>>', "../result_htmls/$ptm_name.html"
#			  or die "Can't open a file to write results: $!";
#			print FHTML qq(<tr>
#         <th colspan="4">Text Evidence ( <span class="substrate">substrate</span> <span class="kinase">kinase</span> <span class="site">site</span> )</th>
#                </tr>
#                 <tr>
#                   <td colspan="4" class="left">@{$sentences_ref}</td>
#                 </tr>
#                 </table>
#                <a href="#" class="back"><img src="../images/back_to_top.png" width="50" height="50" alt="Back to Top" title="Back to Top" /></a>
#                <a href="../files/results/${suffix}_results.txt" target="_blank" class="download"><img src="../images/download.png" width="50" height="50" alt="Download All Results" title="Download All Results" /></a>
#                </div>
#</div>
#</div>
#                </body>
#                </html>);
#			close(FHTML);
#		}
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

	
	my $origin_text = '';
	for ( my $i = 0 ; $i < @sentences_init ; $i++ ) {
		$origin_text .= $sentences_init[$i];
	}
	eval {   
		     
		my $self = newdb( "localhost", "ptminfo", "root", "1234" );

		$rows =
		  dosql( $self, "select * from ptmtext where pmid = '$each_pmid'" );
		if ( $rows eq '0E0' ) {

			
			$origin_text =~ s/'/''/g;

			
			$origin_text =~ s/\(//g;
			$origin_text =~ s/\)//g;
			my $disease_text   = get_disease_text($origin_text);
			my $organisms_text = get_organisms($origin_text);
			my $goterms        = get_goterms($origin_text);
			my $title = get_title($organisms_text);
			dosql( $self,
"INSERT  ptmtext (pmid,origin_text,disease_text,organisms_text,ptm_type,goterms,title) VALUES ($each_pmid,'$origin_text','$disease_text','$organisms_text','$ptm_name','$goterms','$title')"
			);
		}
	};

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
						eval {
							    
							my $self =
							  newdb( "localhost", "ptminfo", "root", "1234" );
							dosql( $self,
"delete from ptmdetails where pmid = $each_pmid and sentence_id = $sen_map_id"
							);

						
							my $sentences =
							  $sentences_init[ ${$sen_have_trigger_ids_ref}[$i]
							  ];
							$sentences =~ s/'/''/g;

							
							my $substrate_value = join( '', @substrate );
							$substrate_value =~ s/\(//g;
							$substrate_value =~ s/\)//g;
							my $kinase_value = join( '', @kinase );
							$kinase_value =~ s/\(//g;
							$kinase_value =~ s/\)//g;
							my $site_value = join( '', @site );
							$site_value =~ s/\(//g;
							$site_value =~ s/\)//g;
							dosql( $self,
"insert  ptmdetails (pmid,sentence_id,substrate,kinase,site,text_evidence,ptm_type,crosstalk) VALUES ($each_pmid,$sen_map_id,'$substrate_value','$kinase_value','$site_value','$sentences','$ptm_name','@crosstalk')"
							);
						};
					}

				}

				$sen_str = '';    # clear the string
			}

			$sen_str .= $_;
		}
		close DEP;
	}
}

sub ie_hydroxylation {
	my ( $suffix, $fname, $each_pmid, $sentences_ref, $sen_have_trigger_ids_ref,
		$map_rule_ref, $flag_sid )
	  = @_;
	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "Hydroxylation";

	
	my $origin_text = '';
	for ( my $i = 0 ; $i < @sentences_init ; $i++ ) {
		$origin_text .= $sentences_init[$i];
	}
	eval {    
		     
		my $self = newdb( "localhost", "ptminfo", "root", "1234" );

		$rows =
		  dosql( $self, "select * from ptmtext where pmid = '$each_pmid'" );
		if ( $rows eq '0E0' ) {

			
			$origin_text =~ s/'/''/g;

			
			$origin_text =~ s/\(//g;
			$origin_text =~ s/\)//g;
			my $disease_text   = get_disease_text($origin_text);
			my $organisms_text = get_organisms($origin_text);
			my $goterms        = get_goterms($origin_text);
			my $title = get_title($organisms_text);
			dosql( $self,
"INSERT  ptmtext (pmid,origin_text,disease_text,organisms_text,ptm_type,goterms,title) VALUES ($each_pmid,'$origin_text','$disease_text','$organisms_text','$ptm_name','$goterms','$title')"
			);
		}
	};

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
						eval { 
							    
							my $self =
							  newdb( "localhost", "ptminfo", "root", "1234" );
							dosql( $self,
"delete from ptmdetails where pmid = $each_pmid and sentence_id = $sen_map_id"
							);

							
							my $sentences =
							  $sentences_init[ ${$sen_have_trigger_ids_ref}[$i]
							  ];
							$sentences =~ s/'/''/g;

							
							my $substrate_value = join( '', @substrate );
							$substrate_value =~ s/\(//g;
							$substrate_value =~ s/\)//g;
							my $kinase_value = join( '', @kinase );
							$kinase_value =~ s/\(//g;
							$kinase_value =~ s/\)//g;
							my $site_value = join( '', @site );
							$site_value =~ s/\(//g;
							$site_value =~ s/\)//g;
							dosql( $self,
"insert  ptmdetails (pmid,sentence_id,substrate,kinase,site,text_evidence,ptm_type,crosstalk) VALUES ($each_pmid,$sen_map_id,'$substrate_value','$kinase_value','$site_value','$sentences','$ptm_name','@crosstalk')"
							);
						};
					}

				}

				$sen_str = '';    # clear the string
			}

			$sen_str .= $_;
		}
		close DEP;
	}
}

sub ie_myristoylation {
	my ( $suffix, $fname, $each_pmid, $sentences_ref, $sen_have_trigger_ids_ref,
		$map_rule_ref, $flag_sid )
	  = @_;
	my @sentences_init = @{$sentences_ref};
	my $ptm_name       = "Myristoylation";

	
	my $origin_text = '';
	for ( my $i = 0 ; $i < @sentences_init ; $i++ ) {
		$origin_text .= $sentences_init[$i];
	}
	eval {    
		     
		my $self = newdb( "localhost", "ptminfo", "root", "1234" );

		$rows =
		  dosql( $self, "select * from ptmtext where pmid = '$each_pmid'" );
		if ( $rows eq '0E0' ) {

			
			$origin_text =~ s/'/''/g;

			
			$origin_text =~ s/\(//g;
			$origin_text =~ s/\)//g;
			my $disease_text   = get_disease_text($origin_text);
			my $organisms_text = get_organisms($origin_text);
			my $goterms        = get_goterms($origin_text);
			my $title = get_title($organisms_text);
			dosql( $self,
"INSERT  ptmtext (pmid,origin_text,disease_text,organisms_text,ptm_type,goterms,title) VALUES ($each_pmid,'$origin_text','$disease_text','$organisms_text','$ptm_name','$goterms','$title')"
			);
		}
	};

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
						eval { 
							   
							my $self =
							  newdb( "localhost", "ptminfo", "root", "1234" );
							dosql( $self,
"delete from ptmdetails where pmid = $each_pmid and sentence_id = $sen_map_id"
							);

							
							$sentences =~ s/'/''/g;

							
							my $substrate_value = join( '', @substrate );
							$substrate_value =~ s/\(//g;
							$substrate_value =~ s/\)//g;
							my $kinase_value = join( '', @kinase );
							$kinase_value =~ s/\(//g;
							$kinase_value =~ s/\)//g;
							my $site_value = join( '', @site );
							$site_value =~ s/\(//g;
							$site_value =~ s/\)//g;
							dosql( $self,
"insert  ptmdetails (pmid,sentence_id,substrate,kinase,site,text_evidence,ptm_type,crosstalk) VALUES ($each_pmid,$sen_map_id,'$substrate_value','$kinase_value','$site_value','$sentences','$ptm_name','@crosstalk')"
							);
						};
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

	
	my $origin_text = '';
	for ( my $i = 0 ; $i < @sentences_init ; $i++ ) {
		$origin_text .= $sentences_init[$i];
	}
	eval {    
		     
		my $self = newdb( "localhost", "ptminfo", "root", "1234" );

		$rows =
		  dosql( $self, "select * from ptmtext where pmid = '$each_pmid'" );
		if ( $rows eq '0E0' ) {

			
			$origin_text =~ s/'/''/g;

			
			$origin_text =~ s/\(//g;
			$origin_text =~ s/\)//g;
			my $disease_text   = get_disease_text($origin_text);
			my $organisms_text = get_organisms($origin_text);
			my $goterms        = get_goterms($origin_text);
			my $title = get_title($organisms_text);
			dosql( $self,
"INSERT  ptmtext (pmid,origin_text,disease_text,organisms_text,ptm_type,goterms,title) VALUES ($each_pmid,'$origin_text','$disease_text','$organisms_text','$ptm_name','$goterms','$title')"
			);
		}
	};

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
						eval { 
							    
							my $self =
							  newdb( "localhost", "ptminfo", "root", "1234" );
							dosql( $self,
"delete from ptmdetails where pmid = $each_pmid and sentence_id = $sen_map_id"
							);

							
							my $sentences =
							  $sentences_init[ ${$sen_have_trigger_ids_ref}[$i]
							  ];
							$sentences =~ s/'/''/g;

							
							my $substrate_value = join( '', @substrate );
							$substrate_value =~ s/\(//g;
							$substrate_value =~ s/\)//g;
							my $kinase_value = join( '', @kinase );
							$kinase_value =~ s/\(//g;
							$kinase_value =~ s/\)//g;
							my $site_value = join( '', @site );
							$site_value =~ s/\(//g;
							$site_value =~ s/\)//g;
							dosql( $self,
"insert  ptmdetails (pmid,sentence_id,substrate,kinase,site,text_evidence,ptm_type,crosstalk) VALUES ($each_pmid,$sen_map_id,'$substrate_value','$kinase_value','$site_value','$sentences','$ptm_name','@crosstalk')"
							);
						};
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

	
	my $origin_text = '';
	for ( my $i = 0 ; $i < @sentences_init ; $i++ ) {
		$origin_text .= $sentences_init[$i];
	}
	eval {   
		      
		my $self = newdb( "localhost", "ptminfo", "root", "1234" );

		$rows =
		  dosql( $self, "select * from ptmtext where pmid = '$each_pmid'" );
		if ( $rows eq '0E0' ) {

			
			$origin_text =~ s/'/''/g;

			
			$origin_text =~ s/\(//g;
			$origin_text =~ s/\)//g;
			my $disease_text   = get_disease_text($origin_text);
			my $organisms_text = get_organisms($origin_text);
			my $goterms        = get_goterms($origin_text);
			my $title = get_title($organisms_text);
			dosql( $self,
"INSERT  ptmtext (pmid,origin_text,disease_text,organisms_text,ptm_type,goterms,title) VALUES ($each_pmid,'$origin_text','$disease_text','$organisms_text','$ptm_name','$goterms','$title')"
			);
		}
	};

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
						eval {
							    
							my $self =
							  newdb( "localhost", "ptminfo", "root", "1234" );
							dosql( $self,
"delete from ptmdetails where pmid = $each_pmid and sentence_id = $sen_map_id"
							);

							
							my $sentences =
							  $sentences_init[ ${$sen_have_trigger_ids_ref}[$i]
							  ];
							$sentences =~ s/'/''/g;

							
							my $substrate_value = join( '', @substrate );
							$substrate_value =~ s/\(//g;
							$substrate_value =~ s/\)//g;
							my $kinase_value = join( '', @kinase );
							$kinase_value =~ s/\(//g;
							$kinase_value =~ s/\)//g;
							my $site_value = join( '', @site );
							$site_value =~ s/\(//g;
							$site_value =~ s/\)//g;
							dosql( $self,
"insert  ptmdetails (pmid,sentence_id,substrate,kinase,site,text_evidence,ptm_type,crosstalk) VALUES ($each_pmid,$sen_map_id,'$substrate_value','$kinase_value','$site_value','$sentences','$ptm_name','@crosstalk')"
							);
						};
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

	
	my $origin_text = '';
	for ( my $i = 0 ; $i < @sentences_init ; $i++ ) {
		$origin_text .= $sentences_init[$i];
	}
	eval {    
		      
		my $self = newdb( "localhost", "ptminfo", "root", "1234" );

		$rows =
		  dosql( $self, "select * from ptmtext where pmid = '$each_pmid'" );
		if ( $rows eq '0E0' ) {

			
			$origin_text =~ s/'/''/g;

			
			$origin_text =~ s/\(//g;
			$origin_text =~ s/\)//g;
			my $disease_text   = get_disease_text($origin_text);
			my $organisms_text = get_organisms($origin_text);
			my $goterms        = get_goterms($origin_text);
			my $title = get_title($organisms_text);
			dosql( $self,
"INSERT  ptmtext (pmid,origin_text,disease_text,organisms_text,ptm_type,goterms,title) VALUES ($each_pmid,'$origin_text','$disease_text','$organisms_text','$ptm_name','$goterms','$title')"
			);
		}
	};

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
						eval { 
							    
							my $self =
							  newdb( "localhost", "ptminfo", "root", "1234" );
							dosql( $self,
"delete from ptmdetails where pmid = $each_pmid and sentence_id = $sen_map_id"
							);

							
							my $sentences =
							  $sentences_init[ ${$sen_have_trigger_ids_ref}[$i]
							  ];
							$sentences =~ s/'/''/g;

							
							my $substrate_value = join( '', @substrate );
							$substrate_value =~ s/\(//g;
							$substrate_value =~ s/\)//g;
							my $kinase_value = join( '', @kinase );
							$kinase_value =~ s/\(//g;
							$kinase_value =~ s/\)//g;
							my $site_value = join( '', @site );
							$site_value =~ s/\(//g;
							$site_value =~ s/\)//g;
							dosql( $self,
"insert  ptmdetails (pmid,sentence_id,substrate,kinase,site,text_evidence,ptm_type,crosstalk) VALUES ($each_pmid,$sen_map_id,'$substrate_value','$kinase_value','$site_value','$sentences','$ptm_name','@crosstalk')"
							);
						};
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

	
	my $origin_text = '';
	for ( my $i = 0 ; $i < @sentences_init ; $i++ ) {
		$origin_text .= $sentences_init[$i];
	}
	eval {   
		      
		my $self = newdb( "localhost", "ptminfo", "root", "1234" );

		$rows =
		  dosql( $self, "select * from ptmtext where pmid = '$each_pmid'" );
		if ( $rows eq '0E0' ) {

			
			$origin_text =~ s/'/''/g;

			
			$origin_text =~ s/\(//g;
			$origin_text =~ s/\)//g;
			my $disease_text   = get_disease_text($origin_text);
			my $organisms_text = get_organisms($origin_text);
			my $goterms        = get_goterms($origin_text);
			my $title = get_title($organisms_text);
			dosql( $self,
"INSERT  ptmtext (pmid,origin_text,disease_text,organisms_text,ptm_type,goterms,title) VALUES ($each_pmid,'$origin_text','$disease_text','$organisms_text','$ptm_name','$goterms','$title')"
			);
		}
	};

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
						eval { 
							    
							my $self =
							  newdb( "localhost", "ptminfo", "root", "1234" );
							dosql( $self,
"delete from ptmdetails where pmid = $each_pmid and sentence_id = $sen_map_id"
							);

							
							my $sentences =
							  $sentences_init[ ${$sen_have_trigger_ids_ref}[$i]
							  ];
							$sentences =~ s/'/''/g;

							
							my $substrate_value = join( '', @substrate );
							$substrate_value =~ s/\(//g;
							$substrate_value =~ s/\)//g;
							my $kinase_value = join( '', @kinase );
							$kinase_value =~ s/\(//g;
							$kinase_value =~ s/\)//g;
							my $site_value = join( '', @site );
							$site_value =~ s/\(//g;
							$site_value =~ s/\)//g;
							dosql( $self,
"insert  ptmdetails (pmid,sentence_id,substrate,kinase,site,text_evidence,ptm_type,crosstalk) VALUES ($each_pmid,$sen_map_id,'$substrate_value','$kinase_value','$site_value','$sentences','$ptm_name','@crosstalk')"
							);
						};
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
	my $cgi = shift;    # recieve value from main

	my $radio = $cgi->param('radio');       # recieve radio's value from browser
	my $pmids = $cgi->param('sequences');   # recieve pmids' value from browser
	my $filename =
	  $cgi->param('fileUpload');            # recieve the file name from brower
	my $fh = $cgi->upload('fileUpload');  # recieve the file handle from browser
	my $texts  = $cgi->param('texts');      # recieve texts' value from browser
	my $search = $cgi->param('searchkeys'); # recieve search' value from browser
	my $time   = $cgi->param('time');       # recieve search' value from browser
	my $disease =
	  $cgi->param('disease');             # recieve search' value from browser
	my $selectptm =
	  $cgi->param('selectptm');             # recieve search' value from browser
	                                        #search process
	$pageindex =
	  $cgi->param('pageindex');             
	                                        
	$isfirst = $cgi->param('isfirst'); 
	if ( ( $radio eq 'radio_search' ) && $search ) {

		$search_ptmtype = $selectptm;
		$search_target = $search."_".$disease."_".$time;
	

		my $searchtarget = lc($selectptm."_".$search."_".$disease."_".$time);

		#search table searchrecord    
		      
		my $self = newdb( "localhost", "ptminfo", "root", "1234" );
		$rows =
		  dosql( $self, "SELECT searchtarget FROM resultcache WHERE LOWER(searchtarget) = '$searchtarget'" );
		if ( $rows eq '0E0' ) {
					 @all_pmids_result =
		  keyWordsRetrievalPubmed( $search, $selectptm, $disease, $time );
		  $all_pmids_result_len = @all_pmids_result;
		 @all_pmids_result_2014 =
		  keyWordsRetrievalPubmed( $search, $selectptm,$disease,'2014' );
	#	my @all_pmids_search = search_pmid(@all_pmids_result);
	#	@all_pmids_search = search_pmid_record(@all_pmids_search);
		my @refs = search_pmid(@all_pmids_result);
		
				my @all_pmids_search = @{$refs[0]};
				 @pmid_has_info = @{$refs[1]};
			#	my @pmid_has_pub_info = search_pmid_record(@all_pmids_search);
			my @pmid_has_pub_info = search_pmid_record(@all_pmids_result_2014);
				push(@pmid_has_info,@pmid_has_pub_info);
				#@all_pmids_result = @pmid_has_info;
				my $pmid_has_info_str = join(',',@pmid_has_info);
				my $time = file_suffix();
		dosql( $self,
"INSERT  resultcache (searchtarget,all_pmids_len,pmids_res,time) VALUES ('$searchtarget','$all_pmids_result_len','$pmid_has_info_str','$time')"
			);
		# call pubmed API to download the file that formated in MEDLINE form
		my $suffix = call_pubmed(@pmid_has_pub_info); # return unique file suffix
		if ( $suffix != 0 ) {

			# process the auto-download pubmed file
			deal_pubmed($suffix);

			# start parsing
			foreach my $each_pmid (@pmid_has_pub_info) {
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
					flock( EACH, 8 );
					close EACH;
				}

				# call lingpipe sub function
				my ( $fname, $sentences_ref, $sen_have_trigger_ids_ref,
					$sen_have_triggers_ref, $map_rule_ref )
				  = lingpipe($pmid_suffix);
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
			insert_recordpmid(@pmid_has_pub_info);
		}

		}else{
			 my @result = query_resultcache( $self,
				"SELECT * FROM resultcache WHERE LOWER(searchtarget) = '$searchtarget'" );
				      $all_pmids_result_len = $result[0][1];
				    my $pmid_has_info_str = $result[0][2];
				     @pmid_has_info = split(',',$pmid_has_info_str);			  		
		}

		
		
		
		
		
		
		
		
		
		
		


		
	}
	if ( $radio eq 'radio_pmid' && ( $pmids || defined $fh ) ) {

	  # deal with the uploaded file (if file uploaded, file was first proceeded)
		if ( defined $fh ) {
			my $file_type =
			  $cgi->uploadInfo($filename)->{'Content-Type'}; # get the MIME type
			unless ( $file_type eq 'text/plain' ) {
				print "<p><em>ERROR: PLAIN FILES ONLY!</em></p>"
				  ;    # die if not a plain file
			}
			else {
				my $io_handle = $fh->handle
				  ;    # upgrade the handle to one compatible with IO::Handle
				my $file;
				while ( my $bytesread = $io_handle->read( my $buffer, 1024 ) ) {
					$file .=
					  $buffer;    # read all the uploaded file to a whole string
				}
				@all_pmids_result = split_pmid($file);
			}
		}

		# deal with the sequences
		elsif ($pmids) {
			@all_pmids_result = split_pmid($pmids);
		}

		# judge the total number of @all_pmids array
		
	#	my @all_pmids_search = search_pmid(@all_pmids_result);
	#	@all_pmids_search = search_pmid_record(@all_pmids_search);
		  $all_pmids_result_len = @all_pmids_result;
			my @refs = search_pmid(@all_pmids_result);
		
				my @all_pmids_search = @{$refs[0]};
				 @pmid_has_info = @{$refs[1]};
				my @pmid_has_pub_info = search_pmid_record(@all_pmids_search);
				push(@pmid_has_info,@pmid_has_pub_info);

		# call pubmed API to download the file that formated in MEDLINE form
		my $suffix = call_pubmed(@pmid_has_pub_info); # return unique file suffix
		if ( $suffix != 0 ) {

			# process the auto-download pubmed file
			deal_pubmed($suffix);

			# start parsing
			foreach my $each_pmid (@pmid_has_pub_info) {
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
					flock( EACH, 8 );
					close EACH;
				}

				# call lingpipe sub function
				my ( $fname, $sentences_ref, $sen_have_trigger_ids_ref,
					$sen_have_triggers_ref, $map_rule_ref )
				  = lingpipe($pmid_suffix);
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
			insert_recordpmid(@pmid_has_pub_info);
		
		}
		 $search_ptmtype = '12';
	}

	if ( $radio eq 'radio_text' && $texts ) {
		$texts =~ s/\s+/ /mg;    # replace mutiple spaces to an only space

		# delete possible citations
		$texts =~ s/ [\(|\[][A-Z][a-z]+?,?.+?\(\d+\).+?,? \d+-\d+[\)|\]]//g;
		$texts =~ s/ [\(|\[][A-Z][a-z]+? .+?, \d+?[\)|\]]//g;

		# save uploaded texts into a unique file
		my ( $suffix, $texts_suffix, $file_name );
		$suffix       = file_suffix();
		$texts_suffix = 'text_' . ${suffix} . '.txt';
		$file_name    = "../files/init_file/" . $texts_suffix;
		my $each_pmid = '000000';
		$all_pmids_result_len =1;
		$isfirst = 0;
		@pmid_has_info = ('0');
		eval {    
			      
			my $self = newdb( "localhost", "ptminfo", "root", "1234" );
			dosql( $self, "DELETE FROM ptmdetails WHERE pmid ='0'" );
			dosql( $self, "DELETE FROM ptmtext WHERE pmid ='0'" );
		};

		# lock the file
		open TEXT, '>', $file_name
		  or die "Can't open text file for write: $!";
		flock( TEXT, 2 ) or die;    # lock file to write
		print TEXT $texts;
		flock( TEXT, 8 ) or die;    # unlock file
		close TEXT;

		# call lingpipe sub function
		my ( $fname, $sentences_ref, $sen_have_trigger_ids_ref,
			$sen_have_triggers_ref, $map_rule_ref )
		  = lingpipe($texts_suffix);
		my @sentences            = @{$sentences_ref};
		my @sen_have_trigger_ids = @{$sen_have_trigger_ids_ref};
		my @sen_have_triggers    = @{$sen_have_triggers_ref};

		# call stanford_parser sub function
		if ( @sen_have_trigger_ids && @sen_have_triggers ) {
			standford_parser($fname);    # stanford_parser parsing
		}

		# information extraction
		#chose PTM process
		my %ptm_hash;
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
			if ( $iterms =~ /anchor|GPI|glycosylphosphatidylinositol/i ) {
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
		my $max_trigger_value = ( sort { $b <=> $a } values %triggers_hash )[0];
		while ( ( $Key, $Value ) = each(%triggers_hash) ) {
			if ( $Value == $max_trigger_value ) {
				$max_trigger = $Key;
			}
		}
		if ( $max_trigger eq 'phosphorylation' ) {
			$ptm_hash{"Phosphorylation"} = 1;
			ie_phospho( $suffix, $fname, $each_pmid, $sentences_ref,
				$sen_have_trigger_ids_ref, $map_rule_ref );
		}
		elsif ( $max_trigger eq 'methylation' ) {
			$ptm_hash{"Methylation"} = 2;
			ie_methylation( $suffix, $fname, $each_pmid, $sentences_ref,
				$sen_have_trigger_ids_ref, $map_rule_ref );
		}
		elsif ( $max_trigger eq 'glycosylation' ) {
			$ptm_hash{"Glycosylation"} = 3;
			ie_glycosylation( $suffix, $fname, '', $sentences_ref,
				$sen_have_trigger_ids_ref, $map_rule_ref );
		}
		elsif ( $max_trigger eq 'acetylation' ) {
			$ptm_hash{"Acetylation"} = 4;
			ie_acetylation( $suffix, $fname, '', $sentences_ref,
				$sen_have_trigger_ids_ref, $map_rule_ref );
		}
		elsif ( $max_trigger eq 'amidation' ) {
			$ptm_hash{"Amidation"} = 5;
			ie_amidation( $suffix, $fname, '', $sentences_ref,
				$sen_have_trigger_ids_ref, $map_rule_ref );
		}
		elsif ( $max_trigger eq 'hydroxylation' ) {
			$ptm_hash{"Hydroxylation"} = 6;
			ie_hydroxylation( $suffix, $fname, '', $sentences_ref,
				$sen_have_trigger_ids_ref, $map_rule_ref );
		}
		elsif ( $max_trigger eq 'myristoylation' ) {
			$ptm_hash{"Myristoylation"} = 7;
			ie_myristoylation( $suffix, $fname, '', $sentences_ref,
				$sen_have_trigger_ids_ref, $map_rule_ref );
		}
		elsif ( $max_trigger eq 'sulfation' ) {
			$ptm_hash{"Sulfation"} = 8;
			ie_sulfation( $suffix, $fname, '', $sentences_ref,
				$sen_have_trigger_ids_ref, $map_rule_ref );
		}
		elsif ( $max_trigger eq 'gpi_anchor' ) {
			$ptm_hash{"GPI-Anchor"} = 9;
			ie_anchor( $suffix, $fname, '', $sentences_ref,
				$sen_have_trigger_ids_ref, $map_rule_ref );
		}
		elsif ( $max_trigger eq 'disulfide' ) {
			$ptm_hash{"Disulfide"} = 10;
			ie_disulfide( $suffix, $fname, '', $sentences_ref,
				$sen_have_trigger_ids_ref, $map_rule_ref );
		}
		elsif ( $max_trigger eq 'ubiquitination' ) {
			$ptm_hash{"Ubiquitination"} = 11;
			ie_ubiquitination( $suffix, $fname, '', $sentences_ref,
				$sen_have_trigger_ids_ref, $map_rule_ref );
		}
$search_ptmtype = '12';

	}

}

sub main {

	chdir("/home/bmi/wwwroot/mptm/cgi-bin/");

	#chdir("/var/www/mptm/cgi-bin/");
	my $cgi = CGI->new;
	preprocess($cgi);
}

sub print_main_HTML {
	print <<HTML;
Content-type: text/html;

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Results</title>
<link rel="shortcut icon" href="../images/icon.png" type="image/x-icon" />
<link href="../css/default.css" rel="stylesheet" type="text/css" />
<link href="../css/results.css" rel="stylesheet" type="text/css" />
<link href="../jquery-ui/jquery-ui.css" rel="stylesheet">
<script src="../jquery-ui/jquery-1.11.1.min.js"></script>
<script src="../javascript/bar.js" type="text/javascript"></script>
<script src="../javascript/mptmdb_sort.js" type="text/javascript"></script>
<script src="../javascript/validate.js" type="text/javascript"></script>
<script src="../javascript/pmidsearch.js" type="text/javascript"></script>
<script type="text/javascript">
\$(document).ready(function(){
	\$('#roll').hide();
	\$(window).scroll(function() {
		if(\$(window).scrollTop() >= 100){
			\$('#roll').fadeIn(400);
    }
    else
    {
    \$('#roll').fadeOut(200);
    }
  });
  \$('#roll_top').click(function(){\$('html,body').animate({scrollTop: '0px'}, 800);});
  \$('#roll_bottom').click(function(){\$('html,body').animate({scrollTop:\$('#bottombox').offset().top}, 800);});
});
</script>
<script type="text/javascript">
function mouseOver(obj){
if(obj.className="css1")
   obj.className="css2";
}
function mouseOut(obj){
if(obj.className="css2")
   obj.className="css1";
}
</script>

    <script type="text/javascript">
        function blackview(){
            \$('.mask').css({'display': 'block'});
        }
    </script>
	
    <script type="text/javascript">
        function change_pmid(){
            var imgObj = document.getElementById("quickview_pmid");
            var Flag=(imgObj.getAttribute("src",2)=="../images/sort_a.png")
            imgObj.src=Flag?"../images/sort_d.png":"../images/sort_a.png";
        }
        function change_date(){
            var imgObj = document.getElementById("quickview_date");
            var Flag=(imgObj.getAttribute("src",2)=="../images/sort_a.png")
            imgObj.src=Flag?"../images/sort_d.png":"../images/sort_a.png";
        }
        function change_ptmtype(){
            var imgObj = document.getElementById("quickview_ptm_type");
            var Flag=(imgObj.getAttribute("src",2)=="../images/sort_a.png")
            imgObj.src=Flag?"../images/sort_d.png":"../images/sort_a.png";
        }
    </script>
	
<script type="text/javascript">
\$(document).ready(function() {
    \$('.show_loading').click(function() {       
        \$('.mask').css({'display': 'block'});
        center(\$('.mess'));
        check(\$(this).parent(), \$('.btn1'), \$('.btn2'));
    });
    // 居中
    function center(obj) {
       
        var screenWidth = \$(window).width(), screenHeight = \$(window).height();  //当前浏览器窗口的 宽高
        var scrolltop = \$(document).scrollTop();//获取当前窗口距离页面顶部高度
   
        var objLeft = (screenWidth - obj.width())/2 ;
        var objTop = (screenHeight - obj.height())/2 + scrolltop;

        obj.css({left: objLeft + 'px', top: objTop + 'px','display': 'block'});
        //浏览器窗口大小改变时
        \$(window).resize(function() {
            screenWidth = \$(window).width();
            screenHeight = \$(window).height();
            scrolltop = \$(document).scrollTop();
           
            objLeft = (screenWidth - obj.width())/2 ;
            objTop = (screenHeight - obj.height())/2 + scrolltop;
           
            obj.css({left: objLeft + 'px', top: objTop + 'px','display': 'block'});
           
        });
        //浏览器有滚动条时的操作、
        \$(window).scroll(function() {
            screenWidth = \$(window).width();
            screenHeight = \$(window).height();
            scrolltop = \$(document).scrollTop();
           
            objLeft = (screenWidth - obj.width())/2 ;
            objTop = (screenHeight - obj.height())/2 + scrolltop;
           
            obj.css({left: objLeft + 'px', top: objTop + 'px','display': 'block'});
        });
       
    }
   
});
</script>
</head>
<body>
<div class="mask"></div>
<div class="mess">
         <p><img src="../images/loading.gif" height="50px" width="70px"/></p>
         <p>Running MPTM......</p>
		 <p>It may take few minutes !</p>
</div>
<div class="container">	
<div class="nav">
	<div class="navigation">
        <ul class="MenuBar">
        <li><img src="../images/LOGO.png" /></li>
        <li><a href="../index.html">Web Server</a></li>
        <li><a href="../ptmdb.html">MPTMDB</a></li>
        <li><a href="../network.html">Network</a></li>
        <li><a href="../download.html">Download</a></li>
        <li><a href="../tutorial.html">Tutorial</a></li>
        </ul>
		<div class="clear"></div><!--清除格式-->
	</div>   <!-- end .navigation -->
</div><!-- end .nav -->
<div class="clear"></div>
HTML

print_result($search_ptmtype,$search_target,$all_pmids_result_len,$pageindex,$isfirst,@pmid_has_info);

print <<HTML;
			<div class="clear"></div>
			<div id="changpage"></div>
			</div><!--end container-->

<script src="../jquery-ui/external/jquery/jquery.js"></script>
<script src="../jquery-ui/jquery-ui.js"></script>
<script>
	\$( "#tabs" ).tabs();
	\$(".dialog").dialog({
		autoOpen:false,
		width:600,
		height:500,
	});
	\$(".dialog-link").click(function(event){
		var i = \$(".dialog-link").index(this);
		\$(".dialog").eq(i).dialog("open");
		event.preventDefault();
	});
	\$(document).ready(function(){
	\$(".btn").click(function(){	
		\$(this).next().slideToggle();	
	});
	\$(".show-disease").click(function(){	
		\$(this).next().slideToggle();	
	});
});
</script>


<script>
    \$(".ui-button").click(
    function(){
        \$('.mask').css({'display': 'none'});
    });

</script>

<script type="text/javascript">

    \$(".c_kinase").click(function(){
	if(\$(this).is(':checked')){
		\$(this).closest(".det").children('.kinase').css({'color': '#00F'});}
	else{
		\$(this).closest(".det").children('.kinase').css({'color': '#000'});}
	});

	
    \$(".c_substrate").click(function(){
	
		if ( \$(this).is(':checked')){
		\$(this).closest(".det").children('.substrate').css({'color': '#F00'});}
		else{
		\$(this).closest(".det").children('.substrate').css({'color': '#000'});}
    });
	
    \$(".c_site").click(
    function(){
		if( \$(this).is(':checked')){
			\$(this).closest(".det").children('.site').css({'color': '#0F0'});
		}
		else{
			\$(this).closest(".det").children('.site').css({'color': '#000'});
		}
    });
	
    \$(".c_organisms").click(
    function(){
		if ( \$(this).is(':checked')){
			\$(this).closest(".det").children('.species').css({'color':'#339999'});
		}
		else{
			\$(this).closest(".det").children('.species').css({'color':'#000'});
		}
    });
	
    \$(".c_crosstalk").click(
    function(){
		if ( \$(this).is(':checked')){
			\$(this).closest(".det").children('.crosstalk').css({'color':'#ff3399'});
		}
		else{
			\$(this).closest(".det").children('.crosstalk').css({'color':'#000'});
		}
    });
	
    \$(".c_disease_evidence").click(
    function(){
		if ( \$(this).is(':checked')){
			\$(this).closest(".det").children('.disevidence').css({'color':'#FF00FF'});
		}else{
			\$(this).closest(".det").children('.disevidence').css({'color':'#000'});
		}
    });
	
    \$(".c_goterms").click(
    function(){
		if ( \$(this).is(':checked')){
			\$(this).closest(".det").children('.goterms').css({'color':'#99cc33'});
		}else{
			\$(this).closest(".det").children('.goterms').css({'color':'#000'});
		}
    });	
</script>


<script type="text/javascript">
    var otable2=document.getElementsByClassName("view1");
    if (otable2.rows.length>=6){
        \$(".dialog").dialog({
            autoOpen:false,
            width:600,
            height:438,
        });
    }

    if(otable2.rows.length<6){
        \$(".dialog").dialog({
            autoOpen: false,
            width: 980,
        });
    };

</script>

<script type="text/javascript">
    ospan=document.getElementById("ui-id-27");
    if(!ospan){
		ospan=document.getElementById("ui-id-24");
		if (!ospan){
			ospan=document.getElementById("ui-id-8");
		}
	}
	ospan.parentNode.style.backgroundColor="#ea5302";
	

</script>

<script type="text/javascript">
    /*分页*/
    var obj,j;
    var page=0;
    var nowPage=0;//当前页
    var listNum=17;//每页显示<ul>数
    var PagesLen;//总页数
    var PageNum=4;//分页链接接数(5个)
    onload=function(){
        obj=document.getElementById("quick_view").getElementsByTagName("tr");
        j=obj.length;
        PagesLen=Math.ceil(j/listNum);
        upPage(0);
    }
    function upPage(p){
        nowPage=p//内容变换
        for (var i=1;i<j;i++){
            obj[i].style.display="none"
        }
        for (var i=p*listNum;i<(p+1)*listNum;i++){
            if(obj[i])obj[i].style.display="table-row";
        }
        //分页链接变换
        strS='<p><a href="###" onclick="upPage(0)">First</a>  '
        var PageNum_2=PageNum%2==0?Math.ceil(PageNum/2)+1:Math.ceil(PageNum/2);
        var PageNum_3=PageNum%2==0?Math.ceil(PageNum/2):Math.ceil(PageNum/2)+1;
        var strC="",startPage,endPage;
        if (PageNum>=PagesLen){
            startPage=0;
            endPage=PagesLen-1;
        }
        else if (nowPage<PageNum_2){
            startPage=0;
            endPage=PagesLen-1>PageNum?PageNum:PagesLen-1;
        }//
        else {
            startPage=nowPage+PageNum_3>=PagesLen?PagesLen-PageNum-1: nowPage-PageNum_2+1;
            var t=startPage+PageNum;endPage=t>PagesLen?PagesLen-1:t;
        }
        for (var i=startPage;i<=endPage;i++){
            if (i==nowPage)
                strC+='<a href="###" style="color:black;font-weight:700;" onclick="upPage('+i+')">'+(i+1)+'</a>';
            else
                strC+='<a href="###" onclick="upPage('+i+')">'+(i+1)+'</a> ';
        }
        strE=' <a href="###" onclick="upPage('+(PagesLen-1)+')">Last</a>  ';
        /*strE2=nowPage+1+"/"+PagesLen+"页"+"  共"+j+"条"+"</p>";*/
        document.getElementById("changpage").innerHTML=strS+strC+strE;/*+strE2;*/
    }
</script>
<div id="roll"><div title="Top" id="roll_top"></div></div> 
    <div id="footer">
      <p class="copyright">&copy;&nbsp;&nbsp;2014 All Rights Reserved &nbsp;&bull;&nbsp; Design by <a href="http://bioinformatics.ustc.edu.cn/">HI_lab</a> @ <a href="http://ustc.edu.cn/">USTC</a>.</p>
    </div>
</body>
</html>
HTML

}
my @pmid_has_info;
my @all_pmids_result;
my $search_ptmtype;
my $search_target;
my $all_pmids_result_len;
my $pageindex;
my $isfirst;
main();
print_main_HTML();
