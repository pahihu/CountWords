REBOL [
    Title: "Count words"
    File: %count.r
    Author: "pahihu"
    Date: 29-Apr-2021
    Version: 1.0
]

separators: to-string [#"^/" #"^-" #" "]

count-words: func [source /local words word old-val][
    words: to-hash copy []
    foreach word parse lowercase read source separators [
        either old-val: select words word [
            change old-val add first old-val 1
        ][
            insert tail words copy/deep reduce [word [1]]
        ]
    ]
    write %rebol.result form sort/skip/compare/reverse words 2 2
]

bench: func [source /local t1 t2][
    recycle
    t1: now/precise
    count-words source
    t2: now/precise
    print ["Elapsed time" difference t2 t1]
]

bench %kjvbible_x10.txt
quit
