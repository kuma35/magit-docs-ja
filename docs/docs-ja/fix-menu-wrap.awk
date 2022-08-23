# insert new-line
/@documentencoding/ && /@documentlanguage/ {
    print $1,$2
    print $3,$4
    next
}


/^\*[^:]+:[^:]+$/ {
    LAST_LINE = $0
    next
}

LAST_LINE != ""  && /^[^*@]/ {
    # 現在行が *,@ で始まってなくて、前行が * で始まっている時は前行と現在行を連結して出力
    print LAST_LINE " " $0
    LAST_LINE = ""
    next
}

LAST_LINE != ""  && /^@/ {
    # 現在行が @ で始まって、前行が * で始まっている時は前行と現在行を出力
    print LAST_LINE
    print
    LAST_LINE = ""
    next
}

LAST_LINE != "" {
    LAST_LINE = ""
}

{
    print
}
