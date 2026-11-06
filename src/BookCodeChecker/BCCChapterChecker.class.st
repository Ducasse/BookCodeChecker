"
I check a Microdown chapter of a book against the code of the image and report the discrepancies, sorted by line.

## Responsibility:

- I find the classes that are unknown or deprecated, and the messages that nothing implements, that the receiver class does not understand, or that are deprecated.
- I check both the Smalltalk code blocks and the inline code references of the chapter.
- I take into account the classes and methods that the chapter defines itself, including inherited methods of the classes it defines.

## Collaborators:

- `BCCSnippetExtractor` reads the chapter.
- `BCCSnippet` and `BCCInlineReference` describe what the chapter shows.
- `BCCDiscrepancy` represents what I report.
- `SystemNavigation` and `Smalltalk globals` represent the image.

## Public API and Key Messages

- `checkString: aString` and `checkFile: aFileReference` answer the discrepancies.
- `discrepancies`, `snippets`, `inlineReferences` after a check.

```
(BCCChapterChecker new checkFile: 'Chapters/bloc/element.md') do: [ :each | Transcript crShow: each printString ]
```

See `BCCChapterChecker class >> #exampleCheckedSampleChapter`, run `BCCChapterChecker class >> #scriptCheckSampleChapter` or `BCCChapterChecker class >> #scriptCheckChapterFile`.

## Internal Representation

- `snippets` and `inlineReferences` are the checked parts of the chapter.
- `definedClasses` maps each class defined by the chapter to its superclass name; `definedSelectors` holds the selectors of the methods it defines.
- `discrepancies` is the result of the last check.

### Implementation Points

A discrepancy is a hint, not a proof: a message sent to an untyped receiver is only reported when no class of the image implements it.
"
Class {
	#name : 'BCCChapterChecker',
	#superclass : 'Object',
	#instVars : [
		'snippets',
		'definedSelectors',
		'inlineReferences',
		'definedClasses',
		'discrepancies'
	],
	#category : 'BookCodeChecker-Core',
	#package : 'BookCodeChecker',
	#tag : 'Core'
}

