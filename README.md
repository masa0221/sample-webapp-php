# nginx + php-fpm + mysql の webアプリ
コンテナで動くサンプル用のWebアプリケーションです。

![screen-shot](./docs/images/screen-shot.png)

```
+-----------+      +-----------+      +---------+ 
| webserver | <--> |    app    | <--> |   db    | 
|  (nginx)  |      | (php-fpm) |      | (mysql) | 
+-----------+      +-----------+      +---------+ 
```
※ webserver <---> app のやり取りはUNIXドメインソケットを使用

## 構造
```
❯ tree
.
├── README.md
├── compose.yaml                       # docker compose のためのファイル
├── docker                             # docker: コンテナイメージを作成するために必要なファイルを配置
│   ├── nginx                          # nginx: nginxイメージのためのファイルを配置
│   │   ├── Dockerfile
│   │   └── conf
│   │       ├── conf.d
│   │       │   ├── default.conf
│   │       │   └── upstream.conf
│   │       └── nginx.conf
│   └── php-fpm                        # php-fpm: php-fpmイメージのためのファイルを配置
│       ├── Dockerfile
│       └── conf
│           └── php-fpm.d
│               └── zz-docker.conf
└── src                                # src: ソースコードを配置
    ├── app                            # app: エントリーポイントのphpから読み込まれるphpを配置
    │   ├── app.php
    │   └── template
    │       └── index.tpl.php
    └── public                         # public: ドキュメントルートにするディレクトリ
        └── index.php                  # エントリーポイントになるphp

12 directories, 11 files
```

## コンテナイメージのビルド方法

```sh
cd sample-webapp-php
```

```sh
docker compose build
```

結果
```
❯ docker image ls | grep -E '^webapp-|^REPOSITORY'
REPOSITORY                          TAG        IMAGE ID       CREATED          SIZE
webapp-nginx                        latest     1079966c89c7   24 minutes ago   43.5MB
webapp-php                          latest     b44ced50d28c   24 minutes ago   78.2MB
```

### 変数を指定してビルド
```sh
TAG=v0.1.0 docker compose build
```
```sh
REGISTRY_HOST=123456789012.dkr.ecr.ap-northeast-1.amazonaws.com docker compose build
```

### サービスを指定してビルド
```sh
docker compose build webserver
```
```sh
docker compose build app
```


## 起動 / 停止
### 起動
```sh
docker compose up -d
```

```
❯ docker compose ps
NAME                            IMAGE                 COMMAND                   SERVICE     CREATED          STATUS                    PORTS
sample-webapp-php-app-1         webapp-php:latest     "docker-php-entrypoi…"   app         33 seconds ago   Up 26 seconds (healthy)   9000/tcp
sample-webapp-php-db-1          mysql:8.0             "docker-entrypoint.s…"   db          33 seconds ago   Up 32 seconds (healthy)   3306/tcp, 33060/tcp
sample-webapp-php-webserver-1   webapp-nginx:latest   "/docker-entrypoint.…"   webserver   33 seconds ago   Up 21 seconds             0.0.0.0:8080->80/tcp
```

[http://127.0.0.1:8080](http://127.0.0.1:8080) へアクセスするとHTMLコンテンツがレスポンスされる
```
❯ curl -i http://127.0.0.1:8080
HTTP/1.1 200 OK
Server: nginx/1.25.3
Date: Thu, 15 Aug 2024 23:57:15 GMT
Content-Type: text/html; charset=UTF-8
Transfer-Encoding: chunked
Connection: keep-alive
X-Powered-By: PHP/8.3.10

<!doctype html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://cdn.tailwindcss.com/3.0.0"></script>
</head>
<body class="bg-gray-50 flex items-center justify-center min-h-screen">
  <div class="bg-white p-10 rounded-lg shadow-lg">
    <h1 class="text-4xl font-bold underline text-gray-900">Hello! Docker Compose!</h1>
    <p class="mt-4 text-gray-600">PHP version: 8.3.10</p>
    <p class="mt-4 text-gray-600">MySQL version: 8.0.39</p>
  </div>
</body>
</html>
```

### 停止
```sh
docker compose down
```

## Kubernetes で動かす場合
以下を参照してください。  
[https://github.com/masa0221/sample-webapp-php-manifests](https://github.com/masa0221/sample-webapp-php-manifests)


## LICENSE
Apache License 2.0
