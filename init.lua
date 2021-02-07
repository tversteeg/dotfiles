--[[ Bootstrap Package Manager ]]
do
	local cmd = vim.cmd
	local fn = vim.fn

	-- Clone the git repository if not found
	local install_path = fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		cmd("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
	end

	-- Initialize the package manager
	cmd("packadd packer.nvim")
end

--[[ Packages ]]
require("packer").startup(function()
	-- Update the package manager
	use {"wbthomason/packer.nvim", opt = true}

	-- Purple color theme
	use "yassinebridi/vim-purpura"
	do
		vim.cmd("colorscheme purpura")
	end

	-- Language Server
	use "neovim/nvim-lspconfig"
	-- Language Server extensions, type inlay hints
	use "nvim-lua/lsp_extensions.nvim"
	-- Language Server completions
	use "nvim-lua/completion-nvim"
	do
		local cmd = vim.cmd
		local map = vim.api.nvim_set_keymap
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
			map("n", shortcut, "<cmd>lua vim.lsp.buf." .. name .. "()<CR>", {noremap = true, silent = true})
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
		cmd("autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost * lua require\"lsp_extensions\".inlay_hints{prefix = \"\", highlight = \"NonText\"}")
	end

	-- Show git blame info on the current line
	use "APZelos/blamer.nvim"
	do
		vim.g.blamer_enabled = 1
	end

	-- Switch between relative and absolute numbers
	use "jeffkreeftmeijer/vim-numbertoggle"

	-- Show buffers in the tabline
	use "ap/vim-buftabline"

	-- Show and remove extra whitespace
	use "ntpeters/vim-better-whitespace"
	do
		-- Strip all whitespace on save, disable with :DisableStripWhitespaceOnSave
		vim.g.strip_whitespace_on_save = 1
	end

	-- Highlight f & t symbols
	use "unblevable/quick-scope"
	do
		-- Trigger a highlight in the appropriate direction when pressing these keys
		vim.g.qs_highlight_on_keys = {"f", "F", "t", "T"}
	end

	-- Highlight color text
	use "norcalli/nvim-colorizer.lua"
	do
		local colorizer = require "colorizer"

		colorizer.setup()
	end

	-- Add rainbow parentheses
	use "luachen1990/rainbow"
	do
		vim.g.rainbow_active = 1
	end

	-- Code snippets
	use "SirVer/ultisnips"
	do
		vim.g.UltiSnipsExpandTrigger = "<c-s>"
		vim.g.UltiSnipsJumpForwardTrigger = "<c-b>"
		vim.g.UltiSnipsJumpBackwardTrigger = "<c-z>"
		-- Split the window
		vim.g.UltiSnipsEditSplit = "vertical"
	end

	-- Fuzzy find
	use {"junegunn/fzf.vim", requires = {"junegunn/fzf"}}
	do
		local map = vim.api.nvim_set_keymap

		-- Map shortcuts
		map("", "<C-p>", ":GFiles<CR>", {})
		map("!", "<C-p>", ":GFiles<CR>", {})
		map("", "<C-.>", ":FZF<CR>", {})
		map("!", "<C-.>", ":FZF<CR>", {})

		-- Use bat for FZF previews
		vim.g.fzf_files_options = "--preview \"bat {}\""
	end

	-- Rust
	use "rust-lang/rust.vim"
	-- Rust crate versions
	use "mhinz/vim-crates"
	do
		local cmd = vim.cmd

		-- Autoformat Rust on save
		vim.g.rustfmt_autosave = 1

		-- Show outdated crates in Cargo.toml
		cmd("autocmd BufRead Cargo.toml call crates#toggle()")
	end

	-- TOML syntax
	use "cespare/vim-toml"

	-- RON syntax
	use "ron-rs/ron.vim"

	-- Keep track of the time spent programming with wakatime
	use "wakatime/vim-wakatime"
end)

--[[ Global Options ]]
do
	local o = vim.o

	-- Always use UTF-8
	o.encoding = "utf-8"

	-- Automatically reload files changed outside of vim
	o.autoread = true

	-- Don't wait 4 seconds for a popup to show
	o.updatetime = 1000

	-- Set the title in the terminal
	o.title = true

	-- Where to store the undo files
	o.undodir = "~/.config/nvim/undo"

	-- Show live preview of substitutions
	o.inccommand = "split"

	-- Set the minimal width of the window
	o.winwidth = 80

	-- Set the terminal colors needed for the colorizer
	o.termguicolors = true
end

--[[ Window Options ]]
do
	local wo = vim.wo

	-- Display the line numbers sidebar
	wo.number = true
	wo.relativenumber = true

	-- Highlight the current line
	wo.cursorline = true
	wo.cursorcolumn = true

	-- Automatically hide some symbols (mainly markdown)
	wo.conceallevel = 2

	-- Always show the sign column
	wo.signcolumn = "yes"
end

--[[ Buffer Options ]]
do
	local bo = vim.bo

	-- Save undo across all sessions
	bo.undofile = true

	-- Don't use swap files
	bo.swapfile = false
end

--[[ Auto Commands ]]
do
	local cmd = vim.cmd

	-- Create an autocommand group
	-- TODO: replace with https://github.com/neovim/neovim/pull/12378
	local function create_augroup(autocmds, name)
		cmd("augroup " .. name)
		cmd("autocmd!")
		for _, autocmd in ipairs(autocmds) do
			cmd("autocmd " .. autocmd)
		end
		cmd("augroup END")
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
	local map = vim.api.nvim_set_keymap

	-- Use jj instead of <esc>
	map("i", "jj", "<esc>", {noremap = true})
	map("i", "<esc>", "", {noremap = true})

	-- Move across wrapped lines like regular lines
	-- Go to the first non-blank character of a line
	map("n", "0", "^", {noremap = true})
	-- Just in case you need to go to the very beginning of a line
	map("n", "^", "0", {noremap = true})
end
