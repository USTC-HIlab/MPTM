sub paging {
	my @pmids    = @_;
	my $pmid_str = '';
	my @page_arr;
	my $j = 0;
	for ( my $i = 0 ; $i < @pmids ; $i++ ) {
		$pmid_str .= $pmids[$i] . ",";
		if ( ( $i + 1 ) % 10 == 0 ) {
			$page_arr[$j] = $pmid_str;
			$j++;
			$pmid_str = '';
		}
	}
	if ($pmid_str) {
		$page_arr[$j] = $pmid_str;
	}
	return @page_arr;
}

sub search_from_go_terms {
	my $goname = shift;
	my $self = newdb( "localhost", "ptminfo", "root", "1234" );
	my @result_go_terms =
	  query_goterms( $self, "select * from go_terms where goname = '$goname'" );
	my $goid   = $result_go_terms[0][0];
	my $gotype = $result_go_terms[0][2];
	return $goid, $gotype;
}

sub file_suffix {
	my $time = time;
	my $rand = int( rand(1000000) + 1000 );
	my $suffix = $time + $rand; # define a random number appending the file name
	return $suffix;
}

sub save_result {

	my ( $suffix, @save_result ) = @_;
	open RESULT, '>>', "../files/results/${suffix}_results.txt"
	  or die "Can't open a file to write results: $!";
	print RESULT
"PMID\tSentence_ID\tSubstrate(s)\tEnzyme(s)\tSite(s)\tText_Evidence\tPtm_Type\n";
	for ( my $i ; $i < @save_result ; $i++ ) {
		print RESULT
"$save_result[$i][0]\t$save_result[$i][1]\t$save_result[$i][2]\t$save_result[$i][3]\t$save_result[$i][4]\t$save_result[$i][5]\t$save_result[$i][6]\n";
	}
	close(RESULT);
}

