
build:
	coffee -o ./lib -c ./server
	cp ./server/config.json ./lib/
	coffee -c ./client/shared/validate.coffee
	
	coffee --bare -c ./bin/stratus.coffee
	echo '#!/usr/bin/env node' | cat - ./bin/stratus.js > temp && mv temp ./bin/stratus.js
	chmod +x ./bin/stratus.js

test:
	@echo "server"
	./test/run.sh
	
	@echo "fractus-autocomplete"
	(cd client/fractus-autocomplete && mocha)
	
	@echo "fractus-autoindent"
	(cd client/fractus-autoindent && mocha)
	
	@echo "fractus-autopair"
	(cd client/fractus-autopair && mocha)

clean:
	rm -rf ./lib
	rm ./bin/stratus.js
	rm ./client/shared/validate.js


.PHONY: build test clean
