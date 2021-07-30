REBOL [ Title: "Count words" ]

count-words: funct [source][
    words: make hash! 32768
    foreach word parse lowercase read source to-string [#"^/" #"^-" #" "] [
        either pos: select words word [
            change pos add first pos 1
        ][
            insert tail words copy/deep reduce [word [1]]
        ]
    ]
    form sort/skip/compare/reverse words 2 2
]

print count-words to-file first system/options/args
