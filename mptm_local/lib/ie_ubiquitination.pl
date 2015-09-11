sub substrate_pattern_ubiquitination {

	my @each_dep  = @_;
	my @substrate = ('NULL');

	for ( my $i = 0 ; $i < @each_dep ; $i++ ) {

		# (1) prep_of
		# one layer
		if ( $each_dep[$i] !~
			/prep_of\((?:de|un|non)ubiquit.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/prep_of\((?:.*?ubiquit.*?|Ubiquitination)-\d+'?, (PRO\d+)-\d+'?\)/i
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
							&& $word !~ /(?:de|un|non)ubiquit/i
							&& $word =~ /ubiquit|substrate/i )
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
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ubiquit|substrate/i )
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
							&& $word !~ /(?:de|un|non)ubiquit|ubiquitinates/i
							&& $word =~ /ubiquit|substrate/i )
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
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ubiquit|substrate/i )
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

		# (2) nsubjpass(ubiquitinated|regulated, PRO)
		# one layer
		if ( $each_dep[$i] !~
			/nsubjpass\((?:de|un|non)ubiquit.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/nsubjpass\((?:.*?ubiquitinated|regulated)-\d+'?, (PRO\d+)-\d+'?\)/i
		  )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# (3) prep_in(token, PRO)
		# one layer
		if ( $each_dep[$i] !~
			/prep_in\((?:de|un|non)ubiquit.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/prep_in\((?:.*?ubiquit.+?)-\d+'?, (PRO\d+)-\d+'?\)/i )
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
					if (   $word !~ /(?:de|un|non)ubiquit/i
						&& $word =~ /ubiquit|ser|thr|tyr/i )
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
								if (   $2 !~ /(?:de|un|non)ubiquit/i
									&& $2 =~ /ubiquit/i )
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
								if (   $2 !~ /(?:de|un|non)ubiquit/i
									&& $2 =~ /ubiquit/i )
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
					if (   $word !~ /(?:de|un|non)ubiquit/i
						&& $word =~ /ubiquit|ser|thr|tyr/i )
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
								if (   $2 !~ /(?:de|un|non)ubiquit/i
									&& $2 =~ /ubiquit/i )
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
								if (   $2 !~ /(?:de|un|non)ubiquit/i
									&& $2 =~ /ubiquit/i )
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
			/amod\(PRO\d+-\d+'?, (?:de|un|non)ubiquitinated-\d+'?\)/i
			&& $each_dep[$i] =~
			/amod\((PRO\d+)-\d+'?, .*?ubiquitinated-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}
		elsif ( $each_dep[$i] =~
			/amod\(ubiquitination-\d+'?, (PRO\d+)-mediated-\d+'?\)/i )
		{

		}
		elsif ( $each_dep[$i] !~
			/amod\((?:de|un|non)ubiquitination-\d+'?, (PRO\d+)-\d+'?\)/i
			&& $each_dep[$i] =~
			/amod\((?:ubiquitination|degradation)-\d+'?, (PRO\d+)-\d+'?\)/i )
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

					# amod(ubiquit|site, token)
					if (   $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i
						|| $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if (   $relation !~ /conj_and/
							&& $word !~ /(?:de|un|non)ubiquit/i
							&& $word =~ /ubiquit|site|regulation/i )
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
			/dobj\((?:de|un|non)ubiquit.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
/dobj\((?:.*?ubiquitinates?|ubiquitinating)-\d+'?, (PRO\d+)-\d+'?\)/i
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
		# dobj(token, PRO)
		elsif ( $each_dep[$i] =~ /dobj\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			if (   $token !~ /(?:de|un|non)ubiquitinated/i
				&& $token =~ /ubiquitinated|cataly[s|z]ed|modified/i )
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
			elsif ( $token !~
				/ubiquitinated|cataly[s|z]ed|modified|prevent|inhibit/i )
			{
				for ( my $j = $i - 1 ; $j > $i - 4 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if (   $word !~ /(?:de|un|non)ubiquit/i
							&& $word =~ /ubiquit|substrate/i )
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
						if (   $word !~ /(?:de|un|non)ubiquit/i
							&& $word =~ /ubiquit|substrate/i )
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
			/nsubj\((?:de|un|non)ubiquitinat.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/nsubj\((?:ubiquitination)-\d+'?, (PRO\d+)-\d+'?\)/i
			|| $each_dep[$i] =~
			/nsubj\((PRO\d+)-\d+'?, Ubiquitination-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# nsubj(token, PRO)
		elsif ( $each_dep[$i] =~ /nsubj\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;

			# nsubj(ubiquitinated, PRO)
			if (   $token !~ /(?:de|un|non)ubiquitinated/i
				&& $token =~ /ubiquit/i )
			{
				my $flag     = 0;
				my $neg_flag = 0;
				for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $word =~ /is|was|are|were|be/i ) {

							# negation judge
							for ( my $k = $j - 1 ; $k >= 0 && $k != $i ; $k-- )
							{
								if ( $each_dep[$k] =~
									/(.+?)\($token, (.+?)-\d+'?\)/i
									|| $each_dep[$k] =~
									/(.+?)\((.+?)-\d+'?, $token\)/i )
								{
									my $relation = $1;
									my $word_2   = $2;
									if (   $relation =~ /neg/
										&& $word_2 =~ /not/i )
									{
										$neg_flag = 1;
										last;
									}
								}
							}
							for (
								my $k = $j + 1 ;
								$k < @each_dep && $k != $i ;
								$k++
							  )
							{
								if ( $each_dep[$k] =~
									/(.+?)\($token, (.+?)-\d+'?\)/i
									|| $each_dep[$k] =~
									/(.+?)\((.+?)-\d+'?, $token\)/i )
								{
									my $relation = $1;
									my $word_2   = $2;
									if (   $relation =~ /neg/
										&& $word_2 =~ /not/i )
									{
										$neg_flag = 1;
										last;
									}
								}
							}
							if ( !$neg_flag ) {
								$flag = 1;
								last;
							}
						}
					}
				}
				for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $word =~ /is|was|are|were|be/i ) {

							# negation judge
							for ( my $k = $j - 1 ; $k >= 0 && $k != $i ; $k-- )
							{
								if ( $each_dep[$k] =~
									/(.+?)\($token, (.+?)-\d+'?\)/i
									|| $each_dep[$k] =~
									/(.+?)\((.+?)-\d+'?, $token\)/i )
								{
									my $relation = $1;
									my $word_2   = $2;
									if (   $relation =~ /neg/
										&& $word_2 =~ /not/i )
									{
										$neg_flag = 1;
										last;
									}
								}
							}
							for (
								my $k = $j + 1 ;
								$k < @each_dep && $k != $i ;
								$k++
							  )
							{
								if ( $each_dep[$k] =~
									/(.+?)\($token, (.+?)-\d+'?\)/i
									|| $each_dep[$k] =~
									/(.+?)\((.+?)-\d+'?, $token\)/i )
								{
									my $relation = $1;
									my $word_2   = $2;
									if (   $relation =~ /neg/
										&& $word_2 =~ /not/i )
									{
										$neg_flag = 1;
										last;
									}
								}
							}
							if ( !$neg_flag ) {
								$flag = 1;
								last;
							}
						}
					}
				}
				if ($flag) {
					@substrate = push_finding( $pro1, @substrate )
					  ;    # push the found element into corresponding array
					@substrate =
					  substrate_appositive( \@each_dep, $i, \@substrate,
						$pro1 );    # search all possible appositives
				}
			}
			elsif ( $token !~ /ubiquitinated/i ) {
			  LAYER_2: for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if (   $relation !~ /dobj|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)ubiquit|ubiquitinates/i
							&& $word =~ /ubiquit|substrate/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|residue|undergo/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $2 !~
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ubiquit|substrate/i )
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
							for ( my $k = $j + 1 ; $k < @each_dep ; $k++ ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $2 !~
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ubiquit|substrate/i )
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
						if (   $relation !~ /dobj|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)ubiquit|ubiquitinates/i
							&& $word =~ /ubiquit|substrate/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|residue|undergo/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $2 !~
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ubiquit|substrate/i )
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
							for ( my $k = $j + 1 ; $k < @each_dep ; $k++ ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $2 !~
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ubiquit|substrate/i )
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
					if (   $word !~ /(?:de|un|non)ubiquit|ubiquitinates/i
						&& $word =~ /ubiquit|substrate/i )
					{
						@substrate = push_finding( $pro1, @substrate )
						  ;    # push the found element into corresponding array
						@substrate =
						  substrate_appositive( \@each_dep, $i, \@substrate,
							$pro1 );    # search all possible appositives
						last LAYER_2;
					}

					# three layer
					elsif ( $word =~ /site|residue/i ) {
						for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if ( $2 !~ /(?:de|un|non)ubiquit|ubiquitinates/i
									&& $2 =~ /ubiquit|substrate/i )
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
								if ( $2 !~ /(?:de|un|non)ubiquit|ubiquitinates/i
									&& $2 =~ /ubiquit|substrate/i )
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
					if (   $word !~ /(?:de|un|non)ubiquit|ubiquitinates/i
						&& $word =~ /ubiquit|substrate/i )
					{
						@substrate = push_finding( $pro1, @substrate )
						  ;    # push the found element into corresponding array
						@substrate =
						  substrate_appositive( \@each_dep, $i, \@substrate,
							$pro1 );    # search all possible appositives
						last LAYER_2;
					}

					# three layer
					elsif ( $word =~ /site|residue/i ) {
						for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
							if ( $each_dep[$k] =~ /(.+?)\($word, (.+?-\d+'?)\)/i
								|| $each_dep[$j] =~
								/(.+?)\((.+?-\d+'?), $word\)/i )
							{
								if ( $2 !~ /(?:de|un|non)ubiquit|ubiquitinates/i
									&& $2 =~ /ubiquit|substrate/i )
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
								if ( $2 !~ /(?:de|un|non)ubiquit|ubiquitinates/i
									&& $2 =~ /ubiquit|substrate/i )
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
			/nn\((PRO\d+)-\d+'?, PRO\d+-(?:de|un|non)ubiquitinated-\d+'?\)/i
			&& $each_dep[$i] =~
			/nn\((PRO\d+)-\d+'?, PRO\d+-.*?ubiquitinated-\d+'?\)/i
			|| $each_dep[$i] =~
			/nn\((?:ubiquitination)-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# nn(token, PRO)
		elsif ( $each_dep[$i] =~ /nn\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
				if (   $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i
					|| $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i )
				{
					my $relation = $1;
					my $word     = $2;
					if (   $relation =~ /prep_of/
						&& $word !~ /(?:de|un|non)ubiquit/i
						&& $word =~ /ubiquit/i )
					{
						@substrate = push_finding( $pro1, @substrate )
						  ;    # push the found element into corresponding array
						@substrate =
						  substrate_appositive( \@each_dep, $i, \@substrate,
							$pro1 );    # search all possible appositives
						last;
					}
					elsif ($relation !~ /agent|prep_with/
						&& $word !~ /(?:de|un|non)ubiquit/i
						&& $word =~ /ubiquit/i )
					{
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

		# (8) partmod
		# one layer
		# partmod(PRO, ubiquitinated|ubiquitination)
		if ( $each_dep[$i] !~
			/partmod\(PRO\d+-\d+'?, (?:de|un|non)ubiquit.*?-\d+'?\)/i
			&& $each_dep[$i] =~
			/partmod\((PRO\d+)-\d+'?, .*?ubiquit(?:ed|ion)-\d+'?\)/i )
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
		# appos(PRO, [ubiquit|substrate])
		if ( $each_dep[$i] !~
			/appos\(PRO\d+-\d+'?, (?:de|un|non)ubiquit.*?-\d+'?\)/i
			&& $each_dep[$i] =~
			/appos\((PRO\d+)-\d+'?, (?:.*?ubiquit.*?|substrates?)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# appos([ubiquit|substrate], PRO)
		if ( $each_dep[$i] !~
			/appos\((?:de|un|non)ubiquit.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/appos\((?:.*?ubiquit.*?|substrates?)-\d+'?, (PRO\d+)-\d+'?\)/i )
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
						if ( $word =~ /ubiquitination|substrate/i ) {
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
						if ( $word =~ /ubiquitination|substrate/i ) {
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
		# prep_on([ubiquitination|site], PRO)
		if ( $each_dep[$i] !~
			/prep_on\((?:de|un|non)ubiquitination-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/prep_on\((?:.*?ubiquitination|sites?)-\d+'?, (PRO\d+)-\d+'?\)/i )
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
					if ( $word =~ /ubiquit|/i ) {
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
		# xsubj(ubiquitinated, PRO)
		if ( $each_dep[$i] !~
			/xsubj\((?:de|un|non)ubiquit.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/xsubj\((?:ubiquitinated)-\d+'?, (PRO\d+)-\d+'?\)/i )
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
			/prep_from\((?:.*?ubiquit)?peptides?-\d+'?, (PRO\d+)-\d+'?\)/i )
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
		# prep_within(ubiquitinated, PRO)
		if ( $each_dep[$i] !~
			/prep_within\((?:de|un|non)ubiquitinated-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/prep_within\(.*?ubiquitinated-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# (13#) prep_with
		# one layer
		if ( $each_dep[$i] !~
			/prep_with\((?:de|un|non)ubiquit.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
/prep_with\((?:.*?ubiquit.*?|Ubiquitination|ligase)-\d+'?, (PRO\d+)-\d+'?\)/i
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
		# prep_of(token, PRO)
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
						if (   $relation !~ /agent|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)ubiquit/i
							&& $word =~ /ubiquit/i )
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
									if (   $1 !~ /agent|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ubiquit/i )
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
						if (   $relation !~ /agent|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)ubiquit|ubiquitinates/i
							&& $word =~ /ubiquit/i )
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
									if (   $1 !~ /agent|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ubiquit/i )
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
					if (   $word !~ /(?:de|un|non)ubiquit/i
						&& $word =~ /ubiquitinated|ligase/i )
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

		# (15) *(PRO-ubiquitinated, PRO)
		if ( $each_dep[$i] !~
/.+?\(PRO\d+-(?:de|un|non)(?:ubiquitinated)-\d+'?, (PRO\d+)-\d+'?\)/i
			&& $each_dep[$i] =~
			/.+?\(PRO\d+-.*?ubiquitinated-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# (16) *(PRO-ubiquitination, *) or *(*, PRO-ubiquitination)
		if ( $each_dep[$i] =~ /.+?\((PRO\d+)-ubiquitination-\d+'?, .+?-\d+'?\)/i
			|| $each_dep[$i] =~
			/.+?\(.+?-\d+'?, (PRO\d+)-ubiquitination-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# (17) *(ubiquitination, PRO)
		if ( $each_dep[$i] !~
			/.+?\((?:de|un|non)ubiquitination-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/.+?\(.*?ubiquitination-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# (18) num
		# one layer
		if ( $each_dep[$i] !~
			/num\((?:de|un|non)ubiquit.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/prep_of\((?:.*?ubiquit.*?|Ubiquitination)-\d+'?, (PRO\d+)-\d+'?\)/i
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
		#num(token, PRO)
		elsif ( $each_dep[$i] =~ /num\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
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
							&& $word !~ /(?:de|un|non)ubiquit/i
							&& $word =~ /ubiquit|regulates/i )
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
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ubiquit|regulates/i )
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
							&& $word !~ /(?:de|un|non)ubiquit|ubiquitinates/i
							&& $word =~
							/ubiquit|regulatory/i)
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
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ubiquit/i )
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

		# (11)prep_including
		# one layer
		if ( $each_dep[$i] !~
			/prep_including\((?:de|un|non)ubiquit.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
/prep_including\((?:.*?ubiquit.*?|Ubiquitination)-\d+'?, (PRO\d+)-\d+'?\)/i
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
		#prep_including(token, PRO)
		elsif (
			$each_dep[$i] =~ /prep_including\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i )
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
							&& $word !~ /(?:de|un|non)ubiquit/i
							&& $word =~ /ubiquit/i )
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
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ubiquit/i )
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
							&& $word !~ /(?:de|un|non)ubiquit|ubiquitinates/i
							&& $word =~
							/ubiquit|regulatory|ser|thr|tyr|terminal|NH2/i )
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
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ubiquit/i )
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

		#(12)prep_towards
		# one layer
		if ( $each_dep[$i] !~
			/prep_towards\((?:de|un|non)ubiquit.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/prep_towards\((?:activity)-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}
			# (13) xcomp
		# one layer
		if ( $each_dep[$i] !~
			/xcomp\((?:de|un|non)ubiquit.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/xcomp\((?:.*?ubiquit.*?|Ubiquitination)-\d+'?, (PRO\d+)-\d+'?\)/i
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
		# prep_of(token, PRO)
		elsif ( $each_dep[$i] =~ /xcomp\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
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
							&& $word !~ /(?:de|un|non)ubiquit/i
							&& $word =~ /ubiquit|substrate/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit|bound/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ubiquit|substrate/i )
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
							&& $word !~ /(?:de|un|non)ubiquit|ubiquitinates/i
							&& $word =~ /ubiquit|substrate/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit|bound/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ubiquit|substrate/i )
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
		
		# (14) num
		# one layer
#		if ( $each_dep[$i] !~
#			/num\((?:de|un|non)ubiquit.*?-\d+'?, PRO\d+-\d+'?\)/i
#			&& $each_dep[$i] =~
#			/prep_of\((?:.*?ubiquit.*?|Ubiquitination)-\d+'?, (PRO\d+)-\d+'?\)/i
#		  )
#		{
#			my $pro1 = $1;    # capture PRO
#			@substrate = push_finding( $pro1, @substrate )
#			  ;               # push the found element into corresponding array
#			@substrate =
#			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
#			  ;               # search all possible appositives
#		}

		# two layer
		#num(token, PRO)
		if ( $each_dep[$i] =~ /num\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
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
							&& $word !~ /(?:de|un|non)ubiquit/i
							&& $word =~ /ubiquit|regulates/i )
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
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ligase/i )
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
							&& $word !~ /(?:de|un|non)ubiquit|ubiquitinates/i
							&& $word =~
							/ligase/i )
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
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ligase/i )
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

	}

	return @substrate;

}

sub kinase_pattern_ubiquitination {

	my @each_dep = @_;
	my @kinase   = ('NULL');

	for ( my $i = 0 ; $i < @each_dep ; $i++ ) {

		# (1) agent
		# one layer
		# agent(token, PRO)
		if ( $each_dep[$i] !~
			/agent\((?:de|un|non)ubiquitinated-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/agent\((?:.*?ubiquitinated|mutation)-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# (2) prep_by
		# one layer
		# prep_by(token, PRO)
		if ( $each_dep[$i] !~
			/prep_by\((?:de|un|non)ubiquit.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/prep_by\((?:.*?ubiquitinated|PRO\d+)-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		elsif ( $each_dep[$i] =~ /prep_by\((.+?-\d+'?), (PRO\d+)-(\d+'?)\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			my $index = $3;
			for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {

				# prep_by(ubiquit, token) || prep_by(token, ubiquit)
				if (   $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i
					|| $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i )
				{
					my $relation = $1;
					my $word     = $2;
					if (   $word !~ /(?:de|un|non)ubiquit/i
						&& $word =~ /ubiquitination|ubiquitinated|PRO\d+/i )
					{
						@kinase = push_finding( $pro1, @kinase )
						  ;    # push the found element into corresponding array
						@kinase =
						  kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
						  ;    # search all possible appositives
						last;
					}
				}

				# [ubiquitination|ubiquitinated] by PRO
				elsif ( $each_dep[$j] =~
					/(.+?)\(.+?-\d+'?, (?:de|un|non)ubiquit.*?-\d+'?\)/i
					|| $each_dep[$j] =~
/.+?\(.+?-\d+'?, (?:ubiquitination|ubiquitinated)-(\d+'?)\)/i
				  )
				{
					my $index_new = $1;
					if ( $index = $index_new + 2 ) {
						@kinase = push_finding( $pro1, @kinase )
						  ;    # push the found element into corresponding array
						@kinase =
						  kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
						  ;    # search all possible appositives
						last;
					}
				}
			}
		}

		# (3) nsubj
		# one layer
		# nsubj(PRO, token)
		if ( $each_dep[$i] =~
			/nsubj\((PRO\d+)(-specific)?-\d+'?, (?:ligases?|enzymes?)-\d+'?\)/i
		  )
		{
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# nsubj(token, PRO)
		elsif ( $each_dep[$i] !~
			/nsubj\((?:de|un|non)ubiquit.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
/nsubj\((?:.*?ubiquitinates?|regulates|ubiquitylates|ligase|catalyze)-\d+'?, (PRO\d+)-\d+'?\)/i
		  )
		{
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# nsubj(token, PRO)
		elsif ( $each_dep[$i] =~ /nsubj\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			if (   $token !~ /(?:de|un|non)ubiquitinated/i
				&& $token =~ /ubiquit|ligase|regulate/i )
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
					@kinase = push_finding( $pro1, @kinase )
					  ;    # push the found element into corresponding array
					@kinase =
					  kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
					  ;    # search all possible appositives
				}
			}
			elsif ( $token !~ /ubiquitinated|regulate|ligase/i ) {
				for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if (   $relation !~ /prep_for/
							&& $word =~
							/ligase|enzyme|ubiquitination|E3|E2|E1|regulate/i )
						{
							@kinase = push_finding( $pro1, @kinase )
							  ; # push the found element into corresponding array
							@kinase =
							  kinase_appositive( \@each_dep, $i, \@kinase,
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
						if (   $relation !~ /prep_for/
							&& $word =~
							/ligase|enzyme|ubiquitination|E3|E2|E1/i )
						{
							@kinase = push_finding( $pro1, @kinase )
							  ; # push the found element into corresponding array
							@kinase =
							  kinase_appositive( \@each_dep, $i, \@kinase,
								$pro1 );    # search all possible appositives
							last;
						}
					}
				}
			}
		}

		# (4) prep_for
		# one layer
		# prep_for(token, PRO)
		if ( $each_dep[$i] !~
			/prep_for\((?:de|un|non)ubiquit.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
/prep_for\((?:.*?ubiquitination|substrates?)-\d+'?, (PRO\d+)-\d+'?\)/i
		  )
		{
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# prep_for(token, PRO)
		elsif ( $each_dep[$i] =~ /prep_for\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
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
							&& $word !~ /(?:de|un|non)ubiquit/i
							&& $word =~ /ubiquit|substrate|ligase/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit|as/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ligase/i )
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
							&& $word !~ /(?:de|un|non)ubiquit|ubiquitinates/i
							&& $word =~ /ubiquit|substrate|ligase/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit|as/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ligase/i )
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

		# (5) nn
		# one layer
		# nn(PRO, PRO-ubiquitinated)
		if ( $each_dep[$i] =~ /nn\((PRO\d+)-\d+'?, (?:ligase|E3|E2|E1)-\d+'?\)/i
			|| $each_dep[$i] =~
			/nn\(ubiquitylation-\d+'?, (PRO\d+)-mediated-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# nn([kinase|substrate], PRO)
		elsif ( $each_dep[$i] =~
			/nn\((?:enzyme|lagase||substrates?)-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# nn(PRO, kinase)
		elsif ( $each_dep[$i] =~ /nn\((PRO\d+)-\d+'?, (?:enzyme)-\d+'?\)/i ) {
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# nn(token, PRO)
		elsif ( $each_dep[$i] =~ /nn\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i|| $each_dep[$i] =~ /nn\((.+?-\d+'?), (PRO\d+)-mediated-\d+'?\)/i) {
			my $token = $1;
			my $pro1  = $2;
			if ( $token !~ /induction/i ) {
				for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
					if (   $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i
						|| $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if (   $token !~ /bind/
							&& $relation !~ /prep_of|conj_and|conj_or|appos/
							&& $word !~ /(?:de|un|non)ubiquit/i
							&& $word     =~ /ubiquitination|target|ligase/i
							|| $relation =~ /agent/
							&& $word     =~ /ubiquitinated|ligase/i )
						{
							@kinase = push_finding( $pro1, @kinase )
							  ; # push the found element into corresponding array
							@kinase =
							  kinase_appositive( \@each_dep, $i, \@kinase,
								$pro1 );    # search all possible appositives
							last;
						}
					}
				}
			}
		}

		# (6) prep_of
		# one layer
		# prep_of(substrate, PRO)
		if ( $each_dep[$i] =~ /prep_of\((?:substrates?|activity)-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
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
							&& $word !~ /(?:de|un|non)ubiquit/i
							&& $word =~ /ubiquit|substrate|ligase/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit|as/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ligase/i )
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
							&& $word !~ /(?:de|un|non)ubiquit|ubiquitinates/i
							&& $word =~ /ubiquit|substrate|ligase/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|activit|as/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~
										/(?:de|un|non)ubiquit|ubiquitinates/i
										&& $2 =~ /ligase/i )
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

		# (7) amod
		# two layer
		if ( $each_dep[$i] =~ /amod\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i||$each_dep[$i] =~ /amod\((.+?-\d+'?), (PRO\d+-PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;    # capture PRO
			                   # if found kinase pattern
			for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {

				# kinase pattern
				# [nn|prep_of](token, *)
				if (   $each_dep[$j] =~ /prep_of\($token, PRO\d+-\d+'?\)/i
					||$each_dep[$j] =~
					/amod\($token, ubiquit.*-\d+'?\)/i)
				{
					@kinase = push_finding( $pro1, @kinase )
					  ;        # push the found element into corresponding array
					@kinase =
					  kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
					  ;        # search all possible appositives
					last;
				}
			}
		}

		# (8) appos
		# one layer
		# appos(kinase, PRO)
		if (   $each_dep[$i] =~ /appos\(ligase-\d+'?, (PRO\d+)-\d+'?\)/i
			|| $each_dep[$i] =~ /appos\((PRO\d+)-\d+'?, ligase-\d+'?\)/i )
		{
			my $pro1 = $1;     # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;                # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;                # search all possible appositives
		}

		# (9) dobj
		# two layer
		# dobj(token, PRO)
		if ( $each_dep[$i] =~ /dobj\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			if (   $token !~ /(?:de|un|non)ubiquitinated/i
				&& $token =~ /ubiquitinated|poly-ubiquitylated/i )
			{
				my $flag     = 0;
				my $neg_flag = 0;
				for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $word =~ /is|was|are|were|be/i ) {

							# negation judge
							for ( my $k = $j - 1 ; $k >= 0 && $k != $i ; $k-- )
							{
								if ( $each_dep[$k] =~
									/(.+?)\($token, (.+?)-\d+'?\)/i
									|| $each_dep[$k] =~
									/(.+?)\((.+?)-\d+'?, $token\)/i )
								{
									my $relation = $1;
									my $word_2   = $2;
									if (   $relation =~ /neg/
										&& $word_2 =~ /not/i )
									{
										$neg_flag = 1;
										last;
									}
								}
							}
							for (
								my $k = $j + 1 ;
								$k < @each_dep && $k != $i ;
								$k++
							  )
							{
								if ( $each_dep[$k] =~
									/(.+?)\($token, (.+?)-\d+'?\)/i
									|| $each_dep[$k] =~
									/(.+?)\((.+?)-\d+'?, $token\)/i )
								{
									my $relation = $1;
									my $word_2   = $2;
									if (   $relation =~ /neg/
										&& $word_2 =~ /not/i )
									{
										$neg_flag = 1;
										last;
									}
								}
							}
							if ( !$neg_flag ) {
								$flag = 1;
								last;
							}
						}
					}
				}
				for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if ( $word =~ /is|was|are|were|be/i ) {

							# negation judge
							for ( my $k = $j - 1 ; $k >= 0 && $k != $i ; $k-- )
							{
								if ( $each_dep[$k] =~
									/(.+?)\($token, (.+?)-\d+'?\)/i
									|| $each_dep[$k] =~
									/(.+?)\((.+?)-\d+'?, $token\)/i )
								{
									my $relation = $1;
									my $word_2   = $2;
									if (   $relation =~ /neg/
										&& $word_2 =~ /not/i )
									{
										$neg_flag = 1;
										last;
									}
								}
							}
							for (
								my $k = $j + 1 ;
								$k < @each_dep && $k != $i ;
								$k++
							  )
							{
								if ( $each_dep[$k] =~
									/(.+?)\($token, (.+?)-\d+'?\)/i
									|| $each_dep[$k] =~
									/(.+?)\((.+?)-\d+'?, $token\)/i )
								{
									my $relation = $1;
									my $word_2   = $2;
									if (   $relation =~ /neg/
										&& $word_2 =~ /not/i )
									{
										$neg_flag = 1;
										last;
									}
								}
							}
							if ( !$neg_flag ) {
								$flag = 1;
								last;
							}
						}
					}
				}
				if ($flag) {
					@kinase = push_finding( $pro1, @kinase )
					  ;    # push the found element into corresponding array
					@kinase =
					  kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
					  ;    # search all possible appositives
				}
			}
		}elsif( $each_dep[$i] =~ /dobj\(conjugates-\d+'?, (PRO\d+)-\d+'?\)/i ){
				@kinase = push_finding( $pro1, @kinase )
					  ;    # push the found element into corresponding array
					@kinase =
					  kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
					  ;    # search all possible appositives
		}

		# (10) xsubj
		# one layer
		# xsubj(ubiquit, PRO)
		if ( $each_dep[$i] !~
			/xsubj\((?:de|un|non)ubiquit-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~ /xsubj\(ligase-\d+'?, (PRO\d+)-\d+'?\)/i||$each_dep[$i] =~ /xsubj\(ubiquitinate-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# (11) pobj
		# two layer
		# pobj(by, PRO)
		if ( $each_dep[$i] =~ /pobj\(by-\d+'?, (PRO\d+)-\d+'?\)/i ) {
			my $pro1 = $1;    # capture PRO
			for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
				if ( $each_dep[$j] !~
					/pobj\((?:de|un|non)ubiquit.*?-\d+'?, by\)/i
					&& $each_dep[$j] =~
					/pobj\((?:ubiquitinated|catalysed)-\d+'?, by\)/i )
				{
					@kinase = push_finding( $pro1, @kinase )
					  ;       # push the found element into corresponding array
					@kinase =
					  kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
					  ;       # search all possible appositives
					last;
				}
			}
		}

		# (12) prep_to
		# one layer
		# prep_to(kinase, PRO)
		if ( $each_dep[$i] =~ /prep_to\(kinases?-\d+'?, (PRO\d+)-\d+'?\)/i ) {
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# (13) infmod
		# one layer
		# infmod(PRO, phosphorylate)
		if ( $each_dep[$i] =~ /infmod\((PRO\d+)-\d+'?, phosphorylate-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# (14) *(PRO-ubiquitinated, PRO)
		if ( $each_dep[$i] !~
			/.+?\(PRO\d+-(?:de|un|non)ubiquitinated-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/.+?\((PRO\d+)-.*?ubiquitinated-\d+'?, PRO\d+-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# (15) nsubjpass(ubiquitinated|regulated, PRO)
		# one layer
		if ( $each_dep[$i] =~ /nsubjpass\(involved-\d+'?, (PRO\d+)-\d+'?\)/i ) {
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@substrate = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

	}

	return @kinase;

}

sub site_pattern_ubiquitination {

	my @each_dep = @_;
	my @site     = ('NULL');

	for ( my $i = 0 ; $i < @each_dep ; $i++ ) {

		# (1) [S|s]erine-\d+ or [T|t]hreonine-\d+ or [T|t]yrosine-\d+
		#     positions?-\d+ or residues?-\d+
		#     O-ubiquit[serine|threonine|tyrosine]-\d+
		#     Ser-\d+ or Thr-\d+ or Tyr-\d+
		#     S-\d+ or T-\d+ or Y-\d+
		if ( $each_dep[$i] =~
/\(((?:Serine|Threonine|Tyrosine|positions?|residues?|O-ubiquit(?:serine|threonine|tyrosine)|Ser|Thr|Tyr|\bS\b|\bT\b|\bY\b)-\d+)-\d+'?, /i
		  )
		{
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;    # push the found element into corresponding array
		}
		if ( $each_dep[$i] =~
/, ((?:Serine|Threonine|Tyrosine|O-ubiquit(?:serine|threonine|tyrosine)|Ser|Thr|Tyr|\bS\b|\bT\b|\bY\b)-\d+)-\d+'?\)/i
		  )
		{
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;    # push the found element into corresponding array
		}

		# (2) Ser\d+ or Thr\d+ or Tyr\d+ or T\d+ or Y\d+
		if ( $each_dep[$i] =~
/\(((?:Ser|Thr|Tyr|\bT|\bY)\d+(\\\/(?:Ser|Lys|Tyr|\bT|\bY)\d+)?)-\d+'?, /i
		  )
		{
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;    # push the found element into corresponding array
		}
		if ( $each_dep[$i] =~
/, ((?:Ser|Thr|Lys|\bT|\bY)\d+(\\\/(?:Ser|Lys|Tyr|\bT|\bY)\d+)?)-\d+'?\)/i
		  )
		{
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;    # push the found element into corresponding array
		}

		# (3) nn
	if ( $each_dep[$i] =~
			/nn\(residue-\d+'?, (Lys-\d+)-\d+'?\)/ )
		{
			my $site_name = $1;    # capture site name
			@site = push_finding( $site_name, @site )
			  ;    # push the found element into corresponding array
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

		# (5) lysine
		if ( $each_dep[$i] =~
			/.+?\(ubiquitination-\d+'?, (lysine-\d+)-\d+'?\)/i )
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
					my $site_name = "$res-$number";    # capture site name
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
						my $site_name = "$res-$number";    # capture site name
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
			if ( $token !~ /(?:de|un|non)ubiquit/i && $token =~ /ubiquit/ ) {
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
					if (   $word !~ /(?:de|un|non)ubiquit/i
						&& $word =~ /ubiquit/i )
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
								if (   $2 !~ /(?:de|un|non)ubiquit/i
									&& $2 =~ /ubiquit/i )
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
								if (   $2 !~ /(?:de|un|non)ubiquit/i
									&& $2 =~ /ubiquit/i )
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
					if (   $word !~ /(?:de|un|non)ubiquit/i
						&& $word =~ /ubiquit/i )
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
								if (   $2 !~ /(?:de|un|non)ubiquit/i
									&& $2 =~ /ubiquit/i )
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
								if (   $2 !~ /(?:de|un|non)ubiquit/i
									&& $2 =~ /ubiquit/i )
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
