--[[ Bootstrap Package Manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        -- latest stable release
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

--[[ Plugins ]]
require("lazy").setup({
    -- Colorscheme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "latte",
                --transparent_background = true,
                integrations = {
                    treesitter = true,
                    gitgutter = true,
                    ts_rainbow = true,
                    hop = true,
                    cmp = true,
                    telescope = true,
                    fidget = true,
                    notify = true,
                    indent_blankline = {
                        enabled = true,
                        colored_indent_levels = true,
                    },
                },
                dim_inactive = {
                    enabled = true,
                    percentage = 0.1,
                },
            })

            vim.cmd("colorscheme catppuccin")
        end,
    },

    -- Registers plugin
    {
        dir = "~/r/registers.nvim/",
        name = "registers",
        opts = {
            show = "+*\"-/_=#%.0123456789abcdefghijklmnopqrstuvwxyz:",
            system_clipboard = false,
        },
        keys = {
            { "\"", mode = { "n", "v" } },
            { "<C-R>", mode = "i" }
        },
        cmd = "Registers",
        init = function()
            vim.cmd("iabbrev regtest <C-R>=2*3<CR>")
        end,
    },

    -- Fuzzy find popup windows
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-telescope/telescope-ui-select.nvim",
            "nvim-lua/plenary.nvim",
        },
        config = function()
            -- Use telescope as the default neovim ui
            require("telescope").load_extension("ui-select")
        end,
        keys = {
            {
                "<C-p>",
                function()
                    if vim.fn.getcwd() == "~" or vim.fn.getcwd() == "/home/thomas" then
                        -- Show all files in home directory
                        require("telescope.builtin").find_files()
                    else
                        require("telescope.builtin").git_files()
                    end
                end,
                mode = { "n", "v", "i" },
                desc = "Git files or all files when in ~",
            },
            {
                "<C-l>",
                function()
                    require("telescope.builtin").diagnostics()
                end,
                mode = { "n", "v", "i" },
                desc = "Diagnostics list",
            },
        },
    },

    -- Pretty telescope
    {
        "stevearc/dressing.nvim",
        lazy = true,
        init = function()
            -- Only load when actually needed
            vim.ui.select = function(...)
                require("lazy").load({ plugins = { "dressing.nvim" } })

                return vim.ui.select(...)
            end
            vim.ui.input = function(...)
                require("lazy").load({ plugins = { "dressing.nvim" } })

                return vim.ui.input(...)
            end
        end,
    },

    -- Frequently visited files with <leader>f
    {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = {
            "telescope.nvim",
            "nvim-lua/plenary.nvim",
            "tami5/sqlite.lua",
        },
        config = function()
            require("telescope").load_extension("frecency")
        end,
        keys = {
            {
                "<leader>f",
                function()
                    require("telescope").extensions.frecency.frecency()
                end,
                desc = "Most used files"
            }
        }
    },

    -- Treesitter highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ':TSUpdate',
        dependencies = {
            -- Rainbow parentheses
            "p00f/nvim-ts-rainbow",
        },
        config = function()
            local treesitter = require "nvim-treesitter.configs"

            treesitter.setup({
                ensure_installed = {
                    "lua",
                    "rust",
                    "python",
                    "typescript",
                    "vue",
                    "toml",
                    "yaml",
                    "json",
                    "dockerfile",
                    "bash",
                    "vim",
                },
                -- Syntax highlighting
                highlight = {
                    enable = true,
                    extended_mode = true,
                },
                -- Rainbow parentheses
                rainbow = {
                    enable = true,
                },
            })
        end,
    },

    -- Dev icons, requires a nerd font
    "kyazdani42/nvim-web-devicons",

    -- Pretty notifications
    {
        "rcarriga/nvim-notify",
        config = function()
            vim.notify = require("notify")
        end,
    },

    -- LSP Config initial setup, we can't initialize the LSP servers here because Mason needs to be called in between
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Autocompletion
            "hrsh7th/cmp-nvim-lsp",
            "lsp_signature.nvim",
            "nvim-navic",
        },
        init = function()
            -- Format using LSP on save
            vim.api.nvim_create_autocmd({ "BufWritePre" }, {
                callback = function()
                    vim.lsp.buf.format()
                end,
            })
        end,
        config = function()
            -- Add LSP to autocompletion
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local on_attach = function(client, bufnr)
                if client.server_capabilities.documentSymbolProvider then
                    require("nvim-navic").attach(client, bufnr)
                end

                -- Show LSP signature hints while typing
                require("lsp_signature").on_attach(nil, bufnr)
            end

            local lsp = require "lspconfig"

            -- Setup Rust
            lsp.rust_analyzer.setup({
                cmd = { "rustup", "run", "nightly", "rust-analyzer" },
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    ["rust-analyzer"] = {
                        assist = {
                            -- Add #[must_use] when generating `_as` methods for enum variants
                            emitMustUse = true,
                        },
                        typing = {
                            -- Insert closing angle brackets when for generic argument lists
                            autoClosingAngleBrackets = { enable = true },
                        },
                    }
                }
            })

            -- Setup Vue without formatting
            lsp.volar.setup({
                init_options = {
                    documentFeatures = {
                        documentColor = true,
                        documentFormatting = false,
                    },
                },
                on_attach = on_attach,
                capabilities = capabilities,
                filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue",
                    "json" },
            })

            -- Setup Python
            lsp.pylsp.setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })

            -- Setup Lua
            local runtime_path = vim.split(package.path, ';')
            table.insert(runtime_path, "lua/?.lua")
            table.insert(runtime_path, "lua/?/init.lua")
            lsp.lua_ls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files
                            library = vim.api.nvim_get_runtime_file("", true),
                        },
                        telemetry = {
                            enable = false,
                        },
                        format = {
                            enable = true,
                            defaultConfig = {
                                indent_style = "tab",
                                indent_size = "1",
                            }
                        }
                    }
                }
            })

            -- Setup Bash
            lsp.bashls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })

            -- Setup YAML
            lsp.yamlls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })

            -- Setup TOML
            lsp.taplo.setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })

            -- Setup Markdown
            lsp.marksman.setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })

            -- Setup Docker
            lsp.dockerls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })
            lsp.docker_compose_language_service.setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })
        end,
    },

    -- Automatic installers
    {
        "williamboman/mason.nvim",
        dependencies = "neovim/nvim-lspconfig",
        config = true,
        cmd = { "Mason", "MasonInstall", "MasonUninstall" },
        opts = {
            ensure_installed = {
                "rust-analyzer",
                "lua-language-server",
                "vue-language-server",
                "python-lsp-server",
                "bash-language-server",
                "yaml-language-server",
                "docker-compose-language-service",
                "dockerfile-language-service",
                "taplo",
                "marksman",
                "eslint_d",
                "prettierd",
            }
        },
    },

    -- LSP signature hints while typing
    {
        "ray-x/lsp_signature.nvim",
        dependencies = "neovim/nvim-lspconfig",
        config = true,
        lazy = true,
    },

    -- Code context for statusline
    {
        "SmiteshP/nvim-navic",
        dependencies = "neovim/nvim-lspconfig",
        lazy = true,
    },

    -- LSP from tools
    {
        "jose-elias-alvarez/null-ls.nvim",
        dependencies = "neovim/nvim-lspconfig",
        config = function()
            local null_ls = require("null-ls")
            local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
            null_ls.setup({
                sources = {
                    null_ls.builtins.code_actions.eslint_d,
                    null_ls.builtins.diagnostics.eslint_d,
                    null_ls.builtins.formatting.prettierd,
                },
                -- Format on save
                on_attach = function(client, bufnr)
                    if client.supports_method("textDocument/formatting") then
                        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            group = augroup,
                            buffer = bufnr,
                            callback = function()
                                vim.lsp.buf.format({ bufnr = bufnr })
                            end,
                        })
                    end
                end,
            })

            -- Decrease timeout, prettier is slow
            vim.lsp.buf.format({ timeout_ms = 10000 })
        end,
        event = "BufReadPre",
    },

    -- LSP progress indicator
    {
        "j-hui/fidget.nvim",
        opts = {
            window = {
                blend = 0,
            }
        },
        event = "VeryLazy",
    },

    -- Show a lightbulb in the gutter when an action is available
    {
        "kosayoda/nvim-lightbulb",
        config = function()
            require("nvim-lightbulb").setup({
                float = {
                    enabled = ""
                }
            })

            vim.api.nvim_create_autocmd(
                { "CursorHold", "CursorHoldI" },
                {
                    callback = function()
                        require("nvim-lightbulb").update_lightbulb()
                    end
                })
        end,
        event = { "CursorHold", "CursorHoldI" },
    },

    -- Code action menu
    -- <leader>a
    {
        "weilbith/nvim-code-action-menu",
        cmd = "CodeActionMenu",
        keys = { { "<leader>a", "<cmd>CodeActionMenu<CR>", desc = "Code action menu" } }
    },

    -- Diagnostics using virtual lines
    {
        url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        config = function()
            require("lsp_lines").setup()

            -- Disable virtual text diagnostics since they are redundant
            vim.diagnostic.config({
                virtual_text = false
            })
        end,
        event = "VeryLazy",
    },

    -- LSP autocompletion with nvim-cmp
    {
        "hrsh7th/cmp-nvim-lsp",
        lazy = true,
    },

    -- Preview rename
    {
        "smjonas/inc-rename.nvim",
        config = true,
        keys = "<leader>r",
    },

    -- Quickfix
    {
        "kevinhwang91/nvim-bqf",
        ft = "qf",
    },

    -- Snippets
    {
        "L3MON4D3/LuaSnip",
        config = function()
            require("luasnip").config.set_config({
                -- Keep the last snippet around so we can jump back
                history = true,
                -- Update the snippet as we type
                updateevents = "TextChanged,TextChangedI",
            })

            -- Setup snippet loader
            require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })
        end,
        event = "VeryLazy",
    },

    -- Git sidebar
    {
        "lewis6991/gitsigns.nvim",
        config = true,
        event = "VeryLazy",
    },

    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-cmdline",
            "lukas-reineke/cmp-rg",
            -- Snippets
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require "cmp"

            -- The icons
            local kind_icons = {
                Text = "",
                Method = "",
                Function = "",
                Constructor = "",
                Field = "",
                Variable = "",
                Class = "ﴯ",
                Interface = "",
                Module = "",
                Property = "ﰠ",
                Unit = "",
                Value = "",
                Enum = "",
                Keyword = "",
                Snippet = "",
                Color = "",
                File = "",
                Reference = "",
                Folder = "",
                EnumMember = "",
                Constant = "",
                Struct = "",
                Event = "",
                Operator = "",
                TypeParameter = ""
            }

            -- Enable different autocompletion targets
            cmp.setup({
                enabled = true,
                experimental = {
                    ghost_text = true,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "rg" },
                    { name = "nvim_lua" },
                    { name = "path" },
                    { name = "luasnip" },
                    { name = "git" },
                }, {
                    { name = "buffer", keyword_length = 3 },
                }),
                mapping = cmp.mapping.preset.insert({
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.close(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    -- Show the icons
                    format = function(_, vim_item)
                        vim_item.menu = (" (%s)"):format(vim_item.kind)
                        vim_item.kind = ("%s "):format(kind_icons[vim_item.kind])

                        return vim_item
                    end,
                },
            })

            -- Autocompletion in / search
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "buffer" },
                }
            })

            -- Autocompletion in : command
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "path" },
                }, {
                    { name = "cmdline" },
                })
            })

            -- Disable when inside telescope
            vim.api.nvim_create_autocmd(
                { "FileType" },
                {
                    pattern = "TelescopePrompt",
                    callback = function()
                        cmp.setup.buffer({ enabled = false })
                    end
                })

            -- Better completion experience
            -- menuone: Popup even when there's only one match, do not insert text until a selection is
            -- noinstert: Do not insert text until a selection is made
            -- noselect: Do not auto-select, nvim-cmp will do this
            vim.o.completeopt = "menuone,noinsert,noselect"
        end,
        event = "VeryLazy",
    },

    -- Git autocompletion
    {
        "petertriho/cmp-git",
        config = function()
            require("cmp_git").setup()

            -- Add to nvim-cmp
            require("cmp").setup.buffer({ sources = { { name = "git" } } })
        end,
        ft = { "gitcommit", "octo" },
    },

    -- Number increase/decrease
    {
        "monaqa/dial.nvim",
        config = function()
            local augend = require("dial.augend")
            require("dial.config").augends:register_group({
                default = {
                    augend.integer.alias.decimal,
                    augend.integer.alias.hex,
                    augend.hexcolor.new({
                        case = "upper",
                    }),
                    augend.semver.alias.semver,
                    augend.date.alias["%Y/%m/%d"],
                },
            })
        end,
        keys = { 
            {
                "<C-a>", 
                require("dial.map").inc_normal(),
                mode = { "n" },
                desc = "Increase next item under cursor or available",
            },
            {
                "<C-a>", 
                require("dial.map").inc_visual(),
                mode = { "v" },
                desc = "Increase next item under cursor or available",
            },
            {
                "<C-x>", 
                require("dial.map").dec_normal(),
                mode = { "n" },
                desc = "Decrease next item under cursor or available",
            },
            {
                "<C-x>", 
                require("dial.map").dec_visual(),
                mode = { "v" },
                desc = "Decrease next item under cursor or available",
            },
        },
    },

    -- Define and show keybindings
    {
        "mrjones2014/legendary.nvim",
        init = function()
            -- Set the leader key to space
            vim.g.mapleader = " "
            vim.g.maplocalleader = " "
        end,
        config = function()
            local helpers = require('legendary.toolbox')

            local keymaps = {
                -- Splits
                {
                    "<a-h>",
                    "<c-w>h",
                    mode = { "n", "i", "v" },
                    description = "Move to left split"
                },
                {
                    "<a-l>",
                    "<c-w>l",
                    mode = { "n", "i", "v" },
                    description = "Move to right split"
                },
                {
                    "<a-j>",
                    "<c-w>j",
                    mode = { "n", "i", "v" },
                    description = "Move to bottom split"
                },
                {
                    "<a-k>",
                    "<c-w>k",
                    mode = { "n", "i", "v" },
                    description = "Move to top split"
                },
                {
                    "b",
                    "<nop>",
                    description = "Unlearn key in favor of F/T"
                },
                {
                    "w",
                    "<nop>",
                    description = "Unlearn key in favor of f/t"
                },
                {
                    "h",
                    "<nop>",
                    description = "Unlearn key in favor of F/T"
                },
                {
                    "l",
                    "<nop>",
                    description = "Unlearn key in favor of f/t"
                },
                {
                    "k",
                    "<nop>",
                    description = "Unlearn key in favor of <leader>l"
                },
                {
                    "j",
                    "<nop>",
                    description = "Unlearn key in favor of <leader>l"
                },

                -- Menus
                {
                    "<leader><cr>",
                    helpers.lazy_required_fn("legendary", "find", "keymaps"),
                    description = "This menu"
                },

                -- Custom scripts
                {
                    "<leader><leader>n",
                    "<cmd>vsplit /tmp/nvim-tmp-buf.lua<CR>",
                    description = "Open or create a temporary Lua file that we can execute on a buffer with <leader><leader>l"
                },
                {
                    "<leader><leader>e",
                    "<cmd>luafile /tmp/nvim-tmp-buf.lua<CR>",
                    description = "Execute tmp Lua buffer"
                },
                {
                    "<leader><leader>c",
                    function()
                        local last_command = vim.api.nvim_call_function("getreg", { ":", 1 })

                        local file = io.open("/tmp/nvim-tmp-buf.lua", "a")
                        if file then
                            file:write(("vim.api.nvim_command([[%s]])\n"):format(
                                last_command))
                        else
                            error(
                                "Could not open file /tmp/nvim-tmp-buf.lua, please create it first with <leader><leader>c")
                        end
                        io.close(file)

                        vim.api.nvim_command("checktime")
                    end,
                    description = "Append the last executed command to the temporary neovim buffer file"
                },

                -- Neovim dotfiles
                {
                    "<leader>x",
                    "<cmd>source ~/.config/nvim/init.lua<CR>",
                    description = "Reload configuration"
                },

                -- LSP
                { "K", vim.lsp.buf.hover, description = "LSP hover" },
                { "ga", vim.lsp.buf.code_action, description = "LSP code action" },
                { "gd", vim.lsp.buf.declaration, description = "LSP declaration" },
                {
                    "gD",
                    vim.lsp.buf.implementation,
                    description = "LSP implementation"
                },
                { "gr", vim.lsp.buf.references, description = "LSP references" },
                {
                    "<c-k>",
                    vim.lsp.buf.signature_help,
                    description = "LSP signature help"
                },
                {
                    "<leader>d",
                    vim.lsp.buf.type_definition,
                    description = "LSP type definition"
                },
                {
                    "<leader>wa",
                    vim.lsp.buf.add_workspace_folder,
                    description = "LSP add workspace folder"
                },
                {
                    "<leader>wr",
                    vim.lsp.buf.remove_workspace_folder,
                    description = "LSP remove workspace folder"
                },
                {
                    "<leader>r",
                    ":IncRename ",
                    description = "LSP rename"
                },

                -- Rust
                --{ "J", helpers.lazy_required_fn("rust-tools.join_lines", "join_lines"), description = "Join lines" },
                {
                    "<leader>rc",
                    helpers.lazy_required_fn("rust-tools.open_cargo_toml", "open_cargo_toml"),
                    description = "Open Cargo.toml"
                },
                {
                    "<leader>p",
                    helpers.lazy_required_fn("rust-tools.parent_module", "parent_module"),
                    description = "Open parent module"
                },
                {
                    "<leader>e",
                    helpers.lazy_required_fn("rust-tools.expand_macro", "expand_macro"),
                    description = "Expand macro"
                },
                {
                    "<leader>t",
                    helpers.lazy_required_fn("rust-tools.runnables", "runnables"),
                    description = "Rust runnables"
                },
                {
                    "<leader>g",
                    helpers.lazy_required_fn("rust-tools.crate_graph", "view_crate_graph"),
                    description = "View crate graph"
                },

                -- Treesitter
                {
                    "<leader>j",
                    helpers.lazy_required_fn("trevj", "format_at_cursor"),
                    description = "TS Split lines"
                },

                -- Snippets
                {
                    "<c-k>",
                    function()
                        local ls = require("luasnip")

                        if ls.expand_or_jumpable() then
                            ls.expand_or_jump()
                        end
                    end,
                    mode = { "s", "i" },
                    description = "Expand current snippet or jump to the next item within it",
                },
                {
                    "<c-j>",
                    function()
                        local ls = require("luasnip")

                        if ls.jumpable(-1) then
                            ls.jump(-1)
                        end
                    end,
                    mode = { "s", "i" },
                    description = "Move to the previous item within the snippet",
                },
                {
                    "<c-l>",
                    function()
                        local ls = require("luasnip")

                        if ls.choice_active() then
                            ls.change_choice(1)
                        end
                    end,
                    mode = { "s", "i" },
                    description = "Select within the snippet's list of options",
                },
                {
                    "<c-s>",
                    helpers.lazy_required_fn("luasnip.extras", "select_choice"),
                    mode = { "s", "i" },
                    description = "Visually select a snippet choice"
                },
                {
                    "<leader><leader>s",
                    helpers.lazy_required_fn("luasnip.loaders.from_lua", "load",
                        { paths = "~/.config/nvim/snippets/" }),
                    description = "Load snippets"
                },
                {
                    "<leader><leader>r",
                    helpers.lazy_required_fn("luasnip.loaders.from_lua", "edit_snippet_files"),
                    description = "Edit snippets"
                },

                -- Hop
                {
                    "f",
                    {
                        n = {
                            helpers.lazy_required_fn("hop", "hint_char1", {
                                current_line_only = true,
                                case_insensitive = false,
                            }),
                        },
                        o = {
                            helpers.lazy_required_fn("hop", "hint_char1", {
                                current_line_only = true,
                                inclusive_jump = true,
                                case_insensitive = false,
                            }),
                        },
                    },
                    description = "Jump before character after cursor in line",
                },
                {
                    "F",
                    helpers.lazy_required_fn("hop", "hint_char1", {
                        current_line_only = false,
                        case_insensitive = false,
                    }),
                    mode = { "n", "o" },
                    description = "Jump before character in whole view",
                },
                {
                    "t",
                    helpers.lazy_required_fn("hop", "hint_char1",
                        {
                            direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                            current_line_only = true,
                            hint_offset = -1
                        }),
                    mode = { "n", "o" },
                    description = "Jump to character after cursor in line",
                },
                {
                    "T",
                    helpers.lazy_required_fn("hop", "hint_char1",
                        {
                            direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                            current_line_only = true,
                            hint_offset = 1
                        }),
                    mode = { "n", "o" },
                    description = "Jump before character in whole view",
                },
                {
                    "ge",
                    helpers.lazy_required_fn("hop", "hint_words"),
                    mode = { "n", "o", "v" },
                    description = "Jump to word on page",
                },
                {
                    "gl",
                    helpers.lazy_required_fn("hop", "hint_lines_skip_whitespace"),
                    mode = { "n", "o", "v" },
                    description = "Jump to word on page",
                },
                {
                    "g/",
                    helpers.lazy_required_fn("hop", "hint_patterns"),
                    mode = { "n", "o", "v" },
                    description = "/ but with matches to jump to",
                },

                -- Clipboard
                {
                    "<leader>c",
                    helpers.lazy_required_fn("osc52", "copy_operator"),
                    mode = { "n", "o" },
                    description = "Copy to terminal using OSC52 standard"
                },
            }

            -- Quickly access different register modes for testing
            --[[
			for key, mode in pairs({ i = "insert", w = "paste", m = "motion" }) do
				keymaps[#keymaps + 1] = {
					"<C-" .. key .. ">",
					helpers.lazy_required_fn("registers", "show", mode),
					mode = { "n", "v", "i" },
					description = "Registers test function " .. mode,
				}
			end
			]]
            require("legendary").setup({
                keymaps = keymaps,
                most_recent_item_at_top = true,
                which_key = nil,
            })
        end,
    },

    -- Show indentation lines
    {
        "lukas-reineke/indent-blankline.nvim",
        init = function()
            vim.opt.list = true
            vim.opt.listchars:append("space:⋅")
            vim.opt.listchars:append("eol:↴")
        end,
        opts = {
            space_char_blankline = " ",
            show_trailing_blankline_indent = true,
            show_current_context = true,
            show_current_context_start = true,
            context_patterns = {
                "class", "function", "method", "block", "list_literal", "selector",
                "^if", "^table", "if_statement", "while", "for"
            },
        },
        event = "BufReadPre",
    },

    -- Unlearn bad patterns
    {
        "ja-ford/delaytrain.nvim",
        event = "VeryLazy",
    },

    -- Quick jump
    {
        "phaazon/hop.nvim",
        opts = { keys = "uhetonaspg.c,rkmjwv" },
        lazy = true,
    },

    -- Clipboard manager using OSC52
    {
        "ojroques/nvim-osc52",
        config = true,
        keys = "<leader>c",
    },

    -- Sudo, :SudaWrite
    {
        "lambdalisue/suda.vim",
        cmd = "SudaWrite"
    },

    -- Create a beautiful screenshot of the code
    {
        "krivahtoo/silicon.nvim",
        run = "./install.sh build",
        opts = {
            font = "FiraCode Nerd Font=20",
            output = {
                path = "/home/thomas/Pictures/Screenshot",
            },
        },
        cmd = "Silicon",
    },

    -- Switch between relative and absolute numbers
    {
        "jeffkreeftmeijer/vim-numbertoggle",
        event = "VeryLazy",
    },

    -- Show and remove extra whitespace
    {
        "ntpeters/vim-better-whitespace",
        config = function()
            -- Strip all whitespace on save, disable with :DisableStripWhitespaceOnSave
            vim.g.strip_whitespace_on_save = 1
        end,
        event = "VeryLazy",
    },

    -- Highlight TODO comments
    {
        "folke/todo-comments.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = true,
        event = "VeryLazy",
    },

    -- Crates
    {
        "saecki/crates.nvim",
        config = function()
            require("crates").setup()

            -- Add to nvim-cmp
            require("cmp").setup.buffer({ sources = { { name = "crates" } } })
        end,
        event = "BufEnter Cargo.toml",
    },

    -- Opposite of J
    {
        "AckslD/nvim-trevJ.lua",
        config = true,
        keys = "<leader>j",
    },

    -- TOML
    {
        "cespare/vim-toml",
        ft = "toml",
    },

    -- package.json updates
    {
        "vuki656/package-info.nvim",
        dependencies = "MunifTanjim/nui.nvim",
        opts = {
            hide_up_to_date = true,
        },
        ft = "json",
    },

    -- Keep track of the time spent programming with wakatime
    {
        "wakatime/vim-wakatime",
        event = "VeryLazy",
    },

    -- WGSL highlighting
    {
        "DingDean/wgsl.vim",
        event = "BufEnter *.wgsl",
    },

    -- KDL highlighting
    {
        "imsnif/kdl.vim",
        event = "BufEnter *.kdl",
    },
}, {
    ui = {
        border = "single",
    },
    checker = {
        enabled = true,
        concurrency = 1,
    },
})

