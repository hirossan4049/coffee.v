import socket

def detect_method(uri):
    data=""
    header_parts = {
            'HTCPCP' : '200 OK',
            'Cache-Control' : 'private',
            'Content-Type' : 'message/coffeepot',
    }

    if 'BREW' in uri:
        for k,v in header_parts.items():
            data+=str(k)+":"+str(v)+"\r\n"
        data+="\r\nstart\r\n"

    elif 'GET' in uri:
        data+="418 - I\'m a tea pod.\r\n"

    else:
        data+="Bad request!!\n"

    return data

http_response = """
HTTP/1.1 200 OK
Content-Type: text/html

<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Page Title</title>
  </head>
  <body>
    <h1>Hello, World</h1>
  </body>
</html>
"""

# AF = IPv4 という意味
# TCP/IP の場合は、SOCK_STREAM を使う
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    # IPアドレスとポートを指定
    s.bind(('127.0.0.1', 50007))
    # 1 接続
    s.listen(1)
    # connection するまで待つ
    while True:
        # 誰かがアクセスしてきたら、コネクションとアドレスを入れる
        conn, addr = s.accept()
        with conn:
            while True:
                # データを受け取る
                data = conn.recv(1024)
                if not data:
                    break
                query = data.decode('utf-8','replace')
                print(query)
                if query.find('HTCPCP') != -1 and query.find('coffee') != -1:
                    res = detect_method(query)
                elif query.find("HTTP"):
                    res = http_response
                else:
                    res = "None"
                print(res)
                #print('data : {}, addr: {}'.format(data.decode('utf-8','replace'), addr))
                # クライアントにデータを返す(b -> byte でないといけない)
                conn.sendall(res.encode())
