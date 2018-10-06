VERSION = "1.0.5"

function fzf()
    if TermEmuSupported then
        local err = RunTermEmulator("fzf", false, true, "fzf.fzfOutput")
        if err ~= nil then
            messenger:Error(err)
        end
    else
        local output, err = RunInteractiveShell("fzf", false, true)
        if err ~= nil then
            messenger:Error(err)
        else
            local strings = import("strings")
            CurView():Open(strings.TrimSpace(output))
        end
    end
end

function fzfOutput(output)
    local strings = import("strings")
    CurView():Open(strings.TrimSpace(output))
end

MakeCommand("fzf", "fzf.fzf", 0)