sub print_ptm_info {

	#from ptmdatails
	my ( $ptm_type, $search_target, $search_ptmtype, $pageindex, @pmids_all ) =
	  @_;
	if ( $ptm_type ne '12' ) {
		@pmids_all = ( sort { $a <=> $b } @pmids_all );
	}
	#my %num_organism_hash={'9606'=>'Human','9606'=>'Human','9606'=>'Human','9606'=>'Human','9606'=>'Human','9606'=>'Human','9606'=>'Human','9606'=>'Human'};
	my $self = newdb( "localhost", "ptminfo", "root", "1234" );
	my @page_arr = paging(@pmids_all);

	my @pmids = split( ',', $page_arr[ $pageindex - 1 ] );
	my $suffix = file_suffix();
	print <<HTML;
		<div id = "$ptm_type" class="marg1">
HTML

	for ( my $each_pmid = 0 ; $each_pmid < @pmids ; $each_pmid++ ) {
		my @result = query( $self,
			"SELECT * FROM ptmdetails WHERE pmid = '$pmids[$each_pmid]'" );
		my @text_result = query_ptmtext( $self,
			"SELECT * FROM ptmtext WHERE pmid = '$pmids[$each_pmid]'" );

		#gene norm
		my @gene_norm_result = query_genenorm( $self,
			"SELECT * FROM genenorm WHERE pmid = '$pmids[$each_pmid]'" );
		eval { save_result( $suffix, @result ); };

		my $isptm = 1;

#		for ( my $j = 0 ; $j < @result ; $j++ ) {
#			if ( $result[$j][2] ne 'NULL') {class="css1" onmouseover="mouseOver(this)" onmouseout="mouseOut(this)"
#				$isptm = 1;
#				last;
#			}
#		}
		if ($isptm) {

			if ( $pmids[$each_pmid] eq '0' ) {
				print <<HTML;
			<div  class="pmid" colspan="4">Data Mined From Texts</div>
HTML
			}
			else {
				print <<HTML;
			<div  class="pmid" colspan="4"><a href="http://www.ncbi.nlm.nih.gov/pubmed/?term=$pmids[$each_pmid]" target="_blank">Data Mined From PMID: $pmids[$each_pmid]</a>
			</div>
HTML

				print <<HTML;
			<div style="clear:right;"></div>
			<div class="data_pmc">
HTML
				if ( $text_result[0][6] ) {
					my $pmcid = $text_result[0][6];
					print <<HTML;
			<div  class="pmcid" colspan="4">
			<a href="http://www.ncbi.nlm.nih.gov/pmc/articles/?term=$pmcid" target="_blank">Full Text From PMC: $pmcid </a>
			</div>
HTML
				}

				if ( $text_result[0][7] ) {
					my $pubdate = $text_result[0][7];
					$pubdate =~ s/(\d{4})(\d{2})(\d{2})/$1.$2.$3/;
					print <<HTML;
			<div  class="pubdate" colspan="4">
			Published Time: $pubdate
			</div>
HTML
				}
				print <<HTML;
			</div>
HTML



#############################print mined results



#				print <<HTML;
#<table >	
#HTML
			}


			print <<HTML;
<table>
<tr class="caption">
<th>&nbsp;&nbsp;<strong></strong>&nbsp;&nbsp;</th>
<th><strong>Mined Data</strong></th>
<th><strong>Text Evidence</strong></th>
<th><strong>Related Abstracts from PubMed</strong></th>
<th><strong>Related Diseases from OMIM</strong></th>
</tr>
HTML

			my $substrate_all_len = 0;
			my @substrate_all;
			for ( my $j = 0 ; $j < @result ; $j++ ) {

				if ( $result[$j][2] ne 'NULL' ) {
					my @substrate_arr = split( ',', $result[$j][2] );
					for ( my $i = 0 ; $i < @substrate_arr ; $i++ ) {
						$substrate_arr[$i] =~ s/^\s+|\s+$//;    #去除空格
						if ( $substrate_arr[$i] ) {
							push( @substrate_all, $substrate_arr[$i] );
						}
					}
				}
			}
			@substrate_all = remove_duplicate(@substrate_all);
			my %pro_pmid = find_relate_pmid(@substrate_all);

			#return gene mapping uniprotkb_id
			my %mined_uniprotkb_hash = find_mapping_uniprotkb($pmids[$each_pmid],@substrate_all);

			#related sentences
			my %substrate_sen = ();
			for ( my $i = 0 ; $i < @substrate_all ; $i++ ) {
				for ( my $j = 0 ; $j < @result ; $j++ ) {
					if ( $result[$j][5] =~ /\b$substrate_all[$i]\b/ ) {
						$substrate_sen{ $substrate_all[$i] } = $result[$j][5];
					}
				}
			}

			$substrate_all_len = @substrate_all;
			my $self = newdb( "localhost", "ptminfo", "root", "1234" );

			for ( my $i = 0 ; $i < @substrate_all ; $i++ ) {
				
				if ( $i == 0 ) {
					if ($mined_uniprotkb_hash{$substrate_all[$i]} ne '') {
						my $search_uni_str = $mined_uniprotkb_hash{$substrate_all[$i]};
						my @search_uni_arr = split('/',$search_uni_str);
						my $search_uniid = $search_uni_arr[0];
						my $search_uniname = "UniprotKB AC/ID: ".$search_uni_str;
						print <<HTML;
	<tr>
	<th rowspan=$substrate_all_len >Substrate</th>
<td>$substrate_all[$i]&nbsp<a class = "uniprot_link" href="http://www.uniprot.org/uniprot/$search_uniid" target="_blank">UniprotKB: $search_uniid</a></td>
HTML
					}
					else {
						print <<HTML;
	<tr>
	<th rowspan=$substrate_all_len >Substrate</th>
<td>$substrate_all[$i]</td>
HTML
					}
					my @pro_pmid_arr =
					  split( '\.', $pro_pmid{ $substrate_all[$i] } )
					  ;   
					my %pmid_textevidence;
					my $self = newdb( "localhost", "ptminfo", "root", "1234" );
					for ( my $j = 0 ; $j < @pro_pmid_arr ; $j++ ) {
						my @result = query( $self,
"SELECT * FROM ptmdetails WHERE pmid='$pro_pmid_arr[$j]' AND substrate REGEXP '$substrate_all[$i]' AND ptm_type = '$ptm_type'"
						);
						for ( my $k = 0 ; $k < @result ; $k++ ) {
							if ( $result[$k][5] ne 'NULL' ) {
								$pmid_textevidence{ $pro_pmid_arr[$j] } =
								  $result[$k][5];
							}
						}
					}
					my $pmid_textevidence_len = keys %pmid_textevidence;

					
					$substrate_sen{ $substrate_all[$i] } =~
s/(\b$substrate_all[$i]\b)/<span class=\"substrate\">$1<\/span>/g;
					print <<HTML;
					<td >$substrate_sen{$substrate_all[$i]}</td>
<td >
<span>$pmid_textevidence_len</span>
<button class="dialog-link"></button>
<div  class="dialog" title="Pmids List">
<table class="view1">
HTML
					while ( ( $key, $value ) = each %pmid_textevidence ) {
						$value =~
s/(\b$substrate_all[$i]\b)/<span class=\"substrate\">$1<\/span>/g;
						print <<HTML;
	<tr>
	<td><a href="http://bioinformatics.ustc.edu.cn/mptm/cgi-bin/results_original.cgi?radio=radio_pmid&sequences=$key&pageindex=1&isfirst=0" target="_blank">$key</a></td>
	<td>$value</td>
	</tr>
HTML
					}
					%pmid_textevidence = ();   
					print <<HTML;
</table>
</div>
</td>
HTML

					#related disease from OMIM
					my @sub_pro_arr         = $substrate_all[$i];
					my @protein_disease     = get_disease(@sub_pro_arr);
					my $protein_disease_len = @protein_disease;
					print <<HTML;
<td>Disease from OMIM ($protein_disease_len) <img src="../images/plus.jpg" class="show-disease"width="10px" >
		   	 <div class="list" style="display: none;">
		   	 <table border = "0">
HTML

					for ( my $i = 0 ; $i < @protein_disease ; $i++ ) {
						my @protein_disease_arr =
						  split( '_', $protein_disease[$i] );
						my $mim = $protein_disease_arr[1];
						$mim =~ s/MIM=//;
						print <<HTML;
		   	 <tr class="css1" class="css1" onmouseover="mouseOver(this)" onmouseout="mouseOut(this)">
		    <td>$protein_disease_arr[0]  <a href="http://www.omim.org/entry/$mim" target="_blank">$protein_disease_arr[1]</a></td> 
		    </tr>
HTML
					}
					print <<HTML;
</table>
</div>
</td>
</tr>
HTML
				}
				else {
					if ($mined_uniprotkb_hash{$substrate_all[$i]} ne '') {
					my $search_uni_str = $mined_uniprotkb_hash{$substrate_all[$i]};
					my @search_uni_arr = split('/',$search_uni_str);
					my $search_uniid = $search_uni_arr[0];
					my $search_uniname = "UniprotKB AC/ID: ".$search_uni_str;
						print <<HTML;
	<tr>
<td>$substrate_all[$i]&nbsp<a class = "uniprot_link" href="http://www.uniprot.org/uniprot/$search_uniid" target="_blank">UniprotKB: $search_uniid</a></td>
HTML
					
					}
					else {
						print <<HTML;
	<tr>
<td>$substrate_all[$i]</td>
HTML
					}
					my @pro_pmid_arr =
					  split( '\.', $pro_pmid{ $substrate_all[$i] } )
					  ;    
					my %pmid_textevidence;
					my $self = newdb( "localhost", "ptminfo", "root", "1234" );
					for ( my $j = 0 ; $j < @pro_pmid_arr ; $j++ ) {
						my @result = query( $self,
"SELECT * FROM ptmdetails WHERE pmid='$pro_pmid_arr[$j]' AND substrate REGEXP '$substrate_all[$i]' AND ptm_type = '$ptm_type'"
						);
						for ( my $k = 0 ; $k < @result ; $k++ ) {
							if ( $result[$k][5] ne 'NULL' ) {
								$pmid_textevidence{ $pro_pmid_arr[$j] } =
								  $result[$k][5];
							}
						}
					}
					my $pmid_textevidence_len = keys %pmid_textevidence;
					$substrate_sen{ $substrate_all[$i] } =~
s/(\b$substrate_all[$i]\b)/<span class=\"substrate\">$1<\/span>/g;
					print <<HTML;
					<td >$substrate_sen{$substrate_all[$i]}</td>
<td ><span>$pmid_textevidence_len</span>
<button class="dialog-link"></button>
<div  class="dialog" title="Pmids List">
<table class="view1">
HTML
					while ( ( $key, $value ) = each %pmid_textevidence ) {
						$value =~
s/(\b$substrate_all[$i]\b)/<span class=\"substrate\">$1<\/span>/g;
						print <<HTML;
	<tr>
	<td><a href="http://bioinformatics.ustc.edu.cn/mptm/cgi-bin/results_original.cgi?radio=radio_pmid&sequences=$key&pageindex=1&isfirst=0" target="_blank">$key</a></td>
	<td>$value</td>
	</tr>
HTML
					}
					%pmid_textevidence = ();    
					print <<HTML;
</table>
</div>
</td>
HTML

					#related disease from OMIM
					my @sub_pro_arr         = $substrate_all[$i];
					my @protein_disease     = get_disease(@sub_pro_arr);
					my $protein_disease_len = @protein_disease;
					print <<HTML;
<td>Disease from OMIM ($protein_disease_len) <img src="../images/plus.jpg" class= "show-disease" width="10px" >
		   	 <div class="list"  style="display: none;">
		   	 <table border = "0">
HTML

					for ( my $i = 0 ; $i < @protein_disease ; $i++ ) {
						my @protein_disease_arr =
						  split( '_', $protein_disease[$i] );
						my $mim = $protein_disease_arr[1];
						$mim =~ s/MIM=//;
						print <<HTML;
		   	 <tr class="css1" onmouseover="mouseOver(this)" onmouseout="mouseOut(this)">
		    <td>$protein_disease_arr[0]  <a href="http://www.omim.org/entry/$mim" target="_blank">$protein_disease_arr[1]</a></td> 
		    </tr>
HTML
					}
					print <<HTML;
</table>
</div>
</td>
</tr>
HTML
				}

			}

		
			my $kinase_all_len = 0;
			my @kinase_all;
			for ( my $j = 0 ; $j < @result ; $j++ ) {
				if ( $result[$j][3] ne 'NULL' ) {
					my @kinase_arr = split( ',', $result[$j][3] );
					for ( my $i = 0 ; $i < @kinase_arr ; $i++ ) {
						$kinase_arr[$i] =~ s/^\s+|\s+$//;    
						if ( $kinase_arr[$i] ) {
							push( @kinase_all, $kinase_arr[$i] );
						}
					}
				}
			}
			@kinase_all = remove_duplicate(@kinase_all);
			%pro_pmid   = find_relate_pmid(@kinase_all);
			#return gene mapping uniprotkb_id
			 %mined_uniprotkb_hash = find_mapping_uniprotkb($pmids[$each_pmid],@kinase_all);
			
			my %kinase_sen = ();
			for ( my $i = 0 ; $i < @kinase_all ; $i++ ) {
				for ( my $j = 0 ; $j < @result ; $j++ ) {
					if ( $result[$j][5] =~ /$kinase_all[$i]/ ) {
						$kinase_sen{ $kinase_all[$i] } = $result[$j][5];
					}
				}
			}

			$kinase_all_len = @kinase_all;
			for ( my $i = 0 ; $i < @kinase_all ; $i++ ) {

				if ( $i == 0 ) {
	if ($mined_uniprotkb_hash{$kinase_all[$i]} ne '') {
					my $search_uni_str = $mined_uniprotkb_hash{$kinase_all[$i]};
						my @search_uni_arr = split('/',$search_uni_str);
						my $search_uniid = $search_uni_arr[0];
						my $search_uniname = "UniprotKB AC/ID: ".$search_uni_str;
						print <<HTML;
	<tr>
	<th rowspan=$kinase_all_len >Enzyme</th>
<td>$kinase_all[$i]&nbsp<a class = "uniprot_link" href="http://www.uniprot.org/uniprot/$search_uniid" target="_blank">UniprotKB: $search_uniid</a></td>
HTML
					}
					else {
						print <<HTML;
	<tr>
	<th rowspan=$kinase_all_len >Enzyme</th>
<td>$kinase_all[$i]</td>
HTML
					}

					my @pro_pmid_arr =
					  split( '\.', $pro_pmid{ $kinase_all[$i] } )
					  ;    
					my %pmid_textevidence;
					my $self = newdb( "localhost", "ptminfo", "root", "1234" );
					for ( my $j = 0 ; $j < @pro_pmid_arr ; $j++ ) {
						my @result = query( $self,
"SELECT * FROM ptmdetails WHERE pmid='$pro_pmid_arr[$j]' AND kinase REGEXP '$kinase_all[$i]' AND ptm_type='$ptm_type'"
						);
						for ( my $k = 0 ; $k < @result ; $k++ ) {
							if ( $result[$k][5] ne 'NULL' ) {
								$pmid_textevidence{ $pro_pmid_arr[$j] } =
								  $result[$k][5];
							}
						}
					}
					my $pmid_textevidence_len = keys %pmid_textevidence;
					$kinase_sen{ $kinase_all[$i] } =~
s/(\b$kinase_all[$i]\b)/<span class=\"kinase\">$1<\/span>/g;
					print <<HTML;
						<td >$kinase_sen{$kinase_all[$i]}</td>
<td >
<span>$pmid_textevidence_len</span>
<button  class="dialog-link"></button>
<div  class="dialog" title="Pmids List">
<table class="view1">
HTML
					while ( ( $key, $value ) = each %pmid_textevidence ) {
						$value =~
s/(\b$kinase_all[$i]\b)/<span class=\"kinase\">$1<\/span>/g;
						print <<HTML;
	<tr>
	<td><a href="http://bioinformatics.ustc.edu.cn/mptm/cgi-bin/results_original.cgi?radio=radio_pmid&sequences=$key&pageindex=1&isfirst=0" target="_blank">$key</a></td>
	<td>$value</td>
	</tr>
HTML
					}
					%pmid_textevidence = ();   
					print <<HTML;
</table>
</div>
</td>			
HTML

					#related disease from OMIM
					my @kin_pro_arr         = $kinase_all[$i];
					my @protein_disease     = get_disease(@kin_pro_arr);
					my $protein_disease_len = @protein_disease;
					print <<HTML;
<td>Disease from OMIM ($protein_disease_len)<img src="../images/plus.jpg" class="show-disease" width="10px" >
		   	 <div class="list" style="display: none;">
		   	 <table border = "0">
HTML

					for ( my $i = 0 ; $i < @protein_disease ; $i++ ) {
						my @protein_disease_arr =
						  split( '_', $protein_disease[$i] );
						my $mim = $protein_disease_arr[1];
						$mim =~ s/MIM=//;
						print <<HTML;
		   	 		   	 <tr class="css1"  onmouseover="mouseOver(this)" onmouseout="mouseOut(this)">
		    <td>$protein_disease_arr[0]  <a href="http://www.omim.org/entry/$mim" target="_blank">$protein_disease_arr[1]</a></td> 
					  		    </tr>
HTML
					}
					print <<HTML;
	</table>
	</div>
	</td>			
</tr>
HTML
				}
				else {
	if ($mined_uniprotkb_hash{$kinase_all[$i]} ne '') {
			my $search_uni_str = $mined_uniprotkb_hash{$kinase_all[$i]};
			my @search_uni_arr = split('/',$search_uni_str);
			my $search_uniid = $search_uni_arr[0];
			my $search_uniname = "UniprotKB AC/ID: ".$search_uni_str;
						print <<HTML;
	<tr>
<td>$kinase_all[$i]&nbsp<a class = "uniprot_link" href="http://www.uniprot.org/uniprot/$search_uniid" target="_blank">UniprotKB: $search_uniid</a></td>
HTML
					}
					else {
						print <<HTML;
	<tr>
<td>$kinase_all[$i]</td>
HTML
					}
					my @pro_pmid_arr =
					  split( '\.', $pro_pmid{ $kinase_all[$i] } )
					  ;   
					my %pmid_textevidence;
					my $self = newdb( "localhost", "ptminfo", "root", "1234" );
					for ( my $j = 0 ; $j < @pro_pmid_arr ; $j++ ) {
						my @result = query( $self,
"SELECT * FROM ptmdetails WHERE pmid='$pro_pmid_arr[$j]' AND kinase REGEXP '$kinase_all[$i]' AND ptm_type='$ptm_type'"
						);
						for ( my $k = 0 ; $k < @result ; $k++ ) {
							if ( $result[$k][5] ne 'NULL' ) {
								$pmid_textevidence{ $pro_pmid_arr[$j] } =
								  $result[$k][5];
							}
						}
					}
					my $pmid_textevidence_len = keys %pmid_textevidence;
					$kinase_sen{ $kinase_all[$i] } =~
s/(\b$kinase_all[$i]\b)/<span class=\"kinase\">$1<\/span>/g;
					print <<HTML;
<td >$kinase_sen{$kinase_all[$i]}</td>
<td >
<span>$pmid_textevidence_len</span>
<button  class="dialog-link"></button>
<div  class="dialog" title="Pmids List">
<table class="view1">
HTML
					while ( ( $key, $value ) = each %pmid_textevidence ) {
						$value =~
s/(\b$kinase_all[$i]\b)/<span class=\"kinase\">$1<\/span>/g;
						print <<HTML;
	<tr>
	<td><a href="http://bioinformatics.ustc.edu.cn/mptm/cgi-bin/results_original.cgi?radio=radio_pmid&sequences=$key&pageindex=1&isfirst=0" target="_blank">$key</a></td>
	<td>$value</td>
	</tr>
HTML
					}
					%pmid_textevidence = ();    
					print <<HTML;
</table>
</div>
</td>
HTML

					#related disease from OMIM
					my @kin_pro_arr         = $kinase_all[$i];
					my @protein_disease     = get_disease(@kin_pro_arr);
					my $protein_disease_len = @protein_disease;
					print <<HTML;
<td>Disease from OMIM ($protein_disease_len)<img src="../images/plus.jpg" class="show-disease" width="10px" >
		   	 <div class="list" style="display: none;">
		   	 <table border = "0">
HTML
					for ( my $i = 0 ; $i < @protein_disease ; $i++ ) {
						my @protein_disease_arr =
						  split( '_', $protein_disease[$i] );
						my $mim = $protein_disease_arr[1];
						$mim =~ s/MIM=//;
						print <<HTML;
		   	 		   	 <tr class="css1"  onmouseover="mouseOver(this)" onmouseout="mouseOut(this)">
		    <td>$protein_disease_arr[0]  <a href="http://www.omim.org/entry/$mim" target="_blank">$protein_disease_arr[1]</a></td> 
					  		    </tr>
HTML
					}
					print <<HTML;
	</table>
	</div>
	</td>				
	</tr>
HTML
				}
			}

			

			my $site_all_len = 0;
			my @site_all;
			for ( my $j = 0 ; $j < @result ; $j++ ) {

				if ( $result[$j][4] ne 'NULL' ) {
					my @site_arr = split( ',', $result[$j][4] );
					for ( my $i = 0 ; $i < @site_arr ; $i++ ) {
						$site_arr[$i] =~ s/^\s+|\s+$//;   
						if ( $site_arr[$i] ) {
							push( @site_all, $site_arr[$i] );
						}
					}
				}
			}
			@site_all = remove_duplicate(@site_all);
			%pro_pmid = find_relate_pmid(@site_all);
			my %site_sen      = ();
			my @site_simplify = @site_all;
			for ( my $i = 0 ; $i < @site_simplify ; $i++ ) {
				for ( my $j = 0 ; $j < @result ; $j++ ) {
					if ( $site_simplify[$i] =~ /(\d+)/ ) {
						$site_simplify[$i] = $1;
					}
					if ( $result[$j][5] =~ /$site_simplify[$i]/ ) {
						$site_sen{ $site_simplify[$i] } = $result[$j][5];
					}
				}
			}

			$site_all_len = @site_all;
			for ( my $i = 0 ; $i < @site_all ; $i++ ) {
				if ( $i == 0 ) {
					print <<HTML;
		   	<tr>
		   	<th rowspan=$site_all_len >Site</th>
		   <td >$site_all[$i]</td>
HTML
					my @pro_pmid_arr =
					  split( '\.', $pro_pmid{ $site_all[$i] } )
					  ;   
					my %pmid_textevidence;
					my $self = newdb( "localhost", "ptminfo", "root", "1234" );
					for ( my $j = 0 ; $j < @pro_pmid_arr ; $j++ ) {
						my @result = query( $self,
"SELECT * FROM ptmdetails WHERE pmid='$pro_pmid_arr[$j]' AND site REGEXP '[A-Z|a-z|-]$site_all[$i]\$' AND ptm_type='$ptm_type'"
						);
						for ( my $k = 0 ; $k < @result ; $k++ ) {
							if ( $result[$k][5] ne 'NULL' ) {
								$pmid_textevidence{ $pro_pmid_arr[$j] } =
								  $result[$k][5];
							}
						}
					}
					my $pmid_textevidence_len = keys %pmid_textevidence;
					$site_sen{ $site_simplify[$i] } =~
					  s/($site_simplify[$i])/<span class=\"site\">$1<\/span>/g;
					print <<HTML;
							   <td >$site_sen{$site_simplify[$i]}</td>
<td colspan="2">
<span>$pmid_textevidence_len</span>
<button  class="dialog-link"></button>
<div  class="dialog" title="Pmids List">
<table class="view1">
HTML
					while ( ( $key, $value ) = each %pmid_textevidence ) {
						$value =~
s/(\b$site_simplify[$i]\b)/<span class=\"site\">$1<\/span>/g;
						print <<HTML;
	<tr>
	<td><a href="http://localhost/mptm/cgi-bin/results_original.cgi?radio=radio_pmid&sequences=$key&pageindex=1" target="_blank">$key</a></td>
	<td>$value</td>
	</tr>
HTML
					}
					%pmid_textevidence = ();    
					print <<HTML;
</table>
</div>
</td>

		   </tr>
HTML
				}
				else {
					print <<HTML;
		   	<tr>
		   <td >$site_all[$i]</td>
HTML
					my @pro_pmid_arr =
					  split( '\.', $pro_pmid{ $site_all[$i] } )
					  ;   
					my %pmid_textevidence;
					my $self = newdb( "localhost", "ptminfo", "root", "1234" );
					for ( my $j = 0 ; $j < @pro_pmid_arr ; $j++ ) {
						my @result = query( $self,
"SELECT * FROM ptmdetails WHERE pmid='$pro_pmid_arr[$j]' AND site REGEXP '[A-Z|a-z|-]$site_all[$i]\$' AND ptm_type='$ptm_type'"
						);
						for ( my $k = 0 ; $k < @result ; $k++ ) {
							if ( $result[$k][5] ne 'NULL' ) {
								$pmid_textevidence{ $pro_pmid_arr[$j] } =
								  $result[$k][5];
							}
						}
					}
					my $pmid_textevidence_len = keys %pmid_textevidence;

					
					$site_sen{ $site_simplify[$i] } =~
					  s/($site_simplify[$i])/<span class=\"site\">$1<\/span>/g;
					print <<HTML;
							   	<td >$site_sen{$site_simplify[$i]}</td>
<td colspan="2">
<span>$pmid_textevidence_len</span>
<button  class="dialog-link"></button>
<div  class="dialog" title="Pmids List">
<table class="view1">
HTML
					while ( ( $key, $value ) = each %pmid_textevidence ) {
						$value =~
s/(\b$site_simplify[$i]\b)/<span class=\"site\">$1<\/span>/g;
						print <<HTML;
	<tr>
	<td><a href="http://localhost/mptm/cgi-bin/results_original.cgi?radio=radio_pmid&sequences=$key&pageindex=1" target="_blank">$key</a></td>
	<td>$value</td>
	</tr>
HTML
					}
					%pmid_textevidence = ();   
					print <<HTML;
</table>
</div>
</td>

		   </tr>
HTML
				}
			}

			

			#disease_all_text
			my @disease_all_text;
			my $disease_all_text_len = 0;

			#disease from text
			my @disease_evidence_arr = split( '_', $text_result[0][2] );
			for ( my $i = 1 ; $i < @disease_evidence_arr ; $i++ ) {
				my $disease_text = $disease_evidence_arr[$i];
				push( @disease_all_text, $disease_text );
			}

			$disease_all_text_len = @disease_all_text;
			print <<HTML;
		  <tr>
		  <th rowspan="1">Disease</th>
		   	 <td colspan="4">Disease from text ($disease_all_text_len)<img src="../images/plus.jpg" class="show-disease" width="10px" >
		   	 <div class="list" style="display: none;">
		   	 <table border = "0">
HTML

			#disease from text
			for ( my $i = 0 ; $i < @disease_all_text ; $i++ ) {
				print <<HTML;
		   	 <tr>
		    <td>$disease_all_text[$i]</td> 
		    </tr>
HTML

			}

			print <<HTML;
	</table>
	</div>
	</td>
	</tr>
HTML

			
			my @goterms_all;
			my $goterms_all_len = 0;
			my @goterms_arr = split( '_', $text_result[0][5] );
			$goterms_all_len = @goterms_arr - 1;
			for ( my $i = 1 ; $i < @goterms_arr ; $i++ ) {
				my ( $goid, $gotype ) =
				  search_from_go_terms( $goterms_arr[$i] );
				$gotype = ucfirst($gotype);
				if ( $i == 1 ) {

					print <<HTML;
		   	<tr>
		   	<th rowspan=$goterms_all_len >GO Terms</th>
<td colspan="4"> <a href="http://amigo.geneontology.org/amigo/term/$goid" target="_blank">$goid</a> $goterms_arr[$i] $gotype</td> 
		  </tr>
HTML
				}
				else {
					print <<HTML;
		   	<tr>
<td colspan="4"> <a href="http://amigo.geneontology.org/amigo/term/$goid" target="_blank">$goid</a> $goterms_arr[$i] $gotype</td> 
		   </tr>
HTML
				}

			}

			
			my @organisms_arr = split( '_', $text_result[0][3] );
			my $organisms_str = $organisms_arr[1];
			for ( my $i = 2 ; $i < @organisms_arr ; $i++ ) {
				$organisms_str .= ',' . $organisms_arr[$i];
			}
			print <<HTML;
		   	<tr>
		   	<th>Organisms</th>
		   	<td colspan="4">$organisms_str</td>
		   	</tr>
HTML

			
			my $crosstalk_all_len = 0;
			my @crosstalk_all;
			for ( my $j = 0 ; $j < @result ; $j++ ) {
				if ( $result[$j][9] ne 'NULL' ) {
					my @crosstalk_arr = split( ',', $result[$j][9] );
					for ( my $i = 0 ; $i < @crosstalk_arr ; $i++ ) {
						$crosstalk_arr[$i] =~ s/^\s+|\s+$//;   
						push( @crosstalk_all, $crosstalk_arr[$i] );
					}
				}
			}
			@crosstalk_all = remove_duplicate(@crosstalk_all);
			my $crosstalk_str = $crosstalk_all[0];
			for ( my $i = 1 ; $i < @crosstalk_all ; $i++ ) {
				$crosstalk_str .= ',' . $crosstalk_all[$i];
			}
			print <<HTML;
		   	<tr>
		   	<th>Crosstalk</th>
		   	<td colspan="4">$crosstalk_str</td>
		   	</tr>
     	</table>
HTML
#############################print gene_norm

#############show details
			show_details( $pmids[$each_pmid], @result );

		}

	}
	print <<HTML;
<div class="down_page">
	<div id="download"><a href="../files/results/${suffix}_results.txt" target="_blank" class="download">Download All Results</a>
	</div>
HTML

	if ( $search_ptmtype eq '12' ) {
		my $pmid_all_str = join( ',', @pmids_all );
		for ( my $i = 1 ; $i <= @page_arr ; $i++ ) {
			if ( $i == $pageindex ) {
				print <<HTML;
HTML
			}
			else {
				print <<HTML;
			<li><a class="show_loading" href="http://bioinformatics.ustc.edu.cn/mptm/cgi-bin/results_original.cgi?radio=radio_pmid&sequences=$pmid_all_str&pageindex=$i">$i</a></li>	
HTML
			}
		}
	}
	else {
		my @arr              = split( '_', $search_target );
		my $search_substrate = $arr[0];
		my $search_disease   = $arr[1];
		my $search_time      = $arr[2];
		my %ptm_type_hash    = (
			'Phosphorylation' => 0,
			'Methylation'     => 1,
			'Glycosylation'   => 2,
			'Acetylation'     => 3,
			'Amidation'       => 4,
			'Hydroxylation'   => 5,
			'Myristoylation'  => 6,
			'Sulfation'       => 7,
			'GPI-Anchor'      => 8,
			'Disulfide'       => 9,
			'Ubiquitination'  => 10
		);
		for ( my $i = 1 ; $i <= @page_arr ; $i++ ) {
			if ( $i == $pageindex ) {
				print <<HTML;
	<li class="nowpage"><a href="#">$i</a></li>	
HTML
			}
			else {
				print <<HTML;
	<li><a class="show_loading" href="http://bioinformatics.ustc.edu.cn/mptm/cgi-bin/results_original.cgi?radio=radio_search&selectptm=$ptm_type_hash{$ptm_type}&searchkeys=$search_substrate&disease=$search_disease&time=$search_time&pageindex=$i">$i</a></li>
HTML
			}
		}
	}

	print <<HTML;
</div> <!-- end down_page -->
HTML
	print <<HTML;
     	</div>   <!-- end marg1-->

HTML

}

