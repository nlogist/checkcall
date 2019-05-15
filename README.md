# checkcall
Get information on outgoing and incoming call by checking NTT optical router 

NTT の宅内用光ルータにアクセスし，直近の通話ログをローカルファイルに書き出す Bash スクリプトです。

## 動作概要
NTT の宅内用光ルータ (PR-400KI) に wget でアクセスし，直近の通話ログを取得します。
ローカルのログファイルと比較し，違いがあれば新しい着信または発信があったとして IFTTT の Webhook に通知し，ローカルのログファイルに追加します。
違いがなければ何もせずに終了します。
cron に登録しておけば，新規の発着信があったときに IFTTT から通知が届くようになります。

## 設定
光ルータの IP アドレスを設定します。
```
URL="http://192.168.0.1/cgi-bin/mainte.cgi?st_clog"
```
光ルータにアクセスする場合のユーザとパスワードをそれぞれ設定します。
```
OPTS="--http-user=user --http-password=password --auth-no-challenge"
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
* * * * * cd /path/to/checkcall; for i in `seq 0 30 59`; do (sleep ${i}; bash checkcall.sh) & done;
```
