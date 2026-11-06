"
I extract from a Microdown chapter the code blocks and the inline code references, each with the line where it appears.

## Responsibility:

- I use Microdown to find the code blocks, in reading order, and compute their line numbers.
- I find the backquoted inline code outside code blocks.
- I hold the sample chapter used by the examples and scripts of the package.

## Collaborators:

- `Microdown` parses the chapter into `MicCodeBlock` elements.
- `BCCSnippet` and `BCCInlineReference` are the objects I create.
- `BCCChapterChecker` uses me to read a chapter.

## Public API and Key Messages

- `snippetsFrom: aString`
- `inlineReferencesFrom: aString`

```
BCCSnippetExtractor new snippetsFrom: BCCSnippetExtractor sampleChapter
```

Run `BCCSnippetExtractor class >> #scriptExtractSampleChapter`.

### Implementation Points

Microdown does not record line numbers, so I walk the lines in parallel and match each code block with the next fence line.
"
Class {
	#name : 'BCCSnippetExtractor',
	#superclass : 'Object',
	#category : 'BookCodeChecker-Core',
	#package : 'BookCodeChecker',
	#tag : 'Core'
}

{ #category : 'private - demo' }
BCCSnippetExtractor class >> sampleChapter [
	"Answer a small Microdown chapter whose code drifted from the image, used by the examples and scripts of the package."

	^ String lf join: #( '# Elements' '' 'An element is created with `BlElement new` and sized with `BlElement>>#size:`.'
		     '' '```smalltalk' 'BlElement new' '	size: 200 @ 100;' '	background: Color red;' '	yourself' '```' '' 'Elements live in a `BlUniverse`.'
		     '' '```' 'BlElement << #MyCircle' '	package: ''Demo''' '```' '' '```' 'MyCircle >> initialize' '	super initialize.'
		     '	self geometry: BlCircleGeometry new.' '	self removeAllChildrenNamed: #label' '```' )
]

{ #category : 'script' }
BCCSnippetExtractor class >> scriptExtractSampleChapter [
	"Inspect the code blocks and the inline code references extracted from a sample chapter, with their line numbers."

	<script>
	| extractor |
	extractor := self new.
	{
		(extractor snippetsFrom: self sampleChapter).
		(extractor inlineReferencesFrom: self sampleChapter) } inspect
]

{ #category : 'extracting' }
BCCSnippetExtractor >> codeBlocksIn: aString [

	| blocks |
	blocks := OrderedCollection new.
	self collectCodeBlocksOf: (Microdown parse: aString) into: blocks.
	^ blocks
]

{ #category : 'extracting' }
BCCSnippetExtractor >> collectCodeBlocksOf: aMicElement into: blocks [
	"Walk the Microdown tree depth first so code blocks nested in lists or quotes are found in reading order."

	aMicElement class = MicCodeBlock ifTrue: [
			blocks add: aMicElement.
			^ self ].
	aMicElement children do: [ :each | self collectCodeBlocksOf: each into: blocks ]
]

{ #category : 'extracting' }
BCCSnippetExtractor >> indexOfFenceIn: lines from: start [
	"Answer the index of the first line, from start on, that opens a code block."

	^ (start to: lines size) detect: [ :index | (lines at: index) trimLeft beginsWith: '```' ] ifNone: [ start ]
]

{ #category : 'extracting' }
BCCSnippetExtractor >> inlineReferencesFrom: aString [
	"Answer an inline reference for each backquoted text of aString found outside code blocks, with its line."

	| references inCodeBlock |
	references := OrderedCollection new.
	inCodeBlock := false.
	aString lines doWithIndex: [ :line :index |
			(line trimLeft beginsWith: '```')
				ifTrue: [ inCodeBlock := inCodeBlock not ]
				ifFalse: [ inCodeBlock ifFalse: [ references addAll: (self inlineReferencesIn: line at: index) ] ] ].
	^ references
]

{ #category : 'extracting' }
BCCSnippetExtractor >> inlineReferencesIn: aLine at: anIndex [

	^ ('`([^`]+)`' asRegex matchesIn: aLine) collect: [ :match |
		  BCCInlineReference text: (match copyFrom: 2 to: match size - 1) lineNumber: anIndex ]
]

{ #category : 'extracting' }
BCCSnippetExtractor >> snippetsFrom: aString [
	"Answer a snippet for each Microdown code block of aString, in reading order, with the line where its code starts."

	| lines cursor |
	lines := aString lines.
	cursor := 1.
	^ (self codeBlocksIn: aString) collect: [ :block |
			  | fence |
			  fence := self indexOfFenceIn: lines from: cursor.
			  cursor := (self indexOfFenceIn: lines from: fence + 1 + block body lines size) + 1.
			  BCCSnippet source: block body language: block language lineNumber: fence + 1 ]
]
