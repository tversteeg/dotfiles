--[[ Bootstrap Package Manager ]]
local packer_bootstrap
do
    -- Clone the git repository if not found
    local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
        -- Clone the package manager repository
        packer_bootstrap = vim.fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
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
    use "~/r/registers.nvim"

    -- Fuzzy find popup windows
    use {
        "nvim-telescope/telescope.nvim",
        requires = {
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
                ensure_installed = { "lua", "rust", "typescript", "python", "vue", "toml", "vim", "yaml", "json", "dockerfile", "bash" },
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
                { "hrsh7th/cmp-nvim-lsp" },
            },
            config = function()
                local lsp = require "lspconfig"

                -- Add LSP to autocompletion
                local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

                -- Setup Rust
                lsp.rust_analyzer.setup({
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

                -- Setup Vue
                lsp.volar.setup({
                    capabilities = capabilities,
                    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
                })

                -- Setup Python
                lsp.pylsp.setup({
                    capabilities = capabilities,
                })

                -- Setup Lua
                local runtime_path = vim.split(package.path, ';')
                table.insert(runtime_path, "lua/?.lua")
                table.insert(runtime_path, "lua/?/init.lua")
                lsp.sumneko_lua.setup({
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

                -- Format using LSP on save
                vim.api.nvim_create_autocmd({ "BufWritePre" }, {
                    callback = function()
                        vim.lsp.buf.format()
                    end,
                })
            end,
        }

        -- Use FZF for the LSP
        -- :LspDiagnostics
        -- :LspDiagnosticsAll
        -- :LspFuzzyLast
        use {
            "ojroques/nvim-lspfuzzy",
            requires = {
                { "junegunn/fzf" },
                -- For the preview
                { "junegunn/fzf.vim" },
                config = function()
                    require("lspfuzzy").setup()
                end,
            },
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
                require("lsp_lines").register_lsp_virtual_lines()

                -- Disable virtual text diagnostics since they are redundant
                vim.diagnostic.config({
                    virtual_text = false
                })
            end,
        }
    end

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
            local git = require "cmp_git"

            -- Fix neovim completion options
            vim.o.completeopt = "menuone,noinsert,noselect"

            -- Enable different autocompletion targets
            cmp.setup({
                enabled = true,
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                sources = {
                    { name = "nvim_lsp" },
                    { name = "rg" },
                    { name = "nvim_lua" },
                    { name = "buffer" },
                    { name = "path" },
                    { name = "crates" },
                    { name = "luasnip" },
                    { name = "git" },
                },
                mapping = cmp.mapping.preset.insert({
                    --["<space>"] = cmp.mapping.complete(),
                    ["<c-y>"] = cmp.mapping.confirm({ select = true }),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
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

            git.setup()

            -- Disable when inside telescope
            vim.api.nvim_create_autocmd(
                { "FileType" },
                {
                    pattern = "TelescopePrompt",
                    callback = function()
                        cmp.setup_buffer({ enabled = false })
                    end
                })
        end,
    }

    -- Define and show keybindings
    use {
        "mrjones2014/legendary.nvim",
        config = function()
            local helpers = require('legendary.helpers')

            local keymaps = {
                -- Menus
                { "<leader><leader>", helpers.lazy_required_fn("legendary", "find", "keymaps"), description = "This menu" },
                { "<leader>a", "<cmd>CodeActionMenu<CR>", description = "Code action menu" },
                { "<leader>f", require("telescope").extensions.frecency.frecency, description = "Most used files" },
                { "<c-p>", helpers.lazy_required_fn("telescope.builtin", "git_files"), description = "Git files", mode = { "n", "v", "i" } },

                -- Neovim dotfiles
                { "<leader>l", "luafile %<CR>", description = "Execute current buffer as a Lua file" },

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
                { "<leader>r", vim.lsp.buf.rename, description = "LSP rename" },
            }

            require("legendary").setup({
                keymaps = keymaps,
                most_recent_item_at_top = true,
            })

        end,
    }

    --[[
    -- Automatically format code
    use {
        "mhartington/formatter.nvim",
        config = function()
            require("formatter").setup({
                filetype = {
                    lua = {
                        function()
                            return {
                                exe = "luafmt",
                                args = { "-l", vim.bo.textwidth, "--stdin" },
                                stdin = true
                            }
                        end
                    },
                    python = {
                        function()
                            return {
                                exe = "cemsdev",
                                args = { "run", "format", "--only", "python" },
                            }
                        end
                    },
                    javascript = {
                        function()
                            return {
                                exe = "cemsdev",
                                args = { "run", "format", "--only", "typescript" },
                            }
                        end
                    },
                    typescript = {
                        function()
                            return {
                                exe = "cemsdev",
                                args = { "run", "format", "--only", "typescript" },
                            }
                        end
                    },
                    vue = {
                        function()
                            return {
                                exe = "prettier",
                                args = { "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)), "--single-quote" },
                                stdin = true
                            }
                        end
                    },
                    markdown = {
                        function()
                            return {
                                exe = "cemsdev",
                                args = { "run", "format", "--only", "markdown" },
                            }
                        end
                    },
                    sh = {
                        function()
                            return {
                                exe = "shfmt",
                                stdin = true,
                            }
                        end
                    },
                }
            })

            vim.cmd("autocmd BufWritePost * FormatWrite")
        end,
    }
    ]] --

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
            { "nvim-telescope/telescope-ui-select.nvim" },
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
            })

            -- Map the shortcuts
            local function map_shortcut(shortcut, name, args)
                vim.api.nvim_set_keymap("n", shortcut, ("<cmd>lua require'rust-tools.%s'.%s(%s)<CR>"):format(name, name, args or ""), { noremap = true, silent = true })
            end

            map_shortcut("K", "hover_actions")
            map_shortcut("J", "join_lines")
            map_shortcut("<leader>c", "open_cargo_toml")
            map_shortcut("<leader>p", "parent_module")
            map_shortcut("<leader>r", "runnables")
            map_shortcut("<leader>e", "expand_macro")

            map_shortcut("<leader>u", "move_item", "true")
            map_shortcut("<leader>d", "move_item", "false")

            vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>lua require'rust-tools.crate_graph'.view_crate_graph()<CR>", { noremap = true, silent = true })
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

    -- Base16 colorscheme
    vim.cmd("colorscheme base16")
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
