--[[ Bootstrap Package Manager ]]
do
	-- Clone the git repository if not found
	local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
	if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
		vim.cmd("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
	end

	-- Initialize the package manager
	vim.cmd("packadd packer.nvim")
end

--[[ Packages ]]
require("packer").startup(function()
	-- Update the package manager
	use {"wbthomason/packer.nvim", opt = true}

	-- Purple color theme
	use {
		"yassinebridi/vim-purpura",
		config = function()
			vim.cmd("colorscheme purpura")
		end,
	}

	-- Language Server
	use {
		"neovim/nvim-lspconfig",
		requires = {
			-- Language Server extensions, type inlay hints
			"nvim-lua/lsp_extensions.nvim",
			-- Language Server completions
			"nvim-lua/completion-nvim",
		},
		ft = "rust",
		config = function()
			local lsp = require "lspconfig"

			-- Attach the plugins to the LSP
			local on_attach = function(client)
				local completion = require "completion"

				completion.on_attach(client)
			end

			-- Setup rust-analyzer
			lsp.rust_analyzer.setup({on_attach = on_attach})

			-- Map the shortcuts
			local function lsp_map(shortcut, name)
				vim.api.nvim_set_keymap("n", shortcut, "<cmd>lua vim.lsp.buf." .. name .. "()<CR>", {noremap = true, silent = true})
			end
			lsp_map("gd", "declaration")
			lsp_map("<c-]>", "definition")
			lsp_map("K", "hover")
			lsp_map("gD", "implementation")
			lsp_map("<c-k>", "signature_help")
			lsp_map("1gD", "type_definition")
			lsp_map("gr", "references")
			lsp_map("g0", "document_symbol")
			lsp_map("ga", "code_action")

			-- Enable type inlay hints
			vim.cmd("autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost * lua require\"lsp_extensions\".inlay_hints{prefix = \"\", highlight = \"NonText\"}")
		end
	}

	-- Show git blame info on the current line
	use {
		"APZelos/blamer.nvim",
		config = function()
			vim.g.blamer_enabled = 1
		end,
	}

	-- Switch between relative and absolute numbers
	use "jeffkreeftmeijer/vim-numbertoggle"

	-- Show buffers in the tabline
	use "ap/vim-buftabline"

	-- Show and remove extra whitespace
	use {
		"ntpeters/vim-better-whitespace",
		config = function()
			-- Strip all whitespace on save, disable with :DisableStripWhitespaceOnSave
			vim.g.strip_whitespace_on_save = 1
		end,
	}

	-- Highlight f & t symbols
	use {
		"unblevable/quick-scope",
		config = function()
			-- Trigger a highlight in the appropriate direction when pressing these keys
			vim.g.qs_highlight_on_keys = {"f", "F", "t", "T"}
		end,
	}

	-- Set the terminal colors needed for the colorizer
	vim.o.termguicolors = true
	-- Highlight color text
	use {
		"norcalli/nvim-colorizer.lua",
		config = function()
			local colorizer = require "colorizer"

			colorizer.setup()
		end,
	}

	-- Add rainbow parentheses
	use {
		"luachen1990/rainbow",
		config = function()
			vim.g.rainbow_active = 1
		end,
	}

	-- Code snippets
	use {
		"SirVer/ultisnips",
		config = function()
			vim.g.UltiSnipsExpandTrigger = "<c-s>"
			vim.g.UltiSnipsJumpForwardTrigger = "<c-b>"
			vim.g.UltiSnipsJumpBackwardTrigger = "<c-z>"
			-- Split the window
			vim.g.UltiSnipsEditSplit = "vertical"
		end,
	}

	-- Fuzzy find
	use {
		"junegunn/fzf.vim",
		requires = {"junegunn/fzf"},
		config = function()
			-- Map shortcuts
			vim.api.nvim_set_keymap("", "<C-p>", ":GFiles<CR>", {})
			vim.api.nvim_set_keymap("!", "<C-p>", ":GFiles<CR>", {})
			vim.api.nvim_set_keymap("", "<C-.>", ":FZF<CR>", {})
			vim.api.nvim_set_keymap("!", "<C-.>", ":FZF<CR>", {})

			-- Use bat for FZF previews
			vim.g.fzf_files_options = "--preview \"bat {}\""
		end,
	}

	-- Rust
	use {
		"rust-lang/rust.vim",
		config = function()
			-- Autoformat Rust on save
			vim.g.rustfmt_autosave = 1
		end,
	}

	-- Luacheck
	use {
		"vim-syntastic/syntastic",
		ft = "lua",
		config = function()
			vim.g.syntastic_lua_checkers = {"luacheck"}
		end,
	}

	-- TOML
	use {
		"cespare/vim-toml",
		-- Rust crate versions
		requires = {"mhinz/vim-crates"},
		ft = "toml",
		config = function()
			-- Show outdated crates in Cargo.toml
			vim.cmd("autocmd BufRead Cargo.toml call crates#toggle()")
		end,
	}

	-- RON
	use {
		"ron-rs/ron.vim",
		ft = "ron",
	}

	-- Keep track of the time spent programming with wakatime
	use "wakatime/vim-wakatime"
end)

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
	vim.o.undodir = "~/.config/nvim/undo"

	-- Show live preview of substitutions
	vim.o.inccommand = "split"

	-- Set the minimal width of the window
	vim.o.winwidth = 80
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
		"FileType lua setlocal tabstop=4 shiftwidth=4",
	}, "lua")

	-- YAML indentation
	create_augroup({
		"FileType yaml setlocal ts=2 sts=2 sw=2 expandtab",
		"FileType yml setlocal ts=2 sts=2 sw=2 expandtab",
	}, "yaml")

	-- Highlight yanked regions
	create_augroup({
		"TextYankPost * silent! lua require'vim.highlight'.on_yank()"
	}, "highlight")
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