sub show_details {
	my ( $pmid, @result ) = @_;
	my @substrate_all;
	my @kinase_all;
	my @site_all;
	my @crosstalk_all;
	my $self = newdb( "localhost", "ptminfo", "root", "1234" );
	my @text_result =
	  query_ptmtext( $self, "select * from ptmtext where pmid='$pmid'" );

	for ( my $j = 0 ; $j < @result ; $j++ ) {

		if ( $result[$j][2] ne 'NULL' ) {
			my @substrate_arr = split( ',', $result[$j][2] );
			for ( my $i = 0 ; $i < @substrate_arr ; $i++ ) {
				$substrate_arr[$i] =~ s/^\s+|\s+$//;   
				push( @substrate_all, $substrate_arr[$i] );
			}
		}
		if ( $result[$j][3] ne 'NULL' ) {
			my @kinase_arr = split( ',', $result[$j][3] );
			for ( my $i = 0 ; $i < @kinase_arr ; $i++ ) {
				$kinase_arr[$i] =~ s/^\s+|\s+$//;      
				push( @kinase_all, $kinase_arr[$i] );
			}
		}
		if ( $result[$j][4] ne 'NULL' ) {
			my @site_arr = split( ',', $result[$j][4] );
			for ( my $i = 0 ; $i < @site_arr ; $i++ ) {
				$site_arr[$i] =~ s/^\s+|\s+$//;         
				push( @site_all, $site_arr[$i] );
			}
		}
		if ( $result[$j][9] ne 'NULL' ) {
			my @crosstalk_arr = split( ',', $result[$j][9] );
			for ( my $i = 0 ; $i < @crosstalk_arr ; $i++ ) {
				$crosstalk_arr[$i] =~ s/^\s+|\s+$//;   
				push( @crosstalk_all, $crosstalk_arr[$i] );
			}
		}
	}
	@substrate_all = remove_duplicate(@substrate_all);
	@kinase_all    = remove_duplicate(@kinase_all);
	@site_all      = remove_duplicate(@site_all);
	@crosstalk_all = remove_duplicate(@crosstalk_all);
	my $text_result = $text_result[0][1];

	#substrate
	for ( my $i = 0 ; $i < @substrate_all ; $i++ ) {
		$text_result =~
		  s/($substrate_all[$i])/<span class=\"substrate\">$1<\/span>/g;
	}

	#kinase
	for ( my $i = 0 ; $i < @kinase_all ; $i++ ) {
		$text_result =~ s/($kinase_all[$i])/<span class=\"kinase\">$1<\/span>/g;
	}

	#site
	for ( my $i = 0 ; $i < @site_all ; $i++ ) {
		$site_all[$i] =~ s/-/ /g;
		if ( $site_all[$i] =~ /(\d+)/ ) {
			$site_all[$i] = $1;
		}
		$text_result =~ s/($site_all[$i])/<span class=\"site\">$1<\/span>/g;
	}

	#organisms
	my @organisms_arr = split( '_', $text_result[0][3] );
	for ( my $i = 1 ; $i < @organisms_arr ; $i++ ) {
		$text_result =~
		  s/(\b$organisms_arr[$i]\b)/<span class=\"species\">$1<\/span>/ig;
	}

	#crosstalk
	for ( my $i = 0 ; $i < @crosstalk_all ; $i++ ) {
		$text_result =~
		  s/(\b$crosstalk_all[$i]\b)/<span class=\"crosstalk\">$1<\/span>/ig;
	}

	#disease_evidence
	my @disease_evidence_arr = split( '_', $text_result[0][2] );
	for ( my $i = 1 ; $i < @disease_evidence_arr ; $i++ ) {
		$text_result =~
s/(\b$disease_evidence_arr[$i]\b)/<span class=\"disevidence\">$1<\/span>/ig;
	}

	#goterms
	my @goterms_arr = split( '_', $text_result[0][5] );
	for ( my $i = 1 ; $i < @goterms_arr ; $i++ ) {
		$text_result =~
		  s/(\b$goterms_arr[$i]\b)/<span class=\"goterms\">$1<\/span>/ig;
	}
	print <<HTML;
	<button class="btn">Details</button>
			<div class="det" style="display:none">$text_result
<br/>
<br/>
<form class="hlform">
	<span>Select/deselect: </span>
		<div class="mark-sub">
		<input class="c_substrate" type="checkbox" checked="" >substrate
	</div>
	
	<div class="mark-kinase">
		<input class="c_kinase" type="checkbox" checked="" >kinase
	</div>
	
	<div class="mark-site">
		<input class="c_site" type="checkbox" checked="" >site
	</div>
	
	<div class="mark-disease_evidence">
		<input class="c_disease_evidence" type="checkbox" checked="checked" >disease
	</div>	
	
	<div class="mark-goterms">
		<input class="c_goterms" type="checkbox" checked="checked" >goterms
	</div>	
	
	<div class="mark-organisms">
		<input class="c_organisms" type="checkbox" checked="checked" >organisms
	</div>
	
	<div class="mark-crosstalk">
		<input class="c_crosstalk" type="checkbox" checked="checked" >crosstalk
	</div>

</form>
			
</div>
<br/><br/>

HTML

}

sub get_title {
	my $text  = shift;
	my @arr   = split( '.', $text );
	my $title = $arr[0];
	return $title;
}

