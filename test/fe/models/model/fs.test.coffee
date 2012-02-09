should = require 'should'
Model  = require '../../../../server/fe/models/model/fs'

class SpaceAlien extends Model
  @modelName: "space-alien"
  modelName:  "space-alien"
  
  constructor: (options = {}) ->
    super
    { @id, @name, @heads, @favIceCream } = options
  
  attributes: ->
    return { @id, @name, @heads, @favIceCream }
  
  valid: (callback) ->
    @errors.push "Name is required"        unless @name
    @errors.push "favIceCream is required" unless @favIceCream
    return callback @errors.length == 0

(new SpaceAlien())._db()

buildAlien = ->
  return new SpaceAlien
    name:        "Prince Zorg, Conquerer of Galaxies"
    heads:       3
    favIceCream: "strawberry"

invalidAlien = ->
  a      = buildAlien()
  a.name = ""
  return a

describe "Model", ->
  describe "Model#constructor", ->
    zorg = new SpaceAlien
      name:        "Prince Zorg, Conquerer of Galaxies"
      heads:       3
      favIceCream: "strawberry"
    
    it "assigns the attributes", ->
      zorg.name.should.eql "Prince Zorg, Conquerer of Galaxies"
      zorg.heads.should.eql 3
      zorg.favIceCream.should.eql "strawberry"
  
  
  describe "Model#attributes", ->
    zorg = buildAlien().attributes()
    
    it "has all of the properties", ->
      zorg.name.should.eql "Prince Zorg, Conquerer of Galaxies"
      zorg.heads.should.eql 3
      zorg.favIceCream.should.eql "strawberry"
  
  
  describe "Model#valid", ->
    describe "valid", ->
      alien = buildAlien()
      
      it "is true", (done) ->
        alien.valid (valid) ->
          valid.should.be.true
          done()
    
    describe "invalid", ->
      it "is false & assigns errors", (done) ->
        alien = invalidAlien()
        alien.valid (valid) ->
          valid.should.be.false
          alien.errors.length.should.be.above 0
          done()
  
  
  describe "Model.find", ->
    setup = (callback) ->
      zorg = buildAlien()
      zorg.save =>
        SpaceAlien.find zorg.id, (zorg2) =>
          callback zorg, zorg2
    
    it "gets the model", (done) ->
      setup (alien1, alien2) ->
        alien1.name.should.eql alien2.name
        done()
  
  
  describe "Model.where", ->
    setup = (callback) ->
      zorg = buildAlien()
      zorg.save =>
        SpaceAlien.where favIceCream: "strawberry", (aliens) =>
          callback aliens
    
    it "finds the matching alien", (done) ->
      setup (aliens) ->
        aliens[0].favIceCream.should.eql "strawberry"
        done()
  
  
  describe "Model#save", ->
    setup = (callback) ->
      zorg = buildAlien()
      zorg.save => callback zorg
    
    it "gives the model an 'id' property", (done) ->
      setup (zorg) ->
        zorg.id.should.be.a "string"
        done()
    
    it "saves the model", (done) ->
      setup (zorg) ->
        SpaceAlien.find zorg.id, (alien) ->
          alien.name.should.eql zorg.name
          done()
  
  
  describe "Model#destroy", ->
    setup = (callback) ->
      zorg = buildAlien()
      zorg.save =>
        {id} = zorg
        zorg.destroy => callback id
    
    it "cannot be found", (done) ->
      setup (id) ->
        SpaceAlien.find id, (alien) ->
          should.not.exist alien
          done()

