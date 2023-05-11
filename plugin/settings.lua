require("nvim-tree").setup {}
require("toggleterm").setup {
  direction = 'float',
}
require("trouble").setup {
  position = "right",
}
require("bufferline").setup {
  options = {
    buffer_close_icon = '',
    modified_icon = '●',
    close_icon = '',
    left_trunc_marker = '',
    right_trunc_marker = '',
    themable = true,
    diagnostics = "coc",
    sort_by = 'insert_at_end',
    hover = {
      enabled = true,
      delay = 200,
      reveal = { 'close' }
    },
    get_element_icon = function(element)
      local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(element.filetype, { default = false })
      return icon, hl
    end
  }
}
