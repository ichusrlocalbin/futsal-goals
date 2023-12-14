# futsalのゴール数を管理

## 環境構築

* firestoreを有効に
* firebase authを有効に
  * google sign in を有効に
* [Flutter アプリに Firebase を追加する](https://firebase.google.com/docs/flutter/setup?hl=ja&platform=web) に従い、 `flutterfire configure` などを実行
* `web/index.html` の 次の `YOUR_GOOGLE_SIGN_IN_OAUTH_CLIENT_ID` を firebase authのgoogle providerの ウエブクライアントIDに書き換え
  ```
  <meta name="google-signin-client_id" content="YOUR_GOOGLE_SIGN_IN_OAUTH_CLIENT_ID.apps.googleusercontent.com">
  ```


  
