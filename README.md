# Dotfiles

### Usage

```bash
cargo install dotter

git clone git@github.com:tversteeg/dotfiles.git ~/.dotfiles

cd ~/.dotfiles
dotter
```

### Applying new udev rules

```bash
dotter && sudo udevadm control --reload-rules && sudo udevadm trigger
```
