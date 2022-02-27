ifeq (.private, $(wildcard .private))
    PRIVATE = 1
endif

bootstrap: secrets

secrets:
ifdef PRIVATE
	@cat .env > FootballTables/Secrets/Secrets.swift
else
	@cp FootballTables/Secrets/Secrets.swift.example FootballTables/Secrets/Secrets.swift
endif
