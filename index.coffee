{CompositeDisposable} = require 'atom'
subs = new CompositeDisposable
{readdir} = require 'fs'
path = require 'path'
{exec} = require 'child_process'

configDirPath = atom.configDirPath
keymaps = path.resolve configDirPath, 'keymaps'


#-------------------------------------------------------------------------------
activate = ->
  # Load keymaps
  readdir keymaps, (err, files) ->
    throw err if err

    out = files
      .map (fpath) -> path.resolve keymaps, fpath
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

tempkeymaps = keymaps
if path.sep is '\\'
  tempkeymaps = keymaps + '\\'
  tempkeymaps = tempkeymaps.split('\\').join('\\\\')
else
  tempkeymaps = keymaps + '/'
validregex = ///#{tempkeymaps}.*\.[cj]son$///

valid = (file) -> validregex.test file

open = (keymaps) -> atom.open pathsToOpen: keymaps #, newWindow: true

deactivate = -> subs.dispose()
#-------------------------------------------------------------------------------
module.exports = {activate, deactivate}
