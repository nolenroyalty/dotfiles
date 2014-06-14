# I almost always want files that *contain* something, not necessarily match it exactly
fff () {
    find ${2-.} -iname "*$1*"
}

