return {
    -- Builder method
    s("builder_method", fmt([[
    /// {}.
    fn (self, {}) -> Self {{
        {}

        self
    }}
    ]], {
        i(2),
        i(1),
        i(0),
    })),

    -- Rust function
    s("fn", fmt([[
    /// {}.
    fn {}({}) -> {} {{
        {}
    }}
    ]], {
        i(4),
        i(1),
        i(2),
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
        i(0),
    }))
}