sub get_disease_text {

	
	my $text = shift;

	#disease_evidence
	my @disevidence_all = (
		'Spondyloepimetaphyseal dysplasia with joint laxity',
		'Retinoschisis',
		'Macular dystrophy',
		'Opsismodysplasia',
		'White sponge nevus',
		'Cirrhosis',
		'Earwax',
		'Diabetes insipidus',
		'Histidinemia',
		'Cerebrotendinous xanthomatosis',
		'Systemic lupus erythematosus',
		'Multiple sclerosis',
		'Warfarin resistance',
		'Bent bone dysplasia syndrome',
		'Basal ganglia calcification',
		'Autoimmune lymphoproliferative syndrome',
		'SC phocomelia syndrome',
		'Muscle hypertrophy',
		'Sulfite oxidase deficiency',
		'Glaucoma',
		'Lipoid adrenal hyperplasia',
		'Myeloid leukemia',
		'Palmoplantar keratoderma',
		'Chylomicron retention disease',
		'Lung cancer',
		'Glutaric acidemia IIA',
		'COPD',
		'Arthropathy',
		'Mitochondrial phosphate carrier deficiency',
		'Manitoba oculotrichoanal syndrome',
		'Myoglobinuria',
		'Athabaskan brainstem dysgenesis syndrome',
		'Intervertebral disc disease',
		'De la Chapelle dysplasia',
		'Mulibrey nanism',
		'Hematuria',
		'MASS syndrome',
		'Epilepsy idiopathic generalized',
		'Kininogen deficiency',
		'Native American myopathy',
		'Rippling muscle disease',
		'Omenn syndrome',
		'Thyroid carcinoma',
		'Mast cell disease',
		'Hemolytic uremic syndrome',
		'Trimethylaminuria',
		'Odontoonychodermal dysplasia',
		'Hypomyelination',
		'Kawasaki disease',
		'Hangover',
		'Steatocystoma multiplex',
		'Ataxia',
		'Prostate cancer aggressiveness QTL',
		'Deafness ',
		'Fibromatosis',
		'Aspergillosis',
		'Retinal disease in Usher syndrome type IIA',
		'Dentin dysplasia',
		'Mesothelioma',
		'Celiac disease',
		'Chondrodysplasia punctata',
		'Anhaptoglobinemia',
		'Macroglobulinemia',
		'Carnitine deficiency',
		'Spondyloarthropathy',
		'Dystransthyretinemic hyperthyroxinemia',
		'ABCD syndrome',
		'Spondylocarpotarsal synostosis syndrome',
		'Scapuloperoneal spinal muscular atrophy',
		'Cyanosis',
		'Spondylometaepiphyseal dysplasia',
		'Nicotine dependence',
		'Haddad syndrome',
		'Progressive external ophthalmoplegia',
		'Fumarase deficiency',
		'Vasculopathy',
		'Methionine adenosyltransferase deficiency',
		'Cerebral infarction',
		'Oculoauricular syndrome',
		'Terminal osseous dysplasia',
		'Adenosine triphosphate',
		'Nystagmus',
		'Rickets',
		'Endometrial carcinoma',
		'Hepatic adenoma',
		'Myopia',
		'Ventricular fibrillation',
		'Ectopia lentis',
		'Dyserythropoietic anemia',
		'BCG infection',
		'Persistent truncus arteriosus',
		'Deep venous thrombosis',
		'Achondroplasia',
		'Pilomatricoma',
		'Hepatic venoocclusive disease with immunodeficiency',
		'Fabry disease',
		'Keratitis',
		'Periventricular heterotopia with microcephaly',
		'Facial paresis',
		'Scapuloperoneal myopathy',
		'Bethlem myopathy',
		'Adenomas',
		'Muscle glycogenosis',
		'Ocular albinism',
		'Mitochondrial complex III deficiency',
		'Pancreatic lipase deficiency',
		'Erythrokeratodermia variabilis with erythema gyratum repens',
		'EBD inversa',
		'Neuroaxonal neurodegeneration',
		'COACH syndrome',
		'Fibrocalculous pancreatic diabetes',
		'Warfarin sensitivity',
		'Mycobacterial infection',
		'Reticulate acropigmentation of Kitamura',
		'Osteolysis',
		'Genitopatellar syndrome',
		'Neural tube defects',
		'breast tumor',
		'Exostoses',
		'Incontinentia pigmenti',
		'Leprechaunism',
		'Myosclerosis',
		'Peeling skin syndrome',
		'Pseudohypoaldosteronism type I',
		'Lymphoma',
		'Leigh syndrome',
		'Trichotillomania',
		'Liddle syndrome',
		'Phosphohydroxylysinuria',
		'Myofibromatosis',
		'Leukemia',
		'Basal laminar drusen',
		'PCWH syndrome',
		'Blepharospasm',
		'Persistent Mullerian duct syndrome',
		'Pseudohypoparathyroidism',
		'Methylmalonic aciduria',
		'Myhre syndrome',
		'Otospondylomegaepiphyseal dysplasia',
		'Myocardial infarcation',
		'Autoimmune lymphoproliferative syndrome type IV',
		'Codeine sensitivity',
		'Epidermolysis bullosa',
		'Fundus albipunctatus',
		'CHARGE syndrome',
		'Synpolydactyly',
		'Hepatocellular carcinoma',
		'CINCA syndrome',
		'Hypophosphatemic rickets with hypercalciuria',
		'Alkaptonuria',
		'Mevalonic aciduria',
		'Angiopathy',
		'Episodic pain syndrome',
		'Properdin deficiency',
		'Transposition of great arteries',
		'Proteus syndrome',
		'Kanzaki disease',
		'WHIM syndrome',
		'Glass syndrome',
		'Premature ovarian failure',
		'Leukoencephalopathy with vanishing white matter',
		'Uric acid concentration',
		'Hyperlipoproteinemia',
		'Leiomyoma',
		'Tibial muscular dystrophy',
		'Hemolytic anemia due to adenylate kinase deficiency',
		'Hyperlipidemia',
		'Alzheimer disease',
		'Knobloch syndrome',
		'Schizophrenia',
		'Pyruvate dehydrogenase phosphatase deficiency',
		'Pseudofolliculitis barbae',
		'Poikiloderma with neutropenia',
		'Multiple pterygium syndrome',
		'Dysprothrombinemia',
		'Asparagine synthetase deficiency',
		'van der Woude syndrome',
		'Glycerol kinase deficiency',
		'Chilblain lupus',
		'Lipodystrophy',
		'Gitelman syndrome',
		'Pancreatic carcinoma',
		'Agammaglobulinemia',
		'Malignant melanoma',
		'Invasive pneumococcal disease',
		'Tetralogy of Fallot',
		'Adrenal hypoplasia',
		'Mucolipidosis IV',
		'Specific granule deficiency',
		'Arthyrgryposis',
		'Sarcosinemia',
		'Long QT syndrome',
		'CK syndrome',
		'Greig cephalopolysyndactyly syndrome',
		'Nephrotic syndrome',
		'Van Buchem disease',
		'SESAME syndrome',
		'Retinal arterial macroaneurysm with supravalvular pulmonic stenosis',
		'Paget disease',
		'Neuronopathy',
		'IMAGE syndrome',
		'Stroke',
		'Ethylmalonic encephalopathy',
		'Skeletal defects',
		'Medulloblastoma',
		'White blood cell count QTL',
		'Hypoproteinemia',
		'Pseudovaginal perineoscrotal hypospadias',
		'Hypoinsulinemic hypoglycemia with hemihypertrophy',
		'Xeroderma pigmentosum',
		'Farber lipogranulomatosis',
		'Progressive external ophthalmoplegia with mitochondrial DNA deletions',
		'Trypsinogen deficiency',
		'Chrondrodysplasia',
		'Watson syndrome',
		'Hypertrophic osteoarthropathy',
		'Central hypoventilation syndrome',
		'Epiphyseal dysplasia',
		'Mental retardation syndrome',
		'Pancreatic cancer',
		'Anemia',
		'Mucopolysaccharidosis Is',
		'Kleefstra syndrome',
		'Prolidase deficiency',
		'Thrombophilia due to thrombin defect',
		'Eosinophil peroxidase deficiency',
		'CLOVE syndrome',
		'Ovarian hyperstimulation syndrome',
		'Occult macular dystrophy',
		'Gaze palsy',
		'Methylmalonate semialdehyde dehydrogenase deficiency',
		'Phenylketonuria',
		'Encephalopahty',
		'Rhizomelic chondrodysplasia punctata',
		'Iridogoniodysgenesis',
		'Sialidosis',
		'Esophageal carcinoma',
		'Atrial fibrillation',
		'Diabetes',
		'Revesz syndrome',
		'Thromboembolism',
		'Hypoprothrombinemia',
		'Congenital myopathy with excess of muscle spindles',
		'Dengue fever',
		'Blood pressure regulation QTL',
		'Dementia',
		'Arthrogryposis',
		'Somatostatin analog',
		'Mitochondrial pyruvate carrier deficiency',
		'Liver failure',
		'Iminoglycinuria',
		'Leydig cell hypoplasia with pseudohermaphroditism',
		'Rhabdomyosarcoma',
		'Neuroepithelioma',
		'Hemophilia A',
		'Cleidocranial dysplasia',
		'Acampomelic campomelic dysplasia',
		'Pyruvate dehydrogenase lipoic acid synthetase deficiency',
		'Retinitis pigmentosa',
		'Episodic ataxia',
		'Thrombophilia due to protein S deficiency',
		'Spinal muscular atrophy',
		'Muscular dystrophy',
		'Hyperlysinemia',
		'GAPO syndrome',
		'Gray platelet syndrome',
		'Glycine encephalopathy',
		'Esophageal squamous cell carcinoma',
		'Mucopolysaccharidosis II',
		'Venous thrombosis',
		'Myelofibrosis',
		'Alveolar capillary dysplasia with misalignment of pulmonary veins',
		'Renal glucosuria',
		'SERKAL syndrome',
		'Polyglucosan body myopathy',
		'Pendred syndrome',
		'Ichthyosis',
		'Oocyte maturation defect',
		'Polyglucosan body disease',
		'Microphthalmia',
		'Spina bifida',
		'Pseudohypoparathyroidism Ic',
		'Blau syndrome',
		'Frasier syndrome',
		'Thrombocytopenia',
		'Trichodontoosseous syndrome',
		'Congenital heart defects',
		'Retinoblastoma',
		'Cerebral amyloid angiopathy',
		'Stiff skin syndrome',
		'Myxoid liposarcoma',
		'Melioidosis',
		'Galactosialidosis',
		'Immunodeficiency with hyper IgM',
		'Neuropathy',
		'Guttmacher syndrome',
		'Amyotrophy',
		'Trichoepithelioma',
		'Persistent hyperplastic primary vitreous',
		'Ovarioleukodystrophy',
		'Mucopolysaccharidosis type IX',
		'Hypohaptoglobinemia',
		'Mitochondrial complex I deficiency',
		'Kuru',
		'Pyruvate carboxylase deficiency',
		'Heart block',
		'Becker muscular dystrophy',
		'Trifunctional protein deficiency',
		'Ovarian cancer',
		'Arrhythmogenic right ventricular dysplasia',
		'Pyogenic bacterial infections',
		'Aldosteronism',
		'Venous thromboembolism',
		'Metabolic syndrome',
		'SCID',
		'Question mark ears',
		'Aspartylglucosaminuria',
		'Hyperbilirubinemia',
		'Dermatofibrosarcoma protuberans',
		'Pulmonary hypertension',
		'Cystathioninuria',
		'Alopecia universalis',
		'Ciliary dyskinesia',
		'Amelogenesis imperfecta',
		'Burkitt lymphoma',
		'SBBYSS syndrome',
		'Ichthyosis bullosa of Siemens',
		'Huntington disease',
		'Spinal muscular atrophy with progressive myoclonic epilepsy',
		'Lipoprotein lipase deficiency',
		'Cohen syndrome',
		'Hemolytic anemia',
		'Arthrogryposis multiplex congenita',
		'Diastrophic dysplasia',
		'Meleda disease',
		'Alacrima',
		'CPT II deficiency',
		'Angioedema',
		'Carpenter syndrome',
		'Renal tubular acidosis',
		'Melanoma',
		'Craniometaphyseal dysplasia',
		'Pituitary adenoma',
		'Blue cone monochromacy',
		'Congenital cataracts',
		'Blood group Cromer',
		'Pheochromocytoma',
		'Desmosterolosis',
		'Larsen syndrome',
		'Chitotriosidase deficiency',
		'Neutrophil immunodeficiency syndrome',
		'Wilson disease',
		'Retinopathy of prematurity',
		'Small patella syndrome',
		'Cousin syndrome',
		'Myasthenia',
		'Plasma triglyceride level QTL',
		'Mannosidosis',
		'Myelodysplastic syndrome',
		'Pseudohypoparathyroidism Ia',
		'Tangier disease',
		'Bradyopsia',
		'Laron dwarfism',
		'Inosine triphosphatase deficiency',
		'Hepatoblastoma',
		'Mucopolysaccharidosis type IIID',
		'Epileptic encephalopathy',
		'Hyperoxaluria',
		'Maple syrup urine disease',
		'Glutathione synthetase deficiency',
		'Visceral myopathy',
		'Pulmonary disease',
		'Striatal degeneration',
		'Cardiac arrhythmia',
		'Weyers acrodental dysostosis',
		'Fragile X syndrome',
		'Geroderma osteodysplasticum',
		'Pycnodysostosis',
		'Erythermalgia',
		'Hyperglycinuria',
		'Spondyloepiphyseal dysplasia with congenital joint dislocations',
		'Exfoliation syndrome',
		'Hyperprolinemia',
		'Cushing syndrome',
		'Acrocallosal syndrome',
		'Hyperparathyroidism',
		'Desbuquois dysplasia',
		'OI type III',
		'Insensitivity to pain',
		'Maculopathy',
		'Ovarian carcinoma',
		'Bladder cancer',
		'Immunodeficiency',
		'Erythrokeratodermia variabilis et progressiva',
		'Slowed nerve conduction velocity',
		'Hypercholesterolemia',
		'Phosphoserine phosphatase deficiency',
		'Traboulsi syndrome',
		'Pierson syndrome',
		'Cardiomypathy',
		'Hyperekplexia',
		'Herpes simplex encephalitis',
		'Gnathodiaphyseal dysplasia',
		'STAR syndrome',
		'Bartter syndrome',
		'Myotonia congenita',
		'Hypercholanemia',
		'Nevus',
		'Osteopetrosis',
		'Mental retardation',
		'Mucopolysaccharidosis type IIIC (Sanfilippo C)',
		'Hyperostosis',
		'Citrullinemia',
		'Refsum disease',
		'Dyskeratosis congenita',
		'Tooth agenesis',
		'Acromicric dysplasia',
		'Crouzon syndrome',
		'Atrioventricular septal defect',
		'Syndactyly',
		'Naxos disease',
		'Poikiloderma',
		'Osteosarcoma',
		'CATSHL syndrome',
		'IgE levels QTL',
		'Metaphyseal dysplasia without hypotrichosis',
		'Trichothiodystrophy',
		'Nephrolithiasis',
		'Cystic fibrosis',
		'Lymphedema',
		'Hypochondroplasia',
		'Encephalopathy',
		'Hyperbiliverdinemia',
		'Systemic lupus erythematosus susceptibility to',
		'Primary lateral sclerosis',
		'Pseudomonas aeruginosa',
		'Sitosterolemia',
		'Cardiofaciocutaneous syndrome',
		'Spondylocheirodysplasia',
		'Mitochondrial complex II deficiency',
		'Wolfram syndrome',
		'Esophageal cancer',
		'Doyne honeycomb degeneration of retina',
		'Dyskinesia',
		'Troyer syndrome',
		'Acheiropody',
		'Oculopharyngeal muscular dystrophy',
		'Craniolenticulosutural dysplasia',
		'Hydrolethalus syndrome',
		'Meconium ileus',
		'Aspartate aminotransferase',
		'Coumarin resistance',
		'Duchenne muscular dystrophy',
		'Hemolytic anemia due to glutathione peroxidase deficiency',
		'Myopathy with lactic acidosis',
		'Hepatitis B virus infection',
		'Griscelli syndrome',
		'Friedreich ataxia',
		'Ovarian response to FSH stimulation',
		'Nasopharyngeal carcinoma',
		'Holocarboxylase synthetase deficiency',
		'Mitochondrial complex IV deficiency',
		'Lead poisoning',
		'Jalili syndrome',
		'Carney complex variant',
		'Gaucher disease',
		'Mucopolysaccharidosis VII',
		'Ectodermal dysplasia',
		'Emphysema due to AAT deficiency',
		'Salla disease',
		'Carpal tunnel syndrome',
		'Histiocytoma',
		'Ectodermal',
		'Galactokinase deficiency with cataracts',
		'Hyperfibrinolysis',
		'Pulmonary fibrosis',
		'Infections',
		'Interstitial nephritis',
		'Cystinuria',
		'Dyssegmental dysplasia',
		'Melanocytic nevus syndrome',
		'Coloboma of optic nerve',
		'Hypermanganesemia with dystonia',
		'Acne inversa',
		'Chondrodysplasia with joint dislocations',
		'Hydrocephalus',
		'Carboxypeptidase N deficiency',
		'Argininemia',
		'Lysinuric protein intolerance',
		'Parastremmatic dwarfism',
		'Buruli ulcer',
		'Adenocarcinoma of lung',
		'Hemophagocytic lymphohistiocytosis',
		'Friedreich ataxia with retained reflexes',
		'Erythrocytosis due to bisphosphoglycerate mutase deficiency',
		'Caudal duplication anomaly',
		'Darier disease',
		'Mast syndrome',
		'Kaposi sarcoma',
		'Familial Mediterranean fever',
		'Colon cancer',
		'Heterotopia',
		'Fructose intolerance',
		'Dravet syndrome',
		'Metachromatic leukodystrophy',
		'Spondyloepimetaphyseal dysplasia',
		'Hartsfield syndrome',
		'Proteinuria',
		'Pseudohypoaldosteronism',
		'Cutis laxa',
		'Myxoma',
		'Gardner syndrome',
		'Delayed sleep phase syndrome',
		'Keutel syndrome',
		'Hemoglobin H disease',
		'Fanconi anemia',
		'Leukodystrophy',
		'Thyroid papillary carcinoma',
		'Epidermolysis bullosa pruriginosa',
		'Muenke syndrome',
		'Clopidogrel',
		'Mucolipidosis III gamma',
		'Neuroblastoma with Hirschsprung disease',
		'Cardioencephalomyopathy',
		'Nonaka myopathy',
		'Exocrine pancreatic insufficiency',
		'Hyperalphalipoproteinemia',
		'Autism susceptibility',

		'Polyarteritis nodosa',
		'Spondyloepiphyseal dysplasia tarda with progressive arthropathy',
		'Colchicine resistance',
		'Cardiac valvular dysplasia',
		'Fatty liver',
		'Hyperuricemia',
		'Glomerulosclerosis',
		'Shaheen syndrome',
		'Myotubular myopathy',
		'Hypercalciuria',
		'Colonic adenoma recurrence',
		'Pneumococcal disease',
		'Vici syndrome',
		'Monilethrix',
		'Colostrum secretion',
		'Hemosiderosis',
		'Langer mesomelic dysplasia',
		'Protein Z deficiency',

		'Multiple endocrine neoplasia IIA',
		'Sickle cell anemia',
		'SMED Strudwick type',
		'Basal cell carcinoma',
		'Bare lymphocyte syndrome',
		'Hyperinsulinemic hypoglycemia',
		'Spastic paralysis',
		'Hemolytic anemia due to glutathione synthetase deficiency',
		'Ciliary diskinesia',
		'Hirschsprung disease',
		'Alcohol sensitivity',
		'Atelosteogenesis',
		'Dent disease',
		'Olmsted syndrome',
		'Hyperpigmentation',
		'VLCAD deficiency',
		'Lipase deficiency',
		'Czech dysplasia',
		'Leprosy',
		'Dermatitis',
		'SFM syndrome',
		'Polyposis syndrome',
		'Abetalipoproteinemia',
		'Proud syndrome',
		'Cardiac conduction defect',
		'Odontohypophosphatasia',
		'Myopathy due to myoadenylate deaminase deficiency',
		'Intestinal atresia',
		'Pancreatitis',
		'Nonsmall cell lung cancer',
		'Alstrom syndrome',
		'Dursun syndrome',
		'Zinc deficiency',
		'Transcobalamin II deficiency',
		'Werner syndrome',
		'Kahrizi syndrome',
		'Convulsions',
		'Cystic fibrosis lung disease',
		'Neurocutaneous melanosis',
		'Small cell cancer of the lung',
		'Homocystinuria',
		'Myoclonic epilepsy',
		'Radioulnar synostosis with amegakaryocytic thrombocytopenia',
		'Allergic rhinitis',
		'Amelogenesis imperfecta type',
		'Spermatocytic seminoma',
		'Cerebral palsy',
		'Precocious puberty',
		'Epstein syndrome',
		'Neuromuscular disease',
		'Panhypopituitarism',
		'Atopy',
		'Nicotine addiction',
		'Pseudohypoparathyroidism Ib',
		'Mucopolysaccharidosis type IIIB (Sanfilippo B)',
		'Cataract',
		'FILS syndrome',
		'Gilbert syndrome',
		'Pseudoachondroplasia',
		'Efavirenz central nervous system toxicity',
		'Hex A pseudodeficiency',
		'Insulin resistance',
		'Glutamine deficiency',
		'Toxic epidermal necrolysis',
		'Oculodentodigital dysplasia',
		'Acatalasemia',
		'Carney complex',
		'Estrogen resistance',
		'Hypouricemia',
		'Aniridia',
		'Thrombophilia',
		'Hyperkalemic periodic paralysis',
		'Gilles de la Tourette syndrome',
		'Glycosylphosphatidylinositol deficiency',
		'Heterotaxy',
		'Anonychia congenita',
		'Vohwinkel syndrome with ichthyosis',
		'Vohwinkel syndrome',
		'Hepatocellular cancer',
		'Dermatopathia pigmentosa reticularis',
		'Osteosclerosis',
		'Paget disease of bone',
		'Triphalangeal thumb',
		'XFE progeroid syndrome',
		'Basal cell nevus syndrome',
		'Amyotrophic lateral sclerosis',
		'Alagille syndrome',
		'Perry syndrome',
		'Schizencephaly',
		'ADULT syndrome',
		'Glanzmann thrombasthenia',
		'Waardenburg syndrome',
		'Woolly hair',
		'Pfeiffer syndrome',
		'Afibrinogenemia',
		'Microvillus inclusion disease',
		'Spinocrebellar ataxia',
		'Growth retardation',
		'LADD syndrome',
		'Mucopolysaccharidosis Ih',
		'Phenylthiocarbamide tasting',
		'Digital clubbing',
		'Aplastic anemia',
		'Mycobacterium tuberculosis infection',
		'Cervical cancer',
		'Lymphangioleiomyomatosis',
		'Sebastian syndrome',
		'Galactosemia',
		'Nephrogenic syndrome of inappropriate antidiuresis',
		'Efavirenz',
		'Renal tubular dysgenesis',
		'Sengers syndrome',
		'Aphakia',
		'Telangiectasia',
		'Pyropoikilocytosis',
		'Hypokalemic periodic paralysis',
		'Foveomacular dystrophy',
		'Leigh syndrome due to mitochondrial complex I deficiency',
		'Warsaw breakage syndrome',
		'Failure of tooth eruption',
		'Cocoon syndrome',
		'Novelty seeking personality',
		'Methemoglobinemia',
		'Tylosis with esophageal cancer',
		'Carbamoylphosphate synthetase I deficiency',
		'Myopathy',
		'Dysalbuminemic hyperzincemia',
		'Ichthyosis with confetti',
		'CHILD syndrome',
		'Chondrosarcoma',
		'Migraine',
		'Bothnia retinal dystrophy',
		'Hyperphenylalaninemia',
		'Hodgkin lymphoma',
		'Deafness',
		'Kappa light chain deficiency',
		'Branchiooculofacial syndrome',
		'Retinitis punctata albescens',
		'Myeloperoxidase deficiency',
		'IgE',
		'Ectopia lentis et pupillae',
		'Advanced sleep phase syndrome',
		'Pontocerebellar hypoplasia',
		'Hypertriglyceridemia',
		'Aphasia',
		'Isovaleric acidemia',
		'Hyperaldosteronism',
		'Ichthyosis prematurity syndrome',
		'Nijmegen breakage syndrome',
		'Leigh syndrome due to cytochrome c oxidase deficiency',
		'Hypophosphatasia',
		'Severe combined immunodeficiency',
		'MASA syndrome',
		'Cylindromatosis',
		'Hypoglycemia of infancy',
		'Netherton syndrome',
		'Thrombophilia due to protein C deficiency',
		'Endometrial cancer',
		'Epilepsy',
		'Hyperthyroidism',
		'Complex I',
		'Feingold syndrome',
		'Glutaric aciduria III',
		'Polycystic liver disease',
		'Dyschromatosis symmetrica hereditaria',
		'Leydig cell adenoma',
		'Mitochondrial complex V (ATP synthase) deficiency',
		'Hypocalcemia',
		'Hypophosphatemic rickets',
		'Arts syndrome',
		'Phosphoserine aminotransferase deficiency',
		'Ventricular tachycardia',
		'Schindler disease',
		'OI type II',
		'Cardiomyopathy',
		'Striatonigral degeneration',
		'Ischemic stroke',
		'Fechtner syndrome',
		'Vertical talus',
		'Osteopathia striata with cranial sclerosis',
		'Microphthalmia with limb anomalies',
		'Nevus sebaceous',
		'Hypersensitivity syndrome',
		'Glyoxalase II deficiency',
		'Arterial calcification',
		'Hepatitis C virus',
		'Lowe syndrome',
		'Hypermethioninemia',
		'Heinz body anemias',
		'Brachydactyly',
		'Basal ganglia cancification',
		'Surfactant metabolism dysfunction',
		'Lumbar disc degeneration',
		'Eiken syndrome',
		'Greenberg skeletal dysplasia',
		'Spondylometaphyseal dysplasia',
		'Multiple fibroadenomas of the breast',
		'Bloom syndrome',
		'IVIC syndrome',
		'CHIME syndrome',
		'Ectrodactyly',
		'Polymicrogyria',
		'Argininosuccinic aciduria',
		'Hypertrichotic osteochondrodysplasia',
		'EBD',
		'Contractural arachnodactyly',
		'Night blindness',
		'Parathyroid adenoma with cystic changes',
		'Spondyloepiphyseal dysplasia tarda',
		'Desmoid disease',
		'Homocystinuria due to MTHFR deficiency',
		'Thrombophilia due to activated protein C resistance',
		'Alternating hemiplegia of childhood',
		'Adenylosuccinase deficiency',
		'Lactase deficiency',
		'Cleft palate with ankyloglossia',
		'Leydig cell hypoplasia with hypergonadotropic hypogonadism',
		'Albinism',
		'Pentosuria',
		'Malouf syndrome',
		'Lathosterolosis',
		'Fraser syndrome',
		'Multiple endocrine neoplasia',
		'Kniest dysplasia',
		'Hepatitis C virus infection',
		'Hawkinsinuria',
		'Systemic lupus erythematous',
		'Renal agenesis',
		'Adrenomyeloneuropathy',
		'Cranioosteoarthropathy',
		'Velocardiofacial syndrome',
		'Hypercalcemia',
		'Spherocytosis',
		'Multiple myeloma',
		'Spondyloenchondrodysplasia with immune dysregulation',
		'Neutrophilia',
		'Campomelic dysplasia with autosomal sex reversal',
		'Optic atrophy plus syndrome',
		'Right atrial isomerism',
		'Polyhydramnios',
		'Craniosynostosis',
		'Usher syndrome',
		'PEPCK deficiency',
		'Hemolytic anemia due to triosephosphate isomerase deficiency',
		'Gastric cancer',
		'Liebenberg syndrome',
		'Bacteremia',
		'Martsolf syndrome',
		'Polydactyly',
		'Fertile eunuch syndrome',
		'CRASH syndrome',
		'HIV infection',
		'Atypical mycobacteriosis',
		'Chronic granulomatous disease',
		'Peters anomaly',
		'RAPADILINO syndrome',
		'Brody myopathy',
		'Atrichia with papular lesions',
		'Inclusion body myopathy',
		'Bone mineral density variation QTL',
		'Gout',
		'Osteoarthritis with mild chondrodysplasia',
		'Sialuria',
		'Propionicacidemia',
		'Campomelic dysplasia',
		'Mucopolysaccharidosis IVA',
		'Diaphyseal medullary stenosis with malignant fibrous histiocytoma',
		'Endplate acetylcholinesterase deficiency',
		'Tropical calcific pancreatitis',
		'Migraine without aura',
		'Stickler sydrome',
		'Hypobetalipoproteinemia',
		'Meckel syndrome',
		'Keratosis',
		'Hypothalamic hamartomas',
		'LCHAD deficiency',
		'Weaver syndrome',
		'Toenail dystrophy',
		'HELLP syndrome',
		'Myopathy with extrapyramidal signs',
		'Epidermal nevus',
		'Thalassemias',
		'Piebaldism',
		'Legius syndrome',
		'Pyruvate kinase deficiency',
		'Cowchock syndrome',
		'Pseudohermaphroditism',
		'Barth syndrome',
		'Osteogenesis imperfecta',
		'Frontometaphyseal dysplasia',
		'Thrombotic thrombocytopenic purpura',
		'Hypotrichosis',
		'Verheij syndrome',
		'Ullrich congenital muscular dystrophy',
		'Hypoalphalipoproteinemia',
		'McArdle disease',
		'Restrictive dermopathy',
		'Renal carcinoma',
		'Breast cancer',
		'Autism',
		'Thrombophilia due to antithrombin III deficiency',
		'Cardiomyopaty',
		'Favism',
		'Febrile seizures',
		'Thrombophilia due to thrombomodulin defect',
		'Keratosis palmoplantaris striata II',
		'Cherubism',
		'OI type IV',
		'Pityriasis rubra pilaris',
		'Xanthinuria',
		'Acrodermatitis enteropathica',
		'Clubfoot',
		'Hypothryoidism',
		'Dihydropyrimidine dehydrogenase deficiency',
		'Hypermethioninemia due to adenosine kinase deficiency',
		'Bile acid synthesis defect',
		'Canavan disease',
		'Insomnia',
		'Keratosis palmoplantaris striata I',
		'Hepatitic C virus',
		'Glutaric acidemia IIC',
		'Adenomatous polyposis coli',
		'Juvenile polyposis syndrome',
		'Opitz GBBB syndrome',
		'Caudal regression syndrome',
		'Severe combined immunodeficiency due to ADA deficiency',
		'Blood group GIL',
		'Interstitial lung disease',
		'Coloboma',
		'Craniodiaphyseal dysplasia',
		'Gillespie syndrome',
		'Sarcoidosis',
		'Brunner syndrome',
		'Aromatase excess syndrome',
		'Goiter',
		'Myokymia',
		'Pulmonary alveolar microlithiasis',
		'Menkes disease',
		'Pregnancy loss',
		'Chronic infections',
		'Supranuclear palsy',
		'Hyperammonemia due to carbonic anhydrase VA deficiency',
		'Leukocyte adhesion deficiency',
		'VACTERL association',
		'AIDS',
		'Transaldolase deficiency',
		'Blepharophimosis',
		'Megaloblastic anemia due to dihydrofolate reductase deficiency',
		'MODY',
		'Reticular dysgenesis',
		'Hemochromatosis',
		'Majeed syndrome',
		'Cole disease',
		'Adrenal hyperplasia',
		'Cleft palate',
		'Dihydrolipoamide dehydrogenase deficiency',
		'Myelofibrosis with myeloid metaplasia',
		'Cerebellar ataxia',
		'Adrenoleukodystrophy',
		'Apert syndrome',
		'Adenosine deaminase deficiency',
		'Scott syndrome',
		'Ichthyosis vulgaris',
		'Centronuclear myopathy',
		'Cerebral dysgenesis',
		'Myopathy congenital',
		'Myoclonus',
		'Osteochondritis dissecans',
		'Sacral agenesis with vertebral anomalies',
		'Fucosidosis',
		'Paroxysmal nocturnal hemoglobinuria',
		'Mismatch repair cancer syndrome',
		'Neuroblastoma',
		'Microcephaly',
		'Seizures',
		'Schwannomatosis',
		'HARP syndrome',
		'KBG syndrome',
		'Hereditary persistence of fetal hemoglobin',
		'Emberger syndrome',
		'Polymicrogyria with seizures',
		'Crouzon syndrome with acanthosis nigricans',
		'Chondrodysplasia with platyspondyly',
		'Kindler syndrome',
		'Hemangioma',
		'Epidermolytic hyperkeratosis',
		'Paroxysmal nonkinesigenic dyskinesia',
		'Keratosis follicularis spinulosa decalvans',
		'Keratoderma',
		'Fleck retina',
		'Currarino syndrome',
		'Partington syndrome',
		'Pleuropulmonary blastoma',
		'Polyposis',
		'CPT deficiency',
		'Hypocalciuric hypercalcemia',
		'Epiphyseal chondrodysplasia',
		'Alopecia',
		'Urocanase deficiency',
		'Silver spastic paraplegia syndrome',
		'Ohdo syndrome',
		'Hypoceruloplasminemia',
		'Dysautonomia',
		'Symphalangism',
		'GRACILE syndrome',
		'Fructosuria',
		'Combined hyperlipidemia',
		'Craniofrontonasal dysplasia',
		'Acromesomelic dysplasia',
		'Roberts syndrome',
		'Chondrodysplasia',
		'Glycerol quantitative trait locus',
		'Raine syndrome',
		'Adermatoglyphia',
		'Hyaline fibromatosis syndrome',
		'Fibrosis of extraocular muscles',
		'Septooptic dysplasia',
		'MEDNIK syndrome',
		'MHC class II deficiency',
		'Ghosal hematodiaphyseal syndrome',
		'Phosphoglycerate dehydrogenase deficiency',
		'Enlarged vestibular aqueduct',
		'Osteoglophonic dysplasia',
		'Thyrotoxic periodic paralysis',
		'Mucopolysaccharidisis type IIIA (Sanfilippo A)',
		'Leukoencephalopathy',
		'Multisystemic smooth muscle dysfunction syndrome',
		'Hypothyroidism',
		'Progressive familial heart block',
		'Amyloidosis',
		'Scoliosis',
		'Gracile bone dysplasia',
		'Cystinosis',
		'Macrocephaly',
		'Autoimmune disease',
		'Stickler syndrome',
		'Synpolydactyly with foot anomalies',
		'Macrothrombocytopenia',
		'Retinol dystrophy',
		'Atelosteogenesis II',
		'Ceroid lipofuscinosis',
		'Schneckenbecken dysplasia',
		'Hemophilia B',
		'Neutropenia',
		'AMP deaminase deficiency',
		'Pick disease',
		'Thrombosis',
		'Polycythemia vera',
		'Wrinkly skin syndrome',
		'Marshall syndrome',
		'Amish infantile epilepsy syndrome',
		'Immunodysregulation',
		'Combined immunodeficiency',
		'Asplenia',
		'Scapuloperoneal syndrome',
		'Macrocytic anemia',
		'Spondyloperipheral dysplasia',
		'Paramyotonia congenita',
		'Asthma',
		'Diabetes mellitus',
		'Osseous heteroplasia',
		'Aplasia cutis congenita',
		'Muscular dystrophy with epidermolysis bullosa simplex',
		'Pseudoxanthoma elasticum',
		'Adult i phenotype without cataract',
		'Combined SAP deficiency',
		'Metatropic dysplasia',
		'Dentinogenesis imperfecta',
		'Intestinal pseudoobstruction',
		'Perlman syndrome',
		'Tyrosinemia',
		'Obesity',
		'Cholestasis',
		'Hydrocephalus with Hirschsprung disease',
		'Jawad syndrome',
		'Multiple sulfatase deficiency',
		'Renal dysplasia',
		'Riboflavin deficiency',
		'Heinz body anemia',
		'Renal hypoplasia',
		'Facial clefting',
		'Leukoencephalopathy with ataxia',
		'Epidermolysis bullosa simplex',
		'Autoinflammation',
		'Erythroderma',
		'Influenza',
		'Scaphocephaly',
		'Cockayne syndrome',
		'Lipoprotein glomerulopathy',
		'Saccharopinuria',
		'Anauxetic dysplasia',
		'Spondyloepiphyseal dysplasia',
		'Leukoencephaly with vanishing white matter',
		'Spinocerebellar ataxia',
		'Multiple endocrine neoplasia IIB',
		'Thrombocytopenic purpura',
		'Adenocarcinoma',
		'Trehalase deficiency',
		'Achondrogenesis Ib',
		'Myopathy due to CPT II deficiency',
		'Platelet glycoprotein IV deficiency',
		'Parkinson disease',
		'Dimethylglycine dehydrogenase deficiency',
		'Aural atresia',
		'Preterm premature rupture of the membranes',
		'Galactose epimerase deficiency',
		'HDL deficiency',
		'Tn polyagglutination syndrome',
		'Parathyroid carcinoma',
		'Metaphyseal chondrodysplasia',
		'Dyslexia',
		'Pseudopseudohypoparathyroidism',
		'Bone mineral density',
		'Hemolytic anemia due to hexokinase deficiency',
		'CARASIL syndrome',
		'Thalassemia',
		'Aromatase deficiency',
		'Temtamy preaxial brachydactyly syndrome',
		'Pyogenic sterile arthritis',
		'Trichomegaly',
		'Peripheral neuropathy',
		'Glutaric acidemia IIB',
		'Hyperuricemic nephropathy',
		'Transposition of the great arteries',
		'Autoimmune thyroid disease',
		'Dystonia',
		'Rett syndrome',
		'Char syndrome',
		'Best macular dystrophy',
		'Wolman disease',
		'Ichthyosis histrix',
		'Diaphanospondylodysostosis',
		'Periodic fever',
		'Debrisoquine sensitivity',
		'EDICT syndrome',
		'Prostate cancer',
		'Exfoliative ichthyosis',
		'Laing distal myopathy',
		'Metachondromatosis',
		'Hydrocephalus with congenital idiopathic intestinal pseudoobstruction',
		'Enterokinase deficiency',
		'Fuhrmann syndrome',
		'Hypereosinophilic syndrome',
		'Sudden infant death with dysgenesis of the testes syndrome',
		'Segawa syndrome',
		'Polycystic kidney disease',
		'Conjunctivitis',
		'Legionaire disease',
		'Danon disease',
		'Macular degeneration',
		'Achondrogenesis',
		'Resting heart rate',
		'HFE hemochromatosis',
		'Hepatitis B virus',
		'Lissencephaly',
		'Multiple joint dislocations',
		'Retinal degeneration',
		'Glioblastoma',
		'Hydrocephalus due to aqueductal stenosis',
		'Hypoaldosteronism',
		'Bone marrow failure',
		'Hamamy syndrome',
		'Squamous cell carcinoma',
		'Eculizumab',
		'Premature chromatid separation trait',
		'Hepatic lipase deficiency',
		'Robinow syndrome',
		'Tetrology of Fallot',
		'Acromegaly',
		'Hypoparathyroidism',
		'Lumbar disc disease',
		'Costello syndrome',
		'Meacham syndrome',
		'Bulimia nervosa',
		'Angelman syndrome',
		'Severe combined immunodeficiency with microcephaly',
		'Escobar syndrome',
		'Renal cell carcinoma',
		'Rheumatoid arthritis',
		'Kowarski syndrome',
		'Laryngoonychocutaneous syndrome',
		'Alcohol dependence',
		'RIDDLE syndrome',
		'Meningioma',
		'Renpenning syndrome',
		'Otopalatodigital syndrome',
		'Preeclampsia',
		'Boomerang dysplasia',
		'Optic nerve hypoplasia',
		'Polyneuropathy',
		'Glutaricaciduria',
		'Prion disease with protracted course',
		'Hypertension',
		'Ewing sarcoma',
		'Multicentric carpotarsal osteolysis syndrome',
		'Adrenal insufficiency',
		'Keratosis palmoplantaris striata III',
		'Spastic ataxia',
		'SED congenita',
		'Sudden infant death syndrome',
		'Atransferrinemia',
		'Thrombophilia due to elevated HRG',
		'TARP syndrome',
		'Tourette syndrome',
		'Blood group',
		'Tuberculosis',
		'Bestrophinopathy',
		'Alazami syndrome',
		'Caffey disease',
		'Opioid dependence',
		'Spermatogenic failure',
		'Mycobacterium tuberculosis',
		'Mononeuropathy of the median nerve',
		'Biotinidase deficiency',
		'Fundus flavimaculatus',
		'Bilirubin',
		'Myocardial infarction',
		'Thrombocythemia',
		'Lymphoproliferative syndrome',
		'Autoimmune polyendocrinopathy syndrome ',
		'Congenital bilateral absence of vas deferens',
		'Drug addiction',
		'Osteopoikilosis',
		'Miller syndrome',
		'Myasthenic syndrome',
		'Creatine phosphokinase',
		'Malaria',
		'Asperger syndrome susceptibility',
		'Hyperchylomicronemia',
		'Dihydropyrimidinuria',
		'Ataxia with isolated vitamin E deficiency',
		'Fibrodysplasia ossificans progressiva',
		'Schimke immunoosseous dysplasia',
		'Plasma fibronectin deficiency',
		'Du Pan syndrome',
		'Timothy syndrome',
		'Multicentric osteolysis',
		'Renal tubular acidosis with deafness',
		'Retinal dystrophy',
		'Glioma',
		'van Buchem disease',
		'Neurofibromatosis',
		'Focal dermal hypoplasia',
		'Polymicrogyria with optic nerve hypoplasia',
		'Unipolar depression',
		'Thrombophilia due to HRG deficiency',
		'Succinic semialdehyde dehydrogenase deficiency',
		'Granulomatous disease',
		'Parkes Weber syndrome',
		'Conotruncal anomaly face syndrome',
		'Multiple system atrophy',
		'Krabbe disease',
		'Lewy body dementia',
		'Epidermolysis bullosa dystrophica',
		'West nile virus',
		'Lumbar disc herniation',
		'Fibrochondrogenesis',
		'Small fiber neuropathy',
		'Erythrocytosis',
		'Adiponectin deficiency',
		'Marfan syndrome',
		'Jensen syndrome',
		'C syndrome',
		'Temtamy syndrome',
		'Primary aldosteronism',
		'Platyspondylic skeletal dysplasia',
		'Medullary thyroid carcinoma',
		'High molecular weight kininogen deficiency',
	);
	$disease_str = '';
	for ( my $i = 0 ; $i < @disevidence_all ; $i++ ) {
		if ( $text =~ /\b$disevidence_all[$i]\b/ig ) {
			$disease_str .= '_' . $disevidence_all[$i];
		}
	}
	return $disease_str;
}

