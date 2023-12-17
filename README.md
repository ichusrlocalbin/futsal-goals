# futsalのゴール数を管理

## 環境構築

### console

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

### deploy

* [Build and release a web app](https://docs.flutter.dev/deployment/web)を参考に

#### build

```bash
$ flutter build web
```

or

```bash
$ flutter build web --release
```

#### firebase hosting

```
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

### deploy

```bash
$ firebase deply
```
https://<プロジェクト名>.web.app にデプロイされる
