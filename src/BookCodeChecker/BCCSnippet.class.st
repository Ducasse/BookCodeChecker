"
I represent one code block of a Microdown chapter: its source, the fence language and the line where its code starts.

## Responsibility:

- I parse my source as a book method (`Class >> selector` header followed by the body), a plain method or an expression.
- I tell which classes my code uses, which messages it sends, and which classes and methods it defines.
- I infer, when my code tells it, the class of the receiver of a message (`X new`, a temporary assigned once, `self` in a method with header).

## Collaborators:

- `BCCSnippetExtractor` creates me from the code blocks of a chapter.
- `BCCChapterChecker` asks me for globals, sends and receiver types to compare them with the image.
- `RBParser` builds my parse tree.

## Public API and Key Messages

- `BCCSnippet class >> #source:` and `#source:language:lineNumber:` create me.
- `isSmalltalk`, `isParsable`
- `referencedGlobals`, `sentSelectors`, `messageNodes`, `receiverTypeOf:`
- `definedClasses`, `definedClassNames`, `definedSelectors`, `headerClassName`

```
(BCCSnippet source: 'MyCircle >> initialize
	super initialize.
	self geometry: BlCircleGeometry new') definedSelectors
	""a Set(#initialize)""
```

See `BCCSnippet class >> #exampleMethodWithHeader` and `BCCSnippet class >> #exampleExpression`.

## Internal Representation

- `source` the code of the block, `language` the fence argument, `lineNumber` the line of the first code line in the chapter.
- `ast` the parse tree, lazily computed, nil when the code does not parse.
- `headerClassName` and `headerIsClassSide` describe the `Class >> selector` header line, if any.

### Implementation Points

A source such as `space show` also parses as a method named `space`. I only accept a plain method when its selector is lowercase and alone on the first line.
"
Class {
	#name : 'BCCSnippet',
	#superclass : 'Object',
	#instVars : [
		'source',
		'lineNumber',
		'language',
		'ast',
		'headerClassName',
		'headerIsClassSide'
	],
	#category : 'BookCodeChecker-Core',
	#package : 'BookCodeChecker',
	#tag : 'Core'
}

