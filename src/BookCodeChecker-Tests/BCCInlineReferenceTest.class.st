"
I test `BCCInlineReference`.
"
Class {
	#name : 'BCCInlineReferenceTest',
	#superclass : 'TestCase',
	#category : 'BookCodeChecker-Tests',
	#package : 'BookCodeChecker-Tests'
}

{ #category : 'tests' }
BCCInlineReferenceTest >> referenceTo: aString [

	^ BCCInlineReference text: aString lineNumber: 1
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testClassReferenceClassName [

	self assert: (self referenceTo: 'BlElement') referencedClassName equals: #BlElement
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testClassReferenceHasNoSelector [

	self assert: (self referenceTo: 'BlElement') selector isNil
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testClassSideMethodReferenceClassName [

	self assert: (self referenceTo: 'BlElement class>>#new') referencedClassName equals: #BlElement
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testClassSideMethodReferenceIsClassSide [

	self assert: (self referenceTo: 'BlElement class>>#new') isClassSide
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testEscapedTextIsNotInlineExpression [

	self deny: (self referenceTo: 'AeCairo\-Image\-Surface') isInlineExpression
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testExpressionHasNoClassName [

	self assert: (self referenceTo: 'BlElement new') referencedClassName isNil
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testExpressionHasNoSelector [

	self assert: (self referenceTo: 'self addChild: x') selector isNil
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testExpressionIsInlineExpression [

	self assert: (self referenceTo: 'BlCircleGeometry new matchExtent: 100 @ 50') isInlineExpression
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testExpressionWithoutClassIsNotInlineExpression [

	self deny: (self referenceTo: 'x foo: 3') isInlineExpression
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testInlineExpressionSnippetLineNumber [

	self assert: (BCCInlineReference text: 'OrderedCollection new' lineNumber: 7) asSnippet lineNumber equals: 7
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testIsCheckable [

	self assert: (self referenceTo: 'addChild:') isCheckable
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testKeywordSelectorIsNotInlineExpression [

	self deny: (self referenceTo: 'addChild:') isInlineExpression
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testKeywordSelectorReference [

	self assert: (self referenceTo: 'addChild:at:') selector equals: #addChild:at:
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testKeywordSelectorReferenceHasNoClassName [

	self assert: (self referenceTo: 'addChild:') referencedClassName isNil
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testMethodReferenceClassName [

	self assert: (self referenceTo: 'BlElement>>#addChild:') referencedClassName equals: #BlElement
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testMethodReferenceIsInstanceSide [

	self deny: (self referenceTo: 'BlElement>>#addChild:') isClassSide
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testMethodReferenceSelector [

	self assert: (self referenceTo: 'BlElement>>#addChild:') selector equals: #addChild:
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testMethodReferenceWithSpacesSelector [

	self assert: (self referenceTo: 'BlElement >> addChild:') selector equals: #addChild:
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testPackageNameHasNoClassName [

	self assert: (self referenceTo: 'Bloc-Core') referencedClassName isNil
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testPlainWordIsNotCheckable [

	self deny: (self referenceTo: 'layout') isCheckable
]

{ #category : 'tests' }
BCCInlineReferenceTest >> testUnaryWordHasNoSelector [

	self assert: (self referenceTo: 'layout') selector isNil
]
