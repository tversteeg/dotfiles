return {
    -- Builder method
    s("builder_method", {
        t "/// ",
        i(3),
        t({ ".", "fn " }),
        i(1),
        t "(self, ",
        i(2),
        t({ ") -> Self {", "\t" }),
        i(0),
        t({ "", "}" }),
    }),
    -- Rust function
    s("fn", {
        t "/// ",
        i(4),
        t({ ".", "fn " }),
        i(1),
        t "(",
        i(2),
        t ") ",
        c(3, {
            t "Result<()> ",
            sn(nil, { t "Result<", i(1), t "> " }),
            sn(nil, { t "Option<", i(1), t "> " }),
            t "String ",
            t "'static str ",
            t "bool ",
            t "f32 ",
            t "f64 ",
        }),
        t({ "{", "\t" }),
        i(0),
        t({ "", "}" }),
    })
}
