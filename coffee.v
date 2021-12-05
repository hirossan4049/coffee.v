//
// CREATED BY HIROSSAN4049.
//

import io
import os
import net


fn main() {
    println("
               __  __
     ___ ___  / _|/ _| ___  ___      __   __
    / __/ _ \\| |_| |_ / _ \\/ _ \\     \\ \\ / /
   | (_| (_) |  _|  _|  __/  __/  _   \\ V /
    \\___\\___/|_| |_|  \\___|\\___| (_)   \\_/

    ")
    mut l := net.listen_tcp(.ip6, ':2525') or { panic("error") }

    for {
        mut conn := l.accept() or {
            panic("panic")
            continue 
        }
        println("==================")
        go handle_conn(mut conn)
    }
}

[manualfree]
fn handle_conn(mut conn net.TcpConn) {
    conn.set_read_timeout(300) // fxime
    conn.set_write_timeout(300) // fixme
    defer {
        conn.close() or {}
    }

    mut reader := io.new_buffered_reader(reader: conn)
    defer {
        reader.free() 
    }

    conn.write("".bytes()) or {}
    mut line := reader.read_line() or { return }
    method, target, version := parse_request_line(line)
    println(method)
    println(target)
    println(version)

    //req := http.parse_request(mut reader) or { return }
    //println(req)
    //
    data := os.read_file("html/418.html") or {
        panic("cannnot read html/418.html")
        return
    }

    conn.write(("
HTTP/1.1 418 OK
Content-Type: text/html

    " + data).bytes()) or {}
}

fn parse_request_line(s string) (string, string, string) {
	words := s.split(' ')
	if words.len != 3 {
		return "", "", ""//panic('malformed request line')
	}
	method := words[0]
	target := words[1]
	version := words[2]
	return method, target, version
}