{ #category : 'examples' }
BCCSnippet class >> exampleExpression [

	<sampleInstance>
	^ self
		  source: 'BlElement new
	background: Color red;
	yourself'
		  language: 'smalltalk'
		  lineNumber: 12
]

{ #category : 'examples' }
BCCSnippet class >> exampleMethodWithHeader [

	<sampleInstance>
	^ self source: 'MyCircle >> initialize
	super initialize.
	self geometry: BlCircleGeometry new'
]

{ #category : 'instance creation' }
BCCSnippet class >> source: aString [

	^ self source: aString language: 'smalltalk' lineNumber: 1
]

{ #category : 'instance creation' }
BCCSnippet class >> source: aString language: aLanguage lineNumber: anInteger [

	^ self new
		  setSource: aString language: aLanguage lineNumber: anInteger;
		  yourself
]

{ #category : 'accessing' }
BCCSnippet >> ast [
	"Answer the parse tree of my source, or nil when it is not Smalltalk code."

	^ ast ifNil: [ ast := self parse ]
]

{ #category : 'querying' }
BCCSnippet >> declaresName: aString [

	^ self nodes anySatisfy: [ :node |
			  (node isSequence or: [ node isBlock or: [ node isMethod ] ]) and: [
				  (node temporaryNames includes: aString) or: [ node isSequence not and: [ node argumentNames includes: aString ] ] ] ]
]

{ #category : 'querying' }
BCCSnippet >> definedClassNames [
	"Answer the names of the classes my code defines with `<<` or `subclass:...` messages."

	^ self definedClasses keys asSet
]

{ #category : 'querying' }
BCCSnippet >> definedClasses [
	"Answer a dictionary mapping the name of each class my code defines with `<<` or `subclass:...` to the name of its superclass (nil when it is not a plain class name)."

	| classes |
	classes := Dictionary new.
	self messageNodes do: [ :node |
			(self isClassDefinition: node) ifTrue: [
				classes at: node arguments first value put: (node receiver isVariable ifTrue: [ node receiver name asSymbol ]) ] ].
	^ classes
]

{ #category : 'querying' }
BCCSnippet >> definedSelectors [
	"Answer the selector of the method my code defines, if any."

	^ self ast
		  ifNotNil: [ :tree |
				  tree isMethod
					  ifTrue: [ Set with: tree selector ]
					  ifFalse: [ Set new ] ]
		  ifNil: [ Set new ]
]

{ #category : 'accessing' }
BCCSnippet >> headerClassName [
	"Answer the name of the class given in a `Class >> selector` header line, or nil for an expression."

	self ast.
	^ headerClassName
]

{ #category : 'private - typing' }
BCCSnippet >> isClassDefinition: aMessageNode [

	^ (aMessageNode selector = #'<<' or: [ aMessageNode selector beginsWith: 'subclass:' ]) and: [
		  aMessageNode arguments first isLiteralNode and: [ aMessageNode arguments first value isSymbol ] ]
]

{ #category : 'private - typing' }
BCCSnippet >> isGlobalName: aString [

	^ aString first isUppercase and: [ (self declaresName: aString) not ]
]

{ #category : 'testing' }
BCCSnippet >> isParsable [

	^ self ast isNotNil
]

{ #category : 'testing' }
BCCSnippet >> isSmalltalk [
	"Answer whether the fence language of my code block denotes Pharo code (misspellings included)."

	| lowercase |
	lowercase := language asLowercase.
	^ lowercase = 'pharo' or: [ lowercase = 'st' or: [ lowercase includesSubstring: 'smal' ] ]
]

{ #category : 'accessing' }
BCCSnippet >> language [

	^ language
]

{ #category : 'accessing' }
BCCSnippet >> lineNumber [

	^ lineNumber
]

{ #category : 'querying' }
BCCSnippet >> messageNodes [

	^ self nodes select: [ :node | node isMessage ]
]

{ #category : 'querying' }
BCCSnippet >> nodes [
	"Answer my parse tree root and all its descendants."

	^ self ast ifNil: [ #(  ) ] ifNotNil: [ :tree | tree allChildren copyWithFirst: tree ]
]

{ #category : 'private - parsing' }
BCCSnippet >> parse [
	"Answer my parse tree, trying a method with a header line, a method, then an expression."

	^ self parseWithHeader ifNil: [ self parseAsMethod ifNil: [ self parseAsExpression ] ]
]

{ #category : 'private - parsing' }
BCCSnippet >> parseAsExpression [

	^ RBParser parseExpression: source onError: [ :message :position | ^ nil ]
]

{ #category : 'private - parsing' }
BCCSnippet >> parseAsMethod [
	"Parse my source as a method without header. Expressions such as `space show` also parse as methods, so I only accept a lowercase selector pattern alone on the first line."

	| firstLineSize tree |
	firstLineSize := (source lines ifEmpty: [ ^ nil ]) first size.
	tree := (self parseAsMethod: source) ifNil: [ ^ nil ].
	(tree selector first isLowercase and: [ tree body statements isEmpty or: [ tree body start > firstLineSize ] ]) ifFalse: [ ^ nil ].
	^ tree
]

{ #category : 'private - parsing' }
BCCSnippet >> parseAsMethod: aString [

	^ RBParser parseMethod: aString onError: [ :message :position | ^ nil ]
]

{ #category : 'private - parsing' }
BCCSnippet >> parseWithHeader [
	"Parse a book method written as `Class >> selector` or `Class class >> selector` followed by its body."

	| lines header classPart |
	lines := source lines.
	lines ifEmpty: [ ^ nil ].
	header := lines first.
	(header includesSubstring: '>>') ifFalse: [ ^ nil ].
	^ (self parseAsMethod: (String cr join: { (header copyAfter: $>) allButFirst trimBoth } , lines allButFirst)) ifNotNil: [ :tree |
			  classPart := (header copyUpTo: $>) substrings.
			  headerClassName := (classPart ifEmpty: [ #( '' ) ]) first asSymbol.
			  headerIsClassSide := classPart size > 1 and: [ classPart second = 'class' ].
			  tree ]
]

{ #category : 'querying' }
BCCSnippet >> receiverTypeOf: aMessageNode [
	"Answer `className -> isClassSide` for the receiver of aMessageNode when my code tells its class, nil otherwise."

	^ self typeOfNode: aMessageNode receiver
]

{ #category : 'querying' }
BCCSnippet >> referencedGlobals [
	"Answer the capitalised variable names my code uses and does not declare as temporaries or arguments."

	^ (self nodes select: [ :node | node isVariable and: [ node name first isUppercase and: [ (self declaresName: node name) not ] ] ])
		  collect: [ :node | node name asSymbol ]
		  as: Set
]

{ #category : 'querying' }
BCCSnippet >> sentSelectors [

	^ self messageNodes collect: [ :node | node selector ] as: Set
]

{ #category : 'initialization' }
BCCSnippet >> setSource: aString language: aLanguage lineNumber: anInteger [

	source := aString.
	language := aLanguage.
	lineNumber := anInteger.
	headerIsClassSide := false
]

{ #category : 'accessing' }
BCCSnippet >> source [

	^ source
]

{ #category : 'private - typing' }
BCCSnippet >> typeOfInstanceCreation: aMessageNode [
	"Answer the type of `Class new`, nil for any other message."

	(aMessageNode selector = #new and: [ aMessageNode receiver isVariable and: [ self isGlobalName: aMessageNode receiver name ] ]) ifFalse: [ ^ nil ].
	^ aMessageNode receiver name asSymbol -> false
]

{ #category : 'private - typing' }
BCCSnippet >> typeOfNode: aNode [
	"Answer `className -> isClassSide` for the value of aNode, inferred from `self` in a method with header, a class reference, `Class new`, a `Class new ...; yourself` cascade, or a temporary assigned once with one of them. Answer nil when unknown."

	aNode isVariable ifTrue: [ ^ self typeOfVariable: aNode name ].
	aNode isMessage ifTrue: [ ^ self typeOfInstanceCreation: aNode ].
	(aNode isCascade and: [ aNode messages last selector = #yourself ]) ifTrue: [ ^ self typeOfNode: aNode receiver ].
	^ nil
]

{ #category : 'private - typing' }
BCCSnippet >> typeOfTemporary: aName [
	"Answer the type of the value of the temporary aName when it is assigned exactly once, nil otherwise."

	| assignments |
	assignments := self nodes select: [ :node | node isAssignment and: [ node variable name = aName ] ].
	assignments size = 1 ifFalse: [ ^ nil ].
	^ self typeOfNode: assignments first value
]

{ #category : 'private - typing' }
BCCSnippet >> typeOfVariable: aName [

	aName = #self ifTrue: [ ^ headerClassName ifNotNil: [ :name | name -> headerIsClassSide ] ].
	(self isGlobalName: aName) ifTrue: [ ^ aName asSymbol -> true ].
	^ self typeOfTemporary: aName
]
