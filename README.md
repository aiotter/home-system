# おうちシステムのすべて

## 初期設定

[このブログ](https://blog.ymgyt.io/entry/homeserver-with-nixos-and-raspberrypi-install-nixos/)を参考に、まずは NixOS をインストールする。

## 初回のデプロイ

マシンにログインし、nixos-rebuild を実行する。

```bash
nixos-rebuild --flake github:aiotter/home-system#home
```

## 2 回目以降のデプロイ

[colmena](https://github.com/zhaofengli/colmena) を使用して、ssh を通してリモートでデプロイできる。
home.local ドメインを参照するので、LAN の中から実行すること。

```bash
nix run github:aiotter/home-system -- apply --reboot
```
