# checkcall
Get information on outgoing and incoming call by checking NTT optical router (PR-400KI, PR-500KI)

NTT の宅内用光ルータにアクセスし，直近の通話ログをローカルファイルに書き出す Bourne shell スクリプトです。

## 動作概要
NTT の宅内用光ルータに wget でアクセスし，直近の通話ログを取得します。
ローカルのログファイルと比較し，違いがあれば新しい着信または発信があったとして IFTTT の Webhook に通知し，ローカルのログファイルに追加します。
違いがなければ何もせずに終了します。
cron に登録しておけば，新規の発着信があったときに IFTTT から通知が届くようになります。

## 設定
### IFTTT の設定
IFTTT でアプレットを作成します。LINE でメッセージを受け取る場合は以下のようにします。
1. if this then that の 'this' をクリック
1. Choose a service で 'Webhooks' を選択
1. Choose trigger で 'Receive a web request' を選択
    - Event Name に Phone Call と入力し，'Create trigger' をクリック
1. if this then that の 'that' をクリック
1. 'LINE' を選択
1. Choose action で 'Send message' を選択
    - Recipient で '1:1でLINE Notifyから通知を受け取る' または送りたいグループを選択
    - Message には次のように入力
    ```
    日時: {{Value1}}<br>
    通話時間: {{Value2}}<br>
    備考: {{Value3}}
    ```
    - 'Create action' をクリック
### スクリプトの設定
光ルータの IP アドレスを設定します。
```
URL="http://192.168.0.1/cgi-bin/mainte.cgi?st_clog"
```
光ルータにアクセスする場合のユーザとパスワードをそれぞれ設定します。
```
OPTS="--http-user=user --http-password=password --auth-no-challenge -q --tries=1 --timeout=10"
```
IFTTT で Webhook アプリを作成し，イベント名を「Phone Call」とし，スクリプトの設定と合わせておきます。
```
EVENT='Phone Call'
```

その秘密鍵の文字列を設定します。
```
SECRET_KEY='your_secret_key_for_ifttt'
```
ログを記録するファイルを作成します。
```
$ touch checkcall.log
```

## 使い方
実行して動作確認します。
```
$ bash checkcall.sh
```
ログファイルを確認します。
```
$ cat checkcall.log
```

## crontab への登録
スクリプトを /path/to/checkcall/checkcall.sh に設置したときは，crontab に次のように登録すれば 30 秒毎に発着信のチェックが行われます。
```
* * * * * cd /path/to/checkcall; for i in `seq 0 30 59`; do (sleep ${i}; sh checkcall.sh) & done;
```
