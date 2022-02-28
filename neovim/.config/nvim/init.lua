--[[ Bootstrap Package Manager ]]
do
    -- Clone the git repository if not found
    local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
        -- Clone the package manager repository
        packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
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
require("packer").startup({function(use)
    -- The package manager itself
    use "wbthomason/packer.nvim"

    -- Registers plugin
    use "~/r/registers.nvim"

    -- Fuzzy find popup windows
    use {
        "nvim-telescope/telescope.nvim",
        requires = {
            { "nvim-lua/plenary.nvim" },
        },
        config = function()
            vim.api.nvim_set_keymap("", "<c-p>", ":lua require('telescope.builtin').git_files()<CR>", {})
            vim.api.nvim_set_keymap("!", "<c-p>", ":lua require('telescope.builtin').git_files()<CR>", {})
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
            local parsers = require "nvim-treesitter.parsers"

            treesitter.setup({
                ensure_installed = {"lua", "rust", "typescript", "python", "vue", "toml", "vim", "yaml", "json", "dockerfile", "bash"},
                -- Syntax highlighting
                highlight = {
                    enable = true,
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
                    filetypes = {"typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json"},
                })

                -- Setup Python
                lsp.pylsp.setup({
                    capabilities = capabilities,
                })

                -- Map the shortcuts
                local function lsp_map(shortcut, name)
                    vim.api.nvim_set_keymap("n", shortcut, "<cmd>lua vim.lsp.buf." .. name .. "()<CR>", {noremap = true, silent = true})
                end

                lsp_map("gd", "declaration")
                lsp_map("K", "hover")
                lsp_map("gD", "implementation")
                lsp_map("<c-k>", "signature_help")
                lsp_map("1gD", "type_definition")
                lsp_map("ga", "code_action")
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
                vim.cmd("autocmd CursorHold,CursorHoldI * lua require('nvim-lightbulb').update_lightbulb()")
            end
        }

        -- Code action menu
        -- <leader>a
        use {
            "weilbith/nvim-code-action-menu",
            config = function()
                -- Show the code action menu
                vim.api.nvim_set_keymap("n", "<leader>a", "<cmd>CodeActionMenu<CR>", {noremap = true, silent = true})
            end,
        }

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
        },
        config = function()
            local cmp = require "cmp"

            -- Fix neovim completion options
            vim.o.completeopt = "menuone,noinsert,noselect"

            -- Enable different autocompletion targets
            cmp.setup({
                enabled = true,
                sources = {
                    {name = "nvim_lsp"},
                    {name = "rg"},
                    {name = "nvim_lua"},
                    {name = "buffer"},
                    {name = "path"},
                    {name = "crates"},
                },
                mapping = {
                    ["<c-space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
                    ["<c-y>"] = cmp.mapping.confirm({select = true}),
                    ["<CR>"] = cmp.mapping.confirm({select = true}),
                },
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end,
                },
            })

            -- Autocompletion in / search
            cmp.setup.cmdline("/", {
                sources = {
                    {name = "buffer"},
                }
            })

            -- Autocompletion in : command
            cmp.setup.cmdline(":", {
                sources = cmp.config.sources({
                    {name = "path"},
                }, {
                    {name = "cmdline"},
                })
            })

            -- Disable when inside telescope
            vim.cmd("autocmd FileType TelescopePrompt lua require('cmp').setup.buffer({ enabled = false })")
        end,
    }

    -- Automatically format code
    use {
        "lukas-reineke/format.nvim",
        config = function()
            require("format").setup({
                lua = {
                    {
                        cmd = {
                            function(file)
                                return string.format("luafmt -l %s -w replace %s", vim.bo.textwidth, file)
                            end
                        }
                    }
                },
                python = {
                    {
                        cmd = {"cemsdev run format --only python"}
                    }
                },
                javascript = {
                    {
                        cmd = {"cemsdev run format --only typescript"}
                    }
                },
                typescript = {
                    {
                        cmd = {"cemsdev run format --only typescript"}
                    }
                },
                vue = {
                    {
                        cmd = {"prettier -w"}
                    }
                },
                markdown = {
                    {
                        cmd = {"cemsdev run format --only markdown"}
                    }
                },
                bash = {
                    {
                        cmd = {"shfmt -l -w"}
                    }
                },
                sh = {
                    {
                        cmd = {"shfmt -l -w"}
                    }
                }
            })

            vim.cmd("autocmd BufWritePost * FormatWrite")
        end,
    }

    -- Show whitespace
    use {
        "lukas-reineke/indent-blankline.nvim",
        cfg = function()
            local indent = require "indent_blankline"

            vim.g.indent_blankline_show_first_indent_level = true
            vim.g.indent_blankline_show_trailing_blankline_indent = false
            vim.g.indent_blankline_show_current_context = true
            vim.g.indent_blankline_context_patterns = {
                "class", "function", "method", "block", "list_literal", "selector",
                "^if", "^table", "if_statement", "while", "for"
            }

            require("indent_blankline").setup()
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
        end,
    }

    -- TOML
    use {
        "cespare/vim-toml",
        ft = "toml",
    }

    -- Keep track of the time spent programming with wakatime
    use "wakatime/vim-wakatime"

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
}})

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
    -- Use jj instead of <esc>
    vim.api.nvim_set_keymap("i", "jj", "<esc>", {noremap = true})
    vim.api.nvim_set_keymap("i", "<esc>", "", {noremap = true})

    -- Move across wrapped lines like regular lines
    -- Go to the first non-blank character of a line
    vim.api.nvim_set_keymap("n", "0", "^", {noremap = true})
    -- Just in case you need to go to the very beginning of a line
    vim.api.nvim_set_keymap("n", "^", "0", {noremap = true})
end
