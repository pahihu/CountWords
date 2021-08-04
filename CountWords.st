'From Squeak5.3 of 28 May 2021 [latest update: #19459] on 4 August 2021 at 3:06:04 pm'!
Object subclass: #CountWords
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'CountWords-Test'!

!CountWords methodsFor: 'as yet unclassified' stamp: 'ap 8/4/2021 14:39'!
processFile: anInputFile
	| frequency |
	
	"FileDirectory setDefaultDirectory: '<YourCountWordsDirectory'."
	frequency := Bag new.	
	StandardFileStream readOnlyFileNamed: anInputFile do: [ :aStream |
		[aStream atEnd] whileFalse: [
			frequency addAll: (aStream nextLine translateToLowercase findTokens: ' ')
		]
	].
	
	StandardFileStream forceNewFileNamed: 'talk.result' do: [ :aStream |
		(frequency valuesAndCounts associations asSortedCollection: [ :x :y | x value > y value ]) 
			printElementsOn: aStream
			separatedBy: Character lf
	].
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

CountWords class
	instanceVariableNames: ''!

!CountWords class methodsFor: 'as yet unclassified' stamp: 'ap 8/4/2021 11:05'!
run
	^self run: 'kjvbible_x10.txt'! !

!CountWords class methodsFor: 'as yet unclassified' stamp: 'ap 8/4/2021 11:04'!
run: anInputFile
	"Process words from anInputFile"

	^self new processFile: anInputFile
! !

