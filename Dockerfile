FROM python:3.7-alpine

# uwsgiをinstallするときにc コンパイラ必要でキレ散らかした
RUN apk add gcc build-base linux-headers

RUN pip install flask uwsgi

COPY . /app

WORKDIR /app

# ここはdocker実行する際に docker run flask_uwgsi xxxx とかで上書きできる
# 上記のxxxxに何も入力しなかった際に実行されるコマンド
CMD [ "uwsgi", "--ini", "myapp.ini" ]
