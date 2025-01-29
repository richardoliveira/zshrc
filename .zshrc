export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

alias python='python3'

ccm() {
    git diff | cody chat --stdin -m "Write a commit message for this diff"
}

# Adicionar ao arquivo ~/.zshrc ou ~/.bashrc

# 1. Criar branch a partir de outra com pull automático
git_create_branch() {
    if [ "$1" = "-h" ]; then
        echo "Uso: gcb <branch_origem> <nova_branch>"
        echo "Exemplo: gcb main feature/nova-funcionalidade"
        echo "Cria uma nova branch a partir de outra, fazendo pull automático da branch de origem"
        return 0
    fi
    if [ "$#" -ne 2 ]; then
        echo "Uso: gcb <branch_origem> <nova_branch>"
        echo "Use 'gcb -h' para mais informações"
        return 1
    fi
    git checkout "$1" && \
    git pull origin "$1" && \
    git checkout -b "$2"
}
alias gcb='git_create_branch'

# 2. Apagar branch local
git_delete_branch_local() {
    if [ "$1" = "-h" ]; then
        echo "Uso: gdbl <nome_da_branch>"
        echo "Exemplo: gdbl feature/old-branch"
        echo "Apaga uma branch local (force delete)"
        return 0
    fi
    if [ "$#" -ne 1 ]; then
        echo "Uso: gdbl <nome_da_branch>"
        echo "Use 'gdbl -h' para mais informações"
        return 1
    fi
    git branch -D "$1"
}
alias gdbl='git_delete_branch_local'

# 3. Apagar branch remota e local com confirmação
git_delete_branch_remote() {
    if [ "$1" = "-h" ]; then
        echo "Uso: gbdr <nome_da_branch>"
        echo "Exemplo: gbdr feature/old-branch"
        echo "Apaga uma branch tanto localmente quanto remotamente (após confirmação)"
        return 0
    fi
    if [ "$#" -ne 1 ]; then
        echo "Uso: gbdr <nome_da_branch>"
        echo "Use 'gbdr -h' para mais informações"
        return 1
    fi
    read -p "Tem certeza que deseja apagar a branch $1 remotamente? (s/N) " confirm
    if [[ $confirm =~ ^[Ss]$ ]]; then
        git push origin --delete "$1" && \
        git branch -D "$1" && \
        echo "Branch $1 removida localmente e remotamente"
    else
        echo "Operação cancelada"
    fi
}
alias gbdr='git_delete_branch_remote'

# 4. Facilitar add, commit e amend
git_add_commit() {
    if [ "$1" = "-h" ]; then
        echo "Uso: gac <mensagem_do_commit>"
        echo "Exemplo: gac \"feat: adiciona nova funcionalidade\""
        echo "Adiciona todas as alterações e faz commit com a mensagem especificada"
        echo ""
        echo "Outros aliases relacionados:"
        echo "gaca  - Adiciona alterações e faz commit --amend (permite editar mensagem)"
        echo "gacan - Adiciona alterações e faz commit --amend sem editar mensagem"
        return 0
    fi
    if [ "$#" -lt 1 ]; then
        echo "Uso: gac <mensagem_do_commit>"
        echo "Use 'gac -h' para mais informações"
        return 1
    fi
    git add . && git commit -m "$*"
}
alias gac='git_add_commit'

git_add_commit_amend() {
    if [ "$1" = "-h" ]; then
        echo "Uso: gaca"
        echo "Adiciona todas as alterações e faz commit --amend (abre editor para editar mensagem)"
        return 0
    fi
    git add . && git commit --amend
}
alias gaca='git_add_commit_amend'

git_add_commit_amend_no_edit() {
    if [ "$1" = "-h" ]; then
        echo "Uso: gacan"
        echo "Adiciona todas as alterações e faz commit --amend mantendo a mensagem anterior"
        return 0
    fi
    git add . && git commit --amend --no-edit
}
alias gacan='git_add_commit_amend_no_edit'

