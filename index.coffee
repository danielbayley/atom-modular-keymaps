{CompositeDisposable} = require 'atom'
subs = new CompositeDisposable
{readdir} = require 'fs'
{sep, resolve} = require 'path'
{exec} = require 'child_process'

configDirPath = atom.configDirPath
keymaps = resolve configDirPath, 'keymaps'


#-------------------------------------------------------------------------------
activate = ->
  # Load keymaps
  readdir keymaps, (err, files) ->
    throw err if err

    out = files
      .map (fpath) -> resolve keymaps, fpath
      .filter valid
      .map (keymap) -> atom.keymaps.loadKeymap(keymap)
#-------------------------------------------------------------------------------

  # Automatically reload modified keymaps.
  subs.add atom.workspace.observeTextEditors (editor) ->
    keymap = editor.getPath()
    editor.onDidSave -> if valid keymap
      atom.keymaps.reloadKeymap keymap

  subs.add atom.commands.add 'atom-workspace',
    'modular-keymaps:open': ->
      mainKeymaps = configDirPath + "/keymap.cson" # file
      open [ keymaps, resolve(mainKeymaps) ]

#-------------------------------------------------------------------------------

valid = (file) ->
  tempkeymaps = keymaps + sep
  if sep is '\\'
    tempkeymaps = tempkeymaps.split('\\').join('\\\\')

  ///#{tempkeymaps}.*\.[cj]son$///.test file

open = (keymaps) -> atom.open pathsToOpen: keymaps #, newWindow: true

deactivate = -> subs.dispose()
#-------------------------------------------------------------------------------
module.exports = {activate, deactivate}
