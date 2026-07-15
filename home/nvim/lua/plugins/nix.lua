local profile_bin = "/etc/profiles/per-user/" .. os.getenv("USER") .. "/bin/"

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
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
        },

        marksman = {
          mason = false,
          cmd = { profile_bin .. "marksman" },
        },

        jsonls = {
          mason = false,
          cmd = { profile_bin .. "vscode-json-language-server", "--stdio" },
        },
      },
    },
  },
}