# 5. Rebase interativo com pull automático
git_rebase_interactive() {
    if [ "$1" = "-h" ]; then
        echo "Uso: gri <branch_base>"
        echo "Exemplo: gri main"
        echo "Faz checkout na branch base, puxa as alterações,"
        echo "retorna para a branch atual e inicia rebase interativo"
        return 0
    fi
    if [ "$#" -ne 1 ]; then
        echo "Uso: gri <branch_base>"
        echo "Use 'gri -h' para mais informações"
        return 1
    fi
    current_branch=$(git symbolic-ref --short HEAD)
    git checkout "$1" && \
    git pull origin "$1" && \
    git checkout "$current_branch" && \
    git rebase -i "$1"
}
alias gri='git_rebase_interactive'

# 6. Fetch com prune
git_fetch() {
    if [ "$1" = "-h" ]; then
        echo "Uso: gf"
        echo "Atualiza referências remotas e remove branches obsoletas (git fetch -p)"
        return 0
    fi
    git fetch -p
}
alias gf='git_fetch'

# 7. Listar branches locais
git_list_local() {
    if [ "$1" = "-h" ]; then
        echo "Uso: gll"
        echo "Lista todas as branches locais"
        echo "Opções:"
        echo "  -v    Mostra último commit de cada branch"
        return 0
    fi
    if [ "$1" = "-v" ]; then
        git branch -v
    else
        git branch
    fi
}
alias gll='git_list_local'

# 8. Listar branches remotas
git_list_remote() {
    if [ "$1" = "-h" ]; then
        echo "Uso: glr"
        echo "Lista todas as branches no repositório remoto"
        echo "Opções:"
        echo "  -v    Mostra último commit de cada branch"
        return 0
    fi
    if [ "$1" = "-v" ]; then
        git branch -r -v
    else
        git branch -r
    fi
}
alias glr='git_list_remote'

# 9. Verificar branches locais que não existem no remoto
git_check_cleanup() {
    if [ "$1" = "-h" ]; then
        echo "Uso: gcc"
        echo "Lista branches locais que não existem no repositório remoto"
        echo "Útil para identificar branches que podem ser removidas localmente"
        echo "Atualiza primeiro o fetch para garantir informações atualizadas"
        return 0
    fi
    
    echo "Atualizando referências remotas..."
    git fetch -p
    
    echo -e "\nBranches que existem apenas localmente:"
    for branch in $(git branch --format "%(refname:short)"); do
        if ! git branch -r | grep -q "origin/$branch$"; then
            # Obtém a data do último commit da branch
            last_commit_date=$(git log -1 --format="%ai" "$branch" 2>/dev/null)
            if [ -n "$last_commit_date" ]; then
                echo -e "$branch\t(Último commit: $last_commit_date)"
            else
                echo "$branch"
            fi
        fi
    done
}
alias gcc='git_check_cleanup'

# 10. Lista todas as branches (locais e remotas)
git_log_all() {
    if [ "$1" = "-h" ]; then
        echo "Uso: gl [-v]"
        echo "Lista todas as branches locais e remotas em um único comando"
        echo ""
        echo "Por padrão mostra:"
        echo "  - Branches locais (prefixo: nenhum)"
        echo "  - Branches remotas (prefixo: origin/)"
        echo ""
        echo "Opções:"
        echo "  -v    Mostra último commit de cada branch"
        echo ""
        echo "Nota: Uma mesma branch pode aparecer duas vezes se existir local e remotamente"
        echo "      Para ver apenas branches locais use: gll"
        echo "      Para ver apenas branches remotas use: glr"
        return 0
    fi
    if [ "$1" = "-v" ]; then
        echo "=== Branches Locais ==="
        git branch -v
        echo -e "\n=== Branches Remotas ==="
        git branch -r -v
    else
        echo "=== Branches Locais ==="
        git branch
        echo -e "\n=== Branches Remotas ==="
        git branch -r
    fi
}
alias gl='git_log_all'

# 11. Comandos básicos do git
git_status() {
    if [ "$1" = "-h" ]; then
        echo "Uso: gs"
        echo "Mostra o status do repositório git (git status)"
        return 0
    fi
    git status
}
alias gs='git_status'

