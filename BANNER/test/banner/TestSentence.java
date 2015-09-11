/* 
 Copyright (c) 2007 Arizona State University, Dept. of Computer Science and Dept. of Biomedical Informatics.
 This file is part of the BANNER Named Entity Recognition System, http://banner.sourceforge.net
 This software is provided under the terms of the Common Public License, version 1.0, as published by http://www.opensource.org.  For further information, see the file 'LICENSE.txt' included with this distribution.
 */

package banner;

import static org.junit.Assert.*;

import org.junit.Test;

import banner.Sentence;
import banner.tagging.Mention;
import banner.tagging.MentionType;
import banner.tokenization.SimpleTokenizer;

public class TestSentence {

	@Test
	public void testGetSGML() {
		Sentence sentence = new Sentence(
				"Co-immunoprecipitation analysis confirmed that Bis interacted with Bcl-2 in vivo.");
		SimpleTokenizer tokenizer = new SimpleTokenizer();
		tokenizer.tokenize(sentence);
		sentence.addMention(new Mention(sentence, MentionType.getType("GENE"),
				6, 7));
		sentence.addMention(new Mention(sentence, MentionType.getType("GENE"),
				9, 12));
		assertEquals(2, sentence.getMentions().size());
		assertEquals(
				"Co - immunoprecipitation analysis confirmed that <GENE> Bis </GENE> interacted with <GENE> Bcl - 2 </GENE> in vivo .",
				sentence.getSGML());
	}

}
