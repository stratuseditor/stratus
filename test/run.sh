rm -rf $HOME/.stratus/test; mkdir -p $HOME/.stratus/test/projects
NODE_ENV='test' mocha $(find test -name '*.test.coffee') --globals i,name,cb,ret
