local profile_bin = "/etc/profiles/per-user/" .. os.getenv("USER") .. "/bin/"

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          mason = false,
          cmd = { profile_bin .. "vtsls", "--stdio" },
          filetypes = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
          },
        },
        lua_ls = {
          mason = false,
          cmd = { profile_bin .. "lua-language-server" },
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
        nil_ls = {
          mason = false,
          cmd = { profile_bin .. "nil" },
        },
        gopls = {
          mason = false,
          cmd = { profile_bin .. "gopls" },
          filetypes = {
            "go",
            "gomod",
          },
        },
        marksman = {
          mason = false,
          cmd = { profile_bin .. "marksman" },
          filetypes = {
            "markdown",
          },
        },
        ruff = {
          mason = false,
          cmd = { profile_bin .. "ruff", "server" },
        },

        pyright = {
          mason = false,
          cmd = { profile_bin .. "pyright-langserver", "--stdio" },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        stylua = {
          command = profile_bin .. "stylua",
        },
        gofumpt = {
          command = profile_bin .. "gofumpt",
        },
        goimports = {
          command = profile_bin .. "goimports",
        },
        shfmt = {
          command = profile_bin .. "shfmt",
        },
      },
    },
  },
}
