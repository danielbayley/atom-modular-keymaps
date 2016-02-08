module.exports =
	#config:
	subs: null
	activate: ->
		# {name} = require './package.json' if @debug
		{mkdir,readdir} = require 'fs'
		{CompositeDisposable} = require 'atom'
#-------------------------------------------------------------------------------
		@subs = new CompositeDisposable

		ATOM_HOME = atom.configDirPath #process.env.ATOM_HOME
		keymaps = "#{ATOM_HOME}/keymaps" # folder

		#if 'sync-settings' is in atom.packages.getAvailablePackageNames()
		#isPackageLoaded 'sync-settings' #isPackageActive
		#backup = 'sync-settings.extraFiles'
		#backups = atom.config.get backup

		# Load keymaps
		readdir keymaps, (err, files) ->
			throw err if err #console.error err if @debug
			files.forEach (keymap) ->
				if keymap.endsWith '.cson' #try
					#console.log "#{name}: Loaded #{keymap} keymap." if @debug
					atom.keymaps.loadKeymap "#{keymaps}/#{keymap}"
					# FIXME
					# Settings displays 'Atom' as source if keybinding is set in keymaps/
					# as oposed to 'User' if set in keymap.cson

					# Backup keymaps
					#if keymap not in backups? #try
					#	atom.config.pushAtKeyPath backup,"#{keymaps}/#{keymap}"

#-------------------------------------------------------------------------------

		@subs.add atom.commands.add 'atom-workspace', #body
			'modular-keymaps:open': => @open [ keymaps,"#{ATOM_HOME}/keymap.cson"? ]
			##{name}:open #application:open-your-keymap

		# Automatically reload modified keymaps
		@subs.add atom.workspace.observeTextEditors (editor) ->
			keymap = editor.getPath()
			editor.onDidSave ->
				if keymap.startsWith(keymaps) and keymap.endsWith '.cson'
					#console.log "#{name}: Reloaded #{keymap} keymap." if @debug
					atom.keymaps.reloadKeymap keymap

#-------------------------------------------------------------------------------
	open: (keymaps) ->
		#exec 'atom -n "$ATOM_HOME"/keymap{s,.cson}'
		atom.open ({ pathsToOpen: keymaps, newWindow: true }) #try
		# FIXME atom.project.removePath atom.configDirPath

	#reload: ->

#-------------------------------------------------------------------------------
	deactivate: -> @subs.dispose()