sub get_disease {

	
	my @protein = @_;
	my $self    = newdb( "localhost", "ptminfo", "root", "1234" );
	my @disease = ();
	for ( my $i = 0 ; $i < @protein ; $i++ ) {
		my @result = query_omimdata( $self,
			"select * from omimdata where protein regexp '$protein[$i]'" );
		for ( my $j = 0 ; $j < @result ; $j++ ) {
			if ( $result[$j][2] ne 'NULL' && $result[$j][3] ne 'NULL' ) {

				my $disease = $result[$j][2] . "_MIM=" . $result[$j][3];
				push( @disease, $disease );
			}
		}

	}
	return @disease;   
}

sub get_goterms {

	
	my $text = shift;

	#disease_evidence
	my @goterms_all = (
		'reproduction',
		'thioredoxin',
		'sulfate assimilation',
		'repairosome',
		'glycerol-1-phosphatase activity',
		'flocculation',
		'polarisome',
		'exocyst',
		'protein polyubiquitination',
		'leptotene',
		'zygotene',
		'pachytene',
		'diplotene',
		'diakinesis',
		'endopolyphosphatase activity',
		'sulfite transport',
		'macromitophagy',
		'micromitophagy',
		'macropexophagy',
		'micropexophagy',
		'karyogamy',
		'conjugation',
		'cytogamy',
		'kinetochore',
		'chromatin',
		'nucleosome',
		'euchromatin',
		'heterochromatin',
		'cytokinesis',
		'glycerophosphodiester transport',
		'ossification',
		'RNA methylation',
		'fibrillin',
		'peptide amidation',
		'globin',
		'angiogenesis',
		'microfibril',
		'elastin',
		'elastin',
		'luteinization',
		'luteolysis',
		'vasculogenesis',
		'galectin',
		'pseudophosphatase activity',
		'ruffle',
		'somitogenesis',
		'phosphotyrosine binding',
		'phosphatidylserine binding',
		'autolysis',
		'uropod',
		'lymphangiogenesis',
		'thigmotaxis',
		'polkadots',
		'podosome',
		'manchette',
		'hypersensitivity',
		'lipid hydroxylation',
		'regionalization',
		'Gene_Ontology',
		'molecular_function',
		'protein',
		'ribonucleoprotein',
		'2-deoxyglucose-6-phosphatase activity',
		'6-phosphofructokinase activity',
		'6-phosphofructo-2-kinase activity',
		'N-acetylgalactosamine-4-sulfatase activity',
		'N4-(beta-N-acetylglucosaminyl)-L-asparaginase activity',
		'acetylcholinesterase activity',
		'acylphosphatase activity',
		'amidase activity',
		'amidophosphoribosyltransferase activity',
		'aminomethyltransferase activity',
		'arylformamidase activity',
		'aryldialkylphosphatase activity',
		'arylsulfatase activity',
		'cerebroside-sulfatase activity',
		'dimethylallyltranstransferase activity',
		'ethanolaminephosphotransferase activity',
		'exopolyphosphatase activity',
		'formamidase activity',
		'galactosylceramidase activity',
		'glucose-6-phosphatase activity',
		'glucosylceramidase activity',
		'guanosine-diphosphatase activity',
		'histidinol-phosphatase activity',
		'iduronate-2-sulfatase activity',
		'phosphatidylinositol-3-phosphatase activity',
		'inositol-1,4,-bisphosphate 3-phosphatase',
		'inositol-1,4,-bisphosphate 4-phosphatase',
		'inositol-1,4,5-trisphosphate 1-phosphatase',
		'alpha-N-acetylglucosaminidase activity',
		'beta-N-acetylhexosaminidase activity',
		'cyclophilin',
		'phosphoglucomutase activity',
		'phosphomannomutase activity',
		'phospholipase activity',
		'lysophospholipase activity',
		'phosphorylase activity',
		'steryl-sulfatase activity',
		'thiamine-pyrophosphatase activity',
		'trehalose-phosphatase activity',
		'serpin',
		'gp130',
		'ephrin',
		'neuroligin',
		'collagen',
		'proteoglycan',
		'phosphate:hydrogen symporter',
		'apolipoprotein',
		'binding',
		'lectin',
		'N-acetylgalactosamine lectin',
		'phospholipid binding',
		'1-phosphatidylinositol binding',
		'phosphatidylinositol-4,5-bisphosphate binding',
		'phosphatidylinositol-3,4,5-trisphosphate binding',
		'ubiquitin',
		'polyubiquitin',
		'ribozyme',
		'RNA',
		'DNA',
		'cellular_component',
		'intracellular',
		'cell',
		'ascus',
		'nucleus',
		'importin',
		'transportin',
		'exportin',
		'nucleoplasm',
		'chromosome',
		'chromatid',
		'telomere',
		'centromere',
		'chiasma',
		'beta-heterochromatin',
		'alpha-heterochromatin',
		'nucleolus',
		'cytoplasm',
		'mitochondrion',
		'lysosome',
		'endosome',
		'vacuole',
		'peroxisome',
		'microsome',
		'coatomer',
		'centrosome',
		'centriole',
		'aster',
		'spindle',
		'cytosol',
		'ribosome',
		'polysome',
		'cytoskeleton',
		'microtubule',
		'neurofilament',
		'caveola',
		'microvillus',
		'cilium',
		'axoneme',
		'shmoo',
		'6-phosphofructokinase complex',
		'gluconeogenesis',
		'pentose-phosphate shunt',
		'fermentation',
		'oxidative phosphorylation',
		'glycerophosphate shuttle',
		'protein-disulfide reduction',
		'6-phosphofructokinase reduction',
		'5,10-methylenetetrahydrofolate oxidation',
		'dADP phosphorylation',
		'dGDP phosphorylation',
		'IDP phosphorylation',
		'dIDP phosphorylation',
		'mutagenesis',
		'DNA methylation',
		'translation',
		'protein phosphorylation',
		'protein dephosphorylation',
		'protein acetylation',
		'protein deacetylation',
		'protein sulfation',
		'peptidyl-tyrosine sulfation',
		'protein methylation',
		'protein demethylation',
		'protein glycosylation',
		'terminal O-glycosylation',
		'proteolysis',
		'ubiquitin cycle',
		'protein monoubiquitination',
		'protein deglycosylation',
		'AMP phosphorylation',
		'ADP phosphorylation',
		'sulfur utilization',
		'phosphorus utilization',
		'transport',
		'exocytosis',
		'endocytosis',
		'pinocytosis',
		'phagocytosis',
		'autophagy',
		'chemotaxis',
		'actin ubiquitination',
		'oncogenesis',
		'synapsis',
		'phosphatidylinositol-4,5-bisphosphate hydrolysis',
		'I-kappaB phosphorylation',
		'JUN phosphorylation',
		'spermatogenesis',
		'vitellogenesis',
		'insemination',
		'cellularization',
		'gastrulation',
		'axonogenesis',
		'metamorphosis',
		'histolysis',
		'eclosion',
		'parturition',
		'aging',
		'digestion',
		'excretion',
		'lactation',
		'hemostasis',
		'phototransduction',
		'behavior',
		'learning',
		'memory',
		'mating',
		'copulation',
		'fibrinogen',
		'N-acetyltransferase activity',
		'spectrin',
		'lipophorin',
		'acetylesterase activity',
		'sulfotransferase activity',
		'biological_process',
		'organophosphorus resistance',
		'methyltransferase activity',
		'C-methyltransferase activity',
		'N-methyltransferase activity',
		'O-methyltransferase activity',
		'S-methyltransferase activity',
		'UDP-glycosyltransferase activity',
		'bioluminescence',
		'necrosis',
		'opsonization',
		'sulfate transport',
		'methyl-CpG binding',
		'selectin',
		'acetylglucosaminyltransferase activity',
		'acetylgalactosaminyltransferase activity',
		'25-hydroxycholecalciferol-24-hydroxylase activity',
		'phosphatidylethanolamine binding',
		'1-phosphatidylinositol-5-phosphate kinase',
		'phosphofructokinase activity',
		'N-acetylglucosamine-6-sulfatase activity',
		'alpha-N-acetylgalactosaminidase activity',
		'phospholipid scrambling',
		'CHRAC',
		'tachykinin',
		'1-phosphofructokinase activity',
		'6-phospho-beta-glucosidase activity',
		'alpha,alpha-phosphotrehalase activity',
		'beta-phosphoglucomutase activity',
		'carboxymethylenebutenolidase activity',
		'4-hydroxy-tetrahydrodipicolinate reductase',
		'4-hydroxy-tetrahydrodipicolinate synthase',
		'glucose-1-phosphatase activity',
		'nicotinamidase activity',
		'phosphatidylglycerophosphatase activity',
		'phospho-N-acetylmuramoyl-pentapeptide-transferase activity',
		'phosphopentomutase activity',
		'phosphoribulokinase activity',
		'DNA-methyltransferase activity',
		'tRNA sulfurtransferase',
		'pilus',
		'transduction',
		'nucleoid',
		'pathogenesis',
		'virulence',
		'fimbrin',
		'aerotaxis',
		'flavodoxin',
		'cytochrome',
		'glutaredoxin',
		'amicyanin',
		'rubredoxin',
		'amyloplast',
		'plasmodesma',
		'chloroplast',
		'chromoplast',
		'etioplast',
		'glyoxysome',
		'leucoplast',
		'photosystem',
		'phragmoplast',
		'phragmosome',
		'plastid',
		'proplastid',
		'granum',
		'elaioplast',
		'megasporogenesis',
		'microsporogenesis',
		'megagametogenesis',
		'fertilization',
		'thylakoid',
		'tropism',
		'gravitropism',
		'phototropism',
		'photomorphogenesis',
		'skotomorphogenesis',
		'photoperiodism',
		'thigmotropism',
		'de-etiolation',
		'photosynthetic phosphorylation',
		'abscission',
		'cyanelle',
		'germination',
		'photorespiration',
		'pollination',
		'nodulation',
		'dehiscence',
		'expansin',
		'circumnutation',
		'photoprotection',
		'transpiration',
		'senescence',
		'photoinhibition',
		'hydrotropism',
		'plastoglobule',
		'phosphatidylinositol-5-phosphate binding',
		'stromule',
		'carboxyl-O-methyltransferase activity',
		'chromocenter',
		'histone monoubiquitination',
		'methyl-CpNpG binding',
		'methyl-CpNpN binding',
		'chlororespiration',
		'ubiquitin homeostasis',
		'polyferredoxin',
		'azurin',
		'plastocyanin',
		'glypican',
		'syndecan',
		'glucuronate-2-sulfatase activity',
		'opsin',
		'holin',
		'colicin',
		'thiosulfate transport',
		'phosphoglycerate transport',
		'phosphoenolpyruvate transport',
		'nucleotide-sulfate transport',
		'glucose-6-phosphate transport',
		'N-acetylgalactosamine transport',
		'N-acetylglucosamine transport',
		'methylgalactoside transport',
		'CMP-N-acetylneuraminate transport',
		'UDP-N-acetylglucosamine transport',
		'UDP-N-acetylgalactosamine transport',
		'glycerol-3-phosphate transport',
		'S-methylmethionine transport',
		'holin',
		'methylammonium transport',
		'acetylcholine transport',
		'acetyl-CoA transport',
		'sulfathiazole transport',
		'phospholipid transport',
		'aminophospholipid transport',
		'methanogenesis',
		'photosynthesis',
		'antiport',
		'symport',
		'uniport',
		'Nebenkern',
		'membrane',
		'rhabdomere',
		'allatostatin',
		'insulin',
		'beta-N-acetylglucosaminidase activity',
		'aggresome',
		'macroautophagy',
		'microautophagy',
		'death',
		'1-phosphatidylinositol-3-kinase activity',
		'phosphorylation',
		'dephosphorylation',
		'inositol-1,4,5-trisphosphate phosphatase',
		'organophosphorus susceptibility/resistance',
		'dimethylargininase activity',
		'acetyltransferase activity',
		'O-acetyltransferase activity',
		'S-acetyltransferase activity',
		'C-acetyltransferase activity',
		'pyrophosphatase activity',
		'sarcoplasm',
		'intein',
		'protein ubiquitination',
		'histone methylation',
		'histone phosphorylation',
		'histone acetylation',
		'histone ubiquitination',
		'histone deacetylation',
		'histone dephosphorylation',
		'histone demethylation',
		'histone deubiquitination',
		'protein deubiquitination',
		'diphosphotransferase activity',
		'sulfurtransferase activity',
		'phosphatase activity',
		'activin',
		'inhibin',
		'hemerythrin',
		'hemocyanin',
		'ceramidase activity',
		'galactosylgalactosylglucosylceramidase activity',
		'glycosylceramidase activity',
		'adrenocorticotropin',
		'6-phosphogluconolactonase activity',
		'nucleoside-diphosphatase activity',
		'nucleoside-triphosphatase activity',
		'phospholipid scrambling',
		'nucleologenesis',
		'peptidyl-lysine hydroxylation',
		'peptidyl-lysine N6-acetylation',
		'peptidyl-histidine methylation',
		'peptidyl-lysine methylation',
		'peptidyl-lysine trimethylation',
		'peptidyl-lysine monomethylation',
		'peptidyl-lysine dimethylation',
		'peptidyl-lysine myristoylation',
		'protein amidation',
		'peptidyl-serine phosphopantetheinylation',
		'peptidyl-serine phosphorylation',
		'peptidyl-histidine phosphorylation',
		'peptidyl-threonine phosphorylation',
		'peptidyl-tyrosine phosphorylation',
		'peptidyl-arginine phosphorylation',
		'peptidyl-cysteine methylation',
		'protein hydroxylation',
		'peptidyl-cysteine desulfurization',
		'protein desulfurization',
		'peptidyl-arginine C5-methylation',
		'poly-N-methyl-propylamination',
		'peptidyl-proline di-hydroxylation',
		'protein phosphopantetheinylation',
		'peptidyl-arginine methylation',
		'peptidyl-cysteine phosphorylation',
		'peptidyl-cysteine S-acetylation',
		'peptidyl-tyrosine hydroxylation',
		'protein-pyridoxal-5-phosphate linkage',
		'peptidyl-glutamine 2-methylation',
		'peptidyl-glutamine methylation',
		'protein myristoylation',
		'peptidyl-lysine acetylation',
		'peptidyl-cysteine acetylation',
		'dibenzothiophene desulfurization',
		'organosulfide cycle',
		'apolysis',
		'oviposition',
		'host',
		'metaxin',
		'virion',
		'provirus',
		'myristoyltransferase activity',
		'3-deoxy-manno-octulosonate-8-phosphatase activity',
		'deacetylase activity',
		'proprioception',
		'transsulfuration',
		'sulfur oxidation',
		'sulfide oxidation',
		'sulfate reduction',
		'bisulfite reduction',
		'aspartate transamidation',
		'2-aminobenzenesulfonate desulfonation',
		'peptidyl-proline hydroxylation',
		'peptidyl-arginine N5-methylation',
		'peptidyl-asparagine methylation',
		'synaptosome',
		'cytolysis',
		'flagellum',
		'phosphatase binding',
		'rhoptry',
		'microneme',
		'conoid',
		'apicoplast',
		'schizogony',
		'glycosome',
		'acidocalcisome',
		'kinetoplast',
		'pellicle',
		'neurogenesis',
		'signaling',
		'myofibril',
		'sarcomere',
		'lamellipodium',
		'parvulin',
		'immunophilin',
		'hemidesmosome',
		'desmosome',
		'phycobilisome',
		'hemopoiesis',
		'anaphylaxis',
		'glycocalyx',
		'S-layer',
		'diuresis',
		'natriuresis',
		'filopodium',
		'lipid glycosylation',
		'T-tubule',
		'defecation',
		'axon',
		'dendrite',
		'sleep',
		'peristalsis',
		'tRNA methylation',
		'midbody',
		'phosphatidyltransferase activity',
		'pseudocleavage',
		'axolemma',
		'preribosome',
		'ovulation',
		'(S)-coclaurine-N-methyltransferase activity',
		'autosome',
		'replisome',
		'peptidyl-serine O-acetylation',
		'peptidyl-serine acetylation',
		'peptidyl-arginine hydroxylation',
		'macronucleus',
		'micronucleus',
		'regeneration',
		'pseudopodium',
		'rRNA methylation',
		'phosphopantetheine binding',
		'phosphatidylcholine binding',
		'actin phosphorylation',
		'invertasome',
		'keratinization',
		'carboxysome',
		'spitzenkorper',
		'polyubiquitin binding',
		'xanthophore',
		'cytostome',
		'cytoproct',
		'envelope',
		'vesicle',
		'proteinoplast',
		'phagolysosome',
		'mitosome',
		'bleb',
		'eisosome',
		'transposition',
		'methylation',
		'phosphatidylinositol-3-phosphate binding',
		'stereocilium',
		'beta-N-acetylgalactosaminidase activity',
		'demethylase activity',
		'sulfiredoxin activity',
		'polyamine acetylation',
		'spermidine acetylation',
		'spermine acetylation',
		'putrescine acetylation',
		'nucleomorph',
		'porosome',
		'esterosome',
		'beta-1,4-N-acetylgalactosaminyltransferase activity',
		'2-aminoethylphosphonate transport',
		'2-aminoethylphosphonate binding',
		'hydroxyectoine binding',
		'hydroxyectoine transport',
		'S-methylmethionine cycle',
		'phospholipid efflux',
		'galactose-6-sulfurylase activity',
		'cellulose-polysulfatase activity',
		'chondro-4-sulfatase activity',
		'chondro-6-sulfatase activity',
		'N-sulfoglucosamine-3-sulfatase activity',
		'6-phospho-beta-galactosidase activity',
		'enhanceosome',
		'steroid acetylation',
		'steroid deacetylation',
		'sterol acetylation',
		'sterol deacetylation',
		'gerontoplast',
		'microtubule anchoring',
		'BBSome',
		'ribophagy',
		'hydroxyproline transport',
		'methyltransferase complex',
		'methylosome',
		'4-hydroxypyridine-3-hydroxylase activity',
		'peptidyl-lysine deacetylation',
		'pupariation',
		'pupation',
		'phosphatidylinositol binding',
		'hatching',
		'cytoneme',
		'peptidyl-arginine C-methylation',
		'peptidyl-arginine N-methylation',
		'peptidyl-arginine omega-N-methylation',
		'alpha-1,4-N-acetylgalactosaminyltransferase activity',
		'segmentation',
		'peptidyl-tyrosine dephosphorylation',
		'histone-serine phosphorylation',
		'histone-threonine phosphorylation',
		'histone-tyrosine phosphorylation',
		'methylthiotransferase activity',
		'tRNA methylthiolation',
		'phosphoanandamide dephosphorylation',
		'peptidyl-threonine dephosphorylation',
		'peptidyl-histidine dephosphorylation',
		'aggrephagy',
		'mucocyst',
		'scintillon',
		'endolysosome',
		'microspike',
		'acroblast',
		'fucosylation',
		'3-sulfino-L-alanine binding',
		'peptidyl-histidine hydroxylation',
		'rumination',
		'thiosulfate binding',
		'deglucuronidation',
		'RNA (guanine-N7)-methylation',
		'swimming',
		'coflocculation',
		'peptidyl-serine autophosphorylation',
		'protein trans-autophosphorylation',
		'protein cis-autophosphorylation',
		'myofilament',
		'acetyl-CoA:oxalate CoA-transferase',
		'peptidyl-tyrosine autophosphorylation',
		'growth',
		'locomotion',
		'gliogenesis',
		'nematocyst',
		'acetylcholine binding',
		'peptidyl-asparagine hydroxylation',
		'homoiothermy',
		'vasoconstriction',
		'vasodilation',
		'taxis',
		'phototaxis',
		'gravitaxis',
		'paraspeckles',
		'sarcolemma',
		'kinesis',
		'chemokinesis',
		'orthokinesis',
		'klinokinesis',
		'melanosome',
		'odontogenesis',
		'myelination',
		'hydrogenosome',
		'microbody',
		'mannosome',
		'chorion',
		'capsule',
		'chylomicron',
		'catagen',
		'exogen',
		'telogen',
		'anagen',
		'actomyosin',
		'prothylakoid',
		'thelarche',
		'menarche',
		'menopause',
		'menstruation',
		'fibrinolysis',
		'hibernation',
		'estivation',
		'alkylphosphonate transport',
		'alkanesulfonate transport',
		'costamere',
		'thermotaxis',
		'ubiquitin binding',
		'glycerol-3-phosphatase activity',
		'varicosity',
		'sulfate binding',
		'perikaryon',
		'fibril',
		'alkanesulfonate binding',
		'organelle',
		'megasome',
		'adenosine-diphosphatase activity',
		'cellulosome',
		'ectoplasm',
		'phospholipase binding',
		'anoikis',
		'poly(3-hydroxyalkanoate) binding',
		'apoptosome',
		'phosphatidylinositol-3,4-bisphosphate binding',
		'macromolecule glycosylation',
		'macromolecule methylation',
		'pigmentation',
		'protein anchor',
		'neuroprotection',
		'6-phosphofructo-2-kinase/fructose-2,6-biphosphatase complex',
		'chemotropism',
		'exosporium',
		'symbiosome',
		'exine',
		'ectexine',
		'endexine',
		'nexine',
		'sexine',
		'columella',
		'tectum',
		'intine',
		'dedifferentiation',
		'iridosome',
		'leucosome',
		'pterinosome',
		'cyanosome',
		'enamidase activity',
		'hydroxyneurosporene-O-methyltransferase activity',
		'N-acetylgalactosamine-6-sulfatase activity',
		'sporulation',
		'DNA hypermethylation',
		'DNA hypomethylation',
		'sporoplasm',
		'anammoxosome',
		'pirellulosome',
		'dendriole',
		'C-fiber',
		'exoneme',
		'crystalloid',
		'micropinocytosis',
		'macropinocytosis',
		'pinosome',
		'micropinosome',
		'macropinosome',
		'microspike',
		'protein sulfhydration',
		'peptidyl-cystine sulfhydration',
		'hemi-methylated DNA-binding',
		'amphisome',
		'autolysosome',
		'nucleophagy',
		'depurination',
		'depyrimidination',
		'chitosome',
		'transcytosis',
		'vimentin',
		'desmin',
		'peripherin',
		'pronucleus',
		'uridine-diphosphatase activity',
		'fusome',
		'spectrosome',
		'synapse',
		'phosphoserine/phosphothreonine binding',
		'peptidyl-tryptophan hydroxylation',
		'phospholipid translocation',
		'decidualization',
		'capsomere',
		'protein autophosphorylation',
		'assemblon',
		'lipid phosphorylation',
		'carbohydrate phosphorylation',
		'phospholipid dephosphorylation',
		'hydroxyapatite binding',
		'phosphatidylinositol phosphorylation',
		'phosphatidylinositol dephosphorylation',
		'chlorosome',
		'mesosome',
		'N-acetylgalactosamine binding',
		'secretion',
		'nucleotide phosphorylation',
		'habituation',
		'sensitization',
		'guanidinodeoxy-scyllo-inositol-4-phosphatase activity',
		'beta-aspartyl-N-acetylglucosaminidase activity',
		'2-carboxy-D-arabinitol-1-phosphatase activity',
		'4-methyleneglutaminase activity',
		'5-aminopentanamidase activity',
		'hydroxynitrilase activity',
		'adenosine-tetraphosphatase activity',
		'adenylylsulfatase activity',
		'alkylacetylglycerophosphatase activity',
		'alkylamidase activity',
		'aryl-acylamidase activity',
		'choline-sulfatase activity',
		'caldesmon-phosphatase activity',
		'carboxymethylhydantoinase activity',
		'carnitinamidase activity',
		'D-lactate-2-sulfatase activity',
		'diisopropyl-fluorophosphatase activity',
		'dimethylallylcistransferase activity',
		'disulfoglucosamine-6-sulfatase activity',
		'dolichyl-phosphatase activity',
		'dolichyldiphosphatase activity',
		'endoglycosylceramidase activity',
		'glycerol-2-phosphatase activity',
		'glycosulfatase activity',
		'phosphatidylinositol-mediated signaling',
		'apoplast',
		'hyperphosphorylation',
		'oogenesis',
		'sarcomerogenesis',
		'mannitol-1-phosphatase activity',
		'methylguanidinase activity',
		'monomethyl-sulfatase activity',
		'monoterpenyl-diphosphatase activity',
		'myosin-light-chain-phosphatase activity',
		'N,N-dimethylformamidase activity',
		'N-acylneuraminate-9-phosphatase activity',
		'omega-amidase activity',
		'pentanamidase activity',
		'phosphoadenylylsulfatase activity',
		'phosphoamidase activity',
		'phosphoglucokinase activity',
		'phosphoketolase activity',
		'phosphoribokinase activity',
		'prenyl-diphosphatase activity',
		'sedoheptulose-bisphosphatase activity',
		'sorbitol-6-phosphatase activity',
		'streptomycin-6-phosphatase activity',
		'sugar-phosphatase activity',
		'sugar-terminal-phosphatase activity',
		'thiamin-triphosphatase activity',
		'thymidine-triphosphatase activity',
		'trimetaphosphatase activity',
		'triphosphatase activity',
		'tryptophanamidase activity',
		'undecaprenyl-diphosphatase activity',
		'peptidyl-glycinamidase activity',
		'hydroxycinnamoyltransferase activity',
		'O-hydroxycinnamoyltransferase activity',
		'phosphoserine binding',
		'phosphothreonine binding',
		'coagulation',
		'peptidyl-5-hydroxy-L-lysine trimethylation',
		'cognition',
		'diapedesis',
		'thermoception',
		'electroception',
		'equilibrioception',
		'magnetoreception',
		'echolocation',
		'peptidyl-serine sulfation',
		'peptidyl-threonine sulfation',
		'localization',
		'phosphoprotein binding',
		'anaphase',
		'metaphase',
		'prophase',
		'interphase',
		'telophase',
		'amitosis',
		'tRNA acetylation',
		'acetylcholine uptake',
		'protein autoubiquitination',
		'sulfation',
		'lysophospholipid transport',
		'P-methyltransferase activity',
		'Se-methyltransferase activity',
		'jasmonoyl-isoleucine-12-hydroxylase activity',
		'inositol phosphorylation',
		'beta-6-sulfate-N-acetylglucosaminidase activity',
		'1-phosphatidylinositol-5-kinase activity',
		'trichocyst',
		'symplast',
		'microgametogenesis',
		'phospholipid homeostasis',
		'reflex',
		'micturition',
		'kinocilium',
		'diestrus',
		'proestrus',
		'estrus',
		'metestrus',
		'delamination',
		'transdifferentiation',
		'flight',
		'innervation',
		'yolk',
		'karyomere',
		'CDP phosphorylation',
		'acetylcholine secretion',
		'dAMP phosphorylation',
		'CMP phosphorylation',
		'dCMP phosphorylation',
		'GDP phosphorylation',
		'UDP phosphorylation',
		'dCDP phosphorylation',
		'TDP phosphorylation',
		'mononeme',
		'glycosylation',
		'ubiquitin-dependent endocytosis',
		'fructose-6-phosphate binding',
		'anchoring junction',
		'telosome',
		'peptidyl-serine dephosphorylation',
		'oncosis',
		'cornification',
		'pyroptosis',
		'phosphatidylinositol-4-phosphate binding',
		'rRNA (guanine-N7)-methylation',
		'phytoceramidase activity',
		'glycerol-2-phosphate transport',
		'micropyle',
		'Hsp90 deacetylation',
		'trans-translation',
		'demethylation',
		'oxidative demethylation',
		'prespliceosome',
		'invadopodium',
		'pi-body',
		'piP-body',
		'mastication',
		'dihydroceramidase activity',
		'prominosome',
		'alpha-tubulin acetylation',
		'parasitism',
		'mRNA methylation',
		'phosphatidylinositol-3,5-bisphosphate binding',
		'4,4-dimethyl-9beta,19-cyclopropylsterol oxidation',
		'4-alpha-methyl-delta7-sterol oxidation',
		'DNA demethylation',
		'mutualism',
		'commensalism',
		'haustorium',
		'arbuscule',
		'tubulin deacetylation',
		'inosine-diphosphatase activity',
		'epiboly',
		'peptidyl-histidine autophosphorylation',
		'acetyl-CoA:L-lysine N6-acetyltransferase',
		'enucleation',
		'amelogenesis',
		'dentinogenesis',
		'cytoophidium',
		'dishabituation',
		'ripoptosome',
		'prenylation',
		'UDP-glucosylation',
		'deoxynucleoside-diphosphatase activity',
		'nematosome',
		'mesaxon',
		'gemmule',
		'mannosylation',
		'sialylation',
		'polynucleotide dephosphorylation',
		'DNA dephosphorylation',
		'deuterosome',
		'peptidyl-N-phospho-arginine dephosphorylation',
		'4-(trimethylammonio)butanoate transport',
		'4-hydroxyphenylacetate transport',
		'phosphatidylglycerol binding',
		'acetyltransferase complex',
		'phosphatase complex',
		'vasomotion',
		'peptide-serine-N-acetyltransferase activity',
		'peptide-glutamate-N-acetyltransferase activity',
		'sulfurtransferase complex',
		'phosphomannomutase complex',
		'peptidyl-threonine trans-autophosphorylation',
		'xylanosome',
		'peptidyl-threonine autophosphorylation',
		'pexophagosome',
		'omegasome',
		'N-methylnicotinate transport',
	);
	$goterms_str = '';
	for ( my $i = 0 ; $i < @goterms_all ; $i++ ) {
		if ( $text =~ /\b$goterms_all[$i]\b/ig ) {
			$goterms_str .= '_' . $goterms_all[$i];
		}
	}
	return $goterms_str;
}

