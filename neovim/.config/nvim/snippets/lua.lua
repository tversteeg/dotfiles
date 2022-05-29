return {
    s("req", fmt("local {} = require(\"{}\")", {
        dl(2, l._1:match("%.([%w_]+)$"), { 1 }),
        i(1)
    })),

    s("use", fmt([[
    -- {comment}
    use {{
        "{author}/{repo}",
        config = function()
            require("{require}").setup({{
                {setup}
            }})
        end,
    }}
    ]], {
        author = i(1),
        repo = i(2),
        comment = i(3),
        require = i(4),
        setup = i(0),
    })),

    s("snippet", fmt([=[
    s("{title}", fmt([[
        {format_string}
    ]], {{
        i(0),
    }})),
    ]=], {
        title = i(1),
        format_string = i(0),
    })),

    s("keymap_lazy_required_fn", fmt([[
        {{ "{key}", helpers.lazy_required_fn({require}, {call}), description = {description} }},
        {next}
    ]], {
        key = i(1),
        require = i(2),
        call = i(3),
        description = i(4),
        next = i(0),
    })),
}