{ #category : 'examples' }
BCCChapterChecker class >> exampleCheckedSampleChapter [

	<sampleInstance>
	^ self new
		  checkString: BCCSnippetExtractor sampleChapter;
		  yourself
]

{ #category : 'script' }
BCCChapterChecker class >> scriptCheckChapterFile [
	"Ask for a Microdown chapter file and inspect the discrepancies between its code and the image."

	<script>
	(UIManager default chooseExistingFileReference: 'Chapter to check' extensions: #( 'md' ) path: FileLocator home) ifNotNil: [
		:file | (self new checkFile: file) inspect ]
]

{ #category : 'script' }
BCCChapterChecker class >> scriptCheckSampleChapter [
	"Inspect the discrepancies found in a sample chapter: an unknown class, a deprecated message and a message its receiver does not understand."

	<script>
	(self new checkString: BCCSnippetExtractor sampleChapter) inspect
]

{ #category : 'checking' }
BCCChapterChecker >> checkFile: aFileReference [

	^ self checkString: aFileReference asFileReference contents
]

{ #category : 'checking' }
BCCChapterChecker >> checkString: aString [
	"Answer the discrepancies, each reported once and sorted by line, between the Microdown chapter aString (its Smalltalk code blocks, its inline expressions and its inline class or method references) and the code of the image."

	| found |
	self readChapter: aString.
	found := OrderedCollection new.
	snippets do: [ :each | found addAll: (self discrepanciesOf: each) ].
	inlineReferences do: [ :each | found addAll: (self inlineDiscrepanciesOf: each) ].
	discrepancies := found asSet asOrderedCollection sort: [ :a :b |
		                 a lineNumber < b lineNumber or: [ a lineNumber = b lineNumber and: [ a printString <= b printString ] ] ].
	^ discrepancies
]

{ #category : 'private - checking' }
BCCChapterChecker >> classDiscrepancyOf: aName in: aSnippet [
	"Answer a discrepancy when the class aName is neither in the image nor defined by the chapter, or is deprecated; answer nil otherwise."

	(definedClasses includesKey: aName) ifTrue: [ ^ nil ].
	^ Smalltalk globals
		  at: aName
		  ifPresent: [ :global |
			  (global isClass and: [ global isDeprecated ]) ifTrue: [ BCCDiscrepancy kind: #deprecatedClass name: aName snippet: aSnippet ] ]
		  ifAbsent: [ BCCDiscrepancy kind: #unknownClass name: aName snippet: aSnippet ]
]

{ #category : 'accessing' }
BCCChapterChecker >> discrepancies [

	^ discrepancies
]

{ #category : 'private - checking' }
BCCChapterChecker >> discrepanciesOf: aSnippet [
	"Answer the discrepancies of aSnippet, each reported once."

	| classNames found |
	aSnippet isParsable ifFalse: [ ^ { (BCCDiscrepancy kind: #notParsable name: '' snippet: aSnippet) } ].
	classNames := aSnippet referencedGlobals copy.
	aSnippet headerClassName ifNotNil: [ :className | classNames add: className ].
	found := (classNames sorted collect: [ :each | self classDiscrepancyOf: each in: aSnippet ])
	         , (aSnippet messageNodes collect: [ :each | self sendDiscrepancyOf: each in: aSnippet ]).
	^ (found reject: [ :each | each isNil ]) asSet asOrderedCollection sort: [ :a :b | a printString <= b printString ]
]

{ #category : 'private - checking' }
BCCChapterChecker >> imageClassFor: aName [
	"Answer the image class named aName or, for a class defined by the chapter, its first ancestor present in the image; nil when there is none."

	| name |
	name := aName.
	[ name isNotNil ] whileTrue: [
		Smalltalk globals at: name ifPresent: [ :global | global isBehavior ifFalse: [ ^ nil ]. ^ global ].
		name := definedClasses at: name ifAbsent: [ nil ] ].
	^ nil
]

{ #category : 'private - checking' }
BCCChapterChecker >> inlineDiscrepanciesOf: aReference [

	| classDiscrepancy |
	classDiscrepancy := aReference referencedClassName ifNotNil: [ :className | self classDiscrepancyOf: className in: aReference ].
	classDiscrepancy ifNotNil: [ ^ { classDiscrepancy } ].
	aReference selector ifNil: [ ^ #(  ) ].
	^ (aReference isMethodReference
		   ifTrue: [ self methodDiscrepancyOf: aReference ]
		   ifFalse: [ self selectorDiscrepancyOf: aReference selector in: aReference ])
		  ifNil: [ #(  ) ]
		  ifNotNil: [ :discrepancy | { discrepancy } ]
]

{ #category : 'accessing' }
BCCChapterChecker >> inlineReferences [

	^ inlineReferences
]

{ #category : 'private - checking' }
BCCChapterChecker >> labelOf: aSelector in: aType [
	"Answer `Class>>selector` or `Class class>>selector` for aType (`className -> isClassSide`)."

	^ String streamContents: [ :stream |
			  stream nextPutAll: aType key.
			  aType value ifTrue: [ stream nextPutAll: ' class' ].
			  stream
				  nextPutAll: '>>';
				  nextPutAll: aSelector ]
]

{ #category : 'private - checking' }
BCCChapterChecker >> methodDiscrepancyOf: aReference [

	^ self typedDiscrepancyOf: aReference selector to: aReference referencedClassName -> aReference isClassSide in: aReference
]

{ #category : 'private - checking' }
BCCChapterChecker >> readChapter: aString [
	"Collect what the chapter aString shows (code blocks, inline expressions, inline references) and what it defines (classes and selectors)."

	| extractor references |
	extractor := BCCSnippetExtractor new.
	references := extractor inlineReferencesFrom: aString.
	snippets := ((extractor snippetsFrom: aString) select: [ :each | each isSmalltalk ])
	            , (references select: [ :each | each isInlineExpression ] thenCollect: [ :each | each asSnippet ]).
	inlineReferences := references select: [ :each | each isCheckable ].
	definedClasses := Dictionary new.
	snippets do: [ :each | definedClasses addAll: each definedClasses ].
	definedSelectors := Set new.
	snippets do: [ :each | definedSelectors addAll: each definedSelectors ]
]

{ #category : 'private - checking' }
BCCChapterChecker >> selectorDiscrepancyOf: aSelector in: aSnippet [
	"Answer a discrepancy when no method of the image or of the chapter implements aSelector, or when all its implementors are deprecated; answer nil otherwise."

	| implementors |
	(definedSelectors includes: aSelector) ifTrue: [ ^ nil ].
	implementors := SystemNavigation default allImplementorsOf: aSelector.
	implementors ifEmpty: [ ^ BCCDiscrepancy kind: #unimplementedSelector name: aSelector snippet: aSnippet ].
	(implementors allSatisfy: [ :each | each compiledMethod isDeprecated ]) ifFalse: [ ^ nil ].
	^ BCCDiscrepancy kind: #deprecatedSelector name: aSelector snippet: aSnippet
]

{ #category : 'private - checking' }
BCCChapterChecker >> sendDiscrepancyOf: aMessageNode in: aSnippet [
	"Check the send against the class of its receiver when aSnippet tells it, against all the image otherwise."

	^ (aSnippet receiverTypeOf: aMessageNode)
		  ifNil: [ self selectorDiscrepancyOf: aMessageNode selector in: aSnippet ]
		  ifNotNil: [ :type | self typedDiscrepancyOf: aMessageNode selector to: type in: aSnippet ]
]

{ #category : 'accessing' }
BCCChapterChecker >> snippets [

	^ snippets
]

{ #category : 'private - checking' }
BCCChapterChecker >> typedDiscrepancyOf: aSelector to: aType in: aSource [
	"Answer a discrepancy when the class described by aType (`className -> isClassSide`) does not understand aSelector or only through a deprecated method; answer nil otherwise or when the class is unknown."

	| behavior method label |
	(definedSelectors includes: aSelector) ifTrue: [ ^ nil ].
	behavior := (self imageClassFor: aType key) ifNil: [ ^ nil ].
	aType value ifTrue: [ behavior := behavior class ].
	label := self labelOf: aSelector in: aType.
	method := behavior lookupSelector: aSelector.
	method ifNil: [ ^ BCCDiscrepancy kind: #notUnderstood name: label snippet: aSource ].
	method isDeprecated ifFalse: [ ^ nil ].
	^ BCCDiscrepancy kind: #deprecatedSelector name: label snippet: aSource
]
