# Sinatra　メモアプリ

## アプリ概要

Sinatra上で動くメモアプリです。次のことができます。

* メモの作成（メモタイトル、メモ内容）
* メモの修正
* メモの削除

データはテキスト形式(.txt)で保存します。

## アプリの使い方

下記コマンドでアプリを起動します。

```bash
bundle exec ruby myapp.rb
```

アプリ起動後は、下記のような画面が表示されます。

* トップ画面（ http://localhost:4567/ ）
  ![image.png](https://www.evernote.com/l/AZCJujylOFFA152sXWpwHk2E8w_XqkNVZoUB/image.png)
* メモ登録画面（ http://localhost:4567/memos ）
  ![image.png](https://www.evernote.com/l/AZDDax7y3p1KdZkHX2krEtCc3r8uRAgTlH8B/image.png)

  メモタイトル、メモ内容は必ず入力してください。空コンテンツがあるとトップ画面がエラー状態になります。空コンテンツ対策していません😅

* メモ詳細表示画面（ http://localhost:4567/memos/{memo_id} ）
  ![!image.png](https://www.evernote.com/l/AZCFo73bSaZNW6ct51BsbrDdCwe_pztfKo4B/image.png)
* メモ編集画面（ http://localhost:4567/memos/{memo_id}/edit ）
  ![image.png](https://www.evernote.com/l/AZDCo4CeACZB4ZpwZl1_etZCkg7BplpRxDUB/image.png)

## 動作確認環境

項目|バージョン情報
---|---
OS|macOS Monterey（ver. 12.4）
ruby|3.1.0p0
Bunler|2.3.5

## インストール方法

メモアプリは、Bundlerを使ってgemの依存関係を管理しています。事前にBundlerが使えるようにしておいてください。

``` bash
git clone https://github.com/goruchanchan/sinatra_memo_app.git

cd sinatra_memo_app
# コンテンツ格納用ディレクトリを作成します
mkdir db

bundle install
bundle exec ruby myapp.rb
```
