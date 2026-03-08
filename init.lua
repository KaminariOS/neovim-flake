vim.api.nvim_create_augroup("jump_last_position", { clear = true })

if vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")

  local function copy_reg(reg)
    local orig = osc52.copy(reg)
    return function(lines, regtype)
      vim.fn.setreg(reg, table.concat(lines, "\n"), regtype)
      orig(lines, regtype)
    end
  end

  vim.g.clipboard = {
    name = "OSC 52 with register sync",
    copy = {
      ["+"] = copy_reg("+"),
      ["*"] = copy_reg("*"),
    },
    paste = {
      ["+"] = function()
        return vim.fn.getreg("+"), "v"
      end,
      ["*"] = function()
        return vim.fn.getreg("*"), "v"
      end,
    },
  }

  vim.o.clipboard = "unnamedplus"
end

vim.api.nvim_create_autocmd("BufReadPost", {
  group = "jump_last_position",
  callback = function()
    local last_pos = vim.fn.line([['"]])
    local last_line = vim.fn.line("$")
    if last_pos > 0 and last_pos <= last_line then
      vim.cmd([[normal! g'"]])
    end
  end,
})

vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })
vim.keymap.set("n", "<C-Left>", ":vertical resize +3<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-Right>", ":vertical resize -3<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-Up>", ":resize +3<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-Down>", ":resize -3<CR>", { noremap = true, silent = true })

vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "CursorHold", "FocusGained" }, {
  pattern = "*",
  callback = function()
    vim.cmd("checktime")
  end,
})

vim.opt.autowriteall = true

local modes = { "n", "i", "v", "s", "x", "o", "l" }
for _, mode in ipairs(modes) do
  vim.keymap.set(mode, "<C-j>", "<Esc>", { noremap = true, silent = true })
  vim.keymap.set(mode, "<C-S-j>", "<Esc>", { noremap = true, silent = true })
  vim.keymap.set(mode, "<C-k>", "<Esc>", { noremap = true, silent = true })
  vim.keymap.set(mode, "<C-e>", "<Cmd>wq<CR>", { noremap = true, silent = true })
end

vim.keymap.set("c", "<C-j>", "<C-c>", { noremap = true, silent = true })
vim.keymap.set("c", "<C-S-j>", "<C-c>", { noremap = true, silent = true })
vim.keymap.set("c", "<C-k>", "<C-c>", { noremap = true, silent = true })

vim.keymap.set("t", "<C-j>", "<C-\\><C-n>", { noremap = true, silent = true })
vim.keymap.set("t", "<C-S-j>", "<C-\\><C-n>", { noremap = true, silent = true })
vim.keymap.set("t", "<C-k>", "<C-\\><C-n>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-F>", "<Cmd>Neotree toggle<CR>", { noremap = true, silent = true })

local root_names = { ".git", "Makefile", "CMakeLists.txt", "flake.nix", "package.json", "Cargo.lock" }
local root_cache = {}

local function set_root()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return
  end

  path = vim.fs.dirname(path)

  local root = root_cache[path]
  if root == nil then
    local root_file = vim.fs.find(root_names, { path = path, upward = true })[1]
    if root_file == nil then
      return
    end

    root = vim.fs.dirname(root_file)
    root_cache[path] = root
  end

  vim.fn.chdir(root)
end

local root_augroup = vim.api.nvim_create_augroup("MyAutoRoot", {})
vim.api.nvim_create_autocmd("BufEnter", { group = root_augroup, callback = set_root })

vim.api.nvim_create_augroup("AutoSaveAndNotify", { clear = true })

vim.api.nvim_create_autocmd("InsertLeave", {
  group = "AutoSaveAndNotify",
  pattern = "*",
  callback = function()
    if vim.bo.modified then
      vim.cmd("write")
      vim.notify("File saved (InsertLeave)", vim.log.levels.INFO)
    end
  end,
})

vim.api.nvim_create_autocmd("FocusLost", {
  group = "AutoSaveAndNotify",
  pattern = "*",
  callback = function()
    if vim.bo.modified then
      vim.cmd("write")
      vim.notify("File saved (FocusLost)", vim.log.levels.INFO)
    end
  end,
})

vim.api.nvim_create_autocmd("TextChanged", {
  group = "AutoSaveAndNotify",
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "i" and vim.bo.modified then
      vim.cmd("write")
      vim.notify("Auto-saved", vim.log.levels.INFO)
    end
  end,
})

vim.keymap.set("n", "<leader>ca", function()
  require("crates").show_popup()
end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>bd", ":bd<CR>", { noremap = true, silent = true })
