{CompositeDisposable} = require 'atom'
subs = new CompositeDisposable
{readdir, statSync} = require 'fs'
{sep, resolve} = require 'path'
{exec} = require 'child_process'

configDirPath = atom.configDirPath
keymaps = resolve configDirPath, 'keymaps'

activate = -> loadAllKeymaps keymaps

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
      .map loadKeymap

validDir = (fullPath) ->
  stats = statSync fullPath
  gitDir = ///.*\.git$///.test fullPath
  return stats.isDirectory() and not gitDir

valid = (file) ->
  tempkeymaps = keymaps + sep
  if sep is '\\'
    tempkeymaps = tempkeymaps.split('\\').join('\\\\')

  ///#{tempkeymaps}.*\.[cj]son$///.test file

loadKeymap = (keymap) ->
  try
    options =
      watch: true
    atom.keymaps.loadKeymap keymap, options
  catch error
    tempOptions =
      dismissable: false
      detail: error.stack
    atom.notifications.addError 'Failed to load `' + keymap + '`', tempOptions
    atom.keymaps.watchKeymap keymap

#-------------------------------------------------------------------------------

subs.add atom.commands.add 'atom-workspace',
  'modular-keymaps:open': ->
    mainKeymaps = configDirPath + "/keymap.cson" # file
    open [ keymaps, resolve(mainKeymaps) ]

open = (keymaps) -> atom.open pathsToOpen: keymaps #, newWindow: true

#-------------------------------------------------------------------------------

deactivate = -> subs.dispose()

#-------------------------------------------------------------------------------
module.exports = {activate, deactivate}
