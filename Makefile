ifeq (.private, $(wildcard .private))
    PRIVATE = 1
endif

bootstrap: secrets

secrets:
ifdef PRIVATE
	@cat .env > App/FootballTables/Secrets/Secrets.swift
else
	@cp App/FootballTables/Secrets/Secrets.swift.example App/FootballTables/Secrets/Secrets.swift
endif
