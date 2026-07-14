# わんコレ！

犬友達をかわいく記録するための Flutter 製アプリです。  
ドッグラン、犬イベント、旅行先などで出会ったワンコの情報を、写真付きカードとして保存できます。

## 主な機能

- ワンコプロフィール登録
- 一覧カード表示
- 詳細表示
- 編集機能
- 写真の追加、差し替え、お気に入り設定
- マイワンコ管理
- 検索、絞り込み
- ローカル保存
- スマホ向け Web 表示

## 使用技術

- Flutter
- Material 3
- Riverpod
- SQLite
- SharedPreferences

## 開発環境での起動

```bash
flutter pub get
flutter run
```

## Web ビルド

```bash
flutter build web
```

ビルド後の出力先:

```text
build/web
```

## スマホで使う方法

同じ Wi-Fi に接続した状態で、PC 側で Web サーバーを起動し、スマホからその URL にアクセスします。  
詳細は [SMARTPHONE_MANUAL.md](C:/Users/hiro/dog_friend_manager/SMARTPHONE_MANUAL.md) を参照してください。

## 補足

このリポジトリには Flutter プロジェクト一式が含まれています。  
ダウンロード後に Flutter 環境があれば、ローカルで編集、ビルド、実行できます。
