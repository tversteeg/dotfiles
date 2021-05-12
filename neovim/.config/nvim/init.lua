--[[ Bootstrap Package Manager ]]
do
    -- Clone the git repository if not found
    local install_path = vim.fn.stdpath("data") .. "/site/pack/paqs/opt/paq-nvim"
    if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
        -- Clone the package manager repository
        vim.cmd("!git clone https://github.com/savq/paq-nvim " .. install_path)
    end

    -- Initialize the package manager
    vim.cmd("packadd paq-nvim")
end

--[[ Local packages ]]
do
    local function loc(name, dir)
        local target_dir = ("%s/site/pack/%s/start"):format(vim.fn.stdpath("data"), name)

        -- If the plugin is already linked do nothing
        if vim.fn.empty(vim.fn.glob(target_dir)) <= 0 then
            return
        end

        -- Create the directory
        vim.cmd(("!mkdir -p %q"):format(target_dir))

        -- Create a symbolic link for the locally developed plugins
        vim.cmd(("!ln -s %s %s/%s"):format(dir, target_dir, name))
    end

    -- Registers plugin
    loc("registers.nvim", "~/r/registers.nvim")
end

--[[ Packages ]]
do
    -- Get the name of a package
    local function plugin_name(path)
        return path:gmatch(".*/(.*)")()
    end

    -- Get the full path of where the plugin should be installed
    local function plugin_path(name, opt)
        return ("%s/site/pack/paqs/%s/%s"):format(vim.fn.stdpath("data"), opt and "opt" or "start", plugin_name(name))
    end

    -- Whether the package is already loaded, look in both the opt and the start path
    local function is_loaded(name)
        -- First check the optional path
        if vim.fn.empty(vim.fn.glob(plugin_path(name, true))) == 0 then
            return true
        else
            -- Then check the start path
            return vim.fn.empty(vim.fn.glob(plugin_path(name, false))) == 0
        end
    end

    -- Run the installation with plugin specific configuration settings
    local function paq(data)
        local paq = require "paq-nvim"

        -- If a single string is passed use that
        if type(data) == "string" then
            data = {
                data,
            }
        end
        assert(type(data[1]) == "string", vim.inspect(data))

        -- If a filetype is declared to load the plugin, the package is optional
        if data.ft then
            data.opt = true
        end

        -- First install the dependencies
        if data.deps then
            local function load_dep(dep)
                assert(type(dep) == "string", vim.inspect(data))
                paq.paq(dep)
            end

            if type(data.deps) == "table" then
                -- Loop over all the strings
                for _, dep in pairs(data.deps) do
                    load_dep(dep)
                end
            else
                load_dep(data.deps)
            end
        end

        -- Register the paq package
        paq.paq(data)

        local function load()
            -- Call the pre configuration function if set
            if data.pre_cfg then
                data.pre_cfg()
            end

            -- Load the package itself if it's optional
            if data.opt then
                vim.cmd("packadd " .. plugin_name(data[1]))
            end

            -- Call the configuration function if set
            if data.cfg then
                data.cfg()
            end
        end

        -- Load the plugin
        -- TODO: wait for autocommand for ft https://github.com/neovim/neovim/pull/12378
        if not data.opt or data.ft then
            -- Only load when the package is installed
            if is_loaded(data[1]) then
                load()
            end
        end
    end

    -- The package manager itself
    paq {
        "savq/paq-nvim",
        opt = true,
    }

    -- Treesitter highlighting
    paq {
        "nvim-treesitter/nvim-treesitter",
        deps = {
            -- Rainbow parentheses
            "p00f/nvim-ts-rainbow",
            -- Show treesitter symbols
            "nvim-treesitter/playground",
            -- Treesitter text objects & motions
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        run = function()
            vim.cmd(":TSUpdate")
        end,
        cfg = function()
            local treesitter = require "nvim-treesitter.configs"

            treesitter.setup({
                ensure_installed = {"lua", "rust", "typescript", "python"},
                -- Syntax highlighting
                highlight = {
                    enable = true,
                },
                -- Better indentation
                indent = {
                    enable = true,
                },
                -- Rainbow parentheses
                rainbow = {
                    enable = true,
                },
                -- Playground, show the treesitter symbols
                playground = {
                    enable = true,
                },
                -- Text objects
                textobjects = {
                    -- Selection spans
                    select = {
                        enable = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                            ["al"] = "@conditional.outer",
                            ["il"] = "@conditional.inner",
                        },
                    },
                    -- Move parameters around in functions
                    swap = {
                        enable = true,
                        swap_next = {
                            ["<leader>a"] = "@parameter.inner",
                        },
                        swap_previous = {
                            ["<leader>A"] = "@parameter.inner",
                        },
                    }
                },
            })
        end,
    }

    -- Color theme
    paq {
        "sainnhe/everforest",
        pre_cfg = function()
            vim.o.termguicolors = true
        end,
        cfg = function()
            -- "hard", "medium" or "soft"
            vim.g.everforest_background = "hard"

            vim.cmd("colorscheme everforest")
        end,
    }

    -- Pretty dev icons, requires a nerd font
    paq {
        "yamatsum/nvim-web-nonicons",
        deps = {
            "kyazdani42/nvim-web-devicons",
        },
        cfg = function()
            local icons = require "nvim-web-devicons"

            icons.setup()
        end,
    }

    -- Language Server
    paq {
        "neovim/nvim-lspconfig",
        deps = {
            -- Language Server extensions, type inlay hints
            "nvim-lua/lsp_extensions.nvim",
            -- Status line information
            "nvim-lua/lsp-status.nvim",
            -- Use FZF for the LSP, :LspDiagnostics
            "ojroques/nvim-lspfuzzy",
        },
        ft = "rust",
        cfg = function()
            local lsp = require "lspconfig"
            local fuzzy = require "lspfuzzy"
            local lsp_status = require "lsp-status"

            -- Add LSP snippets to autocompletion
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true

            -- Setup rust-analyzer
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
            lsp.vuels.setup({
                on_attach = lsp_status.on_attach,
                capabilities = lsp_status.capabilities,
            })

            -- Setup typescript
            lsp.tsserver.setup({
                on_attach = lsp_status.on_attach,
                capabilities = lsp_status.capabilities,
            })

            -- Setup python
            lsp.pyls.setup({
                on_attach = lsp_status.on_attach,
                capabilities = lsp_status.capabilities,
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
            -- The rest is mapped in the telescope nvim part

            -- Enable type inlay hints
            vim.cmd("autocmd FileType rust :lua require'lsp_extensions'.inlay_hints({prefix = '', highlight = 'NonText'})")

            -- Setup LSP
            fuzzy.setup({})

            -- Setup the status line
            lsp_status.register_progress()
        end
    }

    -- Auto completion
    paq {
        "hrsh7th/nvim-compe",
        cfg = function()
            local compe = require "compe"

            -- Fix neovim completion options
            vim.o.completeopt = "menuone,noinsert,noselect"

            -- Enable different autocompletion targets
            compe.setup({
                enabled = true,
                source = {
                    path = true,
                    buffer = true,
                    calc = true,
                    nvim_lsp = true,
                    nvim_lua = true,
                    spell = true,
                    tags = true,
                    treesitter = true,
                    snippets_nvim = true,
                },
            })

            -- Map autocompletion key
            vim.api.nvim_set_keymap("i", "<c-space>", "compe#complete()", {noremap = true, expr = true, silent = true})
            vim.api.nvim_set_keymap("i", "<cr>", "compe#confirm('<cr>')", {noremap = true, expr = true, silent = true})
        end,
    }

    -- Comments, gcc for a single line, gc with a motion
    paq {
        "b3nj5m1n/kommentary",
        cfg = function()
            local kommentary = require "kommentary.config"

            kommentary.configure_language("rust", {
                single_line_comment_strings = "//",
                multi_line_comment_strings = {"/*", "*/"},
            })
            kommentary.configure_language("lua", {
                single_line_comment_strings = "--",
                multi_line_comment_strings = {"--[[", "]]"},
            })
        end,
    }

    -- Git information in the sidebar
    paq {
        "lewis6991/gitsigns.nvim",
        cfg = function()
            local signs = require "gitsigns"

            signs.setup()
        end,
    }

    -- Git blame info on the current line
    paq "f-person/git-blame.nvim"

    -- Switch between relative and absolute numbers
    paq "jeffkreeftmeijer/vim-numbertoggle"

    -- Show buffers in the tabline
    paq {
        "akinsho/nvim-bufferline.lua",
        cfg = function()
            local bufferline = require "bufferline"

            bufferline.setup({
                options = {
                    diagnostics = "nvim_lsp",
                    show_close_icon = false,
                    show_buffer_close_icon = false,
                },
            })
        end,
    }

    -- Pretty status line
    paq {
        "hoob3rt/lualine.nvim",
        deps = {
            "kyazdani42/nvim-web-devicons",
        },
        cfg = function()
            local statusline = require "lualine"

            statusline.setup({
                options = {
                    theme = "everforest",
                    section_separators = "",
                    component_separators = "",
                }
            })
        end
    }

    -- Show and remove extra whitespace
    paq {
        "ntpeters/vim-better-whitespace",
        cfg = function()
            -- Strip all whitespace on save, disable with :DisableStripWhitespaceOnSave
            vim.g.strip_whitespace_on_save = 1
        end,
    }

    -- Highlight color text
    paq {
        "norcalli/nvim-colorizer.lua",
        cfg = function()
            local colorizer = require "colorizer"

            colorizer.setup()
        end,
    }

    -- Highlight words and lines on the cursor
    paq "yamatsum/nvim-cursorline"

    -- Dim inactive windows
    --[[paq {
        "sunjon/shade.nvim",
        cfg = function()
            local shade = require "shade"

            shade.setup()
        end
    }]]

    -- Peek lines when pressing :
    paq {
        "nacro90/numb.nvim",
        cfg = function()
            local numb = require "numb"

            numb.setup()
        end
    }

    -- Code snippets
    paq {
        "norcalli/snippets.nvim",
        cfg = function()
            local snippets = require "snippets"

            snippets.use_suggested_mappings()

            vim.api.nvim_set_keymap("i", "<c-s>", "<cmd>lua return require'snippets'.expand_or_advance(1)<CR>", {noremap = true})
            vim.api.nvim_set_keymap("i", "<c-b>", "<cmd>lua return require'snippets'.expand_or_advance(-1)<CR>", {noremap = true})
        end,
    }

    -- Fuzzy find popup windows
    paq {
        "nvim-telescope/telescope.nvim",
        deps = {
            "nvim-lua/popup.nvim",
            "nvim-lua/plenary.nvim",
        },
        cfg = function()
            -- Map shortcuts
            vim.api.nvim_set_keymap("", "<C-p>", ":lua require 'telescope.builtin'.git_files()<CR>", {})
            vim.api.nvim_set_keymap("!", "<C-p>", ":lua require 'telescope.builtin'.git_files()<CR>", {})

            vim.api.nvim_set_keymap("", "<leader>ff", ":lua require 'telescope.builtin'.find_files()<CR>", {})
            vim.api.nvim_set_keymap("", "<leader>fq", ":lua require 'telescope.builtin'.quickfix()<CR>", {})
            vim.api.nvim_set_keymap("", "<leader>fb", ":lua require 'telescope.builtin'.buffers()<CR>", {})
            vim.api.nvim_set_keymap("", "<leader>fh", ":lua require 'telescope.builtin'.help_tags()<CR>", {})
            vim.api.nvim_set_keymap("", "<leader>ft", ":lua require 'telescope.builtin'.filetypes()<CR>", {})

            vim.api.nvim_set_keymap("", "gr", ":lua require 'telescope.builtin'.lsp_references()<CR>", {})
            vim.api.nvim_set_keymap("", "g0", ":lua require 'telescope.builtin'.lsp_document_symbols()<CR>", {})
            vim.api.nvim_set_keymap("", "ga", ":lua require 'telescope.builtin'.lsp_code_actions()<CR>", {})
            vim.api.nvim_set_keymap("", "<c-]>", ":lua require 'telescope.builtin'.lsp_definitions()<CR>", {})

            vim.api.nvim_set_keymap("", "<leader>ld", ":lua require 'telescope.builtin'.lsp_document_diagnostics()<CR>", {})
            vim.api.nvim_set_keymap("", "<leader>lw", ":lua require 'telescope.builtin'.lsp_workspace_diagnostics()<CR>", {})
        end,
    }

    -- Make vim harder
    paq {
        "takac/vim-hardtime",
        cfg = function()
            -- Always enable hardtime
            vim.g.hardtime_default_on = 1

            -- Allow combination of keys
            vim.g.hardtime_allow_different_key = 1

            -- Set the maximum repeated key presses
            vim.g.hardtime_maxcount = 4
        end,
    }

    -- Rust
    paq {
        "rust-lang/rust.vim",
        ft = "rust",
        cfg = function()
            -- Autoformat Rust on save
            vim.g.rustfmt_autosave = 1
        end,
    }

    -- Luacheck
    paq {
        "vim-syntastic/syntastic",
        ft = "lua",
        cfg = function()
            vim.g.syntastic_lua_checkers = {"luacheck"}
        end,
    }

    -- TOML
    paq {
        "cespare/vim-toml",
        ft = "toml",
    }

    -- Rust crate versions
    paq {
        "mhinz/vim-crates",
        ft = "toml",
        cfg = function()
            -- Show outdated crates in Cargo.toml
            vim.cmd("autocmd BufRead Cargo.toml call crates#toggle()")
        end,
    }

    -- RON
    paq {
        "ron-rs/ron.vim",
        ft = "ron",
    }

    -- Vue.js
    paq {
        "posva/vim-vue",
        ft = {"javascript", "vue", "scss"},
    }

    -- Delphi
    paq "rkennedy/vim-delphi"

    -- Keep track of the time spent programming with wakatime
    paq "wakatime/vim-wakatime"
end

--[[ Global Options ]]
do
    -- Always use UTF-8
    vim.o.encoding = "utf-8"

    -- Automatically reload files changed outside of vim
    vim.o.autoread = true

    -- Don't wait 4 seconds for a popup to show
    vim.o.updatetime = 1000

    -- Set the title in the terminal
    vim.o.title = true

    -- Where to store the undo files
    vim.o.undodir = "/home/thomas/.config/nvim/undo"

    -- Show live preview of substitutions
    vim.o.inccommand = "split"

    -- Set the minimal width of the window
    vim.o.winwidth = 80

    -- Show the command in the status line
    vim.o.showcmd = true
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

    -- Always show the sign column
    vim.wo.signcolumn = "yes"
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