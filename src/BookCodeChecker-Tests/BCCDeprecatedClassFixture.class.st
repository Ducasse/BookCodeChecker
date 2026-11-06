"
I am a test fixture of `BCCChapterCheckerTest`: I answer true to `isDeprecated` so that the checker reports my use.
"
Class {
	#name : 'BCCDeprecatedClassFixture',
	#superclass : 'Object',
	#category : 'BookCodeChecker-Tests',
	#package : 'BookCodeChecker-Tests'
}

{ #category : 'testing' }
BCCDeprecatedClassFixture class >> isDeprecated [
	"I stand for a deprecated class in the checker tests."

	^ true
]
