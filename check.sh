GREEN=$(tput setaf 2)
# YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
NC="$(tput sgr0)"

width=28
errors=0

header() {
    printf "\n🔍 %s\n" "$GREEN $1 $NC"
}

checkTools() {
    cmd=$1
    package=${cmd}

    if [ "$2" != "" ]; then
        package=$2
    fi

    if command -v "$cmd" >/dev/null; then
        status="[✔️]"
        color="$GREEN"
    else
        errors=1
        status="[!]"
        color="$RED"
    fi

    printf "%-${width}s %s%s%s\n" "$package" "$color" "$status" "$NC"
}

echo "🔎 emacs-starter installaction checker 🔎"
header "Requirements"
checkTools "emacs"
checkTools "fd"
checkTools "just"
checkTools "mise"
checkTools "pre-commit"
checkTools "prettier"

###############################################################################
# languages support
###############################################################################
#
if [ "$IDEM_ANSIBLE_SUPPORT" == "true" ]; then
    header "Ansible support"
    checkTools "ansible"
fi

if [ "$IDEM_COPILOT_SUPPORT" == "true" ]; then
    header "Copilot support"
    checkTools "copilot-language-server"
fi

if [ "$IDEM_DOCKERFILE_SUPPORT" == "true" ]; then
    header "Dockerfile support"
    checkTools "docker-langserver" "dockerfile-language-server"
fi

if [ "$IDEM_GO_SUPPORT" == "true" ]; then
    header "Go support"
    checkTools "go"
fi

if [ "$IDEM_JAVASCRIPT_SUPPORT" == "true" ]; then
    header "Javascript support"
    checkTools "node"
    checkTools "npm"
fi

if [ "$IDEM_JSON_SUPPORT" == "true" ]; then
    header "json support"
    checkTools "vscode-json-language-server" "vscode-json-languageserver"
fi

if [ "$IDEM_LEDGER_SUPPORT" == "true" ]; then
    header "ledger support"
    checkTools "hledger"
    checkTools "ledger"
fi

if [ "$IDEM_LATEX_SUPPORT" == "true" ]; then
    checkTools "gs"
    checkTools "pdflatex"
    header "latex support"
fi

if [ "$IDEM_LUA_SUPPORT" == "true" ]; then
    header "lua support"
    checkTools "lua"
    checkTools "lua-language-server"
fi

if [ "$IDEM_MAKE_SUPPORT" == "true" ]; then
    header "make support"
    checkTools "make"
fi

if [ "$IDEM_MARKDOWN_SUPPORT" == "true" ]; then
    header "markdown support"
    checkTools "go-grip"
    checkTools "markdownlint"
    checkTools "pandoc"
    checkTools "proselint"
fi

if [ "$IDEM_NIX_SUPPORT" == "true" ]; then
    header "nix support"
    checkTools "nixfmt"
fi

if [ "$IDEM_PYTHON_SUPPORT" == "true" ]; then
    header "python support"
    checkTools "black"
    checkTools "isort"
    checkTools "pipenv"
    checkTools "poetry"
    checkTools "pyflakes"
    checkTools "pytest"
    checkTools "python3" "python"
    checkTools "ty"
    checkTools "uv"
fi

if [ "$IDEM_RUST_SUPPORT" == "true" ]; then
    header "rust support"
    checkTools "cargo-clippy" "clippy"
    checkTools "rust-analyzer"
    checkTools "rustfmt"
fi

if [ "$IDEM_SCALA_SUPPORT" == "true" ]; then
    header "scala support"
    checkTools "metals"
    checkTools "sbt"
    checkTools "scalafmt"
fi

if [ "$IDEM_SH_SUPPORT" == "true" ]; then
    header "sh support"
    checkTools "bash-language-server"
    checkTools "bashdb"
    checkTools "shellcheck"
    checkTools "shfmt"
fi

if [ "$IDEM_TERRAFORM_SUPPORT" == "true" ]; then
    header "terraform support"
    checkTools "terraform"
    checkTools "terraform-ls"
fi

if [ "$IDEM_YAML_SUPPORT" == "true" ]; then
    header "yaml support"
    checkTools "yaml-language-server"
fi

if [ ! "$errors" -eq 0 ]; then
    echo "⚠️ Please verify your installation"
    exit 1
fi
