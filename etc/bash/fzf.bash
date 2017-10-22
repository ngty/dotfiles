# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="$PATH:/usr/local/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/usr/local/opt/fzf/shell/key-bindings.bash"

# Tweaks
# Use ~~ as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER='~~'

# # Options to fzf command
# export FZF_COMPLETION_OPTS='+c -x'
#
# # Use ag instead of the default find command for listing path candidates.
# # - The first argument to the function is the base path to start traversal
# # - See the source code (completion.{bash,zsh}) for the details.
# # - ag only lists files, so we use with-dir script to augment the output
# _fzf_compgen_path() {
#   ag -g "" "$1" | with-dir "$1"
# }
#
# # Use ag to generate the list for directory completion
# _fzf_compgen_dir() {
#   ag -g "" "$1" | only-dir "$1"
# }
