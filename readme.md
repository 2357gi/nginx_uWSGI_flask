# 実験するやつ

## 概要

uwsgiを用いてflaskアプリを動かし、その前にnginxを設置して,  
動かすもの。  

大まかな流れとしては,

1. vagrantにてUbuntuの仮想マシンを立ち上げる
2. 内部でnginxを立ち上げる。
3. 内部でflaskと**flaskをunixソケット通信で動かすuWSGI**を動かす。
	- ここはdockerによりコンテナ化する.
	- socketファイルだけvagrantと共有する
4. nginxにてそのsocketを指定する
5. nginx - socket(uwsgi) - flask  実現！


おもしろ教育ポイントとしては、  
socket通信を用いてnginxとflaskが通信していることを確認するために、  
flask - uwsgiをdockerで包んで、  
socketファイルだけをhost側に受け渡してあげているところ。

host側とdocker側ではsocketファイルが存在する`tmp`ファイルしか共有していないのに  
nginxがsocket通信によりflaskにアクセスすることができている。  

**dockerのportバインド機能は用いていない。**

基本的には[Flask + uWSGI + Nginx でハローワールドするまで @ さくらのVPS (CentOS 6.6) - Qiita](https://qiita.com/morinokami/items/e0efb2ae2aa04a1b148b)から拾ってきたやつ。



## 使い方

### vagrantを立ち上げる
vagrantを起動する  
```shell
$ vagrant up
```

vagrantにsshする  

```
vagrant ssh
```
vagrantというuser名でsshできる。ちなみにパスワードは`vagrant`
現在このプロジェクトのルートディレクトリとvagrant内の`/app`がバインドしてある。  

*vagrantに関してわかんなかったらinternetにいっぱい落ちてるので漁って*

--- 以下vagrant内 ---

### 仮想マシンの状況の確認
まずvagrantにてバーチャルマシンが作られるときに`./setup.sh`によって  
nginxとdockerがインストールされている。  

いちおうnginx. dockerの確認
```
docker run hello-world

sudo nginx -t	# nginxのテストできるやつ。nginxの設定イジったら基本これ
```
*nginxに関してはPermissionなんもやってないからsudoが必要。仕事が雑なので...*

バインドされているディレクトリに移動  
```
cd /app
```


### containerの作成
Dockerfile読んでビルド  
```
cat Dockerfile

dokcer build -t uwsgi_flask .
```

### 試しにflaskだけ起動する
挙動の確認  
vagrantの5000番とcontainerの5000を共有し、flaskを実行している。
```shell
docker run --rm -p 5000:5000 -d -v `pwd`:/app uwsgi_flask python app.py

# port転送指定したので、cuurlしてみる
curl localhost:5000
```
flaskのログも確認する

```
docker logs <containerID>
```
### uwsgiを用いて起動する

docker runするときにコマンドを何も指定しなければDockerfileの`CMD`が実行される。

```
docker run --rm -d  -v /tmp:/tmp uwsgi_flask
```
ちゃんとsocketが生成されているか、vagrantと共有されているか確認

```
file /tmp/uwsgi.sock
```

### nginxの設定

nginxの設定ファイルを書いていく。   
`/etc/nginx/nginx.conf`に
```

    include /etc/nginx/conf.d/*.conf;
```

conf.d/の.confを全部インクルードする設定があると思う。  
なので普通はこれを使ってconf.dの中にユーザー設定を記述していく。  

`/etc/nginx/conf.d/default.conf`
```
server {
	# 80番で受け付けたとき
    listen	80;

	# / にアクセスが来たとき
    location / {
		# uwsgiのパラメータをインクルードする。実態は/etc/nginx/uwsgi_params.
		# uwsgiはすごいのでnginxにデフォでパラメーターファイルがよういしてあるノダ！
        include uwsgi_params;

		# ここでuwsgiのsocket(dockerと共有したもの)を指定しているノダ！
		# ポイントはhttp:/ではなく、unix:/ なのだ。socketを指定する場合はこうなのだ。
        uwsgi_pass unix:/tmp/uwsgi.sock;
    }
}
```

unixドメインソケットなのでunixをつけるのだ。unixドメインソケットとかそのあたりはググるのだ。

```
# nginx test
sudo nginx -t
```

nginxの再起動
```
sudo service nginx restart
```
(PWはググるのだ。)

## 確認
エラー履いてなかったらたいていできてるけど一応確認するのだ。  
vagrant内でlocalhost:80にcurlしたり、  
あとはvirtualマシンにも`192.168.33.10`というアドレスを振ってあるので(`./Vagrantfile`の16行目なのだ。)  
ホストでそのIPにcurlしても確認できるのだ。



