#input gene or protein
BEGIN{
delete $INC{"/home/bmi/wwwroot/mptm/cgi-bin/mysql.pl"}
}
use GD;
use GD::Graph;
use GD::Graph::bars;
use JSON::PP;
require '/home/bmi/wwwroot/mptm/cgi-bin/mysql.pl';
#取数组中最大的数
sub get_max {
	my $max_value = shift @_;
	foreach (@_) {
		if ( $_ gt $max_value ) {
			$max_value = $_;
		}
	}
	$max_value;
}

#根据关键词从数据库中获取数据，用于图表展示
sub get_sql_data {

	my @ptm_name = (
		"Phosphorylation", "Methylation",
		"Glycosylation",   "Acetylation",
		"Amidation",       "Hydroxylation",
		"Myristoylation",  "Sulfation",
		"GPI-Anchor",      "Disulfide",
		"Ubiquitination"
	);
	my $rev_search = shift;

	#将搜索的多个关键字拆开存入数组
	my @rev_arr = split( ',', $rev_search );

	#初始化data
	my @data;
	my $self = newdb( "localhost", "ptminfo", "root", "1234" );

	#结果存入数据库
	my $rows;    #记录查询结果条数
	for ( $i = 0 ; $i < @rev_arr ; $i++ ) {
		for ( my $j = 1 ; $j < 12 ; $j++ ) {

			#存入数据库错误，继续执行下面程序
			eval {
				$rows = dosql( $self,
"SELECT * FROM ptmdetails where substrate REGEXP '$rev_arr[$i]' AND PTM_Type = '$ptm_name[$j-1]'"
				);
			};
			$data[0][$i] = $rev_arr[$i];
			if ( $rows eq '0E0' ) {
				$rows = 0;
			}
			$data[$j][$i] = $rows;
		}
	}

	return @data;
}

sub generate_bars {

	my @data = @_;

	my $im = GD::Graph::bars->new( 980, 600 );
	$im->set(

		#x_label       => 'ptm type',
		y_label => 'Number of literatures',
		title   => 'Distribution of protein post-translation modifications',

		#y_max_value      => 4,
		y_tick_number    => 8,
		y_label_skip     => 1,       #每隔几个显示一个坐标值
		bar_spacing      => 0,       #同组柱间距
		legend_placement => 'RT',    #图列位置
		bargroup_spacing => 15,      #柱间间距
		accent_treshold  => 200,
		show_values      => 1,

		#use_axis =>[1,1,1],
		#x_label_position => 0,
		accentclr => '#D3D3D3',
		valuesclr => 'black',
		dclrs     => [
			"#FF0000", "#0000FF", "#4B0082", "#00FF00", "#FFFF00", "#74EE08",
			"#EAAB60", "#E6A5F0", "#767476", "#000000", "#FF1493"
		],
		transparent => 1,            #0或1 设为1 背景将变为透明
		l_margin    => 1,
		b_margin    => 1,
		r_margin    => 1,
		t_margin    => 11
	) || die $im->error;
	$im->set( x_labels_vertical => 0, values_vertical => 1 );
	$im->set_legend(
		"Phosphorylation", "Methylation",
		"Glycosylation",   "Acetylation",
		"Amidation",       "Hydroxylation",
		"Myristoylation",  "Sulfation",
		"GPI-Anchor",      "Disulfide",
		"Ubiquitination"
	);
	my $gd = $im->plot( \@data ) || die $im->error;
	open( IMG, ">../statistics_file/barimage.jpeg" ) or die $!;
	binmode IMG;
	print IMG $gd->jpeg();

}
#site normalization
sub site_normalization {
	my @site_arr = @_;

	for ( my $i = 0 ; $i < @site_arr - 1 ; $i++ ) {
		if ( $site_arr[$i] =~ /(\d+)/ ) {

			$site_arr[$i] =
			  uc( substr( $site_arr[$i], 0, 1 ) )
			  . $1;       #这里以后还要进一步判断
		}
	}

	return @site_arr;

}
#去除明显的激酶错误
sub drop_error_kinase{
	my @arr = @_;
	my @right_arr;
	foreach(@arr){
		if($_ !~ /RNA/){
			push(@right_arr,$_);
		}
	}
	return @right_arr;
}
sub preprocess {
	my $cgi = shift;    # recieve value from main
	my $quick_search =
	  $cgi->param('quick_search');    # recieve search' value from browser
	my @data = get_sql_data($quick_search);
	generate_bars(@data);
	my $json = cytoscape_graph($quick_search);
	print_HTML($json);

}

