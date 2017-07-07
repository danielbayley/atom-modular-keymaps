{CompositeDisposable} = require 'atom'
subs = new CompositeDisposable
{resolve} = require 'path'
fs = require 'fs-extra'

keymaps = resolve atom.configDirPath,'keymaps' # folder

#-------------------------------------------------------------------------------
activate = ->
  fs.mkdirp keymaps

  # Load keymaps
  fs.readdir keymaps, (error, files) ->
    #throw error if error
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

  subs.add atom.commands.add 'body',
    'modular-keymaps:open': ->
      open [ keymaps, resolve atom.configDirPath,'keymap.cson']

#-------------------------------------------------------------------------------


open = (keymaps) -> atom.open pathsToOpen: keymaps #, newWindow: true
valid = (file) -> file.startsWith(keymaps) and /\.[cj]son$/.test file

deactivate = -> subs.dispose()
#-------------------------------------------------------------------------------
module.exports = {activate, deactivate}
