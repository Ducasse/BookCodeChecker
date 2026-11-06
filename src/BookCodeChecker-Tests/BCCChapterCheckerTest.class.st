"
I test `BCCChapterChecker`.
"
Class {
	#name : 'BCCChapterCheckerTest',
	#superclass : 'TestCase',
	#category : 'BookCodeChecker-Tests',
	#package : 'BookCodeChecker-Tests'
}

{ #category : 'helpers' }
BCCChapterCheckerTest >> chapterWith: codeBlocks [
	"Answer a markdown chapter holding each string of codeBlocks in its own Smalltalk code block."

	^ String lf join: (codeBlocks inject: OrderedCollection new into: [ :lines :each |
				   lines
					   add: 'Some text.';
					   add: '';
					   add: '```smalltalk';
					   add: each;
					   add: '```';
					   add: '';
					   yourself ])
]

{ #category : 'helpers' }
BCCChapterCheckerTest >> discrepanciesOf: codeBlocks [

	^ BCCChapterChecker new checkString: (self chapterWith: codeBlocks)
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testClassDefinedInChapterIsKnown [

	self assert: (self discrepanciesOf: #( 'ZZBccBookWidget new' 'Object << #ZZBccBookWidget' )) isEmpty
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testDeprecatedClass [

	self
		assert: ((self discrepanciesOf: #( 'BCCDeprecatedClassFixture new' )) collect: [ :each | each kind -> each name ] as: Array)
		equals: { (#deprecatedClass -> #BCCDeprecatedClassFixture) }
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testDeprecatedSelector [

	self
		assert:
		((self discrepanciesOf: #( 'anObject bccObsoleteFixtureSelector' )) collect: [ :each | each kind -> each name ] as: Array)
		equals: { (#deprecatedSelector -> #bccObsoleteFixtureSelector) }
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testInlineClassSideMethodIsKnown [

	self assert: (BCCChapterChecker new checkString: 'See `OrderedCollection class>>#new:`.') isEmpty
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testInlineDeprecatedSelector [

	self
		assert: ((BCCChapterChecker new checkString: 'See `BCCDeprecatedFixture>>#bccObsoleteFixtureSelector`.')
				 collect: [ :each | each kind ]
				 as: Array)
		equals: #( deprecatedSelector )
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testInlineExpressionKnown [

	self assert: (BCCChapterChecker new checkString: 'Use `OrderedCollection new add: 3` here.') isEmpty
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testInlineExpressionNotUnderstood [

	self
		assert: ((BCCChapterChecker new checkString: 'Use `OrderedCollection new asUppercase` here.')
				 collect: [ :each | each kind -> each name ]
				 as: Array)
		equals: { (#notUnderstood -> 'OrderedCollection>>asUppercase') }
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testInlineInheritedMethodIsKnown [

	self assert: (BCCChapterChecker new checkString: 'See `OrderedCollection>>#printString`.') isEmpty
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testInlineKnownClass [

	self assert: (BCCChapterChecker new checkString: 'See `OrderedCollection` here.') isEmpty
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testInlineLineNumber [

	self assert: (BCCChapterChecker new checkString: (String lf join: #( 'a' 'b `ZZBccNoSuchClass`' ))) first lineNumber equals: 2
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testInlineMethodNotUnderstoodByClass [

	self
		assert: ((BCCChapterChecker new checkString: 'See `OrderedCollection>>#bccNeverImplemented:`.')
				 collect: [ :each | each kind -> each name ]
				 as: Array)
		equals: { (#notUnderstood -> 'OrderedCollection>>bccNeverImplemented:') }
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testInlineSelectorDefinedInChapterIsKnown [

	self assert: (BCCChapterChecker new checkString: (self chapterWith: #( 'Object >> bccBookDefinedSelector: x
	^ x' )) , 'Then `bccBookDefinedSelector:`.') isEmpty
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testInlineUnimplementedSelector [

	self
		assert:
		((BCCChapterChecker new checkString: 'Send `bccNeverImplemented:` here.') collect: [ :each | each kind -> each name ] as: Array)
		equals: { (#unimplementedSelector -> #bccNeverImplemented:) }
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testInlineUnknownClass [

	self
		assert:
		((BCCChapterChecker new checkString: 'See `ZZBccNoSuchClass` here.') collect: [ :each | each kind -> each name ] as: Array)
		equals: { (#unknownClass -> #ZZBccNoSuchClass) }
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testKnownCodeHasNoDiscrepancy [

	self assert: (self discrepanciesOf: #( 'OrderedCollection new add: 3; yourself' )) isEmpty
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testNonSmalltalkSnippetIsIgnored [

	self assert: (BCCChapterChecker new checkString: (String lf join: #( '```text' 'ZZBccNoSuchClass foo' '```' ))) isEmpty
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testSameDiscrepancyIsReportedOnce [

	self assert: (self discrepanciesOf: #( 'ZZBccNoSuchClass new. ZZBccNoSuchClass new' )) size equals: 1
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testSelectorDefinedInChapterIsKnown [

	self assert: (self discrepanciesOf: #( 'OrderedCollection new bccBookDefinedSelector'
			    'Object >> bccBookDefinedSelector
	^ 1' )) isEmpty
]

{ #category : 'tests - receiver types' }
BCCChapterCheckerTest >> testSelfSendNotUnderstoodByChapterClass [

	self
		assert: ((self discrepanciesOf: #( 'OrderedCollection << #ZZBccBookList' 'ZZBccBookList >> m
	^ self asUppercase' )) collect: [ :each | each kind -> each name ] as: Array)
		equals: { (#notUnderstood -> 'ZZBccBookList>>asUppercase') }
]

{ #category : 'tests - receiver types' }
BCCChapterCheckerTest >> testSelfSendToChapterMethod [

	self assert: (self discrepanciesOf: #( 'OrderedCollection << #ZZBccBookList' 'ZZBccBookList >> m
	^ self bccBookOther' 'ZZBccBookList >> bccBookOther
	^ 1' )) isEmpty
]

{ #category : 'tests - receiver types' }
BCCChapterCheckerTest >> testSelfSendToInheritedMethodOfChapterClass [

	self assert: (self discrepanciesOf: #( 'OrderedCollection << #ZZBccBookList' 'ZZBccBookList >> m
	^ self add: 3' )) isEmpty
]

{ #category : 'tests - receiver types' }
BCCChapterCheckerTest >> testSendDeprecatedInReceiverClass [

	self
		assert: ((self discrepanciesOf: #( 'BCCDeprecatedFixture new size' )) collect: [ :each | each kind -> each name ] as: Array)
		equals: { (#deprecatedSelector -> 'BCCDeprecatedFixture>>size') }
]

{ #category : 'tests - receiver types' }
BCCChapterCheckerTest >> testSendNotUnderstoodByReceiverClass [

	self
		assert: ((self discrepanciesOf: #( 'OrderedCollection new asUppercase' )) collect: [ :each | each kind -> each name ] as: Array)
		equals: { (#notUnderstood -> 'OrderedCollection>>asUppercase') }
]

{ #category : 'tests - receiver types' }
BCCChapterCheckerTest >> testSendUnderstoodByReceiverClass [

	self assert: (self discrepanciesOf: #( '| c | c := OrderedCollection new. c add: 3' )) isEmpty
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testUnimplementedSelector [

	self
		assert:
		((self discrepanciesOf: #( 'anObject bccNeverImplementedSelector' )) collect: [ :each | each kind -> each name ] as: Array)
		equals: { (#unimplementedSelector -> #bccNeverImplementedSelector) }
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testUnknownClassIsTheOnlyDiscrepancy [

	self assert: (self discrepanciesOf: #( 'ZZBccNoSuchClass new' )) size equals: 1
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testUnknownClassKind [

	self assert: (self discrepanciesOf: #( 'ZZBccNoSuchClass new' )) first kind equals: #unknownClass
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testUnknownClassLineNumber [

	self assert: (self discrepanciesOf: #( '3 + 4' 'ZZBccNoSuchClass new' )) first lineNumber equals: 10
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testUnknownClassName [

	self assert: (self discrepanciesOf: #( 'ZZBccNoSuchClass new' )) first name equals: #ZZBccNoSuchClass
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testUnknownHeaderClass [

	self
		assert: ((self discrepanciesOf: #( 'ZZBccNoSuchClass >> foo
	^ 1' )) collect: [ :each | each kind -> each name ] as: Array)
		equals: { (#unknownClass -> #ZZBccNoSuchClass) }
]

{ #category : 'tests' }
BCCChapterCheckerTest >> testUnparsableSnippet [

	self
		assert: ((self discrepanciesOf: #( 'this is ( plain text' )) collect: [ :each | each kind ] as: Array)
		equals: #( notParsable )
]
