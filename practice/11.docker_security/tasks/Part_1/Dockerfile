FROM golang:1.18.10

RUN mkdir /vuln
COPY main.go /vuln/main.go
RUN cd /vuln && echo "module github.com/Frichetten/CVE-2019-5736-PoC" > go.mod && go build

ENTRYPOINT ["/vuln/CVE-2019-5736-PoC"]

