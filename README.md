# わんコレ！

出会ったわんこ友達を、写真つきでかわいく記録できる Flutter 製アプリです。  
ドッグラン、イベント、旅行先で出会った犬友をカード形式で管理できます。

## 主な機能

- 犬友プロフィールの登録、編集、削除
- 写真の複数登録
- お気に入り写真の設定
- マイワンコ登録
- 検索、絞り込み
- イベント履歴、再会記録
- ローカル保存
- スマホ向け Web 表示
- PWA としてホーム画面追加

## 公開ページ

[GitHub Pages で開く](https://coronsky.github.io/wancolle/)

## ダウンロード方法

1. このリポジトリを開く
2. 右上の `Code` を押す
3. `Download ZIP` を選ぶ

Git を使う場合:

```bash
git clone https://github.com/coronsky/wancolle.git
cd wancolle
```

## 開発環境

- Flutter
- Material 3
- Riverpod
- SQLite
- SharedPreferences

## ローカル起動

```bash
flutter pub get
flutter run
```

## Web ビルド

```bash
flutter build web
```

ビルド成果物:

```text
build/web
```

## スマホで使う

- GitHub Pages を開く
- iPhone は Safari の共有メニューから `ホーム画面に追加`
- Android は Chrome のメニューから `ホーム画面に追加`

詳しい手順は [SMARTPHONE_MANUAL.md](C:/Users/hiro/dog_friend_manager/SMARTPHONE_MANUAL.md) を参照してください。
