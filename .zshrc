export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

alias git-create-branch='f() { 
    if [[ $# -ne 2 ]]; then
        echo "Objetivo: Criar uma nova branch a partir da branch base, atualizando-a se necessário.";
        echo "Uso: git-create <branch_base> <nova_branch>";
    else
        if [[ $(git rev-parse --abbrev-ref HEAD) != $1 ]]; then
            git checkout $1;
            git pull origin $1;
        fi;
        git checkout -b $2;
        unset -f f;
    fi;
}; f'

alias git-merge-branch='f() { 
    if [[ $# -ne 2 ]]; then
        echo "Objetivo: Atualizar e fazer merge da branch de origem para a branch de destino.";
        echo "Uso: git-merge <branch_origem> <branch_destino>";
    else
        echo "Atualizando a branch $1";
        git checkout $1;
        git pull origin $1;

        echo "Atualizando a branch $2";
        git checkout $2;
        git pull origin $2;

        echo "Fazendo merge da branch $1 para $2";
        git checkout $2;
        git merge $1;
        unset -f f;
    fi;
}; f'

alias git-remote='f() { 
    if [[ $# -ne 0 ]]; then
        echo "Objetivo: Identificar o endereço remoto de um repositório Git.";
        echo "Uso: git-remote";
    else
        remote=$(git remote get-url --all origin 2>/dev/null)
        if [ -z "$remote" ]; then
            echo "Erro: O repositório não tem um remoto chamado 'origin' configurado."
        else
            echo "Endereço remoto do repositório:"
            echo "$remote"
        fi
        unset -f f;
    fi;
}; f'

alias git-change-remote='f() { 
    if [[ $# -ne 1 ]]; then
        echo "Objetivo: Trocar o endereço remoto do repositório Git.";
        echo "Uso: git-change-remote <novo_endereco>";
    else
        novo_endereco=$1
        git remote set-url origin $novo_endereco
        echo "Endereço remoto alterado para: $novo_endereco"
        unset -f f;
    fi;
}; f'

alias git-delete-branch='f() { 
    if [[ $# -ne 1 ]]; then
        echo "Objetivo: Deletar uma branch local e remota.";
        echo "Uso: git-delete-branch <nome_da_branch>";
    else
        branch_name=$1

        echo "Deletando a branch local: $branch_name";
        git branch -d $branch_name;

        echo "Deletando a branch remota: $branch_name";
        git push origin --delete $branch_name;

        unset -f f;
    fi;
}; f'

alias git-delete-branch-local='f() { 
    if [[ $# -ne 1 ]]; then
        echo "Objetivo: Deletar uma branch local.";
        echo "Uso: git-delete-branch <nome_da_branch>";
    else
        branch_name=$1

        echo "Deletando a branch local: $branch_name";
        git branch -d $branch_name;

        unset -f f;
    fi;
}; f'

alias git-link-remote='f() { 
    if [[ $# -ne 1 ]]; then
        echo "Objetivo: Vincular um repositório local a um repositório remoto no GitHub.";
        echo "Uso: git-vincular-remoto <url_do_repositorio>";
    else
        repo_url=$1

        git init
        git remote add origin $repo_url
        git add .
        git commit -m "feat(projeto): Primeiro commit"
        git branch -M main
        git push -u origin main

        unset -f f;
    fi;
}; f'

export PATH=$PATH:~/.local/bin

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


# pnpm
export PNPM_HOME="/home/richard/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
