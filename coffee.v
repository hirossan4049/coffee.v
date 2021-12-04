
import io
import net
import net.urllib
import net.http


fn main() {
    println("hello world")
    mut l := net.listen_tcp(.ip6, ':2525') or { panic("error") }
    println(l)

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

    conn.write("
HTTP/1.1 200 OK
Content-Type: text/html

<!DOCTYPE html>
<html>
<h1>hello world</h1>
</html>
    ".bytes()) or {}
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
