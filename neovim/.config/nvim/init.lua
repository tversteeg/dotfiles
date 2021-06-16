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

    -- Fuzzy find popup windows
    paq {
        "nvim-telescope/telescope.nvim",
        deps = {
            "nvim-lua/popup.nvim",
            "nvim-lua/plenary.nvim",
        },
        cfg = function()
            vim.api.nvim_set_keymap("", "<C-p>", ":lua require 'telescope.builtin'.git_files()<CR>", {})
            vim.api.nvim_set_keymap("!", "<C-p>", ":lua require 'telescope.builtin'.git_files()<CR>", {})
        end,
    }

    -- Treesitter highlighting
    paq {
        "nvim-treesitter/nvim-treesitter",
        deps = {
            -- Rainbow parentheses
            "p00f/nvim-ts-rainbow",
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
                -- Rainbow parentheses
                rainbow = {
                    enable = true,
                },
            })
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
            --vim.api.nvim_set_keymap("i", "<cr>", "compe#confirm('<cr>')", {noremap = true, expr = true, silent = true})
        end,
    }

    -- Switch between relative and absolute numbers
    paq "jeffkreeftmeijer/vim-numbertoggle"

    -- Show and remove extra whitespace
    paq {
        "ntpeters/vim-better-whitespace",
        cfg = function()
            -- Strip all whitespace on save, disable with :DisableStripWhitespaceOnSave
            vim.g.strip_whitespace_on_save = 1
        end,
    }

    -- Autoformat
    paq {
        "lukas-reineke/format.nvim",
        cfg = function()
            local format = require "format"

            format.setup({
                lua = {
                    {
                        cmd = {
                            function(file)
                                return string.format("luafmt -l %s -w replace %s", vim.bo.textwidth, file)
                            end
                        }
                    }
                },
                javascript = {
                    {cmd = {"prettier -w", "./node_modules/.bin/eslint --fix"}}
                },
                html = {
                    {cmd = {"prettier -w"}},
                },
                markdown = {
                    {cmd = {"prettier -w"}},
                    {
                        cmd = {"black"},
                        start_pattern = "^```python$",
                        end_pattern = "^```$",
                        target = "current"
                    }
                }
            })

            vim.cmd("autocmd BufWritePost * FormatWrite")
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

    -- TOML
    paq {
        "cespare/vim-toml",
        ft = "toml",
    }

    -- Keep track of the time spent programming with wakatime
    paq "wakatime/vim-wakatime"
end

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
