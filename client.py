import socket
import sys

args = sys.argv

if len(args) == 4:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        # サーバを指定
        s.connect(('127.0.0.1', 2525))
        #s.connect(('www.htcpcp.net', 80))
        # サーバにメッセージを送る
        sdata = args[1] + " " + args[2] + " " + args[3]
        s.sendall(sdata.encode())
        # ネットワークのバッファサイズは1024。サーバからの文字列を取得する
        data = s.recv(1024)
        #
        print(data.decode('utf-8','replace'))
else:
    print("use 4 param(filename HTCPCP scheme method)")