--[[ Global Options ]]
do
    -- Always use UTF-8
    vim.o.encoding = "utf-8"

    -- Automatically reload files changed outside of vim
    vim.o.autoread = true

    -- Where to store the undo files
    vim.o.undodir = "/home/thomas/.config/nvim/undo"

    -- Show live preview of substitutions
    vim.o.inccommand = "split"

    -- Enable terminal gui colors
    vim.o.termguicolors = true

    -- Disable mouse
    vim.cmd("set mouse=")
end

--[[ Window Options ]]
do
    -- Display the line numbers sidebar
    vim.wo.number = true
    vim.wo.relativenumber = true

    -- Highlight the current line
    vim.wo.cursorline = true
    vim.wo.cursorcolumn = true

    -- Automatically hide some symbols (mainly markdown)
    vim.wo.conceallevel = 2
end

--[[ Buffer Options ]]
do
    -- Save undo across all sessions
    vim.bo.undofile = true

    -- Don't use swap files
    vim.bo.swapfile = false
end

--[[ Auto Commands ]]
do
    -- Create an autocommand group
    -- TODO: replace with https://github.com/neovim/neovim/pull/12378
    local function create_augroup(autocmds, name)
        vim.cmd("augroup " .. name)
        vim.cmd("autocmd!")
        for _, autocmd in ipairs(autocmds) do
            vim.cmd("autocmd " .. autocmd)
        end
        vim.cmd("augroup END")
    end

    -- Save the position of screen at exit
    create_augroup({
        "BufWinLeave *.* mkview",
        "BufWinEnter *.* silent loadview",
    }, "position")

    -- Lua indentation
    create_augroup({
        "FileType lua setlocal tabstop=4 shiftwidth=4 expandtab autoindent",
    }, "lua")

    -- YAML indentation
    create_augroup({
        "FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab",
        "FileType yml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab",
    }, "yaml")

    -- Type- & JavaScript indentation
    create_augroup({
        "FileType vue setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab",
        "FileType typescript setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab",
        "FileType javascript setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab",
    }, "vue")

    -- Python indentation
    create_augroup({
        "FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4 textwidth=79 expandtab autoindent fileformat=unix"
    }, "python")

    -- Highlight yanked regions
    create_augroup({
        "TextYankPost * silent! lua require'vim.highlight'.on_yank()"
    }, "highlight")

    -- Delphi indentation
    create_augroup({
        "FileType delphi setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab autoindent fileformat=unix foldmethod=indent"
    }, "delphi")
