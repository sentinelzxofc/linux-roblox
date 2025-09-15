local ClearCommand = {}

function ClearCommand.execute(args, context)
    if context.terminal then
        context.terminal:clearTerminal()
        return ""
    else
        return "Erro: Terminal não acessível"
    end
end

ClearCommand.name = "clear"
ClearCommand.description = "Limpar a tela do terminal"
ClearCommand.usage = "/clear"
ClearCommand.examples = {
    "/clear - Limpa todo o texto do terminal"
}

return ClearCommand