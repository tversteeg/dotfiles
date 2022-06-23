return {
    s("computed", fmt([[
    const {name} = computed(() => {{
        {body}
    }});
    ]], {
        name = i(1),
        body = i(0),
    })),

    s("dialog_error", fmt([[
    try {{
        {body}
    }} catch (error) {{
        $q.dialog({{
          title: 'Error',
          message: (error as Error).message,
          ok: {{
            label: 'Ok',
          }},
        }});
    }}
    ]], {
        body = i(0),
    })),
}
