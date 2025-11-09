
# todo.nvim

simple buffer plugin


## Installation

Install the plugin with your package manager.

### with [lazy.nvim](https://github.com/folke/lazy.nvim)


  ```/lua/plugins/todo.lua``` :
```lua
  return {
    "antoniofontaneti/todo.nvim",
    config = function()
        require("todo").setup({
            target_file = "~/notes/todo.md", -- path to your target file
            border = "single", -- single, rounded, double
            width = 0.5, -- width of window in % of screen size
            height = 0.5, -- height of window in % of screen size
            position = "center", -- topleft, topright, bottomleft, bottomright
            auto_save = true, -- true, false
        })
    end,
}
```
    
## Usage

- Open buffer :
 
Cmdline
```:Td```

Or set keymap
 ```vim.keymap.set("n", "<leader>td", ":Td<CR>", { silent = true }) ```

 - Close buffer :
  
In normal mode, press ```q```
 
