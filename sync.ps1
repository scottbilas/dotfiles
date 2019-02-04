pushd ~/dotfiles
try {
    Parse-IniFile .gitmodules | % values | ?{ $_.url -and $_.url.startswith('git') } | %{
        write-host "** $($_.path) **"
        g -C $_.path push
        write-host
    }
    '** dotfiles **'
    g push
}
finally { popd }
