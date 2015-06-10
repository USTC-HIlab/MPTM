use DBI;
use Data::Dumper;
use strict;
use warnings;
sub newdb {    
	my ( $host, $dbName, $user, $password ) = @_;
	$host     = "localhost" if !defined($host)     or $host     eq "";
	$dbName   = "mysql"     if !defined($dbName)   or $dbName   eq "";
	$user     = "root"      if !defined($user)     or $user     eq "";
	$password = ""          if !defined($password) or $password eq "";

	my $self = {
		"host"     => $host,
		"database" => $dbName,
		"user"     => $user,
		"password" => $password
	};

	return $self;
}
sub query {    #sql string for select
	my ( $self, $sql ) = @_;
	my @result;

	# print $sql;
	# exit();
	my ( $database, $host, $user, $password ) =
	  ( $self->{database}, $self->{host}, $self->{user}, $self->{password} );

	my $dbh = DBI->connect( "DBI:mysql:database=$database;host=$host",
		$user, $password )
	  or die "Can't connect to database: $DBI::errstr\n";    #连接数据库
	my $sth = $dbh->prepare($sql);                           #准备
	$sth->execute();                                         #执行

my $i = 0;
	while ( my $res = $sth->fetchrow_hashref() ) {
		$result[$i][0] = $res->{'pmid'};
		$result[$i][1] = $res->{'sentence_id'};
		$result[$i][2] = $res->{'substrate'};
		$result[$i][3] = $res->{'kinase'};
		$result[$i][4] = $res->{'site'};
		$result[$i][5] = $res->{'text_evidence'};
		$result[$i][6] = $res->{'ptm_type'};
		$result[$i][7] = $res->{'disease'};
		$result[$i][8] = $res->{'species'};
		$result[$i][9] = $res->{'crosstalk'};
		$i = $i+1;
	} #打印抽取结果                                             #打印抽取结果
	$sth->finish;        #结束句柄
	$dbh->disconnect;    #断开
			return @result
}
sub query_resultcache{
	    #sql string for select
	my ( $self, $sql ) = @_;
	my @result;

	# print $sql;
	# exit();
	my ( $database, $host, $user, $password ) =
	  ( $self->{database}, $self->{host}, $self->{user}, $self->{password} );

	my $dbh = DBI->connect( "DBI:mysql:database=$database;host=$host",
		$user, $password )
	  or die "Can't connect to database: $DBI::errstr\n";    #连接数据库
	my $sth = $dbh->prepare($sql);                           #准备
	$sth->execute();                                         #执行

#	   while(my @res = $sth->fetchrow_array())    {
#	       push @result, \@res;
#	    }
my $i = 0;
	while ( my $res = $sth->fetchrow_hashref() ) {
		$result[$i][0] = $res->{'searchtarget'};
		$result[$i][1] = $res->{'all_pmids_len'};
		$result[$i][2] = $res->{'pmids_res'};
		$result[$i][3] = $res->{'time'};
		$i = $i+1;
	} #打印抽取结果                                             #打印抽取结果
	$sth->finish;        #结束句柄
	$dbh->disconnect;    #断开
			return @result
	
}
sub query_ptmtext{
	    #sql string for select
	my ( $self, $sql ) = @_;
	my @result;

	# print $sql;
	# exit();
	my ( $database, $host, $user, $password ) =
	  ( $self->{database}, $self->{host}, $self->{user}, $self->{password} );

	my $dbh = DBI->connect( "DBI:mysql:database=$database;host=$host",
		$user, $password )
	  or die "Can't connect to database: $DBI::errstr\n";    #连接数据库
	my $sth = $dbh->prepare($sql);                           #准备
	$sth->execute();                                         #执行

#	   while(my @res = $sth->fetchrow_array())    {
#	       push @result, \@res;
#	    }
my $i = 0;
	while ( my $res = $sth->fetchrow_hashref() ) {
		$result[$i][0] = $res->{'pmid'};
		$result[$i][1] = $res->{'origin_text'};
		$result[$i][2] = $res->{'disease_text'};
		$result[$i][3] = $res->{'organisms_text'};
		$result[$i][4] = $res->{'ptm_type'};
		$result[$i][5] = $res->{'goterms'};
		$result[$i][6] = $res->{'pmcid'};    
		$result[$i][7] = $res->{'pubdate'}; 
		$result[$i][8] = $res->{'title'};
		$i = $i+1;
	} #打印抽取结果                                             #打印抽取结果
	$sth->finish;        #结束句柄
	$dbh->disconnect;    #断开
			return @result
	
}
sub query_genenorm{
	    #sql string for select
	my ( $self, $sql ) = @_;
	my @result;

	# print $sql;
	# exit();
	my ( $database, $host, $user, $password ) =
	  ( $self->{database}, $self->{host}, $self->{user}, $self->{password} );

	my $dbh = DBI->connect( "DBI:mysql:database=$database;host=$host",
		$user, $password )
	  or die "Can't connect to database: $DBI::errstr\n";    #连接数据库
	my $sth = $dbh->prepare($sql);                           #准备
	$sth->execute();                                         #执行

#	   while(my @res = $sth->fetchrow_array())    {
#	       push @result, \@res;
#	    }
my $i = 0;
	while ( my $res = $sth->fetchrow_hashref() ) {
		$result[$i][0] = $res->{'pmid'};
		$result[$i][1] = $res->{'gene_id'};
		$result[$i][2] = $res->{'uniprotkb_id'};
		$result[$i][3] = $res->{'gene_name'};
		$result[$i][4] = $res->{'protein_name'};
		$result[$i][5] = $res->{'organism_name'};
		$result[$i][6] = $res->{'score'};    
		$result[$i][7] = $res->{'mined_data_name'};    
		$result[$i][8] = $res->{'uniprotkb_organism'};  
		$result[$i][9] = $res->{'uniprot_en'};   
		$result[$i][10] = $res->{'uniprotkb_gene_name'}; 
		$i = $i+1;
	} #打印抽取结果                                             #打印抽取结果
	$sth->finish;        #结束句柄
	$dbh->disconnect;    #断开
			return @result
	
}
sub query_ptmdata {    #sql string for select
	my ( $self, $sql ) = @_;
	my @result;

	# print $sql;
	# exit();
	my ( $database, $host, $user, $password ) =
	  ( $self->{database}, $self->{host}, $self->{user}, $self->{password} );

	my $dbh = DBI->connect( "DBI:mysql:database=$database;host=$host",
		$user, $password )
	  or die "Can't connect to database: $DBI::errstr\n";    #连接数据库
	my $sth = $dbh->prepare($sql);                           #准备
	$sth->execute();                                         #执行

#	   while(my @res = $sth->fetchrow_array())    {
#	       push @result, \@res;
#	    }
my $i = 0;
	while ( my $res = $sth->fetchrow_hashref() ) {
	#	$result[$i][0] = $res->{'id'};
		$result[$i][1] = $res->{'protein'};
		$result[$i][2] = $res->{'pro_id'};
		$result[$i][3] = $res->{'pro_org'};
		$result[$i][4] = $res->{'kinase'};
		$result[$i][5] = $res->{'kin_id'};
		$result[$i][6] = $res->{'kin_org'};
		$result[$i][7] = $res->{'site'};
		$result[$i][8] = $res->{'ptm_type'};
		$i = $i+1;
	} #打印抽取结果                                             #打印抽取结果
	$sth->finish;        #结束句柄
	$dbh->disconnect;    #断开
			return @result
}
sub query_disease {
	    #sql string for select
	my ( $self, $sql ) = @_;
	my @result;

	# print $sql;
	# exit();
	my ( $database, $host, $user, $password ) =
	  ( $self->{database}, $self->{host}, $self->{user}, $self->{password} );

	my $dbh = DBI->connect( "DBI:mysql:database=$database;host=$host",
		$user, $password )
	  or die "Can't connect to database: $DBI::errstr\n";    #连接数据库
	my $sth = $dbh->prepare($sql);                           #准备
	$sth->execute();                                         #执行

#	   while(my @res = $sth->fetchrow_array())    {
#	       push @result, \@res;
#	    }
my $i = 0;
	while ( my $res = $sth->fetchrow_hashref() ) {
	#	$result[$i][0] = $res->{'id'};
		$result[$i][1] = $res->{'disease'};
		$result[$i][2] = $res->{'protein'};
		$result[$i][3] = $res->{'org'};
		$result[$i][4] = $res->{'ptm_type'};
		$i = $i+1;
	} #打印抽取结果                                             #打印抽取结果
	$sth->finish;        #结束句柄
	$dbh->disconnect;    #断开
			return @result
	
}
sub query_goterms{
	
	    #sql string for select
	my ( $self, $sql ) = @_;
	my @result;

	# print $sql;
	# exit();
	my ( $database, $host, $user, $password ) =
	  ( $self->{database}, $self->{host}, $self->{user}, $self->{password} );

	my $dbh = DBI->connect( "DBI:mysql:database=$database;host=$host",
		$user, $password )
	  or die "Can't connect to database: $DBI::errstr\n";    #连接数据库
	my $sth = $dbh->prepare($sql);                           #准备
	$sth->execute();                                         #执行

#	   while(my @res = $sth->fetchrow_array())    {
#	       push @result, \@res;
#	    }
my $i = 0;
	while ( my $res = $sth->fetchrow_hashref() ) {
		$result[$i][0] = $res->{'goid'};
		$result[$i][1] = $res->{'goname'};
		$result[$i][2] = $res->{'gotype'};
		$i = $i+1;
	} #打印抽取结果                                             #打印抽取结果
	$sth->finish;        #结束句柄
	$dbh->disconnect;    #断开
			return @result
	
	
}
sub query_omimdata {
	    #sql string for select
	my ( $self, $sql ) = @_;
	my @result;

	# print $sql;
	# exit();
	my ( $database, $host, $user, $password ) =
	  ( $self->{database}, $self->{host}, $self->{user}, $self->{password} );

	my $dbh = DBI->connect( "DBI:mysql:database=$database;host=$host",
		$user, $password )
	  or die "Can't connect to database: $DBI::errstr\n";    #连接数据库
	my $sth = $dbh->prepare($sql);                           #准备
	$sth->execute();                                         #执行

#	   while(my @res = $sth->fetchrow_array())    {
#	       push @result, \@res;
#	    }
my $i = 0;
	while ( my $res = $sth->fetchrow_hashref() ) {
	#	$result[$i][0] = $res->{'id'};
		$result[$i][1] = $res->{'protein'};
		$result[$i][2] = $res->{'disease'};
		$result[$i][3] = $res->{'omim_id'};
		$i = $i+1;
	} #打印抽取结果                                             #打印抽取结果
	$sth->finish;        #结束句柄
	$dbh->disconnect;    #断开
			return @result
	
}