sub get_organisms {

	
	my $text = shift;

	#organisms_evidence
	my @organevidence_all = (
		'human',  'mouse',     'rat', 'yeast',
		'bovine', 'zebrafish', 'fly', 'virus'
	);
	$organisms_str = '';
	for ( my $i = 0 ; $i < @organevidence_all ; $i++ ) {
		if ( $text =~ /\b$organevidence_all[$i]\b/ig ) {
			$organisms_str .= '_' . $organevidence_all[$i];
		}
	}
	return $organisms_str;

}

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

sub remove_duplicate {
	my @array = @_;
	my %count;
	my @uniq_array = grep { ++$count{$_} < 2; } @array;
}
sub find_mapping_uniprotkb {
		my ( $pmid, @mined ) = @_;
		my %mined_uniprotkb_id_hash = ();
		my $self = newdb( "localhost", "ptminfo", "root", "1234" );
		for ( my $i = 0 ; $i < @mined ; $i++ ) {
			my @result = query_genenorm( $self,
"SELECT * FROM genenorm WHERE gene_name REGEXP '$mined[$i]' AND pmid = '$pmid'"
			);
			for ( my $j = 0 ; $j < @result ; $j++ ) {
				if ( $result[$j][2] ne 'NULL' && $result[$j][9] ne 'NULL' ) {
				my $uniprotKB_id = $result[$j][2];
				my $uniprot_entry = $result[$j][9];
				my $uniprotKB_id_link = $uniprotKB_id."/".$uniprot_entry;
				$mined_uniprotkb_id_hash{ $mined[$i] } = $uniprotKB_id_link;
			}
}

		}
		return %mined_uniprotkb_id_hash;    #return gene mapping uniprotkb_id
	}
