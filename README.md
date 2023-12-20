# futsalのゴール数を管理

## what is this?

* futsalのゴールと勝敗を記録するwebアプリ
  * ゴール数の記録
  * 勝敗、引き分けの記録
  * 走行距離、メモの記録
  * 1年の結果表示
  * csvファイルへのダウンロード
  <img src="./docs/images/daily_score.png" width=33% height=33%>
  <img src="./docs/images/yearly_score.png" width=33% height=33%>
  <img src="./docs/images/score_edit.png" width=33% height=33%>
* 環境構築に従えば、自分用の環境が出来るはず

## 環境構築

### 開発環境

* flutter: 3.16.3
* node: 20.10.0 (正確な値は .node-version を参照)
* ruby: 3.2.2 (正確な値は .node-version を参照)

### firebase console

* firestoreを有効に
* firebase authを有効に
  * google sign in を有効に → ウエブクライアントID をメモっておく
* `lib/firebase_options.dart` を生成
  * [Flutter アプリに Firebase を追加する](https://firebase.google.com/docs/flutter/setup?hl=ja&platform=web) に従い、 `flutterfire configure` などを実行
* `web/index.html` の 次の `YOUR_GOOGLE_SIGN_IN_OAUTH_CLIENT_ID` を firebase authのgoogle providerの ウエブクライアントIDに書き換え
  ```
  <meta name="google-signin-client_id" content="YOUR_GOOGLE_SIGN_IN_OAUTH_CLIENT_ID.apps.googleusercontent.com">
  ```
  * [参考](https://pub.dev/packages/google_sign_in_web#web-integration)
* firestore のルール設定
  ```
  rules_version = '2';

  service cloud.firestore {
    match /databases/{database}/documents {
      // usersコレクション内のドキュメントに対するルール
      match /users/{userId}/{document=**} {
        // 読み取りと書き込みのアクセスを、認証されたユーザーの自身のドキュメントに限定する
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
  ```

### 動作確認

```bash
$ flutter run -d chrome
```

### deploy

* [Build and release a web app](https://docs.flutter.dev/deployment/web)を参考に

#### build

```bash
$ flutter build web --release --no-tree-shake-icons
```

#### firebase hosting

```bash
$ firebase init hosting
> Use an existing project
> ... (プロジェクトの選択)
? What do you want to use as your public directory? build/web
? Configure as a single-page app (rewrite all urls to /index.html)? No
? Set up automatic builds and deploys with GitHub? No
✔  Wrote build/web/404.html
? File build/web/index.html already exists. Overwrite? No
i  Skipping write of build/web/index.html

i  Writing configuration info to firebase.json...
i  Writing project information to .firebaserc...

✔  Firebase initialization complete!
$ 
```

#### deploy

```bash
$ firebase deply
```
https://<プロジェクト名>.web.app にデプロイされる

## License

MIT
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

