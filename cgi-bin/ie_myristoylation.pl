sub substrate_pattern_myrist {

	my @each_dep  = @_;
	my @substrate = ('NULL');

	for ( my $i = 0 ; $i < @each_dep ; $i++ ) {

		# (1) prep_of
		# one layer
		if ( $each_dep[$i] !~
			/prep_of\((?:de|un|non)myrist.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/prep_of\((?:myrist.*?)-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# prep_of(token, PRO)
		elsif ( $each_dep[$i] =~ /prep_of\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			if ( $token !~ /stimulation|content/i ) {
			  LAYER_2: for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist|myristoylates/i
							&& $word =~ /myrist|residues/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)myrist|myristoylates/i
										&& $2 =~ /myrist/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			  LAYER_2: for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist|myristoylates/i
							&& $word =~ /myrist|residues/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)myrist|myristoylates/i
										&& $2 =~ /myrist/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			}
		}

		# (2) nsubjpass( myristoylated |regulated, PRO)
		# one layer
		if ( $each_dep[$i] !~
			/nsubjpass\((?:de|un|non)myrist.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
/nsubjpass\((?:myristoylated|regulated|myristilated|myristylated|modified)-\d+'?, (PRO\d+)-\d+'?\)/i
		  )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# nsubjpass(token, PRO)
		elsif ( $each_dep[$i] =~ /nsubjpass\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			if ( $token !~ /stimulation|content/i ) {
			  LAYER_2: for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist|myristoylates/i
							&& $word =~ /myrist|targeted/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit|covalently/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)myrist|myristoylates/i
										&& $2 =~ /myrist|targeted/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			  LAYER_2: for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist|myristoylates/i
							&& $word =~ /myrist|targeted/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit|covalently/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)myrist|myristoylates/i
										&& $2 =~ /myrist|targeted/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			}
		}

		# (3) prep_in(token, PRO)
		# one layer
		if ( $each_dep[$i] !~
			/prep_in\((?:de|un|non)myrist.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
/prep_in\((?:.*?myrist.+?|localiz.+?|positions?|(?:ser|thr|tyr).*?-?\d+)-\d+'?, (PRO\d+)-\d+'?\)/i
		  )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# prep_in(token, PRO)
		elsif ( $each_dep[$i] =~ /prep_in\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
		  LAYER_2: for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
				if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
					|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
				{
					my $relation = $1;
					my $word     = $2;
					if (   $word !~ /(?:de|un|non)myrist/i
						&& $word =~ /myrist|ser|thr|tyr/i )
					{
						@substrate = push_finding( $pro1, @substrate )
						  ;    # push the found element into corresponding array
						@substrate =
						  substrate_appositive( \@each_dep, $i, \@substrate,
							$pro1 );    # search all possible appositives
						last LAYER_2;
					}

					# three layer
					elsif ( $word =~ /site/i ) {
						for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if (   $2 !~ /(?:de|un|non)myrist/i
									&& $2 =~ /myrist/i )
								{
									@substrate =
									  push_finding( $pro1, @substrate )
									  ; # push the found element into corresponding array
									@substrate =
									  substrate_appositive( \@each_dep, $i,
										\@substrate, $pro1 )
									  ;    # search all possible appositives
									last LAYER_2;
								}
							}
						}
						for ( my $k = $j + 1 ; $k < @each_dep ; $k++ ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if (   $2 !~ /(?:de|un|non)myrist/i
									&& $2 =~ /myrist/i )
								{
									@substrate =
									  push_finding( $pro1, @substrate )
									  ; # push the found element into corresponding array
									@substrate =
									  substrate_appositive( \@each_dep, $i,
										\@substrate, $pro1 )
									  ;    # search all possible appositives
									last LAYER_2;
								}
							}
						}
					}
				}
			}
		  LAYER_2: for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
				if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
					|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
				{
					my $relation = $1;
					my $word     = $2;
					if (   $word !~ /(?:de|un|non)myrist/i
						&& $word =~ /myrist|ser|thr|tyr/i )
					{
						@substrate = push_finding( $pro1, @substrate )
						  ;    # push the found element into corresponding array
						@substrate =
						  substrate_appositive( \@each_dep, $i, \@substrate,
							$pro1 );    # search all possible appositives
						last LAYER_2;
					}

					# three layer
					elsif ( $word =~ /site/i ) {
						for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if (   $2 !~ /(?:de|un|non)myrist/i
									&& $2 =~ /myrist/i )
								{
									@substrate =
									  push_finding( $pro1, @substrate )
									  ; # push the found element into corresponding array
									@substrate =
									  substrate_appositive( \@each_dep, $i,
										\@substrate, $pro1 )
									  ;    # search all possible appositives
									last LAYER_2;
								}
							}
						}
						for ( my $k = $j + 1 ; $k < @each_dep ; $k++ ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if (   $2 !~ /(?:de|un|non)myrist/i
									&& $2 =~ /myrist/i )
								{
									@substrate =
									  push_finding( $pro1, @substrate )
									  ; # push the found element into corresponding array
									@substrate =
									  substrate_appositive( \@each_dep, $i,
										\@substrate, $pro1 )
									  ;    # search all possible appositives
									last LAYER_2;
								}
							}
						}
					}
				}
			}
		}

		# (4) amod
		# one layer
		if ( $each_dep[$i] !~
			/amod\(PRO\d+-\d+'?, (?:de|un|non) myristoylated -\d+'?\)/i
			&& $each_dep[$i] =~
			/amod\((PRO\d+)-\d+'?, .*? myristoylated -\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}
		elsif ( $each_dep[$i] !~
			/amod\((?:de|un|non)myristoylation-\d+'?, (PRO\d+)-\d+'?\)/i
			&& $each_dep[$i] =~
			/amod\(.*?myristoylation-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# amod(token, PRO)
		elsif ( $each_dep[$i] =~ /amod\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;    # capture PRO

			if ( $token !~ /inhibit|prevent/ ) {
				for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {

					# amod(myrist|site, token)
					if (   $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i
						|| $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if (   $relation !~ /conj_and/
							&& $word !~ /(?:de|un|non)myrist/i
							&& $word =~ /myrist|site/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last;
						}
					}
				}
			}
		}

		# (5) dobj
		# one layer
		if ( $each_dep[$i] !~
			/dobj\((?:de|un|non)myrist.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/dobj\(.*?myristoylates?-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# dobj(token, PRO)
		elsif ( $each_dep[$i] =~ /dobj\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			if (   $token !~ /(?:de|un|non)myristoylated /i
				&& $token =~ /myristoylated|targeted/i )
			{
				my $flag = 0;
				for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $word =~ /is|was|are|were|be/i || $word =~ /not/i )
						{
							$flag = 1;
							last;
						}
					}
				}
				for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $word =~ /is|was|are|were|be/i || $word =~ /not/i )
						{
							$flag = 1;
							last;
						}
					}
				}
				if ( !$flag ) {
					@substrate = push_finding( $pro1, @substrate )
					  ;    # push the found element into corresponding array
					@substrate =
					  substrate_appositive( \@each_dep, $i, \@substrate,
						$pro1 );    # search all possible appositives
				}
			}
			elsif ( $token !~ /myristoylated/i ) {
				for ( my $j = $i - 1 ; $j > $i - 4 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if (   $word !~ /(?:de|un|non)myrist/i
							&& $word =~ /myrist|substrate/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last;
						}
					}
				}
				for ( my $j = $i + 1 ; $j < $i + 4 ; $j++ ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if (   $word !~ /(?:de|un|non)myrist/i
							&& $word =~ /myrist|substrate/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last;
						}
					}
				}
			}
		}

		# (6) nsubj
		# one layer
		if ( $each_dep[$i] !~
			/nsubj\((?:de|un|non)myristoylat.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/nsubj\((?:N-myristylated|myristoylated)-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# prep_of(token, PRO)
		elsif ( $each_dep[$i] =~ /nsubj\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			if ( $token !~ /stimulation|content/i ) {
			  LAYER_2: for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist|myristoylates/i
							&& $word =~ /myrist|sequence/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit|covalently/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)myrist|myristoylates/i
										&& $2 =~ /myrist|sequence/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			  LAYER_2: for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist|myristoylates/i
							&& $word =~ /myrist|sequence/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit|covalently/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)myrist|myristoylates/i
										&& $2 =~ /myrist|sequence/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			}
		}

		# other two layer
		# nsubj(PRO, token)
		elsif ( $each_dep[$i] =~ /nsubj\((PRO\d+)-\d+'?, (.+?-\d+'?)\)/i ) {
			my $token = $2;
			my $pro1  = $1;
		  LAYER_2: for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
				if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
					|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
				{
					my $relation = $1;
					my $word     = $2;
					if (   $word !~ /(?:de|un|non)myrist|myristoylates/i
						&& $word =~ /myrist|substrate/i )
					{
						@substrate = push_finding( $pro1, @substrate )
						  ;    # push the found element into corresponding array
						@substrate =
						  substrate_appositive( \@each_dep, $i, \@substrate,
							$pro1 );    # search all possible appositives
						last LAYER_2;
					}

					# three layer
					elsif ( $word =~ /site|residue|covalently/i ) {
						for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if ( $2 !~ /(?:de|un|non)myrist|myristoylates/i
									&& $2 =~ /myrist|substrate/i )
								{
									@substrate =
									  push_finding( $pro1, @substrate )
									  ; # push the found element into corresponding array
									@substrate =
									  substrate_appositive( \@each_dep, $i,
										\@substrate, $pro1 )
									  ;    # search all possible appositives
									last LAYER_2;
								}
							}
						}
						for ( my $k = $j + 1 ; $k < @each_dep ; $k++ ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if ( $2 !~ /(?:de|un|non)myrist|myristoylates/i
									&& $2 =~ /myrist|substrate/i )
								{
									@substrate =
									  push_finding( $pro1, @substrate )
									  ; # push the found element into corresponding array
									@substrate =
									  substrate_appositive( \@each_dep, $i,
										\@substrate, $pro1 )
									  ;    # search all possible appositives
									last LAYER_2;
								}
							}
						}
					}
				}
			}
		  LAYER_2: for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
				if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
					|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
				{
					my $relation = $1;
					my $word     = $2;
					if (   $word !~ /(?:de|un|non)myrist|myristoylates/i
						&& $word =~ /myrist|substrate/i )
					{
						@substrate = push_finding( $pro1, @substrate )
						  ;    # push the found element into corresponding array
						@substrate =
						  substrate_appositive( \@each_dep, $i, \@substrate,
							$pro1 );    # search all possible appositives
						last LAYER_2;
					}

					# three layer
					elsif ( $word =~ /site|residue|covalently/i ) {
						for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if ( $2 !~ /(?:de|un|non)myrist|myristoylates/i
									&& $2 =~ /myrist|substrate/i )
								{
									@substrate =
									  push_finding( $pro1, @substrate )
									  ; # push the found element into corresponding array
									@substrate =
									  substrate_appositive( \@each_dep, $i,
										\@substrate, $pro1 )
									  ;    # search all possible appositives
									last LAYER_2;
								}
							}
						}
						for ( my $k = $j + 1 ; $k < @each_dep ; $k++ ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if ( $2 !~ /(?:de|un|non)myrist|myristoylates/i
									&& $2 =~ /myrist|substrate/i )
								{
									@substrate =
									  push_finding( $pro1, @substrate )
									  ; # push the found element into corresponding array
									@substrate =
									  substrate_appositive( \@each_dep, $i,
										\@substrate, $pro1 )
									  ;    # search all possible appositives
									last LAYER_2;
								}
							}
						}
					}
				}
			}
		}

		# (7) nn
		# one layer
		if ( $each_dep[$i] !~
			/nn\((PRO\d+)-\d+'?, PRO\d+-(?:de|un|non)myristoylated-\d+'?\)/i
			&& $each_dep[$i] =~
			/nn\((PRO\d+)-\d+'?, PRO\d+-.*?myristoylated -\d+'?\)/i
			|| $each_dep[$i] =~ /nn\(myristoylat-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}
		elsif ( $each_dep[$i] =~ /nn\((PRO\d+)-\d+'?, Myrist.*?-\d+'?\)/i ) {
			my $pro1 = $1;
			@substrate = push_finding( $pro1, @substrate );
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 );
		}

		# two layer
		# nn(token, PRO)
		elsif ( $each_dep[$i] =~ /nn\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			if ( $token !~ /stimulation|content/i ) {
			  LAYER_2: for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist|myristoylates/i
							&& $word =~ /myrist/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)myrist|myristoylates/i
										&& $2 =~ /myrist/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			  LAYER_2: for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist|myristoylates/i
							&& $word =~ /myrist/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)myrist|myristoylates/i
										&& $2 =~ /myrist/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			}
		}

		# (8) partmod
		# one layer
		# partmod(PRO,  myristoylated |myristoylation)
		if ( $each_dep[$i] !~
			/partmod\(PRO\d+-\d+'?, (?:de|un|non)myrist.*?-\d+'?\)/i
			&& $each_dep[$i] =~
			/partmod\((PRO\d+)-\d+'?, .*?myristoylat(?:ed|ion)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# (9) appos
		# one layer
		# appos(PRO, [myrist|substrate])
		if ( $each_dep[$i] !~
			/appos\(PRO\d+-\d+'?, (?:de|un|non)myrist.*?-\d+'?\)/i
			&& $each_dep[$i] =~
			/appos\((PRO\d+)-\d+'?, (?:.*?myrist.*?|substrates?)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# appos([myrist|substrate], PRO)
		if ( $each_dep[$i] !~
			/appos\((?:de|un|non)myrist.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/appos\((?:.*?myrist.*?|substrates?)-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# appos(token, PRO)
		elsif ( $each_dep[$i] =~ /appos\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			if ( $token !~ /PRO\d+/ ) {
				for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $word =~ /myristoylation|substrate/i ) {
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last;
						}
					}
				}
				for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $word =~ /myristoylation|substrate/i ) {
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last;
						}
					}
				}
			}
		}

		# (10) prep_on
		# one layer
		# prep_on([myristoylation|site], PRO)
		if ( $each_dep[$i] !~
			/prep_on\((?:de|un|non)myristoylation-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/prep_on\((?:.*?myristoylation|sites?)-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# prep_on(token, PRO)
		elsif ( $each_dep[$i] =~ /prep_on\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
				if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
					|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
				{
					my $relation = $1;
					my $word     = $2;
					if ( $word =~ /site|substrate/i ) {
						@substrate = push_finding( $pro1, @substrate )
						  ;    # push the found element into corresponding array
						@substrate =
						  substrate_appositive( \@each_dep, $i, \@substrate,
							$pro1 );    # search all possible appositives
						last;
					}
				}
			}
			for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
				if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
					|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
				{
					my $relation = $1;
					my $word     = $2;
					if ( $word =~ /site|substrate/i ) {
						@substrate = push_finding( $pro1, @substrate )
						  ;    # push the found element into corresponding array
						@substrate =
						  substrate_appositive( \@each_dep, $i, \@substrate,
							$pro1 );    # search all possible appositives
						last;
					}
				}
			}
		}

		# (11) xsubj
		# one layer
		# xsubj( myristoylated |phosphoprotein, PRO)
		if ( $each_dep[$i] !~
			/xsubj\((?:de|un|non)myrist.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/xsubj\(myristoylated-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# (12) prep_from
		# one layer
		# prep_from(peptide, PRO)
		if ( $each_dep[$i] !~
			/prep_from\((?:de|un|non)phosphopeptides?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/prep_from\((?:.*?myrist)?peptides?-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# prep_from(token, PRO)
		elsif ( $each_dep[$i] =~ /prep_from\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
				if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
					|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
				{
					my $relation = $1;
					my $word     = $2;
					if ( $word =~ /peptide/i ) {
						@substrate = push_finding( $pro1, @substrate )
						  ;    # push the found element into corresponding array
						@substrate =
						  substrate_appositive( \@each_dep, $i, \@substrate,
							$pro1 );    # search all possible appositives
						last;
					}
				}
			}
			for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
				if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
					|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
				{
					my $relation = $1;
					my $word     = $2;
					if ( $word =~ /peptide/i ) {
						@substrate = push_finding( $pro1, @substrate )
						  ;    # push the found element into corresponding array
						@substrate =
						  substrate_appositive( \@each_dep, $i, \@substrate,
							$pro1 );    # search all possible appositives
						last;
					}
				}
			}
		}

		# (13) prep_within
		# prep_within( myristoylated , PRO)
		if ( $each_dep[$i] !~
			/prep_within\((?:de|un|non) myristoylated -\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/prep_within\(.*? myristoylated -\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		#  prep_within(token, PRO)
		elsif ( $each_dep[$i] =~ /prep_within\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i )
		{
			my $token = $1;
			my $pro1  = $2;
			if ( $token !~ /stimulation|content/i ) {
			  LAYER_2: for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist/i
							&& $word =~
							/myrist|regulatory|ser|thr|tyr|terminal|NH2/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~ /(?:de|un|non)myrist/i
										&& $2 =~ /myrist/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			  LAYER_2: for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist/i
							&& $word =~
							/myrist|regulatory|ser|thr|tyr|terminal|NH2/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)myrist|myristoylates/i
										&& $2 =~ /myrist/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			}
		}

		# (14) prep_for
		# three layer
		# prep_for(token, PRO)
		if ( $each_dep[$i] =~ /prep_for\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
		  LAYER_2: for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
				if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
					|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
				{
					my $relation = $1;
					my $word     = $2;
					if (   $word !~ /(?:de|un|non)myrist/i
						&& $word =~ / myristoylated /i )
					{

						# three layer
						for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if ( $2 =~ /is|was|are|were|be/i ) {
									@substrate =
									  push_finding( $pro1, @substrate )
									  ; # push the found element into corresponding array
									@substrate =
									  substrate_appositive( \@each_dep, $i,
										\@substrate, $pro1 )
									  ;    # search all possible appositives
									last LAYER_2;
								}
							}
						}
						for ( my $k = $j + 1 ; $k < @each_dep ; $k++ ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if ( $2 =~ /is|was|are|were|be/i ) {
									@substrate =
									  push_finding( $pro1, @substrate )
									  ; # push the found element into corresponding array
									@substrate =
									  substrate_appositive( \@each_dep, $i,
										\@substrate, $pro1 )
									  ;    # search all possible appositives
									last LAYER_2;
								}
							}
						}
					}
				}
			}
		}

		# (15) *(PRO- myristoylated , PRO)
		if ( $each_dep[$i] !~
/.+?\(PRO\d+-(?:de|un|non)(?: myristoylated )-\d+'?, (PRO\d+)-\d+'?\)/i
			&& $each_dep[$i] =~
			/.+?\(PRO\d+-.*? myristoylated -\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# (16) *(PRO-myristoylation, *) or *(*, PRO-myristoylation)
		if ( $each_dep[$i] =~ /.+?\((PRO\d+)-myristoylation-\d+'?, .+?-\d+'?\)/i
			|| $each_dep[$i] =~
			/.+?\(.+?-\d+'?, (PRO\d+)-myristoylation-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# (17) *(myristoylation, PRO)
		if ( $each_dep[$i] !~
			/.+?\((?:de|un|non)myristoylation-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/.+?\(.*?myristoylation-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# (18)  prep_with
		# one layer
		if ( $each_dep[$i] !~
			/prep_with\((?:de|un|non)myrist.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/prep_with\((?:myrist.*?)-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		#  prep_with(token, PRO)
		elsif ( $each_dep[$i] =~ /prep_with\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			if ( $token !~ /stimulation|content/i ) {
			  LAYER_2: for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist|myristoylates/i
							&& $word =~
							/myrist|regulatory|ser|thr|tyr|terminal|NH2/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)myrist|myristoylates/i
										&& $2 =~ /myrist/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			  LAYER_2: for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist|myristoylates/i
							&& $word =~
							/myrist|regulatory|ser|thr|tyr|terminal|NH2/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)myrist|myristoylates/i
										&& $2 =~ /myrist/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			}
		}

		# (19)  conj_and
		# one layer
		if ( $each_dep[$i] !~
			/conj_and\((?:de|un|non)myrist.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/conj_and\(.*?myrist.*?-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		#  conj_and(token, PRO)
		elsif ( $each_dep[$i] =~ /conj_and\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			if ( $token !~ /stimulation|content/i ) {
			  LAYER_2: for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist|myristoylates/i
							&& $word =~ /myrist/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)myrist|myristoylates/i
										&& $2 =~ /myrist/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			  LAYER_2: for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist|myristoylates/i
							&& $word =~ /myrist/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)myrist|myristoylates/i
										&& $2 =~ /myrist/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			}
		}

		# (20) prep_to
		# one layer
		if ( $each_dep[$i] !~
			/prep_to\((?:de|un|non)myrist.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/prep_to\((?:myrist.*?)-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# prep_of(token, PRO)
		elsif ( $each_dep[$i] =~ /prep_to\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			if ( $token !~ /stimulation|content/i ) {
			  LAYER_2: for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist|myristoylates/i
							&& $word =~
							/myrist|regulatory|ser|thr|tyr|terminal|NH2/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)myrist|myristoylates/i
										&& $2 =~ /myrist/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			  LAYER_2: for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $relation !~
							   /agent|prep_with|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)myrist|myristoylates/i
							&& $word =~
							/myrist|regulatory|ser|thr|tyr|terminal|NH2/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)myrist|myristoylates/i
										&& $2 =~ /myrist/i )
									{
										@substrate =
										  push_finding( $pro1, @substrate )
										  ; # push the found element into corresponding array
										@substrate = substrate_appositive(
											\@each_dep,  $i,
											\@substrate, $pro1
										);    # search all possible appositives
										last LAYER_2;
									}
								}
							}
						}
					}
				}
			}
		}

		#(21)prep_by
		if (
			$each_dep[$i] =~ /prep_by\(myristate-(PRO\d+)-\d='?, .+?-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

	}

	return @substrate;

}

sub kinase_pattern_myrist {

	my @each_dep = @_;
	my @kinase   = ('NULL');
	return @kinase;

}

sub site_pattern_myrist {

	my @each_dep = @_;
	my @site     = ('NULL');

	for ( my $i = 0 ; $i < @each_dep ; $i++ ) {

		# (1) [S|s]erine-\d+ or [T|t]hreonine-\d+ or [T|t]yrosine-\d+
		#     positions?-\d+ or residues?-\d+
		#     O-myrist[serine|threonine|tyrosine]-\d+
		#     Ser-\d+ or Thr-\d+ or Tyr-\d+
		#     S-\d+ or T-\d+ or Y-\d+
		if ( $each_dep[$i] =~
/\(((?:Serine|Threonine|Tyrosine|positions?|residues?|O-myrist(?:serine|threonine|tyrosine)|Ser|Thr|Tyr|\bS\b|\bT\b|\bY\b)-\d+)-\d+'?, /i
		  )
		{
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;    # push the found element into corresponding array
		}
		if ( $each_dep[$i] =~
/, ((?:Serine|Threonine|Tyrosine|O-myrist(?:serine|threonine|tyrosine)|Ser|Thr|Tyr|\bS\b|\bT\b|\bY\b)-\d+)-\d+'?\)/i
		  )
		{
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;    # push the found element into corresponding array
		}

		# (2) Ser\d+ or Thr\d+ or Tyr\d+ or T\d+ or Y\d+
		if ( $each_dep[$i] =~
/\(((?:Ser|Thr|Tyr|\bT|\bY)\d+(\\\/(?:Ser|Thr|Tyr|\bT|\bY)\d+)?)-\d+'?, /i
		  )
		{
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;    # push the found element into corresponding array
		}
		if ( $each_dep[$i] =~
/, ((?:Ser|Thr|Tyr|\bT|\bY)\d+(\\\/(?:Ser|Thr|Tyr|\bT|\bY)\d+)?)-\d+'?\)/i
		  )
		{
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;    # push the found element into corresponding array
		}

# (3) *(Ser|Thr|Tyr|serines?|threonines?|tyrosines?, \d+) or *(\d+, Ser|Thr|Tyr|serines?|threonines?|tyrosines?)
		if ( $each_dep[$i] =~
			/.+?\((\bser.*?|\bthr.*?|\btyr.*?)-\d+'?, (\d+)-\d+'?\)/i )
		{
			my $res;
			if ( $1 !~ /.*?\d+$/i ) {
				$res = $1;
			}
			my $num = $2;
			my @numbers = number_appositive( \@each_dep, $i, $num );

			foreach my $number (@numbers) {
				$res =~ s/s$//;    # replace plural name's last "s"
				my $site_name = "$number";    # capture site name
				@site = push_finding( $site_name, @site )
				  ;    # push the found element into corresponding array
			}
		}
		if ( $each_dep[$i] =~
			/.+?\((\d+)-\d+'?, (\bser.*?|\bthr.*?|\btyr.*?)-\d+'?\)/i )
		{
			my $res;
			if ( $2 !~ /.*?\d+$/i ) {
				$res = $2;
			}
			my $num = $1;
			my @numbers = number_appositive( \@each_dep, $i, $num );

			foreach my $number (@numbers) {
				$res =~ s/s$//;    # replace plural name's last "s"
				my $site_name = "$number";    # capture site name
				@site = push_finding( $site_name, @site )
				  ;    # push the found element into corresponding array
			}
		}

		# (4) sequence form
		if ( $each_dep[$i] =~
			/appos\(((?:[A-Z][a-z]{2}-)*?[A-Z][a-z]{2})-\d+'?, P-\d+'?\)/ )
		{
			my $site_name = $1;    # capture site name
			@site = push_finding( $site_name, @site )
			  ;    # push the found element into corresponding array
		}
		if ( $each_dep[$i] =~ /appos\(--\d+'?, P-\d+'?\)/ ) {

			# search the forward sentence
			if (   $i > 0
				&& $each_dep[ $i - 1 ] =~
				/nn\(--\d+'?, ((?:[A-Z][a-z]{2}-)*?[A-Z][a-z]{2})-\d+'?\)/ )
			{
				my $site_name = $1;    # capture site name
				@site = push_finding( $site_name, @site )
				  ;    # push the found element into corresponding array
			}
		}

		# (5)Gly|Ala|Gln|Leu
		if ( $each_dep[$i] =~ /(Gly-Ala-Gln-Leu)/i ) {
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;        # push the found element into corresponding array
		}

		#(my) dobj
		if ( $each_dep[$i] =~ /dobj\(modified-\d+'?, (Lys-\d+)-\d+'?\)/i ) {
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;        # push the found element into corresponding array
		}

		#prep_at
		if ( $each_dep[$i] =~
			/prep_at\(myristoylation-\d+'?, ((?:Cys|Gly)\d+)-\d+'?\)/i )
		{
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;        # push the found element into corresponding array
		}

		#(myristoylation,site)
		if ( $each_dep[$i] =~ /.+?\(myristoylation-\d+'?, (Lys-\d+)-\d+'?\)/i )
		{
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;        # push the found element into corresponding array
		}

		# (6) position + number
		# (7) residue + number
		# this line
		if ( $each_dep[$i] =~
/.+?\((positions?|residues?)-(\d+)'?, (\d+|one|two|three|four|five|six|seven|eight|nine|ten)-(\d+)'?\)/
		  )
		{
			my $res    = "residue";
			my $index1 = $2;
			my $num    = $3;
			my $index2 = $4;
			if ( $index2 > $index1 ) {
				my @numbers = number_appositive( \@each_dep, $i, $num );
				foreach my $number (@numbers) {
					my $site_name = "$number";    # capture site name
					@site = push_finding( $site_name, @site )
					  ;    # push the found element into corresponding array
				}
			}
		}

		# next lines
		if ( $each_dep[$i] =~
			/.+?\(.+?-\d+'?, (positions?|residues?)-(\d+)'?\)/ )
		{
			my $res    = "residue";
			my $index1 = $2;

			# search next line
			if (
				$i < $#each_dep
				&& ( $each_dep[ $i + 1 ] =~
/\((\d+|one|two|three|four|five|six|seven|eight|nine|ten)-(\d+)'?, /i
					|| $each_dep[ $i + 1 ] =~
/, (\d+|one|two|three|four|five|six|seven|eight|nine|ten)-(\d+)'?\)/i
				)
			  )
			{
				my $num    = $1;
				my $index2 = $2;
				if ( $index2 > $index1 ) {
					my @numbers = number_appositive( \@each_dep, $i, $num );
					foreach my $number (@numbers) {
						$res =~ s/s$//;    # replace plural name's last "s"
						my $site_name = "$number";    # capture site name
						@site = push_finding( $site_name, @site )
						  ;    # push the found element into corresponding array
					}
				}
				$i += 1;
			}
		}

		# other sites formated as [A-Z][a-z]{2}-?\d+
		# one layer
		if ( $each_dep[$i] =~ /.+?\(([A-Z][a-z]{2}-?\d+)-\d+'?, (.+?)-\d+'?\)/ )
		{
			my $site_name = $1;
			my $token     = $2;
			if ( $token !~ /(?:de|un|non)myrist/i && $token =~ /myrist/ ) {
				@site = push_finding( $site_name, @site )
				  ;    # push the found element into corresponding array
			}
		}

		# two layer
		elsif (
			$each_dep[$i] =~ /.+?\(([A-Z][a-z]{2}-?\d+)-\d+'?, (.+?-\d+'?)\)/ )
		{
			my $site_name = $1;
			my $token     = $2;
		  LAYER_2: for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
				if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
					|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
				{
					my $relation = $1;
					my $word     = $2;
					if (   $word !~ /(?:de|un|non)myrist/i
						&& $word =~ /myrist/i )
					{
						@site = push_finding( $site_name, @site )
						  ;    # push the found element into corresponding array
						last LAYER_2;
					}

					# three layer
					else {
						for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if (   $2 !~ /(?:de|un|non)myrist/i
									&& $2 =~ /myrist/i )
								{
									@site = push_finding( $site_name, @site )
									  ; # push the found element into corresponding array
									last LAYER_2;
								}
							}
						}
						for ( my $k = $j + 1 ; $k < @each_dep ; $k++ ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if (   $2 !~ /(?:de|un|non)myrist/i
									&& $2 =~ /myrist/i )
								{
									@site = push_finding( $site_name, @site )
									  ; # push the found element into corresponding array
									last LAYER_2;
								}
							}
						}
					}
				}
			}
		  LAYER_2: for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
				if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
					|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
				{
					my $relation = $1;
					my $word     = $2;
					if (   $word !~ /(?:de|un|non)myrist/i
						&& $word =~ /myrist/i )
					{
						@site = push_finding( $site_name, @site )
						  ;    # push the found element into corresponding array
						last LAYER_2;
					}

					# three layer
					else {
						for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if (   $2 !~ /(?:de|un|non)myrist/i
									&& $2 =~ /myrist/i )
								{
									@site = push_finding( $site_name, @site )
									  ; # push the found element into corresponding array
									last LAYER_2;
								}
							}
						}
						for ( my $k = $j + 1 ; $k < @each_dep ; $k++ ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if (   $2 !~ /(?:de|un|non)myrist/i
									&& $2 =~ /myrist/i )
								{
									@site = push_finding( $site_name, @site )
									  ; # push the found element into corresponding array
									last LAYER_2;
								}
							}
						}
					}
				}
			}
		}

	}

	return @site;
}
1;
