// Future versions of Hyper may add additional config options,
// which will not automatically be merged into this file.
// See https://hyper.is#cfg for all currently supported options.

module.exports = {
    config: {
      // Choose either "stable" for receiving highly polished,
      // or "canary" for less polished but more frequent updates
      updateChannel: 'stable',

      // default font size in pixels for all tabs
      fontSize: 13,

      // font family with optional fallbacks
      fontFamily: '"LiterationMono NF", Menlo, "DejaVu Sans Mono", Consolas, "Lucida Console", monospace',

      // terminal cursor background color and opacity (hex, rgb, hsl, hsv, hwb or cmyk)
      cursorColor: 'rgba(248,28,229,0.8)',

      // `BEAM` for |, `UNDERLINE` for _, `BLOCK` for █
      cursorShape: 'BEAM',

      // set to true for blinking cursor
      cursorBlink: true,

      // color of the text
      foregroundColor: '#fff',

      // terminal background color
      backgroundColor: '#000',

      // border color (window, tabs)
      borderColor: '#333',

      // custom css to embed in the main window
      css: '.splitpane_divider { background-color: #005060 !important; }',

      // custom css to embed in the terminal window
      termCSS: '',

      // set to `true` (without backticks) if you're using a Linux setup that doesn't show native menus
      // default: `false` on Linux, `true` on Windows (ignored on macOS)
      showHamburgerMenu: '',

      // set to `false` if you want to hide the minimize, maximize and close buttons
      // additionally, set to `'left'` if you want them on the left, like in Ubuntu
      // default: `true` on windows and Linux (ignored on macOS)
      showWindowControls: '',

      // custom padding (css format, i.e.: `top right bottom left`)
      padding: '12px 14px',

      // the full list. if you're going to provide the full color palette,
      // including the 6 x 6 color cubes and the grayscale map, just provide
      // an array here instead of a color map object
      colors: {
        black: '#000000',
        red: '#ff0000',
        green: '#33ff00',
        yellow: '#ffff00',
        blue: '#0066ff',
        magenta: '#cc00ff',
        cyan: '#00ffff',
        white: '#d0d0d0',
        lightBlack: '#808080',
        lightRed: '#ff0000',
        lightGreen: '#33ff00',
        lightYellow: '#ffff00',
        lightBlue: '#0066ff',
        lightMagenta: '#cc00ff',
        lightCyan: '#00ffff',
        lightWhite: '#ffffff'
      },

      // the shell to run when spawning a new session (i.e. /usr/local/bin/fish)
      // if left empty, your system's login shell will be used by default
      //
      // Windows
      // - Make sure to use a full path if the binary name doesn't work
      // - Remove `--login` in shellArgs
      //
      // Bash on Windows
      // - Example: `C:\\Windows\\System32\\bash.exe`
      //
      // Powershell on Windows
      // - Example: `C:\\WINDOWS\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`
      shell: 'C:\\WINDOWS\\System32\\WindowsPowerShell\\v1.0\\powershell.exe',

      // for setting shell arguments (i.e. for using interactive shellArgs: ['-i'])
      // by default ['--login'] will be used
      shellArgs: [],

      // for environment variables
      env: {},

      // set to false for no bell
      bell: 'SOUND',

      // if true, selected text will automatically be copied to the clipboard
      copyOnSelect: true,

      // if true, on right click selected text will be copied or pasted if no
      // selection is present (true by default on Windows)
      // quickEdit: true

      // URL to custom bell
      // bellSoundURL: 'http://example.com/bell.mp3',

      // https://github.com/zeit/hyper/issues/3617
      webGLRenderer: false,

      paneNavigation: {
        debug: false,
        hotkeys: {
          navigation: {
            up: 'ctrl+alt+k',
            down: 'ctrl+alt+j',
            left: 'ctrl+alt+h',
            right: 'ctrl+alt+l'
          },
          jump_prefix: 'ctrl+alt', // completed with 1-9 digits
          permutation_modifier: 'shift', // Added to jump and navigation hotkeys for pane permutation
          maximize: 'ctrl+alt+z'
        },
        showIndicators: false, // Show pane number
        indicatorPrefix: '^⌥', // Will be completed with pane number
        indicatorStyle: { // Added to indicator <div>
          position: 'absolute',
          top: 0,
          left: 0,
          fontSize: '10px'
        },
        focusOnMouseHover: false,
        inactivePaneOpacity: 0.5 // Set to 1 to disable inactive panes dimming
      }

      // for advanced config flags please refer to https://hyper.is/#cfg
    },

    // a list of plugins to fetch and install from npm
    // format: [@org/]project[#version]
    // examples:
    //   `hyperpower`
    //   `@company/project`
    //   `project#1.0.1`
    plugins: [
      "hyper-ligatures",
      "hyper-cursor-fade",
      "hyper-material",
      "hyper-pane"
    ],

    // in development, you can create a directory under
    // `~/.hyper_plugins/local/` and include it here
    // to load it and avoid it being `npm install`ed
    localPlugins: [],

    keymaps: {
      "window:devtools": "ctrl+shift+i",
      "window:reload": "ctrl+shift+r",
      "window:reloadFull": "ctrl+shift+f5",
      "window:preferences": "ctrl+,",
      "window:hamburgerMenu": "alt",
      "plugins:update": "ctrl+shift+u",

      "zoom:reset": "ctrl+0",
      "zoom:in": "ctrl+=",
      "zoom:out": "ctrl+-",

      "window:new": "ctrl+shift+n",
      "window:minimize": "ctrl+shift+m",

      "window:close": [
        "alt+f4"
      ],

      "tab:new": "ctrl+shift+t",

      "window:new": "ctrl+shift+n",
      "window:minimize": "ctrl+shift+m",

      "tab:jump:prefix": "ctrl",
      "tab:next": "ctrl+tab",
      "tab:prev": "ctrl+shift+tab",
      "pane:next": "",
      "pane:prev": "",
      "pane:splitVertical": "ctrl+alt+|",
      "pane:splitHorizontal": "ctrl+alt+-",
      "pane:close": "ctrl+shift+w",

      "editor:undo": "ctrl+shift+z",
      "editor:redo": "ctrl+shift+y",
      "editor:cut": "ctrl+shift+x",
      "editor:copy": "ctrl+shift+c",
      "editor:paste": "ctrl+shift+v",

      // the defaults for these interfere with posh handlers
      "editor:break": "",
      "editor:selectAll": "",
      "editor:deletePreviousWord": "",
      "editor:deleteNextWord": "",
      "editor:deleteBeginningLine": "",
      "editor:deleteEndLine": "",
      "editor:movePreviousWord": "",
      "editor:moveNextWord": "",
      "editor:moveBeginningLine": "",
      "editor:moveEndLine": "",

      // don't like these
      "editor:clearBuffer": "",
      "window:zoom": "",
      "window:toggleFullScreen": "",
    }
  };