sub find_relate_pmid {

	
	my @pro_arr  = @_;
	my %pro_pmid = ();

	my $self = newdb( "localhost", "ptminfo", "root", "1234" );
	for ( my $i = 0 ; $i < @pro_arr ; $i++ ) {
		my $pmid_str;
		my @pmid_str;
		my @result = query( $self,
"select * from ptmdetails where substrate regexp '$pro_arr[$i]'or kinase regexp '$pro_arr[$i]'or site regexp '$pro_arr[$i]'"
		);
		for ( my $j = 0 ; $j < @result ; $j++ ) {
			if ( $result[$j][0] ne 'NULL' && $result[$j][0] ne '0' ) {
				push( @pmid_str, $result[$j][0] );
			}
		}
		@pmid_str = remove_duplicate(@pmid_str);
		for ( my $k = 0 ; $k < @pmid_str ; $k++ ) {

			#only give 100
			if ( $k < 50 ) {

				#	print $pmid_str[$i]."\n";
				if ( $k == 0 ) {
					$pmid_str = $pmid_str[$k];
				}
				else {
					$pmid_str = $pmid_str . '.' . $pmid_str[$k];
				}
			}
			else {
				last;
			}
		}
		$pro_pmid{ $pro_arr[$i] } = $pmid_str;
	}
	return %pro_pmid;
}

