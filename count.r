REBOL [ Title: "Count words" ]

count-words: func [
    source
    /local words old-count
][
    words: make hash! 32768
    foreach word parse lowercase read source to-string [#"^/" #"^-" #" "] [
        either old-count: select words word [
            change old-count add first old-count 1
        ][
            insert tail words copy/deep reduce [word [1]]
        ]
    ]
    form sort/skip/compare/reverse words 2 2
]

print count-words to-file first system/options/args
