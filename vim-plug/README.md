At a certain point, I decided it would be better to vendor vim-plug versions in
my dotfiles in case I needed a different version. Also removes that whole
"curling a random file over the Internet without looking at it first" business.

For vendoring new versions, add them to this dir:

`VERSION=0.12.0; curl -fLo $VERSION https://raw.githubusercontent.com/junegunn/vim-plug/$VERSION/plug.vim`

And don't forget to copy them to `~/.vim/autoload` in the setup scripts:

```
mkdir -p ~/.vim/autoload
VERSION=0.12.0 cp vim-plug/$VERSION ~/.vim/autoload/plug.vim
```
