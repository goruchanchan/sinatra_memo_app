# Sinatra　メモアプリ

## アプリ概要

Sinatra上で動くメモアプリです。次のことができます。

* メモの作成（メモタイトル、メモ内容）
* メモの修正
* メモの削除

データはPostgreSQLに保存します。

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
PostgreSQL|14.4

## インストール方法

メモアプリのデータはPostgreSQLでデータを管理しています。まずは、PostgreSQLを使えるようにします。

``` bash
# PostgreSQLのインストール
% brew install postgresql
# PostgreSQLの起動
% brew services start postgresql
# メモ用データベースの作成
% createdb memoDB
# メモ用データベースへ接続
% psql memoDB
```

データベースへ接続したら、テーブルを下記の通り作成します。

``` sql
-- テーブルの作成
memoDB=# CREATE TABLE Memos
(memo_id SERIAL NOT NULL,
title VARCHAR(100) NOT NULL,
content VARCHAR(200) NOT NULL,
PRIMARY KEY (memo_id));
-- 
```

SQLインジェクションへの対応として、`pg`gemにて動的プレースホルダ対応しています。また、保険的な対策として、DB更新用のユーザを作ります。

``` sql
-- パスワード付きユーザの作成（パスワード、ユーザ名はお好きなものをつけてください）
memoDB=# CREATE USER hoge PASSWORD 'hogehoge';
-- ユーザにDB更新に必要な権限を付与
memoDB=# GRANT SELECT, UPDATE, INSERT, DELETE ON memos TO hoge;
-- Sequenceの権限を与える
memoDB=# GRANT USAGE ON SEQUENCE memos_memo_id_seq TO hoge;
```

次にアプリをクローンしてきます。

``` bash
% git clone https://github.com/goruchanchan/sinatra_memo_app.git
% cd sinatra_memo_app
```

クローンが完了したら、`myapp.rb` 10行目のパスワード付きユーザ情報を、作成したユーザの値で更新します。

メモアプリは、Bundlerを使ってgemの依存関係を管理しています。事前にBundlerが使えるようにしておいてください。

``` bash
# bundlerのインストール
% gem install bundler
# 不要なgemをインストールしないように設定
% bundle config set --local without 'development'
# 必要なgemのインストール
% bundle install
# メモアプリの起動
% bundle exec ruby myapp.rb
```
