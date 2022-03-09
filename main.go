package main

import (
	"context"
	"fmt"
	"github.com/gorilla/handlers"
	"github.com/sethvargo/go-envconfig"
	"log"
	"net/http"
	"os"
)

type Config struct {
	Path string `env:"PATH,default=/srv"`
	Port int    `env:"PORT,default=80"`
}

func main() {
	ctx := context.Background()

	cfg := Config{}
	if err := envconfig.Process(ctx, &cfg); err != nil {
		log.Panicf("failed to parse environment for config: %s", err.Error())
	}

	mux := http.NewServeMux()
	mux.Handle("/", http.FileServer(http.Dir(cfg.Path)))

	log.Printf("port=%d path=%s", cfg.Port, cfg.Port)

	s := &http.Server{
		Addr:    fmt.Sprintf(":%d", cfg.Port),
		Handler: handlers.LoggingHandler(os.Stdout, mux),
	}

	if err := s.ListenAndServe(); err != nil {
		log.Panicf("failed to open http server: %s", err.Error())
	}
}
