{CompositeDisposable} = require 'atom'
subs = new CompositeDisposable
{resolve} = require 'path'
fs = require 'fs-plus'

keymaps = resolve atom.configDirPath,'keymaps' # folder

config = (get) -> atom.config.get "modular-keymaps.#{get}"

#-------------------------------------------------------------------------------
activate = ->
  fs.makeTree keymaps

  # Load keymaps
  fs.list keymaps, (error, files) ->
    #throw error if error
    files
      .map (path) -> resolve keymaps, path
      .filter valid
      .map load # keymap

#-------------------------------------------------------------------------------

  # Automatically load new keymaps.
  subs.add atom.workspace.observeTextEditors (editor) ->
    keymap = editor.getPath()
    editor.onDidSave ->
      load keymap, config 'notify' if valid keymap

  subs.add atom.commands.add 'body',
    'modular-keymaps:open': ->
      open [ keymaps, resolve atom.configDirPath,'keymap.cson']

#-------------------------------------------------------------------------------

valid = (file) -> file.startsWith(keymaps) and /\.[cj]son$/.test file

load = (keymap, notify = false) ->
  try
    atom.keymaps.loadKeymap keymap, watch: true
    if notify is true
      atom.notifications.addSuccess "`#{keymap}` was reloaded."
  catch error
    alert keymap, error
    atom.keymaps.watchKeymap keymap

open = (keymaps) -> atom.open pathsToOpen: keymaps #newWindow: true

alert = (keymap, {stack}) ->
  line = stack.match( /\d+:\d+/ )[0]
  atom.notifications.addError "Failed to load `#{keymap}`",
    detail: stack
    buttons: [
      text: "Edit Keymap"
      onDidClick: -> open "#{keymap}:#{line}"
    ]

deactivate = -> subs.dispose()
#-------------------------------------------------------------------------------
module.exports = {activate, deactivate}
