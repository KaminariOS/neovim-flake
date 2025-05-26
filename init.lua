vim.api.nvim_create_augroup("jump_last_position", { clear = true })
vim.opt.clipboard:append("unnamedplus")

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

-- Remap splits navigation to just CTRL + hjkl
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })

-- Make adjusting split sizes a bit more friendly
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

-- Map Ctrl+j to Esc in various modes
local modes = { "n", "i", "v", "s", "x", "o", "l" }
for _, mode in ipairs(modes) do
  vim.keymap.set(mode, "<C-j>", "<Esc>", { noremap = true, silent = true })
end

-- Map Ctrl+j to Ctrl+c in command-line mode
vim.keymap.set("c", "<C-j>", "<C-c>", { noremap = true, silent = true })

-- Map Ctrl+j to exit terminal mode
vim.keymap.set("t", "<C-j>", "<C-\\><C-n>", { noremap = true, silent = true })

-- Map Ctrl+Shift+j (Ctrl-S-j) to Esc in various modes
for _, mode in ipairs(modes) do
  vim.keymap.set(mode, "<C-S-j>", "<Esc>", { noremap = true, silent = true })
end

-- Map Ctrl+Shift+j to Ctrl+c in command-line mode
vim.keymap.set("c", "<C-S-j>", "<C-c>", { noremap = true, silent = true })

-- Map Ctrl+Shift+j to exit terminal mode
vim.keymap.set("t", "<C-S-j>", "<C-\\><C-n>", { noremap = true, silent = true })

-- Map Ctrl+k to Esc in various modes
for _, mode in ipairs(modes) do
  vim.keymap.set(mode, "<C-k>", "<Esc>", { noremap = true, silent = true })
end

-- Map Ctrl+k to Ctrl+c in command-line mode
vim.keymap.set("c", "<C-k>", "<C-c>", { noremap = true, silent = true })

-- Map Ctrl+k to exit terminal mode
vim.keymap.set("t", "<C-k>", "<C-\\><C-n>", { noremap = true, silent = true })

-- Map Ctrl+F to toggle NvimTree
vim.keymap.set("n", "<C-F>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

for _, mode in ipairs(modes) do
  vim.keymap.set(mode, "<C-e>", "<Cmd>wq<CR>", { noremap = true, silent = true })
end

-- Array of file names indicating root directory. Modify to your liking.
local root_names = { '.git', 'Makefile', 'CMakeList.txt', 'flake.nix', 'package.json', 'Cargo.lock'}

-- Cache to use for speed up (at cost of possibly outdated results)
local root_cache = {}

local set_root = function()
  -- Get directory path to start search from
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then return end
  path = vim.fs.dirname(path)

  -- Try cache and resort to searching upward for root directory
  local root = root_cache[path]
  if root == nil then
    local root_file = vim.fs.find(root_names, { path = path, upward = true })[1]
    if root_file == nil then return end
    root = vim.fs.dirname(root_file)
    root_cache[path] = root
  end

  -- Set current directory
  vim.fn.chdir(root)
end

local root_augroup = vim.api.nvim_create_augroup('MyAutoRoot', {})
vim.api.nvim_create_autocmd('BufEnter', { group = root_augroup, callback = set_root })


-- Create an autocommand group to avoid duplicate autocommands
vim.api.nvim_create_augroup("AutoSaveAndNotify", { clear = true })

-- Save on leaving Insert mode if the buffer is modified, then notify
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

-- Also save on losing focus if the buffer is modified, then notify
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


vim.api.nvim_create_autocmd({ "TextChanged"}, {
  group = "AutoSaveAndNotify",
  pattern = "*",
  callback = function()
	if vim.fn.mode() ~= "i" and vim.bo.modified then
      vim.cmd("write")
      vim.notify("Auto-saved", vim.log.levels.INFO)
    end
  end,
})

vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(), { bufnr })

vim.keymap.set("n", "<leader>ca", ":lua require('crates').show_popup()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>bd", ":bd<CR>", { noremap = true, silent = true })
