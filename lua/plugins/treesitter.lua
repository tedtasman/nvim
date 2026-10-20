local parsers = {
    "javascript", "typescript", "tsx", "css", "scss", "python", "java",
    "http", "markdown", "c_sharp", "go",
    -- http required for rest.nvim
}

-- The `main` branch no longer registers filetype -> parser aliases, and core
-- only ships help/checkhealth. Without these, .cs and .tsx get no parser.
local ft_aliases = {
    c_sharp = { "cs" },
    tsx = { "typescriptreact" },
    javascript = { "javascriptreact" },
}

-- markdown is installed for other consumers but keeps the regex highlighter.
local no_highlight = { markdown = true }

local M = {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local ts = require("nvim-treesitter")
        ts.setup()

        for lang, fts in pairs(ft_aliases) do
            vim.treesitter.language.register(lang, fts)
        end

        ts.install(parsers)

        local filetypes = {}
        for _, lang in ipairs(parsers) do
            if not no_highlight[lang] then
                vim.list_extend(filetypes, vim.treesitter.language.get_filetypes(lang))
            end
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = filetypes,
            callback = function(args)
                -- install() is async; the parser may not be present on first run.
                pcall(vim.treesitter.start, args.buf)
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })

        -- Neovim's own ftplugin/markdown.lua calls vim.treesitter.start(), so
        -- leaving markdown out of the list above is not enough to opt out.
        -- Registered after the ftplugin, so this wins. Drop it to take the
        -- core default.
        vim.api.nvim_create_autocmd("FileType", {
            pattern = vim.tbl_keys(no_highlight),
            callback = function(args)
                vim.treesitter.stop(args.buf)
            end,
        })
    end,
}

return { M }
