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
      .map load # keymap

#-------------------------------------------------------------------------------

  # Automatically load new keymaps.
  subs.add atom.workspace.observeTextEditors (editor) ->
    keymap = editor.getPath()
    editor.onDidSave -> if valid keymap
      load keymap

  subs.add atom.commands.add 'body',
    'modular-keymaps:open': ->
      open [ keymaps, resolve atom.configDirPath,'keymap.cson']

#-------------------------------------------------------------------------------

valid = (file) -> file.startsWith(keymaps) and /\.[cj]son$/.test file

load = (keymap, notify = false) ->
  try
    atom.keymaps.loadKeymap keymap, watch: true
  catch error
    unless atom.packages.hasActivatedInitialPackages()
      alert keymap, error
      atom.keymaps.watchKeymap keymap

open = (keymaps) -> atom.open pathsToOpen: keymaps #newWindow: true

alert = (keymap, {stack}) ->
  line = stack.match( /\d+:\d+/ )[0]
  atom.notifications.addError "Failed to load `#{keymap}`",
    detail: stack
    dismissable: true
    buttons: [
      text: "Edit Keymap"
      onDidClick: -> open "#{keymap}:#{line}"
    ]

deactivate = -> subs.dispose()
#-------------------------------------------------------------------------------
module.exports = {activate, deactivate}
