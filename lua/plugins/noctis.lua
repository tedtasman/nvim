local M = {
    "talha-akram/noctis.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.api.nvim_create_autocmd("ColorSchemePre", {
            pattern = "noctis*",
            callback = function()
                vim.cmd("highlight clear")
            end,
        })

        vim.cmd.colorscheme("noctis_bordo")
    end,
}

return { M }