sub main {

	chdir("/home/bmi/wwwroot/mptm/cgi-bin/");
	#chdir("/var/www/mptm/cgi-bin/");
	my $statistics_cgi = CGI->new;
	preprocess($statistics_cgi);
}

#产生生成激酶与底物作用的关系图的数据 dataSchema
sub cytoscape_graph {
	my $search_content = shift;

	#	$search_content='H3';

	#将搜索的多个关键字拆开存入数组
	my @rev_arr = split( ',', $search_content );

	#接受多个数组的引用
	my $self     = newdb( "localhost", "ptminfo", "root", "1234" );
	my $param    = {};
	my $arrnodes = [];
	$param->{'name'} = "label";
	$param->{'type'} = "string";
	push( @$arrnodes, $param );
	$param           = {};
	$param->{'name'} = "foo";
	$param->{'type'} = "string";
	push( @$arrnodes, $param );
	$param           = {};
	$param->{'name'} = "Pmid";
	$param->{'type'} = "string";
	push( @$arrnodes, $param );
	$param           = {};
	$param->{'name'} = "Site";
	$param->{'type'} = "string";
	push( @$arrnodes, $param );
	$param           = {};
	$param->{'name'} = "PTM_Type";
	$param->{'type'} = "string";
	push( @$arrnodes, $param );
	$param           = {};
	$param->{'name'} = "Text_evidence";
	$param->{'type'} = "string";
	push( @$arrnodes, $param );
	$param           = {};
	$param->{'name'} = "Phenotype";
	$param->{'type'} = "string";
	push( @$arrnodes, $param );

	$param = {};
	my $arredges = [];
	$param->{'name'} = "label";
	$param->{'type'} = "string";
	push( @$arredges, $param );
	$param           = {};
	$param->{'name'} = "PTM_Type";
	$param->{'type'} = "string";
	push( @$arredges, $param );
	my $dataSchema = {};
	$dataSchema->{'nodes'} = $arrnodes;
	$dataSchema->{'edges'} = $arredges;
	my %relative_s_k = ();
	my %s_k          = ();
	my %ptminfo      = ();    #存储每条ptm过程记录的信息
	my %ptminfo_data =
	  ();    #存储每条ptm过程记录的信息,来自ptmdata表
	my %diseaseinfo =
	  ();    # 存储每条记录和疾病相关信息，来自disease表
	my @result_ptm_kinase;

	for ( my $i = 0 ; $i < @rev_arr ; $i++ ) {
	#$rev_arr[$i] = lc($rev_arr[$i]); #turn to lower
		#from ptmdatails
		my @result = query( $self,
			"SELECT * FROM ptmdetails WHERE LOWER(substrate) REGEXP '$rev_arr[$i]'" );

		#from ptmdata
		my @result_ptmdata = query_ptmdata( $self,
			"SELECT * FROM ptmdata WHERE LOWER(protein) REGEXP '$rev_arr[$i]'" );

		#from table disease
		my @result_disease = query_disease( $self,
			"SELECT * FROM disease WHERE LOWER(protein) REGEXP '$rev_arr[$i]'" );

		my $sub = $rev_arr[$i];
		for ( my $j = 0 ; $j < @result ; $j++ ) {
			if ( $result[$j][2] ne 'NULL' && $result[$j][3] ne 'NULL' ) {
				my @sub_arr = split(',',$result[$j][2]);
				my $sb = $sub;                                 #substrate
				#去除正则匹配时出现的不完全情况 比如把CK2当作K2
				if(grep { $_ eq $sb } @sub_arr){
				my @kinase_arr = split( ',', $result[$j][3] );
				@kinase_arr = drop_error_kinase(@kinase_arr);
				for ( my $i = 0 ; $i < @kinase_arr ; $i++ ) {
					my $si = $kinase_arr[$i];                    #kinase
					$s_k{$si}++;
					$result_ptm_kinase[($j*@kinase_arr)+$i] = $si;
					$ptminfo{$si} =
					    $result[$j][0] . '&'
					  . $result[$j][4] . '&'
					  . $result[$j][6] . '&'
					  . $result[$j][5];
					my $ty = $result[$j][6];                   #type
					$s_k{$sb}++;
					$relative_s_k{ $sb . '&' . $si } = $ty;
				}
				}
			}
		}

		#table ptmdata
		for ( my $j = 0 ; $j < @result_ptmdata ; $j++ ) {
			if (   $result_ptmdata[$j][1] ne 'NULL'
				&& $result_ptmdata[$j][4] ne 'NULL' )
			{
				my $sb = $sub;                                        #substrate
				my @kinase_arr = split( ',', $result_ptmdata[$j][4] );
				for ( my $i = 0 ; $i < @kinase_arr ; $i++ ) {
					my $si = $kinase_arr[$i];                           #site
					$s_k{$si}++;
			

					#protein,pro_id,kinase,kin_id,PTM_Type
					$ptminfo_data{$si} =
					    $result_ptmdata[$j][1] . '&'
					  . $result_ptmdata[$j][2] . '&'
					  . $result_ptmdata[$j][7] . '&'
					  . $result_ptmdata[$j][5] . '&'
					  . $result_ptmdata[$j][8];
					my $ty = $result_ptmdata[$j][8];                  #type
					$s_k{$sb}++;
					$relative_s_k{ $sb . '&' . $si } = $ty;
				}
			}
		}

		#table disease
		for ( my $j = 0 ; $j < @result_disease ; $j++ ) {
			if ( $result_disease[$j][1] ne 'NULL' ) {
				my $sb = $sub;                                        #substrate
				$diseaseinfo{$sb} .= $result_disease[$j][1].".    ";
			}
		}

	}

	if (%s_k) {
		my $i = 1;
		while ( ( my $key, my $value ) = each %s_k ) {
			$s_k{$key} = $i;
			$i++;
		}
	}
	my $darrnodes = [];    #节点数组
	if (%s_k) {
		while ( ( my $key, my $value ) = each %s_k ) {

			$param            = {};
			$param->{'id'}    = "$value";
			$param->{'label'} = "$key";     #substrate
			my @ptminfo      = split( '&', $ptminfo{$key} );
			my @ptminfo_data = split( '&', $ptminfo_data{$key} );
			if ( grep { $_ eq $key } @rev_arr ) {
				$param->{'foo'}       = "sub";
				$param->{'Phenotype'} = $diseaseinfo{$key};
			}
			elsif ( grep { $_ eq $key } @result_ptm_kinase ) {
				$param->{'foo'}           = "";
				$param->{'Pmid'}          = "$ptminfo[0]";
				$param->{'Site'}        = "$ptminfo[1]";
				$param->{'PTM_Type'}      = "$ptminfo[2]";
				$param->{'Text_evidence'} = "$ptminfo[3]";				
			}
			else {
				$param->{'foo'}      = "";
				$param->{'PTM_Type'} = "$ptminfo_data[4]";
				$param->{'Site'}   = "$ptminfo_data[2]";
			}
			push( @$darrnodes, $param );

		}
	}
	else {    #target have no site
		for ( my $i = 0 ; $i < @rev_arr ; $i++ ) {
			$param            = {};
			$param->{'id'}    = "$i+1";
			$param->{'label'} = "$rev_arr[$i]";    #substrate
			$param->{'foo'}   = "sub";
			push( @$darrnodes, $param );
		}
	}
	my $darredges = [];                            #边数组

	if ( %relative_s_k && %s_k ) {
		while ( ( my $key, my $value ) = each %relative_s_k ) {
			my @split_arr = split( '&', $key );
			$param             = {};
			$param->{'id'}     = "$s_k{$split_arr[0]}to$s_k{$split_arr[1]}";
			$param->{'target'} = "$s_k{$split_arr[0]}";
			$param->{'source'} = "$s_k{$split_arr[1]}";
			$param->{'label'}  = "$value";
			$param->{'PTM_Type'}    = "$value";
			push( @$darredges, $param );
		}
	}

	my $data = {};
	$data->{'nodes'} = $darrnodes;
	if (%relative_s_k) {
		$data->{'edges'} = $darredges;
	}

	my $jsonhash = {};
	$jsonhash->{'dataSchema'} = $dataSchema;

	#if (%relative_s_k) {
	$jsonhash->{'data'} = $data;

	#}

	my $json = JSON::PP->new->utf8->encode($jsonhash);
}

