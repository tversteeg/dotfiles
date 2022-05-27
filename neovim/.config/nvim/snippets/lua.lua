return {
    s("req", fmt("local {} = require(\"{}\")", {
        dl(2, l._1:match("%.([%w_]+)$"), { 1 }),
        i(1)
    }))
}
