# おうちシステムのすべて

## 構成

準備中

## デプロイ方法

### 初回のデプロイ

[このブログ](https://blog.ymgyt.io/entry/homeserver-with-nixos-and-raspberrypi-install-nixos/)を参考に、まずは NixOS をインストールする。

マシンにログインし、`nixos-rebuild` を実行する。

```bash
nixos-rebuild switch --flake github:aiotter/home-system#home
```

### 2 回目以降のデプロイ

[Colmena](https://github.com/zhaofengli/colmena) を使用して、ssh を通して簡単にデプロイできる。
`home.local` ドメインを参照するので LAN の中から実行すること。

```bash
nix run github:aiotter/home-system -- apply --reboot
```
