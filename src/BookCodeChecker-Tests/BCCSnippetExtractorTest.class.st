"
I test `BCCSnippetExtractor`.
"
Class {
	#name : 'BCCSnippetExtractorTest',
	#superclass : 'TestCase',
	#category : 'BookCodeChecker-Tests',
	#package : 'BookCodeChecker-Tests'
}

{ #category : 'tests' }
BCCSnippetExtractorTest >> sampleText [

	^ String lf join:
		  #( '# Title' '' 'Some text.' '' '```smalltalk' 'BlElement new' '```' '' 'More text.' '' '```' 'Foo >> bar' '	^ 1' '```' '' '```text'
		     'not code' '```' )
]

{ #category : 'tests' }
BCCSnippetExtractorTest >> sampleTextWithInlineCode [

	^ String lf join: #( 'Use `BlElement` and `addChild:`.' '```' 'a `notInline` b' '```' 'Then `layout`.' )
]

{ #category : 'tests' }
BCCSnippetExtractorTest >> testInlineReferenceLineNumbers [

	self
		assert:
		((BCCSnippetExtractor new inlineReferencesFrom: self sampleTextWithInlineCode) collect: [ :each | each lineNumber ] as: Array)
		equals: #( 1 1 5 )
]

{ #category : 'tests' }
BCCSnippetExtractorTest >> testInlineReferenceTexts [

	self
		assert: ((BCCSnippetExtractor new inlineReferencesFrom: self sampleTextWithInlineCode) collect: [ :each | each text ] as: Array)
		equals: #( 'BlElement' 'addChild:' 'layout' )
]

{ #category : 'tests' }
BCCSnippetExtractorTest >> testLineNumbersAfterBlockEndingWithBlankLine [

	| text |
	text := String lf join: #( '```' 'a foo' '' '```' 'text' '```' 'b bar' '```' ).
	self assert: ((BCCSnippetExtractor new snippetsFrom: text) collect: [ :each | each lineNumber ] as: Array) equals: #( 2 7 )
]

{ #category : 'tests' }
BCCSnippetExtractorTest >> testSnippetCount [

	self assert: (BCCSnippetExtractor new snippetsFrom: self sampleText) size equals: 3
]

{ #category : 'tests' }
BCCSnippetExtractorTest >> testSnippetLanguages [

	self
		assert: ((BCCSnippetExtractor new snippetsFrom: self sampleText) collect: [ :each | each isSmalltalk ] as: Array)
		equals: #( true true false )
]

{ #category : 'tests' }
BCCSnippetExtractorTest >> testSnippetLineNumbers [

	self
		assert: ((BCCSnippetExtractor new snippetsFrom: self sampleText) collect: [ :each | each lineNumber ] as: Array)
		equals: #( 6 12 17 )
]

{ #category : 'tests' }
BCCSnippetExtractorTest >> testSnippetSources [

	self
		assert: ((BCCSnippetExtractor new snippetsFrom: self sampleText) collect: [ :each | each source lines first ] as: Array)
		equals: #( 'BlElement new' 'Foo >> bar' 'not code' )
]

{ #category : 'tests' }
BCCSnippetExtractorTest >> testTextWithoutCodeHasNoSnippet [

	self assert: (BCCSnippetExtractor new snippetsFrom: 'just text') isEmpty
]