sub print_result {

   
	my ( $search_ptmtype, $search_target, $all_pmids_result_len, $pageindex,
		$isfirst, @pmids )
	  = @_;
	my @arr = split( '_', $search_target );
	my $search_substrate = $arr[0];

	#	my $search_disease = $arr[1];
	#	my $search_time = $arr[2];
	my $self = newdb( "localhost", "ptminfo", "root", "1234" );
	my @ptm_type = (
		'Phosphorylation', 'Methylation',
		'Glycosylation',   'Acetylation',
		'Amidation',       'Hydroxylation',
		'Myristoylation',  'Sulfation',
		'GPI-Anchor',      'Disulfide',
		'Ubiquitination'
	);

	
	my %ptmtype_num;
	my @phos;
	my @meth;
	my @glyc;
	my @acet;
	my @amid;
	my @hydr;
	my @myri;
	my @sulf;
	my @gpi;
	my @disu;
	my @ubiq;
	my @pmids_quick;   
	my %substrate_quick = ();
	my %site_quick = ();
	my @result;

	for ( my $i = 0 ; $i < @pmids ; $i++ ) {
		if ( $search_ptmtype eq '12' ) {
			@result = query( $self, "SELECT * FROM ptmdetails WHERE pmid = '$pmids[$i]'" );
		}
		else {
			@result = query( $self, "SELECT * FROM ptmdetails WHERE pmid = '$pmids[$i]' AND substrate REGEXP '$search_substrate'"
			);
		}

		for ( my $j = 0 ; $j < @result ; $j++ ) {
						
			
				my @site_quick_arr = split( ',', $result[$j][4] );
				for ( my $kk = 0 ; $kk < @site_quick_arr ; $kk++ ) {
					if($site_quick_arr[$kk] ne 'NULL'){
					$site_quick{ $site_quick_arr[$kk]."\t".$pmids[$i] } = $pmids[$i];  
				}
				}
				###################################
				my @sub_quick_arr = split( ',', $result[$j][2] );
				for ( my $k = 0 ; $k < @sub_quick_arr ; $k++ ) {
					if( $sub_quick_arr[$k] ne 'NULL'){
					$substrate_quick{ $sub_quick_arr[$k]."\t".$pmids[$i]} = $pmids[$i];
						}
				}
				push( @pmids_quick, $pmids[$i] ); 
			if ( $result[$j][2] ne 'NULL' ) {
				$ptmtype_num{ $result[$j][6]}++;
	
				###
				if ( $result[$j][6] eq 'Phosphorylation' ) {
					push( @phos,        $pmids[$i] );
					#push( @pmids_quick, $pmids[$i] );  
					last;
				}
				elsif ( $result[$j][6] eq 'Methylation' ) {
					push( @meth,        $pmids[$i] );
					#push( @pmids_quick, $pmids[$i] ); 
					last;
				}
				elsif ( $result[$j][6] eq 'Glycosylation' ) {
					push( @glyc,        $pmids[$i] );
					#push( @pmids_quick, $pmids[$i] );  
					last;
				}
				elsif ( $result[$j][6] eq 'Acetylation' ) {
					push( @acet,        $pmids[$i] );
					#push( @pmids_quick, $pmids[$i] );  
					last;
				}
				elsif ( $result[$j][6] eq 'Amidation' ) {
					push( @amid,        $pmids[$i] );
					#push( @pmids_quick, $pmids[$i] );  
					last;
				}
				elsif ( $result[$j][6] eq 'Hydroxylation' ) {
					push( @hydr,        $pmids[$i] );
					#push( @pmids_quick, $pmids[$i] );  
					last;
				}
				elsif ( $result[$j][6] eq 'Myristoylation' ) {
					push( @myri,        $pmids[$i] );
					#push( @pmids_quick, $pmids[$i] );  
					last;
				}
				elsif ( $result[$j][6] eq 'Sulfation' ) {
					push( @sulf,        $pmids[$i] );
					#push( @pmids_quick, $pmids[$i] ); 
					last;
				}
				elsif ( $result[$j][6] eq 'GPI-Anchor' ) {
					push( @gpi,         $pmids[$i] );
					#push( @pmids_quick, $pmids[$i] ); 
					last;
				}
				elsif ( $result[$j][6] eq 'Disulfide' ) {
					push( @disu,        $pmids[$i] );
					#push( @pmids_quick, $pmids[$i] ); 
					last;
				}
				elsif ( $result[$j][6] eq 'Ubiquitination' ) {
					push( @ubiq,        $pmids[$i] );
					#push( @pmids_quick, $pmids[$i] );  
					last;
				}
				else {
					last;
				}
			}
		}
	}
	$pmid_num = 0;                                     
	while ( ( $key, $value ) = each %ptmtype_num ) {
		if ( $search_ptmtype eq '12' ) {
			$pmid_num += $value;
		}
		elsif ( $key eq $ptm_type[$search_ptmtype] ) {
			$pmid_num = $value;
		}

	}

	#my $allpmids_num = @pmids;    #all pmids
	print <<HTML;
	<div id="summary">
	<p>$all_pmids_result_len PMID(s) return by PubMed,  </p>
	<p>$pmid_num PMID(s) have PTM information.</p>
	</div>
HTML
if($isfirst eq '1'){


	print <<HTML;
<form  id="divWin_text" class="quick_dialog" style="background-color:#DDD;" action="results_original.cgi" method="post" enctype="multipart/form-data" id="frmMainPmid" onsubmit="return search_pmids(this)">
<input style="display:none" type="radio" id="pmid" name="radio" value="radio_pmid"/>
    <table id="quick_view" style="background-color:#ffffff; width:100%">
        <thead style = "color:#000; background-color:#ea5302; line-height: 35px" >
        <tr style = "width:100%">
			<th style = "cursor: pointer; text-align: center; width: 4%" >Select</th >
            <th style = "cursor: pointer; text-align: center; width: 7%" > PMID <img id="quickview_pmid" src="../images/sort_a.png" style="width: 20px;height: 20px" onclick="sortTable('quick_view',1,'int'),change_pmid()"> </th >
            <th style = "cursor: pointer; text-align: center; width: 34%" >Title</th >
            <th style = "cursor: pointer; text-align: center; width: 14%" >Substrate</th >
            
            <th style = "cursor: pointer; text-align: center; width: 8%" >Organisms</th >
            <th style = "cursor: pointer; text-align: center; width: 10%" >PTM type<img id="quickview_ptm_type" src="../images/sort_a.png" style="width: 20px;height: 20px" onclick="sortTable('quick_view',5),change_ptmtype()"></th >
            <th style = "cursor: pointer; text-align: center; width: 10%" >Time<img id="quickview_date" src="../images/sort_a.png" style="width: 20px;height: 20px" onclick="change_date(),sortTable('quick_view',6,'date')"></th >
			<th style = "cursor: pointer; text-align: center; width: 5%" >More</th >
        </tr >
		</thead>
HTML

	for (
		my $each_pmid_quick = 0 ;
		$each_pmid_quick < @pmids_quick ;
		$each_pmid_quick++
	  )
	{
		my @text_result_quick = query_ptmtext( $self,
"SELECT * FROM ptmtext WHERE pmid = '$pmids_quick[$each_pmid_quick]'"
		);
		my $ptm_type_quick_item = $text_result_quick[0][4];

		if (   $ptm_type_quick_item eq $ptm_type[$search_ptmtype]
			|| $search_ptmtype eq '12' )
		{
			my $pmid_quick_item  = $pmids_quick[$each_pmid_quick];
			my $pmcid_quick_item = $text_result_quick[0][6];
			my $title_quick_item = $text_result_quick[0][8];
			my $sub_quick_item   = '';
			while ( ( $key, $value ) = each %substrate_quick ) {
				if (   $key ne 'NULL'
					&& $value eq $pmids_quick[$each_pmid_quick] )
				{
					my @arr = split('\t',$key);
					$sub_quick_item .= $arr[0] . ",";
				}

			}

			if ( $sub_quick_item eq '' ) {
				$sub_quick_item = '*';
			}

			my $site_quick_item = '';
			while ( ( $key, $value ) = each %site_quick ) {
				if (   $key ne 'NULL'
					&& $value eq $pmids_quick[$each_pmid_quick] )

				{	my @arr = split('\t',$key);
					$site_quick_item .= $arr[0] . ",";
				}

			}
			if ( $site_quick_item eq '' ) {
				$site_quick_item = '*';
			}

			my @organisms_quick_arr = split( '_', $text_result_quick[0][3] );
			my $organisms_quick_item = '';
			for ( my $kk = 1 ; $kk < @organisms_quick_arr ; $kk++ ) {
				$organisms_quick_item .= $organisms_quick_arr[$kk] . ",";

			}

			if ( $organisms_quick_item eq '' ) {
				$organisms_quick_item = '*';
			}

			my $pubdate_quick_item = $text_result_quick[0][7];
			$pubdate_quick_item =~ s/(\d{4})(\d{2})(\d{2})/$1-$2-$3/;

			#打印到html上

			print <<HTML;
	<tr>
	<td><input type="checkbox" value="$pmid_quick_item" class="paperslist" /></td>
	<td>$pmid_quick_item</td>
	<td>$title_quick_item</td>
	<td><span >$sub_quick_item</span></td>
	
	<td>$organisms_quick_item</td>
	<td>$ptm_type_quick_item</td>
	<td>$pubdate_quick_item</td>
	<td class="pmid_list_link"><a href="http://bioinformatics.ustc.edu.cn/mptm/cgi-bin/results_original.cgi?radio=radio_pmid&sequences=$pmid_quick_item&pageindex=1&isfirst=0" target="_blank">✍</a></td>
	</tr>
HTML
		}

	}
	print <<HTML;
</table>
<textarea style="display:none" name="sequences" id="sequences" cols="" rows="" ></textarea>
<textarea name="pageindex" class="pageindex" cols="1" rows="1" >1</textarea>
<textarea name="isfirst" class="isfirst" cols="1" rows="1" >0</textarea>
<input type="submit" name="submit" class="submit"  value="Submit"/>
<span>* Select multiple records to view the results !</span>
</form>
HTML
}

##########################
	if ( $pmid_num && $isfirst eq '0' ) {
		print <<HTML;
	<div id="tabs">
	<ul>
HTML

		while ( ( $key, $value ) = each %ptmtype_num ) {
			if ( $search_ptmtype eq '12' ) {
				print <<HTML;
	  <li><a href="#$key">$key($value)</a></li>
HTML
			}
			elsif ( $key eq $ptm_type[$search_ptmtype] ) {
				print <<HTML;
	  <li><a href="#$key">$key($value)</a></li>
HTML
			}

		}

		print <<HTML;
</ul>
HTML
		while ( ( $key, $value ) = each %ptmtype_num ) {
			if ( $key eq 'Phosphorylation'
				&& ( $search_ptmtype eq '0' || $search_ptmtype eq '12' ) )
			{
				print_ptm_info( $key, $search_target, $search_ptmtype,
					$pageindex, @phos );
			}
			elsif ( $key eq 'Methylation'
				&& ( $search_ptmtype eq '1' || $search_ptmtype eq '12' ) )
			{
				print_ptm_info( $key, $search_target, $search_ptmtype,
					$pageindex, @meth );
			}
			elsif ( $key eq 'Glycosylation'
				&& ( $search_ptmtype eq '2' || $search_ptmtype eq '12' ) )
			{
				print_ptm_info( $key, $search_target, $search_ptmtype,
					$pageindex, @glyc );
			}
			elsif ( $key eq 'Acetylation'
				&& ( $search_ptmtype eq '3' || $search_ptmtype eq '12' ) )
			{
				print_ptm_info( $key, $search_target, $search_ptmtype,
					$pageindex, @acet );
			}
			elsif ( $key eq 'Amidation'
				&& ( $search_ptmtype eq '4' || $search_ptmtype eq '12' ) )
			{
				print_ptm_info( $key, $search_target, $search_ptmtype,
					$pageindex, @amid );
			}
			elsif ( $key eq 'Hydroxylation'
				&& ( $search_ptmtype eq '5' || $search_ptmtype eq '12' ) )
			{
				print_ptm_info( $key, $search_target, $search_ptmtype,
					$pageindex, @hydr );
			}
			elsif ( $key eq 'Myristoylation'
				&& ( $search_ptmtype eq '6' || $search_ptmtype eq '12' ) )
			{
				print_ptm_info( $key, $search_target, $search_ptmtype,
					$pageindex, @myri );
			}
			elsif ( $key eq 'Sulfation'
				&& ( $search_ptmtype eq '7' || $search_ptmtype eq '12' ) )
			{
				print_ptm_info( $key, $search_target, $search_ptmtype,
					$pageindex, @sulf );
			}
			elsif ( $key eq 'GPI-Anchor'
				&& ( $search_ptmtype eq '8' || $search_ptmtype eq '12' ) )
			{
				print_ptm_info( $key, $search_target, $search_ptmtype,
					$pageindex, @gpi );
			}
			elsif ( $key eq 'Disulfide'
				&& ( $search_ptmtype eq '9' || $search_ptmtype eq '12' ) )
			{
				print_ptm_info( $key, $search_target, $search_ptmtype,
					$pageindex, @disu );
			}
			elsif (
				$key eq 'Ubiquitination'
				&& (   $search_ptmtype eq '10'
					|| $search_ptmtype eq '12' )
			  )
			{
				print_ptm_info( $key, $search_target, $search_ptmtype,
					$pageindex, @ubiq );
			}
			else {
			}
		}
		print <<HTML;
	</div><!-- end tabs-->
HTML

	}

}
1;
