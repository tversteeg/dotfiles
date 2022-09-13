--[[ Bootstrap Package Manager ]]
local packer_bootstrap
do
    -- Clone the git repository if not found
    local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
        -- Clone the package manager repository
        packer_bootstrap = vim.fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
            install_path })
    end

    -- Initialize the package manager
    vim.cmd("packadd packer.nvim")

    -- Autocompile when this file is saved
    vim.cmd([[
    augroup packer_user_config
    autocmd!
    autocmd BufWritePost init.lua source <afile> | PackerCompile
    augroup end
    ]])
end

--[[ Plugins ]]
require("packer").startup({ function(use)
    -- The package manager itself
    use "wbthomason/packer.nvim"

    -- Registers plugin
    use {
        "~/r/registers.nvim",
        config = function()
            require("registers").setup({})
        end
    }

    -- Fuzzy find popup windows
    use {
        "nvim-telescope/telescope.nvim",
        requires = {
            { "nvim-telescope/telescope-ui-select.nvim" },
            { "nvim-lua/plenary.nvim" },
            { "stevearc/dressing.nvim" },
        },
        config = function()
            -- Use telescope as the default neovim ui
            require("telescope").load_extension("ui-select")

            require("dressing").setup({})
        end,
    }

    -- Frequently visited files with <leader>f
    use {
        "nvim-telescope/telescope-frecency.nvim",
        requires = {
            { "nvim-lua/plenary.nvim" },
            { "tami5/sqlite.lua" },
        },
        config = function()
            require("telescope").load_extension("frecency")
        end,
    }

    -- Treesitter highlighting
    use {
        "nvim-treesitter/nvim-treesitter",
        run = ':TSUpdate',
        requires = {
            -- Rainbow parentheses
            { "p00f/nvim-ts-rainbow" },
        },
        config = function()
            local treesitter = require "nvim-treesitter.configs"

            treesitter.setup({
                ensure_installed = { "lua", "rust", "typescript", "python", "vue", "toml", "vim", "yaml", "json",
                    "dockerfile", "bash" },
                -- Syntax highlighting
                highlight = {
                    enable = true,
                    extended_mode = true,
                },
                -- Rainbow parentheses
                rainbow = {
                    enable = true,
                },
                -- Key bindings
                keymaps = {
                    -- Incremental selection based on the named nodes
                    init_selection = "gnn",
                    node_incremental = "grn",
                    scope_incremental = "grc",
                    node_decremental = "grm",
                },
            })
        end,
    }

    -- Colorscheme
    use {
        "catppuccin/nvim",
        config = function()
            require("catppuccin").setup({
                transparent_background = true,
                integrations = {
                    gitgutter = true,
                    ts_rainbow = true,
                    hop = true,
                    indent_blankline = {
                        enabled = true,
                        -- colored_indent_levels = true,
                    },
                },
            })

            vim.g.catppuccin_flavour = "latte"
            vim.cmd("colorscheme catppuccin")
        end,
    }

    -- Dev icons, requires a nerd font
    use "kyazdani42/nvim-web-devicons"

    -- Desktop notifications
    use {
        "simrat39/desktop-notify.nvim",
        requires = {
            { "nvim-lua/plenary.nvim" },
        },
        config = function()
            require("desktop-notify").override_vim_notify()
        end,
    }

    -- Language server
    do
        use {
            "neovim/nvim-lspconfig",
            requires = {
                -- Auto completions
                { "hrsh7th/cmp-nvim-lsp" },
                -- Install language servers
                { "williamboman/nvim-lsp-installer" },
                -- Signature hints while typing
                { "ray-x/lsp_signature.nvim" },
                -- Prettier
                { "jose-elias-alvarez/null-ls.nvim" },
            },
            config = function()
                local lsp = require "lspconfig"

                -- Setup LSP installer
                require("nvim-lsp-installer").setup({})
                -- Setup LSP signature hints
                require("lsp_signature").setup({})

                -- Add LSP to autocompletion
                local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

                local on_attach = function()
                    -- Show LSP signature hints while typing
                    require("lsp_signature").on_attach()
                end

                -- Setup Rust
                lsp.rust_analyzer.setup({
                    on_attach = on_attach,
                    capabilities = capabilities,
                    ["rust-analyzer"] = {
                        assist = {
                            importMergeBehavior = "last",
                            importPrefix = "by_self",
                        },
                        cargo = {
                            loadOutDirsFromCheck = true,
                        },
                        procMacro = {
                            enable = true,
                        },
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
                    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
                })

                -- Use prettier for formatting
                local null_ls = require("null-ls")
                null_ls.setup({
                    sources = {
                        null_ls.builtins.formatting.prettier
                    },
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
                lsp.sumneko_lua.setup({
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

                -- Format using LSP on save
                vim.api.nvim_create_autocmd({ "BufWritePre" }, {
                    callback = function()
                        vim.lsp.buf.format()
                    end,
                })
            end,
        }

        -- LSP progress indicator
        use {
            "j-hui/fidget.nvim",
            config = function()
                require("fidget").setup()
            end,
        }

        -- Show a lightbulb in the gutter when an action is available
        use {
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
            end
        }

        -- Code action menu
        -- <leader>a
        use "weilbith/nvim-code-action-menu"

        -- Diagnostics using virtual lines
        use {
            "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
            config = function()
                require("lsp_lines").setup()

                -- Disable virtual text diagnostics since they are redundant
                vim.diagnostic.config({
                    virtual_text = false
                })
            end,
        }

        -- Preview rename
        use {
            "smjonas/inc-rename.nvim",
            config = function()
                require("inc_rename").setup({})
            end,
        }
    end

    -- Snippets
    use {
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
    }

    -- Git sidebar
    use {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({})
        end,
    }

    -- Autocompletion
    use {
        "hrsh7th/nvim-cmp",
        requires = {
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "hrsh7th/cmp-nvim-lua" },
            { "hrsh7th/cmp-cmdline" },
            { "saecki/crates.nvim" },
            { "lukas-reineke/cmp-rg" },
            -- Snippets
            { "L3MON4D3/LuaSnip" },
            { "saadparwaiz1/cmp_luasnip" },
            -- Git
            { "petertriho/cmp-git" },
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
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "rg" },
                    { name = "nvim_lua" },
                    { name = "path" },
                    { name = "crates" },
                    { name = "luasnip" },
                    { name = "git" },
                }, {
                    { name = "buffer", keyword_length = 3 },
                }),
                mapping = cmp.mapping.preset.insert({
                    --["<c-space>"] = cmp.mapping.complete(),
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
            cmp.setup.cmdline("/", {
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

            require("cmp_git").setup()

            -- Disable when inside telescope
            vim.api.nvim_create_autocmd(
                { "FileType" },
                {
                    pattern = "TelescopePrompt",
                    callback = function()
                        cmp.setup.buffer({ enabled = false })
                    end
                })
        end,
    }

    -- Number increase/decrease
    use {
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
                    augend.semver,
                    augend.date.alias["%Y/%m/%d"],
                },
            })
        end,
    }

    -- Define and show keybindings
    use {
        "mrjones2014/legendary.nvim",
        config = function()
            local helpers = require('legendary.helpers')

            local keymaps = {
                -- Splits
                { "<a-h>", "<c-w>h", mode = { "n", "i", "v" }, description = "Move to left split" },
                { "<a-l>", "<c-w>l", mode = { "n", "i", "v" }, description = "Move to right split" },
                { "<a-j>", "<c-w>j", mode = { "n", "i", "v" }, description = "Move to bottom split" },
                { "<a-k>", "<c-w>k", mode = { "n", "i", "v" }, description = "Move to top split" },
                { "b", "<nop>", description = "Unlearn key in favor of F/T" },
                { "w", "<nop>", description = "Unlearn key in favor of f/t" },
                { "h", "<nop>", description = "Unlearn key in favor of F/T" },
                { "l", "<nop>", description = "Unlearn key in favor of f/t" },
                { "k", "<nop>", description = "Unlearn key in favor of <leader>l" },
                { "j", "<nop>", description = "Unlearn key in favor of <leader>l" },

                -- Menus
                { "<leader><cr>", helpers.lazy_required_fn("legendary", "find", "keymaps"), description = "This menu" },
                { "<leader>a", "<cmd>CodeActionMenu<CR>", description = "Code action menu" },
                { "<leader>f", require("telescope").extensions.frecency.frecency, description = "Most used files" },
                { "<c-p>", function()
                    if vim.fn.getcwd() == "~" or vim.fn.getcwd() == "/home/thomas" then
                        -- Show all files in home directory
                        require("telescope.builtin").find_files()
                    else
                        require("telescope.builtin").git_files()
                    end
                end, description = "Git files", mode = { "n", "v", "i" } },

                -- Custom scripts
                { "<leader><leader>n", "<cmd>vsplit /tmp/nvim-tmp-buf.lua<CR>",
                    description = "Open or create a temporary Lua file that we can execute on a buffer with <leader><leader>l" },
                { "<leader><leader>e", "<cmd>luafile /tmp/nvim-tmp-buf.lua<CR>", description = "Execute tmp Lua buffer" },
                { "<leader><leader>c", function()
                    local last_command = vim.api.nvim_call_function("getreg", { ":", 1 })

                    local file = io.open("/tmp/nvim-tmp-buf.lua", "a")
                    if file then
                        file:write(("vim.api.nvim_command([[%s]])\n"):format(last_command))
                    else
                        error("Could not open file /tmp/nvim-tmp-buf.lua, please create it first with <leader><leader>c")
                    end
                    io.close(file)

                    vim.api.nvim_command("checktime")
                end, description = "Append the last executed command to the temporary neovim buffer file" },

                -- Neovim dotfiles
                { "<leader>x", "<cmd>source ~/.config/nvim/init.lua<CR>", description = "Reload configuration" },

                -- LSP
                { "K", vim.lsp.buf.hover, description = "LSP hover" },
                { "ga", vim.lsp.buf.code_action, description = "LSP code action" },
                { "gd", vim.lsp.buf.declaration, description = "LSP declaration" },
                { "gD", vim.lsp.buf.implementation, description = "LSP implementation" },
                { "gr", vim.lsp.buf.references, description = "LSP references" },
                { "<c-k>", vim.lsp.buf.signature_help, description = "LSP signature help" },
                { "<leader>d", vim.lsp.buf.type_definition, description = "LSP type definition" },
                { "<leader>wa", vim.lsp.buf.add_workspace_folder, description = "LSP add workspace folder" },
                { "<leader>wr", vim.lsp.buf.remove_workspace_folder, description = "LSP remove workspace folder" },
                { "<leader>r", ":IncRename ", description = "LSP rename" },

                -- Rust
                --{ "J", helpers.lazy_required_fn("rust-tools.join_lines", "join_lines"), description = "Join lines" },
                { "<leader>c", helpers.lazy_required_fn("rust-tools.open_cargo_toml", "open_cargo_toml"),
                    description = "Open Cargo.toml" },
                { "<leader>p", helpers.lazy_required_fn("rust-tools.parent_module", "parent_module"),
                    description = "Open parent module" },
                { "<leader>e", helpers.lazy_required_fn("rust-tools.expand_macro", "expand_macro"),
                    description = "Expand macro" },
                { "<leader>t", helpers.lazy_required_fn("rust-tools.runnables", "runnables"),
                    description = "Rust runnables" },
                { "<leader>g", helpers.lazy_required_fn("rust-tools.crate_graph", "view_crate_graph"),
                    description = "View crate graph" },

                -- Treesitter
                { "<leader>j", helpers.lazy_required_fn("trevj", "format_at_cursor"), description = "TS Split lines" },

                -- Snippets
                {
                    "<c-k>", function()
                        local ls = require("luasnip")

                        if ls.expand_or_jumpable() then
                            ls.expand_or_jump()
                        end
                    end,
                    mode = { "s", "i" },
                    description = "Expand current snippet or jump to the next item within it",
                },
                {
                    "<c-j>", function()
                        local ls = require("luasnip")

                        if ls.jumpable(-1) then
                            ls.jump(-1)
                        end
                    end,
                    mode = { "s", "i" },
                    description = "Move to the previous item within the snippet",
                },
                {
                    "<c-l>", function()
                        local ls = require("luasnip")

                        if ls.choice_active() then
                            ls.change_choice(1)
                        end
                    end,
                    mode = { "s", "i" },
                    description = "Select within the snippet's list of options",
                },
                { "<c-s>", helpers.lazy_required_fn("luasnip.extras", "select_choice"), mode = { "s", "i" },
                    description = "Visually select a snippet choice" },
                { "<leader><leader>s",
                    helpers.lazy_required_fn("luasnip.loaders.from_lua", "load", { paths = "~/.config/nvim/snippets/" }),
                    description = "Load snippets" },
                { "<leader><leader>r", helpers.lazy_required_fn("luasnip.loaders.from_lua", "edit_snippet_files"),
                    description = "Edit snippets" },

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
                        { direction = require("hop.hint").HintDirection.AFTER_CURSOR, current_line_only = true,
                            hint_offset = -1 }),
                    mode = { "n", "o" },
                    description = "Jump to character after cursor in line",
                },
                {
                    "T",
                    helpers.lazy_required_fn("hop", "hint_char1",
                        { direction = require("hop.hint").HintDirection.BEFORE_CURSOR, current_line_only = true,
                            hint_offset = 1 }),
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

                -- Dial
                {
                    "<c-a>", "<Plug>(dial-increment)", description = "Increase next item under cursor or available",
                },
                {
                    "<c-x>", "<Plug>(dial-decrement)", description = "Decrease next item under cursor or available",
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
    }

    -- Show indentation lines
    use {
        "lukas-reineke/indent-blankline.nvim",
        cfg = function()
            vim.opt.list = true
            vim.opt.listchars:append("space:⋅")
            vim.opt.listchars:append("eol:↴")

            require("indent_blankline").setup({
                space_char_blankline = " ",
                show_trailing_blankline_indent = true,
                show_current_context = true,
                show_current_context_start = true,
                context_patterns = {
                    "class", "function", "method", "block", "list_literal", "selector",
                    "^if", "^table", "if_statement", "while", "for"
                },
            })
        end,
    }

    -- Quick jump
    use {
        "phaazon/hop.nvim",
        config = function()
            require("hop").setup({
                --keys = "uhetonaspg.c,rkmjwv",
            })
        end,
    }

    -- Switch between relative and absolute numbers
    use "jeffkreeftmeijer/vim-numbertoggle"

    -- Show and remove extra whitespace
    use {
        "ntpeters/vim-better-whitespace",
        config = function()
            -- Strip all whitespace on save, disable with :DisableStripWhitespaceOnSave
            vim.g.strip_whitespace_on_save = 1
        end,
    }

    -- Highlight TODO comments
    use {
        "folke/todo-comments.nvim",
        requires = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("todo-comments").setup()
        end,
    }

    -- Rust
    use {
        "iron-e/rust.vim",
        ft = "rust",
        config = function()
            -- Autoformat Rust on save
            vim.g.rustfmt_autosave = 1
        end,
    }

    -- More Rust
    use {
        "simrat39/rust-tools.nvim",
        requires = {
            { "neovim/nvim-lspconfig" },
            { "nvim-lua/popup.nvim" },
            { "nvim-lua/plenary.nvim" },
            -- Debugging
            { "mfussenegger/nvim-dap" },
        },
        ft = "rust",
        config = function()
            require("rust-tools").setup({
                tools = {
                    -- Automatically set inlay hints
                    autoSetHints = true,

                    -- Show actions when hovering
                    hover_with_actions = true,

                    runnables = {
                        -- Use telescope for the selection menu
                        use_telescope = true,
                    },
                },
                server = {
                    -- Attach to nvim-cmp
                    capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
                }
            })
        end,
    }

    -- Opposite of J
    use {
        "AckslD/nvim-trevJ.lua",
        config = function()
            require("trevj").setup()
        end,
    }

    -- TOML
    use {
        "cespare/vim-toml",
        ft = "toml",
    }

    -- Keep track of the time spent programming with wakatime
    use "wakatime/vim-wakatime"

    -- WGSL highlighting
    use "DingDean/wgsl.vim"

    -- Automatically setup the configuration after cloning packer.nvim, must be after other plugins
    if packer_bootstrap then
        require("packer").sync()
    end
end,
    -- Use a floating window for packer
    config = {
        display = {
            open_fn = require("packer.util").float,
        },
    } })

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

    -- Set the leader key to space
    vim.g.mapleader = " "

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
