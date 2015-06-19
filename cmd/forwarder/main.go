package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/heroku/log-iss/Godeps/_workspace/src/github.com/heroku/authenticater"
	"github.com/heroku/log-iss/Godeps/_workspace/src/github.com/heroku/slog"
)

type ShutdownCh chan struct{}

var Config IssConfig

func Logf(format string, a ...interface{}) {
	orig := fmt.Sprintf(format, a...)
	fmt.Printf("app=log-iss source=%s %s\n", Config.Deploy, orig)
}

func LogContext(ctx slog.Context) {
	ctx["app"] = "log-iss"
	ctx["source"] = Config.Deploy
	fmt.Println(ctx)
}

func awaitShutdownSignals(chs ...ShutdownCh) {
	sigCh := make(chan os.Signal)
	signal.Notify(sigCh, syscall.SIGTERM, syscall.SIGINT)
	for sig := range sigCh {
		Logf("ns=main at=shutdown-signal signal=%q", sig)
		for _, ch := range chs {
			ch <- struct{}{}
		}
	}
}

func main() {
	config, err := NewIssConfig()
	if err != nil {
		log.Fatalln(err)
	}

	Config = config

	auth, err := authenticater.NewBasicAuthFromString(Config.Tokens)
	if err != nil {
		log.Fatalln(err)
	}

	forwarderSet := NewForwarderSet(Config)
	forwarderSet.Start()

	shutdownCh := make(ShutdownCh)

	httpServer := NewHttpServer(Config, auth, Fix, forwarderSet.Inbox)

	go awaitShutdownSignals(httpServer.ShutdownCh, shutdownCh)

	go func() {
		if err := httpServer.Run(); err != nil {
			log.Fatalln("Unable to start HTTP server:", err)
		}
	}()

	Logf("ns=main at=start")
	<-shutdownCh
	Logf("ns=main at=drain")
	httpServer.Wait()
	Logf("ns=main at=exit")
}
