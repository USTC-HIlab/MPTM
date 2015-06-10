sub substrate_pattern_amidat {

	my @each_dep  = @_;
	my @substrate = ('NULL');

	for ( my $i = 0 ; $i < @each_dep ; $i++ ) {

		# (1) prep_of
		# one layer
		if ( $each_dep[$i] =~ /prep_of\(amidation-\d+, (PRO\d+)-\d+\)/i ) {
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
							&& $word !~ /(?:de|un|non)amid/i
							&& $word =~ /amid|acid/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|position/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~ /(?:de|un|non)amidat/i
										&& $2 =~ /amidat|sequence|acid/i )
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
							&& $word !~ /(?:de|un|non)amidat/i
							&& $word =~ /amid|sequence|Asn|Leu|acid/i )
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
										&& $2 !~ /(?:de|un|non)amidat/i
										&& $2 =~ /amid|acid/i )
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

		#my(2)appos
		if ( $each_dep[$i] =~ /appos\(amidat.*?-\d+, (PRO\d+)-\d+\)/i|| $each_dep[$i] =~ /appos\((PRO\d+)-\d+, .*?amid.*?-\d+\)/i ) {
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		#appos(token, PRO)
		elsif ( $each_dep[$i] =~ /appos\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
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
							&& $word !~ /(?:de|un|non)amid/i
							&& $word =~ /amid|peptide/i )
						{
							@substrate = push_finding( $pro1, @substrate )
							  ; # push the found element into corresponding array
							@substrate =
							  substrate_appositive( \@each_dep, $i, \@substrate,
								$pro1 );    # search all possible appositives
							last LAYER_2;
						}

						# three layer
						elsif ( $word =~ /site|position/i ) {
							for ( my $k = $j - 1 ; $k >= 0 ; $k-- ) {
								if ( $each_dep[$k] =~
									/(.+?)\($word, (.+?-\d+'?)\)/i
									|| $each_dep[$j] =~
									/(.+?)\((.+?-\d+'?), $word\)/i )
								{
									if ( $1 !~
										/agent|prep_with|conj_and|conj_or|appos/
										&& $2 !~ /(?:de|un|non)amid|amidates/i
										&& $2 =~ /amid/i )
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
							&& $word !~ /(?:de|un|non)amid|amidates/i
							&& $word =~
							/amid|regulatory|ser|thr|tyr|terminal|NH2/i )
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
										&& $2 !~ /(?:de|un|non)amid|amidates/i
										&& $2 =~ /amid/i )
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

		# (2) nsubjpass(glycosylation|regulated, PRO)
		# one layer
		if ( $each_dep[$i] !~
			/nsubjpass\((?:de|un|non)amidat.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/nsubjpass\((?:.*?amidat.*?)-\d+'?, (PRO\d+)-\d+'?\)/i )
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
			/prep_in\((?:de|un|non)amidat.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
/prep_in\((?:.*?amid.+?|localiz.+?|positions?|(?:ser|thr|tyr).*?-?\d+)-\d+'?, (PRO\d+)-\d+'?\)/i
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
					if (   $word !~ /(?:de|un|non)amidat/i
						&& $word =~ /amidat|ser|thr|tyr/i )
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
								if (   $2 !~ /(?:de|un|non)amidat/i
									&& $2 =~ /amidat/i )
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
								if (   $2 !~ /(?:de|un|non)amidat/i
									&& $2 =~ /amidat/i )
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
					if (   $word !~ /(?:de|un|non)amidat/i
						&& $word =~ /amidat|ser|thr|tyr/i )
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
								if (   $2 !~ /(?:de|un|non)acetyl/i
									&& $2 =~ /acetyl/i )
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
								if (   $2 !~ /(?:de|un|non)amid/i
									&& $2 =~ /amid/i )
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
		if ( $each_dep[$i] !~ /amod\(PRO\d+-\d+'?, (?:de|un|non)amidat-\d+'?\)/i
			&& $each_dep[$i] =~
			/amod\((PRO\d+)-\d+'?, .*?acetylation-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}
		elsif ( $each_dep[$i] !~
			/amod\((?:de|un|non)amidat.*-\d+'?, (PRO\d+)-\d+'?\)/i
			&& $each_dep[$i] =~
			/amod\(.*?acetylation-\d+'?, (PRO\d+)-\d+'?\)/i )
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

					# amod(amid|site, token)
					if (   $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i
						|| $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if (   $relation !~ /conj_and/
							&& $word !~ /(?:de|un|non)amidat/i
							&& $word =~ /amidat|site/i )
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

		# two layer
		# dobj(token, PRO)
		elsif ( $each_dep[$i] =~ /dobj\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			if (   $token !~ /(?:de|un|non)glycosylation/i
				&& $token =~ /amidat|cataly[s|z]ed|modified/i )
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
				/glycosylated|cataly[s|z]ed|modified|prevent|inhibit/i )
			{
				for ( my $j = $i - 1 ; $j > $i - 4 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if (   $word !~ /(?:de|un|non)amid/i
							&& $word =~ /amid|substrate/i )
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
						if (   $word !~ /(?:de|un|non)amid/i
							&& $word =~ /amid|substrate/i )
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
		if ( $each_dep[$i] =~ /nsubj\(amidat.*-\d+, (PRO\d+)-\d+\)/i ) {
			my $pro1 = $1;                  # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;    # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;    # search all possible appositives
		}

		# (7) nn
		# one layer
		if ( $each_dep[$i] !~
			/nn\((PRO\d+)-\d+'?, PRO\d+-(?:de|un|non)glycosylation-\d+'?\)/i
			&& $each_dep[$i] =~
			/nn\((PRO\d+)-\d+'?, PRO\d+-.*?glycosylation-\d+'?\)/i
			|| $each_dep[$i] =~ /nn\((?:phosphate)-\d+'?, (PRO\d+)-\d+'?\)/i )
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
						&& $word !~ /(?:de|un|non)amid/i
						&& $word =~ /amid/i )
					{
						@substrate = push_finding( $pro1, @substrate )
						  ;    # push the found element into corresponding array
						@substrate =
						  substrate_appositive( \@each_dep, $i, \@substrate,
							$pro1 );    # search all possible appositives
						last;
					}
					elsif ($relation !~ /agent|prep_with/
						&& $word !~ /(?:de|un|non)amid/i
						&& $word =~ /glycosylate/i )
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
		# partmod(PRO, glycosylation|glycosylation)
		if ( $each_dep[$i] !~
			/partmod\(PRO\d+-\d+'?, (?:de|un|non)amid.*?-\d+'?\)/i
			&& $each_dep[$i] =~
			/partmod\((PRO\d+)-\d+'?, .*?glycosylat(?:ed|ion)-\d+'?\)/i )
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
		# appos(PRO, [amid|substrate])
		if ( $each_dep[$i] !~
			/appos\(PRO\d+-\d+'?, (?:de|un|non)amid.*?-\d+'?\)/i
			&& $each_dep[$i] =~
			/appos\((PRO\d+)-\d+'?, (?:.*?amid.*?|substrates?)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# appos(amid, PRO)
		if ( $each_dep[$i] !~
			/appos\((?:de|un|non)amid.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/appos\((?:.*?amid.*?|substrates?)-\d+'?, (PRO\d+)-\d+'?\)/i )
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
						if ( $word =~ /glycosylation|substrate/i ) {
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
						if ( $word =~ /glycosylation|substrate/i ) {
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
		# prep_on([glycosylation|site], PRO)
		if ( $each_dep[$i] =~
			/prep_on\((?:.*?acetyl.*|sites?)-\d+'?, (PRO\d+)-\d+'?\)/i )
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
		# xsubj(glycosylation|phosphoprotein, PRO)
		if ( $each_dep[$i] !~
			/xsubj\((?:de|un|non)acetyl.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/xsubj\((?:acetylation)-\d+'?, (PRO\d+)-\d+'?\)/i )
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
		# prep_within(glycosylation, PRO)
		if ( $each_dep[$i] !~
			/prep_within\((?:de|un|non)acetylation-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/prep_within\(.*?acetylation-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
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
					if (   $word !~ /(?:de|un|non)amid/i
						&& $word =~ /acetylation/i )
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

		# (15) *(PRO-glycosylation, PRO)
		if ( $each_dep[$i] !~
			/.+?\(PRO\d+-(?:de|un|non)(?:acetylation)-\d+'?, (PRO\d+)-\d+'?\)/i
			&& $each_dep[$i] =~
			/.+?\(PRO\d+-.*?acetylation-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# (16) *(PRO-glycosylation, *) or *(*, PRO-glycosylation)
		if (   $each_dep[$i] =~ /.+?\((PRO\d+)-acetylation-\d+'?, .+?-\d+'?\)/i
			|| $each_dep[$i] =~
			/.+?\(.+?-\d+'?, (PRO\d+)-acetylation-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@substrate = push_finding( $pro1, @substrate )
			  ;               # push the found element into corresponding array
			@substrate =
			  substrate_appositive( \@each_dep, $i, \@substrate, $pro1 )
			  ;               # search all possible appositives
		}

		# (17) *(glycosylation, PRO)
		if ( $each_dep[$i] !~
			/.+?\((?:de|un|non)acetylation-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~ /.+?\(.*?acetylation-\d+'?, (PRO\d+)-\d+'?\)/i )
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

sub kinase_pattern_amidat {

	my @each_dep = @_;
	my @kinase   = ('NULL');

	for ( my $i = 0 ; $i < @each_dep ; $i++ ) {

		# (1) agent
		# one layer
		# agent(token, PRO)
		if ( $each_dep[$i] !~
			/agent\((?:de|un|non)acetylation-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
/agent\((?:.*?acetylation|cataly[s|z]ed|modified|mediated|labeled|recogni[s|z]ed|targeted)-\d+'?, (PRO\d+)-\d+'?\)/i
		  )
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
			/prep_by\((?:de|un|non)amidat.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
/prep_by\((?:.*?glycosylated|.*?acetylation|ser.*?|thr.*?|tyr.*?|PRO\d+)-\d+'?, (PRO\d+)-\d+'?\)/i
		  )
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

				# prep_by(acetyl, token) || prep_by(token, acetyl)
				if (   $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i
					|| $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i )
				{
					my $relation = $1;
					my $word     = $2;
					if (   $word !~ /(?:de|un|non)amid/i
						&& $word =~ /acetylation|PRO\d+/i )
					{
						@kinase = push_finding( $pro1, @kinase )
						  ;    # push the found element into corresponding array
						@kinase =
						  kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
						  ;    # search all possible appositives
						last;
					}
				}

				# [acetylation] by PRO
				elsif ( $each_dep[$j] =~
					/(.+?)\(.+?-\d+'?, (?:de|un|non)amidat.*?-\d+'?\)/i
					|| $each_dep[$j] =~
					/.+?\(.+?-\d+'?, (?:acetylation|amidat)-(\d+'?)\)/i )
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
/nsubj\((PRO\d+)(-specific)?-\d+'?, (?:ser.*?-?\d+|kinases?|enzymes?)-\d+'?\)/i
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
			/nsubj\((?:de|un|non)amidat.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
/nsubj\((?:.*?acetylated?|cataly[s|z]es?|modif(?:y|ies)|kinases?|enzymes?)-\d+'?, (PRO\d+)-\d+'?\)/i
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
			if (   $token !~ /(?:de|un|non)acetylation/i
				&& $token =~ /acetylation|cataly[s|z]ed|modified/i )
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
			elsif ( $token !~ /acetylation|cataly[s|z]ed|modified|substrate/i )
			{
				for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
					if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
						|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
					{
						my $relation = $1;
						my $word     = $2;
						if (   $relation !~ /prep_for/
							&& $word =~ /kinase|enzyme/i )
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
							&& $word =~ /kinase|enzyme/i )
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
			/prep_for\((?:de|un|non)amidat.*?-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
/prep_for\((?:.*?acetylation|substrates?|those|)-\d+'?, (PRO\d+)-\d+'?\)/i
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
		elsif ( $each_dep[$i] =~ /prep_for\((.+?-\d+'?), PRO\d+-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {

				# prep_by(token, PRO)
				if ( $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i ) {
					my $relation = $1;
					my $word     = $2;
					if (   $word !~ /(?:de|un|non)amidat/i
						&& $word =~ /.*?amidat.+?|PRO\d+/i )
					{
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

		# (5) nn
		# one layer
		# nn(PRO, PRO-acetylation)
		if (
			$each_dep[$i] =~ /nn\(PRO\d+-\d+'?, (PRO\d+)-acetylation-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# nn([kinase|substrate], PRO)
		elsif ( $each_dep[$i] =~
			/nn\((?:kinases?|substrates?)-\d+'?, (PRO\d+)-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# nn(PRO, kinase)
		elsif ( $each_dep[$i] =~ /nn\((PRO\d+)-\d+'?, (?:kinases?)-\d+'?\)/i ) {
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# two layer
		# nn(token, PRO)
		elsif ( $each_dep[$i] =~ /nn\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
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
							&& $word !~ /(?:de|un|non)amid/i
							&& $word =~ /acetylation|target/i
							|| $relation =~ /agent/ && $word =~ /acetylation/i )
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

		# two layer
		#prep_of(token, PRO)
		elsif ( $each_dep[$i] =~ /prep_of\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;
			for ( my $j = $i - 1 ; $j >= 0 ; $j-- ) {
				if (   $each_dep[$j] =~ /(.+?)\($token, (.+?-\d+'?)\)/i
					|| $each_dep[$j] =~ /(.+?)\((.+?-\d+'?), $token\)/i )
				{
					my $relation = $1;
					my $word     = $2;
					if (   $relation =~ /agent|prep_with|nsubj/
						&& $word !~ /(?:de|un|non)amid/i
						&& $word =~ /acetylation|acetylates/i )
					{
						@kinase = push_finding( $pro1, @kinase )
						  ;    # push the found element into corresponding array
						@kinase =
						  kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
						  ;    # search all possible appositives
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
					if (   $relation =~ /agent|prep_with|nusbj/
						&& $word !~ /(?:de|un|non)amid/i
						&& $word =~ /acetylation|acetylates/i )
					{
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

		# (7) amod
		# two layer
		if ( $each_dep[$i] =~ /amod\((.+?-\d+'?), (PRO\d+)-\d+'?\)/i ) {
			my $token = $1;
			my $pro1  = $2;    # capture PRO
			                   # if found kinase pattern
			for ( my $j = $i + 1 ; $j < @each_dep ; $j++ ) {

				# kinase pattern
				# [nn|prep_of](token, *)
				if (   $each_dep[$j] =~ /prep_of\($token, PRO\d+-\d+'?\)/i
					|| $each_dep[$j] !~
					/nn\($token, (?:de|un|non)acetylation.*?-\d+'?\)/i
					&& $each_dep[$j] =~
					/nn\($token, .*?acetylation.*?-\d+'?\)/i )
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
		if ( $each_dep[$i] =~ /appos\(kinases?-\d+'?, (PRO\d+)-\d+'?\)/i ) {
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
			if (   $token !~ /(?:de|un|non)acetylation/i
				&& $token =~ /acetylation|cataly[s|z]ed|modified/i )
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
		}

		# (10) xsubj
		# one layer
		# xsubj(acetylate, PRO)
		if ( $each_dep[$i] !~
			/xsubj\((?:de|un|non)acetylate-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/xsubj\(.*?glycosylate-\d+'?, (PRO\d+)-\d+'?\)/i )
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
				if ( $each_dep[$j] !~ /pobj\((?:de|un|non)amid.*?-\d+'?, by\)/i
					&& $each_dep[$j] =~
					/pobj\((?:glycosylation|catalysed)-\d+'?, by\)/i )
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
		# infmod(PRO, glycosylate)
		if ( $each_dep[$i] =~ /infmod\((PRO\d+)-\d+'?, glycosylate-\d+'?\)/i ) {
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

		# (14) *(PRO-glycosylation, PRO)
		if ( $each_dep[$i] !~
			/.+?\(PRO\d+-(?:de|un|non)acetylation-\d+'?, PRO\d+-\d+'?\)/i
			&& $each_dep[$i] =~
			/.+?\((PRO\d+)-.*?acetylation-\d+'?, PRO\d+-\d+'?\)/i )
		{
			my $pro1 = $1;    # capture PRO
			@kinase = push_finding( $pro1, @kinase )
			  ;               # push the found element into corresponding array
			@kinase = kinase_appositive( \@each_dep, $i, \@kinase, $pro1 )
			  ;               # search all possible appositives
		}

	}

	return @kinase;

}

sub site_pattern_amidat {

	my @each_dep = @_;
	my @site     = ('NULL');

	for ( my $i = 0 ; $i < @each_dep ; $i++ ) {

		# (1) prep_of
		if ( $each_dep[$i] =~ /prep_of\(.*, (Lys\d+?)-\d+\)/i ) {
			my $site_name = $1;
			@site = push_finding( $site_name, @site );
		}

		# (1) prep_at
		if ( $each_dep[$i] =~ /prep_at\(Acetylation-\d+, (Lys\d+?)-\d+\)/i ) {
			my $site_name = $1;
			@site = push_finding( $site_name, @site );
		}

		#(2)appos
		if ( $each_dep[$i] =~ /appos\((?:acetylation)-\d+, (PRO\d+?)-\d+\)/i ) {
			my $site_name = $1;
			@site = push_finding( $site_name, @site );
		}
		if ( $each_dep[$i] =~ /appos\((Asn|Leu|Thr)-\d+, (\d+)-\d+\)/i ) {
			my $site_name = $1 . $2;
			@site = push_finding( $site_name, @site );
		}

		#(3)nsubj
		if ( $each_dep[$i] =~ /nsubj\(site-\d+, (PRO\d+)-\d+\)/i ) {
			my $site_name = $1;
			@site = push_finding( $site_name, @site );
		}

		# (2) Asn Len Thr
		if ( $each_dep[$i] =~
/\(((?:Asn|Leu|Thr\bT|\bY)\d+(\\\/(?:Asn|Leu|Thr\bT|\bY)\d+)?)-\d+'?, /i
		  )
		{
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;    # push the found element into corresponding array
		}
		if ( $each_dep[$i] =~
			/, ((?:Asn|Leu|Thr)\d+(\\\/(?:Asn|Leu|Thr)\d+)?)-\d+'?\)/i )
		{
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;    # push the found element into corresponding array
		}

# (3) *(Asn|Leu|Thrserines?|threonines?|tyrosines?, \d+) or *(\d+, Asn|Leu|Thrserines?|threonines?|tyrosines?)
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

		# (5) SerP or ThrP or TyrP
		if ( $each_dep[$i] =~ /(SerP|ThrP|TyrP)/ ) {
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;        # push the found element into corresponding array
		}
##my site 
#	if ( $each_dep[$i] =~ /.+?\((.+)-?amide-\d+, .+?-\d+\)/i||$each_dep[$i] =~ /.+?\(.+?-\d+, (.+)-?amide-\d+\)/i ) {
#			my $site_name = $1;
#			@site = push_finding( $site_name, @site )
#			  ;        # push the found element into corresponding array
#		}
#		#(6)prep_in
#		if ( $each_dep[$i] =~ /prep_in\(.*(Gly-Arg-Phe-amide)-\d+, .+?\)/i ) {
#			my $site_name = $1;
#			@site = push_finding( $site_name, @site )
#			  ;        # push the found element into corresponding array
#		}
		if (   $each_dep[$i] =~ /advmod\((.*)-amide-\d+, .+?\)/i
			|| $each_dep[$i] =~ /acomp\(.+?, (.*)-amide-\d+\)/i
			|| $each_dep[$i] =~ /acomp\((.*)-amide-\d+, .+?\)/i
			|| $each_dep[$i] =~ /advmod\(.+?, (.*)-amide-\d+\)/i )
		{
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;        # push the found element into corresponding array
		}

		#(7)dep
		if ( $each_dep[$i] =~
			/dep\((pGlu|Leu|Thr|Phe|Ser|Pro|Asp|Trp|NH2)-\d+, .*amide\)/i)
		{
			my $site_name = $1;
			@site = push_finding( $site_name, @site )
			  ;        # push the found element into corresponding array
		}

		# (8) position + number
		# (9) residue + number
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

	}

	return @site;

}
1;
