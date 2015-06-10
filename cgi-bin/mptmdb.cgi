BEGIN{
delete $INC{"/home/bmi/wwwroot/mptm/cgi-bin/mysql.pl"}
}
require '/home/bmi/wwwroot/mptm/cgi-bin/mysql.pl';
sub preprocess {
	my $cgi = shift;    # recieve value from main
	my $mptmdb_search =
	  $cgi->param('mptmdb_search');    # recieve search' value from browser

	my $select = $cgi->param('select');
	print $cgi->header(-type=>"application/text",charset=>"utf-8");
	#substrate
	if($select && $mptmdb_search){
		getdata_ptmdetails($select,$mptmdb_search);
	}
}
sub main {

	chdir("/home/bmi/wwwroot/mptm/cgi-bin/");
	#chdir("/var/www/mptm/cgi-bin/");
	my $mptmdb_cgi = CGI->new;
	preprocess($mptmdb_cgi);
}
sub remove_duplicate {
		my @array = @_;
		my %count;
		my @uniq_array = grep { ++$count{$_} < 2; } @array;
	}
sub print_no_info{
	print qq(<div class="noin" align="center" style="margin-top:0px;">
		<img src="images/no-result.png"/>
		<div align="center" class="sorry">Sorry,No Search Result!</div>
		<br/>
		<div align="center" class="back"><a href="http://bioinformatics.ustc.edu.cn/mptm/ptmdb.html">Back To Search</a></div>
		</div>);
}
sub print_info{
	my ($mptmdb_search,@info_result) = @_;
	my @rec_pmid;
	my @ptm_type;
	my @text_evidence;
	for(my $i=0;$i<@info_result-1;$i++){
		my $pmid = $info_result[$i][0];
		my $ptm_type = $info_result[$i][6];
		my $text_evidence = $info_result[$i][5];
		$text_evidence =~s/(\b$mptmdb_search\b)/<span class=\"mptmdb_format\">$1<\/span>/ig; 
		if($info_result[$i][0] != $info_result[$i+1][0]){
		push(@rec_pmid,$pmid);
		push(@ptm_type,$ptm_type);
		push(@text_evidence,$text_evidence);
		}
	}
	print qq(<div id="selIt" style="text-align: center">
            <tbody>
          <!--  <input type="checkbox"  name="chk_all" id="chk_all" checked="0"  onclick="selall_none();selType()"/>All-->
            <input type="checkbox"  name="chk_list" id="Phosphorylation"  onclick="selType()" value="1" />Phosphorylation
            <input type="checkbox"  name="chk_list" id="Methylation" onclick="selType()" value="2"/>Methylation
            <input type="checkbox"  name="chk_list" id="Glycosylation"  onclick="selType()" value="3"/>Glycosylation
            <input type="checkbox"  name="chk_list" id="Acetylation"  onclick="selType()" value="4"/>Acetylation
            <input type="checkbox"  name="chk_list" id="Hydroxylation" onclick="selType()" value="5"/>Hydroxylation<br/>
            <input type="checkbox"  name="chk_list" id="Myristoylation"  onclick="selType()" value="6"/>Myristoylation
            <input type="checkbox"  name="chk_list" id="Amidation"  onclick="selType()" value="7"/>Amidation
            <input type="checkbox"  name="chk_list" id="Sulfation"  onclick="selType()" value="8"/>Sulfation
            <input type="checkbox"  name="chk_list" id="GPI-Anchor" onclick="selType()" value="9"/>GPI-Anchor
            <input type="checkbox"  name="chk_list" id="Disulfide"  onclick="selType()" value="10"/>Disulfide
            <input type="checkbox"  name="chk_list" id="Ubiquitination" onclick="selType()" value="11"/>Ubiquitination
            </tbody>
    </div> <br />
	
);
	print qq(<table rules=rows frame=hsides id = "tblSort">);
	my $self = newdb( "localhost", "ptminfo", "root", "1234" );

	print qq(<thead style = "color:#000; background-color:#ea5302; line-height: 35px" >
<tr >
<th style = "cursor: pointer; text-align: center;" > PMID <img id="sort_pmid" src="images/sort_a.png" style="width: 20px;height: 20px" onclick="sortTable('tblSort',0,'int'),change_pmid()"> </th >
<th style = "cursor: pointer; text-align: center" > Text Evidence</th >
<th style = "cursor: pointer; text-align: center" > Type <img id="sort_type" src="images/sort_a.png" style="width: 20px;height: 20px" onclick="sortTable('tblSort',2),change_type()"></th >
<th style = "cursor: pointer; text-align: center" > Date <img id="sort_date" src="images/sort_a.png" style="width: 20px;height: 20px" onclick="sortTable('tblSort',3,'date'),change_date()"></th >
<th style = "cursor: pointer; text-align: center">E</th >
<th style = "cursor: pointer; text-align: center">N</th >
</tr >
</thead> );
	for(my $i=0;$i<@rec_pmid;$i++){
	my @text_result_search = query_ptmtext( $self, "SELECT * FROM ptmtext WHERE pmid = '$rec_pmid[$i]'" );
	my $pubdate = $text_result_search[0][7];
	if($pubdate =~ /NULL/){
		$pubdate = "****-**-**";
	}else{
		$pubdate =~ s/(\d{4})(\d{2})(\d{2})/$1-$2-$3/;
	}

print qq(
<tr class="css1" onMouseOver="mouseOver(this)" onMouseOut="mouseOut(this)">
	<td>$rec_pmid[$i]</td>
	<td>$text_evidence[$i]</td>
	<td>$ptm_type[$i]</td>
	<td>$pubdate</td>
	<td><a href="http://bioinformatics.ustc.edu.cn/mptm/cgi-bin/results_original.cgi?radio=radio_pmid&sequences=$rec_pmid[$i]&pageindex=1&isfirst=0" target="_blank"><img src="images/e.png"  alt="e" title="Show Mined Data!" /></a></td>
<td><a href="http://bioinformatics.ustc.edu.cn/mptm/cgi-bin/statistics.cgi?quick_search=$mptmdb_search" target="_blank"><img src="images/n.png"  alt="n" title="Show NetWork!" /></a></td>
</tr>);
	} 
		print qq(<table>);
}


sub getdata_ptmdetails{
	my ($select,$mptmdb_search) = @_;
	my $self = newdb( "localhost", "ptminfo", "root", "1234" );
				eval {
				$rows = dosql( $self,
			"SELECT * FROM ptmdetails WHERE $select REGEXP '$mptmdb_search'");
			};
			#no results
			if ( $rows eq '0E0' ) {
				print_no_info();
			}else{
					my @result = query( $self,
			"SELECT * FROM ptmdetails WHERE $select REGEXP '$mptmdb_search'" );
			print_info($mptmdb_search,@result);
			}
}
main();

