REBOL [ Title: "Count words" ]

count-words: func [source /local words word old-val][
    words: to-hash copy []
    foreach word parse lowercase read source to-string [#"^/" #"^-" #" "] [
        either old-val: select words word [
            change old-val add first old-val 1
        ][
            insert tail words copy/deep reduce [word [1]]
        ]
    ]
    form sort/skip/compare/reverse words 2 2
]

print count-words to-file first system/options/args
