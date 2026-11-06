"
I am a test fixture of `BCCChapterCheckerTest`: my methods are deprecated so that the checker reports their use.
"
Class {
	#name : 'BCCDeprecatedFixture',
	#superclass : 'Object',
	#category : 'BookCodeChecker-Tests',
	#package : 'BookCodeChecker-Tests'
}

{ #category : 'fixture' }
BCCDeprecatedFixture >> bccObsoleteFixtureSelector [
	"I stand for a deprecated method in the checker tests."

	self deprecated: 'Only a test fixture'
]

{ #category : 'accessing' }
BCCDeprecatedFixture >> size [
	"I stand for a method deprecated in one class while other classes still implement its selector."
	self deprecated: 'Only a test fixture'.
	^ 0
]