sub print_HTML {
	my $json = shift;
	print <<HTML;
Content-type: text/html;

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>NetWork</title>
<link rel="shortcut icon" href="../images/icon.png" type="image/x-icon" />
<link href="../css/default.css" rel="stylesheet" type="text/css" />
<link href="../css/network.css" rel="stylesheet" type="text/css" />
<script src="../javascript/bar.js" type="text/javascript"></script>
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
  <!-- JSON support for IE (needed to use JS API) -->
        <script type="text/javascript" src="../javascript/js/json2.min.js"></script>
        
        <!-- Flash embedding utility (needed to embed Cytoscape Web) -->
        <script type="text/javascript" src="../javascript/js/AC_OETags.min.js"></script>
        
        <!-- Cytoscape Web JS API (needed to reference org.cytoscapeweb.Visualization) -->
        <script type="text/javascript" src="../javascript/js/cytoscapeweb.min.js"></script>
        
        <script type="text/javascript">
            window.onload=function() {
                // id of Cytoscape Web container div
                var div_id = "cytoscapeweb";
                
                // you could also use other formats (e.g. GraphML) or grab the network data via AJAX
                var network_json = $json;
                //create the mapper
                var colornodesMapper = {
               	attrName:"foo",
                	entries:[{attrValue:"sub",value:"#ff0000"},{attrValue:"my_site",value:"#29E2E9"},{attrValue:"site",value:"#0000ff"}]
                };
               var coloredgesMapper = {
                	attrName:"label",
                	entries:[{attrValue:"Phosphorylation",value:"#ff0000"},{attrValue:"Methylation",value:"#0000ff"},{attrValue:"Glycosylation",value:"#4B0082"},{attrValue:"Acetylation",value:"#00FF00"},{attrValue:"Amidation",value:"#FFFF00"},
                	{attrValue:"Hydroxylation",value:"#74EE08"},{attrValue:"Myristoylation",value:"#EAAB60"},{attrValue:"Sulfation",value:"#E6A5F0"},{attrValue:"GPI-Anchor",value:"#767476"},{attrValue:"Disulfide",value:"#000000"},
                	{attrValue:"Ubiquitination",value:"#FF1493"}]
               };
                //visual style
                var visual_style = {
                	global:{
                		backgroundColor:"#FFFFFF"
                	},
                	nodes:{
                		color:{discreteMapper:colornodesMapper}
                	},
                	edges:{
                		color:{discreteMapper:coloredgesMapper}
                	}
                	
                };
                // initialization options
                var options = {
                    // where you have the Cytoscape Web SWF
                    swfPath: "../javascript/swf/CytoscapeWeb",
                    // where you have the Flash installer SWF
                    flashInstallerPath: "../javascript/swf/playerProductInstall"
                };
                
                // init and draw
                var vis = new org.cytoscapeweb.Visualization(div_id, options);
            
    //callback when Cytoscape Web has finished drawing
                vis.ready(function(){
                	vis.addListener("click","nodes",function(event){handle_click(event);})
                	.addListener("click","edges",function(event){handle_click(event);
                	});
                function handle_click(event){
                	var target = event.target;
                	clear();
                	//print("clickname="+event.group);
                	for(var i in target.data){
                		var variable_name = i;
                		var variable_value = target.data[i];
				if(variable_value != null && variable_value !='' && variable_value != 'NULL' && variable_name !='label' && variable_name !='id' && variable_name !='target' && variable_name !='source'){
                		print(variable_name+"="+variable_value);
}
                	}
                }
                function clear(){
                	document.getElementById("note").innerHTML="";
                }
                function print(msg){
                	document.getElementById("note").innerHTML += "<p>" +msg+"</p>";
                }
                });
          
                
             	var draw_options = {
             		network: network_json,
             		visualStyle:visual_style
             	}
                vis.draw(draw_options);
            };
        </script>
        <style>
        #cytoscapeweb{
        	height:600px;
        	width:980px;
        }
        </style>
</head>

<body>
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
</div> <!-- end nav -->
	<div id="page">	
		<div id="content">
		<div id="cytoscapeweb">
		</div>
		<div id="note">
		Click nodes for details!
        </div>
        </br></br>
        <img src= ../statistics_file/barimage.jpeg>
		</div><!--end content-->
		<div style="clear: both;">&nbsp;</div>
	</div><!--end page-->
</div><!--end container-->
<div id="roll"><div title="Top" id="roll_top"></div></div> 
<div id="footer">
<p class="copyright">&copy;&nbsp;&nbsp;2013 All Rights Reserved &nbsp;&bull;&nbsp; Design by HI_lab @ USTC.</p>
</div><!--end footer-->
</body>
</html>
HTML

}
main();
