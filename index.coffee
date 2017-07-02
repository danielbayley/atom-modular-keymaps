{CompositeDisposable} = require 'atom'
subs = new CompositeDisposable
{readdir, statSync} = require 'fs'
{sep, resolve} = require 'path'
{exec} = require 'child_process'

configDirPath = atom.configDirPath
keymaps = resolve configDirPath, 'keymaps'


#-------------------------------------------------------------------------------
activate = ->
  loadAllKeymaps = (rootPath) ->
    readdir rootPath, (err, pathNames) ->
      throw err if err

      fullPaths = pathNames
        .map (name) -> resolve rootPath, name

      fullPaths
        .filter validDir
        .map (dir) ->
          loadAllKeymaps dir

      fullPaths
        .filter valid
        .map (keymap) ->
          atom.keymaps.loadKeymap keymap

  loadAllKeymaps keymaps


validDir = (fullPath) ->
  stats = statSync fullPath
  gitDir = ///.*\.git$///.test fullPath
  return stats.isDirectory() and not gitDir

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
