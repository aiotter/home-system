# おうちシステムのすべて

## 構成

準備中

## デプロイ方法

### まずは最低限の設定をデプロイ

[このブログ](https://blog.ymgyt.io/entry/homeserver-with-nixos-and-raspberrypi-install-nixos/)を参考に、まずは NixOS をインストールする。

マシンにログインし、`nixos-rebuild` を実行する。

```bash
nixos-rebuild switch --flake github:aiotter/home-system#primer
```

### クレデンシャルを環境変数に設定

[`.env.sample`](./.env.sample) を参考に、環境変数を設定する。


### 続いてすべての設定をデプロイ

[Colmena](https://github.com/zhaofengli/colmena) を使用して、ssh を通してデプロイする。
クレデンシャルを環境変数から注入する必要がある。
`home.local` ドメインを参照するので LAN の中から実行すること。

```bash
nix run github:aiotter/home-system#switch
```