#执行一条语句
sub dosql {
	my ( $self, $sql ) = @_;
	my ( $database, $host, $user, $password ) =
	  ( $self->{database}, $self->{host}, $self->{user}, $self->{password}, );
	my $dbh = DBI->connect( "DBI:mysql:database=$database;host=$host",
		$user, $password )
	  or die "Can't connect to database: $DBI::errstr\n";    #连接数据库

	my $rows = $dbh->do($sql) or die "Can't execute $sql: $dbh->errstr\n";

	#    $dbh->commit or die "commit error :$dbh->errstr\n";
	$dbh->disconnect;                                        #断开

	return $rows;
}

#执行多条带占位符（?）的sql
sub execMultiSql {
	my ( $self, $sql, $params ) = @_;
	my ( $database, $host, $user, $password ) =
	  ( $self->{database}, $self->{host}, $self->{user}, $self->{password}, );
	my $dbh = DBI->connect( "DBI:mysql:database=$database;host=$host",
		$user, $password )
	  or die "Can't connect to database: $DBI::errstr\n";    #连接数据库

	my $sth  = $dbh->prepare($sql);
	my $rows = 0;
	eval {
		foreach my $ref_param ( @{$params} )
		{
			$rows += $sth->execute( @{$ref_param} );
		}

		$sth->finish;
		$dbh->disconnect;                                    #断开
	};
	if ($@) {
		print "an error: $@,continue... \n";
		$dbh->rollback;
		$sth->finish;
		$dbh->disconnect;
		return 0;
	}
	return $rows;
}
1;
