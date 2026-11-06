"
I test `BCCSnippet`.
"
Class {
	#name : 'BCCSnippetTest',
	#superclass : 'TestCase',
	#category : 'BookCodeChecker-Tests',
	#package : 'BookCodeChecker-Tests'
}

{ #category : 'tests' }
BCCSnippetTest >> testClassSideHeaderClassName [

	| snippet |
	snippet := BCCSnippet source: 'Foo class >> bar
	^ 1'.
	self assert: snippet headerClassName equals: #Foo
]

{ #category : 'tests' }
BCCSnippetTest >> testDefaultLanguageIsSmalltalk [

	self assert: (BCCSnippet source: '3' language: 'Pharo' lineNumber: 1) isSmalltalk
]

{ #category : 'tests - receiver types' }
BCCSnippetTest >> testDefinedClassSuperclassName [

	self
		assert: ((BCCSnippet source: 'BlElement << #MyWidget
	package: ''X''') definedClasses at: #MyWidget)
		equals: #BlElement
]

{ #category : 'tests' }
BCCSnippetTest >> testExpressionHasNoHeaderClassName [

	| snippet |
	snippet := BCCSnippet source: '3 + 4'.
	self assert: snippet headerClassName isNil
]

{ #category : 'tests' }
BCCSnippetTest >> testExpressionReferencedGlobals [

	| snippet |
	snippet := BCCSnippet source: 'OrderedCollection new add: 3; yourself'.
	self assert: snippet referencedGlobals equals: #( OrderedCollection ) asSet
]

{ #category : 'tests' }
BCCSnippetTest >> testExpressionSentSelectors [

	| snippet |
	snippet := BCCSnippet source: 'OrderedCollection new add: 3; yourself'.
	self assert: snippet sentSelectors equals: #( new add: yourself ) asSet
]

{ #category : 'tests' }
BCCSnippetTest >> testLineNumber [

	self assert: (BCCSnippet source: '3' language: 'st' lineNumber: 12) lineNumber equals: 12
]

{ #category : 'tests' }
BCCSnippetTest >> testMethodWithHeaderClassName [

	| snippet |
	snippet := BCCSnippet source: 'Foo >> bar: x
	^ x printString'.
	self assert: snippet headerClassName equals: #Foo
]

{ #category : 'tests' }
BCCSnippetTest >> testMethodWithHeaderDefinedSelectors [

	| snippet |
	snippet := BCCSnippet source: 'Foo >> bar: x
	^ x printString'.
	self assert: snippet definedSelectors equals: #( bar: ) asSet
]

{ #category : 'tests' }
BCCSnippetTest >> testMethodWithHeaderIsParsable [

	| snippet |
	snippet := BCCSnippet source: 'Foo >> bar: x
	^ x printString'.
	self assert: snippet isParsable
]

{ #category : 'tests' }
BCCSnippetTest >> testMethodWithHeaderSentSelectors [

	| snippet |
	snippet := BCCSnippet source: 'Foo >> bar: x
	^ x printString'.
	self assert: snippet sentSelectors equals: #( printString ) asSet
]

{ #category : 'tests' }
BCCSnippetTest >> testMisspelledSmalltalkLanguageIsSmalltalk [

	self assert: (BCCSnippet source: '3' language: 'smalltak' lineNumber: 1) isSmalltalk
]

{ #category : 'tests' }
BCCSnippetTest >> testPlainTextHasNoReferencedGlobals [

	| snippet |
	snippet := BCCSnippet source: 'this is ( plain text'.
	self assert: snippet referencedGlobals isEmpty
]

{ #category : 'tests' }
BCCSnippetTest >> testPlainTextIsNotParsable [

	| snippet |
	snippet := BCCSnippet source: 'this is ( plain text'.
	self deny: snippet isParsable
]

{ #category : 'tests' }
BCCSnippetTest >> testShiftClassDefinitionDefinedClassNames [

	| snippet |
	snippet := BCCSnippet source: 'Object << #MyWidget
	slots: { #a };
	package: ''X'''.
	self assert: snippet definedClassNames equals: #( MyWidget ) asSet
]

{ #category : 'tests' }
BCCSnippetTest >> testStLanguageIsSmalltalk [

	self assert: (BCCSnippet source: '3' language: 'st' lineNumber: 1) isSmalltalk
]

{ #category : 'tests' }
BCCSnippetTest >> testSubclassDefinitionDefinedClassNames [

	| snippet |
	snippet := BCCSnippet source: 'Object subclass: #MyWidget
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''X'''.
	self assert: snippet definedClassNames equals: #( MyWidget ) asSet
]

{ #category : 'tests' }
BCCSnippetTest >> testTextLanguageIsNotSmalltalk [

	self deny: (BCCSnippet source: '3' language: 'text' lineNumber: 1) isSmalltalk
]

{ #category : 'tests - receiver types' }
BCCSnippetTest >> testTypeOfCascadeOnNewInstance [

	self assert: (self typeOf: #add: in: 'OrderedCollection new add: 3; yourself') equals: #OrderedCollection -> false
]

{ #category : 'tests - receiver types' }
BCCSnippetTest >> testTypeOfSelfSendInClassSideMethodWithHeader [

	self
		assert: (self typeOf: #bar in: 'Foo class >> m
	self bar')
		equals: #Foo -> true
]

{ #category : 'tests - receiver types' }
BCCSnippetTest >> testTypeOfSelfSendInMethodWithHeader [

	self
		assert: (self typeOf: #bar in: 'Foo >> m
	self bar')
		equals: #Foo -> false
]

{ #category : 'tests - receiver types' }
BCCSnippetTest >> testTypeOfSendToClass [

	self assert: (self typeOf: #new in: 'BlFoo new bar') equals: #BlFoo -> true
]

{ #category : 'tests - receiver types' }
BCCSnippetTest >> testTypeOfSendToNewInstance [

	self assert: (self typeOf: #bar in: 'BlFoo new bar') equals: #BlFoo -> false
]

{ #category : 'tests - receiver types' }
BCCSnippetTest >> testTypeOfSendToTemporaryAssignedTwice [

	self assert: (self typeOf: #foo in: '| e | e := OrderedCollection new. e := 3. e foo') isNil
]

{ #category : 'tests - receiver types' }
BCCSnippetTest >> testTypeOfSendToTemporaryHoldingNewInstance [

	self assert: (self typeOf: #add: in: '| e | e := OrderedCollection new. e add: 3') equals: #OrderedCollection -> false
]

{ #category : 'tests - receiver types' }
BCCSnippetTest >> testTypeOfSendToTemporaryHoldingOtherValue [

	self assert: (self typeOf: #foo in: '| e | e := 3. e foo') isNil
]

{ #category : 'tests - receiver types' }
BCCSnippetTest >> testTypeOfSuperSendIsUnknown [

	self assert: (self typeOf: #bar in: 'Foo >> m
	super bar') isNil
]

{ #category : 'tests - receiver types' }
BCCSnippetTest >> typeOf: aSelector in: aString [
	"Answer the receiver type the snippet aString infers for its first send of aSelector."

	| snippet |
	snippet := BCCSnippet source: aString.
	^ snippet receiverTypeOf: (snippet messageNodes detect: [ :each | each selector = aSelector ])
]
