return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        terraformls = {
          mason = false, -- installed system-wide via Dockerfile
        },
      },
    },
  },
}
