return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/nvim-cmp',
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',
        'j-hui/fidget.nvim'
    },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require('cmp_nvim_lsp')
        local capabilities = vim.tbl_deep_extend(
            'force',
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require('fidget').setup({})
        require('mason').setup({
            PATH = "prepend",
        })
        require('mason-lspconfig').setup({
            ensure_installed = {
                'lua_ls',
                'tsserver',
                'asm_lsp',
                'clangd',
                'cssls',
                'dockerls',
                'gopls',
                'htmx',
                'sqls',
                'pylsp',

        },
        handlers = {
                function(server_name)

                    require('lspconfig')[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                ["lua_ls"] = function()
                    local lspconfig = require('lspconfig')
                    lspconfig.lua_ls.setup {
                        capabilities = capablities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = {'vim', 'it', 'describe', 'before_each', 'after_each'},
                                }
                            }
                        }
                    }
                end,
            }
    
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-i>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-o>'] = cmp.mapping.confirm({select = true}),
                ['<C-Space>'] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            float = {
                focusable = false,
                style = 'minimal',
                border = 'rounded',
                source = 'always',
                header = '',
                prefix = '',
            },
        })
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
            callback = function(event)
                local map = function(keys, func, desc)
                    vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                end
                map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementations')
                map('K', vim.lsp.buf.hover, 'Hover Documentation')
            end
        })
    end
}


