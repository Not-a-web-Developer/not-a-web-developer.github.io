-- Put project's module settings here.
-- This module will be loaded when opening a project, after the user module
-- configuration.
-- It will be automatically reloaded when saved.

local config = require "core.config"

local core = require "core"
local keymap = require "core.keymap"
local config = require "core.config"
local style = require "core.style"
local syntax = require "core.syntax"
local common = require "core.common"
local DocView = require "core.docview"
local command = require "core.command"
local TreeView = require "plugins.treeview"
local keymap = require "core.keymap"
local EmptyView = require "core.emptyview"
local Doc = require "core.doc"

-- you can add some patterns to ignore files within the project
config.ignore_files = {"^%."}

-- Patterns are normally applied to the file's or directory's name, without
-- its path. See below about how to apply filters on a path.
--
-- Here some examples:
--
-- "^%." match any file of directory whose basename begins with a dot.
--
-- When there is an '/' or a '/$' at the end the pattern it will only match
-- directories. When using such a pattern a final '/' will be added to the name
-- of any directory entry before checking if it matches.
--
-- "^%.git/" matches any directory named ".git" anywhere in the project.
--
-- If a "/" appears anywhere in the pattern except if it appears at the end or
-- is immediately followed by a '$' then the pattern will be applied to the full
-- path of the file or directory. An initial "/" will be prepended to the file's
-- or directory's path to indicate the project's root.
--
-- "^/node_modules/" will match a directory named "node_modules" at the project's root.
-- "^/build.*/" match any top level directory whose name begins with "build"
-- "^/subprojects/.+/" match any directory inside a top-level folder named "subprojects".

-- You may activate some plugins on a pre-project base to override the user's settings.
-- config.plugins.trimwitespace = true

local document_width = 900 * SCALE

config.plugins.autocomplete = false
TreeView.visible = false
config.highlight_current_line = false
if system.get_file_info(USERDIR .. "/words") then
  config.plugins.spellcheck.dictionary_file = USERDIR .. "/words"
elseif system.get_file_info(DATADIR .. "/words") then
  config.plugins.spellcheck.dictionary_file = DATADIR .. "/words"
end
config.plugins.language_c = false
config.plugins.language_cpp = false
config.plugins.language_css = false
config.plugins.language_html = false
config.plugins.language_js = false
config.plugins.language_python = false
config.plugins.language_xml = false
config.plugins.linewrapping = {
  enable_by_default = true,
  mode = "word",
  guide = false,
  indent = false,
  width_override = function(docview) return math.min(document_width, docview.size.x) end
}
config.plugins.tag_highlight = false
config.transitions = false
-- override reset syntax to force all docs to be markdown.
Doc.reset_syntax = function(self)
  local header = self:get_text(1, 1, self:position_offset(1, 1, 128))
  local syn = syntax.get(self.filename or ".md", header)
  if self.syntax ~= syn then
    self.syntax = syn
    self.highlighter:soft_reset()
  end
end
local old_doc_new = Doc.new
Doc.new = function(self, ...)
  local result = old_doc_new(self, ...)
  self:reset_syntax()
  return result
end

--[[ function DocView:draw_line_gutter(line, x, y, width)
  if self.size.x > document_width then
    renderer.draw_rect(x + width - style.padding.x, y, 1, self.size.y, style.scrollbar2)
    renderer.draw_rect(x + width + style.padding.x + document_width, y, 1, self.size.y, style.scrollbar2)
  end
end
function DocView:get_gutter_width() return math.max(self.size.x - document_width, 0) / 2 end ]]

command.add(nil, {
  ["files:delete"] = function()
    core.command_view:enter("Delete file path", function(text)
      local success, err, path = common.rm(text)
      if not success then
        core.error("cannot delete file %q: %s", path, err)
      end
    end)
  end
})
