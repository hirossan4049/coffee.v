//
// CREATED BY HIROSSAN4049.
//

import io
import os
import log
import net


const (
    port = 2525
)

//const (
//    error_418 = 
//)


struct TeapotScheme {
mut:
    scheme string      
    host string
    pot_tag string
    additive ?[]string
}


fn main() {
    mut log := log.Log{}
    log.set_level(.info)

    println("
               __  __
     ___ ___  / _|/ _| ___  ___      __   __
    / __/ _ \\| |_| |_ / _ \\/ _ \\     \\ \\ / /
   | (_| (_) |  _|  _|  __/  __/  _   \\ V /
    \\___\\___/|_| |_|  \\___|\\___| (_)   \\_/

    ")
    mut l := net.listen_tcp(.ip6, ':$port') or { panic("error") }

    log.info("start server localhost:$port")

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
    method, scheme, version := parse_request_line(line)

    protocol := version.split("/")[0]

    for {
        mut body := reader.read_line() or { return }
        println(body)

        if reader.end_of_stream {
            break
        }
    }
    

    if protocol == "HTTP" {
        request_http(mut conn)
    } else if protocol == "HTCPCP" {

    }

}

fn request_http(mut conn net.TcpConn) {
    data := os.read_file("html/418.html") or {
        panic("cannnot read html/418.html")
        return
    }
    conn.write(("\
HTTP/1.1 418 OK
Content-Type: text/html\n
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

fn parse_scheme(s string) ?TeapotScheme {
    sc := s.split(':')
    if sc.len != 2 {
        return none
    }

    items := sc[1].split("/")
    if items.len != 2 {
        return none
    }

    host := items[0]
    tag_additive := items[1] // pot tag & Additive
    ta := tag_additive.split("?")
    
    if ta.len == 1 {
        // not found additive
    }

    pot_tag := ta[0]

    return TeapotScheme {
        scheme: sc[0]
        host: host
        pot_tag: pot_tag
        //additive: additive
    }
}