end

--[[ Key Maps ]]
do
    -- Move across wrapped lines like regular lines
    -- Go to the first non-blank character of a line
    vim.api.nvim_set_keymap("n", "0", "^", { noremap = true })
    -- Just in case you need to go to the very beginning of a line
    vim.api.nvim_set_keymap("n", "^", "0", { noremap = true })
end

--[[ Status Line ]]
do
    -- Wrap a status line section in a nice looking field
    local function section(text, opts)
        opts = opts or {}

        if not text or text == "" then
            return ""
        end

        return ("%%#%s#%s%%#Normal# "):format(opts.color or "StatusLine", text)
    end

    -- Icon for the mode
    local function mode()
        local current_mode = vim.api.nvim_get_mode().mode

        local modes = {
            ["n"] = nil,
            ["no"] = nil,
            ["v"] = "",
            ["V"] = " ",
            [""] = " ",
            ["s"] = "麗",
            ["S"] = " ",
            ["^s"] = "礪",
            ["i"] = "﫦",
            ["ic"] = "﫦",
            ["R"] = "屢",
            ["Rv"] = "﯒",
            ["c"] = " ",
            ["cv"] = "",
            ["ce"] = "",
            ["r"] = " ",
            ["rm"] = "ﱟ ",
            ["r?"] = " ",
            ["!"] = " ",
            ["t"] = " ",
        }

        return modes[current_mode]
    end

    -- Pretty full file path
    -- TODO: fix
    local function filepath()
        -- local fname = vim.fn.expand("%:t")

        -- -- :~ reduces relative to home directory
        -- -- :. reduces relative to the current directory
        -- -- :h reduces relative to the head
        -- local fpath = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.:h")
        -- if fpath == "" or fpath == "." then
        --     return fname
        -- end

        -- return ("%%<%s/%s"):format(fpath, fname)
        return "%f"
    end

    -- Modified status
    local function modified()
        return "%m"
    end

    -- Modified status
    local function file_type()
        return "%y"
    end

    -- LSP information
    local function lsp_status(symbol, severity)
        local count = vim.tbl_count(vim.diagnostic.get(0, { severity = severity }))
        if count == 0 then
            return
        end

        return symbol .. " " .. count
    end

    -- LSP signature
    local function lsp_signature()
        if not pcall(require, "lsp_signature") then
            return
        end

        local sig = require("lsp_signature").status_line()

        return sig.hint
    end

    -- Lsp path
    local function lsp_path()
        return "%{%v:lua.require('nvim-navic').get_location()%}"
    end

    -- Git information
    local function git_status()
        return "%{get(b:,'gitsigns_status','')}"
    end

    -- Git information
    local function git_head()
        return "%{get(b:,'gitsigns_head','')}"
    end

    -- Compose and draw the statusline
    function StatusLine()
        return table.concat({
            section(mode()),
            section(filepath()),
            section(modified()),
            "%=",
            section(git_head()),
            section(git_status()),
            "%=",
            section(lsp_path()),
            section(lsp_signature()),
            section(lsp_status("", vim.diagnostic.severity.ERROR)),
            section(lsp_status("", vim.diagnostic.severity.WARN)),
            section(lsp_status("", vim.diagnostic.severity.HINT)),
            section(lsp_status("", vim.diagnostic.severity.INFO)),
            section(file_type()),
        })
    end

    vim.o.statusline = "%!luaeval('StatusLine()')"
end