git_push() {
    if [ "$1" = "-h" ]; then
        echo "Uso: gp [branch]"
        echo "Exemplo: gp ou gp main"
        echo "Envia alterações para o repositório remoto"
        return 0
    fi
    if [ "$#" -eq 0 ]; then
        git push
    else
        git push origin "$1"
    fi
}
alias gp='git_push'

git_pull() {
    if [ "$1" = "-h" ]; then
        echo "Uso: gpl [branch]"
        echo "Exemplo: gpl ou gpl main"
        echo "Puxa alterações do repositório remoto"
        return 0
    fi
    if [ "$#" -eq 0 ]; then
        git pull
    else
        git pull origin "$1"
    fi
}
alias gpl='git_pull'

git_checkout() {
    if [ "$1" = "-h" ]; then
        echo "Uso: gco <branch>"
        echo "Exemplo: gco main"
        echo "Muda para a branch especificada"
        return 0
    fi
    if [ "$#" -ne 1 ]; then
        echo "Uso: gco <branch>"
        echo "Use 'gco -h' para mais informações"
        return 1
    fi
    git checkout "$1"
}
alias gc='git_checkout'

# Help geral - lista todos os comandos disponíveis
git_help() {
    if [ "$1" = "-v" ]; then
        echo "=== Git Aliases - Ajuda Detalhada ==="
        echo ""
        echo "Gerenciamento de Branches:"
        echo "  gcb  <origem> <nova>   - Cria branch nova a partir de outra (com pull)"
        echo "  gc   <branch>          - Muda para a branch especificada"
        echo "  gdbl <branch>          - Deleta branch local (com confirmação)"
        echo "  gbdr <branch>          - Deleta branch remota e local (com confirmação)"
        echo ""
        echo "Listagem e Verificação:"
        echo "  gll                    - Lista branches locais"
        echo "  glr                    - Lista branches remotas"
        echo "  gl                     - Lista todas as branches (locais e remotas)"
        echo "  gcc                    - Verifica branches que só existem localmente"
        echo ""
        echo "Commits e Updates:"
        echo "  gac  <mensagem>        - Git add e commit"
        echo "  gaca                   - Git add e commit amend (edita mensagem)"
        echo "  gacan                  - Git add e commit amend (mantém mensagem)"
        echo "  gri  <branch>          - Rebase interativo com pull automático"
        echo ""
        echo "Comandos Básicos:"
        echo "  gf                     - Fetch com prune"
        echo "  gs                     - Status"
        echo "  gp  [branch]           - Push (opcional: especificar branch)"
        echo "  gpl [branch]           - Pull (opcional: especificar branch)"
        echo ""
        echo "Para ajuda detalhada de cada comando, use: <comando> -h"
        echo "Exemplo: gcb -h"
    else
        echo "=== Git Aliases - Comandos Disponíveis ==="
        echo ""
        echo "Branches:"
        echo "  gcb  - Criar branch    | gco  - Checkout"
        echo "  gdbl - Deletar local   | gbdr - Deletar remota"
        echo ""
        echo "Listagem:"
        echo "  gll  - Listar locais   | glr  - Listar remotas"
        echo "  gl   - Listar todas    | gcc  - Verificar locais"
        echo ""
        echo "Commits:"
        echo "  gac  - Add e commit    | gaca - Commit amend"
        echo "  gacan- Amend no edit   | gri  - Rebase interativo"
        echo ""
        echo "Básicos:"
        echo "  gf   - Fetch           | gs   - Status"
        echo "  gp   - Push            | gpl  - Pull"
        echo ""
        echo "Use 'g -v' para ajuda detalhada"
        echo "Use '<comando> -h' para ajuda específica"
    fi
}
alias g='git_help'

export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/.dotnet/tools
export PATH="$PATH:/opt/mssql-tools/bin"
export PATH="$PATH:/opt/mssql-tools18/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


# pnpm
export PNPM_HOME="/home/$USER/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

export SRC_ENDPOINT="https://sourcegraph.com"
export SRC_ACCESS_TOKEN="sgp_fd1b4edb60bf82b8_e80f78894aa5cf16b19d14b084472500f748b956"
