#set-strictmode -version latest

function install-nerd-fonts {
    scoop bucket add nerd-fonts
    sudo scoop install (dir ~\scoop\buckets\nerd-fonts\*.json | %{ $_.name.replace('.json', '') })
}

# from https://stackoverflow.com/a/422529/14582
Function Parse-IniFile ($file) {
    $ini = @{}

    # Create a default section if none exist in the file. Like a java prop file.
    $section = "NO_SECTION"
    $ini[$section] = @{}

    switch -regex -file $file {
        "^\[(.+)\]$" {
            $section = $matches[1].Trim()
            $ini[$section] = @{}
        }
        "^\s*([^#].+?)\s*=\s*(.*)" {
            $name, $value = $matches[1..2]
            # skip comments that start with semicolon:
            if (!($name.StartsWith(";"))) {
                $ini[$section][$name] = $value.Trim()
            }
        }
    }
    $ini
}
