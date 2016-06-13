{readdir} = require 'fs' #mkdir
{exec} = require 'child_process'

module.exports =

	keymaps: "#{atom.configDirPath}/keymaps" # folder
	#backup: 'sync-settings.extraFiles'
	pattern: 'keymaps/*' #"{@keymaps}/*"

	subs: null
	activate: ->
		{CompositeDisposable} = require 'atom'
		@subs = new CompositeDisposable
#-------------------------------------------------------------------------------

		# Load keymaps
		readdir @keymaps, (err, files) =>
			throw err if err #console.error err
			files.forEach (keymap) =>
				if keymap.endsWith '.cson' #try
					atom.keymaps.loadKeymap "#{@keymaps}/#{keymap}"

#-------------------------------------------------------------------------------

		@subs.add atom.commands.add 'atom-workspace', #body
			'modular-keymaps:open': =>
				@open [ @keymaps,"#{atom.configDirPath}/keymap.cson"]
			#application:open-your-keymap

		# Automatically reload modified keymaps
		@subs.add atom.workspace.observeTextEditors (editor) =>
			keymap = editor.getPath()
			editor.onDidSave =>
				if keymap.startsWith(@keymaps) and keymap.endsWith '.cson'
					atom.keymaps.reloadKeymap keymap

#-------------------------------------------------------------------------------
	open: (keymaps) ->
		#exec 'atom -na "$ATOM_HOME"/keymap{s,.cson}' #-f
		atom.open pathsToOpen: keymaps #, newWindow: true
		# FIXME atom.project.removePath atom.configDirPath

	#reload: ->

#-------------------------------------------------------------------------------
	deactivate: -> @subs.dispose()
