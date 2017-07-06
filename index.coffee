{CompositeDisposable} = require 'atom'
subs = new CompositeDisposable
fs = require 'fs'
{sep, resolve} = require 'path'
{exec} = require 'child_process'

keymaps = resolve atom.configDirPath, 'keymaps'

#-------------------------------------------------------------------------------
activate = ->
  fs.mkdirSync keymaps if !fs.existsSync keymaps

  # Load keymaps
  fs.readdir keymaps, (err, files) ->
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
      open [ keymaps, resolve atom.configDirPath, keymap.cson ]

#-------------------------------------------------------------------------------

valid = (file) ->
  tempkeymaps = "#{keymaps}#{sep}"
  tempkeymaps = tempkeymaps.split('\\').join('\\\\') if sep is '\\'
  ///#{tempkeymaps}.*\.[cj]son$///.test file

open = (keymaps) -> atom.open pathsToOpen: keymaps #, newWindow: true

deactivate = -> subs.dispose()
#-------------------------------------------------------------------------------
module.exports = {activate, deactivate}
