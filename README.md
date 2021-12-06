# coffee.v

## Example

### server

```bash
$ v run coffee.v
```

### client

```bash
$ nc 127.0.0.1 2525 << EOS
BREW coffee://127.0.0.1:2525/pot-1 HTCPCP/1.0

Content-Type: message/coffeepot
Accept-Additions: cream

EOS
```


## License

MIT.
