"
I represent one place where the code shown in a chapter is not in sync with the code of the image.

## Responsibility:

- I know my kind: `#unknownClass`, `#deprecatedClass`, `#unimplementedSelector`, `#notUnderstood`, `#deprecatedSelector` or `#notParsable`.
- I know the name of the class or method concerned and the code block or inline reference where it appears.
- I answer the line of the chapter where I am, and print myself as `line 12: kind name`.

## Collaborators:

- `BCCChapterChecker` creates me.
- `BCCSnippet` or `BCCInlineReference` is my source and gives my line number.

## Public API and Key Messages

- `BCCDiscrepancy class >> #kind:name:snippet:` creates me.
- `kind`, `name`, `snippet`, `lineNumber`

```
BCCDiscrepancy exampleUnknownClass printString
	""'line 21: unknownClass BlUniverse'""
```

See `BCCDiscrepancy class >> #exampleUnknownClass` and `BCCDiscrepancy class >> #exampleNotUnderstood`.

## Internal Representation

- `kind` a Symbol, `name` a class name, a selector or a `Class>>selector` label, `snippet` the source of the discrepancy.

### Implementation Points

Two discrepancies with the same kind, name and line are equal, so the checker reports each one once.
"
Class {
	#name : 'BCCDiscrepancy',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'name',
		'snippet'
	],
	#category : 'BookCodeChecker-Core',
	#package : 'BookCodeChecker',
	#tag : 'Core'
}

{ #category : 'examples' }
BCCDiscrepancy class >> exampleNotUnderstood [

	<sampleInstance>
	^ self
		  kind: #notUnderstood
		  name: 'BlElement>>removeChildNamed:'
		  snippet: (BCCInlineReference text: 'BlElement>>#removeChildNamed:' lineNumber: 291)
]

{ #category : 'examples' }
BCCDiscrepancy class >> exampleUnknownClass [

	<sampleInstance>
	^ self
		  kind: #unknownClass
		  name: #BlUniverse
		  snippet: (BCCSnippet source: 'BlUniverse default' language: 'smalltalk' lineNumber: 21)
]

{ #category : 'instance creation' }
BCCDiscrepancy class >> kind: aSymbol name: aName snippet: aSnippet [

	^ self new
		  setKind: aSymbol name: aName snippet: aSnippet;
		  yourself
]

{ #category : 'comparing' }
BCCDiscrepancy >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ kind = anObject kind and: [ name = anObject name and: [ self lineNumber = anObject lineNumber ] ]
]

{ #category : 'comparing' }
BCCDiscrepancy >> hash [

	^ (kind hash bitXor: name hash) bitXor: self lineNumber hash
]

{ #category : 'accessing' }
BCCDiscrepancy >> kind [

	^ kind
]

{ #category : 'accessing' }
BCCDiscrepancy >> lineNumber [

	^ snippet lineNumber
]

{ #category : 'accessing' }
BCCDiscrepancy >> name [

	^ name
]

{ #category : 'printing' }
BCCDiscrepancy >> printOn: aStream [

	aStream
		nextPutAll: 'line ';
		print: self lineNumber;
		nextPutAll: ': ';
		nextPutAll: kind;
		space;
		nextPutAll: name
]

{ #category : 'initialization' }
BCCDiscrepancy >> setKind: aSymbol name: aName snippet: aSnippet [

	kind := aSymbol.
	name := aName.
	snippet := aSnippet
]

{ #category : 'accessing' }
BCCDiscrepancy >> snippet [

	^ snippet
]
