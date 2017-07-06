{CompositeDisposable} = require 'atom'
subs = new CompositeDisposable
{readdir} = require 'fs'
{resolve} = require 'path'
{exec} = require 'child_process'

keymaps = "#{atom.configDirPath}/keymaps" # folder

#-------------------------------------------------------------------------------
activate = ->
  # Load keymaps
  readdir keymaps, (err, files) ->
    throw err if err
    files
      .map (path) -> resolve keymaps, path
      .filter valid
      .map (keymap) -> atom.keymaps.loadKeymap keymap

#-------------------------------------------------------------------------------

  # Automatically reload modified keymaps.
  subs.add atom.workspace.observeTextEditors (editor) ->
    keymap = editor.getPath()
    editor.onDidSave -> if valid keymap
      atom.keymaps.reloadKeymap keymap

  subs.add atom.commands.add 'atom-workspace',
    'modular-keymaps:open': ->
      open [ keymaps,"#{atom.configDirPath}/keymap.cson"]

#-------------------------------------------------------------------------------

valid = (file) -> ///#{keymaps}/.*\.[cj]son$///.test file

open = (keymaps) -> atom.open pathsToOpen: keymaps #, newWindow: true

deactivate = -> subs.dispose()
#-------------------------------------------------------------------------------
module.exports = {activate, deactivate}
