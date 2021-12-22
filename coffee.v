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
    additive []string
}

struct TeapotHeader {
mut:
	content_type string
	accept_additions []string
}

struct Context {
mut:
	log log.Log
}

fn main() {
	mut ctx := Context{}
    ctx.log = log.Log{}
    ctx.log.set_level(.info)

    println("
         (    (   (      (
         )    )      )    )
         (____(_____(_____(___
         l                   l
         l                   l____
         l                 ___   l
         l                l   l   l
         l                l   l   l
         l                 l__l   l
         l                    ____l
         \\__________________/
               __  __
     ___ ___  / _|/ _| ___  ___      __   __
    / __/ _ \\| |_| |_ / _ \\/ _ \\     \\ \\ / /
   | (_| (_) |  _|  _|  __/  __/  _   \\ V /
    \\___\\___/|_| |_|  \\___|\\___| (_)   \\_/

    ")
    mut l := net.listen_tcp(.ip6, ':$port') or { panic("error") }

    ctx.log.info("start server localhost:$port")

    for {
        mut conn := l.accept() or {
            panic("panic")
            continue 
        }
        //go ctx.handle_conn(mut conn)
        ctx.handle_conn(mut conn)
    }
}

[manualfree]
fn (mut ctx Context) handle_conn(mut conn net.TcpConn) {
    conn.set_read_timeout(3000) // fxime
    conn.set_write_timeout(3000) // fixme
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

    parsed_scheme := parse_scheme(scheme) or { 
        ctx.request_http(mut conn)
        return 
    }
	println(method)
    println(parsed_scheme)

	mut body := ""

    for {
        mut bodyline := reader.read_line() or { break }
		if bodyline != "" {
			body += bodyline + "\n"
		}
    }

    if protocol == "HTTP" {
        ctx.request_http(mut conn)
    } else if protocol == "HTCPCP" {
		header := parse_header(body) or {
			ctx.request_http(mut conn)
			return
		}
		println(header)
        conn.write("$parsed_scheme.pot_tag ok;)\n".bytes()) or {}
	ctx.log.info("HTCPCP: 200")
    }

}                       

fn (mut ctx Context) request_http(mut conn net.TcpConn) {
    data := os.read_file("html/418.html") or {
        ctx.log.error("cannnot read html/418.html")
        return
    }
    conn.write(("\
HTTP/1.1 418 OK
Content-Type: text/html\n
    " + data).bytes()) or {}
	ctx.log.info("HTTP: 418")
}

fn parse_request_line(s string) (string, string, string) {
	words := s.split(' ')
	if words.len != 3 {
		return "", "", ""
	}
	method := words[0]
	target := words[1]
	version := words[2]
	return method, target, version
}

fn parse_scheme(s string) ?TeapotScheme {
    sc := s.split('://')
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
    
    mut additive := []string{}
    if ta.len == 2 {
        // not found additive
        additive = ta[1].split('&') // rfc2324で定義されていない？
    }

    pot_tag := ta[0]

    return TeapotScheme {
        scheme: sc[0]
        host: host
        pot_tag: pot_tag
        additive: additive
    }
}

fn parse_header(s string) ?TeapotHeader {
    lines := s.split("\n")

	mut content_type := ""
	mut additions := []string{}

	for line in lines {
		items := line.split(":")
		key, value := items[0] or { continue }.replace(" ", ""), items[1] or { continue }.replace(" ", "")

		match key {          
			"Content-Type" { content_type = value }
			"Accept-Additions" { additions = value.split(",") }
			else {}
		}
	}
	return TeapotHeader{
		content_type: content_type
		accept_additions: additions
	}
}

