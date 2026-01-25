-- Base16 colorscheme for Neovim

-- Set background mode for light themes
vim.o.background = "light"

require('base16-colorscheme').setup({
    base00 = '{{base00}}',
    base01 = '{{base01}}',
    base02 = '{{base02}}',
    base03 = '{{base03}}',
    base04 = '{{base04}}',
    base05 = '{{base05}}',
    base06 = '{{base06}}',
    base07 = '{{base07}}',
    base08 = '{{base08}}',
    base09 = '{{base09}}',
    base0A = '{{base0A}}',
    base0B = '{{base0B}}',
    base0C = '{{base0C}}',
    base0D = '{{base0D}}',
    base0E = '{{base0E}}',
    base0F = '{{base0F}}',
})

-- Disable terminal background transparency for nvim
vim.api.nvim_set_hl(0, 'Normal', { bg = '{{base00}}', fg = '{{base05}}' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '{{base00}}', fg = '{{base05}}' })

local function set_hl_multiple(groups, value)
    for _, v in pairs(groups) do
        vim.api.nvim_set_hl(0, v, value)
    end
end

vim.api.nvim_set_hl(0, 'Visual', {
    bg = '{{base02}}',
    fg = '{{base05}}',
})

set_hl_multiple({ 'TSComment', 'Comment' }, {
    fg = '{{base03}}',
})

set_hl_multiple({ 'TSMethod', 'Method' }, {
    fg = '{{base0D}}',
})

set_hl_multiple({ 'TSFunction', 'Function' }, {
    fg = '{{base0E}}',
})

vim.api.nvim_set_hl(0, 'Keyword', {
    fg = '{{base0E}}',
})

vim.api.nvim_set_hl(0, 'MsgArea', {
    bg = '{{base01}}',
    fg = '{{base0D}}',
})
