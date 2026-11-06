"
I am the Metacello baseline of the book code checker, the tool that compares the code shown in Microdown book chapters with the code of the image.

## Responsibility:

- I declare the packages `BookCodeChecker` (the checker) and `BookCodeChecker-Tests` (its tests, which require it).
- I define the groups `Core`, `Tests` and `default` (both).
- I need no external project: Microdown and the `RBParser` are part of Pharo.

## Collaborators:

- `Metacello` reads my `baseline:` method to load the packages.
- `BCCChapterChecker` is the entry point of what I load.

## Public API and Key Messages

- `baseline: spec`
- groups: `Core`, `Tests`, `default`

Load it with:

```
Metacello new
	baseline: 'BookCodeChecker';
	repository: 'github://Ducasse/BookCodeChecker:master/src';
	load: #( 'Core' )
```

Run `BaselineOfBookCodeChecker class >> #scriptInspectPackages` to see the declared packages.
"
Class {
	#name : 'BaselineOfBookCodeChecker',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfBookCodeChecker',
	#package : 'BaselineOfBookCodeChecker'
}

{ #category : 'script' }
BaselineOfBookCodeChecker class >> scriptInspectPackages [
	"Inspect the packages this baseline declares, each with the packages it requires."
	<script>
	(self project version spec packages collect: [ :each | each name -> each requires ]) inspect
]

{ #category : 'baselines' }
BaselineOfBookCodeChecker >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec
				package: 'BookCodeChecker';
				package: 'BookCodeChecker-Tests' with: [ spec requires: #( 'BookCodeChecker' ) ].
			spec
				group: 'Core' with: #( 'BookCodeChecker' );
				group: 'Tests' with: #( 'BookCodeChecker-Tests' );
				group: 'default' with: #( 'Core' 'Tests' ) ]
]
