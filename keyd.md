# Keyd

Keyd is a nice program for remapping keys on linux. 

I use it to remap:

* capslock to control on hold and escape on tap.
* left alt key to be super key

## Run

```
sudo stow --target=/ keyd
```

## Commands

At first install.
```sh
sudo systemctl enable keyd --now
```

When modifying a file.
```sh
sudo keyd reload
```

