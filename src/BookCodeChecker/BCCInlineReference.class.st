"
I represent a piece of inline code (text between backquotes) of a chapter that names a class, a method or a keyword selector.

## Responsibility:

- I recognise `Class`, `Class>>#selector`, `Class class>>#selector` and `keyword:selector:` references.
- I answer the class name, the selector and the side of the method I name.
- I know the line where I appear in the chapter.

## Collaborators:

- `BCCSnippetExtractor` creates me from the lines of a chapter.
- `BCCChapterChecker` looks up my class and selector in the image.

## Public API and Key Messages

- `BCCInlineReference class >> #text:lineNumber:` creates me.
- `referencedClassName`, `selector`, `isClassSide`, `isMethodReference`, `isCheckable`
- `isInlineExpression` and `asSnippet` for inline code that is a whole expression, such as `BlCircleGeometry new matchExtent: 100 @ 50`, checked like a code block

```
(BCCInlineReference text: 'BlElement>>#addChild:' lineNumber: 12) selector
	""#addChild:""
```

See `BCCInlineReference class >> #exampleMethodReference` and `BCCInlineReference class >> #exampleKeywordSelector`.

## Internal Representation

- `text` the trimmed inline code, `lineNumber` its line in the chapter.

### Implementation Points

Plain words such as `layout` are not checkable: they could be a variable, a unary selector or an English word.
"
Class {
	#name : 'BCCInlineReference',
	#superclass : 'Object',
	#instVars : [
		'text',
		'lineNumber'
	],
	#category : 'BookCodeChecker-Core',
	#package : 'BookCodeChecker',
	#tag : 'Core'
}

{ #category : 'examples' }
BCCInlineReference class >> exampleKeywordSelector [

	<sampleInstance>
	^ self text: 'addChild:at:' lineNumber: 3
]

{ #category : 'examples' }
BCCInlineReference class >> exampleMethodReference [

	<sampleInstance>
	^ self text: 'BlElement>>#addChild:' lineNumber: 12
]

{ #category : 'instance creation' }
BCCInlineReference class >> text: aString lineNumber: anInteger [

	^ self new
		  setText: aString lineNumber: anInteger;
		  yourself
]

{ #category : 'converting' }
BCCInlineReference >> asSnippet [

	^ BCCSnippet source: text language: 'smalltalk' lineNumber: lineNumber
]

{ #category : 'private - patterns' }
BCCInlineReference >> classPattern [

	^ '[A-Z][A-Za-z0-9]*' asRegex
]

{ #category : 'testing' }
BCCInlineReference >> isCheckable [
	"Answer whether I name a class, a method or a keyword selector that can be looked up in the image."

	^ self referencedClassName isNotNil or: [ self selector isNotNil ]
]

{ #category : 'testing' }
BCCInlineReference >> isClassSide [

	^ self methodMatch ifNil: [ false ] ifNotNil: [ :matcher | (matcher subexpression: 3) isNotNil ]
]

{ #category : 'testing' }
BCCInlineReference >> isInlineExpression [
	"Answer whether I am a Smalltalk expression that sends messages and uses a class, such as `BlCircleGeometry new matchExtent: 100 @ 50`. Text with Microdown escapes (`\`) is prose, not code."

	| snippet |
	self isCheckable ifTrue: [ ^ false ].
	(text includes: $\) ifTrue: [ ^ false ].
	snippet := self asSnippet.
	^ snippet isParsable and: [ snippet messageNodes isNotEmpty and: [ snippet referencedGlobals isNotEmpty ] ]
]

{ #category : 'testing' }
BCCInlineReference >> isMethodReference [

	^ self methodMatch isNotNil
]

{ #category : 'private - patterns' }
BCCInlineReference >> keywordSelectorPattern [

	^ '([a-zA-Z][A-Za-z0-9]*\:)+' asRegex
]

{ #category : 'accessing' }
BCCInlineReference >> lineNumber [

	^ lineNumber
]

{ #category : 'private - patterns' }
BCCInlineReference >> methodMatch [
	"Answer the matcher of my text against the method reference pattern, or nil when it does not match."

	| matcher |
	matcher := self methodPattern.
	(matcher matches: text) ifFalse: [ ^ nil ].
	^ matcher
]

{ #category : 'private - patterns' }
BCCInlineReference >> methodPattern [
	"Match `Class>>#selector`, `Class >> selector` and `Class class>>#selector`."

	^ '([A-Z][A-Za-z0-9]*)( class)? *>> *#?([^ ]+)' asRegex
]

{ #category : 'accessing' }
BCCInlineReference >> referencedClassName [
	"Answer the class named by a `Class` or `Class>>#selector` reference, or nil."

	(self classPattern matches: text) ifTrue: [ ^ text asSymbol ].
	^ self methodMatch ifNotNil: [ :matcher | (matcher subexpression: 2) asSymbol ]
]

{ #category : 'accessing' }
BCCInlineReference >> selector [
	"Answer the selector named by a `Class>>#selector` or keyword selector reference, or nil."

	(self keywordSelectorPattern matches: text) ifTrue: [ ^ text asSymbol ].
	^ self methodMatch ifNotNil: [ :matcher | (matcher subexpression: 4) asSymbol ]
]

{ #category : 'initialization' }
BCCInlineReference >> setText: aString lineNumber: anInteger [

	text := aString trimBoth.
	lineNumber := anInteger
]

{ #category : 'accessing' }
BCCInlineReference >> text [

	^ text
]
